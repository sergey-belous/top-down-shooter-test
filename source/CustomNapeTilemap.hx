package;

import Constants.TileType;
import haxe.Json;
import flixel.addons.nape.FlxNapeSpace;
import flixel.addons.nape.FlxNapeTilemap;
import flixel.math.FlxPoint;
import flixel.system.FlxAssets;
import flixel.tile.FlxBaseTilemap.FlxTilemapAutoTiling;
import flixel.tile.FlxTilemap;
import nape.geom.Vec2;
import nape.shape.Polygon;
import openfl.Assets;

using Lambda;
using logic.PhysUtil;

class CustomNapeTilemap extends FlxNapeTilemap
{
	public var spawnPoints(default, null) = new Array<FlxPoint>();
	public var backgroundLayer:FlxTilemap = null;
	public var foregroundLayer:FlxTilemap = null;

	public function new(tiles:String, graphics:FlxTilemapGraphicAsset, tileSize:Int)
	{
		super();

		if (StringTools.endsWith(tiles.toLowerCase(), ".json"))
		{
			loadFromTiledJson(tiles, graphics, tileSize);
			return;
		}

		loadMapFromCSV(tiles, graphics, tileSize, tileSize, FlxTilemapAutoTiling.OFF);
		setupTileIndices(TileType.BLOCK);

		var vertices = new Array<Vec2>();
		vertices.push(Vec2.get(16, 0));
		vertices.push(Vec2.get(16, 16));
		vertices.push(Vec2.get(0, 16));
		placeCustomPolygonSafe(TileType.SLOPE_SE, vertices);
		vertices[0] = Vec2.get(0, 0);
		placeCustomPolygonSafe(TileType.SLOPE_SW, vertices);
		vertices[1] = Vec2.get(16, 0);
		placeCustomPolygonSafe(TileType.SLOPE_NW, vertices);
		vertices[2] = Vec2.get(16, 16);
		placeCustomPolygonSafe(TileType.SLOPE_NE, vertices);

		for (ty in 0...heightInTiles)
		{
			var prevOneWay = false;
			var length:Int = 0;
			var startX:Int = 0;
			var startY:Int = 0;

			for (tx in 0...widthInTiles)
			{
				if (TileType.ONE_WAY.has(getTile(tx, ty)))
				{
					if (!prevOneWay)
					{
						prevOneWay = true;
						length = 0;
						startX = tx;
						startY = ty;
					}
					length++;
				}
				else if (prevOneWay)
				{
					prevOneWay = false;
					var startPos = getTileCoordsByIndex(startX + startY * widthInTiles, false);
					PhysUtil.setOneWayLong(this, startPos, length);
				}
			}

			if (prevOneWay)
			{
				prevOneWay = false;
				var startPos = getTileCoordsByIndex(startX + startY * widthInTiles, false);
				PhysUtil.setOneWayLong(this, startPos, length);
			}
		}

		var spawnTiles:Array<FlxPoint> = cast getTileCoords(TileType.SPAWN, false);
		for (point in spawnTiles)
		{
			point.x += scaledTileHeight * 0.5;
			spawnPoints.push(point);
		}
	}

	function loadFromTiledJson(mapPath:String, graphics:FlxTilemapGraphicAsset, tileSize:Int):Void
	{
		var rawText = Assets.getText(mapPath);
		var mapData:Dynamic = Json.parse(rawText);
		var width:Int = cast mapData.width;
		var height:Int = cast mapData.height;
		var tileWidth:Int = mapData.tilewidth != null ? cast mapData.tilewidth : tileSize;
		var tileHeight:Int = mapData.tileheight != null ? cast mapData.tileheight : tileSize;
		var expectedCount = width * height;

		var backgroundData = extractLayerDataById(mapData.layers, 1, expectedCount);
		var obstaclesData = extractLayerDataById(mapData.layers, 4, expectedCount);
		var foregroundData = extractLayerDataById(mapData.layers, 5, expectedCount);

		backgroundLayer = new FlxTilemap();
		backgroundLayer.loadMapFromArray(backgroundData, width, height, graphics, tileWidth, tileHeight, FlxTilemapAutoTiling.OFF);
		backgroundLayer.antialiasing = antialiasing;

		loadMapFromArray(obstaclesData, width, height, graphics, tileWidth, tileHeight, FlxTilemapAutoTiling.OFF);
		setupCollideIndex(1);

		foregroundLayer = new FlxTilemap();
		foregroundLayer.loadMapFromArray(foregroundData, width, height, graphics, tileWidth, tileHeight, FlxTilemapAutoTiling.OFF);
		foregroundLayer.antialiasing = antialiasing;

		spawnPoints = [];
	}

	function extractLayerDataById(layers:Dynamic, layerId:Int, expectedCount:Int):Array<Int>
	{
		var result = new Array<Int>();
		var list:Array<Dynamic> = cast layers;
		for (layer in list)
		{
			var type:String = cast layer.type;
			var id:Int = cast layer.id;
			if (type == "tilelayer" && id == layerId)
			{
				var data:Array<Dynamic> = cast layer.data;
				for (value in data)
				{
					result.push(normalizeGid(cast value));
				}
				break;
			}
		}

		if (result.length == 0)
		{
			for (_ in 0...expectedCount)
			{
				result.push(0);
			}
		}
		return result;
	}

	inline function normalizeGid(rawValue:Int):Int
	{
		return rawValue & 0x1FFFFFFF;
	}

	function placeCustomPolygonSafe(tileIndices:Array<Int>, vertices:Array<Vec2>):Void
	{
		body.space = null;
		for (index in tileIndices)
		{
			var points:Array<FlxPoint> = cast getTileCoords(index, false);
			if (points == null)
			{
				continue;
			}
			for (point in points)
			{
				var polygon = new Polygon(vertices);
				polygon.translate(Vec2.get(point.x, point.y));
				body.shapes.add(polygon);
			}
		}
		body.space = FlxNapeSpace.space;
	}
}