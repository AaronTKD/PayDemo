//
//  AppDelegate.m
//  PayDemo
//
//  Created by luoqiang on 15/12/9.
//  Copyright © 2015年 luoqiang. All rights reserved.
//

#import "AppDelegate.h"
#import <AlipaySDK/AlipaySDK.h>
#import "WXApiManager.h"


@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // 注册微信支付
    [WXApi registerApp:@"wxb4ba3c02aa476ea1" withDescription:@"demo 2.0"];
    return YES;
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    return  [WXApi handleOpenURL:url delegate:[WXApiManager sharedManager]];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    [[AlipaySDK defaultService] processOrderWithPaymentResult:url standbyCallback:^(NSDictionary *resultDic) {
        NSLog(@"-----%s------%@",__func__,resultDic);
        NSString *title = nil;
        if ([resultDic[@"resultStatus"] intValue]==9000) {
            title = @"回调2 支付成功！";
        }else{
            title = @"回调2 支付失败！";
        }
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"支付结果：" message:title
                                                       delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
        [alert show];
    }];
    return [WXApi handleOpenURL:url delegate:[WXApiManager sharedManager]];
}

@end
