package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.nape.FlxNapeSpace;
import flixel.addons.nape.FlxNapeSprite;
import flixel.group.FlxGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import nape.constraint.PivotJoint;
import nape.dynamics.InteractionGroup;
import nape.geom.AABB;
import nape.geom.Vec2;
import nape.phys.Body;
import openfl.Assets;
import openfl.display.Sprite;
import photonstorm.FlxWeapon;

// Класс для отображения здоровья
class HealthBar extends FlxSprite
{
	public var maxHealth:Float = 100;
	public var currentHealth:Float = 100;
	public var parentBrick:FlxNapeSprite;

	public function new(parent:FlxNapeSprite)
	{
		super();
		this.parentBrick = parent;
		makeGraphic(32, 4, FlxColor.GREEN);
	}

	public function updateHealthBar():Void
	{
		var healthRatio:Float = currentHealth / maxHealth;
		var barWidth:Int = Math.round(32 * healthRatio);

		var sprite = makeGraphic(32, 4, FlxColor.GREEN);

		if (healthRatio > 0.6)
		{
			sprite.makeGraphic(32, 4, FlxColor.GREEN);
		}
		else if (healthRatio > 0.3)
		{
			sprite.makeGraphic(32, 4, FlxColor.YELLOW);
		}
		else
		{
			sprite.makeGraphic(32, 4, FlxColor.RED);
		}

		// Позиционируем над родительским блоком
		setPosition(parentBrick.x, parentBrick.y - 8);
	}
}

class PlayState extends FlxState
{
	public var box:FlxNapeSprite;
	public var surrounding: FlxNapeSprite;
	public var lazer:FlxWeapon;

	public var walls:Body;

	var bomb:Sprite;
	var terrain:Terrain;

	public var deadGroup:FlxTypedGroup<FlxSprite>;
	public var maxNumber:Int;

	public var levels:Int = 30;
	public var bricks:Array<FlxNapeSprite>; 
	public var brickHealthBars:Array<HealthBar>; // Массив для хранения полосок здоровья
	public var shooter:Shooter;
	public var handJoint:PivotJoint;
	public var body:Body;
	public var brickHeight:Int;
	public var brickWidth:Int;

	public var playerDeceleration:Float = 500; // Сила замедления (пикселей/сек²)
	public var playerMinSpeed:Float = 10; // Минимальная скорость, ниже которой останавливаем
	public var isSlowingDown:Bool = false;

	var layout:FlxSprite;
	var stampedBricks:FlxGroup; // Группа для отпечатанных блоков

	public var rotationSpeed:Float = 180; // Скорость вращения (градусов/сек)
	public var rotationDeceleration:Float = 120; // Замедление вращения (градусов/сек²)
	public var rotationMinSpeed:Float = 5; // Минимальная скорость вращения
	public var isRotating:Bool = false; // Флаг активного вращения
	public var isRotationSlowing:Bool = false;

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

		shooter = new Shooter();
		add(shooter);

		walls = FlxNapeSpace.createWalls(0, 0, 640, 480, 10);

		box = new FlxNapeSprite();
		box.makeGraphic(32, 32, FlxColor.MAGENTA);
		box.createRectangularBody();
		box.antialiasing = true;
		box.scale.x = 1;
		box.scale.y = 1;
		box.flipX = FlxG.random.bool();
		box.flipY = FlxG.random.bool();
		box.setBodyMaterial(.5, .5, .5, 2);
		box.body.position.y = 48;
		box.body.position.x = 48;
		add(box);

		lazer = new FlxWeapon("lazer", box, "x", "y");
 		
		surrounding = new FlxNapeSprite();
		surrounding.makeGraphic(32, 32, FlxColor.MAGENTA);
		surrounding.createRectangularBody();
		surrounding.antialiasing = true;
		surrounding.scale.x = 1;
		surrounding.scale.y = 1;
		surrounding.setBodyMaterial(.5, .5, .5, 2);
		surrounding.body.position.y = 48;
		surrounding.body.position.x = 48;
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

	function createBricks()
	{
		bricks = new Array<FlxNapeSprite>();
		brickHealthBars = new Array<HealthBar>(); // Инициализируем массив полосок здоровья
		var brick:FlxNapeSprite;

		for (i in 0...levels)
		{
			for (j in 0...(levels - i))
			{
				brick = new FlxNapeSprite();
				brick.makeGraphic(brickWidth, brickHeight, FlxColor.BROWN);
				brick.createRectangularBody();
				brick.antialiasing = true;
				brick.body.angularVel = 10;
				brick.scale.x = 1;
				brick.scale.y = 1;
				brick.flipX = FlxG.random.bool();
				brick.flipY = FlxG.random.bool();
				brick.setBodyMaterial(.5, .5, .5, 2);
				brick.body.position.y = FlxG.height - brickHeight / 2 - brickHeight * i + 2;
				brick.body.position.x = (FlxG.width / 2 - brickWidth / 2 * (levels - i - 1)) + brickWidth * j;
				add(brick);
				bricks.push(brick);
				// Создаем полоску здоровья для каждого блока
				var healthBar = new HealthBar(brick);
				healthBar.maxHealth = 100; // Максимальное здоровье
				healthBar.currentHealth = 100; // Текущее здоровье
				healthBar.updateHealthBar();
				add(healthBar);
				brickHealthBars.push(healthBar);
			}
		}
	}

	// Функция для нанесения урона блоку
	public function damageBrick(brick:FlxNapeSprite, damage:Float):Void
	{
		var brickIndex:Int = bricks.indexOf(brick);
		if (brickIndex != -1)
		{
			var healthBar:HealthBar = brickHealthBars[brickIndex];
			healthBar.currentHealth -= damage;

			if (healthBar.currentHealth <= 0)
			{
				// Здоровье опустилось до 0 - отпечатываем блок и удаляем его
				stampBrick(brick);
				removeBrick(brickIndex);
			}
			else
			{
				// Обновляем полоску здоровья
				healthBar.updateHealthBar();
			}
		}
	}

	// Функция для отпечатывания блока
	private function stampBrick(brick:FlxNapeSprite):Void
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
		var brick:FlxNapeSprite = bricks[index];
		var healthBar:HealthBar = brickHealthBars[index];

		// Удаляем из физического пространства
		brick.body.space = null;

		// Удаляем из отображения
		remove(brick);
		remove(healthBar);

		// Удаляем из массивов
		bricks.remove(brick);
		brickHealthBars.remove(healthBar);

		// Уничтожаем объекты
		brick.destroy();
		healthBar.destroy();
	}

	private function applyDeceleration(elapsed:Float):Void
	{
		var currentVelocity:Vec2 = box.body.velocity;
		var currentSpeed:Float = currentVelocity.length;

		if (currentSpeed > playerMinSpeed)
		{
			// Вычисляем новую скорость с учетом замедления
			var newSpeed:Float = currentSpeed - playerDeceleration * elapsed;

			if (newSpeed <= playerMinSpeed)
			{
				// Полная остановка
				box.body.velocity.setxy(0, 0);
				isSlowingDown = false;
			}
			else
			{
				// Сохраняем направление, но уменьшаем скорость
				var normalizedVel:Vec2 = currentVelocity.normalise();
				box.body.velocity.x = normalizedVel.x * newSpeed;
				box.body.velocity.y = normalizedVel.y * newSpeed;
			}
		}
		else
		{
			// Полная остановка
			box.body.velocity.setxy(0, 0);
			isSlowingDown = false;
		}
	}

	private function applyRotationDeceleration(elapsed:Float):Void
	{
		var currentAngularVel:Float = box.body.angularVel;
		var currentSpeed:Float = Math.abs(currentAngularVel) * 180 / Math.PI; // Переводим в градусы/сек

		if (currentSpeed > rotationMinSpeed)
		{
			// Вычисляем новую скорость с учетом замедления
			var newSpeed:Float = currentSpeed - rotationDeceleration * elapsed;

			if (newSpeed <= rotationMinSpeed)
			{
				// Полная остановка вращения
				box.body.angularVel = 0;
				isRotationSlowing = false;
				isRotating = false;
			}
			else
			{
				// Сохраняем направление вращения, но уменьшаем скорость
				var direction:Float = currentAngularVel > 0 ? 1 : -1;
				box.body.angularVel = direction * newSpeed * Math.PI / 180;
			}
		}
		else
		{
			// Полная остановка вращения
			box.body.angularVel = 0;
			isRotationSlowing = false;
			isRotating = false;
		}
	}

	override public function update(elapsed:Float)
	{
		var mousePoint = Vec2.get(FlxG.mouse.getPosition().x, FlxG.mouse.getPosition().y);

		FlxNapeSpace.space.gravity.setxy(0, 0);

		// Управление с клавиатуры - устанавливаем скорость напрямую
		if(FlxG.keys.pressed.W) {
			box.body.position.y -= 5;
			isSlowingDown = false; // Отменяем замедление при новом вводе
		}
		if(FlxG.keys.pressed.S) {
			box.body.position.y += 5;
			isSlowingDown = false;
		}
		if(FlxG.keys.pressed.A) {
			box.body.position.x -= 5;
			isSlowingDown = false;
		}
		if(FlxG.keys.pressed.D) {
			box.body.position.x += 5;
			isSlowingDown = false;
		}

		// Если ни одна клавиша не нажата и есть движение - запускаем замедление
		if (!FlxG.keys.pressed.W && !FlxG.keys.pressed.S && !FlxG.keys.pressed.A && !FlxG.keys.pressed.D)
		{
			if (box.body.velocity.length > playerMinSpeed)
			{
				isSlowingDown = true;
			}
		}

		// Применяем замедление если оно активно
		if (isSlowingDown)
		{
			applyDeceleration(elapsed);
		}

		applyRotationDeceleration(elapsed);

		// Обновляем позиции полосок здоровья
		for (healthBar in brickHealthBars)
		{
			healthBar.updateHealthBar();
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