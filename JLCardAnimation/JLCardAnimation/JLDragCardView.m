//
//  JLDragCardView.m
//  JLCardAnimation
//
//  Created by job on 16/8/31.
//  Copyright © 2016年 job. All rights reserved.
//

#import "JLDragCardView.h"
#import "CardHeader.h"

#define ACTION_MARGIN_RIGHT lengthFit(100)
#define ACTION_MARGIN_LEFT lengthFit(100)
#define ACTION_VELOCITY 400
#define SCALE_STRENGTH 4
#define SCALE_MAX .93
#define ROTATION_MAX 1
#define ROTATION_STRENGTH lengthFit(414)

#define BUTTON_WIDTH lengthFit(40)

@interface JLDragCardView() {
    CGFloat xFromCenter;
    CGFloat yFromCenter;
}
@property (strong, nonatomic) UILabel *nameLabel;


@end

@implementation JLDragCardView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.layer.cornerRadius      = 4;
        self.layer.shadowRadius      = 3;
        self.layer.shadowOpacity     = 0.2;
        self.layer.shadowOffset      = CGSizeMake(1, 1);
        self.layer.shadowPath        = [UIBezierPath bezierPathWithRect:self.bounds].CGPath;
        
        self.panGesture = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(beingDragged:)];
        [self addGestureRecognizer:self.panGesture];
        
        UIView *bgView            = [[UIView alloc]initWithFrame:self.bounds];
        bgView.layer.cornerRadius = 4;
        bgView.clipsToBounds      = YES;
        [self addSubview:bgView];
        
        self.headerImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        self.headerImageView.backgroundColor = [UIColor clearColor];
        self.headerImageView.userInteractionEnabled = YES;
        self.headerImageView.contentMode = UIViewContentModeScaleAspectFill;
        [bgView addSubview:self.headerImageView];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapGesture:)];
        [self.headerImageView addGestureRecognizer:tap];
        
        
        self.nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(20, self.frame.size.width+45, self.frame.size.width - 40, 20)];
        self.nameLabel.font = [UIFont boldSystemFontOfSize:17];
        self.nameLabel.textColor = [UIColor whiteColor];
        self.nameLabel.backgroundColor = [UIColor clearColor];
        self.nameLabel.textAlignment = NSTextAlignmentCenter;
        [bgView addSubview:self.nameLabel];
        
        
        self.noButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.noButton.frame = CGRectMake(self.frame.size.width / 2 - 61, self.frame.size.width-60, 122, 60);
        [self.noButton setImage:[UIImage imageNamed:@"Untitled-2.png"] forState:UIControlStateNormal];
        [bgView addSubview:self.noButton];
        self.noButton.alpha = 0;
        
        self.yesButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.yesButton.frame = CGRectMake(self.frame.size.width / 2 - 61, self.frame.size.width-60, 122, 60);
        [self.yesButton setImage:[UIImage imageNamed:@"Untitled-1.png"] forState:UIControlStateNormal];
        [bgView addSubview:self.yesButton];
        self.yesButton.alpha = 0;
        
    
        self.layer.allowsEdgeAntialiasing                 = YES;
        bgView.layer.allowsEdgeAntialiasing               = YES;
        self.headerImageView.layer.allowsEdgeAntialiasing = YES;
    }
    return self;
}


-(void)tapGesture:(UITapGestureRecognizer *)sender {
    if (!self.canPan) {
        return;
    }
    NSLog(@"tap") ;
}

-(void)layoutSubviews {
    self.nameLabel.text = self.infoDict[@"title"];
    self.headerImageView.image = [UIImage imageNamed:self.infoDict[@"image"]];
}

#pragma mark ------------- 拖动手势
-(void)beingDragged:(UIPanGestureRecognizer *)gesture {
    if (!self.canPan) {
        return ;
    }
    xFromCenter = [gesture translationInView:self].x;
    yFromCenter = [gesture translationInView:self].y;
    
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan:
            break;
        case UIGestureRecognizerStateChanged: {
            CGFloat rotationStrength = MIN(xFromCenter / ROTATION_STRENGTH, ROTATION_MAX);
            CGFloat rotationAngel = (CGFloat) (ROTATION_ANGLE * rotationStrength);
            self.center = CGPointMake(self.originalCenter.x + xFromCenter, self.originalCenter.y + yFromCenter);
            CGAffineTransform transform = CGAffineTransformMakeRotation(rotationAngel);
            CGAffineTransform scaleTransform = CGAffineTransformScale(transform, 1, 1);
            self.transform = scaleTransform;
            [self updateOverLay:xFromCenter];
            
        }
            break;
        case UIGestureRecognizerStateEnded: {
            [self followUpActionWithDistance:xFromCenter andVelocity:[gesture velocityInView:self.superview]];
        }
            break;
            
        default:
            break;
    }
}
#pragma mark ----------- 滑动时候，按钮变大
- (void) updateOverLay:(CGFloat)distance {
   
     [self.delegate moveCards:distance];
    
    if (distance > 0) {
        self.noButton.alpha = 0;
        self.yesButton.alpha = fabs(distance/20);
    } else {
        self.yesButton.alpha = 0;
        self.noButton.alpha = fabs(distance/20);
    }
}

#pragma mark ----------- 后续动作判断
-(void)followUpActionWithDistance:(CGFloat)distance andVelocity:(CGPoint)velocity {
    if (xFromCenter > 0 && (distance > ACTION_MARGIN_RIGHT || velocity.x > ACTION_VELOCITY )) {
        [self rightAction:velocity];
    } else if(xFromCenter < 0 && (distance < - ACTION_MARGIN_RIGHT || velocity.x < -ACTION_VELOCITY)) {
        [self leftAction:velocity];
    }else {
        //回到原点
        [UIView animateWithDuration:RESET_ANIMATION_TIME
                         animations:^{
                             self.center = self.originalCenter;
                             self.transform = CGAffineTransformMakeRotation(0);
                             self.yesButton.alpha = 0;
                             self.noButton.alpha = 0;
                         }];
        [self.delegate moveBackCards];
    }
}
-(void)rightAction:(CGPoint)velocity {
    CGFloat distanceX=[[UIScreen mainScreen]bounds].size.width+CARD_WIDTH+self.originalCenter.x;//横向移动距离
    CGFloat distanceY=distanceX*yFromCenter/xFromCenter;//纵向移动距离
    CGPoint finishPoint = CGPointMake(self.originalCenter.x+distanceX, self.originalCenter.y+distanceY);//目标center点
    
    CGFloat vel=sqrtf(pow(velocity.x, 2)+pow(velocity.y, 2));//滑动手势横纵合速度
    CGFloat displace=sqrt(pow(distanceX-xFromCenter,2)+pow(distanceY-yFromCenter,2));//需要动画完成的剩下距离
    
    CGFloat duration=fabs(displace/vel);//动画时间
    
    if (duration>0.6) {
        duration=0.6;
    }else if(duration<0.3){
        duration=0.3;
    }
    
    [UIView animateWithDuration:duration
                     animations:^{
                         
                         self.center = finishPoint;
                         self.transform = CGAffineTransformMakeRotation(ROTATION_ANGLE);
                     }completion:^(BOOL complete){
                         
                         [self.delegate swipCard:self Direction:YES];
                         self.noButton.alpha = 0;
                         self.yesButton.alpha = 0;
                     }];
    [self.delegate adjustOtherCards];
}

-(void)leftAction:(CGPoint)velocity {
    //横向移动距离
    CGFloat distanceX = -CARD_WIDTH - self.originalPoint.x;
    //纵向移动距离
    CGFloat distanceY = distanceX*yFromCenter/xFromCenter;
    //目标center点
    CGPoint finishPoint = CGPointMake(self.originalPoint.x+distanceX, self.originalPoint.y+distanceY);
    
    CGFloat vel = sqrtf(pow(velocity.x, 2) + pow(velocity.y, 2));
    CGFloat displace = sqrtf(pow(distanceX - xFromCenter, 2) + pow(distanceY - yFromCenter, 2));
    
    CGFloat duration = fabs(displace/vel);
    if (duration>0.6) {
        duration = 0.6;
    }else if(duration < 0.3) {
        duration = 0.3;
    }
    [UIView animateWithDuration:duration
                     animations:^{
                         self.center = finishPoint;
                         self.transform = CGAffineTransformMakeRotation(-ROTATION_ANGLE);
                     } completion:^(BOOL finished) {
                         [self.delegate swipCard:self Direction:NO];
                         self.noButton.alpha = 0;
                         self.yesButton.alpha = 0;
                     }];
    
    [self.delegate adjustOtherCards];
}


-(void)rightButtonClickAction {
    if (!self.canPan) {
        return;
    }
    CGPoint finishPoint = CGPointMake([[UIScreen mainScreen]bounds].size.width+CARD_WIDTH*2/3, 2*PAN_DISTANCE+self.frame.origin.y);
    [UIView animateWithDuration:CLICK_ANIMATION_TIME
                     animations:^{
                         self.center = finishPoint;
                         self.transform = CGAffineTransformMakeRotation(-ROTATION_ANGLE);
                     } completion:^(BOOL finished) {
                         [self.delegate swipCard:self Direction:YES];
                         self.noButton.alpha = 0;
                         self.yesButton.alpha = 0;
                     }];
    [self.delegate adjustOtherCards];
}
-(void)leftButtonClickAction {
    if (!self.canPan) {
        return;
    }
    CGPoint finishPoint = CGPointMake(-CARD_WIDTH*2/3, 2*PAN_DISTANCE + self.frame.origin.y);
    [UIView animateWithDuration:CLICK_ANIMATION_TIME
                     animations:^{
                         self.center = finishPoint;
                         self.transform = CGAffineTransformMakeRotation(-ROTATION_ANGLE);
                   } completion:^(BOOL finished) {
                       [self.delegate swipCard:self Direction:NO];
                       self.noButton.alpha = 0;
                       self.yesButton.alpha = 0;
                   }];
    [self.delegate adjustOtherCards];
    
}

@end
