//
//  FollowMajorViewController.m
//  WeStudy
//
//  Created by Arlenly on 16/3/2.
//  Copyright © 2016年 Arlenly. All rights reserved.
//

#import "FollowMajorViewController.h"

@interface FollowMajorViewController ()

@end

@implementation FollowMajorViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // 导航条返回键文字颜色
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    // 设置背景色
    self.view.backgroundColor = TabBarBG;
    // 右侧按钮标题
    self.navigationItem.title = @"关注行业";
    
    UILabel *lbPrompt = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 50)];
    lbPrompt.text = @"没有关注的行业";
    lbPrompt.textAlignment = NSTextAlignmentCenter;
    lbPrompt.center = CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2-64);
    lbPrompt.textColor = [UIColor grayColor];
    [self.view addSubview:lbPrompt];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
