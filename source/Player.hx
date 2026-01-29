package;

import flixel.FlxG;
import flixel.util.FlxColor;

class Player extends Character
{
	public var isSlowingDown:Bool = false;

	public function new(width:Int, height:Int, xPos:Float, yPos:Float)
	{
		super(width, height, xPos, yPos, FlxColor.MAGENTA, 0, false);
		setCollision(Character.GROUP_PLAYER, Character.MASK_ALL, Character.CB_PLAYER);
		loadGraphic("assets/images/space-marine-sprite-sheet.png", true, 250, 250);
		animation.add("moveRight", [0, 1, 2], 12, true, false);
		animation.add("moveLeft", [0, 1, 2], 12, true, true);
		animation.add('idleRight', [0], 1, false, false);
		animation.add('idleLeft', [0], 1, false, true);
		setGraphicSize(64, 64);
		updateHitbox();
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
	override public function updateMovementAnimation():Void
	{
		if (body.velocity.length > 0 && body.velocity.x > 0 || FlxG.keys.pressed.D)
		{
			direction = 1;
			animation.play('moveRight');
		}
		else if (body.velocity.length > 0 && body.velocity.x < 0 || FlxG.keys.pressed.A)
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
