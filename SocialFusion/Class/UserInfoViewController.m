//
//  UserInfoViewController.m
//  SocialFusion
//
//  Created by 王紫川 on 12-2-12.
//  Copyright (c) 2012年 Tongji Apple Club. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "UserInfoViewController.h"
#import "RenrenUser+Addition.h"
#import "WeiboUser+Addition.h"
#import "RenrenUserInfoViewController.h"
#import "WeiboUserInfoViewController.h"
#import "UIImageView+Addition.h"
#import "Image+Addition.h"
#import "UIApplication+Addition.h"
#import "DetailImageViewController.h"
#import "NewStatusViewController.h"

#define PHOTO_FRAME_SIDE_LENGTH 100.0f

@interface UserInfoViewController(){
    kUserInfoType _type;

}
@end

@implementation UserInfoViewController

@synthesize scrollView = _scrollView;
@synthesize photoImageView = _photoImageView;
@synthesize photoView = _photoView;
@synthesize leaveMessageButton = _leaveMessageButton;
@synthesize genderLabel = _genderLabel;
@synthesize followButton = _followButton;
@synthesize atButton = _atButton;
@synthesize relationshipLabel = _relationshipLabel;
@synthesize nameLabel = _nameLabel;

@synthesize photoImageView_1;
@synthesize photoImageView_2;
@synthesize photoImageView_3;
@synthesize photoImageView_4;
@synthesize bigImagevc;

@synthesize _bigURL_1,_bigURL_2,_bigURL_3,_bigURL_4;
@synthesize _thumbnailURL_1, _thumbnailURL_2, _thumbnailURL_3, _thumbnailURL_4;


- (void)dealloc {
    
    
    self.bigImagevc = nil;
    
    self._bigURL_4 = nil;
    self._bigURL_3 = nil;
    
    self._bigURL_1 = nil;   
    self._bigURL_2 = nil;
    
    self._thumbnailURL_1 = nil;
    self._thumbnailURL_2 = nil;
    self._thumbnailURL_3 = nil;
    self._thumbnailURL_4 = nil;
    
    self.photoImageView_1 = nil;
    self.photoImageView_2 = nil;
    self.photoImageView_3 = nil;
    self.photoImageView_4 = nil;

    self.scrollView = nil;
    self.photoImageView = nil;
    self.photoView = nil;
    self.leaveMessageButton = nil;
    self.genderLabel = nil;
    self.followButton = nil;
    self.atButton = nil;
    self.relationshipLabel = nil;
    self.nameLabel = nil;
    
    [super dealloc];
}

- (void)viewDidUnload
{
     [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.leaveMessageButton = nil;
    self.scrollView = nil;
    self.photoImageView = nil;
    self.genderLabel = nil;
    self.photoView = nil;
    self.followButton = nil;
    self.atButton = nil;
    self.relationshipLabel = nil;
    self.nameLabel = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width, self.scrollView.frame.size.height + 1);
    
    self.photoView.layer.masksToBounds = YES;
    self.photoView.layer.cornerRadius = 5.0f;
    
    self.relationshipLabel.text = nil;
    
    self.scrollView.scrollsToTop = NO;
}

+ (UserInfoViewController *)getUserInfoViewControllerWithType:(kUserInfoType)type {
    UserInfoViewController *vc;
    if(type == kRenrenUserInfo)
        vc = [[[RenrenUserInfoViewController alloc] initWithType:type] autorelease];
    else if(type == kWeiboUserInfo)
        vc = [[[WeiboUserInfoViewController alloc] initWithType:type] autorelease];
    return vc;
}

- (id)initWithType:(kUserInfoType)type {
    self = [super init];
    if(self) {
        _type = type;
    }
    return self;
}

- (void)configureUI {
    self.nameLabel.text = self.processUser.name;
    
    if(self.photoImageView.image == nil) {
        Image *image = [Image imageWithURL:self.headImageURL inManagedObjectContext:self.managedObjectContext];
        if (image == nil) {
            [self.photoImageView loadImageFromURL:self.headImageURL completion:^{
                [self.photoImageView centerizeWithSideLength:PHOTO_FRAME_SIDE_LENGTH];
                [self.photoImageView fadeIn];
            } cacheInContext:self.managedObjectContext];
        }
        else {
            self.photoImageView.image = [UIImage imageWithData:image.imageData.data];
            [self.photoImageView centerizeWithSideLength:PHOTO_FRAME_SIDE_LENGTH];
        }
    }
    
    if([self.processUserGender isEqualToString:@"m"]) 
        self.genderLabel.text = @"男";
    else if([self.processUserGender isEqualToString:@"f"]) 
        self.genderLabel.text = @"女";
    else
        self.genderLabel.text = @"未知";
}

#pragma mark -
#pragma mark IBActions

- (IBAction)didClickAtButton {
    NewStatusViewController *vc = [[NewStatusViewController alloc] init];
    vc.managedObjectContext = self.managedObjectContext;
    vc.processUser = self.processUser;
    [[UIApplication sharedApplication] presentModalViewController:vc];
    [vc release];
}

- (IBAction)didClickPhotoFrameButton {
    if(self.photoImageView.image) {
        [DetailImageViewController showDetailImageWithImage:self.photoImageView.image];
    }
}

- (User *)processUser {
    return nil;
}

- (NSString *)headImageURL {
    return nil;
}

- (NSString *)processUserGender {
    return nil;
}

 

-(void)cacheImage:(NSString *)urlString withPreview:(NSString *)previewUrlString{
    
    Image *image_ = [Image imageWithURL: urlString inManagedObjectContext:self.managedObjectContext];
    
    if (image_ == nil) {
        
        Image *image = [Image imageWithURL: previewUrlString inManagedObjectContext:self.managedObjectContext];
        if (image ){
            if (self.bigImagevc) {
                self.bigImagevc = nil;
            }
            self.bigImagevc =  [DetailImageViewController showDetailImageWithImageFillScreen: [UIImage imageWithData:image.imageData.data] ];    
            
        }
    }
    
    [self cacheImage:urlString];
    
}

-(void)cacheImage:(NSString *)urlString{
    
    if (urlString && urlString.length > 0 ) {
        
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
                            
                            if (self.bigImagevc) {
                                [self.bigImagevc setImage:img];
                            }else{

                                self.bigImagevc = nil;
                                self.bigImagevc = 
                                [DetailImageViewController showDetailImageWithImage:    img ];
                                
                            }
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
    
    
}


-(void )loadImage: (UIImageView*)imageview withImageUrl:(NSString * )url  {
    if (url ) {
        
        Image *image = [Image imageWithURL:url inManagedObjectContext:self.managedObjectContext];
        
        if (image == nil){
            [imageview loadImageFromURL:url completion:^{
                [imageview centerizeWithSideLength:PHOTO_FRAME_SIDE_LENGTH];
                [imageview  fadeIn];
            } cacheInContext:self.managedObjectContext];
        }else{
            [imageview setImage: [UIImage imageWithData:image.imageData.data]];
            [imageview centerizeWithSideLength:PHOTO_FRAME_SIDE_LENGTH];
        }
    }
    
}

-(void)processData : (NSArray *)array{
    
    int i = 0;
    
    for(NSDictionary *dict in array) {
        
        if (i>3) {
            break;
        }
        NSString *url ;
        NSString *middleUrl ;
        
        if (_type == kRenrenUserInfo) {
            
            url = [dict objectForKey:@"url_head"];
            middleUrl = [dict objectForKey:@"url_large"];

        }else{
            // weibo
            url =   [dict objectForKey:@"thumbnail_pic"];
            middleUrl = [dict objectForKey:@"bmiddle_pic"];
            
        }
        
        
        if (url && middleUrl) {
//            NSLog(@"%d", i);
            //            _thumbnailURL[i]= url;
            //            _bigURL[i]=   [[NSString alloc] initWithString:middleUrl];
            
            [dict objectForKey:@"bmiddle_pic"];
            [dict objectForKey:@"original_pic"];
            
            if (i  ==  0 ) {
                self._thumbnailURL_1 = url;
                self._bigURL_1 = middleUrl;
                
                [self loadImage:self.photoImageView_1 withImageUrl:url];
            }else if (i  ==  1 ) {
                self._thumbnailURL_2 = url;
                self._bigURL_2 = middleUrl;
                
                [self loadImage:self.photoImageView_2 withImageUrl:url];
            }else if (i  ==  2 ) {
                
                self._thumbnailURL_3 = url;
                self._bigURL_3 = middleUrl;
                
                [self loadImage:self.photoImageView_3 withImageUrl:url];
            }else if (i  ==  3 ) {
                
                self._thumbnailURL_4 = url;
                self._bigURL_4 = middleUrl;
                
                [self loadImage:self.photoImageView_4 withImageUrl:url];
            }
            
            i++;
        }
        
    }
}




@end
