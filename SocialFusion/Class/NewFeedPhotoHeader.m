//
//  NewFeedPhotoHeader.m
//  SocialFusion
//
//  Created by Air MacBook on 12-6-2.
//  Copyright (c) 2012年 TJU. All rights reserved.
//

#import "NewFeedPhotoHeader.h"

@implementation NewFeedPhotoHeader
@synthesize _timeLabel;
@synthesize _userNameLabel;
@synthesize _headFrameImageView;
@synthesize _headerImageView;


-(void)awakeFromNib{    
    
    NSLog(@"awake from nib");
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)dealloc {
    [_headerImageView release];
    [_timeLabel release];
    [_userNameLabel release];
    [_headFrameImageView release];
    [super dealloc];
}




#pragma mark - ib action

- (IBAction)didClickHeader:(id)sender {
}

- (IBAction)didClickRepost:(id)sender {
}
@end
