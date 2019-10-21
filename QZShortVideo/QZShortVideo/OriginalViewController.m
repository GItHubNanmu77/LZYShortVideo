//
//  OriginalViewController.m
//  QZShortVideo
//
//  Created by cisdi on 2019/10/10.
//  Copyright © 2019 lzy. All rights reserved.
//

#import "OriginalViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface OriginalViewController ()<UINavigationControllerDelegate, UIImagePickerControllerDelegate>
@property (nonatomic, strong) UIImageView *preImage;
@property (nonatomic, strong) UIButton *btnTake;
@property (nonatomic, strong) UIButton *btnNext;

@end

@implementation OriginalViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self.view addSubview:self.preImage];
    [self.view addSubview:self.btnTake];
    [self.view addSubview:self.btnNext];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.preImage.frame = CGRectMake(40, 100, 300, 300);
    self.btnTake.frame = CGRectMake(150, 500, 100, 60);
    self.btnNext.frame = CGRectMake(300, 64, 70, 50);
}
//获取Tmp目录

+(NSString *)rootDirTmp:(NSString *)path {

    NSString *tmpDirectory = NSTemporaryDirectory();

    NSString *rootDir = [tmpDirectory stringByAppendingPathComponent:path];

    [[NSFileManager defaultManager] createDirectoryAtPath:rootDir withIntermediateDirectories:YES attributes:nil error:nil];

    return rootDir;

}
- (void)makePhoto {
    
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    imagePicker.allowsEditing = YES;//编辑模式  但是编辑框是正方形的
// 使用前置还是后置摄像头
        imagePicker.cameraDevice = UIImagePickerControllerCameraDeviceRear;

  #// 设置可用的媒体类型、默认只包含kUTTypeImage
//imagePicker.mediaTypes = @[(NSString *)kUTTypeMovie, (NSString *)kUTTypeImage];

    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *cameraAction = [UIAlertAction actionWithTitle:@"从相机拍照" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
//设置照片来源

            imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
            [self presentViewController:imagePicker animated:YES completion:nil];
        }
    }];
    
    UIAlertAction *photoAction = [UIAlertAction actionWithTitle:@"从相册选择" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [self presentViewController:imagePicker animated:YES completion:nil];
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        NSLog(@"点击了取消");
    }];
    
    [actionSheet addAction:cameraAction];
    [actionSheet addAction:photoAction];
    [actionSheet addAction:cancelAction];
    
    [self presentViewController:actionSheet animated:YES completion:nil];
}

// 控制器不会自己dismiss 需要我们手动在相应的地方实现
// 这两个代理方法只会收到其中一个，取决于用户的点击情况

//结束采集之后 之后怎么处理都在这里写 通过Infokey取出相应的信息  Infokey可在进入文件中查看
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<UIImagePickerControllerInfoKey, id> *)info {
    NSURL *url = [info objectForKey:UIImagePickerControllerMediaURL];
    NSData *videoData = [NSData dataWithContentsOfURL:url];
    CGFloat size = [self getVideoLength:url];
      NSLog(@"00000000视频大小=%f",size);
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
}
//用户点击了取消

- (void)btnNextAction{
    [self dismissViewControllerAnimated:YES completion:nil];
}
//视频时长
- (CGFloat) getVideoLength:(NSURL *)URL
{
    
    AVURLAsset *avUrl = [AVURLAsset assetWithURL:URL];
    CMTime time = [avUrl duration];
    int second = ceil(time.value/time.timescale);
    return second;
}//

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
        [_btnNext setTitle:@"返回" forState:UIControlStateNormal];
        [_btnNext setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _btnNext.titleLabel.font = [UIFont systemFontOfSize:16];
        _btnNext.backgroundColor = [UIColor blueColor];
        [_btnNext addTarget:self action:@selector(btnNextAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _btnNext;
}
@end
