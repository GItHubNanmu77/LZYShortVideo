//
//  RCMediaViewController+Handle.m
//  CoreCapture
//
//  Created by 冯成林 on 2017/6/16.
//  Copyright © 2017年 冯成林. All rights reserved.
//

#import "RCMediaViewController+Handle.h"
#import <AVFoundation/AVFoundation.h>


@implementation RCMediaViewController (Handle)

+(UIImage *)getCoverImage:(NSString *)url {

    NSString *path = [NSString stringWithFormat:@"%@",url];
    
    NSURL *videoURL = [NSURL URLWithString:path];
    
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:videoURL options:nil];
    
    AVAssetImageGenerator *gen = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    
    gen.appliesPreferredTrackTransform = YES;
    
    CMTime time = CMTimeMakeWithSeconds(0.5, 600);
    
    NSError *error = nil;
    
    CMTime actualTime;
    
    CGImageRef image = [gen copyCGImageAtTime:time actualTime:&actualTime error:&error];
    
    UIImage *thumbImg = [[UIImage alloc] initWithCGImage:image];
    
    return thumbImg;
}



@end
