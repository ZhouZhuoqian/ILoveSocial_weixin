//
//  NewFeedListController.h
//  SocialFusion
//
//  Created by He Ruoyun on 11-10-7.
//  Copyright 2011年 Tongji Apple Club. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NewFeedListController.h"


@interface NewFeedListOfImageController : NewFeedListController
{    
}

+ (NewFeedListOfImageController*)getNewFeedListOfImageControllerwithStyle:(kUserFeed)style;
+ (NewFeedListOfImageController*)getNewFeedListOfImageControllerwithStyle:(kUserFeed)style andWXDelegate: ( id<sendMsgToWeChatViewDelegate> )var_delegate;


@end
