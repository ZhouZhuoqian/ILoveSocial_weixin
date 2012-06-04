//
//  NewFeedPhotoHeader.h
//  SocialFusion
//
//  Created by Air MacBook on 12-6-2.
//  Copyright (c) 2012年 TJU. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NewFeedRootData+Addition.h"
@interface NewFeedPhotoHeader : UIView



- (IBAction)didClickHeader:(id)sender;
- (IBAction)didClickRepost:(id)sender;

- (void)configureCell:(NewFeedRootData*)feedData ;

@property (retain, nonatomic) IBOutlet UIImageView *_headerImageView;
@property (retain, nonatomic) IBOutlet UILabel *_timeLabel;
@property (retain, nonatomic) IBOutlet UILabel *_userNameLabel;
@property (retain, nonatomic) IBOutlet UIImageView *_headFrameImageView;
@property (retain, nonatomic) IBOutlet UIButton *_repostButton;
@property (retain, nonatomic) IBOutlet UIButton *_headButton;

@end
