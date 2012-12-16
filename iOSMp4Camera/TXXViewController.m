//
//  TXXViewController.m
//  iOSMp4Camera
//
//  Created by Xiaoxuan Tang on 12-12-14.
//  Copyright (c) 2012年 xiaoxuan Tang. All rights reserved.
//

#import "TXXViewController.h"
@interface TXXViewController ()
- (NSInteger) getFileSize:(NSString*) path;
- (CGFloat) getVideoDuration:(NSURL*) URL;
- (void) convertFinish;
@end

@implementation TXXViewController

- (IBAction)videoQualitySgtClick:(id)sender
{
    NSInteger index = [(UISegmentedControl* )sender selectedSegmentIndex];
    switch (index) {
        case 0:
            _qualityType = UIImagePickerControllerQualityTypeLow;
            break;
        case 1:
            _qualityType = UIImagePickerControllerQualityTypeMedium;
            break;
        case 2:
            _qualityType = UIImagePickerControllerQualityTypeHigh;
            break;
        default:
            break;
    }
}

- (IBAction) mp4QualitySgtClick:(id)sender
{
    NSInteger index = [(UISegmentedControl* )sender selectedSegmentIndex];
    switch (index) {
        case 0:
            _mp4Quality = AVAssetExportPresetLowQuality;
            break;
        case 1:
            _mp4Quality = AVAssetExportPresetMediumQuality;
            break;
        case 2:
            _mp4Quality = AVAssetExportPresetHighestQuality;
        default:
            break;
    }
}

- (IBAction)pickVideoBtnClick:(id)sender
{
    if (_hasVideo)
    {
        [_mp4Path release];
        _mp4Path = nil;
        [_videoURL release];
        _videoURL = nil;
        [_startDate release];
        _startDate = nil;
        
    }
    UIImagePickerController* pickerView = [[UIImagePickerController alloc] init];
    pickerView.sourceType = UIImagePickerControllerSourceTypeCamera;
    NSArray* availableMedia = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];
    pickerView.mediaTypes = [NSArray arrayWithObject:availableMedia[1]];
    [self presentModalViewController:pickerView animated:YES];
    pickerView.videoMaximumDuration = 30;
    pickerView.delegate = self;
    [pickerView release];
}

- (IBAction) switchChanged:(id)sender
{
    _networkOpt = ((UISwitch*) sender).on;
}

- (IBAction)encodeBtnClick:(id)sender
{
    if (!_hasVideo)
    {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"ERROR"
                                                         message:@"Please record a video first"
                                                        delegate:nil
                                               cancelButtonTitle:@"OK"
                                               otherButtonTitles: nil];
        [alert show];
        [alert release];
        return;
    }
    
    AVURLAsset *avAsset = [AVURLAsset URLAssetWithURL:_videoURL options:nil];
    NSArray *compatiblePresets = [AVAssetExportSession exportPresetsCompatibleWithAsset:avAsset];

    if ([compatiblePresets containsObject:_mp4Quality])
        
    {
        _alert = [[UIAlertView alloc] init];
        [_alert setTitle:@"Waiting.."];
        
        UIActivityIndicatorView* activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        activity.frame = CGRectMake(140,
                                    80,
                                    CGRectGetWidth(_alert.frame),
                                    CGRectGetHeight(_alert.frame));
        [_alert addSubview:activity];
        [activity startAnimating];
        [activity release];
        [_alert show];
        [_alert release];
        _startDate = [[NSDate date] retain];

        AVAssetExportSession *exportSession = [[AVAssetExportSession alloc]initWithAsset:avAsset
                                                                              presetName:_mp4Quality];
        NSDateFormatter* formater = [[NSDateFormatter alloc] init];
        [formater setDateFormat:@"yyyy-MM-dd HH:mm:ss "];
        _mp4Path = [[NSHomeDirectory() stringByAppendingFormat:@"/Documents/output-%@.mp4", [formater stringFromDate:[NSDate date]]] retain];
        [formater release];
        
        exportSession.outputURL = [NSURL fileURLWithPath: _mp4Path];
        exportSession.shouldOptimizeForNetworkUse = _networkOpt;
        exportSession.outputFileType = AVFileTypeMPEG4;
        [exportSession exportAsynchronouslyWithCompletionHandler:^{
            switch ([exportSession status]) {
                case AVAssetExportSessionStatusFailed:
                {
                    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                    message:[[exportSession error] localizedDescription]
                                                                   delegate:nil
                                                          cancelButtonTitle:@"OK"
                                                          otherButtonTitles: nil];
                    [alert show];
                    [alert release];
                    break;
                }
                    
                case AVAssetExportSessionStatusCancelled:
                    NSLog(@"Export canceled");
                    break;
                case AVAssetExportSessionStatusCompleted:
                    NSLog(@"Successful!");
                    [self performSelectorOnMainThread:@selector(convertFinish) withObject:nil waitUntilDone:NO];
                    break;
                default:
                    break;
            }
            [exportSession release];
        }];
    }
    else
    {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:@"AVAsset doesn't support mp4 quality"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles: nil];
        [alert show];
        [alert release];
    }
}

- (IBAction) playBtnClick:(id)sender
{
    if (!_hasMp4)
    {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:@"Now mp4 file found"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles: nil];
        [alert show];
        [alert release];
        return;
    }
    
    MPMoviePlayerViewController* playerView = [[MPMoviePlayerViewController alloc] initWithContentURL:[NSURL URLWithString:[NSString stringWithFormat:@"file://localhost/private%@", _mp4Path]]];
    NSLog(@"%@",[NSString stringWithFormat:@"file://localhost/private%@", _mp4Path]);
    [self presentModalViewController:playerView animated:YES];
    [playerView release];
}

#pragma mark - private Method

- (NSInteger) getFileSize:(NSString*) path
{
    NSFileManager * filemanager = [[[NSFileManager alloc]init] autorelease];
    if([filemanager fileExistsAtPath:path]){
        NSDictionary * attributes = [filemanager attributesOfItemAtPath:path error:nil];
        NSNumber *theFileSize;
        if ( (theFileSize = [attributes objectForKey:NSFileSize]) )
            return  [theFileSize intValue]/1024;
        else
            return -1;
    }
    else
    {
        return -1;
    }
}

- (CGFloat) getVideoDuration:(NSURL*) URL
{
    NSDictionary *opts = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO]
                                                     forKey:AVURLAssetPreferPreciseDurationAndTimingKey];
    AVURLAsset *urlAsset = [AVURLAsset URLAssetWithURL:URL options:opts];
    float second = 0;
    second = urlAsset.duration.value/urlAsset.duration.timescale;
    return second;
}

- (void) convertFinish
{
    [_alert dismissWithClickedButtonIndex:0 animated:YES];
    CGFloat duration = [[NSDate date] timeIntervalSinceDate:_startDate];
    _alert = [[UIAlertView alloc] initWithTitle:@"Finish"
                                        message:[NSString stringWithFormat:@"Successful, it takes %.2fs", duration]
                                       delegate:nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles: nil];
    [_alert show];
    [_alert release];
    
    _convertTime.text = [NSString stringWithFormat:@"%.2f s", duration];
    _mp4Size.text = [NSString stringWithFormat:@"%d kb", [self getFileSize:_mp4Path]];
    _hasMp4 = YES;
}

#pragma mark - UIViewController Life Style

- (void)viewDidLoad
{
    [super viewDidLoad];
    _qualityType = UIImagePickerControllerQualityTypeLow;
    _mp4Quality = AVAssetExportPresetLowQuality;
    _hasVideo = NO;
    _hasMp4 = NO;
}

- (void) viewDidUnload
{
    [_videoURL release];
    [_mp4Path release];
    [_startDate release];
    [super viewDidUnload];
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    _videoURL = [info[UIImagePickerControllerMediaURL] retain];
    _fileSize.text = [NSString stringWithFormat:@"%d kb", [self getFileSize:[[_videoURL absoluteString] substringFromIndex:16]]];
    _videoLen.text = [NSString stringWithFormat:@"%.0f s", [self getVideoDuration:_videoURL]];
    _hasVideo = YES;
    [self dismissModalViewControllerAnimated:YES];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissModalViewControllerAnimated:YES];
}


@end
