package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.nape.FlxNapeSpace;
import flixel.group.FlxGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import haxe.ds.ObjectMap;
import nape.callbacks.CbType;
import nape.constraint.PivotJoint;
import nape.dynamics.InteractionGroup;
import nape.geom.AABB;
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

	public var levels:Int = 5;
	public var bricks:Array<Enemy>;
	public var shooter:Shooter;
	public var handJoint:PivotJoint;
	public var body:Body;
	public var brickHeight:Int;
	public var brickWidth:Int;

	var allPlayers = new FlxGroup();
	var level:CustomNapeTilemap;
	var firstRun:Bool = false;
	var currentLevel:String = "assets/data/level1.csv";

	var layout:FlxSprite;
	var stampedBricks:FlxGroup; // Группа для отпечатанных блоков

	override public function create()
	{

		brickHeight = 72;
		brickWidth = 64;

		super.create();

		bgColor = 0xff6ee2ff;

		layout = new FlxSprite(0,0);
		layout = layout.makeGraphic(640, 480, bgColor);
		add(layout);

		// Группа для отпечатанных блоков (выше бекграунда, но ниже активных блоков)
		stampedBricks = new FlxGroup();
		add(stampedBricks);

		FlxNapeSpace.init();
		FlxNapeSpace.drawDebug = true;
		if (Constants.oneWayType == null)
		{
			Constants.oneWayType = new CbType();
		}

		// var w:Int = FlxG.width;
		// var h:Int = FlxG.height;

		// // Initialise terrain bitmap.
		// #if flash
		// var bit = new BitmapData(w, h, true, 0x00000000);
		// bit.perlinNoise(200, 200, 2, 0x3ed, false, true, BitmapDataChannel.ALPHA, false);
		// #else
		// var bit = Assets.getBitmapData("assets/images/terrain.png");
		// #end

		// // Create initial terrain state, invalidating the whole screen.
		// terrain = new Terrain(bit, 30, 5);
		// terrain.invalidate(new AABB(0, 0, w, h), this);

		// add(terrain.sprite);
		walls = FlxNapeSpace.createWalls(0, 0, 0, 0, 10);

		loadLevel(currentLevel);

		box = new Player(64, 82, 148, 148);
		add(box);


		surrounding = new Character(64, 82, 248, 148);
		surrounding.makeGraphic(64, 82, FlxColor.RED);
		surrounding.createRectangularBody(64, 82);
		add(surrounding);

		// lazer = new FlxWeapon("lazer", box, "x", "y");

		// lazer.makePixelBullet(50, 5, 5);
		// lazer.setBulletSpeed(100);

		// add(lazer.group);

		createBricks();

		shooter = new Shooter();
		add(shooter);
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
		var xPos = brick.body.position.x - (brickWidth / 2);
		var yPos = brick.body.position.y - (brickHeight / 2);
		var stampedSprite = new FlxSprite(xPos, yPos);
		stampedSprite.loadGraphic('assets/images/blood.png', false, 64, 64, false);
		stampedSprite.scale.set(1.5, 1.5);
		stampedSprite.antialiasing = true;
		stampedBricks.add(stampedSprite);

		// Также отпечатываем на layout
		// layout.stamp(stampedSprite, cast(xPos, Int), cast(yPos, Int));
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

	function loadLevel(file:String)
	{
		currentLevel = file;

		if (level != null)
		{
			level.body.space = null;
			remove(level);
		}

		level = new CustomNapeTilemap(file, "assets/images/tiles.png", Constants.TILE_SIZE);
		level.body.setShapeMaterials(Constants.platformMaterial);
		level.spawnPoints.sort(function(_, _) return FlxG.random.bool() ? -1 : 1);
		add(level);
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
		box.updateMovementAnimation();
		for (brick in bricks)
		{
			brick.applyRotationDeceleration(elapsed);
			brick.updateMovementAnimation();
		}

		// Обновляем позиции полосок здоровья
		for (brick in bricks)
		{
			brick.updateHealthBar();
		}

		super.update(elapsed);
	}
}