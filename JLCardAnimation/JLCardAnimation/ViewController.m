//
//  ViewController.m
//  JLCardAnimation
//
//  Created by 刘伟 on 2018/4/23.
//  Copyright © 2018年 job. All rights reserved.
//

#import "ViewController.h"
#import "JLCardViewController.h"

@interface ViewController ()
@property (assign, nonatomic) BOOL isVerb;
@property (strong, nonatomic) NSMutableArray *sourceObject;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    JLCardViewController *vc = [[JLCardViewController alloc]init];
    [self addChildViewController:vc];
    [self.view addSubview:vc.view];
}

@end
