//
//  NewFeedPhotoCell.m
//  SocialFusion
//
//  Created by nobby heell on 6/1/12.
//  Copyright (c) 2012 TJU. All rights reserved.
//

#import "NewFeedPhotoCell.h"
#import <QuartzCore/QuartzCore.h>

#import "CommonFunction.h"
#import "NewFeedBlog+NewFeedBlog_Addition.h"
#import "NewFeedUploadPhoto+Addition.h"
#import "NewFeedListController.h"
#import "Base64Transcoder.h"
#import "NSData+NSData_Base64.m"
#import "NSString+DataURI.h"
#import "NewFeedShareAlbum+Addition.h"
#import "NewFeedSharePhoto+Addition.h"
#import "NewFeedData+NewFeedData_Addition.h"
#import "Image+Addition.h"
//#import "CardBrowserViewController.h"
#import "UIImageView+Addition.h"
#define PHOTO_FRAME_SIDE_LENGTH 200.0f


@implementation NewFeedPhotoCell
@synthesize _userNameLabel;
@synthesize captainLabel;
@synthesize _headFrameImageView;
@synthesize imageView;
@synthesize _headImageView;
@synthesize managedObjectContext;



- (void)setList:(NewFeedListOfImageController*)list{
    
}


- (void)dealloc {
    self.imageView = nil;
    self._headImageView = nil;
    self._userNameLabel = nil;
    self.captainLabel = nil;

    [_headFrameImageView release];
    [super dealloc];
}

- (IBAction)selectUser:(id)sender {
    NSLog(@"select user");
}

- (IBAction)repost:(id)sender {
    NSLog(@"repost");

}

-(void )loadImage: (UIImageView*)imageview withImageUrl:(NSString * )url  {
    if (url ) {
        
        
        imageview.image= [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:url]]];
        [imageview centerizeWithSideLength:PHOTO_FRAME_SIDE_LENGTH];
        [imageview  fadeIn];

        return;
        
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


- (void)configureCell:(NewFeedRootData*)feedData  first:(BOOL)bol
{    
    NSLog(@"___________configure cell");
    
//    _photoData=nil;
    
//    [_time setText:[CommonFunction getTimeBefore:[feedData getDate]]];
    
    self._userNameLabel.text  =[feedData getAuthorName] ;
    
    if (bol==YES)
    {
        [self.imageView setImage:nil];
    }
    if ([feedData getStyle] == 0)
    {
         self._headFrameImageView.image=[UIImage imageNamed:@"head_renren.png"] ;
    }
    else
    {
        self._headFrameImageView.image=[UIImage imageNamed:@"head_wb.png"] ;
    }

    self.imageView.image=[UIImage imageNamed:@"photo_default.png"] ;
    
    
    
    

    
    NSString * imageUrl  =     [feedData    owner_Head];    
    self._headImageView.image= [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:imageUrl]]];

    
    if ([feedData class] == [NewFeedShareAlbum class]){

        imageUrl =  [(NewFeedShareAlbum*)feedData photo_url];
//        self.imageView.image= [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:imageUrl]]];
        [self loadImage:self.imageView withImageUrl:imageUrl];
        
    } else if ([feedData class] == [NewFeedSharePhoto class]){
        
        imageUrl =  [(NewFeedSharePhoto*)feedData photo_url];
//        self.imageView.image= [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:imageUrl]]];
        [self loadImage:self.imageView withImageUrl:imageUrl];


    } else if ([feedData class] == [NewFeedUploadPhoto class])
    {
        
        imageUrl =  [(NewFeedUploadPhoto*)feedData photo_url];
        imageUrl =  [(NewFeedUploadPhoto*)feedData photo_big_url];
//        self.imageView.image= [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:imageUrl]]];
        [self loadImage:self.imageView withImageUrl:imageUrl];

    } else if ([feedData class] == [NewFeedData class])
    {
        
        imageUrl =         ((NewFeedData*)feedData).pic_URL;
        
        if (imageUrl!=nil){
            
//            self.imageView.image= [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:imageUrl]]];
            [self loadImage:self.imageView withImageUrl:imageUrl];

        }
        
    }

    
    return;
   
    
    
    if ([feedData class] == [NewFeedShareAlbum class])
    {
        
        NSString* outString = [(NewFeedShareAlbum*)feedData getShareComment];
        
        outString = [(NewFeedShareAlbum*)feedData getAubumName];
        
        outString = [(NewFeedShareAlbum*)feedData getAblbumQuantity];
         
        outString = [(NewFeedShareAlbum*)feedData getFromName];
         
        NSString * commentCountString =         [NSString stringWithFormat:@"评论:%d",[feedData.comment_Count intValue]];

    }
    else if ([feedData class] == [NewFeedSharePhoto class])
    {
        
        NSString* outString = [(NewFeedSharePhoto*)feedData getShareComment];
        [feedData.style intValue];
        
        [NSString stringWithFormat:@"setWeibo('%@')",outString];
        
        outString = [(NewFeedSharePhoto*)feedData getPhotoComment];

        
        [NSString stringWithFormat:@"setComment('%@')",outString];
        
        outString = [(NewFeedSharePhoto*)feedData getTitle];
        [feedData.style intValue];
        
        
        [NSString stringWithFormat:@"setAlbumName('%@')",outString];
        
        outString = [(NewFeedSharePhoto*)feedData getFromName];
        [feedData.style intValue];
        
        
    }
    else if ([feedData class] == [NewFeedUploadPhoto class])
    {
        NSString* outString = [(NewFeedUploadPhoto*)feedData getName];
        
        
        [NSString stringWithFormat:@"setWeibo('%@')",outString];
        
        outString = [(NewFeedUploadPhoto*)feedData getPhoto_Comment];

        
        [NSString stringWithFormat:@"setDetailComment('%@')",outString];
        
        outString = [(NewFeedUploadPhoto*)feedData getTitle];
        
        [feedData.style intValue];
        
        [NSString stringWithFormat:@"setTitle('%@')", outString];
        
        [NSString stringWithFormat:@"setCommentCount('评论:%d')",[feedData.comment_Count intValue]];
        
        [NSString stringWithFormat:@"resetPhoto()"];
        
    }
    else if ([feedData class] == [NewFeedData class])
    {
        if (((NewFeedData*)feedData).repost_ID==nil)
        {
            
            NSString* outString = [(NewFeedData*)feedData getName];
            
            
            [NSString stringWithFormat:@"setWeibo('%@')",outString];
            
            [NSString stringWithFormat:@"setCommentCount('评论:%d')",[feedData.comment_Count intValue]];
            
            if (((NewFeedData*)feedData).pic_URL!=nil)
            {
                [NSString stringWithFormat:@"resetPhoto()"];
            }
            
        }
        else
        {
            NSString* outString = [(NewFeedData*)feedData getName];
            [NSString stringWithFormat:@"setWeibo('%@')",outString];
            outString = [(NewFeedData*)feedData getPostMessage];
            [NSString stringWithFormat:@"setRealRepost('%@')",outString];
            [NSString stringWithFormat:@"setCommentCount('评论:%d')",[feedData.comment_Count intValue]];
            if (((NewFeedData*)feedData).pic_URL!=nil)
            {
                [NSString stringWithFormat:@"resetPhoto()"];
            }
            
        }
    }
    
       
}



@end
