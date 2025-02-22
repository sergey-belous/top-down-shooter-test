package photonstorm;

/**
 * FlxWeapon
 * -- Part of the Flixel Power Tools set
 * 
 * v1.3 Added bullet elasticity and bulletsFired counter
 * v1.2 Added useParentDirection bool
 * v1.1 Added pre-fire, fire and post-fire callbacks and sound support, rnd factors, bool returns and currentBullet
 * v1.0 First release
 * 
 * @version 1.3 - October 9th 2011
 * @link http://www.photonstorm.com
 * @author Richard Davey / Photon Storm
*/

    import haxe.Exception;
    import flixel.FlxSprite;
    import flixel.system.FlxAssets.FlxGraphicAsset;
    import flixel.group.FlxGroup;
    import flixel.math.FlxRect;
    import flixel.math.FlxPoint;
    import flixel.sound.FlxSound;
    import flixel.FlxG;
	import photonstorm.types.Bullet;
	import photonstorm.FlxVelocity;
    import haxe.Constraints.Function;
    import openfl.Lib.getTimer;
	
	/**
	 * TODO
	 * ----
	 * 
	 * Angled bullets
	 * Baked Rotation support for angled bullets
	 * Bullet death styles (particle effects)
	 * Bullet trails - blur FX style and Missile Command "draw lines" style? (could be another FX plugin)
	 * Homing Missiles
	 * Bullet uses random sprite from sprite sheet (for rainbow style bullets), or cycles through them in sequence?
	 * Some Weapon base classes like shotgun, lazer, etc?
	 */
	
	class FlxWeapon 
	{
		/**
		 * Internal name for this weapon (i.e. "pulse rifle")
		 */
		public var name:String;
		
		/**
		 * The FlxGroup into which all the bullets for this weapon are drawn. This should be added to your display and collision checked against it.
		 */
		public var group :FlxTypedGroup<Bullet>;
		
		//	Bullet values
		public var bounds:FlxRect;
		
		private var bulletSpeed:Int;
		private var rotateToAngle:Bool;
		
		//	When firing from a fixed position (i.e. Missile Command)
		private var fireFromPosition:Bool;
		private var fireX:Int;
		private var fireY:Int;
		
		private var lastFired:Int = 0;
		private var nextFire:Int = 0;
		private var fireRate:Int = 0;
		
		//	When firing from a parent sprites position (i.e. Space Invaders)
		private var fireFromParent:Bool;
		private var parent:Dynamic;
		private var parentXVariable:String;
		private var parentYVariable:String;
		private var positionOffset:FlxPoint;
		private var directionFromParent:Bool;
		private var angleFromParent:Bool;
		
		private var velocity:FlxPoint;
		
		public var multiShot:Int = 0;
		
		public var bulletLifeSpan:Int = 0;
		public var bulletElasticity:Int = 0;
		
		public var rndFactorAngle:Int = 0;
		public var rndFactorLifeSpan:Int = 0;
		public var rndFactorSpeed:Int = 0;
		public var rndFactorPosition:FlxPoint = new FlxPoint();
		
		/**
		 * A reference to the Bullet that was fired
		 */
		public var currentBullet:Bullet;
		
		//	Callbacks
		public var onPreFireCallback:Function;
		public var onFireCallback:Function;
		public var onPostFireCallback:Function;
		
		//	Sounds
		public var onPreFireSound:FlxSound;
		public var onFireSound:FlxSound;
		public var onPostFireSound:FlxSound;
		
		//	Quick firing direction angle constants
		public static final BULLET_UP:Int = -90;
		public static final BULLET_DOWN:Int = 90;
		public static final BULLET_LEFT:Int = 180;
		public static final BULLET_RIGHT:Int = 0;
		public static final BULLET_NORTH_EAST:Int = -45;
		public static final BULLET_NORTH_WEST:Int = -135;
		public static final BULLET_SOUTH_EAST:Int = 45;
		public static final BULLET_SOUTH_WEST:Int = 135;
		
		/**
		 * Keeps a tally of how many bullets have been fired by this weapon
		 */
		public var bulletsFired:Int = 0;
		
		//	TODO :)
		private var currentMagazine:Int;
		//private var currentBullet:Int;
		private var magazineCount:Int;
		private var bulletsPerMagazine:Int;
		private var magazineSwapDelay:Int;
		private var magazineSwapCallback:Function;
		private var magazineSwapSound:FlxSound;
		
		private static final FIRE:Int = 0;
		private static final FIRE_AT_MOUSE:Int = 1;
		private static final FIRE_AT_POSITION:Int = 2;
		private static final FIRE_AT_TARGET:Int = 3;
		private static final FIRE_FROM_ANGLE:Int = 4;
		private static final FIRE_FROM_PARENT_ANGLE:Int = 5;
		
		/**
		 * Creates the FlxWeapon class which will fire your bullets.<br>
		 * You should call one of the makeBullet functions to visually create the bullets.<br>
		 * Then either use setDirection with fire() or one of the fireAt functions to launch them.
		 * 
		 * @param	name		The name of your weapon (i.e. "lazer" or "shotgun"). For your internal reference really, but could be displayed in-game.
		 * @param	parentRef	If this weapon belongs to a parent sprite, specify it here (bullets will fire from the sprites x/y vars as defined below).
		 * @param	xVariable	The x axis variable of the parent to use when firing. Typically "x", but could be "screenX" or any public getter that exposes the x coordinate.
		 * @param	yVariable	The y axis variable of the parent to use when firing. Typically "y", but could be "screenY" or any public getter that exposes the y coordinate.
		 */
		public function new(name:String, parentRef:Dynamic = null, xVariable:String = "x", yVariable:String = "y")
		{
			this.name = name;
			
			bounds = new FlxRect(0, 0, FlxG.width, FlxG.height);
			
			positionOffset = new FlxPoint();
			
			velocity = new FlxPoint();
			
			if (parentRef)
			{
				setParent(parentRef, xVariable, yVariable);
			}
		}
		
		/**
		 * Makes a pixel bullet sprite (rather than an image). You can set the width/height and color of the bullet.
		 * 
		 * @param	quantity	How many bullets do you need to make? This value should be high enough to cover all bullets you need on-screen *at once* plus probably a few extra spare!
		 * @param	width		The width (in pixels) of the bullets
		 * @param	height		The height (in pixels) of the bullets
		 * @param	color		The color of the bullets. Must be given in 0xAARRGGBB format
		 * @param	offsetX		When the bullet is fired if you need to offset it on the x axis, for example to line it up with the "nose" of a space ship, set the amount here (positive or negative)
		 * @param	offsetY		When the bullet is fired if you need to offset it on the y axis, for example to line it up with the "nose" of a space ship, set the amount here (positive or negative)
		 */
		public function makePixelBullet(quantity:Int, width:Int = 2, height:Int = 2, color:Int = 0xffffffff, offsetX:Int = 0, offsetY:Int = 0):Void
		{
			group = new FlxTypedGroup(quantity);
			
			for (b in 0...quantity)
			{
				var tempBullet:Bullet = new Bullet(this, b);
				
				tempBullet.makeGraphic(width, height, color);
				
				group.add(tempBullet);
			}
			
			positionOffset.x = offsetX;
			positionOffset.y = offsetY;
		}
		
		/**
		 * Makes a bullet sprite from the given image. It will use the width/height of the image.
		 * 
		 * @param	quantity		How many bullets do you need to make? This value should be high enough to cover all bullets you need on-screen *at once* plus probably a few extra spare!
		 * @param	image			The image used to create the bullet from
		 * @param	offsetX			When the bullet is fired if you need to offset it on the x axis, for example to line it up with the "nose" of a space ship, set the amount here (positive or negative)
		 * @param	offsetY			When the bullet is fired if you need to offset it on the y axis, for example to line it up with the "nose" of a space ship, set the amount here (positive or negative)
		 * @param	autoRotate		When true the bullet sprite will rotate to match the angle of the parent sprite. Call fireFromParentAngle or fromFromAngle to fire it using an angle as the velocity.
		 * @param	frame			If the image has a single row of square animation frames on it, you can specify which of the frames you want to use here. Default is -1, or "use whole graphic"
		 * @param	rotations		The number of rotation frames the final sprite should have.  For small sprites this can be quite a large number (360 even) without any problems.
		 * @param	antiAliasing	Whether to use high quality rotations when creating the graphic. Default is false.
		 * @param	autoBuffer		Whether to automatically increase the image size to accomodate rotated corners. Default is false. Will create frames that are 150% larger on each axis than the original frame or graphic.
		 */
		public function makeImageBullet(quantity:Int, image:FlxGraphicAsset, offsetX:Int = 0, offsetY:Int = 0, autoRotate:Bool = false, rotations:Int = 16, frame:Int = -1, antiAliasing:Bool = false, autoBuffer:Bool = false):Void
		{
			group = new FlxTypedGroup(quantity);
			
			rotateToAngle = autoRotate;
			
			for (b in 0...quantity)
			{
				var tempBullet:Bullet = new Bullet(this, b);
				
				if (autoRotate)
				{
					tempBullet.loadRotatedGraphic(image, rotations, frame, antiAliasing, autoBuffer);
				}
				else
				{
					tempBullet.loadGraphic(image);
				}
				
				group.add(tempBullet);
			}
			
			positionOffset.x = offsetX;
			positionOffset.y = offsetY;
		}
		
		/**
		 * Makes an animated bullet from the image and frame data given.
		 * 
		 * @param	quantity		How many bullets do you need to make? This value should be high enough to cover all bullets you need on-screen *at once* plus probably a few extra spare!
		 * @param	imageSequence	The image used to created the animated bullet from
		 * @param	frameWidth		The width of each frame in the animation
		 * @param	frameHeight		The height of each frame in the animation
		 * @param	frames			An array of numbers indicating what frames to play in what order (e.g. 1, 2, 3)
		 * @param	frameRate		The speed in frames per second that the animation should play at (e.g. 40 fps)
		 * @param	looped			Whether or not the animation is looped or just plays once
		 * @param	offsetX			When the bullet is fired if you need to offset it on the x axis, for example to line it up with the "nose" of a space ship, set the amount here (positive or negative)
		 * @param	offsetY			When the bullet is fired if you need to offset it on the y axis, for example to line it up with the "nose" of a space ship, set the amount here (positive or negative)
		 */
		public function makeAnimatedBullet(quantity:Int, imageSequence:FlxGraphicAsset, frameWidth:Int, frameHeight:Int, frames:Array<Int>, frameRate:Int, looped:Bool, offsetX:Int = 0, offsetY:Int = 0):Void
		{
			group = new FlxTypedGroup(quantity);
			
			for (b in 0...quantity)
			{
				var tempBullet:Bullet = new Bullet(this, b);
				
				tempBullet.loadGraphic(imageSequence, true, frameWidth, frameHeight);
				
				tempBullet.addAnimation("fire", frames, frameRate, looped);
				
				group.add(tempBullet);
			}
			
			positionOffset.x = offsetX;
			positionOffset.y = offsetY;
		}
		
		/**
		 * Internal function that handles the actual firing of the bullets
		 * 
		 * @param	method
		 * @param	x
		 * @param	y
		 * @param	target
		 * @return	true if a bullet was fired or false if one wasn't available. The bullet last fired is stored in FlxWeapon.prevBullet
		 */
		private function runFire(method:Int, x:Int = 0, y:Int = 0, target:FlxSprite = null, angle:Int = 0):Bool
		{
			if (fireRate > 0 && (getTimer() < nextFire))
			{
				return false;
			}
			
			currentBullet = getFreeBullet();
			
			if (currentBullet == null)
			{
				return false;
			}

			if (Reflect.isFunction(onPreFireCallback))
			{
				onPreFireCallback();
			}
			
			if (onPreFireSound != null)
			{
				onPreFireSound.play();
			}
			
			//	Clear any velocity that may have been previously set from the pool
			currentBullet.velocity.x = 0;
			currentBullet.velocity.y = 0;
			
			lastFired = getTimer();
			nextFire = getTimer() + fireRate;
			
			var launchX:Float = positionOffset.x;
			var launchY:Float = positionOffset.y;
			
			if (fireFromParent)
			{
				launchX += Reflect.field(parent, parentXVariable);
				launchY += Reflect.field(parent, parentYVariable);
			}
			else if (fireFromPosition)
			{
				launchX += fireX;
				launchY += fireY;
			}
			
			if (directionFromParent)
			{
				velocity = FlxVelocity.velocityFromFacing(parent, bulletSpeed);
			}
			
			//	Faster (less CPU) to use this small if-else ladder than a switch statement
			if (method == FIRE)
			{
				currentBullet.fire(cast (launchX, Int), cast (launchY, Int), cast(velocity.x, Int), cast(velocity.y, Int));
			}
			else if (method == FIRE_AT_MOUSE)
			{
				currentBullet.fireAtMouse(cast (launchX, Int), cast (launchY, Int), bulletSpeed);
				trace(currentBullet);
			}
			else if (method == FIRE_AT_POSITION)
			{
				currentBullet.fireAtPosition(cast (launchX, Int), cast (launchY, Int), x, y, bulletSpeed);
			}
			else if (method == FIRE_AT_TARGET)
			{
				currentBullet.fireAtTarget(cast (launchX, Int), cast (launchY, Int), target, bulletSpeed);
			}
			else if (method == FIRE_FROM_ANGLE)
			{
				currentBullet.fireFromAngle(cast (launchX, Int), cast (launchY, Int), angle, bulletSpeed);
			}
			else if (method == FIRE_FROM_PARENT_ANGLE)
			{
				currentBullet.fireFromAngle(cast (launchX, Int), cast (launchY, Int), parent.angle, bulletSpeed);
			}
			
			if (Reflect.isFunction(onPostFireCallback))
			{
				onPostFireCallback();
			}
			
			if (onPostFireSound != null)
			{
				onPostFireSound.play();
			}
			
			bulletsFired++;
			
			return true;
		}
		
		/**
		 * Fires a bullet (if one is available). The bullet will be given the velocity defined in setBulletDirection and fired at the rate set in setFireRate.
		 * 
		 * @return	true if a bullet was fired or false if one wasn't available. A reference to the bullet fired is stored in FlxWeapon.currentBullet.
		 */
		public function fire():Bool
		{
			return runFire(FIRE);
		}
		
		/**
		 * Fires a bullet (if one is available) at the mouse coordinates, using the speed set in setBulletSpeed and the rate set in setFireRate.
		 * 
		 * @return	true if a bullet was fired or false if one wasn't available. A reference to the bullet fired is stored in FlxWeapon.currentBullet.
		 */
		public function fireAtMouse():Bool
		{
			return runFire(FIRE_AT_MOUSE);
		}
		
		/**
		 * Fires a bullet (if one is available) at the given x/y coordinates, using the speed set in setBulletSpeed and the rate set in setFireRate.
		 * 
		 * @param	x	The x coordinate (in game world pixels) to fire at
		 * @param	y	The y coordinate (in game world pixels) to fire at
		 * @return	true if a bullet was fired or false if one wasn't available. A reference to the bullet fired is stored in FlxWeapon.currentBullet.
		 */
		public function fireAtPosition(x:Int, y:Int):Bool
		{
			return runFire(FIRE_AT_POSITION, x, y);
		}
		
		/**
		 * Fires a bullet (if one is available) at the given targets x/y coordinates, using the speed set in setBulletSpeed and the rate set in setFireRate.
		 * 
		 * @param	target	The FlxSprite you wish to fire the bullet at
		 * @return	true if a bullet was fired or false if one wasn't available. A reference to the bullet fired is stored in FlxWeapon.currentBullet.
		 */
		public function fireAtTarget(target:FlxSprite):Bool
		{
			return runFire(FIRE_AT_TARGET, 0, 0, target);
		}
		
		/**
		 * Fires a bullet (if one is available) based on the given angle
		 * 
		 * @param	angle	The angle (in degrees) calculated in clockwise positive direction (down = 90 degrees positive, right = 0 degrees positive, up = 90 degrees negative)
		 * @return	true if a bullet was fired or false if one wasn't available. A reference to the bullet fired is stored in FlxWeapon.currentBullet.
		 */
		public function fireFromAngle(angle:Int):Bool
		{
			return runFire(FIRE_FROM_ANGLE, 0, 0, null, angle);
		}
		
		/**
		 * Fires a bullet (if one is available) based on the angle of the Weapons parent
		 * 
		 * @return	true if a bullet was fired or false if one wasn't available. A reference to the bullet fired is stored in FlxWeapon.currentBullet.
		 */
		public function fireFromParentAngle():Bool
		{
			return runFire(FIRE_FROM_PARENT_ANGLE);
		}
		
		/**
		 * Causes the Weapon to fire from the parents x/y value, as seen in Space Invaders and most shoot-em-ups.
		 * 
		 * @param	parentRef		If this weapon belongs to a parent sprite, specify it here (bullets will fire from the sprites x/y vars as defined below).
		 * @param	xVariable		The x axis variable of the parent to use when firing. Typically "x", but could be "screenX" or any public getter that exposes the x coordinate.
		 * @param	yVariable		The y axis variable of the parent to use when firing. Typically "y", but could be "screenY" or any public getter that exposes the y coordinate.
		 * @param	offsetX			When the bullet is fired if you need to offset it on the x axis, for example to line it up with the "nose" of a space ship, set the amount here (positive or negative)
		 * @param	offsetY			When the bullet is fired if you need to offset it on the y axis, for example to line it up with the "nose" of a space ship, set the amount here (positive or negative)
		 * @param	useDirection	When fired the bullet direction is based on parent sprites facing value (up/down/left/right)
		 */
		public function setParent(parentRef:Dynamic, xVariable:String, yVariable:String, offsetX:Int = 0, offsetY:Int = 0, useDirection:Bool = false):Void
		{
			if (parentRef)
			{
				fireFromParent = true;
				
				parent = parentRef;
				
				parentXVariable = xVariable;
				parentYVariable = yVariable;
			
				positionOffset.x = offsetX;
				positionOffset.y = offsetY;
				
				directionFromParent = useDirection;
			}
		}
		
		/**
		 * Causes the Weapon to fire from a fixed x/y position on the screen, like in the game Missile Command.<br>
		 * If set this over-rides a call to setParent (which causes the Weapon to fire from the parents x/y position)
		 * 
		 * @param	x	The x coordinate (in game world pixels) to fire from
		 * @param	y	The y coordinate (in game world pixels) to fire from
		 * @param	offsetX		When the bullet is fired if you need to offset it on the x axis, for example to line it up with the "nose" of a space ship, set the amount here (positive or negative)
		 * @param	offsetY		When the bullet is fired if you need to offset it on the y axis, for example to line it up with the "nose" of a space ship, set the amount here (positive or negative)
		 */
		public function setFiringPosition(x:Int, y:Int, offsetX:Int = 0, offsetY:Int = 0):Void
		{
			fireFromPosition = true;
			fireX = x;
			fireY = y;
			
			positionOffset.x = offsetX;
			positionOffset.y = offsetY;
		}
		
		/**
		 * The speed in pixels/sec (sq) that the bullet travels at when fired via fireAtMouse, fireAtPosition or fireAtTarget.
		 * You can update this value in real-time, should you need to speed-up or slow-down your bullets (i.e. collecting a power-up)
		 * 
		 * @param	speed		The speed it will move, in pixels per second (sq)
		 */
		public function setBulletSpeed(speed:Int):Void
		{
			bulletSpeed = speed;
		}
		
		/**
		 * The speed in pixels/sec (sq) that the bullet travels at when fired via fireAtMouse, fireAtPosition or fireAtTarget.
		 * 
		 * @return	The speed the bullet moves at, in pixels per second (sq)
		 */
		public function getBulletSpeed():Int
		{
			return bulletSpeed;
		}
		
		/**
		 * Sets the firing rate of the Weapon. By default there is no rate, as it can be controlled by FlxControl.setFireButton.
		 * However if you are firing using the mouse you may wish to set a firing rate.
		 * 
		 * @param	rate	The delay in milliseconds (ms) between which each bullet is fired, set to zero to clear
		 */
		public function setFireRate(rate:Int):Void
		{
			fireRate = rate;
		}
		
		/**
		 * When a bullet goes outside of this bounds it will be automatically killed, freeing it up for firing again.
		 * TODO - Needs testing with a scrolling map (when not using single screen display)
		 * 
		 * @param	bounds	An FlxRect area. Inside this area the bullet should be considered alive, once outside it will be killed.
		 */
		public function setBulletBounds(bounds:FlxRect):Void
		{
			this.bounds = bounds;
		}
		
		/**
		 * Set the direction the bullet will travel when fired.
		 * You can use one of the consts such as BULLET_UP, BULLET_DOWN or BULLET_NORTH_EAST to set the angle easily.
		 * Speed should be given in pixels/sec (sq) and is the speed at which the bullet travels when fired.
		 * 
		 * @param	angle		The angle of the bullet. In clockwise positive direction: Right = 0, Down = 90, Left = 180, Up = -90. You can use one of the consts such as BULLET_UP, etc
		 * @param	speed		The speed it will move, in pixels per second (sq)
		 */
		public function setBulletDirection(angle:Int, speed:Int):Void
		{
			velocity = FlxVelocity.velocityFromAngle(angle, speed);
		}
		
		/**
		 * Sets gravity on all currently created bullets<br>
		 * This will update ALL bullets, even those currently "in flight", so be careful about when you call this!
		 * 
		 * @param	xForce	A positive value applies gravity dragging the bullet to the right. A negative value drags the bullet to the left. Zero disables horizontal gravity.
		 * @param	yforce	A positive value applies gravity dragging the bullet down. A negative value drags the bullet up. Zero disables vertical gravity.
		 */
		public function setBulletGravity(xForce:Int, yForce:Int):Void
		{
			group.forEach(function (bullet) return bullet.xGravity = xForce, false);
			group.forEach(function (bullet) return bullet.yGravity = yForce, false);
		}
		
		/**
		 * If you'd like your bullets to accelerate to their top speed rather than be launched already at it, then set the acceleration value here.
		 * If you've previously set the acceleration then setting it to zero will cancel the effect.
		 * This will update ALL bullets, even those currently "in flight", so be careful about when you call this!
		 * 
		 * @param	xAcceleration		Acceleration speed in pixels per second to apply to the bullets horizontal movement, set to zero to cancel. Negative values move left, positive move right.
		 * @param	yAcceleration		Acceleration speed in pixels per second to apply to the bullets vertical movement, set to zero to cancel. Negative values move up, positive move down.
		 * @param	xSpeedMax			The maximum speed in pixels per second in which the bullet can move horizontally
		 * @param	ySpeedMax			The maximum speed in pixels per second in which the bullet can move vertically
		 */
		public function setBulletAcceleration(xAcceleration:Int, yAcceleration:Int, xSpeedMax:Int, ySpeedMax:Int):Void
		{
			if (xAcceleration == 0 && yAcceleration == 0)
			{
				group.forEach(function (bullet) return bullet.accelerates = false, false);
			}
			else
			{
				group.forEach(function (bullet) return bullet.accelerates = true, false);
				group.forEach(function (bullet) return bullet.xAcceleration = xAcceleration, false);
				group.forEach(function (bullet) return bullet.yAcceleration = yAcceleration, false);
				group.forEach(function (bullet) return bullet.maxVelocityX = xSpeedMax, false);
				group.forEach(function (bullet) return bullet.maxVelocityY = ySpeedMax, false);
			}
		}
		
		/**
		 * When the bullet is fired from a parent (or fixed position) it will do so from their x/y coordinate.<br>
		 * Often you need to align a bullet with the sprite, i.e. to make it look like it came out of the "nose" of a space ship.<br>
		 * Use this offset x/y value to achieve that effect.
		 * 
		 * @param	offsetX		The x coordinate offset to add to the launch location (positive or negative)
		 * @param	offsetY		The y coordinate offset to add to the launch location (positive or negative)
		 */
		public function setBulletOffset(offsetX:Int, offsetY:Int):Void
		{
			positionOffset.x = offsetX;
			positionOffset.y = offsetY;
		}
		
		/**
		 * Give the bullet a random factor to its angle, speed, position or lifespan when fired. Can create a nice "scatter gun" effect.
		 * 
		 * @param	randomAngle		The +- value applied to the angle when fired. For example 20 means the bullet can fire up to 20 degrees under or over its angle when fired.
		 * @param	randomSpeed		The +- value applied to the bullet speed when fired. For example 10 means the bullet speed varies by +- 10px/sec
		 * @param	randomPosition	The +- values applied to the x/y coordinates the bullet is fired from.
		 * @param	randomLifeSpan	The +- values applied to the life span of the bullet.
		 */
		public function setBulletRandomFactor(randomAngle:Int = 0, randomSpeed:Int = 0, randomPosition:FlxPoint = null, randomLifeSpan:Int = 0):Void
		{
			rndFactorAngle = randomAngle;
			rndFactorSpeed = randomSpeed;
			
			if (randomPosition != null)
			{
				rndFactorPosition = randomPosition;
			}
			
			rndFactorLifeSpan = randomLifeSpan;
		}
		
		/**
		 * If the bullet should have a fixed life span use this function to set it.
		 * The bullet will be killed once it passes this lifespan (if still alive and in bounds)
		 * 
		 * @param	lifespan	The lifespan of the bullet in ms, calculated when the bullet is fired. Set to zero to disable bullet lifespan.
		 */
		public function setBulletLifeSpan(lifespan:Int):Void
		{
			bulletLifeSpan = lifespan;
		}
		
		/**
		 * The elasticity of the fired bullet controls how much it rebounds off collision surfaces.
		 * 
		 * @param	elasticity	The elasticity of the bullet between 0 and 1 (0 being no rebound, 1 being 100% force rebound). Set to zero to disable.
		 */
		public function setBulletElasticity(elasticity:Int):Void
		{
			bulletElasticity = elasticity;
		}
		
		/**
		 * Internal function that returns the next available bullet from the pool (if any)
		 * 
		 * @return	A bullet
		 */
		private function getFreeBullet():Bullet
		{
			var result:Bullet = null;
			
			if (group == null || group.length == 0)
			{
				throw new Exception("Weapon.as cannot fire a bullet until one has been created via a call to makePixelBullet or makeImageBullet");
				return null;
			}
			
			for (bullet in group.members)
			{
				if (bullet.exists == false)
				{
					result = bullet;
					break;
				}
			}
			
			return result;
		}
		
		/**
		 * Sets a pre-fire callback function and sound. These are played immediately before the bullet is fired.
		 * 
		 * @param	callback	The function to call
		 * @param	sound		An FlxSound to play
		 */
		public function setPreFireCallback(callback:Function = null, sound:FlxSound = null):Void
		{
			onPreFireCallback = callback;
			onPreFireSound = sound;
		}
		
		/**
		 * Sets a fire callback function and sound. These are played immediately as the bullet is fired.
		 * 
		 * @param	callback	The function to call
		 * @param	sound		An FlxSound to play
		 */
		public function setFireCallback(callback:Function = null, sound:FlxSound = null):Void
		{
			onFireCallback = callback;
			onFireSound = sound;
		}
		
		/**
		 * Sets a post-fire callback function and sound. These are played immediately after the bullet is fired.
		 * 
		 * @param	callback	The function to call
		 * @param	sound		An FlxSound to play
		 */
		public function setPostFireCallback(callback:Function = null, sound:FlxSound = null):Void
		{
			onPostFireCallback = callback;
			onPostFireSound = sound;
		}
		
		// TODO
		// public function TODOcreateBulletPattern(pattern:Array):Void
		// {
		// 	//	Launches this many bullets
		// }
		
		
		public function update():Void
		{
			// ???
		}
		
	}