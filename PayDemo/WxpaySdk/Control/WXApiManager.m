//
//  WXApiManager.m
//  SDKSample
//
//  Created by Jeason on 16/07/2015.
//
//

#import "WXApiManager.h"
#import "ConstString.h"

@implementation WXApiManager

#pragma mark - LifeCycle
+(instancetype)sharedManager {
    static dispatch_once_t onceToken;
    static WXApiManager *instance;
    dispatch_once(&onceToken, ^{
        instance = [[WXApiManager alloc] init];
    });
    return instance;
}

- (void)dealloc {
    self.delegate = nil;
}

#pragma mark - WXApiDelegate
- (void)onResp:(BaseResp *)resp {
    
     if([resp isKindOfClass:[PayResp class]]){
        //支付返回结果，实际支付结果需要去微信服务器端查询
         /**
          *  拿到支付结果进行相应的业务逻辑处理，一般通过通知的方式通知支付页面进行相应的信息提示
          *  在这里需要注意的是，微信官方文档给出的支付成功的判断是需要访问服务器后台核实才算是真的支付成功了
          */
        switch (resp.errCode) {
            case WXSuccess:
                /**
                 *  （那么这里就需要请求后台核对支付结果）
                 */
                
                //strMsg = @"支付结果：成功！";
                [NotificationCenter postNotificationName:WxPaySucceedNoti object:nil];
                break;
                
            default:
                //strMsg = @"支付结果：失败！
                [NotificationCenter postNotificationName:WxPayFailedNoti object:nil];
                break;
        }

    }

}

@end
