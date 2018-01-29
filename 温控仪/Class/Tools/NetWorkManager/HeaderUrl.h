
//
//  HeaderUrl.h
//  国际通用版
//
//  Created by 杭州阿尔法特 on 2017/12/1.
//  Copyright © 2017年 张海昌. All rights reserved.
//

#ifndef HeaderUrl_h
#define HeaderUrl_h

//192.168.1.104  本地ip
//114.55.5.92    外网ip
#define kPort 6003
#define localhost @"192.168.1.104"

#define kMineServiceNavTitle @"智能空净"

/**
 *  注册登录
 */

/**
 *  用户注册
 * 在出册用户之前，查询用户手机是否已被注册
 */
#define kJiaoYanZhangHu [NSString stringWithFormat:@"http://%@:8080/smarthome/user/queryPhone" , localhost]

/**
 查询用户名下绑定设备
 */
#define kQueryTheUserdevice [NSString stringWithFormat:@"http://%@:8080/smarthome/userDevice/queryUserDevice", localhost]

/**
 *  发送短信
 *
 */
#define kFaSongDuanXin [NSString stringWithFormat:@"http://%@:8080/smarthome/user/sendCode" , localhost]

/**
 *  注册信息提交
 *
 */
#define kRegisterURL [NSString stringWithFormat:@"http://%@:8080/smarthome/user/register" , localhost]

/**
 *  修改密码，包括登入后修改密码和忘记密码
 *
 */
#define kChongZhiMiMa [NSString stringWithFormat:@"http://%@:8080/smarthome/user/modifyPassword" , localhost]

/**
 *  用户登入
 *
 */
#define kLogin [NSString stringWithFormat:@"http://%@:8080/smarthome/user/login", localhost]





/**
 *  用户信息
 */

/**
 *  修改用户信息
 *
 */
#define kXiuGaiXinXi [NSString stringWithFormat:@"http://%@:8080/smarthome/user/modifyUserInfo", localhost]

/**
 *  用户上传头像
 *
 */
#define kShangChuanTouXiang [NSString stringWithFormat:@"http://%@:8080/smarthome/user/uploadUserHeadphoto", localhost]

/**
 *  查询用户地址
 *
 */
#define kChaXunYongHuDiZhi [NSString stringWithFormat:@"http://%@:8080/smarthome/user/queryUserAddress", localhost]

/**
 *  修改用户地址
 *
 */
#define kXiuGaiYongHuDiZhi [NSString stringWithFormat:@"http://%@:8080/smarthome/user/modifyUserAddress", localhost]




/**
 *  个人中心
 */

/**
 *  查询最新版本号
 *
 */
#define kChaXunBanBenHao [NSString stringWithFormat:@"http://114.55.5.92:8080/smarthome/app/queryLatestVersion"]

/**
 *  查询消息接口
 *
 */
#define kSystemMessageJieKou [NSString stringWithFormat:@"http://%@:8080/smarthome/app/queryPublicMessage", localhost]

/**
 *  查询消息接口
 *
 */
#define kUserReadSystemMessageCount [NSString stringWithFormat:@"http://%@:8080/smarthome/app/increasePMReadCount", localhost]
/**
 *  用户反馈借口
 *
 */
#define kYongHuFanKui [NSString stringWithFormat:@"http://%@:8080/smarthome/app/addFeedback", localhost]

/**
 *  更多产品
 *
 */
#define kGengDuoChanPin [NSString stringWithFormat:@"http://%@:8080/smarthome/deviceType/queryMoreProduct", localhost]




/**
 *  HTML网页
 */

/**
 *  关于我们
 *
 */
#define kAboutOurs [NSString stringWithFormat:@"http://%@:8080/smarthome/app/aboutus", localhost]

/**
 *  产品说明
 *
 */
#define kChanPinShuo [NSString stringWithFormat:@"http://%@:8080/smarthome/app/introduction", localhost]
/**
 *  冷风扇
 *
 */
#define kChanPinShuoLengFengShan [NSString stringWithFormat:@"http://%@:8080/smarthome/app/introduction/fan", localhost]
/**
 *  空气净化器
 *
 */
#define kChanPinShuoKongJing [NSString stringWithFormat:@"http://%@:8080/smarthome/app/introduction/air", localhost]
/**
 *  干衣机
 *
 */
#define kChanPinShuoGanYiJi [NSString stringWithFormat:@"http://%@:8080/smarthome/app/introduction/dryer", localhost]

/**
 *  在线帮助
 *
 */
#define kZaiXianBangZhu [NSString stringWithFormat:@"http://%@:8080/smarthome/app/help", localhost]

/**
 *  更新日志
 *
 */
#define kGengXinRiZhi [NSString stringWithFormat:@"http://%@:8080/smarthome/app/log/ios", localhost]

/**
 *  冷风扇的接口
 */
/**
 *  查询冷风扇当前状态
 *
 */
#define kChaXunLengFengShanDangQianZhuangTai [NSString stringWithFormat:@"http://%@:8080/smarthome/fan/queryDeviceState", localhost]

/**
 *  查询冷风扇当前数据
 *
 */
#define kChaXunLengFengShanDangQianShuJu [NSString stringWithFormat:@"http://%@:8080/smarthome/fan/queryDeviceData", localhost]

/**
 *  冷风扇复位按钮接口
 *
 */
#define kLengFengShanFuWi [NSString stringWithFormat:@"http://%@:8080/smarthome/fan/resetDeviceData", localhost]

/**
 *  冷风扇历史记录
 *
 */
#define kLengFengShanLiShiJiLu [NSString stringWithFormat:@"http://%@:8080/smarthome/fan/queryDeviceHistory", localhost]

/**
 *  冷风扇定时任务
 *
 */
#define kLengFengShanDingShiYuYue [NSString stringWithFormat:@"http://%@:8080/smarthome/fan/jobTask", localhost]




/**
 *  空气净化器接口
 */

/**
 *  查询空净当前状态
 *
 */
#define kChaXunKongJingDangQianZhuangTai [NSString stringWithFormat:@"http://%@:8080/smarthome/air/queryDeviceState", localhost]

/**
 *  查询空净当前数据
 *
 */
#define kChaXunKongJingDangQianShuJu [NSString stringWithFormat:@"http://%@:8080/smarthome/air/queryDeviceData", localhost]

/**
 *  空净历史记录
 *
 */
#define kKongJingLiShiJiLu [NSString stringWithFormat:@"http://%@:8080/smarthome/air/queryDeviceHistory", localhost]


/**
 *  获取空净定时任务
 *
 */
#define kGetKongJingTiming [NSString stringWithFormat:@"http://%@:8080/smarthome/air/queryJobTask", localhost]

/**
 *  查询设备pm25的值
 *
 */
#define kKongJingPM25State [NSString stringWithFormat:@"http://%@:8080/smarthome/air/queryDeviceAirAqi", localhost]

/**
 *  空净定时任务
 *
 */
#define kKongJingDingShiYuYue [NSString stringWithFormat:@"http://%@:8080/smarthome/air/jobTask", localhost]


/**
 *  系统数据
 */
/**
 *  查询历史空气质量数据
 */
#define kLiShiKongQiZhiLiang [NSString stringWithFormat:@"http://%@:8080/smarthome/weather/queryAqiHistory", localhost]

/**
 *  查询当天空气质量数据
 */
#define kDangTianKongQiZhiLiang [NSString stringWithFormat:@"http://%@:80/adapter/weather/queryAqi", localhost]

/**
 *  查询干衣机的状态
 *
 */
#define kChaXunGanYiJiZhuangTai [NSString stringWithFormat:@"http://%@:8080/smarthome/dryer/queryDeviceState", localhost]

/**
 *  查询干衣机的数据
 *
 */
#define kChaXunGanYiJiShuJu [NSString stringWithFormat:@"http://%@:8080/smarthome/dryer/queryDeviceData", localhost]

/**
 *  查询干衣机的历史数据
 *
 */
#define kChaXunGanYiJiLiShiShuJu [NSString stringWithFormat:@"http://%@:8080/smarthome/dryer/queryDeviceHistory", localhost]

/**
 *  干衣机的定时URL
 *
 */
#define kGanYiJiDeDingShiURL [NSString stringWithFormat:@"http://%@:8080/smarthome/dryer/jobTask", localhost]

#define kDeleteServiceURL [NSString stringWithFormat:@"http://%@:8080/smarthome/userDevice/deleteUserDevice", localhost]


/**
 *  修改设备名称
 */
#define kChangeServiceName [NSString stringWithFormat:@"http://%@:8080/smarthome/userDevice/modifyUserDevice", localhost]


/**
 *  所有设备类型借口
 */
#define kAllTypeServiceURL [NSString stringWithFormat:@"http://%@:8080/smarthome/deviceType/queryTypeList", localhost]

#define kBindLengFengShanURL [NSString stringWithFormat:@"http://%@:8080/smarthome/fan/bindDevice", localhost]

#define kBindKongQiJingHuaQiURL [NSString stringWithFormat:@"http://%@:8080/smarthome/air/bindDevice", localhost]

#define kBindGanYiJiURL [NSString stringWithFormat:@"http://%@:8080/smarthome/dryer/bindDevice", localhost]

#define kRequestWeatherURL [NSString stringWithFormat:@"http://114.55.5.92:80/adapter/weather/queryWeather"]

#define kServiceDescriptionURL(typeSn , devTypeSn) [NSString stringWithFormat:@"http://112.124.48.212/webpage/%@/%@/introduction/index.html" , typeSn , devTypeSn]
/**
 注册登入一体化
 */
#define kLoginWithRegisterURL [NSString stringWithFormat:@"http://%@:8080/smarthome/user/loginSimple", localhost]

/**
 获取用户信息
 */
#define kUserInfoURL [NSString stringWithFormat:@"http://%@:8080/smarthome/user/queryUserInfo", localhost]

/**
 查询某个具体设备（小类）
 */
#define kServiceDataWithTypeNumber [NSString stringWithFormat:@"http://%@:8080/smarthome/deviceType/queryType", localhost]

/**
 根据字段名称查询数据
 */
#define kServiceDataWithNameValue [NSString stringWithFormat:@"http://%@:8080/smarthome/deviceType/queryProduct", localhost]



#endif /* HeaderUrl_h */
