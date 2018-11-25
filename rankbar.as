﻿import flash.display.*;

var colbar: Array;
var cfg: Array;


var n: int; // 序号
var id: String; // mid
var cn: String; // 中文名
//var po: Number;
var rt: Number;
var col: Number;

var H: Number;

var format1: TextFormat;

var Icon: Sprite; // 头像容器

function initialize(ni: int, idi: String, cni: String, coli: Number, pofix: String, cfgi: Array): void {

	this.name = idi;
	float.alpha = 0;

	cfg = cfgi;

	rank1.x = cfg[22][0];
	rec.x = cfg[24][0];
	cname.x = cfg[25][0];
	H = cfg[26][0];
	rec.height = cfg[27][0];

	rt = cfg[28][0] / 2;

	format1 = new TextFormat();
	format1.color = cfg[2][1];
	format1.size = cfg[29][0];

	this.y = Number(cfg[30][0]);
	this.alpha = 0;

	n = ni;

	cn = cni;
	cname.text = cni;
	cname.setTextFormat(format1);

	Icon = new Sprite(); // 头像容器
	addChildAt(Icon, 2);

	id = clearDelimeters(idi);
	var icon: Loader = new Loader();
	icon.contentLoaderInfo.addEventListener(Event.COMPLETE, iconLoaded);
	icon.load(new URLRequest(id + pofix));


	col = coli;
	if(cfg[32][0] == "1") {
		include "colbar.as"; // 按增速变色
	} else {
		var newColorTransform: ColorTransform = rec.transform.colorTransform;
		newColorTransform.color = col;
		rec.transform.colorTransform = newColorTransform;
	}
}




function iconLoaded(e: Event): void {

if(id==cfg[110][0]){
  rt=rt*1.5;
  Icon.y-=13;
  var gua: Guajian = new Guajian();
  gua.width = 3 * rt;
  gua.height = 3 * rt;
  gua.x = Number(cfg[23][0]) - 1.5*rt;
  gua.y = Number(cfg[23][1]) - 0.5*rt;
  Icon.addChildAt(gua, 0);
}

	var image: Bitmap = new Bitmap(e.target.content.bitmapData);
	image.width = 2 * rt;
	image.height = 2 * rt;
	image.x = Number(cfg[23][0]) - rt;
	image.y = Number(cfg[23][1]);
	Icon.addChildAt(image, 0);

	if(cfg[31][0] == "1") {
		// Create the mask graphic
		var maskCircle: Sprite = new Sprite();
		maskCircle.graphics.beginFill(0x000000);
		maskCircle.graphics.drawEllipse(image.x, image.y, 2 * rt, 2 * rt);
		maskCircle.graphics.endFill();
		maskCircle.visible = false;
		Icon.addChild(maskCircle);

		image.mask = maskCircle; // Applies the mask
	}

}



var rank: int; // 要去往的排名
rank1.text = "";

var po: Number = 0;
var fan: Number = 0;
var fanlast: Number = 0;
var news: int = 60; // 最近有更新的话，给30帧高亮时间
var tarA: Number; // 最近有更新的目标alpha1，否则半透明


function update(poi: Number): void {

	po = poi;
	fan = po / cfg[36][0];

	if(fan - fanlast > Number(cfg[68][0])) {
		this.alpha = 1;
		news = cfg[69][0];
	} else if(news > Number(cfg[70][0])) {
		news--;
	}
	fanlast = fan;
	tarA = news / cfg[69][0];


	cvalue.text = cfg[38][0] + fan.toFixed(int(cfg[37][0])).toString() + cfg[39][0];
	cvalue.setTextFormat(format1);

	rank1.text = (rank + 1).toString(); //+ "."
	rank1.setTextFormat(format1);

	if(cfg[32][0] == "1") {
		var newColorTransform: ColorTransform = rec.transform.colorTransform;
		newColorTransform.color = colbar[colfun(poi)];
		rec.transform.colorTransform = newColorTransform;
	}
}



function clearDelimeters(formattedString: String): String {
	return formattedString.replace(/[\u000d\u000a\u0008\u0020]+/g, "");
}

// 位置和柱长都采用“固定比例赶往目标值”算法
var targ: Number;
function updatey(i: int, scale: Number): void {

	if(cfg[53][0] == "1") { // 对数轴
		targ = Math.log(1 + fan) * scale;
	} else {
		targ = fan * scale;
	}

	rec.width += (Math.abs(targ) - rec.width) / Number(cfg[8][0]);

	cvalue.x = rec.width + Number(cfg[41][0]);
	if(cvalue.x < Number(cfg[40][0])) {
		cvalue.x = Number(cfg[40][0]);
	}
	if(cvalue.x > Number(cfg[40][1])) {
		cvalue.x = Number(cfg[40][1]);
	}

	float.x = cvalue.x + Number(cfg[106][0]);

	if(cfg[31][1] == "R") {
		Icon.x = rec.x + rec.width;
	}
	if(cfg[25][1] == "R") {
		cname.x = rec.width - (cname.textWidth + 10) + Number(cfg[25][2]);
	}


	if(Math.abs(fan) >= Number(cfg[67][0])) {
		var dist = Math.abs(i * H - this.y);
		if(dist >= Number(cfg[10][0])) { // 变速
			this.y += (i * H - this.y) / Number(cfg[11][0]);
		} else if(dist >= Number(cfg[12][0])) { // 匀速
			if(this.y < i * H) {
				this.y += Number(cfg[11][0]);
			}
			if(this.y > i * H) {
				this.y -= Number(cfg[11][0]);
			}
		} else { // 直接抵达
			this.y = i * H;
		}

	} else {
		rank1.text = "";
		this.y += (Number(cfg[30][0]) - this.y) / Number(cfg[11][0]); // 往出生点消失
	}

	if(Math.abs(fan) <= Number(cfg[67][0]) || (this.alpha > tarA + 0.05)) {
		this.alpha -= 0.05;
	} else if(this.alpha < tarA - 0.05) {
		this.alpha += 0.05;
	}

}




var pstart: int; // 拥有用户的层号起点
var pnum: int; // 拥有用户数量



function colfun(speed: Number): int {
	if(speed <= 0) {
		return(0)
	}
	if(speed >= 50000) {
		return(100)
	}
	return(int(Math.pow(speed / 50000, 1 / 6) * 100))
}




function popf(cni: String, numi: Number, navi:String): void {
  ftimer=0;
  if(clearDelimeters(navi)==""){
      float.cn.text = clearDelimeters(cni);
    }else{
      float.cn.text = clearDelimeters("av"+navi+"-"+cni);
    }

  if(numi<=0.0001){
    float.floater2.visible=false;
    float.num.text ="";
  }
  else{
    float.floater2.visible=true;
    float.num.text = (numi/10000).toFixed(1).toString()+" 万";
  }

	float.alpha = 1;
	float.addEventListener(Event.ENTER_FRAME, fadeout);
}

var ftimer:int;
function fadeout(event: Event): void {

  if(rank>int(cfg[105][0])){float.visible=false}
  else{float.visible=true}

  ftimer++;

  if(ftimer<int(cfg[107][2])){
    if(ftimer>int(cfg[107][0])&&ftimer%int(cfg[107][1])==0){
      float.cn.text = float.cn.text.slice(1,999);
    }
  }else	if(event.target.alpha>0) {
		event.target.alpha -= Number(cfg[107][3])
	} else {
		event.target.alpha = 0;
    ftimer=0;
		event.target.removeEventListener(Event.ENTER_FRAME, fadeout);
	}
}
