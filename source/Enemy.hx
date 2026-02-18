package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxColor;

class Enemy extends Character
{
	public var debugHitbox:FlxSprite = null;

	public function new(widthInit:Int, heightInit:Int, xPosInit:Float, yPosInit:Float)
	{
		super(widthInit, heightInit, xPosInit, yPosInit, 0, true);
		createRectangularBody(widthInit, heightInit);
		loadGraphic("assets/images/chaos-marine-sprite-sheet.png", true, 220, 250);
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
		body.userData.sprite = this;
		// setBodyMaterial(.5, .5, .5, 2);
		// body.angularVel = 10;
		// setPosition(xPos, yPos);
		setCollision(Character.GROUP_TARGET, Character.MASK_ALL, Character.CB_TARGET);
	}

	override public function updateMovementAnimation():Void
	{
		if (animation == null)
		{
			return;
		}
		var speed = body.velocity.length;
		if (speed > 5)
		{
			if (body.velocity.x < 0)
			{
				direction = 1;
			}
			else if (body.velocity.x > 0)
			{
				direction = -1;
			}
			animation.play(direction > 0 ? 'moveRight' : 'moveLeft');
		}
		else
		{
			animation.play(direction > 0 ? 'idleRight' : 'idleLeft');
		}
	}
}
