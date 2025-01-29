package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.nape.FlxNapeSpace;
import flixel.addons.nape.FlxNapeSprite;
import flixel.effects.particles.FlxEmitter;
import flixel.group.FlxGroup;
import flixel.input.mouse.FlxMouseEvent;
import flixel.input.touch.FlxTouch;
import flixel.input.touch.FlxTouchManager;
import flixel.math.FlxPoint;
import nape.callbacks.CbEvent;
import nape.callbacks.CbType;
import nape.callbacks.InteractionCallback;
import nape.callbacks.InteractionListener;
import nape.callbacks.InteractionType;
import nape.constraint.DistanceJoint;
import nape.dynamics.InteractionFilter;
import nape.geom.Vec2;
import openfl.events.TouchEvent;

/**
 * Fires small projectiles to where the user clicks.
 *
 * @author TiagoLr ( ~~~ProG4mr~~~ )
 * @link https://github.com/ProG4mr
 */
class Shooter extends FlxTypedGroup<FlxNapeSprite>
{
	public var CB_BULLET:CbType = new CbType();

	public var mouseJoint:DistanceJoint;
	public var impulse = 2500;

	public var box:FlxNapeSprite = null;

	public var collides:Bool = false;
	public var collidesSpr:FlxNapeSprite = null;

	public var disableShooting:Bool;

	public function new()
	{
		super(64);

		// Background sprite is used to detect mouseClicks on empty space.
		// When such click is detected shooter launches a projectile.
		// If a selectable sprite is clicked, it creates a mouseJoint to that sprite.
		var background:FlxSprite = new FlxSprite();
		background.makeGraphic(640, 480, 0xFF000000);
		background.alpha = 1;
		FlxG.state.insert(0, background);
		FlxMouseEvent.add(background, launchProjectile);

		for (i in 0...maxSize)
		{
			var spr = new FlxNapeSprite(0, 0);
			spr.makeGraphic(2, 2, 0x0);

			spr.antialiasing = true;
			spr.body.allowRotation = false;
			spr.createCircularBody(8);
			spr.setBodyMaterial(0, .2, .4, 20);
			spr.body.cbTypes.add(CB_BULLET);
			spr.body.isBullet = true;
			spr.body.setShapeFilters(new InteractionFilter(256, ~256));
			spr.kill();
			add(spr);
		}

		FlxNapeSpace.space.listeners.add(new InteractionListener(CbEvent.BEGIN, InteractionType.COLLISION, CB_BULLET, CbType.ANY_BODY, onBulletCollides));
	}

	function launchProjectile(spr:FlxSprite)
	{
		if (disableShooting)
			return;

		

		var spr = recycle(FlxNapeSprite);
		var trail = new Trail(spr).start(false, FlxG.elapsed);
		FlxG.state.add(trail);


		if (box != null) {
			spr.body.position.y = 64 + box.getPosition().y;
			spr.body.position.x = 64 + box.getPosition().x;
			// var toTrace = spr.body.worldPointToLocal(new Vec2(FlxG.mouse.x, FlxG.mouse.y), true);
			// spr.body.velocity.setxy(toTrace.x, toTrace.y);
			spr.body.velocity.setxy(FlxG.mouse.x - spr.body.position.x, FlxG.mouse.y - spr.body.position.y);
			spr.body.velocity.length = impulse;
		} else {
			// spr.body.position.y = FlxG.mouse.y;
			// spr.body.position.x = FlxG.mouse.x;
			// spr.body.velocity.setxy(-100, 0);
			// spr.body.velocity.length = impulse;
		}

		// spr.body.angularVel = 30;
	}

	public function onBulletCollides(clbk:InteractionCallback)
	{
		var spr = getFirstAlive();
		if (spr != null) {
			this.collidesSpr = spr;
			trace('spr', spr);
			spr.kill();
		}

		this.collides = true;
	}

	public function setBox(_box:FlxNapeSprite)
	{
		this.box = _box;
	}

	public inline function registerPhysSprite(spr:FlxNapeSprite)
	{
		FlxMouseEvent.add(spr, createMouseJoint);
	}

	function createMouseJoint(spr:FlxNapeSprite)
	{
		mouseJoint = new DistanceJoint(FlxNapeSpace.space.world, spr.body, new Vec2(FlxG.mouse.x, FlxG.mouse.y),
			spr.body.worldPointToLocal(new Vec2(FlxG.mouse.x, FlxG.mouse.y)), 0, 0);

		mouseJoint.space = FlxNapeSpace.space;
	}

	override public function update(elapsed:Float):Void
	{
		this.collides = false;

		super.update(elapsed);

		if (mouseJoint != null)
		{
			mouseJoint.anchor1 = new Vec2(FlxG.mouse.x, FlxG.mouse.y);

			if (FlxG.mouse.justReleased || cast(FlxG.touches.justReleased, Bool))
			{
				mouseJoint.space = null;
			}
		}
	}

	public function setSpeed(maxSpeed:Int)
	{
		impulse = maxSpeed;
	}

	public function setDensity(density:Float)
	{
		for (sprite in members)
		{
			sprite.body.shapes.at(0).material.density = density;
		}
	}
}

class Trail extends FlxEmitter
{
	var attach:FlxNapeSprite;

	public function new(Attach:FlxNapeSprite)
	{
		super(0, 0);

		loadParticles("assets/shooter.png", 20, 0);
		attach = Attach;

		velocity.set(0, 0);
		scale.set(1, 1, 1, 1, 0, 0, 0, 0);
		lifespan.set(0.25);
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);

		if (attach.alive)
		{
			focusOn(attach);
		}
		else
		{
			emitting = false;
		}
	}
}