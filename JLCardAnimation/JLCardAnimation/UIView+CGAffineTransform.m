//
//  UIView+CGAffineTransform.m
//  JLCardAnimation
//
//  Created by 刘伟 on 2018/5/3.
//  Copyright © 2018年 job. All rights reserved.
//

#import "UIView+CGAffineTransform.h"

@implementation UIView (CGAffineTransform)

-(void)show:(void(^)(void))finishBlock{
    //缩小创建好的视图
    CGAffineTransform newTransform = CGAffineTransformScale(self.transform, 0.1, 0.1);
    [self setTransform:newTransform];
    
    //第一次显示的时候放大它
    [UIView animateWithDuration:animateWithDuration_times animations:^{
        CGAffineTransform newTransform = CGAffineTransformConcat(self.transform,  CGAffineTransformInvert(self.transform));
        [self setTransform:newTransform];
        self.alpha = 1.0;
    } completion:^(BOOL finished) {
        if(finishBlock != nil){
            finishBlock();
        }
    }];
}

-(void)hidden:(void(^)(void))finishBlock{
    [UIView animateWithDuration:animateWithDuration_times animations:^{
        CGAffineTransform newTransform =  CGAffineTransformScale(self.transform, 0.0, 0.0);
        [self setTransform:newTransform];
    } completion:^(BOOL finished) {
        if(finishBlock != nil){
            finishBlock();
        }
    }];
    
}

//淡入
-(void)sadeIn:(void(^)(void))finishBlock{
    self.alpha = 0.0;
    [UIView animateWithDuration:animateWithDuration_sade_times animations:^{
        self.alpha = 1.0;
    } completion:^(BOOL finished) {
        if(finishBlock != nil){
            finishBlock();
        }
    }];
}

//淡出
-(void)sadeOut:(void(^)(void))finishBlock;{
    [UIView animateWithDuration:animateWithDuration_sade_times animations:^{
        self.alpha = 0.0;
    } completion:^(BOOL finished) {
        if(finishBlock != nil){
            finishBlock();
        }
    }];
}
@end
