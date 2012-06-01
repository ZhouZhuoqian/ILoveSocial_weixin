//
//  NewFeedListOfImageController.m
//  SocialFusion
//
//  Created by Ben Zhou on 12-6-1.
//  Copyright (c) 2012年 Tongji Apple Club. All rights reserved.
//

#import "NewFeedListOfImageController.h"

#import "RenrenClient.h"
#import "WeiboClient.h"
#import "NewFeedRootData+Addition.h"
#import "NewFeedData+NewFeedData_Addition.h"
#import "NewFeedBlog+NewFeedBlog_Addition.h"
#import "NewFeedUploadPhoto+Addition.h"
#import "NewFeedShareAlbum+Addition.h"
#import "NewFeedSharePhoto+Addition.h"
#import "Image+Addition.h"
#import "UIImageView+Addition.h"
#import "NewFeedBlog.h"
#import "UIImage+Addition.h"
#import "DetailImageViewController.h"
#import "NewFeedUserListController.h"
#import "NewFeedDetailBlogViewCell.h"
#import "NSNotificationCenter+Addition.h"
#import "User+Addition.h"
#import "NSString+HTMLSet.h"

@implementation NewFeedListOfImageController

- (void)dealloc {
    [super dealloc];
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.scrollsToTop = NO;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:@"NewFeedListController" bundle:nil];
    return self;
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *NormalCell = @"NewFeedStatusNormalCell";
    static NSString *RepostCell = @"NewFeedStatusRepostCell";
    static NSString *NormalCellWithPhoto = @"NewFeedStatusNormalCellWithPhoto";
    static NSString *RepostCellWithPhoto = @"NewFeedStatusRepostCellWithPhoto";
    static NSString *ShareAlbumCell = @"NewFeedStatusShareAlbumCell";
    static NSString *SharePhotoCell = @"NewFeedStatusSharePhotoCell";
    static NSString *UploadPhotoCell = @"NewFeedStatusUploadPhotoCell";
    
     if ([indexPath compare:_indexPath]) {
         // check if this is a expose cell
        NewFeedStatusCell* cell;
        
        NewFeedRootData *data = [self.fetchedResultsController objectAtIndexPath:indexPath];
       
        if ([data class]==[NewFeedShareAlbum class])
        {
            cell = (NewFeedStatusCell *)[tableView dequeueReusableCellWithIdentifier:ShareAlbumCell];
            if (cell == nil) {
                cell=[[NewFeedStatusCell alloc] initWithType:kShareAlbum];
            }
            else if ([cell loaded]==NO)
            {
                cell=[[NewFeedStatusCell alloc] initWithType:kShareAlbum];
            }
            
        }
        else if ([data class]==[NewFeedSharePhoto class])
        {
            cell = (NewFeedStatusCell *)[tableView dequeueReusableCellWithIdentifier:SharePhotoCell];
            
            
            if (cell == nil) {
                cell=[[NewFeedStatusCell alloc] initWithType:kSharePhoto];
            }
        }
        else if ([data class]==[NewFeedUploadPhoto class])
        {
            cell = (NewFeedStatusCell *)[tableView dequeueReusableCellWithIdentifier:UploadPhotoCell];
            
            
            if (cell == nil) {
                cell=[[NewFeedStatusCell alloc] initWithType:kUploadPhoto];
            }
            else if ([cell loaded]==NO)
            {
                cell=[[NewFeedStatusCell alloc] initWithType:kUploadPhoto];
            }
            
        }
        else if(0)
        {
            if (((NewFeedData*)data).repost_ID==nil)
            {
                if (((NewFeedData*)data).pic_URL==nil)
                {
                    cell = (NewFeedStatusCell *)[tableView dequeueReusableCellWithIdentifier:NormalCell];
                    
                    
                    if (cell == nil) {
                        cell=[[NewFeedStatusCell alloc] initWithType:kNormal];
                    }
                    else if ([cell loaded]==NO)
                    {
                        cell=[[NewFeedStatusCell alloc] initWithType:kNormal];
                    }
                    
                }
                else
                {
                    cell = (NewFeedStatusCell *)[tableView dequeueReusableCellWithIdentifier:NormalCellWithPhoto];
                    
                    
                    if (cell == nil) {
                        cell=[[NewFeedStatusCell alloc] initWithType:kNormalWithPhoto];
                    }
                    else if ([cell loaded]==NO)
                    {
                        cell=[[NewFeedStatusCell alloc] initWithType:kNormalWithPhoto];
                    }
                    
                }
            }
            else
            {
                if (((NewFeedData*)data).pic_URL==nil)
                {
                    cell = (NewFeedStatusCell *)[tableView dequeueReusableCellWithIdentifier:RepostCell];
                    
                    
                    if (cell == nil) {
                        cell=[[NewFeedStatusCell alloc] initWithType:kRepost];
                    }
                    else if ([cell loaded]==NO)
                    {
                        cell=[[NewFeedStatusCell alloc] initWithType:kRepost];
                    }
                    
                }
                else
                {
                    cell = (NewFeedStatusCell *)[tableView dequeueReusableCellWithIdentifier:RepostCellWithPhoto];
                    
                    if (cell == nil) {
                        cell=[[NewFeedStatusCell alloc] initWithType:kRepostWithPhoto];
                    }
                    else if ([cell loaded]==NO)
                    {
                        cell=[[NewFeedStatusCell alloc] initWithType:kRepostWithPhoto];
                    }
                    
                }
            }
        }
        
        [cell configureCell:data first:YES];        
        cell.delegate=self;
        [cell setList:self];
        
        
        NSData *imageData = nil;
        if([Image imageWithURL:data.owner_Head inManagedObjectContext:self.managedObjectContext]) {
            imageData = [Image imageWithURL:data.owner_Head inManagedObjectContext:self.managedObjectContext].imageData.data;
        }
        if(imageData == nil) {
            if(self.tableView.dragging == NO && self.tableView.decelerating == NO) {
                if(indexPath.row < 5) {
                    [cell.photoView loadImageFromURL:data.owner_Head completion:^{
                        [cell.photoView fadeIn];
                    } cacheInContext:self.managedObjectContext];
                }
            }
        }
        else {
            cell.photoView.image = [UIImage imageWithData:imageData];
        }
        
        return cell;
    }
    //展开时的cell
    else {
        
        NewFeedRootData* a= [self.fetchedResultsController objectAtIndexPath:indexPath];
        
        if ([a class]==[NewFeedShareAlbum class] || [a class]==[NewFeedSharePhoto class]||[a class]==[NewFeedUploadPhoto class])
        {
            NewFeedAlbumCell* cell;
            [[NSBundle mainBundle] loadNibNamed:@"NewFeedAlbumCell" owner:self options:nil];
            cell = _newFeedAlbumCel;
            
            [cell initWithFeedData:a context:self.managedObjectContext renren:self.currentRenrenUser weibo:self.currentWeiboUser];
            
            cell.detailController.delegate=self;
            cell.detailController.delegateWX = self.delegateWX;
            
            return cell;
        }
        else
        {
            NSLog(@"detail cell");
            NewFeedDetailViewCell* cell;
            [[NSBundle mainBundle] loadNibNamed:@"NewFeedDetailViewCell" owner:self options:nil];
            cell = _newFeedDetailViewCel;
            
            [cell initWithFeedData:a context:self.managedObjectContext renren:self.currentRenrenUser weibo:self.currentWeiboUser];
            
            cell.detailController.delegate=self;
            
            cell.detailController.delegateWX = self.delegateWX;
            
            
            return cell;
        }
    }
}




@end
