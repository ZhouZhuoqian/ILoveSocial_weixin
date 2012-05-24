//
//  FriendListViewController.h
//  SocialFusion
//
//  Created by 王紫川 on 11-10-4.
//  Copyright 2011年 Tongji Apple Club. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FriendProfileViewController.h"
#import "FriendListTableViewCell.h"

#define kCustomRowCount 7

@interface FriendListViewController : FriendProfileViewController<FriendListTableViewCellDelegate,UITextFieldDelegate>{
}

@property (retain, nonatomic) IBOutlet UITextField *textField;

+ (FriendListViewController *)getNewFeedListControllerWithType:(RelationshipViewType)type;
- (IBAction)atTextFieldEditingChanged:(UITextField*)textField ;

@end


