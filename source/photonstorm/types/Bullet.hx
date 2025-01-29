/**
 * Bullet
 * -- Part of the Flixel Power Tools set
 * 
 * v1.2 Removed "id" and used the FlxSprite ID value instead
 * v1.1 Updated to support fire callbacks, sounds, random variances and lifespan
 * v1.0 First release
 * 
 * @version 1.2 - October 10th 2011
 * @link http://www.photonstorm.com
 * @author Richard Davey / Photon Storm
*/

package photonstorm.types;

	import flixel.FlxG;
	import flixel.util.FlxColor;
	import flixel.math.FlxPoint;
	import flixel.FlxSprite;
	import photonstorm.FlxMath;
	import photonstorm.FlxVelocity;
	import photonstorm.FlxWeapon;
	import openfl.Lib.getTimer;
	import flixel.addons.nape.FlxNapeSprite;

	class Bullet extends FlxNapeSprite
	{
		public var weapon:FlxWeapon;
		
		public var bulletSpeed:Int;
		
		//	Acceleration or Velocity?
		public var accelerates:Bool;
		public var xAcceleration:Int;
		public var yAcceleration:Int;
		
		public var rndFactorAngle:Int;
		public var rndFactorSpeed:Int;
		public var rndFactorLifeSpan:Int;
		public var lifespan:Int;
		public var launchTime:Int;
		public var expiresTime:Int;

		public var xGravity(default, set):Int;
		public var yGravity(default, set):Int;
		public var maxVelocityX(default, set):Int;
		public var maxVelocityY(default, set):Int;
		
		public var animated:Bool;
		
		public function new(weapon:FlxWeapon, id:Int)
		{
			super();
			
			this.weapon = weapon;
			this.ID = id;
			this.makeGraphic(10, 10, FlxColor.MAGENTA);
			this.createRectangularBody();
			this.antialiasing = true;
			this.scale.x = 1;
			this.scale.y = 1;
			this.flipX = FlxG.random.bool(); // add some variety
			this.flipY = FlxG.random.bool(); // add some variety.
			this.setBodyMaterial(.5, .5, .5, 2);
			this.body.position.y = 48;
			this.body.position.x = 48;
			
			//	Safe defaults
			accelerates = false;
			animated = false;
			bulletSpeed = 0;
			
			exists = false;
		}
		
		/**
		 * Adds a new animation to the sprite.
		 * 
		 * @param	Name		What this animation should be called (e.g. "run").
		 * @param	Frames		An array of numbers indicating what frames to play in what order (e.g. 1, 2, 3).
		 * @param	FrameRate	The speed in frames per second that the animation should play at (e.g. 40 fps).
		 * @param	Looped		Whether or not the animation is looped or just plays once.
		 */
		public function addAnimation(Name:String, Frames:Array<Int>, FrameRate:Int = 0, Looped:Bool = true):Void
		{
			this.animation.add(Name, Frames, FrameRate, Looped);
			
			animated = true;
		}
		
		public function fire(fromX:Int, fromY:Int, velX:Int, velY:Int):Void
		{
			x = fromX + FlxMath.rand( cast(-weapon.rndFactorPosition.x, Int), cast(weapon.rndFactorPosition.x, Int));
			y = fromY + FlxMath.rand( cast(-weapon.rndFactorPosition.y, Int), cast(weapon.rndFactorPosition.y, Int));
			
			if (accelerates)
			{
				acceleration.x = xAcceleration + FlxMath.rand( -weapon.rndFactorSpeed, weapon.rndFactorSpeed);
				acceleration.y = yAcceleration + FlxMath.rand( -weapon.rndFactorSpeed, weapon.rndFactorSpeed);
			}
			else
			{
				velocity.x = velX + FlxMath.rand( -weapon.rndFactorSpeed, weapon.rndFactorSpeed);
				velocity.y = velY + FlxMath.rand( -weapon.rndFactorSpeed, weapon.rndFactorSpeed);
			}
			
			postFire();
		}
		
		public function fireAtMouse(fromX:Int, fromY:Int, speed:Int):Void
		{
			x = fromX + FlxMath.rand( cast(-weapon.rndFactorPosition.x, Int), cast(weapon.rndFactorPosition.x, Int));
			y = fromY + FlxMath.rand( cast(-weapon.rndFactorPosition.y, Int), cast(weapon.rndFactorPosition.y, Int));
			
			if (accelerates)
			{
				FlxVelocity.accelerateTowardsMouse(this, speed + FlxMath.rand( -weapon.rndFactorSpeed, weapon.rndFactorSpeed), cast(maxVelocity.x, Int), cast(maxVelocity.y, Int));
			}
			else
			{
				FlxVelocity.moveTowardsMouse(this, speed + FlxMath.rand( -weapon.rndFactorSpeed, weapon.rndFactorSpeed));
			}
			
			postFire();
		}
		
		public function fireAtPosition(fromX:Int, fromY:Int, toX:Int, toY:Int, speed:Int):Void
		{
			x = fromX + FlxMath.rand( cast(-weapon.rndFactorPosition.x, Int), cast(weapon.rndFactorPosition.x, Int));
			y = fromY + FlxMath.rand( cast(-weapon.rndFactorPosition.y, Int), cast(weapon.rndFactorPosition.y, Int));
			
			if (accelerates)
			{
				FlxVelocity.accelerateTowardsPoint(this, new FlxPoint(toX, toY), speed + FlxMath.rand( -weapon.rndFactorSpeed, weapon.rndFactorSpeed), cast(maxVelocity.x, Int), cast(maxVelocity.y, Int));
			}
			else
			{
				FlxVelocity.moveTowardsPoint(this, new FlxPoint(toX, toY), speed + FlxMath.rand( -weapon.rndFactorSpeed, weapon.rndFactorSpeed));
			}
			
			postFire();
		}
		
		public function fireAtTarget(fromX:Int, fromY:Int, target:FlxSprite, speed:Int):Void
		{
			x = fromX + FlxMath.rand( cast(-weapon.rndFactorPosition.x, Int), cast(weapon.rndFactorPosition.x, Int));
			y = fromY + FlxMath.rand( cast(-weapon.rndFactorPosition.y, Int), cast(weapon.rndFactorPosition.y, Int));
			
			if (accelerates)
			{
				FlxVelocity.accelerateTowardsObject(this, target, speed + FlxMath.rand( -weapon.rndFactorSpeed, weapon.rndFactorSpeed), cast(maxVelocity.x, Int), cast(maxVelocity.y, Int));
			}
			else
			{
				FlxVelocity.moveTowardsObject(this, target, speed + FlxMath.rand( -weapon.rndFactorSpeed, weapon.rndFactorSpeed));
			}
			
			postFire();
		}
		
		public function fireFromAngle(fromX:Int, fromY:Int, fireAngle:Int, speed:Int):Void
		{
			x = fromX + FlxMath.rand( cast(-weapon.rndFactorPosition.x, Int), cast(weapon.rndFactorPosition.x, Int));
			y = fromY + FlxMath.rand( cast(-weapon.rndFactorPosition.y, Int), cast(weapon.rndFactorPosition.y, Int));
			
			var newVelocity:FlxPoint = FlxVelocity.velocityFromAngle(fireAngle + FlxMath.rand( -weapon.rndFactorAngle, weapon.rndFactorAngle), speed + FlxMath.rand( -weapon.rndFactorSpeed, weapon.rndFactorSpeed));
			
			if (accelerates)
			{
				acceleration.x = newVelocity.x;
				acceleration.y = newVelocity.y;
			}
			else
			{
				velocity.x = newVelocity.x;
				velocity.y = newVelocity.y;
			}
			
			postFire();
		}
		
		private function postFire():Void
		{
			if (animated)
			{
				this.animation.play("fire");
			}
			
			if (weapon.bulletElasticity > 0)
			{
				elasticity = weapon.bulletElasticity;
			}
			
			exists = true;
			
			launchTime = getTimer();
			
			if (weapon.bulletLifeSpan > 0)
			{
				lifespan = weapon.bulletLifeSpan + FlxMath.rand( -weapon.rndFactorLifeSpan, weapon.rndFactorLifeSpan);
				expiresTime = getTimer() + lifespan;
			}
			
			if (Reflect.isFunction(weapon.onFireCallback))
			{
				weapon.onFireCallback();
			}
			
			if (weapon.onFireSound != null)
			{
				weapon.onFireSound.play();
			}
		}
		
		public function set_xGravity(gx:Int):Int
		{
			acceleration.x = gx;
			return cast(acceleration.x, Int);
		}
		
		public function set_yGravity(gy:Int):Int
		{
			acceleration.y = gy;
			return cast(acceleration.y, Int);
		}
		
		public function set_maxVelocityX(mx:Int):Int
		{
			maxVelocity.x = mx;
			return cast(maxVelocity.x, Int);
		}
		
		public function set_maxVelocityY(my:Int):Int
		{
			maxVelocity.y = my;
			return cast(maxVelocity.y, Int);
		}
		
		override public function update(elapsed:Float):Void
		{
			// if (lifespan > 0 && getTimer() > expiresTime)
			// {
			// 	kill();
			// }
			
			// if (FlxMath.pointInFlxRect(x, y, weapon.bounds) == false)
			// {
			// 	kill();
			// }
			super.update(elapsed);
		}
		
	}