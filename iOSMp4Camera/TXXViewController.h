//
//  TXXViewController.h
//  iOSMp4Camera
//
//  Created by Xiaoxuan Tang on 12-12-14.
//  Copyright (c) 2012年 xiaoxuan Tang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CoreMedia.h>
#import <MediaPlayer/MediaPlayer.h>

@interface TXXViewController : UIViewController<UIImagePickerControllerDelegate, UINavigationControllerDelegate>
{
    UIImagePickerControllerQualityType                  _qualityType;
    NSString*                                           _mp4Quality;
    
    NSURL*                                              _videoURL;
    NSString*                                           _mp4Path;
    
    UILabel*                                            _fileSize;
    UILabel*                                            _videoLen;
    UIAlertView*                                        _alert;
    NSDate*                                             _startDate;
    
    UILabel*                                            _convertTime;
    UILabel*                                            _mp4Size;
    
    BOOL                                                _hasVideo;
    BOOL                                                _networkOpt;
    BOOL                                                _hasMp4;
}


@property (nonatomic, retain)   IBOutlet    UILabel*    fileSize;
@property (nonatomic, retain)   IBOutlet    UILabel*    videoLen;
@property (nonatomic, retain)   IBOutlet    UILabel*    convertTime;
@property (nonatomic, retain)   IBOutlet    UILabel*    mp4Size;

- (IBAction)videoQualitySgtClick:(id)sender;
- (IBAction)pickVideoBtnClick:(id)sender;

- (IBAction)mp4QualitySgtClick:(id)sender;
- (IBAction)switchChanged:(id)sender;

- (IBAction)encodeBtnClick:(id)sender;
- (IBAction)playBtnClick:(id)sender;
@end
