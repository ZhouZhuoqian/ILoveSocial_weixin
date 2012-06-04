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
#import "DetailImageViewController.h"
#import "RenrenClient.h"
#import "WeiboClient.h"

#define PHOTO_FRAME_SIDE_LENGTH 289.0f


@implementation NewFeedPhotoCell

@synthesize _commentTextView;
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
     [_commentTextView release];
    [super dealloc];
}

- (IBAction)selectUser:(id)sender {
    NSLog(@"select user");
}

- (IBAction)repost:(id)sender {
    NSLog(@"repost");

}

- (IBAction)didClickImageView:(id)sender {
    NSLog(@"did click imageview");
    [DetailImageViewController showDetailImageWithImage:    self.imageView.image ];

}

-(void )loadImage: (UIImageView*)imageview withImageUrl:(NSString * )url  andThumbImageUrl:(NSString * )thumbUrl  {
    
    Image *image_ = nil;
    if (url) {
        image_ = [Image imageWithURL: url inManagedObjectContext:self.managedObjectContext];
    }

    if (image_ == nil) {
        UIImage *thumbimage = 
        [UIImage imageWithData: [NSData dataWithContentsOfURL:[NSURL URLWithString:thumbUrl]]];
        [imageview setImage: thumbimage];
        [imageview centerizeWithSideLengthAndFillScreen:PHOTO_FRAME_SIDE_LENGTH];
        
        
        if (url) {
            
            NSURL *url__ = [NSURL URLWithString:url];    
            dispatch_queue_t downloadQueue = dispatch_queue_create("downloadImageQueue", NULL);
            
            dispatch_async(downloadQueue, ^{ 
                //NSLog(@"download image:%@", urlString);
                NSData *imageData = [NSData dataWithContentsOfURL:url__];
                if(!imageData) {
                    // NSLog(@"download image failed:%@", urlString);
                    return;
                }
                UIImage *img = [UIImage imageWithData:imageData];
                dispatch_async(dispatch_get_main_queue(), ^{
                    if([Image imageWithURL:url inManagedObjectContext:self.managedObjectContext] == nil) {
                        
                        [Image insertImage:imageData withURL:url inManagedObjectContext:self.managedObjectContext];
                        [imageview setImage: img];
                        [imageview centerizeWithSideLengthAndFillScreen:PHOTO_FRAME_SIDE_LENGTH];
                        
                        
                    }
                });
            });
            dispatch_release(downloadQueue);
        }
        
        
    }else{
        
        [imageview setImage: [UIImage imageWithData:image_.imageData.data]];
        [imageview centerizeWithSideLengthAndFillScreen:PHOTO_FRAME_SIDE_LENGTH];
        
    }

}


-(void )loadImage: (UIImageView*)imageview withImageUrl:(NSString * )url  {
    if (url ) {
        if (0) {
            imageview.image= [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:url]]];
            [imageview centerizeWithSideLengthAndFillScreen:PHOTO_FRAME_SIDE_LENGTH];        
            [imageview  fadeIn];
            
            return;
            
        }
    
        
        Image *image = [Image imageWithURL:url inManagedObjectContext:self.managedObjectContext];
        
        if (image == nil){
            [imageview loadImageFromURL:url completion:^{
                [imageview centerizeWithSideLengthAndFillScreen:PHOTO_FRAME_SIDE_LENGTH];
                [imageview  fadeIn];
            } cacheInContext:self.managedObjectContext];
        }else{
            [imageview setImage: [UIImage imageWithData:image.imageData.data]];
            [imageview centerizeWithSideLengthAndFillScreen:PHOTO_FRAME_SIDE_LENGTH];
        }
    }
    
}




- (NSString *)ProcessWeiboData:(NSArray*)array
{
    NSString * tmp = @"";
    int i = 0;
    for(NSDictionary *dict in array) {
        if (i>3) {
            break;
        }
        StatusCommentData* commentsData = [StatusCommentData insertNewComment:1 Dic:dict inManagedObjectContext:self.managedObjectContext];
        tmp = [NSString stringWithFormat:@"%@%@:%@", tmp , [commentsData owner_Name], [commentsData text]];
        i++;

    }

    return tmp;
}

-(void)getComments:(NewFeedRootData*)_feedData  {
    if ([_feedData getStyle] == 0)
    {
        RenrenClient *renren = [RenrenClient client];
        [renren setCompletionBlock:^(RenrenClient *client) {
            if(!client.hasError) {
                NSArray *array = client.responseJSONObject;
                self._commentTextView.text = [NSString stringWithFormat:@"%@%@",self._commentTextView.text,  [self ProcessWeiboData:array]];
            }
            
        }];
        [renren getComments:[_feedData getActor_ID] status_ID:[_feedData getSource_ID] pageNumber:1];
    }
    else
    {
        WeiboClient *weibo = [WeiboClient client];
        [weibo setCompletionBlock:^(WeiboClient *client) {
            if(!client.hasError) {
                NSArray *array = [client.responseJSONObject objectForKey:@"comments"];
                self._commentTextView.text = [NSString stringWithFormat:@"%@%@",self._commentTextView.text,  [self ProcessWeiboData:array]];
            }
        }];
        [weibo getCommentsOfStatus:[_feedData getSource_ID] page:1 count:10];
    }
}

- (void)configureCell:(NewFeedRootData*)feedData  first:(BOOL)bol
{    
     
//    _photoData=nil;
    
    if (bol==YES)
    {
        [self.imageView setImage:nil];
    }
    if ([feedData getStyle] == 0)
    {
         self._headFrameImageView.image=[UIImage imageNamed:@"head_renren.png"] ;
    } else {
        self._headFrameImageView.image=[UIImage imageNamed:@"head_wb.png"] ;
    }

    self.imageView.image=[UIImage imageNamed:@"photo_default.png"] ;
    self.captainLabel.text = [CommonFunction getTimeBefore:[feedData getDate]];
    
    NSString * imageUrl  = nil; 
    NSString * bigImageUrl  = nil;    
    NSString * authorCommentString = nil;
    NSString * commentsString ;
//    if ([feedData class] == [NewFeedShareAlbum class]){
//        imageUrl =  [(NewFeedShareAlbum*)feedData photo_url];
//        self._commentTextView.text =[(NewFeedShareAlbum*)feedData share_comment]  ;
//        NSString * currentText =  self._commentTextView.text ;
//        NSNumber *commentscount = [(NewFeedShareAlbum*)feedData comment_Count] ;
//        NSString * commentsString =   [NSString stringWithFormat:@"共有%i条评论" ,commentscount] ;
//        self._commentTextView.text  = [NSString stringWithFormat:@"%@\n%@" , currentText,  commentsString];
//    }else 
//    if ([feedData class] == [NewFeedSharePhoto class]){
//        
//        imageUrl =  [(NewFeedSharePhoto*)feedData photo_url];
//
//        self._commentTextView.text =[(NewFeedSharePhoto*)feedData getPhotoComment]  ;
//    } else 
    if ([feedData class] == [NewFeedUploadPhoto class])
    {
        imageUrl =  [(NewFeedUploadPhoto*)feedData photo_url];
        bigImageUrl =  [(NewFeedUploadPhoto*)feedData photo_big_url];
        authorCommentString = [(NewFeedUploadPhoto*)feedData photo_comment];
    } else 
    if ([feedData class] == [NewFeedData class])
    {
        imageUrl = ((NewFeedData*)feedData).pic_URL;
        bigImageUrl =  [(NewFeedData*)feedData pic_big_URL];
        authorCommentString = [(NewFeedData*)feedData message]  ;
    }
    
    //*********************************************

    
    if (authorCommentString) {
        commentsString =  [NSString stringWithFormat:@"%@: %@", [feedData getAuthorName],authorCommentString];
    }else{
        commentsString=  @"";
    }
    
    for(   StatusCommentData* commentsData in feedData.comments) {
//        NSLog(@"%@",commentsData);
        commentsString = [NSString stringWithFormat:@"%@\n%@:%@" , commentsString , [commentsData owner_Name] ,   [commentsData text]];
    }
    
    NSNumber *commentscount = [(NewFeedRootData*)feedData comment_Count] ;
    if ( commentscount.intValue >=3) {
        NSString * tmp =   [NSString stringWithFormat:@"共有%@条评论" ,commentscount] ;
       commentsString = [NSString stringWithFormat:@"%@\n%@" , tmp,  commentsString];
    }
    
    self._commentTextView.text = commentsString;
    self._userNameLabel.text  =[feedData getAuthorName] ;
    self._headImageView.image= [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:  [feedData    owner_Head]]]];
    [self loadImage:self.imageView withImageUrl:bigImageUrl andThumbImageUrl:imageUrl];

}



@end
