//
//  ViewController.m
//  QZShortVideo
//
//  Created by cisdi on 2019/6/25.
//  Copyright © 2019 lzy. All rights reserved.
//

#import "ViewController.h"
#import "RCMediaViewController.h"
#import "RCMediaViewController+Handle.h"
#import "TZCameraViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface ViewController ()<RCMediaViewControllerDelegate>

@property (nonatomic, strong) UIImageView *preImage;
@property (nonatomic, strong) UIButton *btnTake;
@property (nonatomic, strong) UIButton *btnNext;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:self.preImage];
    [self.view addSubview:self.btnTake];
    [self.view addSubview:self.btnNext];
    
//    self.preImage.image = [UIImage imageNamed:@"Images/ball.png"];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Resource" ofType:@"bundle"];
    NSBundle *myBundle = [NSBundle bundleWithPath:path];
    NSString *imgPath = [myBundle pathForResource:@"0.jpg" ofType:nil];
    self.preImage.image = [UIImage imageWithContentsOfFile:imgPath];
//    self.preImage.image = [UIImage imageNamed:@"ball.png" inBundle:myBundle compatibleWithTraitCollection:nil];
    
    
    NSMutableArray *arr = [NSMutableArray array];
    for (int i=0; i<20; i++) {
        NSString *name = [NSString stringWithFormat:@"%d.jpg",i];
        UIImage *img = [UIImage imageNamed:name inBundle:myBundle compatibleWithTraitCollection:nil];
        [arr addObject:img];
    }
    NSLog(@"%@",arr);
    
//    NSMutableArray *arr2 = [NSMutableArray array];
//    for (int i=0; i<20; i++) {
//        NSString *name = [NSString stringWithFormat:@"%d.jpg",i];
//        NSString *imgName = [myBundle pathForResource:name ofType:nil];
//        UIImage *img = [UIImage imageWithContentsOfFile:imgName];
//        [arr2 addObject:img];
//    }
//    NSLog(@"%@",arr2);
}
- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.preImage.frame = CGRectMake(40, 100, 300, 300);
    self.btnTake.frame = CGRectMake(150, 500, 100, 60);
    self.btnNext.frame = CGRectMake(300, 64, 70, 50);
}

- (void)makePhoto
{
    RCMediaViewController *ctrl  = [[RCMediaViewController alloc] init];
    ctrl.mediaDelegate = self;
    [self presentViewController:ctrl animated:YES completion: nil];
}

- (void)btnNextAction{
    [self presentViewController:[TZCameraViewController new] animated:YES completion:nil];
}

#pragma mark - RCmediaControlleDelegate
-(void)rc_mediaController:(RCMediaViewController *)media didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *img = info[RCMediaImageInfo];
    if (img){
        self.preImage.image = img;
        //xxxx
        //        [self uploadImg:img];
    }
    
    NSString *video_url = info[RCMediaVideoInfo];
    if(video_url){
//        CGFloat size = [self getFileSize:video_url];
//        NSLog(@"视频大小 = %f",size);
        CGFloat seconds = [self getVideoLength:video_url];
        NSLog(@"视频时长 = %f",seconds);
        NSURL*mediaURL = info[RCMediaVideoInfo];
        UIImage *image = [RCMediaViewController getCoverImage:video_url];
        if(image){
            __weak typeof(self) weakSelf = self;
            dispatch_async(dispatch_get_main_queue(), ^{
                weakSelf.preImage.image = image;
            });
            //xxxx
            //            [self uploadImg:image];
        }
        NSData *data = [NSData dataWithContentsOfURL:mediaURL];
        if(data){
//            [self uploadVideo:data];
        }
    }
    [media dismissViewControllerAnimated:YES completion:nil];
}

- (void)rc_mediaControlelrDidCancel:(RCMediaViewController *)media;
{
    [media dismissViewControllerAnimated:YES completion:nil];
}

- (UIButton *)btnTake {
    if (!_btnTake) {
        _btnTake = [[UIButton alloc] initWithFrame:CGRectZero];
        [_btnTake setTitle:@"相机" forState:UIControlStateNormal];
        [_btnTake setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _btnTake.titleLabel.font = [UIFont systemFontOfSize:16];
        _btnTake.backgroundColor = [UIColor blueColor];
        [_btnTake addTarget:self action:@selector(makePhoto) forControlEvents:UIControlEventTouchUpInside];
    }
    return _btnTake;
}

//获取视频大小单位KB

- (CGFloat) getFileSize:(NSString *)path
{
    NSLog(@"%@",path);
    NSFileManager *fileManager = [NSFileManager defaultManager];
    float filesize = -1.0;
    if ([fileManager fileExistsAtPath:path]) {
        NSDictionary *fileDic = [fileManager attributesOfItemAtPath:path error:nil];//获取文件的属性
        unsigned long long size = [[fileDic objectForKey:NSFileSize] longLongValue];
        filesize = 1.0*size/1024;
    }else{
        NSLog(@"找不到文件");
    }
    return filesize;
}

//视频时长
- (CGFloat) getVideoLength:(NSURL *)URL
{
    AVURLAsset *avUrl = [AVURLAsset assetWithURL:URL];
    CMTime time = [avUrl duration];
    int second = ceil(time.value/time.timescale);
    return second;
}


- (UIImageView*)preImage{
    if(!_preImage){
        _preImage = [[UIImageView alloc]initWithFrame:CGRectZero];
        _preImage.backgroundColor = [UIColor grayColor];
        _preImage.image = [UIImage imageNamed:@""];
    }
    return _preImage;
}

- (UIButton *)btnNext {
    if (!_btnNext) {
        _btnNext = [[UIButton alloc] initWithFrame:CGRectZero];
        [_btnNext setTitle:@"下一页" forState:UIControlStateNormal];
        [_btnNext setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _btnNext.titleLabel.font = [UIFont systemFontOfSize:16];
        _btnNext.backgroundColor = [UIColor blueColor];
        [_btnNext addTarget:self action:@selector(btnNextAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _btnNext;
}
@end
