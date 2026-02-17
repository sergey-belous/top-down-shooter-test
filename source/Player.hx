package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxColor;

class Player extends Character
{
	public var isSlowingDown:Bool = false;
	public var moveSpeed:Float = 180;
	public var debugHitbox:FlxSprite = null;

	public function new(widthInit:Int, heightInit:Int, xPosInit:Float, yPosInit:Float)
	{
		super(widthInit, heightInit, xPosInit, yPosInit, 0, false);
		createRectangularBody(widthInit, heightInit);
		loadGraphic("assets/images/space-marine-sprite-sheet.png", true, 214, 272);
		animation.add("moveRight", [0, 1, 2], 12, true, false);
		animation.add("moveLeft", [0, 1, 2], 12, true, true);
		animation.add('idleRight', [0], 1, false, false);
		animation.add('idleLeft', [0], 1, false, true);
		setGraphicSize(widthInit, heightInit);
		width = widthInit;
		height = heightInit;
		// updateHitbox();
		// offset.set(0, 0);
		// origin.set(0, 0);
		// body.userData.sprite = this;
		// setBodyMaterial(.5, .5, .5, 2);
		// body.angularVel = 0;
		// setPosition(xPos, yPos);
		setCollision(Character.GROUP_PLAYER, Character.MASK_ALL, Character.CB_PLAYER);
		// updateHitbox();
	}

	public function handleInput():Void
	{
		// Управление с клавиатуры - задаем скорость
		var vx:Float = 0;
		var vy:Float = 0;
		if (FlxG.keys.pressed.W)
		{
			vy -= 1;
		}
		if (FlxG.keys.pressed.S)
		{
			vy += 1;
		}
		if (FlxG.keys.pressed.A)
		{
			vx -= 1;
		}
		if (FlxG.keys.pressed.D)
		{
			vx += 1;
		}

		if (vx != 0 || vy != 0)
		{
			var len = Math.sqrt(vx * vx + vy * vy);
			vx = (vx / len) * moveSpeed;
			vy = (vy / len) * moveSpeed;
			body.velocity.setxy(vx, vy);
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
		if (animation == null)
		{
			return;
		}
		var speed = body.velocity.length;
		if (speed > 0 || FlxG.keys.pressed.W || FlxG.keys.pressed.S || FlxG.keys.pressed.A || FlxG.keys.pressed.D)
		{
			if (body.velocity.x < 0 || FlxG.keys.pressed.A)
			{
				direction = -1;
			}
			else if (body.velocity.x > 0 || FlxG.keys.pressed.D)
			{
				direction = 1;
			}
			animation.play(direction > 0 ? 'moveRight' : 'moveLeft');
		}
		else
		{
			animation.play(direction > 0 ? 'idleRight' : 'idleLeft');
		}
	}

	override public function applyDeceleration(elapsed:Float):Void
	{
		body.velocity.setxy(0, 0);
	}
	override public function update(elapsed:Float)
	{
		super.update(elapsed);
		updateHitbox();
		x = body.position.x - (width / 2);
		y = body.position.y - (height / 2);
		trace(x, y, width, height, body.position.x, body.position.y);
	}
}
