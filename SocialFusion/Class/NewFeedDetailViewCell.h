//
//  NewFeedDetailViewCell.h
//  SocialFusion
//
//  Created by He Ruoyun on 11-11-21.
//  Copyright (c) 2011年 Tongji Apple Club. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StatusDetailControllerWithWeb.h"


@protocol sendMsgToWeChatViewDelegate;


@interface NewFeedDetailViewCell : UITableViewCell
{
    IBOutlet StatusDetailControllerWithWeb* _detailController;
}
@property (nonatomic, retain) StatusDetailControllerWithWeb* detailController;
@property (nonatomic,assign) id<sendMsgToWeChatViewDelegate> delegateWX;

- (void)initWithFeedData:(NewFeedRootData*)_feedData  context:(NSManagedObjectContext*)context renren:(RenrenUser*)ren weibo:(WeiboUser*)wei;
@end
