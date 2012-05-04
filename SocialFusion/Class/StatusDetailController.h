//
//  StatusDetailController.h
//  SocialFusion
//
//  Created by He Ruoyun on 11-10-18.
//  Copyright (c) 2011年 Tongji Apple Club. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "NewFeedData.h"
#import "StatusCommentCell.h"
#import "NewFeedStatusCell.h"

#import "EGOTableViewController.h"
#import "NewFeedRootData.h"
#define kToastBottomVerticalPosition 400.0f

@protocol sendMsgToWeChatViewDelegate;
@protocol WeiboRenrenSelecter;

@interface StatusDetailController : EGOTableViewController<UIScrollViewDelegate>
{
    IBOutlet StatusCommentCell *_commentCel;
    IBOutlet UIImageView* _headImage;
    IBOutlet UILabel* _time;
    IBOutlet UILabel* _nameLabel;
    IBOutlet UIView* _titleView;
    IBOutlet UIImageView* _style;
    
    int _pageNumber;
    BOOL _showMoreButton;
    UIActivityIndicatorView* _activity;
    NSData* _photoData; 
    id<WeiboRenrenSelecter> _delegate;

}

@property (nonatomic, retain) NewFeedRootData* feedData;
@property (nonatomic, assign) id<WeiboRenrenSelecter> delegate;
@property (nonatomic,retain) UIScrollView * scrollView;

- (void)setFixedInfo;
- (void)loadMainView;
- (void)loadData;
- (void)ProcessRenrenData:(NSArray*)array;
- (void)ProcessWeiboData:(NSArray*)array;
- (void)clearData;

- (IBAction)repost;
- (IBAction)comment:(id)sender;
- (IBAction)repostToWeixin:(id)sender;

-(IBAction)selectUser;
-(IBAction)selectCommentUser:(id)sender;
@end



@protocol WeiboRenrenSelecter<NSObject>

- (void)selectWeibo:(NSString*)weibo;
-(void)selectRenren:(NSString*)renren;
@end
//////////////weixin
@protocol sendMsgToWeChatViewDelegate <NSObject>
- (void) sendTextContent:(NSString*)nsText;
- (void) sendAppContent;
- (void) sendImageContent;
- (void) sendNewsContent ; 
- (void) sendMusicContent ; 
- (void) sendVideoContent ; 
- (void) doAuth;
@end
//////////////weixin