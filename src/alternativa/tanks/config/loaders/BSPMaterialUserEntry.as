package alternativa.tanks.config.loaders 
{
	
	import alternativa.proplib.objects.PropMesh;
	import utils.textureutils.TextureByteData;
	
	public class BSPMaterialUserEntry extends MaterialUserEntry
	{
		
		public var propMesh:PropMesh;
	   
	   function BSPMaterialUserEntry(propMesh:PropMesh)
	   {
		  super();
		  this.propMesh = propMesh;
	   }
		
	}

}