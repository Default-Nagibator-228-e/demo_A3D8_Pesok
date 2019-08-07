/**
 * This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0. If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
 * If it is not possible or desirable to put the notice in a particular file, then You may include the notice in a location (such as a LICENSE file in a relevant directory) where a recipient would be likely to look for such a notice.
 * You may add additional accurate notices of copyright ownership.
 *
 * It is desirable to notify that Covered Software was "Powered by AlternativaPlatform" with link to http://www.alternativaplatform.com/ 
 * */

package alternativa.engine3d.objects {

	import alternativa.engine3d.alternativa3d;
	import alternativa.engine3d.core.Object3D;
	import alternativa.engine3d.materials.Material;
	import alternativa.engine3d.materials.StandardMaterial;
	import alternativa.engine3d.materials.VertexLightTextureMaterial;
	import alternativa.engine3d.resources.BitmapTextureResource;
	import flash.display.BitmapData;
	import flash.events.Event;

	use namespace alternativa3d;

	/**
	 * Surface is a set of triangles within <code>Mesh</code> object or  instance of kindred class like <code>Skin</code>.
	 * Surface is a entity associated with one material, so different surfaces within one mesh can have different materials.
	 */
	public class Surface {

		/**
		 * Material.
		 */
		private var mat:Material;
		
		private var vmaterial:VertexLightTextureMaterial;
		
		private var smaterial:StandardMaterial;
		
		private var nt:BitmapTextureResource = new BitmapTextureResource(new BitmapData(1, 1, false, 0x7F7FFF));
		
		private var st:BitmapTextureResource = new BitmapTextureResource(new BitmapData(1, 1, false, 0xFFA64D));

		/**
		 * Index of the vertex with which surface starts within index buffer of object's geometry.
		 * @see alternativa.engine3d.resources.Geometry#indices
		 */
		public var indexBegin:int = 0;

		/**
		 * Number of triangles which form this surface.
		 */
		public var numTriangles:int = 0;

		/**
		 * @private 
		 */
		public var object:Object3D;
		
		private var sh:Boolean = false;
		
		private var show:Boolean = false;
		
		public function Surface() {
			nt.upload(Main.stage3D.context3D);
			st.upload(Main.stage3D.context3D);
		}
		
		public function set material(m:Material):void {
			mat = m;
			if (m is VertexLightTextureMaterial)
			{
				sh = true;
				vmaterial = VertexLightTextureMaterial(m);
				smaterial = new StandardMaterial(VertexLightTextureMaterial(m).diffuseMap, nt, st);
				smaterial.specularPower = 0.07;
				smaterial.alphaThreshold = VertexLightTextureMaterial(m).alphaThreshold;
			}
		}
		
		private function tr(e:Event) {
			show = true;
		}
		
		private function fa(e:Event) {
			show = false;
		}
		
		public function get material():Material {
			if (sh)
			{
				return show?smaterial:vmaterial;
			}else{
				return mat;
			}
			return null;
		}

		/**
		 * Returns a copy of this surface.
		 * @return A copy of this surface.
		 */
		public function clone():Surface {
			var res:Surface = new Surface();
			res.object = object;
			res.material = material;
			res.indexBegin = indexBegin;
			res.numTriangles = numTriangles;
			return res;
		}

	}
}
