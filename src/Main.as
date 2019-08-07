package
{

	import alternativa.engine3d.controllers.SimpleObjectController;
	import alternativa.engine3d.core.Camera3D;
	import alternativa.engine3d.core.Light3D;
	import alternativa.engine3d.core.Object3D;
	import alternativa.engine3d.core.Resource;
	import alternativa.engine3d.core.View;
	import alternativa.engine3d.lights.AmbientLight;
	import alternativa.engine3d.lights.DirectionalLight;
	import alternativa.engine3d.loaders.ExporterA3D;
	import alternativa.engine3d.loaders.Parser3DS;
	import alternativa.engine3d.loaders.ParserA3D;
	import alternativa.engine3d.loaders.ParserCollada;
	import alternativa.engine3d.loaders.ParserMaterial;
	import alternativa.engine3d.loaders.TexturesLoader;
	import alternativa.engine3d.loaders.events.TexturesLoaderEvent;
	import alternativa.engine3d.materials.FillMaterial;
	import alternativa.engine3d.materials.Material;
	import alternativa.engine3d.materials.StandardMaterial;
	import alternativa.engine3d.materials.TextureMaterial;
	import alternativa.engine3d.materials.VertexLightTextureMaterial;
	import alternativa.engine3d.objects.Mesh;
	import alternativa.engine3d.objects.SkyBox;
	import alternativa.engine3d.objects.Surface;
	import alternativa.engine3d.primitives.Box;
	import alternativa.engine3d.primitives.Plane;
	import alternativa.engine3d.resources.BitmapTextureResource;
	import alternativa.engine3d.resources.ExternalTextureResource;
	import alternativa.engine3d.resources.Geometry;
	import alternativa.engine3d.shadows.DirectionalLightShadow;
	import alternativa.tanks.config.Config;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.StageQuality;
	import flash.display3D.Context3DRenderMode;
	import flash.display3D.Context3DTextureFormat;
	import flash.display3D.textures.Texture;
	import flash.events.TextEvent;
	import flash.geom.Matrix;
	import flash.geom.Matrix3D;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.net.URLRequest;
	import flash.system.Capabilities;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	import flash.utils.*;
	import utils.MaterialProcessor;
	import utils.ResourceManager;

	import flash.display.Sprite;
	import flash.display.Stage3D;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;

	public class Main extends Sprite {

		public static var stage3D:Stage3D;
		private var resourceManager:ResourceManager;
		public static var resourceManager1:ResourceManager;
		public static var scene:Object3D;
		private var mainCamera:Camera3D;
		private var dirLight:DirectionalLight;
		public static var shadow:DirectionalLightShadow;

		private var controller:SimpleObjectController;
		
		private var displayText:TextField;
		
		private var displayText1:TextField;
		
		private var loader:Loader = new Loader();
		
		private const RESOURCE_LIMIT_ERROR_ID:int = 3691;
		
		public static var saqq:int = 0;

		public function Main() {
			if (stage == null) {
				addEventListener(Event.ADDED_TO_STAGE, init);
			} else {
				init();
			}
		}

		private function init(e:Event = null):void {
			removeEventListener(Event.ADDED_TO_STAGE, init);

			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.stageFocusRect = false;
			stage.quality = StageQuality.HIGH;

			scene = new Object3D();
			
			//resourceManager = new ResourceManager(scene);
			
			stage3D = stage.stage3Ds[0];
			if (stage3D.context3D != null) {
				onContext3DCreate();
			} else {
				stage3D.addEventListener(Event.CONTEXT3D_CREATE, onContext3DCreate);
				stage3D.requestContext3D(Context3DRenderMode.AUTO);
			}

			mainCamera = new Camera3D(10, 50000);
			mainCamera.view = new View(stage.stageWidth, stage.stageHeight, false, 0, 1, 0);
			scene.addChild(mainCamera);
			addChild(mainCamera.view);
			
			addChild(mainCamera.diagram);
			
			initHUD();
			initController();
			prepareView();
			prepareLightsAndShadows();
		}
		
		private function initHUD():void {
			var info:TextInfo = new TextInfo();
			info.x = 10;
			info.y = 10;
			info.write("Map viewer");
			info.write("----");
			info.write("Про — передвижение");
			info.write("WSAD and Arrows — передвижение");
			info.write("Q — сглаживание включить/выключить");
			info.write("----");

			info.write("U — SSAO эффект включить/выключить");
			info.write("I — тени включить/выключить");
			info.write("----");

			info.write("+/- — интенсивность SSAO");
			addChild(info);
		}
		
		private function prepareView():void {
			controller.speed = 800;
			//mainCamera.view.backgroundColor = 0x146298;
			//mainCamera.farClipping = 500;
			//mainCamera.matrix = new Matrix3D(Vector.<Number>([-0.2912704050540924, 0.9566407799720764, 0, 0, -0.4682687222957611, -0.1425747573375702, -0.8720073699951172, 0, -0.8341978192329407, -0.25398993492126465, 0.4894927442073822, 0, 52.13594436645508, 19.32925796508789, 3.971318483352661, 1]));
			controller.smoothingDelay = 0.7;
			//controller.updateObjectTransform();

			/*mainCamera.effectMode = Camera3D.MODE_SSAO_COLOR;
			// Following four parameters depend on scene dimension / camera dimension ratio
			// We relied that in the current scene the camera sees about 30 units of 3d space
			// And the broken house has similar size
			mainCamera.ssaoAngular.occludingRadius = 0.7;
			mainCamera.ssaoAngular.secondPassOccludingRadius = 0.32;
			mainCamera.ssaoAngular.maxDistance = 1;
			mainCamera.ssaoAngular.falloff = 7.2;

			mainCamera.ssaoAngular.intensity = 0.85;
			mainCamera.ssaoAngular.secondPassAmount = 0.76;*/
		}
		
		private function inu(e:Event = null):void {
			//Main.shadow.addCaster(scene);
			//var k:ExporterA3D = new ExporterA3D();
			//var d:ByteArray = k.export(scene);
			//trace(d.toString());
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE,iniSky);
			loader.load(new URLRequest("resources/2.jpg"));
		}
		
		private function prepareLightsAndShadows():void {
			var ambient:AmbientLight = new AmbientLight(0x8bccfa);//0x8bccfa
			ambient.intensity = 0.6;
			scene.addChild(ambient);
			dirLight = new DirectionalLight(Number(String("0x"+"FFA64D")));//0xffd98f//ffd98f
			dirLight.intensity = 1.2;
			dirLight.z = 1.25;
			dirLight.x = 1;
			dirLight.y = 1;
			dirLight.lookAt(0, 0, 0);
			scene.addChild(dirLight);
			shadow = new DirectionalLightShadow(15000, 12000, -13000, 13000, 2048,1);
			shadow.biasMultiplier = 0.996;//0.993;
			dirLight.shadow = shadow;
		}

		public function initController():void {
			mainCamera.z = 0;
			//mainCamera.lookAt(-4750, 9750, 1200);
			controller = new SimpleObjectController(stage, mainCamera, 100, 3, 0.7);
		}
		
		public function onContext3DCreate(e:Event = null):void {
			//resourceManager.context3D = stage3D.context3D;
			stage3D.context3D.enableErrorChecking = false;
			initScene();
			//stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			//stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
			//scene.addChild(dirLight);
		}

		/**
		 * Override this method to perform scene initialization
		 */
		/*public function initScene():void {
			//var c:Config = new Config();
			//c.addEventListener(Event.COMPLETE,inu);
			//c.load("config.xml", "map");
			var parser:Parser3DS;
			parser = new Parser3DS();
			parser.parse(new SceneClass());
			var object:Mesh = parser.objects[0] as Mesh;
			//var skyBoxTexture1:BitmapData = new BitmapData(256, 256);
			/*var normal:BitmapData = new BitmapData(1, 1, false, 0x7F7FFF);
			var t2:BitmapTextureResource = new BitmapTextureResource(normal, true);
			var t:BitmapTextureResource = new BitmapTextureResource(skyBoxTexture1);
			var material:StandardMaterial = new StandardMaterial(t, t2);
			material.specularPower = 0;*/
			/*var d:ExternalTextureResource = new ExternalTextureResource("");
			var texture:Texture = stage3D.context3D.createTexture(skyBoxTexture1.width, skyBoxTexture1.height, Context3DTextureFormat.BGRA, true);
			texture.uploadFromBitmapData(skyBoxTexture1, 0);
			BitmapTextureResource.createMips(texture, skyBoxTexture1);
			d.data = texture;
			var skyBoxTexture:BitmapData = new BitmapData(1, 1, false, 0x7F7FFF);
			var d1:ExternalTextureResource = new ExternalTextureResource("");
			var texture1:Texture = stage3D.context3D.createTexture(skyBoxTexture.width, skyBoxTexture.height, Context3DTextureFormat.BGRA, true);
			texture1.uploadFromBitmapData(skyBoxTexture, 0);
			BitmapTextureResource.createMips(texture1, skyBoxTexture);
			d1.data = texture1;
			var material:StandardMaterial = new StandardMaterial(d, d1);
			material.specularPower = 0;
			object.setMaterialToAllSurfaces(material);
			object.scaleX = 1000;
			object.scaleY = 1000;
			object.scaleZ = 1000;
			object.geometry.calculateNormals();
			object.calculateBoundBox();
			scene.addChild(object);
			shadow.addCaster(object);
			inu();
		}*/
		
		public function initScene():void {
			var c:Config = new Config();
			c.addEventListener(Event.COMPLETE,inu);
			c.load("pesok");
			/*var parser:ParserA3D = new ParserA3D();
			parser.parse(new Model());
			var object:Mesh;
			for each(var obt:* in parser.objects)
			{
				if (obt is Mesh)
				{
					object = Mesh(obt);
					object.scaleX = 1000;
					object.scaleY = 1000;
					object.scaleZ = 1000;
					object.geometry.upload(stage3D.context3D);
					object.geometry.calculateNormals();
					object.geometry.calculateTangents(0);
					object.calculateBoundBox();
					scene.addChild(object);
					shadow.addCaster(object);
				}
			}
			var materialProcessor:MaterialProcessor = new MaterialProcessor(stage3D.context3D);
			//process and initialize materials
			materialProcessor.setupMaterials(parser.objects);

			//get map of "texture url->texture data"
			var textureURLMap:Object = createTextureURLMap();
			//apply external textures
			for each (var textureResource:ExternalTextureResource in scene.getResources(true, ExternalTextureResource)) {
				//get texture name
				var textureName:String = getShortTextureName(textureResource.url).toLocaleLowerCase();
				materialProcessor.setupExternalTexture(textureResource, textureURLMap[textureName]);
			}*/
			//inu();
		}
		
		private function getShortTextureName(name:String):String {
			var shortName:String = name.split("/").pop();
			shortName = shortName.split("\\").pop();
			return shortName;
		}
		
		private function creText(name:String):StandardMaterial {
			/*var skyBoxTexture1:BitmapData = new BitmapData(256, 256);
			var d:ExternalTextureResource = new ExternalTextureResource("");
			var texture:Texture = stage3D.context3D.createTexture(skyBoxTexture1.width, skyBoxTexture1.height, Context3DTextureFormat.BGRA, true);
			texture.uploadFromBitmapData(skyBoxTexture1, 0);
			BitmapTextureResource.createMips(texture, skyBoxTexture1);
			d.data = texture;
			var skyBoxTexture:BitmapData = new BitmapData(1, 1, false, 0x7F7FFF);
			var d1:ExternalTextureResource = new ExternalTextureResource("");
			var texture1:Texture = stage3D.context3D.createTexture(skyBoxTexture.width, skyBoxTexture.height, Context3DTextureFormat.BGRA, true);
			texture1.uploadFromBitmapData(skyBoxTexture, 0);
			BitmapTextureResource.createMips(texture1, skyBoxTexture);
			d1.data = texture1;*/
			var material:StandardMaterial = new StandardMaterial();
			material.specularPower = 0;
			return material;
		}
		
		public function iniSky(e:Event):void {
			 var skyBoxTexture:BitmapData = (loader.content as Bitmap).bitmapData;
			 var SKYBOX_SIZE:int = 200000;
			 var skyBox:SkyBox = new SkyBox(SKYBOX_SIZE,null,null,null,null,null,null,0.001);
			 var sides:Array = [SkyBox.RIGHT,SkyBox.BACK,SkyBox.LEFT,SkyBox.FRONT,SkyBox.TOP,SkyBox.BOTTOM];
			 for(var i:int = 0; i < sides.length; i++)
			 {
				var skyBoxTexture1:BitmapData = new BitmapData(1024, 1024);
				var re:Rectangle = skyBoxTexture.rect;
				re.x = i*1024;
				skyBoxTexture1.copyPixels(skyBoxTexture,re,new Point(0,0));
				var t:BitmapTextureResource = new BitmapTextureResource(skyBoxTexture1);
				t.upload(Main.stage3D.context3D);
				var material:TextureMaterial = new TextureMaterial(t);
				skyBox.getSide(sides[i]).material = material;
			 }
			 skyBox.geometry.upload(stage3D.context3D);
			 skyBox.useShadow = false;
			 scene.addChild(skyBox);
			 stage.addEventListener(Event.ENTER_FRAME, on);
			 stage.addEventListener(Event.RESIZE, onResize);
		}

		public function on(e:Event):void {
			controller.update();
			shadow.centerX = mainCamera.x;
			shadow.centerY = mainCamera.y;
			mainCamera.render(stage3D);
		}

		public function onResize(event:Event = null):void {
			mainCamera.view.width = stage.stageWidth;
			mainCamera.view.height = stage.stageHeight;
			mainCamera.render(stage3D);
		}

		public function onKeyDown(event:KeyboardEvent):void {
			switch (event.keyCode) {
				case Keyboard.Q:
					mainCamera.view.antiAlias = (mainCamera.view.antiAlias == 0) ? 4 : 0;
					if (mainCamera.view.antiAlias == 0) {
						// low
						//mainCamera.ssaoScale = 1;
					} else {
						//mainCamera.ssaoScale = 0;
					}
					break;
				case Keyboard.EQUAL:
				case Keyboard.NUMPAD_ADD:
					//mainCamera.ssaoAngular.intensity += (event.shiftKey) ? 0.01 : 0.05;
					break;
				case Keyboard.MINUS:
				case Keyboard.NUMPAD_SUBTRACT:
					//mainCamera.ssaoAngular.intensity -= (event.shiftKey) ? 0.01 : 0.05;
					//mainCamera.ssaoAngular.intensity = mainCamera.ssaoAngular.intensity <= 0 ? 0 : mainCamera.ssaoAngular.intensity;
					break;
				case Keyboard.U:
					//mainCamera.effectMode = mainCamera.effectMode == Camera3D.MODE_COLOR ? Camera3D.MODE_SSAO_COLOR : Camera3D.MODE_COLOR;
					break;
				case Keyboard.I:
					dirLight.shadow = (dirLight.shadow == shadow) ? null : shadow;
					break;
				case Keyboard.B:
					//mainCamera.blurEnabled = !mainCamera.blurEnabled;
					break;
			}
		}

		public function onKeyUp(event:KeyboardEvent):void {
		}

	}
}
