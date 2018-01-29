var ftsz = parseFloat(document.documentElement.style.fontSize) 
function jisuan(a){
	var z=a
	console.log(z/ftsz)
}
var atm =0;  //判断是温度测量值还是倒计时

/*private Integer id;								// 主键
	private Integer devId;							// 设备ID
	private Boolean warmSwitch;						// 加热开关
	private Long startTime = 0L;					// 启动时间
	
	private String fWarmSwitch;						// 加热开关
	private String fFanSwitch;						// 风扇开关
	private String fTempSetting;					// 温度设定值
	private String sTempReading;					// 温度测量值
	private String fCountdownSetting;				// 倒计时设定值，0表示连续运行（毫秒）
	private String sCountdownReading;				// 倒计时运行值（毫秒）
	private String fAlarmHigh;						// 超温报警上限
	private String fAlarmLow;						// 超温报警下限
	private String fAlarmDeviation;					// 超温报警偏差值
	private String fP1;								// 一共8个
	private String fI1;								// 一共8个
	private String fD1;								// 一共8个
	private String fP2;								// 一共8个
	private String fI2;								// 一共8个
	private String fD2;								// 一共8个
	private String fP3;								// 一共8个
	private String fI3;								// 一共8个
	private String fD3;								// 一共8个
	private String fP4;								// 一共8个
	private String fI4;								// 一共8个
	private String fD4;								// 一共8个
	private String fP5;								// 一共8个
	private String fI5;								// 一共8个
	private String fD5;								// 一共8个
	private String fP6;								// 一共8个
	private String fI6;								// 一共8个
	private String fD6;								// 一共8个
	private String fP7;								// 一共8个
	private String fI7;								// 一共8个
	private String fD7;								// 一共8个
	private String fP8;								// 一共8个
	private String fI8;								// 一共8个
	private String fD8;								// 一共8个
	private String fZeroScaleCorrection;			// 测量值零点修正
	private String fFullScaleCorrection;			// 测量值满度修正*/

function cloneObj(obj){
	var str, newobj = obj.constructor === Array ? [] : {};
		if(typeof obj !== 'object'){
			return;
		} else if(window.JSON){
			str = JSON.stringify(obj), //序列化对象
			newobj = JSON.parse(str); //还原
		} else {
			for(var i in obj){
				newobj[i] = typeof obj[i] === 'object' ? cloneObj(obj[i]) : obj[i]; 
			}
		}
	return newobj;
};


var getDevicePixelRatio = function (){  
    return window.devicePixelRatio || 1;  
}
var pixelTatio = getDevicePixelRatio();
//机器状态
var MCstate = {
  /*BrandName: "TCL塔扇",
  fSwitch: 1,
  fMode:2,
  fWind:1,
  fSwing:1,
  durTime:[],
  sTemp:[],
  sFault:[],
  b :[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
  breset :[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]*/
};

//获取机器类型等数据
var userSn = "",
	devTypeSn = "",
	devSn = "",
	UserDeviceID = "",
	ServieceIP = "",
	BrandName = "",
	identity = "";

	b = [0,0,0,0,0,0,0,0],
	breset = [0,0,0,0,0,0,0,0];

function test(bd){
	/*var d=[0,0,0,0,0,0,0,0,0,0,0,0,0,0]*/
	ReceiveOrder(bd)
}
function ReceiveOrder(bd){
	var bdd = bd;
	if(typeof bd == "string"){
		bdd = bd.split(",");
	}
	if(ISIOS){
		bdd[0] = parseInt(bdd[0],16)
		bdd[1] = parseInt(bdd[1],16)
		bdd[2] = parseInt(bdd[2],16)
		bdd[3] = parseInt(bdd[3],16)
		bdd[4] = parseInt(bdd[4],16)
		bdd[5] = parseInt(bdd[5],16)
	}else{
		bdd=[]
		for(i in bd){
			bdd[i]=bd[i]
		}
		bdd[0] = bdd[0]>=0?bdd[0]:bdd[0]+256
		bdd[1] = bdd[1]>=0?bdd[1]:bdd[1]+256
		bdd[2] = bdd[2]>=0?bdd[2]:bdd[2]+256
		bdd[3] = bdd[3]>=0?bdd[3]:bdd[3]+256
		bdd[4] = bdd[4]>=0?bdd[4]:bdd[4]+256
		bdd[5] = bdd[5]>=0?bdd[5]:bdd[5]+256
	}
	if(bdd.length>=8){
		switch (bdd[3])
		{
			case 0:
			  /*MCstate.sTempReading = bdd*/
			  /*MCstate.sTempReading.splice(4,1,bdd[4])
	          MCstate.sTempReading.splice(5,1,bdd[5])*/
			  break;
			case 1:
			  /*MCstate.fTempSetting = bdd*/
			  MCstate.fTempSetting.splice(4,1,bdd[4])
	          MCstate.fTempSetting.splice(5,1,bdd[5])
			  console.log(bdd)
			  break;
			case 2:
			  MCstate.fCountdownSetting.splice(4,1,bdd[4])
	          MCstate.fCountdownSetting.splice(5,1,bdd[5])
			  break;
			case 3:
			  /*MCstate.sCountdownSetting.splice(4,1,bdd[4])
	          MCstate.sCountdownSetting.splice(5,1,bdd[5])*/
			  break;
			case 4:
			  MCstate.fZeroScaleCorrection.splice(4,1,bdd[4])
	          MCstate.fZeroScaleCorrection.splice(5,1,bdd[5])
			  break;
			case 5:
			  MCstate.fFullScaleCorrection.splice(4,1,bdd[4])
	          MCstate.fFullScaleCorrection.splice(5,1,bdd[5])
			  break;
			case 6:
			  //输出比较模式
			  MCstate.fAlarmDeviation.splice(4,1,bdd[4])
	          MCstate.fAlarmDeviation.splice(5,1,bdd[5])
			  break;
			case 7:
			  //输出上限值
			  MCstate.fAlarmHigh.splice(4,1,bdd[4])
	          MCstate.fAlarmHigh.splice(5,1,bdd[5])
			  break;
			case 8:
			  //输出下限值
			  MCstate.fAlarmLow.splice(4,1,bdd[4])
	          MCstate.fAlarmLow.splice(5,1,bdd[5])
			  break;
			case 9:
			  //输出动作模式
			  break;
			case 10:
			  //输出动作延时
			  break;
			case 11:
			  //输出通断反转
			  break;
			case 12:
			  MCstate.pid1.p.splice(4,1,bdd[4])
	          MCstate.pid1.p.splice(5,1,bdd[5])
			  break;
			case 13:
			  MCstate.pid1.i.splice(4,1,bdd[4])
	          MCstate.pid1.i.splice(5,1,bdd[5])
			  break;
			case 14:
			  MCstate.pid1.d.splice(4,1,bdd[4])
	          MCstate.pid1.d.splice(5,1,bdd[5])
			  break;
			case 15:
			  MCstate.pid2.p.splice(4,1,bdd[4])
	          MCstate.pid2.p.splice(5,1,bdd[5])
			  break;
			case 16:
			  MCstate.pid2.i.splice(4,1,bdd[4])
	          MCstate.pid2.i.splice(5,1,bdd[5])
			  break;
			case 17:
			  MCstate.pid2.d.splice(4,1,bdd[4])
	          MCstate.pid2.d.splice(5,1,bdd[5])
			  break;
			case 18:
			  MCstate.pid3.p.splice(4,1,bdd[4])
	          MCstate.pid3.p.splice(5,1,bdd[5])
			  break;
			case 19:
			  MCstate.pid3.i.splice(4,1,bdd[4])
	          MCstate.pid3.i.splice(5,1,bdd[5])
			  break;
			case 20:
			  MCstate.pid3.d.splice(4,1,bdd[4])
	          MCstate.pid3.d.splice(5,1,bdd[5])
			  break;
			case 21:
			  MCstate.pid4.p.splice(4,1,bdd[4])
	          MCstate.pid4.p.splice(5,1,bdd[5])
			  break;
			case 22:
			  MCstate.pid4.i.splice(4,1,bdd[4])
	          MCstate.pid4.i.splice(5,1,bdd[5])
			  break;
			case 23:
			  MCstate.pid4.d.splice(4,1,bdd[4])
	          MCstate.pid4.d.splice(5,1,bdd[5])
			  break;
			case 24:
			  MCstate.pid5.p.splice(4,1,bdd[4])
	          MCstate.pid5.p.splice(5,1,bdd[5])
			  break;
			case 25:
			  MCstate.pid5.i.splice(4,1,bdd[4])
	          MCstate.pid5.i.splice(5,1,bdd[5])
			  break;
			case 26:
			  MCstate.pid5.d.splice(4,1,bdd[4])
	          MCstate.pid5.d.splice(5,1,bdd[5])
			  break;
			case 27:
			  MCstate.pid6.p.splice(4,1,bdd[4])
	          MCstate.pid6.p.splice(5,1,bdd[5])
			  break;
			case 28:
			  MCstate.pid6.i.splice(4,1,bdd[4])
	          MCstate.pid6.i.splice(5,1,bdd[5])
			  break;
			case 29:
			  MCstate.pid6.d.splice(4,1,bdd[4])
	          MCstate.pid6.d.splice(5,1,bdd[5])
			  break;
			case 30:
			  MCstate.pid7.p.splice(4,1,bdd[4])
	          MCstate.pid7.p.splice(5,1,bdd[5])
			  break;
			case 31:
			  MCstate.pid7.i.splice(4,1,bdd[4])
	          MCstate.pid7.i.splice(5,1,bdd[5])
			  break;
			case 32:
			  MCstate.pid7.d.splice(4,1,bdd[4])
	          MCstate.pid7.d.splice(5,1,bdd[5])
			  break;
			case 33:
			  MCstate.pid8.p.splice(4,1,bdd[4])
	          MCstate.pid8.p.splice(5,1,bdd[5])
			  break;
			case 34:
			  MCstate.pid8.i.splice(4,1,bdd[4])
	          MCstate.pid8.i.splice(5,1,bdd[5])
			  break;
			case 35:
			  MCstate.pid8.d.splice(4,1,bdd[4])
	          MCstate.pid8.d.splice(5,1,bdd[5])
			  break;
			case 36:
			  MCstate.fWarmSwitch.splice(4,1,bdd[4])
	          MCstate.fWarmSwitch.splice(5,1,bdd[5])
			  break;
			case 37:
			  MCstate.fFanSwitch.splice(4,1,bdd[4])
	          MCstate.fFanSwitch.splice(5,1,bdd[5])
			  break;
		}
	}else{
		if(atm==1){
			MCstate.sTempReading.splice(3,1,bdd[3])
	        MCstate.sTempReading.splice(4,1,bdd[4])
		}else if(atm==2){
			MCstate.sCountdownSetting.splice(3,1,bdd[3])
	        MCstate.sCountdownSetting.splice(4,1,bdd[4])
		}
	}
	
	console.log(MCstate)
}
function GetUserData(a){
	if(typeof a == "string"){
		a = eval('('+a+')')
	}
	MCstate.userSn = a.userSn;
	MCstate.devTypeSn = a.devTypeSn;
	MCstate.devSn = a.devSn;
	MCstate.UserDeviceID = a.UserDeviceID;
	MCstate.ServieceIP = a.ServieceIP;
	MCstate.BrandName = a.BrandName;
	MCstate.devTypeNumber = a.devTypeNumber



	$.ajax({
	
		type: "POST",
	
		url: MCstate.ServieceIP + "smarthome/washer/queryDeviceState",
	
		data: {
			'devTypeSn': MCstate.devTypeSn,
			'devSn': MCstate.devSn
		},
	
		dataType: "json",
	
		success: function(data){
			var data = data.data
			if(data){

				for(var i in data){
					if(i=='sTempReading' || i=='sCountdownReading'){
						MCstate[i].splice(3,1,parseInt(data[i][3],16))
						MCstate[i].splice(4,1,parseInt(data[i][4],16))
					}else{
						MCstate[i].splice(4,1,parseInt(data[i][4],16))
						MCstate[i].splice(5,1,parseInt(data[i][5],16))
					}
				}
				
			}
		},
		error: function(){
			MCstate.identity = a.identity;
		}	
	})

	$.ajax({
        type: "POST",
        url: MCstate.ServieceIP +"smarthome/auth/queryAuthMenu",
        data: {
            'userSn': MCstate.userSn,
            'devTypeNumber': MCstate.devTypeNumber,
        },
        dataType: "json",
        success: function(data) {
            if(ISIOS){
                ShowRemind(JSON.stringify(data));
            }else{
                js.ShowRemind(JSON.stringify(data));
            }
            MCstate.authlist = data
        },
        error: function() {

        }
    })

	/*$('.app_top_tit').html(a.devTypeNumber)*/
}


	var CRC16HighForModbus = [
		0x00, 0xC0, 0xC1, 0x01, 0xC3, 0x03, 0x02, 0xC2, 0xC6, 0x06,   
		0x07, 0xC7, 0x05, 0xC5, 0xC4, 0x04, 0xCC, 0x0C, 0x0D, 0xCD,   
		0x0F, 0xCF, 0xCE, 0x0E, 0x0A, 0xCA, 0xCB, 0x0B, 0xC9, 0x09,   
		0x08, 0xC8, 0xD8, 0x18, 0x19, 0xD9, 0x1B, 0xDB, 0xDA, 0x1A,   
		0x1E, 0xDE, 0xDF, 0x1F, 0xDD, 0x1D, 0x1C, 0xDC, 0x14, 0xD4,   
		0xD5, 0x15, 0xD7, 0x17, 0x16, 0xD6, 0xD2, 0x12, 0x13, 0xD3,   
		0x11, 0xD1, 0xD0, 0x10, 0xF0, 0x30, 0x31, 0xF1, 0x33, 0xF3,   
		0xF2, 0x32, 0x36, 0xF6, 0xF7, 0x37, 0xF5, 0x35, 0x34, 0xF4,   
		0x3C, 0xFC, 0xFD, 0x3D, 0xFF, 0x3F, 0x3E, 0xFE, 0xFA, 0x3A,   
		0x3B, 0xFB, 0x39, 0xF9, 0xF8, 0x38, 0x28, 0xE8, 0xE9, 0x29,   
		0xEB, 0x2B, 0x2A, 0xEA, 0xEE, 0x2E, 0x2F, 0xEF, 0x2D, 0xED,   
		0xEC, 0x2C, 0xE4, 0x24, 0x25, 0xE5, 0x27, 0xE7, 0xE6, 0x26,   
		0x22, 0xE2, 0xE3, 0x23, 0xE1, 0x21, 0x20, 0xE0, 0xA0, 0x60,   
		0x61, 0xA1, 0x63, 0xA3, 0xA2, 0x62, 0x66, 0xA6, 0xA7, 0x67,   
		0xA5, 0x65, 0x64, 0xA4, 0x6C, 0xAC, 0xAD, 0x6D, 0xAF, 0x6F,   
		0x6E, 0xAE, 0xAA, 0x6A, 0x6B, 0xAB, 0x69, 0xA9, 0xA8, 0x68,   
		0x78, 0xB8, 0xB9, 0x79, 0xBB, 0x7B, 0x7A, 0xBA, 0xBE, 0x7E,   
		0x7F, 0xBF, 0x7D, 0xBD, 0xBC, 0x7C, 0xB4, 0x74, 0x75, 0xB5,   
		0x77, 0xB7, 0xB6, 0x76, 0x72, 0xB2, 0xB3, 0x73, 0xB1, 0x71,   
		0x70, 0xB0, 0x50, 0x90, 0x91, 0x51, 0x93, 0x53, 0x52, 0x92,   
		0x96, 0x56, 0x57, 0x97, 0x55, 0x95, 0x94, 0x54, 0x9C, 0x5C,   
		0x5D, 0x9D, 0x5F, 0x9F, 0x9E, 0x5E, 0x5A, 0x9A, 0x9B, 0x5B,   
		0x99, 0x59, 0x58, 0x98, 0x88, 0x48, 0x49, 0x89, 0x4B, 0x8B,   
		0x8A, 0x4A, 0x4E, 0x8E, 0x8F, 0x4F, 0x8D, 0x4D, 0x4C, 0x8C,   
		0x44, 0x84, 0x85, 0x45, 0x87, 0x47, 0x46, 0x86, 0x82, 0x42,   
		0x43, 0x83, 0x41, 0x81, 0x80, 0x40 
	];
	var CRC16LowForModbus = [
		0x00, 0xC1, 0x81, 0x40, 0x01, 0xC0, 0x80, 0x41, 0x01, 0xC0,   
		0x80, 0x41, 0x00, 0xC1, 0x81, 0x40, 0x01, 0xC0, 0x80, 0x41,   
		0x00, 0xC1, 0x81, 0x40, 0x00, 0xC1, 0x81, 0x40, 0x01, 0xC0,   
		0x80, 0x41, 0x01, 0xC0, 0x80, 0x41, 0x00, 0xC1, 0x81, 0x40,   
		0x00, 0xC1, 0x81, 0x40, 0x01, 0xC0, 0x80, 0x41, 0x00, 0xC1,   
		0x81, 0x40, 0x01, 0xC0, 0x80, 0x41, 0x01, 0xC0, 0x80, 0x41,   
		0x00, 0xC1, 0x81, 0x40, 0x01, 0xC0, 0x80, 0x41, 0x00, 0xC1,   
		0x81, 0x40, 0x00, 0xC1, 0x81, 0x40, 0x01, 0xC0, 0x80, 0x41,   
		0x00, 0xC1, 0x81, 0x40, 0x01, 0xC0, 0x80, 0x41, 0x01, 0xC0,   
		0x80, 0x41, 0x00, 0xC1, 0x81, 0x40, 0x00, 0xC1, 0x81, 0x40,   
		0x01, 0xC0, 0x80, 0x41, 0x01, 0xC0, 0x80, 0x41, 0x00, 0xC1,   
		0x81, 0x40, 0x01, 0xC0, 0x80, 0x41, 0x00, 0xC1, 0x81, 0x40,   
		0x00, 0xC1, 0x81, 0x40, 0x01, 0xC0, 0x80, 0x41, 0x01, 0xC0,   
		0x80, 0x41, 0x00, 0xC1, 0x81, 0x40, 0x00, 0xC1, 0x81, 0x40,   
		0x01, 0xC0, 0x80, 0x41, 0x00, 0xC1, 0x81, 0x40, 0x01, 0xC0,   
		0x80, 0x41, 0x01, 0xC0, 0x80, 0x41, 0x00, 0xC1, 0x81, 0x40,   
		0x00, 0xC1, 0x81, 0x40, 0x01, 0xC0, 0x80, 0x41, 0x01, 0xC0,   
		0x80, 0x41, 0x00, 0xC1, 0x81, 0x40, 0x01, 0xC0, 0x80, 0x41,   
		0x00, 0xC1, 0x81, 0x40, 0x00, 0xC1, 0x81, 0x40, 0x01, 0xC0,   
		0x80, 0x41, 0x00, 0xC1, 0x81, 0x40, 0x01, 0xC0, 0x80, 0x41,   
		0x01, 0xC0, 0x80, 0x41, 0x00, 0xC1, 0x81, 0x40, 0x01, 0xC0,   
		0x80, 0x41, 0x00, 0xC1, 0x81, 0x40, 0x00, 0xC1, 0x81, 0x40,   
		0x01, 0xC0, 0x80, 0x41, 0x01, 0xC0, 0x80, 0x41, 0x00, 0xC1,   
		0x81, 0x40, 0x00, 0xC1, 0x81, 0x40, 0x01, 0xC0, 0x80, 0x41,   
		0x00, 0xC1, 0x81, 0x40, 0x01, 0xC0, 0x80, 0x41, 0x01, 0xC0,   
		0x80, 0x41, 0x00, 0xC1, 0x81, 0x40 
	];

	function CRC16ForModbusLH(data,offset,length){
		var crcLow = 0xFF,
			crcHigh = 0xFF,
			uIndex;
		for(;length>0;length--){
			uIndex = crcLow ^ data[offset];
			crcLow = crcHigh ^ CRC16LowForModbus[uIndex&0x00FF]
			crcHigh = CRC16HighForModbus[uIndex & 0x00FF];
			offset ++;
		}
		
		//console.log((crcLow).toString(16) + ":" + (crcHigh).toString(16))
		return [crcLow,crcHigh]
		/*console.log((crcLow << 8 | crcHigh).toString(16))*/
	}
	/*var data = [1,6,0,1,1,44]
	CRC16ForModbusLH(data,0,6)*/

var set
$(document).ready(function(){
	function alltime(){
		if(atm==2 || atm==0){
			atm = 1;
			var getmsg=[0x01,0x03,0x00,0x00,0x00,0x01,0x84,0x0A]
		}else if(atm==1){
			atm = 2;
			var getmsg=[0x01,0x03,0x00,0x03,0x00,0x01,0x74,0x0A]
		}
		console.log(getmsg)
		if(ISIOS){
            OrderWebToIOS(getmsg);
        }else{
            js.OrderWebToAndroid(getmsg);
        }
	}
	set=setInterval(alltime,10000)
	
	if(ISIOS) {
		PageLoadIOS();
	} else {
		js.PageLoadAndroid();
	}
	

})		
			