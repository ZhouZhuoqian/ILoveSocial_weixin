//
//  NewFeedPhotoCell.h
//  SocialFusion
//
//  Created by nobby heell on 6/1/12.
//  Copyright (c) 2012 TJU. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NewFeedRootData+Addition.h"
#import "NewFeedListOfImageController.h"
#import "AwesomeMenu.h"
 
@interface NewFeedPhotoCell :  UITableViewCell<AwesomeMenuDelegate>{
    
}


@property (retain, nonatomic) IBOutlet UIImageView *_photoView;
@property (retain, nonatomic) IBOutlet UIImageView *_headImageView;
@property (retain, nonatomic) IBOutlet UILabel *_userNameLabel;
@property (retain, nonatomic) IBOutlet UILabel *captainLabel;
@property (retain, nonatomic) IBOutlet UIImageView *_headFrameImageView;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (retain, nonatomic)   UITextView *_commentTextView;
@property (retain, nonatomic)   NewFeedRootData *_feedData;
@property (retain, nonatomic)   NewFeedListOfImageController *_listController;


- (void)setList:(NewFeedListOfImageController*)list;
- (IBAction)selectUser:(id)sender;
- (IBAction)repost:(id)sender;
- (IBAction)didClickImageView:(id)sender;
- (void)configureCell:(NewFeedRootData*)feedData  first:(BOOL)bol;
- (void)configureCellImage:(NewFeedRootData*)feedData  first:(BOOL)bol;

@end
