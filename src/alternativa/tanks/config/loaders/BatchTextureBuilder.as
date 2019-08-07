package alternativa.tanks.config.loaders 
{
	import alternativa.engine3d.core.Resource;
	import alternativa.engine3d.loaders.TexturesLoader;
	import alternativa.engine3d.materials.EnvironmentMaterial;
	import alternativa.engine3d.materials.StandardMaterial;
	import alternativa.engine3d.materials.TextureMaterial;
	import alternativa.engine3d.materials.VertexLightTextureMaterial;
	import alternativa.engine3d.resources.BitmapTextureResource;
	import alternativa.engine3d.resources.ExternalTextureResource;
	import alternativa.proplib.objects.PropMesh;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.BlendMode;
	import flash.display3D.Context3DTextureFormat;
	import flash.display3D.textures.Texture;
	import utils.textureutils.ITextureConstructorListener;
	import utils.textureutils.TextureByteData;
	import utils.textureutils.TextureConstructor;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import alternativa.engine3d.alternativa3d;
	
	use namespace alternativa3d;
	
	public class BatchTextureBuilder extends EventDispatcher implements ITextureConstructorListener
	{
   
	   private var maxBatchSize:int;
	   
	   private var batchSize:int;
	   
	   private var firstBatchIndex:int;
	   
	   private var batchCouner:int;
	   
	   private var totalCounter:int;
	   
	   private var factoral:int;
	   
	   private var entries:Vector.<MaterialUserEntry>;
	   	   
	   private var constructors:Vector.<IndexedTextureConstructor>;
	   
	   private var textmap:Object = new Object();
	   
	   function BatchTextureBuilder()
	   {
		  super();
	   }
	   
	   public function run(mipMapResolution:Number, maxBatchSize:int, bspEntries:Vector.<BSPMaterialUserEntry>, spriteEntries:Vector.<Sprite3DMaterialUserEntry>) : void
	   {
		  var bspEntry:BSPMaterialUserEntry = null;
		  var spriteEntry:Sprite3DMaterialUserEntry = null;
		  this.maxBatchSize = maxBatchSize;
		  this.constructors = new Vector.<IndexedTextureConstructor>();
		  this.entries = new Vector.<MaterialUserEntry>();
		  for each(bspEntry in bspEntries)
		  {
			 this.entries.push(bspEntry);
		  }
		  for each(spriteEntry in spriteEntries)
		  {
			 this.entries.push(spriteEntry);
		  }
		  this.totalCounter = 0;
		  this.firstBatchIndex = 0;
		  this.createBatch();
	   }
	   
	   public function onTextureReady(constructor:TextureConstructor,dsaa:Boolean,df:String) : void
	   {
		  var materialUser:IMaterialUser = null;
		  var textureConstructor:IndexedTextureConstructor = IndexedTextureConstructor(constructor);
		  var t:BitmapTextureResource = new BitmapTextureResource(textureConstructor.texture);
		  textmap[df + ".png"] = textureConstructor.texture;
		  this.totalCounter++;
		  this.batchCouner++;
		  if(this.totalCounter == factoral)
		  {
			 this.complete();
		  }
	   }
	   
	   private function createBatch() : void
	   {
		  var textureConstructor:IndexedTextureConstructor = null;
		  var textureData:TextureByteData = null;
		  this.batchCouner = 0;
		  for each(var m:MaterialUserEntry in this.entries)
		  {
			 var me:PropMesh = (m as BSPMaterialUserEntry).propMesh;
			 for each(var s:String in me.textures.keys)
			 {
				 this.constructors[factoral] = new IndexedTextureConstructor();
				 factoral++;
			 }
		  }
		  for each(var ma:MaterialUserEntry in this.entries)
		  {
			 var me1:PropMesh = (ma as BSPMaterialUserEntry).propMesh;
			 for(var i2:int = 0; i2 < me1.textures.keys.length; i2++)
			 {
				 textureConstructor = this.constructors[i2];
				 textureConstructor.index = i2;
				 textureData = me1.textures.getValue(me1.textures.keys[i2]);
				 textureConstructor.createTexture(textureData, this, false, me1.textures.keys[i2]);
			 }
		  }
	   }
	   
	   private function getShortTextureName(name:String):String {
			var shortName:String = name.split("/").pop();
			shortName = shortName.split("\\").pop();
			return shortName;
		}
	   
	   private function complete() : void
	   {
		  for(var i:int = 0; i < this.entries.length; i++)
		  {
			 var me:PropMesh = (this.entries[i] as BSPMaterialUserEntry).propMesh;
			 for each (var textureResource:ExternalTextureResource in me.object.getResources(true, ExternalTextureResource)) {
				var textureName:String = getShortTextureName(textureResource.url);
				var resourceData:BitmapData = textmap[textureName];
				var texture:Texture = Main.stage3D.context3D.createTexture(resourceData.width, resourceData.height, Context3DTextureFormat.BGRA, false);
				texture.uploadFromBitmapData(resourceData, 0);
				BitmapTextureResource.createMips(texture, resourceData);
				textureResource.data = texture;
			 }
		  }
		  this.constructors = null;
		  this.entries = null;
		  dispatchEvent(new Event(Event.COMPLETE));
	   }
		
	}

}