//
//  ViewController.m
//  PayDemo
//
//  Created by luoqiang on 15/12/9.
//  Copyright © 2015年 luoqiang. All rights reserved.
//

#import "ViewController.h"
#import "Order.h"
#import "DataSigner.h"
#import <AlipaySDK/AlipaySDK.h>
#import "WXApiRequestHandler.h"
#import "WXApiManager.h"
#import "ConstString.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 注册支付结果通知
    [NotificationCenter addObserver:self selector:@selector(paySucceed) name:WxPaySucceedNoti object:nil];
    [NotificationCenter addObserver:self selector:@selector(payFailed) name:WxPayFailedNoti object:nil];
}

- (NSString *)generateTradeNO
{
    static int kNumber = 15;
    
    NSString *sourceStr = @"0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ";
    NSMutableString *resultStr = [[NSMutableString alloc] init];
    srand(time(0));
    for (int i = 0; i < kNumber; i++)
    {
        unsigned index = rand() % [sourceStr length];
        NSString *oneStr = [sourceStr substringWithRange:NSMakeRange(index, 1)];
        [resultStr appendString:oneStr];
    }
    return resultStr;
}


- (IBAction)pay:(id)sender
{

    
    /*
     *商户的唯一的parnter和seller。
     *签约后，支付宝会为每个商户分配一个唯一的 parnter 和 seller。
     */
    
    /*============================================================================*/
    /*=======================需要填写商户app申请的===================================*/
    /*============================================================================*/
    NSString *partner = @"";
    NSString *seller = @"";
    NSString *privateKey = @"";
    /*============================================================================*/
    /*============================================================================*/
    /*============================================================================*/
    
    //partner和seller获取失败,提示
    if ([partner length] == 0 ||
        [seller length] == 0 ||
        [privateKey length] == 0)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                        message:@"缺少partner或者seller或者私钥。"
                                                       delegate:self
                                              cancelButtonTitle:@"确定"
                                              otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    /*
     *生成订单信息及签名
     */
    //将商品信息赋予AlixPayOrder的成员变量
    Order *order = [[Order alloc] init];
    order.partner = partner;
    order.seller = seller;
    order.tradeNO = [self generateTradeNO]; //订单ID（由商家自行制定）
    order.productName = @"支付测试"; //商品标题
    order.productDescription = @"支付测试"; //商品描述
    order.amount = @"0.01"; //商品价格
    order.notifyURL =  @"http://www.xxx.com"; //回调URL
    
    order.service = @"mobile.securitypay.pay";
    order.paymentType = @"1";
    order.inputCharset = @"utf-8";
    order.itBPay = @"30m";
    order.showUrl = @"m.alipay.com";
    
    //应用注册scheme,在AlixPayDemo-Info.plist定义URL types
    NSString *appScheme = @"paydemo";
    
    //将商品信息拼接成字符串
    NSString *orderSpec = [order description];
    NSLog(@"orderSpec = %@",orderSpec);
    
    //获取私钥并将商户信息签名,外部商户可以根据情况存放私钥和签名,只需要遵循RSA签名规范,并将签名字符串base64编码和UrlEncode
    id<DataSigner> signer = CreateRSADataSigner(privateKey);
    NSString *signedString = [signer signString:orderSpec];
    
    //将签名成功字符串格式化为订单字符串,请严格按照该格式
    NSString *orderString = nil;
    if (signedString != nil) {
        orderString = [NSString stringWithFormat:@"%@&sign=\"%@\"&sign_type=\"%@\"",
                       orderSpec, signedString, @"RSA"];
        
        [[AlipaySDK defaultService] payOrder:orderString fromScheme:appScheme callback:^(NSDictionary *resultDic) {
            /**
             *  支付结果回调，支付宝会返回支付结果信息，一般是走这个方法。
             */
            NSLog(@"reslut = %@",resultDic);
            NSString *title = nil;
            if ([resultDic[@"resultStatus"] intValue]==9000) {
                title = @"回调1 支付成功！";
                [self paySucceed];
            }else{
                title = @"回调1 支付失败！";
                [self payFailed];
            }
            
        }];
        
    }

}

- (IBAction)weixinPay:(id)sender {
    NSString *res = [WXApiRequestHandler jumpToBizPay];
    
    if( ![@"" isEqual:res] ){
        UIAlertView *alter = [[UIAlertView alloc] initWithTitle:@"支付失败" message:res delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        
        [alter show];
    }
    
}


- (void)paySucceed
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"支付结果：" message:@"支付成功！"
                                                   delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
    [alert show];
}

- (void)payFailed
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"支付结果：" message:@"支付失败"
                                                   delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
    [alert show];
}



@end
