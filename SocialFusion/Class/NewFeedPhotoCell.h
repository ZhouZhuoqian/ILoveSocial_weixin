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
 
@interface NewFeedPhotoCell :  UITableViewCell{
    
}


@property (retain, nonatomic) IBOutlet UIImageView *imageView;
@property (retain, nonatomic) IBOutlet UIImageView *_headImageView;
@property (retain, nonatomic) IBOutlet UILabel *_userNameLabel;
@property (retain, nonatomic) IBOutlet UILabel *captainLabel;
@property (retain, nonatomic) IBOutlet UIImageView *_headFrameImageView;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
 @property (retain, nonatomic) IBOutlet UITextView *_commentTextView;

 - (void)setList:(NewFeedListOfImageController*)list;
- (IBAction)selectUser:(id)sender;
- (IBAction)repost:(id)sender;
- (void)configureCell:(NewFeedRootData*)feedData  first:(BOOL)bol;

@end
