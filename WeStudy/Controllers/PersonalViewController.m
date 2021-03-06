//
//  PersonalViewController.m
//  WeStudy
//
//  Created by qianfeng on 16/2/19.
//  Copyright © 2016年 Arlenly. All rights reserved.
//

#import "PersonalViewController.h"
#import "LoginViewController.h"
#import "SettingsViewController.h"
#import "FollowMajorViewController.h"
#import "NoticeViewController.h"
#import "StarsViewController.h"
#import "LocationInnerViewController.h"
#import "MultiMediaViewController.h"
#import "MaterialStoreViewController.h"
#import "ShareViewController.h"

@interface PersonalViewController () <UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *portraitView;

@property (weak, nonatomic) IBOutlet UIButton *userName;

@property (weak, nonatomic) IBOutlet UIButton *studyData;

// 保存登录信息，自动登录
@property (nonatomic,strong) NSUserDefaults *loginUserDefaults;

// storyboard
@property (nonatomic,strong) UIStoryboard *storyMain;

@end

@implementation PersonalViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // 设置圆圆的头像，默认头像从本地读取 portrait0.png
    self.portraitView.layer.cornerRadius = self.portraitView.frame.size.width / 2;
    self.portraitView.clipsToBounds = YES;
    
    // 初始化 NSUserDefaults
    self.loginUserDefaults = [NSUserDefaults standardUserDefaults];
    
    // storyboard 初始化
    self.storyMain = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    // 获取通知中心 -- 注销
//    NSNotificationCenter *centerLogout = [NSNotificationCenter defaultCenter];
//    [centerLogout addObserver:self selector:@selector(logoutCenter:) name:@"logout" object:nil];
    [NSMutableArray array];
    
    // 分栏正中间按钮
    UIButton *centerBtn = [[UIButton alloc] initWithFrame:CGRectMake(WIDTH / 2 - HEIGHT_TABBAR / 2, 0, HEIGHT_TABBAR, HEIGHT_TABBAR)];
    [centerBtn setBackgroundImage:[UIImage imageNamed:@"icon_share"] forState:UIControlStateNormal];
    [self.tabBarController.tabBar addSubview:centerBtn];
    [centerBtn addTarget:self action:@selector(centerBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    
}

- (void)centerBtnClick:(UIButton *)btn {
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    ShareViewController *share = [story instantiateViewControllerWithIdentifier:@"course"];
//    self.modalPresentationStyle = UIModalPresentationPopover;
//    [self.tabBarController presentViewController:share animated:YES completion:nil];
//    [self.navigationController presentViewController:share animated:YES completion:nil];
    [self presentViewController:share animated:YES completion:nil];
    
}

// 接收通知 -- 注销
- (void)logoutCenter:(NSNotificationCenter *)notice {
    [self.userName setTitle:@"点击头像登录或注册" forState:UIControlStateNormal];
    [self.studyData setTitle:@"" forState:UIControlStateNormal];
    self.portraitView.image = [UIImage imageNamed:@"portrait0"];
    
    // 删除 NSUserDefaults 文件 -- 没用？
    NSString *libraryPath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *pathUserDefaults = [NSString stringWithFormat:@"%@/Preferences/",libraryPath];
    NSString *identifier  = [[NSBundle mainBundle] bundleIdentifier];
    NSString *filePath = [pathUserDefaults stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.plist",identifier]];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:filePath]) {
        // 存在 NSUserDefaults 文件，删除之，退出登录
        [fileManager removeItemAtPath:filePath error:nil];
    }
    NSLog(@"****%@",filePath);
}

// 登录成功后，刷新数据（由于从登录页面成功后到此页面是 dismiss 的，数据在那边刷新不了，在这里做）
// 如果已经登录（NsUserDefaults 中有登录账户），直接进入显示登录
- (void)viewWillAppear:(BOOL)animated {
    NSString *loginok = [self.loginUserDefaults stringForKey:@"loginok"];
    
    // 登录成功，刷新用户名、学习数据、头像，自动登录
    if (loginok != nil) {
        NSString *name = [self.loginUserDefaults stringForKey:@"username"];
        NSString *studyata  =[self.loginUserDefaults stringForKey:@"studydata"];
        NSString *pathOfPortrait  =[self.loginUserDefaults stringForKey:@"pathOfPortrait"];
        
        [self.userName setTitle:[NSString stringWithFormat:@"欢迎您:%@",name] forState:UIControlStateNormal];
        [self.studyData setTitle:studyata forState:UIControlStateNormal];
        
        // 保证图片存在，没有就从网络请求重新缓存 -- 否则切换界面刷新界面时出现卡顿
        NSFileManager *manager = [NSFileManager defaultManager];
        if ([manager fileExistsAtPath:pathOfPortrait]) {
            self.portraitView.image = [UIImage imageNamed:pathOfPortrait];    // 头像 -- 已登录
        }else {
            // 沙盒中没有图片就从网络请求
            NSURL *url = [NSURL URLWithString:[self.loginUserDefaults stringForKey:@"urlOfPortrait"]];
            [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:url] queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError) {
                self.portraitView.image = [UIImage imageWithData:data];     // 头像 -- 已登录
                // 将图片写入缓存，此时重新获取沙盒 pathOfPortrait 这个路径可能会发生变化
                [data writeToFile:pathOfPortrait atomically:YES];   // !!! 路径
            }];
        }
        // 测试
//        NSLog(@"%@",pathOfPortrait);
//        NSLog(@"%@",[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0]);
    }
}

// 头像图片手势
- (IBAction)loginGesPic:(id)sender {
    // UITapGestureRecognizer
    NSString *str = [self.loginUserDefaults stringForKey:@"loginok"];
    
    // 未登录状态，模态方式弹出登录界面
    if (str == nil) {
        LoginViewController *login = [_storyMain instantiateViewControllerWithIdentifier:@"login"];
        [self presentViewController:login animated:YES completion:nil];
    }
    // 已经处于登录状态，点击头像可修改头像
    else {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照",@"相册", nil];
        [actionSheet showInView:self.view];
    }
}

// 修改头像的协议方法
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        // 拍照
        // 创建 UIImagePickerController 图片选择器
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        // 指定其代理对象 -- 需要指定两个协议
        picker.delegate = self;
        // 设置资源类型，打开相机，图片的来源来自拍摄照片
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        // 显示，模态方式
        [self presentViewController:picker animated:YES completion:nil];
    }else if (buttonIndex == 1) {
        // 相册
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
        [self presentViewController:picker animated:YES completion:nil];
    }
    // buttonIndex == 2 为取消
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    ////
    NSLog(@"%@",info);
}

// navigation 右侧设置按钮
- (IBAction)rightSettings:(UIBarButtonItem *)sender {
    // 从 storyboard 中取才有用
    SettingsViewController *settings = [_storyMain instantiateViewControllerWithIdentifier:@"settings"];
    // 推入新的 view 隐藏tabbar
    self.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:settings animated:YES];
    // 返回来的时候显示 tabbar
    self.hidesBottomBarWhenPushed = NO;
}

// 关注行业点击事件
- (IBAction)followMajor:(id)sender {
    FollowMajorViewController *followMajor = [[FollowMajorViewController alloc] init];
    self.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:followMajor animated:YES];
    self.hidesBottomBarWhenPushed = NO;
}

// 通知点击事件
- (IBAction)notice:(id)sender {
    NoticeViewController *notice = [[NoticeViewController alloc] init];
    self.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:notice animated:YES];
    self.hidesBottomBarWhenPushed = NO;
}

// 收藏点击事件
- (IBAction)stars:(id)sender {
    StarsViewController *stars = [[StarsViewController alloc] init];
    self.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:stars animated:YES];
    self.hidesBottomBarWhenPushed = NO;
}

// 室内定位点击事件
- (IBAction)locationInner:(id)sender {
    LocationInnerViewController *locationInner = [[LocationInnerViewController alloc] init];
    self.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:locationInner animated:YES];
    self.hidesBottomBarWhenPushed = NO;
}

// 多媒体点击事件
- (IBAction)multiMedia:(id)sender {
    MultiMediaViewController *multiMedia = [[MultiMediaViewController alloc] init];
    self.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:multiMedia animated:YES];
    self.hidesBottomBarWhenPushed = NO;
}

// 资料库点击事件
- (IBAction)materiaStore:(id)sender {
    MaterialStoreViewController *materiaStore = [[MaterialStoreViewController alloc] init];
    self.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:materiaStore animated:YES];
    self.hidesBottomBarWhenPushed = NO;
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
