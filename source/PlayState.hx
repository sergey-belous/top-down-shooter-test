package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.nape.FlxNapeSpace;
import flixel.group.FlxGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import haxe.ds.ObjectMap;
import nape.constraint.PivotJoint;
import nape.dynamics.InteractionGroup;
import nape.geom.AABB;
import nape.geom.Vec2;
import nape.phys.Body;
import openfl.Assets;
import openfl.display.Sprite;
import photonstorm.FlxWeapon;

class PlayState extends FlxState
{
	public var box:Player;
	public var surrounding:Character;
	public var lazer:FlxWeapon;

	public var walls:Body;

	var bomb:Sprite;
	var terrain:Terrain;

	public var deadGroup:FlxTypedGroup<FlxSprite>;
	public var maxNumber:Int;

	public var levels:Int = 40;
	public var bricks:Array<Enemy>;
	public var shooter:Shooter;
	public var handJoint:PivotJoint;
	public var body:Body;
	public var brickHeight:Int;
	public var brickWidth:Int;

	var layout:FlxSprite;
	var stampedBricks:FlxGroup; // Группа для отпечатанных блоков

	override public function create()
	{

		brickHeight = 16;
		brickWidth = brickHeight;

		super.create();

		bgColor = 0xfffa0808;

		layout = new FlxSprite(0,0);
		layout = layout.makeGraphic(640, 480, bgColor);
		add(layout);

		// Группа для отпечатанных блоков (выше бекграунда, но ниже активных блоков)
		stampedBricks = new FlxGroup();
		add(stampedBricks);

		FlxNapeSpace.init();

		var w:Int = FlxG.width;
		var h:Int = FlxG.height;

		// Initialise terrain bitmap.
		#if flash
		var bit = new BitmapData(w, h, true, 0x00000000);
		bit.perlinNoise(200, 200, 2, 0x3ed, false, true, BitmapDataChannel.ALPHA, false);
		#else
		var bit = Assets.getBitmapData("assets/images/terrain.png");
		#end

		// Create initial terrain state, invalidating the whole screen.
		terrain = new Terrain(bit, 30, 5);
		terrain.invalidate(new AABB(0, 0, w, h), this);

		add(terrain.sprite);

		shooter = new Shooter();
		add(shooter);

		walls = FlxNapeSpace.createWalls(0, 0, 640, 480, 10);

		box = new Player(32, 32, 48, 48);
		add(box);

		lazer = new FlxWeapon("lazer", box, "x", "y");
 		
		surrounding = new Character(32, 32, 48, 48, FlxColor.MAGENTA);
		add(surrounding);

		lazer.makePixelBullet(50, 5, 5);
		lazer.setBulletSpeed(100);

		add(lazer.group);

		createBricks();

		shooter.setBox(box);

		deadGroup = new FlxTypedGroup(2048);
		maxNumber = 2048;

		for (i in 0...maxNumber - 1)
		{
			var deadSprite = new FlxSprite();
			deadSprite.makeGraphic(64, 64, FlxColor.GREEN);
			deadSprite.antialiasing = true;
			deadGroup.add(deadSprite);
		}

	}

	function createBricks():Void
	{
		bricks = new Array<Enemy>();
		var brick:Enemy;

		for (i in 0...levels)
		{
			for (j in 0...(levels - i))
			{
				brick = new Enemy(brickWidth, brickHeight, (FlxG.width / 2 - brickWidth / 2 * (levels - i - 1))
					+ brickWidth * j,
					FlxG.height
					- brickHeight / 2
					- brickHeight * i
					+ 2);
				add(brick);
				bricks.push(brick);
				if (brick.healthBar != null)
				{
					add(brick.healthBar);
				}
			}
		}
	}

	// Функция для нанесения урона блоку
	public function damageBrick(brick:Enemy, damage:Float):Void
	{
		var brickIndex:Int = bricks.indexOf(brick);
		if (brickIndex != -1)
		{
			var isDead = brick.applyDamage(damage);
			if (isDead)
			{
				// Здоровье опустилось до 0 - отпечатываем блок и удаляем его
				stampBrick(brick);
				removeBrick(brickIndex);
			}
		}
	}

	// Функция для отпечатывания блока
	private function stampBrick(brick:Enemy):Void
	{
		var stampedSprite = new FlxSprite(brick.x, brick.y);
		stampedSprite.makeGraphic(brickWidth, brickHeight, FlxColor.BROWN);
		stampedSprite.antialiasing = true;
		stampedBricks.add(stampedSprite);

		// Также отпечатываем на layout
		layout.stamp(stampedSprite, Std.int(brick.x), Std.int(brick.y));
	}

	// Функция для удаления блока
	private function removeBrick(index:Int):Void
	{
		var brick:Enemy = bricks[index];

		// Удаляем из физического пространства
		brick.body.space = null;

		// Удаляем из отображения
		remove(brick);
		if (brick.healthBar != null)
		{
			remove(brick.healthBar);
		}

		// Удаляем из массивов
		bricks.remove(brick);

		// Уничтожаем объекты
		brick.destroy();
		if (brick.healthBar != null)
		{
			brick.healthBar.destroy();
		}
	}

	private function isTouchingOtherBrick(brick:Enemy, brickBodies:ObjectMap<Body, Bool>):Bool
	{
		for (arbiter in brick.body.arbiters)
		{
			var otherBody:Body = arbiter.body1 == brick.body ? arbiter.body2 : arbiter.body1;
			if (brickBodies.exists(otherBody))
			{
				return true;
			}
		}
		return false;
	}

	override public function update(elapsed:Float)
	{
		FlxNapeSpace.space.gravity.setxy(0, 0);

		box.handleInput();
		box.applyDecelerationIfNeeded(elapsed);

		var brickBodies = new ObjectMap<Body, Bool>();
		for (brick in bricks)
		{
			brickBodies.set(brick.body, true);
		}

		for (brick in bricks)
		{
			if (!isTouchingOtherBrick(brick, brickBodies))
			{
				brick.applyDeceleration(elapsed);
			}
		}

		box.applyRotationDeceleration(elapsed);
		for (brick in bricks)
		{
			brick.applyRotationDeceleration(elapsed);
		}

		// Обновляем позиции полосок здоровья
		for (brick in bricks)
		{
			brick.updateHealthBar();
		}

		// Обработка столкновений снарядов с блоками
		if (shooter.collides && shooter.collidesSpr != null)
		{
			var collisionPoint = new Vec2(shooter.collidesSpr.x, shooter.collidesSpr.y);
			var collidedBodies = FlxNapeSpace.space.bodiesInCircle(collisionPoint, 96);
			
			collidedBodies.foreach(function(body)
			{
				if (body != box.body && body != walls)
				{
					// Ищем соответствующий блок
					for (brick in bricks)
					{
						if (brick.body == body)
						{
							// Наносим урон блоку (например, 34 урона за попадание)
							damageBrick(brick, 34);
							break;
						}
					}
				}
			});

			// Убиваем снаряд после столкновения
			shooter.collidesSpr.kill();
			shooter.collides = false;
		}

		super.update(elapsed);
	}
}