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

	public var levels:Int = 20;
	public var bricks:Array<FlxNapeSprite>; 
	public var shooter:Shooter;
	public var handJoint:PivotJoint;
	// public var space:Space;
	public var body:Body;
	public var brickHeight:Int; // magic number!
	public var brickWidth:Int;

	var layout:FlxSprite;

	override public function create()
	{
		
		brickHeight = 32;
		brickWidth = brickHeight;

		super.create();

		bgColor = 0xfffa0808;

		layout = new FlxSprite(0,0);
		layout = layout.makeGraphic(640, 480, bgColor);

		add(layout);

		FlxNapeSpace.init();

		shooter = new Shooter();
		// shooter.maxSize = 64;
		add(shooter);

		// FlxG.cameras.bgColor = bgColor;

		walls = FlxNapeSpace.createWalls(0, 0, 640, 480, 10);

		box = new FlxNapeSprite();
		box.makeGraphic(32, 32, FlxColor.MAGENTA);
		box.createRectangularBody();
		box.antialiasing = true;
		box.scale.x = 1;
		box.scale.y = 1;
		box.flipX = FlxG.random.bool(); // add some variety
		box.flipY = FlxG.random.bool(); // add some variety.
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
		// surrounding.flipX = FlxG.random.bool(); // add some variety
		// surrounding.flipY = FlxG.random.bool(); // add some variety.
		surrounding.setBodyMaterial(.5, .5, .5, 2);
		surrounding.body.position.y = 48;
		surrounding.body.position.x = 48;
		add(surrounding);

		//	Tell the weapon to create 50 bullets using the bulletPNG image.
		//	The 5 value is the x offset, which makes the bullet fire from the tip of the players ship.
		lazer.makePixelBullet(50, 5, 5);
		lazer.setBulletSpeed(100);
		
		// //	Sets the direction and speed the bullets will be fired in
		// //this.lazer.setBulletDirection(FlxWeapon.BULLET_UP, 200);
		// add(box);
		add(lazer.group);

		createBricks();

		shooter.setBox(box);

		// handJoint = new PivotJoint(FlxNapeSpace.space.world, null, Vec2.weak(), Vec2.weak());
		// handJoint.space = FlxNapeSpace.space;
		// handJoint.active = false;

		// // We also define this joint to be 'elastic' by setting
		// // its 'stiff' property to false.
		// //
		// //   We could further configure elastic behaviour of this
		// //   constraint through the 'frequency' and 'damping'
		// //   properties.
		// handJoint.stiff = false;

		// Create initial terrain state, invalidating the whole screen.
		// var w:Int = FlxG.width;
		// var h:Int = FlxG.height;

		// var bit = Assets.getBitmapData("assets/images/test.png");

		// terrain = new Terrain(bit, 30, 5);
		// terrain.invalidate(new AABB(0, 0, w, h), this);
		// add(terrain.sprite);

		deadGroup = new FlxTypedGroup(2048);
		maxSize = 2048;

		for (i in 0...maxSize - 1) {
			var deadSprite = new FlxSprite();
			deadSprite.makeGraphic(64, 64, FlxColor.GREEN);
			// deadSprite.loadGraphic('assets/images/blood.png');
			
			deadSprite.antialiasing = true;
			deadGroup.add(deadSprite);
		}
	}

	function createBricks()
	{
		bricks = new Array<FlxNapeSprite>();
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
				brick.flipX = FlxG.random.bool(); // add some variety
				brick.flipY = FlxG.random.bool(); // add some variety.
				brick.setBodyMaterial(.5, .5, .5, 2);
				brick.body.position.y = FlxG.height - brickHeight / 2 - brickHeight * i + 2;
				brick.body.position.x = (FlxG.width / 2 - brickWidth / 2 * (levels - i - 1)) + brickWidth * j;
				add(brick);
				bricks.push(brick);
			}
		}

		
	}

	function explosion(pos:Vec2)
	{
		var region = AABB.fromRect(bomb.getBounds(bomb));
		
		var radius:Int = Std.int(region.width / 2);
		var diameter:Int = 2 * radius;
		var radiusSquared:Int = radius * radius;
		var centerX:Int = Std.int(pos.x);
		var centerY:Int = Std.int(pos.y);
		var dx:Int, dy:Int;

		for (x in 0...diameter)
		{
			for (y in 0...diameter)
			{
				dx = radius - x;
				dy = radius - y;
				if ((dx * dx + dy * dy) > radiusSquared)
				{
					continue;
				}
				terrain.bitmap.setPixel32(centerX + dx, centerY + dy, FlxColor.TRANSPARENT);
			}
		}

		// Invalidate region of terrain effected.
		region.x += pos.x;
		region.y += pos.y;
		terrain.invalidate(region, this);
	}

	override public function update(elapsed:Float)
	{
		var mousePoint = Vec2.get(FlxG.mouse.getPosition().x, FlxG.mouse.getPosition().x);

		FlxNapeSpace.space.gravity.setxy(0, 0);

		if(FlxG.keys.pressed.W) {
			box.body.position = box.body.position.add(new Vec2(0, -10));
		}
		if(FlxG.keys.pressed.S) {
			box.body.position = box.body.position.add(new Vec2(0, 10));
		}
		if(FlxG.keys.pressed.A) {
			box.body.position = box.body.position.add(new Vec2(-10, 0));
		}
		if(FlxG.keys.pressed.D) {
			box.body.position = box.body.position.add(new Vec2(10, 0));
		}
		if(FlxG.keys.pressed.SPACE) {
			var reso = lazer.fireAtMouse();
			trace('result is' + reso);
		}
		if (FlxG.mouse.pressed == true) {
			// var bodies = FlxNapeSpace.space.bodiesUnderPoint(mousePoint);
			// for (body in bodies) {
			// 	if (!body.isDynamic()) {
			// 		continue;
			// 	}
			// 	handJoint.body2 = body;
			// 	handJoint.anchor2.set(body.worldPointToLocal(mousePoint, true));

			// 	// Enable hand joint!
			// 	handJoint.active = true;
			// }
		}
		 else {
			// handJoint.active = false;
		}

		trace(shooter.collides);

		if (shooter.collides) {
	
			var possiblyCollided = FlxNapeSpace.space.bodiesInCircle(new Vec2(shooter.collidesSpr.getPosition().x, shooter.collidesSpr.getPosition().y), 96);
			
			possiblyCollided.foreach(function(el){
				if (el != box.body && el != walls) {
					el.space = null;
					el.velocity = new Vec2(0,0);

					var toStamp = deadGroup.getFirstAlive();
					// add(toStamp);
					toStamp.setPosition(el.position.x, el.position.y);
					layout.stamp(toStamp, cast(el.position.x, Int), cast(el.position.y, Int));
					toStamp.kill();

					trace(deadGroup.countLiving());
					trace(el.position.x, '|||', el.position.y);
				}

				// var deadSprite = new FlxNapeSprite();
				// deadSprite.makeGraphic(64, 64, FlxColor.GREEN);
				// // deadSprite.loadGraphic('assets/images/blood.png');
				
				// deadSprite.antialiasing = true;
				// deadSprite.setPosition(el.position.x, el.position.y);
				// deadSprite.setPosition(shooter.collidesSpr.x, shooter.collidesSpr.y);
				
				
				// toStamp.destroy();
				// add(deadSprite);
				// deadSprite.body.space = null;
				// deadSprite.body.velocity = new Vec2(0,0);
			});
		}

		super.update(elapsed);
	}
}
