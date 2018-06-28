//
//  UIView+CGAffineTransform.h
//  JLCardAnimation
//
//  Created by 刘伟 on 2018/5/3.
//  Copyright © 2018年 job. All rights reserved.
//

#import <UIKit/UIKit.h>
#define animateWithDuration_times 0.2
#define animateWithDuration_sade_times 0.3

@interface UIView (CGAffineTransform)

//放大
-(void)show:(void(^)(void))finishBlock;
//缩小
-(void)hidden:(void(^)(void))finishBlock;

//淡入
-(void)sadeIn:(void(^)(void))finishBlock;
//淡出
-(void)sadeOut:(void(^)(void))finishBlock;

@end
