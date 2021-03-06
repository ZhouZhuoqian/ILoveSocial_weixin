//
//  WeiboUserInfoViewController.h
//  SocialFusion
//
//  Created by 王紫川 on 12-2-17.
//  Copyright (c) 2012年 Tongji Apple Club. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserInfoViewController.h"

@interface WeiboUserInfoViewController : UserInfoViewController

@property (nonatomic, retain) IBOutlet UILabel *blogLabel;
@property (nonatomic, retain) IBOutlet UITextView *descriptionTextView;
@property (nonatomic, retain) IBOutlet UILabel *locationLabel;

@property (nonatomic, retain) IBOutlet UILabel *statusCountLabel;
@property (nonatomic, retain) IBOutlet UILabel *followerCountLabel;
@property (nonatomic, retain) IBOutlet UILabel *friendCountLabel;

@property (nonatomic, retain) IBOutlet UIButton *statusCountButton;
@property (nonatomic, retain) IBOutlet UIButton *followerCountButton;
@property (nonatomic, retain) IBOutlet UIButton *friendCountButton;

- (IBAction)didClickFollowButton;
- (IBAction)didClickBasicInfoButton:(id)sender;
- (IBAction)didClickHomePageButton:(id)sender ;

- (IBAction)didClickPhotoFrameButton_1 ;
- (IBAction)didClickPhotoFrameButton_2 ;
- (IBAction)didClickPhotoFrameButton_3 ;
- (IBAction)didClickPhotoFrameButton_4 ;

//- (void )loadImage: (UIImageView*)imageview withImageUrl:(NSString * )url  ;

@end
