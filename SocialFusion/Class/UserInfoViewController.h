//
//  UserInfoViewController.h
//  SocialFusion
//
//  Created by 王紫川 on 12-2-12.
//  Copyright (c) 2012年 Tongji Apple Club. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreDataViewController.h"
#import "User.h"
#import "DetailImageViewController.h"

typedef enum {
    kRenrenUserInfo = 0,
    kWeiboUserInfo  = 1,
} kUserInfoType;

@interface UserInfoViewController : CoreDataViewController {

}

@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;
@property (nonatomic, retain) IBOutlet UIImageView *photoImageView;
@property (nonatomic, retain) IBOutlet UIImageView *photoImageView_1;
@property (nonatomic, retain) IBOutlet UIImageView *photoImageView_2;
@property (nonatomic, retain) IBOutlet UIImageView *photoImageView_3;
@property (nonatomic, retain) IBOutlet UIImageView *photoImageView_4;
@property (nonatomic, retain) IBOutlet UIView *photoView;
@property (retain, nonatomic) IBOutlet UIButton *leaveMessageButton;
@property (nonatomic, retain) IBOutlet UILabel *genderLabel;
@property (nonatomic, retain) IBOutlet UIButton *followButton;
@property (nonatomic, retain) IBOutlet UIButton *atButton;

@property (nonatomic, retain) IBOutlet UILabel *relationshipLabel;
@property (nonatomic, retain) IBOutlet UILabel *nameLabel;

@property (nonatomic, readonly) User *processUser;
@property (nonatomic, readonly) NSString *headImageURL;
@property (nonatomic, readonly) NSString *processUserGender;
@property (retain,nonatomic)   DetailImageViewController *bigImagevc ;

@property (retain , nonatomic) NSString * _bigURL_1;
@property (retain , nonatomic) NSString * _bigURL_2;
@property (retain , nonatomic) NSString * _bigURL_3;
@property (retain , nonatomic) NSString * _bigURL_4;

@property (retain,nonatomic) NSString * _thumbnailURL_1;
@property (retain,nonatomic) NSString * _thumbnailURL_2;
@property (retain,nonatomic) NSString * _thumbnailURL_3;
@property (retain,nonatomic) NSString * _thumbnailURL_4;


- (id)initWithType:(kUserInfoType)type;
+ (UserInfoViewController *)getUserInfoViewControllerWithType:(kUserInfoType)type;

- (void)configureUI;
- (IBAction)didClickAtButton;
- (IBAction)didClickPhotoFrameButton;
-(void)cacheImage:(NSString *)urlString;
-(void)cacheImage:(NSString *)urlString withPreview:(NSString *)previewUrlString;

-(void )loadImage: (UIImageView*)imageview withImageUrl:(NSString * )url  ;
-(void)processData : (NSArray *)array;


@end
