//
//  NewStatusViewController.h
//  SocialFusion
//
//  Created by Blue Bitch on 12-1-29.
//  Copyright (c) 2012年 Tongji Apple Club. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreDataViewController.h"
#import "PickAtListViewController.h"

typedef enum {
    PostStatusErrorNone     = 0,
    PostStatusErrorWeibo    = 1,
    PostStatusErrorRenren   = 2,
    PostStatusErrorAll      = 3,
} PostStatusErrorCode;

#define TOAST_POS_Y   (self.toolBarView.frame.origin.y + self.toolBarView.frame.size.height - 40.0f)
#define WEIBO_MAX_WORD  140
#define TOOLBAR_HEIGHT  22.0f

@interface PostViewController : CoreDataViewController <UITextViewDelegate, UINavigationControllerDelegate, PickAtListViewControllerDelegate> {
    PostStatusErrorCode _postStatusErrorCode;
    NSUInteger _postCount;
    NSInteger _lastTextViewCount;
}

@property (nonatomic, retain) IBOutlet UITextView *textView;
@property (nonatomic, retain) IBOutlet UILabel *textCountLabel;
@property (nonatomic, retain) IBOutlet UIView *toolBarView;
@property (nonatomic, retain) IBOutlet UILabel *titleLabel;
@property (nonatomic, readonly) UITextView *processTextView;

- (IBAction)didClickCancelButton:(id)sender;
- (IBAction)didClickPostButton:(id)sender;
- (IBAction)didClickAtButton:(id)sender;

- (void)postStatusCompletion;
- (void)dismissView;

- (int)sinaCountWord:(NSString*)s;

- (void)updateTextCount;
- (void)showTextWarning;

@end
