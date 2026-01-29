package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.nape.FlxNapeSprite;
import flixel.util.FlxColor;
import nape.callbacks.CbType;
import nape.dynamics.InteractionFilter;
import nape.geom.Vec2;

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

class Character extends FlxNapeSprite
{
	public static inline var GROUP_PLAYER:Int = 1 << 8;
	public static inline var GROUP_TARGET:Int = 1 << 9;
	public static inline var GROUP_BULLET:Int = 1 << 10;
	public static inline var MASK_ALL:Int = -1;

	public static var CB_PLAYER:CbType = new CbType();
	public static var CB_TARGET:CbType = new CbType();

	public var maxHealth:Float = 100;
	public var currentHealth:Float = 100;
	public var healthBar:HealthBar = null;
	public var deceleration:Float = 500; // Сила замедления (пикселей/сек²)
	public var minSpeed:Float = 0; // Минимальная скорость
	public var rotationKp:Float = 12.0; // Усиление для возврата к вертикали (рад/с² на рад)
	public var rotationKd:Float = 4.0; // Демпфирование угловой скорости (рад/с² на рад/с)
	public var rotationMaxSpeed:Float = 8.0; // Ограничение угловой скорости (рад/с)
	public var rotationSnapAngle:Float = 2 * Math.PI / 180; // Порог защёлки (рад)
	public var rotationSnapSpeed:Float = 0.1; // Порог угловой скорости (рад/с)
	public var direction = 1;

	public function new(width:Int, height:Int, xPos:Float, yPos:Float, color:FlxColor, angularVel:Float = 0, withHealthBar:Bool = false)
	{
		super();
		makeGraphic(width, height, color);
		createRectangularBody();
		antialiasing = true;
		body.angularVel = angularVel;
		scale.x = 1;
		scale.y = 1;
		setBodyMaterial(.5, .5, .5, 2);
		body.position.y = yPos;
		body.position.x = xPos;

		if (withHealthBar)
		{
			healthBar = new HealthBar(this);
			healthBar.maxHealth = maxHealth;
			healthBar.currentHealth = currentHealth;
			healthBar.updateHealthBar();
		}
	}

	public function applyDamage(damage:Float):Bool
	{
		currentHealth -= damage;
		if (healthBar != null)
		{
			healthBar.currentHealth = currentHealth;
		}

		if (currentHealth <= 0)
		{
			return true;
		}

		if (healthBar != null)
		{
			healthBar.updateHealthBar();
		}
		return false;
	}

	public function setCollision(group:Int, mask:Int, cbType:CbType):Void
	{
		body.setShapeFilters(new InteractionFilter(group, mask));
		body.cbTypes.add(cbType);
	}

	public function updateHealthBar():Void
	{
		if (healthBar != null)
		{
			healthBar.updateHealthBar();
		}
	}

	public function applyDeceleration(elapsed:Float):Void
	{
		var currentVelocity:Vec2 = body.velocity;
		var currentSpeed:Float = currentVelocity.length;

		if (currentSpeed > minSpeed)
		{
			// Вычисляем новую скорость с учетом замедления
			var newSpeed:Float = currentSpeed - deceleration * elapsed;

			if (newSpeed <= minSpeed)
			{
				// Полная остановка
				body.velocity.setxy(0, 0);
			}
			else
			{
				// Сохраняем направление, но уменьшаем скорость
				var normalizedVel:Vec2 = currentVelocity.normalise();
				body.velocity.x = normalizedVel.x * newSpeed;
				body.velocity.y = normalizedVel.y * newSpeed;
			}
		}
		else
		{
			// Полная остановка
			body.velocity.setxy(0, 0);
		}
	}

	public function applyRotationDeceleration(elapsed:Float):Void
	{
		var currentAngularVel:Float = body.angularVel; // рад/с
		var currentRotation:Float = body.rotation; // рад

		// Ошибка до вертикального положения (0 рад), нормализуем в [-PI, PI]
		var angleError:Float = -currentRotation;
		angleError = Math.atan2(Math.sin(angleError), Math.cos(angleError));

		// PD-контроллер: тянем к нулю с демпфированием
		var desiredAngularAcc:Float = rotationKp * angleError - rotationKd * currentAngularVel;
		var newAngularVel:Float = currentAngularVel + desiredAngularAcc * elapsed;

		if (newAngularVel > rotationMaxSpeed)
		{
			newAngularVel = rotationMaxSpeed;
		}
		else if (newAngularVel < -rotationMaxSpeed)
		{
			newAngularVel = -rotationMaxSpeed;
		}

		// Защёлка при достижении близости к вертикали
		if (Math.abs(angleError) <= rotationSnapAngle && Math.abs(newAngularVel) <= rotationSnapSpeed)
		{
			body.rotation = 0;
			body.angularVel = 0;		
		}
		else
		{
			body.angularVel = newAngularVel;
		}
	}
	public function updateMovementAnimation():Void
	{
		if (body.velocity.length > 0 && body.velocity.x < 0)
		{
			direction = 1;
			animation.play('moveRight');
		}
		else if (body.velocity.length > 0 && body.velocity.x > 0)
		{
			animation.play('moveLeft');
			direction = -1;
		}
		else if (body.velocity.length == 0)
		{
			if (direction == 1)
			{
				animation.play('idleRight');
			}
			else if (direction == -1)
			{
				animation.play('idleLeft');
			}
		}
	}
}
