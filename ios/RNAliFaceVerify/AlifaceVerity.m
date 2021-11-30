//
//  AlifaceVerity.m
//  faceDemo
//
//  Created by top on 2019/12/12.
//  Copyright © 2019 Facebook. All rights reserved.
//

#import "AlifaceVerity.h"
#import <AliyunIdentityManager/AliyunIdentityPublicApi.h>
#import <AliyunIdentityManager/PoPGatewayNetwork.h>
#import <React/RCTUtils.h>

@implementation AlifaceVerity

RCT_EXPORT_MODULE(RNAliFaceVerify);

@synthesize bridge = _bridge;

- (void)viewDidLoad {
  [super viewDidLoad];
  
  [AliyunSdk init];
}
- (UIViewController *)getVC
{
  UIViewController *controller = RCTKeyWindow().rootViewController;
  UIViewController *presentedController = controller.presentedViewController;
  while (presentedController && ![presentedController isBeingDismissed]) {
    controller = presentedController;
    presentedController = controller.presentedViewController;
  }
  return controller;
}

- (UIViewController *)getCurrentVC
{
    UIViewController *result = nil;
    UIWindow * window = [[UIApplication sharedApplication] keyWindow];
    if (window.windowLevel != UIWindowLevelNormal)
    {
        NSArray *windows = [[UIApplication sharedApplication] windows];
        for(UIWindow * tmpWin in windows)
        {
            if (tmpWin.windowLevel == UIWindowLevelNormal)
            {
                window = tmpWin;
                break;
            }
        }
    }

    UIView *frontView = [[window subviews] objectAtIndex:0];
    id nextResponder = [frontView nextResponder];

    if ([nextResponder isKindOfClass:[UIViewController class]])
        result = nextResponder;
    else
        result = window.rootViewController;

    return result;
}

RCT_EXPORT_METHOD(getZimFace:(NSString *)certName certNo:(NSString *)certNo successCallback:(RCTResponseSenderBlock)successCallback errorCallback:(RCTResponseSenderBlock)errorCallback){
    NSDictionary *userDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:certName,@"certName",certNo,@"certNo",nil];
    if ([NSJSONSerialization isValidJSONObject:userDictionary])
    {
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:userDictionary options:NSJSONWritingPrettyPrinted error: &error];
        NSMutableData *tempJsonData = [NSMutableData dataWithData:jsonData];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        [request setURL:[NSURL URLWithString:@"https://kumili.net/apiV2/FaceInit"]];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [request setHTTPMethod:@"POST"];
        [request setHTTPBody:tempJsonData];
        //
        NSURLSession *session = [NSURLSession sharedSession];
        // 4.根据会话对象，创建一个Task任务
        NSURLSessionDataTask *sessionDataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            /*
             对从服务器获取到的数据data进行相应的处理.
             */
            NSLog(@"从服务器获取到数据");
            NSString *result = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSLog(@"从服务器获取到数据 %@",result);
            if (result) {
                NSLog(@"响应");
                successCallback(@[result]);
            } else {
                errorCallback(@[@false]);
            }
        }];
        //5.最后一步，执行任务，(resume也是继续执行)。
        [sessionDataTask resume];
    }
}

RCT_EXPORT_METHOD(verify:(NSString *)url certId:(NSString *)certId callback:(RCTResponseSenderBlock)callback)
{
//  dispatch_async(dispatch_get_main_queue(), ^{
//    UIViewController *root = [UIApplication sharedApplication].keyWindow.rootViewController;
//    [[APVerifyService sharedService] startVerifyService:@{@"url": url,@"certifyId": certId} target:root block:^(NSMutableDictionary * resultDic){
//      NSLog(@"resultDic=%@", resultDic);
//    }];
//
//  });
    if ([certId length]<1) {
        [self alertInfomation:@"还未获取到certifyId"];
        return;
    }
//    [_submitInfo setUserInteractionEnabled:NO];
    //第一个参数 ,这个参数从服务端拿到值。
//    certifyId =  @"0007494f9fb2d41ba36d7fad6af6875b";
    //第二个参数，extParams , 用于指定设备方向，展现网络菊花等。
    NSMutableDictionary  *extParams = [NSMutableDictionary new];
    //传入当前viewController，用于展现请求网络时的菊花。
    [extParams setValue:self forKey:@"currentCtr"];
    //    [extParams setValue:@"true" forKey:@"uploadLog"];
        
//    //下面是添加设备方位的参数。
//    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
//    NSString *direction = @"";
//    switch (orientation) {
//        case UIInterfaceOrientationLandscapeLeft:
//            direction = @"left";
//            break;
//        case UIInterfaceOrientationLandscapeRight:
//            direction = @"right";
//            break;
//        default:
//            break;
//    }
//    //只有在iPad的横屏模式下，才传此参数。其他任何情况下都不传这个参数。目前界面不支持横竖屏动态切换。
//    [extParams setValue:direction forKey:@"direction"];
    
    [[AliyunIdentityManager sharedInstance] verifyWith:certId extParams:extParams onCompletion:^(ZIMResponse *response) {
         dispatch_async(dispatch_get_main_queue(), ^{
             NSString *title = @"刷脸成功";
             switch (response.code) {
                 case 1000:
                     break;
                 case 1003:
                     title = @"用户退出";
                     break;
                 case 2002:
                     title = @"网络错误";
                     break;
                 case 2006:
                     title = @"刷脸失败";
                     break;
                 default:
                     break;
             }
             UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:response.retMessageSub preferredStyle:UIAlertControllerStyleAlert];
             [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
//                 [_submitInfo setUserInteractionEnabled:YES];
             }]];
             [self presentViewController:alertController animated:YES completion:nil];
            
         });
    }];
}

-(void)alertInfomation:(NSString*)title{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }]];
    [self presentViewController:alertController animated:YES completion:nil];
}

@end
