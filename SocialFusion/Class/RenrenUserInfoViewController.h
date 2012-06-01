//
//  RenrenUserInfoViewController.h
//  SocialFusion
//
//  Created by 王紫川 on 12-2-17.
//  Copyright (c) 2012年 Tongji Apple Club. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserInfoViewController.h"
#import "MWPhotoBrowser.h"


@interface RenrenUserInfoViewController : UserInfoViewController <MWPhotoBrowserDelegate>

@property (nonatomic, retain) IBOutlet UILabel *birthDayLabel;
@property (nonatomic, retain) IBOutlet UILabel *hometownLabel;
@property (nonatomic, retain) IBOutlet UILabel *highSchoolLabel;
@property (nonatomic, retain) IBOutlet UILabel *universityLabel;
@property (nonatomic, retain) IBOutlet UILabel *companyLabel;
- (IBAction)didClickHomePageButton:(id)sender ;
- (IBAction)didClickPhotoFrameButton_1 ;
- (IBAction)didClickPhotoFrameButton_2 ;
- (IBAction)didClickPhotoFrameButton_3 ;
- (IBAction)didClickPhotoFrameButton_4 ;
//- (void )loadImage: (UIImageView*)imageview withImageUrl:(NSString * )url  ;

@end
