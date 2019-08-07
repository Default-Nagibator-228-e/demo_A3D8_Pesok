package alternativa.tanks.config
{
   import alternativa.proplib.PropLibRegistry;
   import utils.TaskSequence;
   import flash.events.Event;
   
   public class PropLibsLoader extends ResourceLoader
   {
       
      
      private var libRegistry:PropLibRegistry;
      
      private var sequence:TaskSequence;
	  
	  private var seq:String;
      
      public function PropLibsLoader(config:Config,s:String)
      {
         this.libRegistry = new PropLibRegistry();
		 seq = s;
         super("Props library loader",config);
      }
      
      override public function run() : void
      {
         this.sequence = new TaskSequence();
         this.sequence.addTask(new PropLibLoadingTask(seq,this.libRegistry,config));
         this.sequence.addEventListener(Event.COMPLETE,this.onProplobsLoadingComplete);
         this.sequence.run();
      }
      
      private function onProplobsLoadingComplete(e:Event) : void
      {
         this.sequence = null;
         config.propLibRegistry = this.libRegistry;
         completeTask();
      }
   }
}

import alternativa.proplib.PropLibRegistry;
import alternativa.proplib.PropLibrary;
import alternativa.tanks.config.Config;
import utils.ByteArrayMap;
import utils.TARAParser;
import utils.Task;
import flash.display.Loader;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.events.SecurityErrorEvent;
import flash.net.URLLoader;
import flash.net.URLLoaderDataFormat;
import flash.net.URLRequest;
import flash.system.ApplicationDomain;
import flash.system.LoaderContext;
import flash.system.Security;
import flash.utils.ByteArray;
import flash.utils.Dictionary;

class PropLibLoadingTask extends Task
{
    
   
   private var url:String;
   
   private var libRegistry:PropLibRegistry;
   
   private var m_loaderReferences:Dictionary = new Dictionary(); 
   
   private var loader:URLLoader = new URLLoader();
   
   private var loi:Config;
   
   function PropLibLoadingTask(url:String, libRegistry:PropLibRegistry,c:Config)
   {
      super();
      this.url = url;
	  loi = c;
      this.libRegistry = libRegistry;
   }
   
   override public function run() : void
   {
	  this.loader.dataFormat = URLLoaderDataFormat.BINARY;
      this.loader.addEventListener(Event.COMPLETE,this.onLoadingComplete);
      this.loader.load(new URLRequest(this.url));
   }
   
   private function onLoadingComplete(event:Event) : void
   {
      var propLibrary:PropLibrary = new PropLibrary(new ByteArrayMap(TARAParser.parse(this.loader.data)),loi);
      this.libRegistry.addLibrary(propLibrary);
      completeTask();
   }
}
