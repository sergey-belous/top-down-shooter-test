package;

import flixel.util.FlxColor;
import flixel.FlxG;

class Player extends Character
{
	public var isSlowingDown:Bool = false;

	public function new(width:Int, height:Int, xPos:Float, yPos:Float)
	{
		super(width, height, xPos, yPos, FlxColor.MAGENTA, 0, false);
		setCollision(Character.GROUP_PLAYER, Character.MASK_ALL, Character.CB_PLAYER);
	}

	public function handleInput():Void
	{
		// Управление с клавиатуры - устанавливаем скорость напрямую
		if (FlxG.keys.pressed.W)
		{
			body.position.y -= 5;
			isSlowingDown = false;
		}
		if (FlxG.keys.pressed.S)
		{
			body.position.y += 5;
			isSlowingDown = false;
		}
		if (FlxG.keys.pressed.A)
		{
			body.position.x -= 5;
			isSlowingDown = false;
		}
		if (FlxG.keys.pressed.D)
		{
			body.position.x += 5;
			isSlowingDown = false;
		}

		// Если ни одна клавиша не нажата и есть движение - запускаем замедление
		if (!FlxG.keys.pressed.W && !FlxG.keys.pressed.S && !FlxG.keys.pressed.A && !FlxG.keys.pressed.D)
		{
			if (body.velocity.length > minSpeed)
			{
				isSlowingDown = true;
			}
		}
	}

	public function applyDecelerationIfNeeded(elapsed:Float):Void
	{
		if (isSlowingDown)
		{
			applyDeceleration(elapsed);
		}
	}
}
