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
#import "NSString+Addition.h"


#define PHOTO_FRAME_SIDE_LENGTH 289.0f

@interface NewFeedPhotoCell(){

}
@property (retain   ,nonatomic ) NSString * _bigImageUrl;
-(void)createPopupMenu:(UIView * )withinThisView;

@end

@implementation NewFeedPhotoCell

@synthesize _commentTextView;
@synthesize _userNameLabel;
@synthesize captainLabel;
@synthesize _headFrameImageView;
@synthesize _photoView;
@synthesize _headImageView;
@synthesize managedObjectContext;
@synthesize _feedData;
@synthesize _listController;
@synthesize _bigImageUrl;

- (void)setList:(NewFeedListOfImageController*)list{
    
}

-(void)awakeFromNib{
    NSLog(@"from nib");

}

- (void)dealloc {
    self._listController = nil;
    self._feedData = nil;
    self._photoView = nil;
    self._headImageView = nil;
    self._userNameLabel = nil;
    self.captainLabel = nil;

    
    [_headFrameImageView release];
     [_commentTextView release];
    [super dealloc];
}


- (IBAction)selectUser:(id)sender {

    NSIndexPath* indexpath = [_listController.tableView indexPathForCell:self];
    [_listController selectUser:indexpath];
    
}

- (IBAction)repost:(id)sender {
    NSLog(@"repost");
}

- (IBAction)didClickImageView:(id)sender {
    
    if ( [self._bigImageUrl isGifURL] ) {
        
        NSString* htmlStr = [NSString stringWithFormat:@"<html><head><link href=\"pocketsocial.css\" rel=\"stylesheet\" type=\"text/css\"/></head><body><div id=\"gifImg\"><span><img src=\"%@\" alt=""/></span></div></body></html>", self._bigImageUrl ];

        UIWebView * webView = [[UIWebView alloc]init];
        [webView loadHTMLString:htmlStr baseURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]]];
        
        webView.alpha = 0;
        [[UIApplication sharedApplication].keyWindow addSubview:webView];
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
        [UIView animateWithDuration:0.5f animations:^{
            webView.alpha = 1;
        }];
        [webView release];
        
        NSLog(@"gif!!!") ;
        
    }else{
        [DetailImageViewController showDetailImageWithImage:    self._photoView.image ];
    }

}

-(void )loadImageAndFillScreen: (UIImageView*)imageview withImageUrl:(NSString * )url  isBigImage:(BOOL) isBigImage isFillScreen:(BOOL) isFillScreen{
    
    if (url ) {
        
        
        if (isBigImage) {
            
            NSData *imgData = UIImageJPEGRepresentation(imageview.image, 0);
            NSLog(@"Size of Image(bytes):%d",[imgData length]);
            
            if ([imgData length] > 3000 ) {
                return;
            }
        }
        
        Image *image = [Image imageWithURL:url inManagedObjectContext:self.managedObjectContext];

        if (image == nil){
           
            [imageview loadImageFromURL:url completion:^{
 
                if (isFillScreen) {
                    if (isBigImage) {                        
                        [imageview centerizeWithSideLength:PHOTO_FRAME_SIDE_LENGTH];
                    }else{
                        [imageview centerizeWithSideLengthAndFillScreen:PHOTO_FRAME_SIDE_LENGTH];
                    }
                }
                [imageview  fadeIn];
            } cacheInContext:self.managedObjectContext];
                      
        }else{
            [imageview setImage: [UIImage imageWithData:image.imageData.data]];
            if (isFillScreen) {
                [imageview centerizeWithSideLengthAndFillScreen:PHOTO_FRAME_SIDE_LENGTH];
            }
            [imageview  fadeIn];
            
        }
        
    }
    
}

-(void )loadImageAndFillScreen: (UIImageView*)imageview withImageUrl:(NSString * )url  isBigImage:(BOOL) isBigImage{
    
    
    [self loadImageAndFillScreen:imageview withImageUrl:url isBigImage:isBigImage isFillScreen:YES];
}

-(void )loadHeadImage: (UIImageView*)headimageview withImageUrl:(NSString * )url  {
    
    [self loadImageAndFillScreen:headimageview withImageUrl:url isBigImage:NO isFillScreen:NO];
    
}

-(void )loadImage: (UIImageView*)imageview withImageUrl:(NSString * )url  andThumbImageUrl:(NSString * )thumbUrl isFirstTime:(BOOL) isFirstTime{
    
    Image *image_ = nil;
    if (url) {
        image_ = [Image imageWithURL: url inManagedObjectContext:self.managedObjectContext];
    }

    if (image_ == nil) {
        
        NSLog(@" // 如果大图不存在, 载入小 ");
        [self loadImageAndFillScreen:imageview withImageUrl:thumbUrl isBigImage:NO];

        if (url  ) {
            [self loadImageAndFillScreen:imageview withImageUrl:url isBigImage:YES];
        }
        
    }else{
        
        [imageview setImage: [UIImage imageWithData:image_.imageData.data]];
        [imageview centerizeWithSideLengthAndFillScreen:PHOTO_FRAME_SIDE_LENGTH];
        [imageview  fadeIn];
        
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
//        NSLog(@"%@", commentsData);
        tmp = [NSString stringWithFormat:@"%@%@:%@", tmp , [commentsData owner_Name], [commentsData text]];
    
        i++;

    }
    
    return tmp;
}

-(void)getComments:(NewFeedRootData*)data  {
    
    if ([data getStyle] == 0)
    {
        RenrenClient *renren = [RenrenClient client];
        [renren setCompletionBlock:^(RenrenClient *client) {
            if(!client.hasError) {
                NSArray *array = client.responseJSONObject;
                self._commentTextView.text = [NSString stringWithFormat:@"%@\n\n%@",self._commentTextView.text,  [self ProcessWeiboData:array]];
            }
            
        }];
        [renren getComments:[data getActor_ID] status_ID:[data getSource_ID] pageNumber:1];
    }
    else
    {
        WeiboClient *weibo = [WeiboClient client];
        [weibo setCompletionBlock:^(WeiboClient *client) {
            if(!client.hasError) {
                NSArray *array = [client.responseJSONObject objectForKey:@"comments"];
                self._commentTextView.text = [NSString stringWithFormat:@"%@\n\n%@",self._commentTextView.text,  [self ProcessWeiboData:array]];
            }
        }];
        [weibo getCommentsOfStatus:[data getSource_ID] page:1 count:10];
    }
    
}

-(void) moreTextViewHeight{
    
    NSInteger length =     self._commentTextView.text.length ;
    NSInteger line = length /19 + 1 ;
    NSLog(@"%i" , line);
    self._commentTextView.frame = CGRectMake( self._commentTextView.frame.origin.x, self._commentTextView.frame.origin.y, self._commentTextView.frame.size.width,  line * 30 );

}

- (void)configureCellImage:(NewFeedRootData*)feedData  first:(BOOL)bol
{    
    
    NSString * imageUrl  = nil; 

    NSString * authorCommentString = nil;
    NSString * commentsString ;
    if ([feedData class] == [NewFeedShareAlbum class]){
        imageUrl =  [(NewFeedShareAlbum*)feedData photo_url];
        self._commentTextView.text =[(NewFeedShareAlbum*)feedData share_comment]  ;
        NSString * currentText =  self._commentTextView.text ;
        NSNumber *commentscount = [(NewFeedShareAlbum*)feedData comment_Count] ;
        NSString * commentsString =   [NSString stringWithFormat:@"共有%i条评论" ,commentscount] ;
        self._commentTextView.text  = [NSString stringWithFormat:@"%@\n%@" , currentText,  commentsString];
    }else  if ([feedData class] == [NewFeedSharePhoto class]){
        
        self._commentTextView.text =[(NewFeedSharePhoto*)feedData getPhotoComment]  ;

        if ( !self._bigImageUrl || [self._bigImageUrl length] == 0) {
            RenrenClient *renren = [RenrenClient client];
            [renren setCompletionBlock:^(RenrenClient *client) {
                if(!client.hasError) {
                    NSArray *array = client.responseJSONObject;
                    for(NSDictionary *dict in array) {
                        
                        self._bigImageUrl = [dict objectForKey:@"url_large"];
                        [self loadImageAndFillScreen: self._photoView withImageUrl:  self._bigImageUrl isBigImage:YES];   
                        
                    } 
                }
            }];
            [renren getSinglePhoto:((NewFeedSharePhoto*)feedData).fromID photoID:((NewFeedSharePhoto*)feedData).mediaID ];
            
        }
       
                
    } else if ([feedData class] == [NewFeedUploadPhoto class]) {
        imageUrl =  [(NewFeedUploadPhoto*)feedData photo_url];

        authorCommentString = [(NewFeedUploadPhoto*)feedData photo_comment];
    } else  if ([feedData class] == [NewFeedData class]) {
        imageUrl = ((NewFeedData*)feedData).pic_URL;

        authorCommentString = [(NewFeedData*)feedData message]  ;
    }
    
    //*********************************************
    
    if (authorCommentString) {
        commentsString =  [NSString stringWithFormat:@"%@: %@", [feedData getAuthorName],authorCommentString];
    }else{
        commentsString=  @"";
    }
    
    NSNumber *commentscount = [(NewFeedRootData*)feedData comment_Count] ;
    if ( commentscount.intValue >=3) {
        NSString * tmp =   [NSString stringWithFormat:@"共有%@条评论" ,commentscount] ;
        commentsString = [NSString stringWithFormat:@"%@\n%@" , tmp,  commentsString];
    }
    
    [self getComments :feedData];
    
    [self loadImageAndFillScreen:self._photoView withImageUrl:self._bigImageUrl isBigImage:YES];

}

- (void)configureCell:(NewFeedRootData*)feedData  first:(BOOL)bol
{    
  
    self._feedData = feedData;
    if (bol==YES)
    {
        [self._photoView setImage:nil];
    }
    if ([feedData getStyle] == 0)
    {
         self._headFrameImageView.image=[UIImage imageNamed:@"head_renren.png"] ;
    } else {
        self._headFrameImageView.image=[UIImage imageNamed:@"head_wb.png"] ;
    }

    self._photoView.image=[UIImage imageNamed:@"photo_default.png"] ;
    self.captainLabel.text = [CommonFunction getTimeBefore:[feedData getDate]];
    
    NSString * imageUrl  = nil; 
  
    NSString * authorCommentString = nil;
    NSString * commentsString ;
    if ([feedData class] == [NewFeedShareAlbum class]){
        imageUrl =  [(NewFeedShareAlbum*)feedData photo_url];
        self._commentTextView.text =[(NewFeedShareAlbum*)feedData share_comment]  ;
        NSString * currentText =  self._commentTextView.text ;
        NSNumber *commentscount = [(NewFeedShareAlbum*)feedData comment_Count] ;
        NSString * commentsString =   [NSString stringWithFormat:@"共有%i条评论" ,commentscount] ;
        self._commentTextView.text  = [NSString stringWithFormat:@"%@\n%@" , currentText,  commentsString];
    }else 
    if ([feedData class] == [NewFeedSharePhoto class]){
        imageUrl =  [(NewFeedSharePhoto*)feedData photo_url];
        self._commentTextView.text =[(NewFeedSharePhoto*)feedData getPhotoComment]  ;
    } else if ([feedData class] == [NewFeedUploadPhoto class]) {
        imageUrl =  [(NewFeedUploadPhoto*)feedData photo_url];
        self._bigImageUrl =  [(NewFeedUploadPhoto*)feedData photo_big_url];
        authorCommentString = [(NewFeedUploadPhoto*)feedData photo_comment];
    } else 
    if ([feedData class] == [NewFeedData class])
    {
        imageUrl = ((NewFeedData*)feedData).pic_URL;
        self._bigImageUrl =  [(NewFeedData*)feedData pic_big_URL];
        authorCommentString = [(NewFeedData*)feedData message]  ;
    }
    
    //*********************************************
    
    if (authorCommentString) {
        commentsString =  [NSString stringWithFormat:@"%@: %@", [feedData getAuthorName],authorCommentString];
    }else{
        commentsString=  @"";
    }
 
    NSNumber *commentscount = [(NewFeedRootData*)feedData comment_Count] ;
    if ( commentscount.intValue >=3) {
        NSString * tmp =   [NSString stringWithFormat:@"共有%@条评论" ,commentscount] ;
        commentsString = [NSString stringWithFormat:@"%@\n%@" , tmp,  commentsString];
    }
    
    self._commentTextView.text = commentsString;

    self._userNameLabel.text  =[feedData getAuthorName] ;
    
    [self loadHeadImage:self._headImageView withImageUrl:[feedData owner_Head] ];

    [self loadImage:self._photoView withImageUrl:self._bigImageUrl andThumbImageUrl:imageUrl isFirstTime:NO];
    
    [self createPopupMenu:self];
    
    
}


#pragma mark -
#pragma mark awesome delegate  
-(void)createPopupMenu:(UIView * )withinThisView{
    
    UIImage *storyMenuItemImage = [UIImage imageNamed:@"bg-menuitem.png"];
//    UIImage *storyMenuItemImage = nil;
    UIImage *storyMenuItemImagePressed = [UIImage imageNamed:@"bg-menuitem-highlighted.png"];
//    UIImage *storyMenuItemImagePressed = nil;

    UIImage *starImage = [UIImage imageNamed:@"icon-star.png"];
    
    AwesomeMenuItem *starMenuItem1 = [[AwesomeMenuItem alloc] initWithImage:storyMenuItemImage
                                                           highlightedImage:storyMenuItemImagePressed 
                                                               ContentImage:starImage 
                                                    highlightedContentImage:nil];
    AwesomeMenuItem *starMenuItem2 = [[AwesomeMenuItem alloc] initWithImage:storyMenuItemImage
                                                           highlightedImage:storyMenuItemImagePressed 
                                                               ContentImage:starImage 
                                                    highlightedContentImage:nil];
    AwesomeMenuItem *starMenuItem3 = [[AwesomeMenuItem alloc] initWithImage:storyMenuItemImage
                                                           highlightedImage:storyMenuItemImagePressed 
                                                               ContentImage:starImage 
                                                    highlightedContentImage:nil];
    
    
    NSArray *menus = [NSArray arrayWithObjects:starMenuItem1, starMenuItem2, starMenuItem3, nil];
    
    [starMenuItem1 release];
    [starMenuItem2 release];
    [starMenuItem3 release];
    
    AwesomeMenu *menu = [[AwesomeMenu alloc] initWithFrame:withinThisView.bounds menus:menus];
    
    menu.startPoint = CGPointMake(287.0, 20.0);
    menu.rotateAngle = -M_PI/3 - 0.14 - (M_PI/4+M_PI/4)   ;
    menu.menuWholeAngle = M_PI / 2 ;

//    menu.nearRadius  = 55.0f;
//    menu.endRadius  = 75.0f;
//    menu.farRadius  = 95.0f;

    menu.delegate = self;
    [withinThisView addSubview:menu];
    
    [menu release];
    
}

/* ⬇⬇⬇⬇⬇⬇⬇⬇⬇⬇⬇⬇⬇⬇⬇⬇⬇⬇⬇⬇⬇⬇⬇⬇⬇ */
/* ⬇⬇⬇⬇⬇⬇ GET RESPONSE OF MENU ⬇⬇⬇⬇⬇⬇ */
/* ⬇⬇⬇⬇⬇⬇⬇⬇⬇⬇⬇⬇⬇⬇⬇⬇⬇⬇⬇⬇⬇⬇⬇⬇⬇ */

- (void)AwesomeMenu:(AwesomeMenu *)menu didSelectIndex:(NSInteger)idx
{
    NSLog(@"Select the index : %d",idx);
}


@end
