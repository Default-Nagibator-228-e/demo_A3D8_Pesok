package alternativa.proplib.objects
{
   import alternativa.engine3d.alternativa3d;
   import alternativa.engine3d.core.Object3D;
   import alternativa.engine3d.core.Resource;
   import alternativa.engine3d.loaders.Parser3DS;
   import alternativa.engine3d.loaders.ParserA3D;
   import alternativa.engine3d.loaders.ParserMaterial;
   import alternativa.engine3d.materials.StandardMaterial;
   import alternativa.engine3d.materials.TextureMaterial;
   import alternativa.engine3d.objects.Mesh;
   import alternativa.engine3d.objects.Surface;
   import alternativa.engine3d.resources.BitmapTextureResource;
   import alternativa.engine3d.resources.ExternalTextureResource;
   import alternativa.proplib.utils.TextureByteDataMap;
   import flash.display.BitmapData;
   import utils.ByteArrayMap;
   import utils.textureutils.TextureByteData;
   import flash.utils.ByteArray;
   
   use namespace alternativa3d;
   
   public class PropMesh extends PropObject
   {
      
      public static const DEFAULT_TEXTURE:String = "$$$_DEFAULT_TEXTURE_$$$";
      
      public static var threshold:Number = 0.01;
      
      public static var meshDistanceThreshold:Number = 0.001;
      
      public static var meshUvThreshold:Number = 0.001;
      
      public static var meshAngleThreshold:Number = 0.001;
      
      public static var meshConvexThreshold:Number = 0.01;
      
      public var textures:TextureByteDataMap;
	  
	  private var mesh1:Mesh;
	  
	  private static const DEFAULT_DIFFUSE:BitmapData = new BitmapData(1, 1, false, 0x888888);
      
      public function PropMesh(modelData:ByteArray, objectName:String, textureFiles:Object, files:ByteArrayMap, imageMap:TextureByteDataMap)
      {
         super(PropObjectType.MESH);
         this.parseModel(modelData, objectName, textureFiles, files, imageMap);
      }
      
      private function parseModel(modelData:ByteArray, objectName:String, textureFiles:Object, files:ByteArrayMap, imageMap:TextureByteDataMap) : void
      {
         var textureName:* = null;
         var textureFileName:String = null;
         var textureByteData:TextureByteData = null;
         var mesh:Mesh = this.processObjects(modelData,objectName);
         this.object = mesh;
         var defaultTextureFileName:String = this.getTextureFileName(mesh);
         if(defaultTextureFileName == null && textureFiles == null)
         {
            throw new Error("PropMesh: no textures found");
         }
         if(textureFiles == null)
         {
            textureFiles = {};
         }
         if(defaultTextureFileName != null)
         {
            textureFiles[PropMesh.DEFAULT_TEXTURE] = defaultTextureFileName;
         }
         this.textures = new TextureByteDataMap();
         for(textureName in textureFiles)
         {
            textureFileName = textureFiles[textureName];
            if(imageMap == null)
            {
               textureByteData = new TextureByteData(files.getValue(textureFileName),null);
            }
            else
            {
               textureByteData = imageMap.getValue(textureFileName);
            }
            this.textures.putValue(textureName,textureByteData);
         }
      }
      
      private function processObjects(modelData:ByteArray, objectName:String) : Mesh
      {
         modelData.position = 0;
         var parser:ParserA3D = new ParserA3D();
         parser.parse(modelData);
		 var object:Mesh;
		 for each(var obt:* in parser.objects)
		 {
			if (obt is Mesh)
			{
				object = Mesh(obt);
				object.scaleX = 1000;
				object.scaleY = 1000;
				object.scaleZ = 1000;
				object.geometry.upload(Main.stage3D.context3D);
				setMaterials(object);
				object.geometry.calculateNormals();
				object.geometry.calculateTangents(0);
				object.calculateBoundBox();
				Main.scene.addChild(object);
				Main.shadow.addCaster(object);
			}
		 }
         return object;
      }
	  
	  private function setMaterials(mesh:Mesh) : void
      {
			 for each(var surface:Surface in mesh._surfaces) {
				var materialTextures:Object;
				if (surface.material) {
					materialTextures = (surface.material as ParserMaterial).textures;
				} else {
					materialTextures = createDefaultMaterialTextures();
				}
				if (!materialTextures["diffuse"]) materialTextures["diffuse"] = new BitmapTextureResource(DEFAULT_DIFFUSE);
				surface.material = createStandardMaterial(materialTextures);
			 }
	  }
	  
	  private function createDefaultMaterialTextures():Object {
		var textures:Object = new Object();
		textures["diffuse"] = new BitmapTextureResource(DEFAULT_DIFFUSE);
		return textures;
	  }
	  
	  private function createStandardMaterial(materialTextures:Object):StandardMaterial {
		var b:BitmapData = new BitmapData(1, 1, false, 0x7F7FFF);
		var d:BitmapTextureResource = new BitmapTextureResource(b);
		d.upload(Main.stage3D.context3D);
		var b1:BitmapData = new BitmapData(1, 1, false, 0xFFA64D);
		var d1:BitmapTextureResource = new BitmapTextureResource(b1);
		d1.upload(Main.stage3D.context3D);
		var material:StandardMaterial = new StandardMaterial(materialTextures["diffuse"],d,d1);
		material.specularPower = 0.07;
		material.alphaThreshold = 0.55;
		material.transparentPass = false;
		material.opaquePass = true;
		return material;
	  }
      
      private function getTextureFileName(mesh:Mesh) : String
      {
		if (mesh != null) {
			try{
				return (mesh.getSurface(0).material.getResources()[0] as ExternalTextureResource).url;
			}catch (e:Error){}
		}
        return null;
      }
      
      override public function traceProp() : void
      {
         var textureName:* = null;
         var textureData:TextureByteData = null;
         super.traceProp();
         for(textureName in this.textures)
         {
            textureData = this.textures[textureName];
         }
      }
   }
}
