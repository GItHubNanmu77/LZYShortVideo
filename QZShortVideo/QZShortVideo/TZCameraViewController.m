//
//  TZCameraViewController.m
//  QZShortVideo
//
//  Created by cisdi on 2019/6/26.
//  Copyright © 2019 lzy. All rights reserved.
//

#import "TZCameraViewController.h"
#import <TZImagePickerController/TZImagePickerController.h>
#import "SDAVAssetExportSession.h"
#import <AVKit/AVKit.h>

@interface TZCameraViewController ()<TZImagePickerControllerDelegate>
@property (nonatomic, strong) UIImageView *preImage;
@property (nonatomic, strong) UIButton *btnTake;
@property (nonatomic, strong) UIButton *btnNext;
@property (nonatomic, strong) UIButton *btnPlay;
@property (nonatomic, strong) UIButton *btnChange;

@property (nonatomic, strong) TZImagePickerController *tzPicker;
@property (nonatomic, copy) NSURL *videoUrl;
@property (nonatomic, copy) NSURL *TZvideoUrl;
@property (nonatomic, copy) NSURL *SDvideoUrl;
@end

@implementation TZCameraViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self.view addSubview:self.preImage];
    [self.view addSubview:self.btnTake];
    [self.view addSubview:self.btnNext];
    [self.view addSubview:self.btnPlay];
    [self.view addSubview:self.btnChange];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.preImage.frame = CGRectMake(40, 100, 300, 300);
    self.btnTake.frame = CGRectMake(50, 500, 100, 60);
    self.btnNext.frame = CGRectMake(300, 64, 70, 50);
    self.btnPlay.frame = CGRectMake(200, 500, 70, 50);
    self.btnChange.frame = CGRectMake(300, 500, 70, 50);
}

- (void)makePhoto
{
    self.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:self.tzPicker animated:YES completion:^{
        
    }];
}

- (void)btnNextAction{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)tz_imagePickerControllerDidCancel:(TZImagePickerController *)picker {
    
}

//获取Tmp目录

+(NSString *)rootDirTmp:(NSString *)path {

    NSString *tmpDirectory = NSTemporaryDirectory();

    NSString *rootDir = [tmpDirectory stringByAppendingPathComponent:path];

    [[NSFileManager defaultManager] createDirectoryAtPath:rootDir withIntermediateDirectories:YES attributes:nil error:nil];

    return rootDir;

}

//选择u图片
- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingPhotos:(NSArray<UIImage *> *)photos sourceAssets:(NSArray *)assets isSelectOriginalPhoto:(BOOL)isSelectOriginalPhoto {
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        weakSelf.preImage.image = [photos firstObject];
    });
    
//    NSURL *videoUrl = [info objectForKey:UIImagePickerControllerMediaURL];
}
//选择视频
- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingVideo:(UIImage *)coverImage sourceAssets:(PHAsset *)asset {
    self.preImage.image = coverImage;
    NSLog(@"path = %@",asset);
    
    [[TZImageManager manager] getVideoOutputPathWithAsset:asset presetName:AVAssetExportPresetLowQuality success:^(NSString *outputPath) {
        // NSData *data = [NSData dataWithContentsOfFile:outputPath];
        NSLog(@"视频导出到本地完成,沙盒路径为:%@",outputPath);
//        NSData *data = [NSData dataWithContentsOfFile:outputPath];
        CGFloat size = [self getFileSize:outputPath];
                   NSLog(@"00000000视频大小=%f",size);
        NSData *data = [NSData dataWithContentsOfFile:outputPath];
        NSLog(@"000大小: %@", [self formatByte:data.length]);
        self.TZvideoUrl = [NSURL fileURLWithPath:outputPath];
        // Export completed, send video here, send by outputPath or NSData
        // 导出完成，在这里写上传代码，通过路径或者通过NSData上传
    } failure:^(NSString *errorMessage, NSError *error) {
    }];
    
    //2222222222222222222
    if (asset.mediaType == PHAssetMediaTypeVideo) {//视频

        PHVideoRequestOptions *options = [[PHVideoRequestOptions alloc] init];
        options.version = PHImageRequestOptionsVersionCurrent;
        options.deliveryMode = PHVideoRequestOptionsDeliveryModeAutomatic;

        PHImageManager *manager = [PHImageManager defaultManager];
        [manager requestAVAssetForVideo:asset options:options resultHandler:^(AVAsset * _Nullable asset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {

            AVURLAsset *urlAsset = (AVURLAsset *)asset;
            NSURL *videoURL = urlAsset.URL;


            NSData *data = [NSData dataWithContentsOfFile:[videoURL absoluteString]];
//            NSLog(@"------%@",data);
//            CGFloat size = [self getFileSize:[videoURL absoluteString]];
//            NSLog(@"2222222视频大小=%f",size);
//           CGFloat seconds =  [self getVideoLength:videoURL];
//            NSLog(@"path = %@",videoURL);
//            NSLog(@"视频时长：%f",seconds);

               [self zipVideo:videoURL asset:urlAsset];
            // path = file:///var/mobile/Media/DCIM/100APPLE/IMG_0034.MOV
//            NSURL *mp4 = [self _convert2Mp4:videoURL];
//            NSFileManager *fileman = [NSFileManager defaultManager];
//            if ([fileman fileExistsAtPath:videoURL.path]) {
//                NSError *error = nil;
//                [fileman removeItemAtURL:videoURL error:&error];
//                if (error) {
//                    NSLog(@"failed to remove file, error:%@.", error);
//                }
//            }
//            [self sendVideoMessageWithURL:mp4];
        }];
        
    }
}

- (void)zipVideo:(NSURL *)outputFileURL asset:(AVAsset *)anAsset {
     NSString *root = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
                NSString *tempDir = [root stringByAppendingString:@"/temp"];
                if (![[NSFileManager defaultManager] fileExistsAtPath:tempDir isDirectory:nil]) {
                    [[NSFileManager defaultManager] createDirectoryAtPath:tempDir withIntermediateDirectories:YES attributes:nil error:nil];
                }
                NSDateFormatter *formater = [[NSDateFormatter alloc] init];
                [formater setDateFormat:@"yyyy-MM-dd-HH:mm:ss-SSS"];
                NSString *time = [formater stringFromDate:[NSDate date]];
    //            NSString *outputPath = [NSHomeDirectory() stringByAppendingFormat:@"/tmp/video-%@.mp4", time];
                NSString *myPathDocs =  [tempDir stringByAppendingPathComponent:[NSString stringWithFormat:@"Video-%@.mp4",time]];
                NSURL *url = [NSURL fileURLWithPath:myPathDocs];
    
    SDAVAssetExportSession *encoder = [SDAVAssetExportSession.alloc initWithAsset:anAsset];
    encoder.outputFileType = AVFileTypeMPEG4;
    encoder.outputURL = url;
    encoder.videoSettings = @
    {
        AVVideoCodecKey: AVVideoCodecH264,
        AVVideoWidthKey: @320,
        AVVideoHeightKey: @568,
        AVVideoCompressionPropertiesKey: @
        {
            AVVideoAverageBitRateKey: @150000,
            AVVideoProfileLevelKey: AVVideoProfileLevelH264Baseline30,
        },
    };
    encoder.audioSettings = @
    {
        AVFormatIDKey: @(kAudioFormatMPEG4AAC),
        AVNumberOfChannelsKey: @2,
        AVSampleRateKey: @44100,
        AVEncoderBitRateKey: @128000,
    };

    [encoder exportAsynchronouslyWithCompletionHandler:^
    {
        if (encoder.status == AVAssetExportSessionStatusCompleted)
        {
            NSLog(@"----Video export succeeded");
            NSLog(@"----%@",encoder.outputURL);
            self.SDvideoUrl = url;
            NSString *urlstring = [[url absoluteString] substringFromIndex:7];
            CGFloat size = [self getFileSize:urlstring];
                       NSLog(@"1111111视频大小=%f",size);
            NSData *data = [NSData dataWithContentsOfFile:urlstring];
            NSLog(@"大小: %@", [self formatByte:data.length]);
        }
        else if (encoder.status == AVAssetExportSessionStatusCancelled)
        {
            NSLog(@"------Video export cancelled");
        }
        else
        {
            NSLog(@"----------Video export failed with error: %@ (%d)", encoder.error.localizedDescription, encoder.error.code);
        }
    }];
}

- (void)switch:(UIButton *)sender {
    sender.selected = !sender.selected;
    if(sender.selected) {
        self.videoUrl = self.TZvideoUrl;
    } else {
        self.videoUrl = self.SDvideoUrl;
    }
}
- (void)play {
    
    // 普通设备
    AVPlayerViewController *aVPlayerVC = [[AVPlayerViewController alloc] init];
    AVPlayer *player = [[AVPlayer alloc] initWithURL:self.videoUrl];
    if (@available(iOS 10.0, *)) {
        player.automaticallyWaitsToMinimizeStalling = NO;
    }
    aVPlayerVC.player = player;
    [self presentViewController:aVPlayerVC animated:YES completion:^{
        [player play];
    }];
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
- (NSString *)formatByte:(unsigned long long)size {
    float f;
    if (size < 1024 * 1024) {
        f = ((float)size / 1024.0);
        return [NSString stringWithFormat:@"%.2fKB", f];
    } else if (size >= 1024 * 1024 && size < 1024 * 1024 * 1024) {
        f = ((float)size / (1024.0 * 1024.0));
        return [NSString stringWithFormat:@"%.2fMB", f];
    }
    f = ((float)size / (1024.0 * 1024.0 * 1024.0));
    return [NSString stringWithFormat:@"%.2fG", f];
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

- (UIButton *)btnPlay {
    if (!_btnPlay) {
        _btnPlay = [[UIButton alloc] initWithFrame:CGRectZero];
        [_btnPlay setTitle:@"播放" forState:UIControlStateNormal];
        [_btnPlay setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _btnPlay.titleLabel.font = [UIFont systemFontOfSize:16];
        _btnPlay.backgroundColor = [UIColor blueColor];
        [_btnPlay addTarget:self action:@selector(play) forControlEvents:UIControlEventTouchUpInside];
    }
    return _btnPlay;
}

- (UIButton *)btnChange {
    if (!_btnChange) {
        _btnChange = [[UIButton alloc] initWithFrame:CGRectZero];
        [_btnChange setTitle:@"切换" forState:UIControlStateNormal];
        [_btnChange setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _btnChange.titleLabel.font = [UIFont systemFontOfSize:16];
        _btnChange.backgroundColor = [UIColor blueColor];
        [_btnChange addTarget:self action:@selector(switch:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _btnChange;
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
- (TZImagePickerController *)tzPicker {
    if (!_tzPicker) {
        _tzPicker = [[TZImagePickerController alloc] initWithMaxImagesCount:9 delegate:self];
        _tzPicker.allowPickingVideo = YES;
        _tzPicker.allowTakeVideo = YES;
        _tzPicker.allowTakePicture = YES;
        _tzPicker.videoMaximumDuration = 60;
        
    }
    return _tzPicker;
}
@end
