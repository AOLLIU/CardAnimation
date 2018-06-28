//
//  QDDragCardResultView.m
//  JLCardAnimation
//
//  Created by 刘伟 on 2018/5/3.
//  Copyright © 2018年 job. All rights reserved.
//

#import "QDDragCardResultView.h"
#import "UIView+CGAffineTransform.h"

@interface QDDragCardResultView()

@property (nonatomic, strong) UIImageView *totalimageView;

@end

@implementation QDDragCardResultView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self addsubViews];
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

- (void) addsubViews {
    self.totalimageView = [[UIImageView alloc]initWithFrame:self.bounds];
    self.totalimageView.image = [UIImage imageNamed:@"result.png"];
    self.totalimageView.userInteractionEnabled = YES;
//    self.totalimageView.contentMode = UIViewContentModeScaleAspectFill;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapGesture:)];
    [self.totalimageView addGestureRecognizer:tap];
    [self addSubview:_totalimageView];
    
}

-(void)tapGesture:(UITapGestureRecognizer *)sender {
    [self sadeOut:nil];
}


@end
