package;

import haxe.io.Bytes;
import haxe.io.Path;
import lime.utils.AssetBundle;
import lime.utils.AssetLibrary;
import lime.utils.AssetManifest;
import lime.utils.Assets;

#if sys
import sys.FileSystem;
#end

#if disable_preloader_assets
@:dox(hide) class ManifestResources {
	public static var preloadLibraries:Array<Dynamic>;
	public static var preloadLibraryNames:Array<String>;
	public static var rootPath:String;

	public static function init (config:Dynamic):Void {
		preloadLibraries = new Array ();
		preloadLibraryNames = new Array ();
	}
}
#else
@:access(lime.utils.Assets)


@:keep @:dox(hide) class ManifestResources {


	public static var preloadLibraries:Array<AssetLibrary>;
	public static var preloadLibraryNames:Array<String>;
	public static var rootPath:String;


	public static function init (config:Dynamic):Void {

		preloadLibraries = new Array ();
		preloadLibraryNames = new Array ();

		rootPath = null;

		if (config != null && Reflect.hasField (config, "rootPath")) {

			rootPath = Reflect.field (config, "rootPath");

			if(!StringTools.endsWith (rootPath, "/")) {

				rootPath += "/";

			}

		}

		if (rootPath == null) {

			#if (ios || tvos || webassembly)
			rootPath = "assets/";
			#elseif android
			rootPath = "";
			#elseif (console || sys)
			rootPath = lime.system.System.applicationDirectory;
			#else
			rootPath = "./";
			#end

		}

		#if (openfl && !flash && !display)
		openfl.text.Font.registerFont (__ASSET__OPENFL__flixel_fonts_nokiafc22_ttf);
		openfl.text.Font.registerFont (__ASSET__OPENFL__flixel_fonts_monsterrat_ttf);
		
		#end

		var data, manifest, library, bundle;

		data = '{"name":null,"assets":"aoy4:pathy27:assets%2Fimages%2Fblood.pngy4:sizei8203y4:typey5:IMAGEy2:idR1y7:preloadtgoR0y33:assets%2Fimages%2FPatagonia30.jpgR2i1334R3R4R5R7R6tgoR0y26:assets%2Fimages%2Fwall.pngR2i5753R3R4R5R8R6tgoR0y36:assets%2Fimages%2Fimages-go-here.txtR2zR3y4:TEXTR5R9R6tgoR0y50:assets%2Fimages%2Fchaos-marine-sprite-sheet.png%7ER2i246689R3y6:BINARYR5R11R6tgoR0y30:assets%2Fimages%2Ftiles.png%7ER2i1614042R3R12R5R13R6tgoR0y32:assets%2Fimages%2Fsoldier.png%7ER2i274R3R12R5R14R6tgoR0y47:assets%2Fimages%2Fchaos-marine-sprite-sheet.pngR2i230023R3R4R5R15R6tgoR0y27:assets%2Fimages%2Fblast.pngR2i5927R3R4R5R16R6tgoR0y29:assets%2Fimages%2Fterrain.pngR2i129353R3R4R5R17R6tgoR0y26:assets%2Fimages%2Ftest.pngR2i87056R3R4R5R18R6tgoR0y30:assets%2Fimages%2Fblood.png%7ER2i5054R3R12R5R19R6tgoR0y27:assets%2Fimages%2Ftiles.pngR2i1614042R3R4R5R20R6tgoR0y29:assets%2Fimages%2Fsoldier.pngR2i308R3R4R5R21R6tgoR0y29:assets%2Fimages%2Ftest.png%7ER2i73026R3R12R5R22R6tgoR0y47:assets%2Fimages%2Fspace-marine-sprite-sheet.pngR2i238276R3R4R5R23R6tgoR0y50:assets%2Fimages%2Fspace-marine-sprite-sheet.png%7ER2i302727R3R12R5R24R6tgoR0y31:assets%2Fimages%2Ftiles.png.kraR2i5053955R3R12R5R25R6tgoR0y28:assets%2Fimages%2Fbullet.pngR2i5022R3R4R5R26R6tgoR0y36:assets%2Fsounds%2Fsounds-go-here.txtR2zR3R10R5R27R6tgoR0y34:assets%2Fdata%2Fdata-goes-here.txtR2zR3R10R5R28R6tgoR0y26:assets%2Fdata%2Flevel1.csvR2i8880R3R10R5R29R6tgoR0y36:assets%2Fmusic%2Fmusic-goes-here.txtR2zR3R10R5R30R6tgoR2i39706R3y5:MUSICR5y28:flixel%2Fsounds%2Fflixel.mp3y9:pathGroupaR32y28:flixel%2Fsounds%2Fflixel.ogghR6tgoR2i8220R3R31R5y26:flixel%2Fsounds%2Fbeep.mp3R33aR35y26:flixel%2Fsounds%2Fbeep.ogghR6tgoR2i33629R3y5:SOUNDR5R34R33aR32R34hgoR2i6840R3R37R5R36R33aR35R36hgoR2i15744R3y4:FONTy9:classNamey35:__ASSET__flixel_fonts_nokiafc22_ttfR5y30:flixel%2Ffonts%2Fnokiafc22.ttfR6tgoR2i29724R3R38R39y36:__ASSET__flixel_fonts_monsterrat_ttfR5y31:flixel%2Ffonts%2Fmonsterrat.ttfR6tgoR0y33:flixel%2Fimages%2Fui%2Fbutton.pngR2i277R3R4R5R44R6tgoR0y36:flixel%2Fimages%2Flogo%2Fdefault.pngR2i505R3R4R5R45R6tgoR0y42:flixel%2Fimages%2Ftransitions%2Fsquare.pngR2i209R3R4R5R46R6tgoR0y53:flixel%2Fimages%2Ftransitions%2Fdiagonal_gradient.pngR2i730R3R4R5R47R6tgoR0y42:flixel%2Fimages%2Ftransitions%2Fcircle.pngR2i299R3R4R5R48R6tgoR0y43:flixel%2Fimages%2Ftransitions%2Fdiamond.pngR2i236R3R4R5R49R6tgh","rootPath":null,"version":2,"libraryArgs":[],"libraryType":null}';
		manifest = AssetManifest.parse (data, rootPath);
		library = AssetLibrary.fromManifest (manifest);
		Assets.registerLibrary ("default", library);
		

		library = Assets.getLibrary ("default");
		if (library != null) preloadLibraries.push (library);
		else preloadLibraryNames.push ("default");
		

	}


}

#if !display
#if flash

@:keep @:bind @:noCompletion #if display private #end class __ASSET__assets_images_blood_png extends flash.display.BitmapData { public function new () { super (0, 0, true, 0); } }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__assets_images_patagonia30_jpg extends flash.display.BitmapData { public function new () { super (0, 0, true, 0); } }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__assets_images_wall_png extends flash.display.BitmapData { public function new () { super (0, 0, true, 0); } }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__assets_images_images_go_here_txt extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__assets_images_chaos_marine_sprite_sheet_png_ extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__assets_images_tiles_png_ extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__assets_images_soldier_png_ extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__assets_images_chaos_marine_sprite_sheet_png extends flash.display.BitmapData { public function new () { super (0, 0, true, 0); } }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__assets_images_blast_png extends flash.display.BitmapData { public function new () { super (0, 0, true, 0); } }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__assets_images_terrain_png extends flash.display.BitmapData { public function new () { super (0, 0, true, 0); } }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__assets_images_test_png extends flash.display.BitmapData { public function new () { super (0, 0, true, 0); } }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__assets_images_blood_png_ extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__assets_images_tiles_png extends flash.display.BitmapData { public function new () { super (0, 0, true, 0); } }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__assets_images_soldier_png extends flash.display.BitmapData { public function new () { super (0, 0, true, 0); } }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__assets_images_test_png_ extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__assets_images_space_marine_sprite_sheet_png extends flash.display.BitmapData { public function new () { super (0, 0, true, 0); } }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__assets_images_space_marine_sprite_sheet_png_ extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__assets_images_tiles_png_kra extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__assets_images_bullet_png extends flash.display.BitmapData { public function new () { super (0, 0, true, 0); } }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__assets_sounds_sounds_go_here_txt extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__assets_data_data_goes_here_txt extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__assets_data_level1_csv extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__assets_music_music_goes_here_txt extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__flixel_sounds_flixel_mp3 extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__flixel_sounds_beep_mp3 extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__flixel_sounds_flixel_ogg extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__flixel_sounds_beep_ogg extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__flixel_fonts_nokiafc22_ttf extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__flixel_fonts_monsterrat_ttf extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__flixel_images_ui_button_png extends flash.display.BitmapData { public function new () { super (0, 0, true, 0); } }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__flixel_images_logo_default_png extends flash.display.BitmapData { public function new () { super (0, 0, true, 0); } }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__flixel_images_transitions_square_png extends flash.display.BitmapData { public function new () { super (0, 0, true, 0); } }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__flixel_images_transitions_diagonal_gradient_png extends flash.display.BitmapData { public function new () { super (0, 0, true, 0); } }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__flixel_images_transitions_circle_png extends flash.display.BitmapData { public function new () { super (0, 0, true, 0); } }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__flixel_images_transitions_diamond_png extends flash.display.BitmapData { public function new () { super (0, 0, true, 0); } }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__manifest_default_json extends null { }


#elseif (desktop || cpp)

@:keep @:image("assets/images/blood.png") @:noCompletion #if display private #end class __ASSET__assets_images_blood_png extends lime.graphics.Image {}
@:keep @:image("assets/images/Patagonia30.jpg") @:noCompletion #if display private #end class __ASSET__assets_images_patagonia30_jpg extends lime.graphics.Image {}
@:keep @:image("assets/images/wall.png") @:noCompletion #if display private #end class __ASSET__assets_images_wall_png extends lime.graphics.Image {}
@:keep @:file("assets/images/images-go-here.txt") @:noCompletion #if display private #end class __ASSET__assets_images_images_go_here_txt extends haxe.io.Bytes {}
@:keep @:file("assets/images/chaos-marine-sprite-sheet.png~") @:noCompletion #if display private #end class __ASSET__assets_images_chaos_marine_sprite_sheet_png_ extends haxe.io.Bytes {}
@:keep @:file("assets/images/tiles.png~") @:noCompletion #if display private #end class __ASSET__assets_images_tiles_png_ extends haxe.io.Bytes {}
@:keep @:file("assets/images/soldier.png~") @:noCompletion #if display private #end class __ASSET__assets_images_soldier_png_ extends haxe.io.Bytes {}
@:keep @:image("assets/images/chaos-marine-sprite-sheet.png") @:noCompletion #if display private #end class __ASSET__assets_images_chaos_marine_sprite_sheet_png extends lime.graphics.Image {}
@:keep @:image("assets/images/blast.png") @:noCompletion #if display private #end class __ASSET__assets_images_blast_png extends lime.graphics.Image {}
@:keep @:image("assets/images/terrain.png") @:noCompletion #if display private #end class __ASSET__assets_images_terrain_png extends lime.graphics.Image {}
@:keep @:image("assets/images/test.png") @:noCompletion #if display private #end class __ASSET__assets_images_test_png extends lime.graphics.Image {}
@:keep @:file("assets/images/blood.png~") @:noCompletion #if display private #end class __ASSET__assets_images_blood_png_ extends haxe.io.Bytes {}
@:keep @:image("assets/images/tiles.png") @:noCompletion #if display private #end class __ASSET__assets_images_tiles_png extends lime.graphics.Image {}
@:keep @:image("assets/images/soldier.png") @:noCompletion #if display private #end class __ASSET__assets_images_soldier_png extends lime.graphics.Image {}
@:keep @:file("assets/images/test.png~") @:noCompletion #if display private #end class __ASSET__assets_images_test_png_ extends haxe.io.Bytes {}
@:keep @:image("assets/images/space-marine-sprite-sheet.png") @:noCompletion #if display private #end class __ASSET__assets_images_space_marine_sprite_sheet_png extends lime.graphics.Image {}
@:keep @:file("assets/images/space-marine-sprite-sheet.png~") @:noCompletion #if display private #end class __ASSET__assets_images_space_marine_sprite_sheet_png_ extends haxe.io.Bytes {}
@:keep @:file("assets/images/tiles.png.kra") @:noCompletion #if display private #end class __ASSET__assets_images_tiles_png_kra extends haxe.io.Bytes {}
@:keep @:image("assets/images/bullet.png") @:noCompletion #if display private #end class __ASSET__assets_images_bullet_png extends lime.graphics.Image {}
@:keep @:file("assets/sounds/sounds-go-here.txt") @:noCompletion #if display private #end class __ASSET__assets_sounds_sounds_go_here_txt extends haxe.io.Bytes {}
@:keep @:file("assets/data/data-goes-here.txt") @:noCompletion #if display private #end class __ASSET__assets_data_data_goes_here_txt extends haxe.io.Bytes {}
@:keep @:file("assets/data/level1.csv") @:noCompletion #if display private #end class __ASSET__assets_data_level1_csv extends haxe.io.Bytes {}
@:keep @:file("assets/music/music-goes-here.txt") @:noCompletion #if display private #end class __ASSET__assets_music_music_goes_here_txt extends haxe.io.Bytes {}
@:keep @:file("/home/sj/haxelib/flixel/5,8,0/assets/sounds/flixel.mp3") @:noCompletion #if display private #end class __ASSET__flixel_sounds_flixel_mp3 extends haxe.io.Bytes {}
@:keep @:file("/home/sj/haxelib/flixel/5,8,0/assets/sounds/beep.mp3") @:noCompletion #if display private #end class __ASSET__flixel_sounds_beep_mp3 extends haxe.io.Bytes {}
@:keep @:file("/home/sj/haxelib/flixel/5,8,0/assets/sounds/flixel.ogg") @:noCompletion #if display private #end class __ASSET__flixel_sounds_flixel_ogg extends haxe.io.Bytes {}
@:keep @:file("/home/sj/haxelib/flixel/5,8,0/assets/sounds/beep.ogg") @:noCompletion #if display private #end class __ASSET__flixel_sounds_beep_ogg extends haxe.io.Bytes {}
@:keep @:font("export/html5/obj/webfont/nokiafc22.ttf") @:noCompletion #if display private #end class __ASSET__flixel_fonts_nokiafc22_ttf extends lime.text.Font {}
@:keep @:font("export/html5/obj/webfont/monsterrat.ttf") @:noCompletion #if display private #end class __ASSET__flixel_fonts_monsterrat_ttf extends lime.text.Font {}
@:keep @:image("/home/sj/haxelib/flixel/5,8,0/assets/images/ui/button.png") @:noCompletion #if display private #end class __ASSET__flixel_images_ui_button_png extends lime.graphics.Image {}
@:keep @:image("/home/sj/haxelib/flixel/5,8,0/assets/images/logo/default.png") @:noCompletion #if display private #end class __ASSET__flixel_images_logo_default_png extends lime.graphics.Image {}
@:keep @:image("/home/sj/haxelib/flixel-addons/3,3,0/assets/images/transitions/square.png") @:noCompletion #if display private #end class __ASSET__flixel_images_transitions_square_png extends lime.graphics.Image {}
@:keep @:image("/home/sj/haxelib/flixel-addons/3,3,0/assets/images/transitions/diagonal_gradient.png") @:noCompletion #if display private #end class __ASSET__flixel_images_transitions_diagonal_gradient_png extends lime.graphics.Image {}
@:keep @:image("/home/sj/haxelib/flixel-addons/3,3,0/assets/images/transitions/circle.png") @:noCompletion #if display private #end class __ASSET__flixel_images_transitions_circle_png extends lime.graphics.Image {}
@:keep @:image("/home/sj/haxelib/flixel-addons/3,3,0/assets/images/transitions/diamond.png") @:noCompletion #if display private #end class __ASSET__flixel_images_transitions_diamond_png extends lime.graphics.Image {}
@:keep @:file("") @:noCompletion #if display private #end class __ASSET__manifest_default_json extends haxe.io.Bytes {}



#else

@:keep @:expose('__ASSET__flixel_fonts_nokiafc22_ttf') @:noCompletion #if display private #end class __ASSET__flixel_fonts_nokiafc22_ttf extends lime.text.Font { public function new () { #if !html5 __fontPath = "flixel/fonts/nokiafc22"; #else ascender = 2048; descender = -512; height = 2816; numGlyphs = 172; underlinePosition = -640; underlineThickness = 256; unitsPerEM = 2048; #end name = "Nokia Cellphone FC Small"; super (); }}
@:keep @:expose('__ASSET__flixel_fonts_monsterrat_ttf') @:noCompletion #if display private #end class __ASSET__flixel_fonts_monsterrat_ttf extends lime.text.Font { public function new () { #if !html5 __fontPath = "flixel/fonts/monsterrat"; #else ascender = 968; descender = -251; height = 1219; numGlyphs = 263; underlinePosition = -150; underlineThickness = 50; unitsPerEM = 1000; #end name = "Monsterrat"; super (); }}


#end

#if (openfl && !flash)

#if html5
@:keep @:expose('__ASSET__OPENFL__flixel_fonts_nokiafc22_ttf') @:noCompletion #if display private #end class __ASSET__OPENFL__flixel_fonts_nokiafc22_ttf extends openfl.text.Font { public function new () { __fromLimeFont (new __ASSET__flixel_fonts_nokiafc22_ttf ()); super (); }}
@:keep @:expose('__ASSET__OPENFL__flixel_fonts_monsterrat_ttf') @:noCompletion #if display private #end class __ASSET__OPENFL__flixel_fonts_monsterrat_ttf extends openfl.text.Font { public function new () { __fromLimeFont (new __ASSET__flixel_fonts_monsterrat_ttf ()); super (); }}

#else
@:keep @:expose('__ASSET__OPENFL__flixel_fonts_nokiafc22_ttf') @:noCompletion #if display private #end class __ASSET__OPENFL__flixel_fonts_nokiafc22_ttf extends openfl.text.Font { public function new () { __fromLimeFont (new __ASSET__flixel_fonts_nokiafc22_ttf ()); super (); }}
@:keep @:expose('__ASSET__OPENFL__flixel_fonts_monsterrat_ttf') @:noCompletion #if display private #end class __ASSET__OPENFL__flixel_fonts_monsterrat_ttf extends openfl.text.Font { public function new () { __fromLimeFont (new __ASSET__flixel_fonts_monsterrat_ttf ()); super (); }}

#end

#end
#end

#end