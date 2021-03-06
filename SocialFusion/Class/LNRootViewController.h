//
//  LNRootViewController.h
//  SocialFusion
//
//  Created by 王紫川 on 12-1-19.
//  Copyright (c) 2012年 Tongji Apple Club. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreDataViewController.h"
#import "LNLabelBarViewController.h"
#import "LNContentViewController.h"
#import "AwesomeMenu.h"

//#import "StatusDetailController.h"

@interface LNRootViewController : CoreDataViewController<LNLabelBarViewControllerDelegate, LNContentViewControllerDelegate,AwesomeMenuDelegate> {
    
    LNLabelBarViewController *_labelBarViewController;
    LNContentViewController *_contentViewController;
    NSMutableDictionary *_openedUserHeap;
    
}


@property (nonatomic, retain) LNLabelBarViewController *labelBarViewController;
@property (nonatomic, retain) LNContentViewController *contentViewController;
//@property (nonatomic, assign) id<sendMsgToWeChatViewDelegate>  delegateWX;

@end
