//
//  RenrenUserInfoViewController.m
//  SocialFusion
//
//  Created by 王紫川 on 12-2-17.
//  Copyright (c) 2012年 Tongji Apple Club. All rights reserved.
//

#import "RenrenUserInfoViewController.h"
#import "RenrenUser+Addition.h"
#import "RenrenClient.h"
#import "LabelConverter.h"
#import "NSNotificationCenter+Addition.h"
#import "Image+Addition.h"
#import "UIImageView+Addition.h"
#import "DetailImageViewController.h"
#define isFlip 1
#define PHOTO_FRAME_SIDE_LENGTH 65.0f


@interface RenrenUserInfoViewController(){

}
- (void)configureRelationshipUI;
-(void)getLastestAlbum;
-(void )getLastestPhotos: (long)aid;
@end

@implementation RenrenUserInfoViewController

@synthesize birthDayLabel = _birthDayLabel;
@synthesize hometownLabel = _hometownLabel;
@synthesize highSchoolLabel = _highSchoolLabel;
@synthesize universityLabel = _universityLabel;
@synthesize companyLabel = _companyLabel;

- (void)dealloc {
    
//    for (int i=0;i<    sizeof(_bigURL)   ;i++)
//    {      
//        [_bigURL[i] release];
//    }
        
    self.birthDayLabel = nil;
    self.hometownLabel = nil;
    self.highSchoolLabel = nil;
    self.universityLabel=  nil;
    self.companyLabel = nil;
    
    [super dealloc];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.birthDayLabel = nil;
    self.hometownLabel = nil;
    self.highSchoolLabel = nil;
    self.universityLabel = nil;
    self.companyLabel = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self configureUI];
    
    RenrenClient *renren = [RenrenClient client];
    [renren setCompletionBlock:^(RenrenClient *client) {
        if (!renren.hasError) {
            NSArray *result = client.responseJSONObject;
            NSDictionary* dict = [result lastObject];
            self.renrenUser = [RenrenUser insertUser:dict inManagedObjectContext:self.managedObjectContext];
            [self configureUI];
        };
    }];
    [renren getUserInfoWithUserID:self.renrenUser.userID];
    
 
    if ((self._thumbnailURL_1 && self._bigURL_1) || 
        (self._thumbnailURL_2 && self._bigURL_2) || 
        (self._thumbnailURL_3 && self._bigURL_3) || 
        (self._thumbnailURL_4 && self._bigURL_4) ) {
        
        
        [self loadImage:self.photoImageView_1 withImageUrl:self._thumbnailURL_1];
        [self loadImage:self.photoImageView_2 withImageUrl:self._thumbnailURL_2];
        [self loadImage:self.photoImageView_3 withImageUrl:self._thumbnailURL_3];
        [self loadImage:self.photoImageView_4 withImageUrl:self._thumbnailURL_4];
        
        
    }else{
        [self getLastestAlbum];   
    }
    
    
}

-(void)getLastestAlbum{
    
    RenrenClient *renren = [RenrenClient client];
    [renren setCompletionBlock:^(RenrenClient *client) {
        if(!client.hasError) {
            NSArray *array = client.responseJSONObject;
            for(NSDictionary *dict in array) {
                int size=[[dict objectForKey:@"size"] intValue];
                NSLog(@"size  =  %d", size);
                long aid=[[dict objectForKey:@"aid"] longValue];
                NSLog(@"aid  =  %ld", aid);
                [self getLastestPhotos: aid];
                break;
            } 
        }
    }];
    [renren getAlbumInfo:self.renrenUser.userID a_ID: @""];
    
}


-(void )getLastestPhotos: (long)aid{
    
    RenrenClient *renren = [RenrenClient client];
    [renren setCompletionBlock:^(RenrenClient *client) {
        if(!client.hasError) {
            NSArray *array = client.responseJSONObject;
            [self processData:array];

        }
    }];
    
    NSString * tmpString = [NSString stringWithFormat:@"%ld",aid];
    [renren getAlbum:self.renrenUser.userID a_ID:tmpString pageNumber:1];
    
}

-(void)didClickPhotoFrameButton___{
    
    MWPhotoBrowser *browser = [[MWPhotoBrowser alloc] initWithDelegate:self];
    browser.displayActionButton = YES;
    
    // Modal
    //*********
    //    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:browser];
    //    nc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    //    [self presentModalViewController:nc animated:YES];
    //    [nc release];
    
    //********
    self.view.alpha = 0;
    [[UIApplication sharedApplication].keyWindow addSubview:browser.view];
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    [UIView animateWithDuration:0.5f animations:^{
        self.view.alpha = 1;
    }];
    
    // Release
	[browser release];
    
}



- (IBAction)didClickPhotoFrameButton_1 {
    
    if (self._bigURL_1  && self._bigURL_1.length > 0) {
        [self cacheImage:self._bigURL_1 withPreview:self._thumbnailURL_1];
    }
    
    
}

- (IBAction)didClickPhotoFrameButton_2 {
//    if (isFlip) {
//         if(_bigURL[1] && _bigURL[1].length > 0) {
//            [self cacheImage:_bigURL[1]];
//          }
//    }else{
//        [self didClickPhotoFrameButton___];
//    }

    if (self._bigURL_2  && self._bigURL_2.length > 0) {
        [self cacheImage:self._bigURL_2 withPreview:self._thumbnailURL_2];
    }
    
}

- (IBAction)didClickPhotoFrameButton_3 {
    
    
    if (self._bigURL_3  && self._bigURL_3.length > 0) {
        [self cacheImage:self._bigURL_3 withPreview:self._thumbnailURL_3];
    }
    
}

- (IBAction)didClickPhotoFrameButton_4 {

    if (self._bigURL_4  && self._bigURL_4.length > 0) {
        [self cacheImage:self._bigURL_4 withPreview:self._thumbnailURL_4];
    }
    
    
}


#pragma mark - MWPhotoBrowserDelegate

- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser {
    return 4;
}

- (MWPhoto *)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    if (index < 4   ){
        
        switch (index) {
            case 0:
                return  [MWPhoto photoWithURL:[NSURL URLWithString:  self._bigURL_1]];
            case 1:
                return  [MWPhoto photoWithURL:[NSURL URLWithString:  self._bigURL_2]];

            case 2:
                return  [MWPhoto photoWithURL:[NSURL URLWithString:  self._bigURL_3]];

            case 3:
                return  [MWPhoto photoWithURL:[NSURL URLWithString:  self._bigURL_4]];
        }
    }
    return nil;
}



- (void)configureUI {
    [super configureUI];
    
    self.birthDayLabel.text = self.renrenUser.detailInfo.birthday;
    self.hometownLabel.text = self.renrenUser.detailInfo.hometownLocation;
    self.universityLabel.text = self.renrenUser.detailInfo.universityHistory;
    self.companyLabel.text = self.renrenUser.detailInfo.workHistory;
    self.highSchoolLabel.text = self.renrenUser.detailInfo.highSchoolHistory;
    self.nameLabel.text = self.renrenUser.name;
    [self configureRelationshipUI];
}

- (void)configureRelationshipUI
{
    if ([self.renrenUser isEqualToUser:self.currentRenrenUser]) {
        self.followButton.hidden = YES;
        self.relationshipLabel.text = @"当前人人网用户。";
        self.atButton.hidden = YES;
        self.leaveMessageButton.hidden = YES;
    }
    else {
        RenrenClient *client = [RenrenClient client];
        [client setCompletionBlock:^(RenrenClient *client) {
            if(!client.hasError) {
                NSArray *array = client.responseJSONObject;
                NSDictionary *dict = array.lastObject;
                NSString *isFriend = [[dict objectForKey:@"are_friends"] stringValue];
                if([isFriend isEqualToString:@"0"]) {
                    self.relationshipLabel.text = [NSString stringWithFormat:@"%@不是你的好友。", self.renrenUser.name];
                }
                else {
                    self.relationshipLabel.text = [NSString stringWithFormat:@"%@是你的好友。", self.renrenUser.name];
                }
            }
        }];
        [client getRelationshipWithUserID:self.renrenUser.userID andAnotherUserID:self.currentRenrenUser.userID];
    }
}

- (User *)processUser {
    return self.renrenUser;
}

- (NSString *)headImageURL {
    return self.renrenUser.detailInfo.mainURL;
}

- (NSString *)processUserGender {
    return self.renrenUser.detailInfo.gender;
}

- (IBAction)didClickHomePageButton:(id)sender {
    NSLog(@"home page pressed");
    
    NSString *identifier = nil;    
    identifier = kChildRenrenNewFeed ;
    
    [NSNotificationCenter postSelectChildLabelNotificationWithIdentifier:identifier];
}




@end
