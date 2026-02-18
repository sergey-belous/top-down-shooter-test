package;

import Character;
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
import flixel.system.FlxAssets.FlxGraphicAsset;
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
	public var collidesTarget:FlxNapeSprite = null;

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
			// Match visual hitbox to physical bullet radius (8px).
			spr.makeGraphic(16, 16, 0x0);
			spr.alpha = 0;

			spr.antialiasing = true;
			spr.body.allowRotation = false;
			spr.createCircularBody(8);
			spr.setBodyMaterial(0, .2, .4, 20);
			spr.body.cbTypes.add(CB_BULLET);
			spr.body.isBullet = true;
			spr.body.setShapeFilters(new InteractionFilter(Character.GROUP_BULLET, Character.MASK_ALL & ~Character.GROUP_PLAYER));
			spr.body.userData.sprite = spr;
			spr.kill();
			add(spr);
		}

		FlxNapeSpace.space.listeners.add(new InteractionListener(CbEvent.BEGIN, InteractionType.COLLISION, CB_BULLET, Character.CB_TARGET, onBulletCollides));
	}

	function launchProjectile(spr:FlxSprite)
	{
		if (disableShooting)
			return;

		if (box == null)
			return;

		var spr = recycle(FlxNapeSprite);

		var playerCenterX:Float = box.body != null ? box.body.position.x : box.getPosition().x + box.width / 2;
		var playerCenterY:Float = box.body != null ? box.body.position.y : box.getPosition().y + box.height / 2;
		var mouseX:Float = FlxG.mouse.x;
		var mouseY:Float = FlxG.mouse.y;

		var directionX:Float = mouseX - playerCenterX;
		var directionY:Float = mouseY - playerCenterY;
		var length:Float = Math.sqrt(directionX * directionX + directionY * directionY);
		if (length <= 0.0001)
		{
			directionX = 1;
			directionY = 0;
		}
		else
		{
			directionX /= length;
			directionY /= length;
		}

		var spawnDistance:Float = 36;
		var projectileCenterX:Float = playerCenterX + directionX * spawnDistance;
		var projectileCenterY:Float = playerCenterY + directionY * spawnDistance;

		spr.setPosition(projectileCenterX - spr.width / 2, projectileCenterY - spr.height / 2);
		spr.body.velocity.x = directionX * impulse;
		spr.body.velocity.y = directionY * impulse;

		var trail = new Trail(spr, projectileCenterX, projectileCenterY, 0.25, 2).start(false, FlxG.elapsed);
		var trail2 = new Trail(spr, projectileCenterX, projectileCenterY, 0.1, 3, 'assets/images/blast.png').start(true, FlxG.elapsed);
		FlxG.state.add(trail);
		FlxG.state.add(trail2);
	}

	public function onBulletCollides(clbk:InteractionCallback)
	{
		var body1 = clbk.int1.castBody;
		var body2 = clbk.int2.castBody;
		if (body1 == null || body2 == null)
		{
			return;
		}

		var bulletBody = body1.cbTypes.has(CB_BULLET) ? body1 : body2;
		var targetBody = bulletBody == body1 ? body2 : body1;
		var bulletSprite:FlxNapeSprite = cast bulletBody.userData.sprite;
		if (bulletSprite == null)
		{
			return;
		}

		this.collidesTarget = cast targetBody.userData.sprite;
		this.collidesSpr = bulletSprite;
		this.collides = true;
		if (this.collides && this.collidesSpr != null)
		{
			var bullet = this.collidesSpr;
			var target = this.collidesTarget;
			if (target != null && Std.isOfType(target, Enemy))
			{
				var enemy:Enemy = cast target;
				if (enemy.debugHitbox != null && !bullet.overlaps(enemy.debugHitbox))
				{
					return;
				}
				var state = FlxG.state;
				if (Std.isOfType(state, PlayState))
				{
					cast(state, PlayState).damageBrick(enemy, 12);
				}
			}

			// Убиваем снаряд после столкновения
			bullet.kill();
			this.collides = false;
			this.collidesSpr = null;
			this.collidesTarget = null;
		}
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
	var hasStartPoint:Bool;

	public function new(Attach:FlxNapeSprite, ?startX:Float, ?startY:Float, ?Lifespan:Float = 0.25, ?Scale:Float = 1,
			?Sprite:FlxGraphicAsset = "assets/images/bullet.png")
	{
		super(startX != null ? startX : 0, startY != null ? startY : 0);

		loadParticles(Sprite, 20, 0);
		attach = Attach;
		hasStartPoint = startX != null && startY != null;
		if (hasStartPoint)
		{
			setPosition(startX, startY);
		}

		velocity.set(0, 0);
		scale.set(Scale, Scale, Scale, Scale, 0, 0, 0, 0);
		lifespan.set(Lifespan);
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
		if (hasStartPoint)
		{
			// Keep initial spawn point for first frame.
			hasStartPoint = false;
			return;
		}

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