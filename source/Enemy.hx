package;

import flixel.util.FlxColor;

class Enemy extends Character
{
	public function new(width:Int, height:Int, xPos:Float, yPos:Float)
	{
		super(width, height, xPos, yPos, FlxColor.BROWN, 10, true);
		setCollision(Character.GROUP_TARGET, Character.MASK_ALL, Character.CB_TARGET);
	}
}
