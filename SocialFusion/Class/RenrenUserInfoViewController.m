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

@interface RenrenUserInfoViewController(){
    NSString * _bigURL[4] ;
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
    for (int i=0;i<    sizeof(_bigURL)   ;i++)
    {
        [_bigURL[i]  release];
    }
    
    [_birthDayLabel release];
    [_hometownLabel release];
    [_companyLabel release];
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
    
    [self getLastestAlbum];   
    
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
            int i = 0;
            for(NSDictionary *dict in array) {
                if (i  >  3 ) {
                    break;
                }
                Image *image = [Image imageWithURL:[dict objectForKey:@"url_head"] inManagedObjectContext:self.managedObjectContext];
                if (image == nil)
                {
                    if (i  ==  0 ) {
                        [self.photoImageView_1 loadImageFromURL:[dict objectForKey:@"url_head"] completion:^{
                            [self.photoImageView_1  fadeIn];
                        } cacheInContext:self.managedObjectContext];
                    }
                    if (i  ==  1 ) {
                        [self.photoImageView_2 loadImageFromURL:[dict objectForKey:@"url_head"] completion:^{
                            [self.photoImageView_2  fadeIn];
                        } cacheInContext:self.managedObjectContext];
                    }
                    if (i  ==  2 ) {
                        [self.photoImageView_3 loadImageFromURL:[dict objectForKey:@"url_head"] completion:^{
                            [self.photoImageView_3  fadeIn];
                        } cacheInContext:self.managedObjectContext];
                    }
                    if (i  ==  3 ) {
                        [self.photoImageView_4 loadImageFromURL:[dict objectForKey:@"url_head"] completion:^{
                            [self.photoImageView_4  fadeIn];
                        } cacheInContext:self.managedObjectContext];
                    }
                }
                else
                {
                    
                    if (i  ==  0 ) {
                        [self.photoImageView_1 setImage: [UIImage imageWithData:image.imageData.data]];
                    }
                    if (i  ==  1 ) {
                        [self.photoImageView_2 setImage: [UIImage imageWithData:image.imageData.data]];
                    }
                    if (i  ==  2 ) {
                        [self.photoImageView_3 setImage: [UIImage imageWithData:image.imageData.data]];
                    }
                    if (i  ==  3 ) {
                        [self.photoImageView_4 setImage: [UIImage imageWithData:image.imageData.data]];
                    }
                    
                }
                //                [_photoInAlbum[i].captian setText:[dict objectForKey:@"caption"]];
                //                _photoID[i]=[[NSString alloc ] initWithString:[[dict objectForKey:@"pid"] stringValue]];
                _bigURL[i]=[[NSString alloc] initWithString:[dict objectForKey:@"url_large"]];
                
                i++;
            } 
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

-(void)cacheImage:(NSString *)urlString{
    
    Image *image = [Image imageWithURL: urlString inManagedObjectContext:self.managedObjectContext];

     if (image == nil)
    {
        if(urlString && urlString.length > 0) {
            NSURL *url = [NSURL URLWithString:urlString];    
            dispatch_queue_t downloadQueue = dispatch_queue_create("downloadImageQueue", NULL);
            
            dispatch_async(downloadQueue, ^{ 
                //NSLog(@"download image:%@", urlString);
                NSData *imageData = [NSData dataWithContentsOfURL:url];
                if(!imageData) {
                    // NSLog(@"download image failed:%@", urlString);
                    return;
                }
                UIImage *img = [UIImage imageWithData:imageData];
                dispatch_async(dispatch_get_main_queue(), ^{
                    if([Image imageWithURL:urlString inManagedObjectContext:self.managedObjectContext] == nil) {
                        [Image insertImage:imageData withURL:urlString inManagedObjectContext:self.managedObjectContext];
//                         self.image = img;
                        [DetailImageViewController showDetailImageWithImage:    img ];
                     }
                });
            });
            dispatch_release(downloadQueue);
        }
    }
    else
    {
        [DetailImageViewController showDetailImageWithImage: [UIImage imageWithData:image.imageData.data] ];
        
    }

}
- (IBAction)didClickPhotoFrameButton_1 {
    
    
    if (isFlip) {
        
        [self cacheImage:_bigURL[0]];
        return;
        
        if(_bigURL[0] && _bigURL[0].length > 0) {
            UIImage * bigImage =  [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:_bigURL[0]]]];
            [DetailImageViewController showDetailImageWithImage:    bigImage ];
        }
    }else{
        [self didClickPhotoFrameButton___];
    }
    
}

- (IBAction)didClickPhotoFrameButton_2 {
    if (isFlip) {
        
        [self cacheImage:_bigURL[1]];
        return;
        
        if(_bigURL[1] && _bigURL[1].length > 0) {
            UIImage * bigImage =  [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:_bigURL[1]]]];
            [DetailImageViewController showDetailImageWithImage:    bigImage ];
        }
    }else{
        [self didClickPhotoFrameButton___];
    }
    
}

- (IBAction)didClickPhotoFrameButton_3 {
    
    if (isFlip) {
        
        [self cacheImage:_bigURL[2]];
        return;
        
        if(_bigURL[2] && _bigURL[2].length > 0) {
            UIImage * bigImage =  [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:_bigURL[2]]]];
            [DetailImageViewController showDetailImageWithImage:    bigImage ];
        }
    }else{
        [self didClickPhotoFrameButton___];
    }
    
}

- (IBAction)didClickPhotoFrameButton_4 {
    if (isFlip) {
        
        [self cacheImage:_bigURL[3]];
        return;
        
        if(_bigURL[3] && _bigURL[3].length > 0) {
            UIImage * bigImage =  [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:_bigURL[3]]]];
            [DetailImageViewController showDetailImageWithImage:    bigImage ];
        }
    }else{
        [self didClickPhotoFrameButton___];
    }
    
}


#pragma mark - MWPhotoBrowserDelegate

- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser {
    return sizeof(_bigURL);
}

- (MWPhoto *)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    if (index < sizeof(_bigURL) && _bigURL[index] && _bigURL[index].length >0 ){
        return  [MWPhoto photoWithURL:[NSURL URLWithString:  _bigURL[index] ]];
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
