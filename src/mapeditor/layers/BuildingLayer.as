/* 
Eb163 Flash RPG Webgame Framework
@author eb163.com
@email game@eb163.com
@website www.eb163.com
*/
package mapeditor.layers
{
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.text.TextField;
	
	import mapeditor.events.MapEvent;
	import mapeditor.items.Building;
	import mapeditor.items.NPC;
	import mapeditor.utils.MapEditorUtils;
	
	import mx.core.UIComponent;
	
	public class BuildingLayer extends UIComponent
	{
		//所有building数组，数组索引对应building id
		public var buildingArray:Array;	
		//建筑数量
		private var maxNum:int = 0;
		//npc数量
		private var maxNumNPC :int=0;
		//路点层
		private var _roadLayer:RoadPointLayer;
		// mapEdirtor引用
		private var _mapEditor :MapEditor;
		
		//获取建筑物清单
		public function BuildingLayer(roadLayer:RoadPointLayer)
		{
			_roadLayer    = roadLayer;
			buildingArray = new Array();
		}
		//放置建筑物
		public function placeAndCloneBuilding(bld:Building, tilePoint:Point):Building{
			placeSign(bld, tilePoint);
			placeBuilding(bld, tilePoint);
			return bld;
		}
		
		//放置建筑物图片
		public function placeBuilding(bld:Building, tilePoint:Point):Building
		{
			//获取建筑物的XML信息
			var blXml:XML = bld.configXml.copy();
			//			if(blXml.@type == "building")
			//			{
			var nbld:Building = new Building(this.maxNum);
			nbld.x = bld.x;
			nbld.y = bld.y;
			if(bld._bitMap != null){
				var blBitMap:BitmapData = bld._bitMap.bitmapData.clone();
				nbld.reset(blBitMap,blXml);
				trace("nbld.reset(blBitMap,blXml);");
			}
			else{
				nbld.configXml = blXml;
				nbld.loadImage();
			}
			nbld.configXml.@id = maxNum;
			nbld.configXml.@px = nbld.x;
			nbld.configXml.@py = nbld.y;
			nbld.configXml.@ix = tilePoint.x;
			nbld.configXml.@iy = tilePoint.y;
			
			this.buildingArray[maxNum] = nbld;
			nbld = Building(this.addChild(nbld));
			this.maxNum++;
			trace("nbld.configXml.@id",nbld.configXml.@id);
			//			}
			return nbld;
		}
		
		//放置障碍物障碍点
		private function placeSign(bld:Building, tilePoint:Point):void
		{
			//获取单元格的宽，高
			var tilePixelWidth:int = this.parentApplication._cellWidth;
			var tilePixelHeight:int = this.parentApplication._cellHeight;
			
			//阻挡和阴影标记
			var pt:Point = MapEditorUtils.getPixelPoint(tilePixelWidth, tilePixelHeight, tilePoint.x, tilePoint.y);
			//获得建筑物障碍点信息的字符串
			var walkableStr:String = bld.configXml.walkable;
			//把XML里的障碍点信息转化为数组
			var wa:Array = walkableStr.split(",");
			//没有阻挡设置
			if (walkableStr != null && walkableStr.length >= 3)
			{
				
				// building的元点在地图坐标系中的tile坐标
				var pxt:int = pt.x - int(wa[0]) - tilePixelWidth/2;
				var pyt:int = pt.y - int(wa[1]) - tilePixelHeight/2;
				_roadLayer.drawWalkableBuilding(bld, pxt, pyt, false);
			}
			
		}
		
		//移除建筑
		public function removeBuild(bld:Building):void{
			//获取单元格的宽，高
			var tilePixelWidth:int  = this.parentApplication._cellWidth;
			var tilePixelHeight:int = this.parentApplication._cellHeight;
			//获取当前建筑物网格的行列坐标
			var offsetCt:Point = MapEditorUtils.getCellPoint(tilePixelWidth, tilePixelHeight, bld.configXml.@xoffset, bld.configXml.@yoffset);
			//获取当前建筑物网格的象素坐标
			var offsetPt:Point = MapEditorUtils.getPixelPoint(tilePixelWidth, tilePixelHeight, offsetCt.x, offsetCt.y);
			//获得建筑物障碍点信息的字符串
			var walkableStr:String = bld.configXml.walkable;
			//把XML里的障碍点信息转化为数组
			var wa:Array = walkableStr.split(",");
			//获取建筑物的原点
			var originPX:int = bld.x - offsetPt.x;
			var originPY:int = bld.y - offsetPt.y;
			//移除建筑的障碍点
			_roadLayer.drawWalkableBuilding(bld, originPX, originPY, true);
			//移除建筑物
			delete buildingArray[bld.id];
			removeChild(bld);
		}
		
		//读取XML配置 放置建筑，再次读取时执行
		public function drawByXml(mapXml:XML, reset:Boolean = false):void{
			for each(var item:XML in mapXml.items.item){
				
				var bl:Building     = new Building();
				var cellPoint:Point = new Point(item.@ix,item.@iy);
				bl.configXml        = item;
				bl.x                = item.@px;
				bl.y                = item.@py;
				trace("for each(var item:XML in mapXml.items.item){");
				placeAndCloneBuilding(bl, cellPoint);
				
			}
			for each(var area:XML in mapXml.areas.area){
				
				var npcB :NPC = new NPC();
				npcB.configXml =area;
				npcB.x =area.@areaX;
				npcB.y =area.@areaY;
				
//				trace(npcB.x,"npc.configXml");
				
				placeAndCloneNPC(npcB);
				
			}
		}
		
		private function placeAndCloneNPC(npcB:NPC):NPC
		{
			placeSignNPC(npcB);
			//			placeBuildingNPC(npc);
			return npcB;
		}		
		
		//		private function placeBuildingNPC(npc:NPC):NPC
		//		{
		//			var blXml:XML = npc.configXml.copy();
		//		
		//			var nbld:NPC = new NPC(this.maxNumNPC);
		////			nbld.x = npc.x;
		////			nbld.y = npc.y;
		////			if(npc._bitMap != null){
		////				var blBitMap:BitmapData = npc._bitMap.bitmapData.clone();
		////				nbld.reset(blBitMap,blXml);
		////				trace("nbld.reset(blBitMap,blXml);");
		////			}
		////			else{
		//				nbld.configXml = blXml;
		////				nbld.loadImage();
		////			}
		////			nbld.configXml.@id = maxNumNPC;
		////			nbld.configXml.@id = npc.id;
		////			nbld.configXml.@type = npc.type;
		////			nbld.configXml.@ix = tilePoint.x;
		////			nbld.configXml.@iy = tilePoint.y;
		//			
		////			this.buildingArray[maxNum] = nbld;
		//			nbld = NPC(this.addChild(nbld));
		//			this.maxNumNPC++;
		//			trace("npc.configXml..@id",nbld.configXml.@id);
		//		
		////			MapEvent.datas.push(
		//			return nbld;
		//		}
		
		private function placeSignNPC(npcA:NPC):void
		{
			
			
			var areaOb :Object = new Object();
			var arr:Array=new Array();
			areaOb.areaName = npcA.configXml.@areaName;
			areaOb.areaType = npcA.configXml.@areaType;
			areaOb.areaX  = npcA.configXml.@areaX;
			areaOb.areaY = npcA.configXml.@areaY;
			areaOb.areaID = npcA.configXml.@areaID;
			var text :TextField=new TextField();
			text.text="刷怪地图:  " + npcA.configXml.@areaName;
			text.x =npcA.configXml.@areaX;
			text.y =npcA.configXml.@areaY;
			text.autoSize = "left";
			text.textColor =0xFF0033;
			text.name = npcA.configXml.@areaName;
			_roadLayer.addChild(text);
			_roadLayer.texts.push(text);
			for each (var npc:XML in npcA.configXml.npc) 
			{
			var npcOb :Object = new Object();
//			var npcXml :XML =  npc.configXml.npc[0];
//			npcOb.configXml=npc;
			npcOb.npcID = npc.@npcID;
			npcOb.npcNum = npc.@npcNum;	
			var i :int;
			var ob :Object = _mapEditor.npcConfigs[0];
			while( npcOb.npcID != ob.npcId)
			{
				i++;
				ob = _mapEditor.npcConfigs[i];
			}
			i = 0;
			text.text +="\n npcID:  "+ npc.@npcID +"\n npc数量:  " + npc.@npcNum+"\n npc姓名:"+ob.npcName;
			arr.push(npcOb);
			}
			if(npcA.configXml.@areaType == "circle")
			{
				var cicleShape:Sprite = new Sprite();
				cicleShape.graphics.lineStyle(3, 0xFFFF00);
				cicleShape.graphics.drawCircle(0,0,npcA.configXml.@areaRadius);
				cicleShape.name =npcA.configXml.@areaName;
				_roadLayer.addChild(cicleShape);
				cicleShape.x = npcA.configXml.@areaX;
				cicleShape.y = npcA.configXml.@areaY;
				trace("cicleShape",cicleShape.x,cicleShape.y);
				_roadLayer.shapes.push(cicleShape);
				
				areaOb.areaRadius = npcA.configXml.@areaRadius;
				MapEvent.npcDatas.push(arr);
				MapEvent.datas.push(areaOb);
				
			}else if(npcA.configXml.@areaType == "rectangle"){
				var rectangleShape:Sprite = new Sprite();
				rectangleShape.graphics.lineStyle(3, 0xFFFF00);
				rectangleShape.graphics.drawRect(0,0,npcA.configXml.@areaWidth,npcA.configXml.@areaHeight);
				rectangleShape.x = npcA.configXml.@areaX;
				rectangleShape.y = npcA.configXml.@areaY;
				rectangleShape.name =npcA.configXml.@areaName;
				_roadLayer.addChild(rectangleShape);
				_roadLayer.shapes.push(rectangleShape);
				
				
				
				areaOb.areaWidth = npcA.configXml.@areaWidth;
				areaOb.areaHeight = npcA.configXml.@areaHeight;
				MapEvent.npcDatas.push(arr);
				MapEvent.datas.push(areaOb);
			}
			MapEvent.dispatcher.addEventListener(MapEvent.CANCEL_EVENT, _roadLayer.cancelCicle);
			MapEvent.dispatcher.addEventListener(MapEvent.MENU_CANCEL_SELECT, _roadLayer.menuCancel);
		}		

	   // ------------读存器
		public function set mapEditor(value:MapEditor):void
		{
			_mapEditor = value;
		}

		
	}
}