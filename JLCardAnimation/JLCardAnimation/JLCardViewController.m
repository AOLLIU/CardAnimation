//
//  JLCardViewController.m
//  JLCardAnimation
//
//  Created by job on 16/9/1.
//  Copyright © 2016年 job. All rights reserved.
//

#import "JLCardViewController.h"
#import "JLDragCardView.h"
#import "CardHeader.h"
#import "QDDragCardResultView.h"
#import "QDDragCardNextPage.h"

#define CARD_NUM 4
#define MIN_INFO_NUM 4
#define CARD_SCALE 0.95

@interface JLCardViewController()<JLDragCardDelegate>

@property (strong, nonatomic)  NSMutableArray *allCards;
@property (assign, nonatomic) CGPoint lastCardCenter;//最后一张卡片的中心点
@property (assign, nonatomic) CGAffineTransform lastCardTransform;//最后一张卡片的位置状态
@property (strong, nonatomic) NSMutableArray *sourceObject;
@property (assign, nonatomic) BOOL flag;
@property (assign, nonatomic) BOOL isVerb;
@property (strong, nonatomic) UIView *maskView;
@property (strong, nonatomic) QDDragCardResultView *resultView;
@property (strong, nonatomic) QDDragCardNextPage *nextPageView;
@property (strong, nonatomic) UIImageView *imageView;

@end


@implementation JLCardViewController

#pragma mark - life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"ZTDraggableView";
    self.view.backgroundColor = [UIColor whiteColor];
    self.allCards = [NSMutableArray array];
    self.sourceObject = [NSMutableArray array];

    [self addheaderView];
    [self addControls];
    [self addCards];
    [self.view addSubview:self.nextPageView];
    [self.view addSubview:self.resultView];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self requestSourceData:YES];
    });
    
}

#pragma mark - JLDragCardDelegate
///滑动后续操作
- (void)swipCard:(JLDragCardView *)cardView Direction:(BOOL)isRight {
    
    if (isRight) {
        [self like:cardView.infoDict];
    }else{
        [self unlike:cardView.infoDict];
    }
    
    [_allCards removeObject:cardView];
    cardView.transform = self.lastCardTransform;
    cardView.center = self.lastCardCenter;
    cardView.canPan = NO;
    [self.view insertSubview:cardView belowSubview:[_allCards lastObject]];
    [_allCards addObject:cardView];
    
    //如果有数据就展示,当小于最小个数时请求下一页数据,但是如果第一次加载的个数就小于卡片的个数,那么一定会是nil,那么就不会加载下一页数据了怎么办,不过好奇心不需要考虑,因为题数一定大于10道
    if ([self.sourceObject firstObject] != nil) {
        cardView.infoDict = [self.sourceObject firstObject];
        [self.sourceObject removeObjectAtIndex:0];
        [cardView layoutSubviews];
        if (self.isVerb) {
            if (self.sourceObject.count < MIN_INFO_NUM) {
                [self requestSourceData:NO];
//                [self loadMoreData];
            }
        }
    }else{
        cardView.hidden = YES;//如果没有数据则隐藏卡片
    }
    
    for (int i = 0; i<CARD_NUM; i++) {
        JLDragCardView*draggableView=[_allCards objectAtIndex:i];
        draggableView.originalCenter=draggableView.center;
        draggableView.originalTransform=draggableView.transform;
        if (i==0) {
            draggableView.canPan=YES;
        }
    }
    
}

///滑动中更改其他卡片位置
- (void)moveCards:(CGFloat)distance {
    
    if (fabs(distance) <= PAN_DISTANCE) {
        for (int i = 1; i < CARD_NUM - 1; i++) {
            JLDragCardView *draggableView = _allCards[i];
            JLDragCardView *preDraggableView = [_allCards objectAtIndex:i-1];
            
            draggableView.transform = CGAffineTransformScale(draggableView.originalTransform, 1+(1/CARD_SCALE-1)*fabs(distance/PAN_DISTANCE)*0.6, 1+(1/CARD_SCALE-1)*fabs(distance/PAN_DISTANCE)*0.6);//0.6为缩减因数，使放大速度始终小于卡片移动速度
            
            CGPoint center = draggableView.center;
            center.y = draggableView.originalCenter.y - (draggableView.originalCenter.y - preDraggableView.originalCenter.y) * fabs(distance/PAN_DISTANCE) * 0.6;//此处的0.6同上
            draggableView.center = center;
        }
    }
}

///滑动终止后复原其他卡片
- (void)moveBackCards {
    for (int i = 1; i < CARD_NUM - 1; i++) {
        JLDragCardView *draggableView = _allCards[i];
        [UIView animateWithDuration:RESET_ANIMATION_TIME
                         animations:^{
                             draggableView.transform = draggableView.originalTransform;
                             draggableView.center = draggableView.originalCenter;
                         }];
    }
}

///滑动后调整其他卡片位置
- (void)adjustOtherCards {
    
    [UIView animateWithDuration:0.2
                     animations:^{
                         for (int i = 1; i< CARD_NUM - 1; i++) {
                             JLDragCardView *draggableView = _allCards[i];
                             JLDragCardView *preDraggableView = [_allCards objectAtIndex:i-1];
                             draggableView.transform = preDraggableView.originalTransform;
                             draggableView.center = preDraggableView.originalCenter;
                         }
                     }completion:^(BOOL complete){
                         for (int i = 1; i< CARD_NUM - 1; i++) {
                             JLDragCardView *preDraggableView = [_allCards objectAtIndex:i-1];
                             if ([[preDraggableView.infoDict objectForKey:@"lastPage"] isEqualToString:@"yes"] && i == 1 && self.isVerb) {
                                 self.resultView.hidden = NO;
                                 self.nextPageView.hidden = NO;
                                 
                                 [UIView animateWithDuration:0.5 animations:^{
                                     self.resultView.alpha = 1;
                                     self.nextPageView.alpha = 1;
                                 } completion:^(BOOL finished) {

                                 }];
                             }
                         }
                         for (int i = 1; i< CARD_NUM - 1; i++) {
                             JLDragCardView *preDraggableView = [_allCards objectAtIndex:i-1];
                             if ([[preDraggableView.infoDict objectForKey:@"lastPage"] isEqualToString:@"yes"] && i == 1 && !self.isVerb) {
                                 self.imageView.image = [UIImage imageNamed:@"header_result.png"];
                             }
                         }
                     }];
    
}

#pragma mark - event response

- (void)normalBtnClick {
    self.isVerb = NO;
    self.imageView.image = [UIImage imageNamed:@"header.png"];
    [self refreshAllCards];
}

- (void) verbBtnClcik {
    self.isVerb = YES;
    self.imageView.image = [UIImage imageNamed:@"header.png"];
    [self refreshAllCards];
}

- (void)like:(NSDictionary*)userInfo {
    NSLog(@"like:%@",userInfo[@"title"]);
}

- (void)unlike:(NSDictionary*)userInfo {
    NSLog(@"unlike:%@",userInfo[@"title"]);
}

#pragma mark - private method
- (void) addheaderView {
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 70, self.view.bounds.size.width, 70)];
    imageView.image = [UIImage imageNamed:@"header.png"];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.imageView = imageView;
    [self.view addSubview:imageView];
}

- (void)addControls {
    
    UIButton *reloadBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [reloadBtn setTitle:@"普通模式" forState:UIControlStateNormal];
    reloadBtn.frame = CGRectMake(self.view.center.x-150, self.view.frame.size.height-60, 100, 30);
    [reloadBtn addTarget:self action:@selector(normalBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:reloadBtn];
    
    UIButton *verbBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [verbBtn setTitle:@"无尽模式" forState:UIControlStateNormal];
    verbBtn.frame = CGRectMake(self.view.center.x+50, self.view.frame.size.height-60, 100, 30);
    [verbBtn addTarget:self action:@selector(verbBtnClcik) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:verbBtn];
}

- (void)addCards {
    
    for (int i = 0; i < CARD_NUM; i++) {
        
        JLDragCardView *draggableView = [[JLDragCardView alloc]initWithFrame:CGRectMake([[UIScreen mainScreen]bounds].size.width+CARD_WIDTH, self.view.center.y-CARD_HEIGHT/2, CARD_WIDTH, CARD_HEIGHT)];
        
        if (i > 0 && i < CARD_NUM - 1) {
            draggableView.transform = CGAffineTransformScale(draggableView.transform, pow(CARD_SCALE, i), pow(CARD_SCALE, i));
        }else if(i == CARD_NUM - 1){
            draggableView.transform = CGAffineTransformScale(draggableView.transform, pow(CARD_SCALE, i-1), pow(CARD_SCALE, i-1));
        }
        draggableView.transform = CGAffineTransformMakeRotation(ROTATION_ANGLE);
        draggableView.delegate = self;
        
        [_allCards addObject:draggableView];
        if (i == 0) {
            draggableView.canPan = YES;
        }else{
            draggableView.canPan = NO;
        }
    }
    //倒序一次加载进来
    for (int i = (int)CARD_NUM-1; i>=0; i--){
        [self.view addSubview:_allCards[i]];
    }
}

- (void)requestSourceData:(BOOL)needLoad {
    
    NSMutableArray *objectArray = [@[] mutableCopy];
    
    [objectArray addObject:@{@"title":@"你家冰箱常备海盐吗?",@"image":@"01.jpg",@"lastPage":@"no"}];
    [objectArray addObject:@{@"title":@"尝试过三种以上牛油果吃法吗?",@"image":@"02.jpg",@"lastPage":@"no"}];
    [objectArray addObject:@{@"title":@"家里有破壁机吗?",@"image":@"03.jpg",@"lastPage":@"no"}];
    [objectArray addObject:@{@"title":@"买菜首选有机吗?",@"image":@"04.jpg",@"lastPage":@"no"}];
    [objectArray addObject:@{@"title":@"有各种各样的美食工具吗?",@"image":@"05.jpg",@"lastPage":@"yes"}];
    if (!self.isVerb) {
        [objectArray addObject:@{@"title":@"",@"image":@"07.png"}];
    }
    
    [self.sourceObject addObjectsFromArray:objectArray];
    
    //如果只是补充数据则不需要重新load卡片，而若是刷新卡片组则需要重新load
    if (needLoad) {
        [self loadAllCards];
    }
}

- (void)loadAllCards {
    
    for (int i = 0; i < self.allCards.count; i++) {
        JLDragCardView *draggableView = self.allCards[i];
        
        if ([self.sourceObject firstObject]) {
            draggableView.infoDict = [self.sourceObject firstObject];
            [self.sourceObject removeObjectAtIndex:0];
            [draggableView layoutSubviews];
            draggableView.hidden = NO;
        }else{
            draggableView.hidden = YES;//如果没有数据则隐藏卡片
        }
    }
    
    for (int i = 0; i < _allCards.count ;i++) {
        
        JLDragCardView *draggableView = self.allCards[i];
        
        CGPoint finishPoint = CGPointMake(self.view.center.x, CARD_HEIGHT/2 + 170);
        
        [UIView animateKeyframesWithDuration:0.3 delay:0.06*i options:UIViewKeyframeAnimationOptionCalculationModeLinear animations:^{
            
            draggableView.center = finishPoint;
            draggableView.transform = CGAffineTransformMakeRotation(0);
            
            if (i > 0 && i < CARD_NUM - 1) {
                JLDragCardView *preDraggableView=[_allCards objectAtIndex:i-1];
                draggableView.transform = CGAffineTransformScale(draggableView.transform, pow(CARD_SCALE, i), pow(CARD_SCALE, i));
                CGRect frame = draggableView.frame;
                frame.origin.y = preDraggableView.frame.origin.y + (preDraggableView.frame.size.height - frame.size.height) + 10 * pow(0.7,i);
                draggableView.frame = frame;
            }else if (i == CARD_NUM-1) {
                JLDragCardView *preDraggableView = [_allCards objectAtIndex:i-1];
                draggableView.transform = preDraggableView.transform;
                draggableView.frame = preDraggableView.frame;
            }
        } completion:^(BOOL finished) {
            
        }];
        
        draggableView.originalCenter = draggableView.center;
        draggableView.originalTransform = draggableView.transform;
        
        if (i == CARD_NUM - 1) {
            self.lastCardCenter = draggableView.center;
            self.lastCardTransform = draggableView.transform;
        }
    }
}

- (void)refreshAllCards {
    
    self.sourceObject = [@[] mutableCopy];
    
    for (int i = 0; i < _allCards.count ;i++) {
        
        JLDragCardView *card = self.allCards[i];
        
        CGPoint finishPoint = CGPointMake(-CARD_WIDTH, 2*PAN_DISTANCE+card.frame.origin.y);
        
        [UIView animateKeyframesWithDuration:0.3 delay:0.06*i options:UIViewKeyframeAnimationOptionCalculationModeLinear animations:^{
            
            card.center = finishPoint;
            card.transform = CGAffineTransformMakeRotation(-ROTATION_ANGLE);
            
        } completion:^(BOOL finished) {
            card.transform = CGAffineTransformMakeRotation(ROTATION_ANGLE);
            card.hidden = YES;
            card.center = CGPointMake([[UIScreen mainScreen]bounds].size.width + CARD_WIDTH, self.view.center.y);
            
            if (i == _allCards.count - 1) {
                [self requestSourceData:YES];
            }
        }];
    }
}

#pragma mark - getter and setter
- (UIView *)maskView {
    if (_maskView == nil) {
        _maskView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
        _maskView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.9];
        _maskView.hidden = YES;
        _maskView.alpha = 0.0;
    }
    return _maskView;
}

- (UIView *)resultView {
    if (_resultView == nil) {
        _resultView = [[QDDragCardResultView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
        _resultView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:1];
        _resultView.hidden = YES;
        _resultView.alpha = 0.0;
    }
    return _resultView;
}

- (UIView *)nextPageView {
    if (_nextPageView == nil) {
        _nextPageView = [[QDDragCardNextPage alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
        _nextPageView.backgroundColor = [UIColor clearColor];
        _nextPageView.hidden = YES;
        _nextPageView.alpha = 0.0;
    }
    return _nextPageView;
}

@end
