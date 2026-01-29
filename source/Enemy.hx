package;

import flixel.util.FlxColor;

class Enemy extends Character
{
	public function new(width:Int, height:Int, xPos:Float, yPos:Float)
	{
		super(width, height, xPos, yPos, FlxColor.BROWN, 10, true);
		setCollision(Character.GROUP_TARGET, Character.MASK_ALL, Character.CB_TARGET);
		loadGraphic("assets/images/chaos-marine-sprite-sheet.png", true, 250, 250);
		animation.add("moveRight", [0, 1, 2], 12, true);
		animation.add("moveLeft", [0, 1, 2], 12, false);
		animation.add('idleRight', [0], 1, true);
		animation.add('idleLeft', [0], 1, false);
		setGraphicSize(64, 64);
		updateHitbox();
	}

	override public function updateMovementAnimation():Void
	{
		if (body.velocity.length > 5 && body.velocity.x > 0)
		{
			direction = 1;
			animation.play('moveRight');
		}
		else if (body.velocity.length > 5 && body.velocity.x < 0)
		{
			animation.play('moveLeft');
			direction = -1;
		}
		else if (body.velocity.length == 5)
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
