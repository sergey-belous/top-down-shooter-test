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

		var spr = recycle(FlxNapeSprite);
		var trail = new Trail(spr).start(false, FlxG.elapsed);
		FlxG.state.add(trail);

		if (box != null)
		{
			// Получаем центр спрайта игрока (позиция + половина размеров)
			var playerCenterX:Float = box.getPosition().x + box.width / 2;
			var playerCenterY:Float = box.getPosition().y + box.height / 2;
		
			// Получаем центр мыши (учитываем, что координаты мыши уже в мировых координатах)
			var mouseX:Float = FlxG.mouse.x;
			var mouseY:Float = FlxG.mouse.y;

			// Вычисляем вектор направления от центра игрока к мыши
			var directionX:Float = mouseX - playerCenterX;
			var directionY:Float = mouseY - playerCenterY;

			// Нормализуем вектор направления
			var length:Float = Math.sqrt(directionX * directionX + directionY * directionY);
			if (length > 0)
			{
				directionX /= length;
				directionY /= length;
			}
			// Задаем расстояние от центра игрока для появления снаряда
			var spawnDistance:Float = 36; // Расстояние от центра игрока

			// Вычисляем центр снаряда
			var projectileCenterX:Float = playerCenterX + directionX * spawnDistance;
			var projectileCenterY:Float = playerCenterY + directionY * spawnDistance;

			// Переводим центр снаряда в координаты верхнего левого угла
			// (вычитаем половину размеров снаряда)
			spr.setPosition(projectileCenterX - spr.width / 2, projectileCenterY - spr.height / 2);

			// Задаем скорость в направлении мыши
			// Используем нормализованный вектор направления и умножаем на импульс
			spr.body.velocity.x = directionX * impulse;
			spr.body.velocity.y = directionY * impulse;
		
			trace('Player center: ($playerCenterX, $playerCenterY)');
			trace('Mouse: ($mouseX, $mouseY)');
			trace('Projectile spawn: (${spr.body.position.x}, ${spr.body.position.y})');
			trace('Direction: ($directionX, $directionY)');
			trace('Velocity: (${spr.body.velocity.x}, ${spr.body.velocity.y})');
		}
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
					cast(state, PlayState).damageBrick(enemy, 34);
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

	public function new(Attach:FlxNapeSprite)
	{
		super(0, 0);

		// loadParticles("assets/shooter.png", 20, 0);
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