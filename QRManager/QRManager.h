//
//  QRManager.h
//  QRSweepDemo
//
//  Created by suxx on 16/6/20.
//  Copyright © 2016年 suxx. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface QRManager : UIViewController

@property (nonatomic, strong)void (^sweepResult)(NSString *);

-(CALayer *)setSweepFrame:(CGRect)frame;

+(UIImage *)generateQRWithInfo:(NSString *)info;

-(void)handleSignal:(NSDictionary *)signalInfo;

@end
