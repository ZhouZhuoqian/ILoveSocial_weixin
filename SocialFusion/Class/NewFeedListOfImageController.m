//
//  NewFeedListController.m
//  SocialFusion
//
//  Created by He Ruoyun on 11-10-7.
//  Copyright 2011年 Tongji Apple Club. All rights reserved.
//

#import "NewFeedListOfImageController.h"
#import <QuartzCore/QuartzCore.h>
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
#import "NewFeedPhotoCell.h"
#import "NewFeedPhotoHeader.h"

@interface NewFeedListOfImageController(){
    BOOL isDebuging ;
    NSInteger cellnumber;
}
- (UITableViewCell *)getMyCell:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;

@end

@implementation NewFeedListOfImageController

- (void)dealloc {
//    self.feedStatusCel =nil;
//    self.newFeedDetailViewCel = nil;
//    self.newFeedDetailBlogViewCel= nil;
//    self.newFeedAlbumCel= nil;
//    self.cellHeightHelper = nil;
    [super dealloc];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:@"NewFeedListController" bundle:nil];
    if(self) {
        _firstLoad = YES;
    }
    return self;
}



+ (NewFeedListOfImageController*)getNewFeedListOfImageControllerwithStyle:(kUserFeed)style
{
    NewFeedListOfImageController* userList;
    if (style == kRenrenUserFeed)
    {
        userList = [[[NewFeedListOfImageController alloc] init] autorelease];
        [userList setStyle:kRenrenUserFeed];
    }
    else if (style == kWeiboUserFeed)
    {
        userList = [[[NewFeedListOfImageController alloc] init] autorelease];
        [userList setStyle:kWeiboUserFeed];        
    }
    //***********************************************
    else if (style == kAllSelfFeed)
    {
        userList = [[[NewFeedListOfImageController alloc] init] autorelease]; 
        [userList setStyle:kAllSelfFeed];
    }
    else if (style == kRenrenSelfFeed)
    {
        userList = [[[NewFeedListOfImageController alloc] init] autorelease]; 
        [userList setStyle:kRenrenSelfFeed];
    }
    else if (style == kWeiboSelfFeed)
    {
        userList=[[[NewFeedListOfImageController alloc] init] autorelease]; 
        [userList setStyle:kWeiboSelfFeed];
    }
    return userList;
}

+ (NewFeedListOfImageController*)getNewFeedListOfImageControllerwithStyle:(kUserFeed)style andWXDelegate: ( id<sendMsgToWeChatViewDelegate> )var_delegate{
    NSLog(@"getnewfeedlistcontrollderwithstyle");
    NewFeedListOfImageController * tmpcon = [self getNewFeedListOfImageControllerwithStyle:style];
    
    tmpcon.delegateWX = var_delegate;
    return tmpcon;
    
}

- (void)setStyle:(int)style
{
    _style = style;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    isDebuging = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];

    [Image clearAllCacheInContext:self.managedObjectContext];
}

- (NSPredicate *)customPresdicate {
    NSPredicate *predicate = nil;
    if(_style == kAllSelfFeed) {
        //NSLog(@"renren name:%@ and weibo name:%@", self.processRenrenUser.name, self.processWeiboUser.name);
        predicate = [NSPredicate predicateWithFormat:@"SELF IN %@||SELF IN %@", self.processRenrenUser.newFeed, self.processWeiboUser.newFeed];
    }
    else if(_style == kRenrenSelfFeed) {
        //NSLog(@"renren name:%@", self.processRenrenUser.name);
        predicate = [NSPredicate predicateWithFormat:@"SELF IN %@", self.processRenrenUser.newFeed];
    }
    else if(_style == kWeiboSelfFeed) {
        //NSLog(@"renren name:%@", self.processWeiboUser.name);
        predicate = [NSPredicate predicateWithFormat:@"SELF IN %@", self.processWeiboUser.newFeed];
    }
    return predicate;
}



- (void)configureRequest:(NSFetchRequest *)request
{
    [request setEntity:[NSEntityDescription entityForName:@"NewFeedRootData" inManagedObjectContext:self.managedObjectContext]];
    NSPredicate *predicate;
    NSSortDescriptor *sort;
    NSSortDescriptor *sort2;
    predicate = [self customPresdicate];
    //  sort = [[NSSortDescriptor alloc] initWithKey:@"1" ascending:YES];
    sort = [[NSSortDescriptor alloc] initWithKey:@"update_Time" ascending:NO];
    sort2 = [[NSSortDescriptor alloc] initWithKey:@"get_Time" ascending:YES] ;
    
    
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sort2, sort, nil];
    
    [request setSortDescriptors:sortDescriptors];
    
    
    //   [request setSortDescriptors:nil];
    [request setPredicate:predicate];
    // NSArray *descriptors = [NSArray arrayWithObject:sort]; 
    // [request setSortDescriptors:descriptors]; 
    [sort release];
    [sort2 release];
    [sortDescriptors release];
    
}

- (BOOL)isUserNewFeedArrayEmpte {
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:0];
    NSInteger count = [sectionInfo numberOfObjects];
    return count == 0;
}

#pragma mark - EGORefresh Method
- (void)refresh {
    
    if(_firstLoad) {
        _firstLoad = NO;
        if(![self isUserNewFeedArrayEmpte] && [self isMemberOfClass:[NewFeedListController class]])
        {
            [self showLoadMoreDataButton];
            return;
        }
    }
    [self hideLoadMoreDataButton];
    if (_currentTime != nil)
    {
        [_currentTime release];
    }
    _clearDataFlag = YES;
    _pageNumber = 0;
    [self loadMoreData];
}

- (void)loadExtraDataForOnscreenRows 
{
    NSArray *visiblePaths = [self.tableView indexPathsForVisibleRows];
    NSTimeInterval i = 0;
    for (NSIndexPath *indexPath in visiblePaths)
    {
        i += 0.05;
        [self performSelector:@selector(loadExtraDataForOnScreenRowsHelp:) withObject:indexPath afterDelay:i];
    }
}

#pragma mark - 
#pragma mark Custom property getter & setter

- (WeiboUser *)processWeiboUser {
    return self.currentWeiboUser;
}

- (RenrenUser *)processRenrenUser {
    return self.currentRenrenUser;
}

- (void)setLoadingCount:(int)loadingCount {
    _loadingCount = loadingCount;
    if(_loadingCount == 0)
    {
        [self stopLoading];
        _loadingFlag = NO;
    }
    
    else
        _loadingFlag = YES;
    if(_loadingCount < 0) {
        // NSLog(@"shit");
    }
    
}

- (void)addNewWeiboData:(NewFeedRootData *)data {
    cellnumber++;
    [self.processWeiboUser addNewFeedObject:data];
}

- (void)addNewRenrenData:(NewFeedRootData *)data {
    cellnumber++;

    [self.processRenrenUser addNewFeedObject:data];
}

- (void)processWeiboData:(NSArray*)array {
    for(NSDictionary *dict in array) {
        int scrollHeight = [_cellHeightHelper getHeight:dict style:1];
        
        NewFeedData* data = [NewFeedData insertNewFeed:1 height:scrollHeight getDate:_currentTime Dic:dict inManagedObjectContext:self.managedObjectContext];
        
        if ([data pic_big_URL]) {
            
            [self addNewWeiboData:data];

        }
        
    }
    
    [self showLoadMoreDataButton];
    [self doneLoadingTableViewData];
}


- (void)processRenrenData:(NSArray*)array {
    for(NSDictionary *dict in array) {
        
        int scrollHeight = [_cellHeightHelper getHeight:dict style:0];
        NewFeedRootData *data;
        
        
        if ([[dict objectForKey:@"feed_type"] intValue] == 30)
        {
            data = [NewFeedUploadPhoto insertNewFeed:0   getDate:_currentTime Dic:dict inManagedObjectContext:self.managedObjectContext];
            [self addNewRenrenData:data];

        }
        else if ([[dict objectForKey:@"feed_type"] intValue] == 33)
        {
            data = [NewFeedShareAlbum insertNewFeed:0  height:scrollHeight getDate:_currentTime Dic:dict inManagedObjectContext:self.managedObjectContext];
            [self addNewRenrenData:data];
            
        }
        else if ([[dict objectForKey:@"feed_type"] intValue] == 32)
        {
            data = [NewFeedSharePhoto insertNewFeed:0 height:scrollHeight getDate:_currentTime Dic:dict inManagedObjectContext:self.managedObjectContext];
            [self addNewRenrenData:data];

        }

    }
    [self showLoadMoreDataButton];
    [self doneLoadingTableViewData];
}


- (void)loadMoreRenrenData {
    _loadingCount = _loadingCount + 1;
    RenrenClient *renren = [RenrenClient client];
    [renren setCompletionBlock:^(RenrenClient *client) {
        if (!client.hasError) {
            [self clearData];
            NSArray *array = client.responseJSONObject;
            [self processRenrenData:array];
        }
        _loadingCount = _loadingCount - 1;
    }];
    
    [renren getNewFeed:_pageNumber];
}

- (void)loadMoreWeiboData {
    _loadingCount = _loadingCount + 1;
    WeiboClient *client = [WeiboClient client];
    [client setCompletionBlock:^(WeiboClient *client) {
        if (!client.hasError) {
            [self clearData];
            NSArray *array = client.responseJSONObject;
            [self processWeiboData:array];        
        }
        _loadingCount = _loadingCount - 1;
    }];
    
    [client getFriendsTimelineSinceID:nil maxID:nil startingAtPage:_pageNumber count:30 feature:0];
}

- (void)loadMoreData {
    if(_loadingFlag)
        return;
    _pageNumber++;
    
    _currentTime = [[NSDate alloc] initWithTimeIntervalSinceNow:0];
    [self startLoading];
    if (_style == kAllSelfFeed)
    {
        [self loadMoreRenrenData];
        [self loadMoreWeiboData];
    }
    else if (_style == kRenrenSelfFeed)
    {
        [self loadMoreRenrenData];
    }
    
    else if (_style == kWeiboSelfFeed)
    {
        [self loadMoreWeiboData];
    }
}
- (void)showImage:(NSString*)smallURL bigURL:(NSString*)bigURL {
    [DetailImageViewController showDetailImageWithURL:bigURL context:self.managedObjectContext];
}


- (void)showImage:(NSString*)smallURL userID:(NSString*)userID photoID:(NSString*)photoID {    
    [DetailImageViewController showDetailImageWithRenrenUserID:userID photoID:photoID context:self.managedObjectContext];
}

#pragma mark - tableview delegate

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section 
{
    
     
    NewFeedPhotoHeader *headerView = [[[NewFeedPhotoHeader alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 60)] autorelease];
    
//    NewFeedPhotoHeader *headerView = [[[NewFeedPhotoHeader alloc] init ] autorelease];

    return headerView;

    
    
    [headerView setBackgroundColor:[UIColor colorWithRed:225.0f / 255.0f green:217.0f / 255.0f blue:195.0f / 255.0f alpha:0.8f]];
    NSString *section_name ;
          section_name = @"section name";
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 2, 306, 18)];
    label.text = section_name;
    label.font = [UIFont fontWithName:@"MV Boli" size:16.0f];
    label.textColor = [UIColor whiteColor];
    label.shadowColor = [UIColor darkGrayColor];
    label.shadowOffset = CGSizeMake(0, 1.0f);
    label.backgroundColor = [UIColor clearColor];
    [headerView addSubview:label];
    [label release];
    return headerView;
    
    
}

- (float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (isDebuging) {
        return 342;
    }else{
        if (_indexPath == nil || [indexPath compare:_indexPath]) {
            return [NewFeedStatusCell heightForCell:[self.fetchedResultsController objectAtIndexPath:indexPath]];
        }
        else {
            
            return 389;
            
        }
    }
   
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSLog(@"%d" , cellnumber);
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    cellnumber = [super tableView:tableView numberOfRowsInSection:section];
    return cellnumber;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!isDebuging) {
        return [self getMyCell:tableView cellForRowAtIndexPath:indexPath];
    }

    static NSString *NormalCell = @"NewFeedStatusNormalCell";
    if (1) {
        NewFeedPhotoCell * cell  =  [tableView dequeueReusableCellWithIdentifier:NormalCell];
        if (cell == nil) {
            NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"NewFeedPhotoCell" owner:nil options:nil];
            for (id currentObject in topLevelObjects) {
                if ([currentObject isKindOfClass:[UITableViewCell class]]) {
                    cell = (NewFeedPhotoCell *) currentObject;
                    break;
                }
            }		
        }
        NewFeedRootData *data = [self.fetchedResultsController objectAtIndexPath:indexPath];
        [cell configureCell:data first:YES];    
    	
        return cell; 
    }
    
}
- (UITableViewCell *)getMyCell:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *NormalCell = @"NewFeedStatusNormalCell";
    static NSString *RepostCell = @"NewFeedStatusRepostCell";
    static NSString *NormalCellWithPhoto = @"NewFeedStatusNormalCellWithPhoto";
    static NSString *RepostCellWithPhoto = @"NewFeedStatusRepostCellWithPhoto";
    static NSString *ShareAlbumCell = @"NewFeedStatusShareAlbumCell";
    static NSString *SharePhotoCell = @"NewFeedStatusSharePhotoCell";
    static NSString *UploadPhotoCell = @"NewFeedStatusUploadPhotoCell";
    static NSString *BlogCell = @"NewFeedStatusBlogCell";
    
    
    if ([indexPath compare:_indexPath] || 1) {
        NewFeedStatusCell* cell;
        
         NewFeedRootData *data = [self.fetchedResultsController objectAtIndexPath:indexPath];
        
        if ([data class]==[NewFeedBlog class])
        {
            cell = (NewFeedStatusCell *)[tableView dequeueReusableCellWithIdentifier:BlogCell];
            if (cell == nil) {
                cell=[[NewFeedStatusCell alloc] initWithType:kBlog];
            }
            else if ([cell loaded]==NO)
            {
                cell=[[NewFeedStatusCell alloc] initWithType:kBlog];
            }
            
        }
        else if ([data class]==[NewFeedShareAlbum class])
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
        else 
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
        
        
        if ([a class]==[NewFeedBlog class])
        {
            NewFeedDetailBlogViewCell* cell;
            [[NSBundle mainBundle] loadNibNamed:@"NewFeedDetailBlogViewCell" owner:self options:nil];
            //            cell = self.newFeedDetailBlogViewCel;
            
            [cell initWithFeedData:a context:self.managedObjectContext renren:self.currentRenrenUser weibo:self.currentWeiboUser];
            cell.detailController.delegate=self;
            cell.detailController.delegateWX = self.delegateWX;
            
            return cell; 
        }
        
        else if ([a class]==[NewFeedShareAlbum class] || [a class]==[NewFeedSharePhoto class]||[a class]==[NewFeedUploadPhoto class])
        {
            NewFeedAlbumCell* cell;
            [[NSBundle mainBundle] loadNibNamed:@"NewFeedAlbumCell" owner:self options:nil];
            //            cell = self.newFeedAlbumCel;
            
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
            //            cell = self.newFeedDetailViewCel;
            
            [cell initWithFeedData:a context:self.managedObjectContext renren:self.currentRenrenUser weibo:self.currentWeiboUser];
            
            cell.detailController.delegate=self;
            
            cell.detailController.delegateWX = self.delegateWX;
            
            return cell;
        }
    }
    
}



#pragma mark - weixin delegate
-(void)sendTextContent:(NSString *)nsText{
    
    //    NSLog(@"%@",nsText);
}


- (void)loadExtraDataForOnScreenRowsHelp:(NSIndexPath *)indexPath {
    
    
    return;
    
    if(self.tableView.dragging || self.tableView.decelerating || _reloadingFlag)
        return;
    
    NewFeedRootData *data = [self.fetchedResultsController objectAtIndexPath:indexPath];
    Image *image = [Image imageWithURL:data.owner_Head inManagedObjectContext:self.managedObjectContext];
    if (!image)
    {
        NewFeedStatusCell *statusCell = (NewFeedStatusCell *)[self.tableView cellForRowAtIndexPath:indexPath];
        [statusCell.photoView loadImageFromURL:data.owner_Head completion:^{
            [statusCell.photoView fadeIn];
        } cacheInContext:self.managedObjectContext];
        
    }
    
    if ([data class]==[NewFeedUploadPhoto class])
    {
        NewFeedUploadPhoto* data2=(NewFeedUploadPhoto*)data;
        image = [Image imageWithURL:data2.photo_url inManagedObjectContext:self.managedObjectContext];
        if (!image)
        {
            NewFeedStatusCell *statusCell = (NewFeedStatusCell *)[self.tableView cellForRowAtIndexPath:indexPath];
            [UIImage loadImageFromURL:data2.photo_url completion:^{
                Image *image1 = [Image imageWithURL:data2.photo_url inManagedObjectContext:self.managedObjectContext];
                
                [statusCell loadPicture:image1.imageData.data];
                
            } cacheInContext:self.managedObjectContext];
        }
        else
        {
            NewFeedStatusCell *statusCell = (NewFeedStatusCell *)[self.tableView cellForRowAtIndexPath:indexPath];
            
            [statusCell loadPicture:image.imageData.data];
            
        }
        
    }
    
    if ([data class]==[NewFeedShareAlbum class])
    {
        NewFeedShareAlbum* data2=(NewFeedShareAlbum*)data;
        image = [Image imageWithURL:data2.photo_url inManagedObjectContext:self.managedObjectContext];
        if (!image)
        {
            NewFeedStatusCell *statusCell = (NewFeedStatusCell *)[self.tableView cellForRowAtIndexPath:indexPath];
            [UIImage loadImageFromURL:data2.photo_url completion:^{
                Image *image1 = [Image imageWithURL:data2.photo_url inManagedObjectContext:self.managedObjectContext];
                
                [statusCell loadPicture:image1.imageData.data];
                
            } cacheInContext:self.managedObjectContext];
        }
        else
        {
            NewFeedStatusCell *statusCell = (NewFeedStatusCell *)[self.tableView cellForRowAtIndexPath:indexPath];
            
            [statusCell loadPicture:image.imageData.data];
            
        }
        
    }
    
    if ([data class]==[NewFeedSharePhoto class])
    {
        NewFeedSharePhoto* data2=(NewFeedSharePhoto*)data;
        image = [Image imageWithURL:data2.photo_url inManagedObjectContext:self.managedObjectContext];
        if (!image)
        {
            NewFeedStatusCell *statusCell = (NewFeedStatusCell *)[self.tableView cellForRowAtIndexPath:indexPath];
            [UIImage loadImageFromURL:data2.photo_url completion:^{
                Image *image1 = [Image imageWithURL:data2.photo_url inManagedObjectContext:self.managedObjectContext];
                
                [statusCell loadPicture:image1.imageData.data];
                
            } cacheInContext:self.managedObjectContext];
        }
        else
        {
            NewFeedStatusCell *statusCell = (NewFeedStatusCell *)[self.tableView cellForRowAtIndexPath:indexPath];
            
            [statusCell loadPicture:image.imageData.data];
            
        }
        
    }
    
    if ([data class]==[NewFeedData class])
    {
        NewFeedData* data2=(NewFeedData*)data;
        if (data2.pic_URL!=nil)
        {
            image = [Image imageWithURL:data2.pic_URL inManagedObjectContext:self.managedObjectContext];
            if (!image)
            {
                NewFeedStatusCell *statusCell = (NewFeedStatusCell *)[self.tableView cellForRowAtIndexPath:indexPath];
                [UIImage loadImageFromURL:data2.pic_URL completion:^{
                    Image *image1 = [Image imageWithURL:data2.pic_URL inManagedObjectContext:self.managedObjectContext];
                    
                    [statusCell loadPicture:image1.imageData.data];
                    
                } cacheInContext:self.managedObjectContext];
            }
            else
            {
                NewFeedStatusCell *statusCell = (NewFeedStatusCell *)[self.tableView cellForRowAtIndexPath:indexPath];
                
                [statusCell loadPicture:image.imageData.data];
                
            }
        }
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    //NSLog(@"scrollViewDidEndDragging");
    [super scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
    if (!decelerate)
	{
        [self loadExtraDataForOnscreenRows];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    //NSLog(@"scrollViewDidEndDecelerating");
    [self loadExtraDataForOnscreenRows];
}

- (void)clearData
{   if(!_clearDataFlag)
    return;
    _clearDataFlag = NO;
    _noAnimationFlag = NO;
    [self.processRenrenUser removeNewFeed:self.processRenrenUser.newFeed];
    [self.processWeiboUser removeNewFeed:self.processWeiboUser.newFeed];
}

- (void)exposeCell:(NSIndexPath*)indexPath
{
   
    return;
    
    [self.tableView cellForRowAtIndexPath:indexPath].selected=false;
    self.tableView.allowsSelection=false;
    _indexPath=[indexPath retain];
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
    self.tableView.scrollEnabled=FALSE;
}

- (void)showImage:(NSIndexPath*)indexPath
{
    NewFeedRootData* _feedData=[self.fetchedResultsController objectAtIndexPath:indexPath];
    if ([_feedData class] == [NewFeedUploadPhoto class]) {
        [self showImage:((NewFeedUploadPhoto*)_feedData).photo_url bigURL:((NewFeedUploadPhoto*)_feedData).photo_big_url];
    }
    else if ([_feedData class] == [NewFeedSharePhoto class]) {
        [self showImage:((NewFeedSharePhoto*)_feedData).photo_url userID:((NewFeedSharePhoto*)_feedData).fromID  photoID:((NewFeedSharePhoto*)_feedData).mediaID];
    }
    else {
        [self showImage:((NewFeedData*)_feedData).pic_URL bigURL:((NewFeedData*)_feedData).pic_big_URL];   
    }
    
}


- (void)selectUser:(NSIndexPath *)indexPath
{
    NewFeedRootData* feedData = [self.fetchedResultsController objectAtIndexPath:indexPath];
    User *usr = feedData.author;
    if(usr == nil) 
        return;
    NSMutableDictionary *userDict = [NSMutableDictionary dictionaryWithDictionary:self.currentUserDict];
    if([usr isMemberOfClass:[RenrenUser class]])
        [userDict setObject:usr forKey:kRenrenUser];
    else if([usr isMemberOfClass:[WeiboUser class]]) 
        [userDict setObject:usr forKey:kWeiboUser];
    [NSNotificationCenter postSelectFriendNotificationWithUserDict:userDict];
}

- (IBAction)resetToNormalList
{
    
    self.tableView.allowsSelection=NO;
    //[self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    self.tableView.scrollEnabled=true;
    NSIndexPath* tempIndex=[_indexPath retain];
    [_indexPath release];
    _indexPath=nil;
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:tempIndex] withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView scrollToRowAtIndexPath:tempIndex atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
    [tempIndex release];
    [self loadExtraDataForOnscreenRows];
}

-(void)loadNewRenrenAt:(NSString*)userID 
{
    // NSLog(@"%@",userID);
    RenrenClient *renren = [RenrenClient client];
    [renren setCompletionBlock:^(RenrenClient *client) {
        if (!client.hasError) {
            [self clearData];
            NSArray *array = client.responseJSONObject;
            //    NSLog(@"%@",array);
            for(NSDictionary *dict in array) {
                
                [dict setValue:[dict objectForKey:@"uid"] forKey:@"id"];//修改dict结构使其和friendget一样
                RenrenUser *user = [RenrenUser insertFriend:dict inManagedObjectContext:self.managedObjectContext];
                NSMutableDictionary *userDict = [NSMutableDictionary dictionaryWithDictionary:self.currentUserDict];
                
                [userDict setObject:user forKey:kRenrenUser];
                
                [NSNotificationCenter postSelectFriendNotificationWithUserDict:userDict];
            }
        }
    }];
    
    [renren getUserInfoWithUserID:userID];
}

-(void)loadNewWeiboAt:(NSString*)userName
{
    //  NSLog(@"%@",userName);
    WeiboClient *client = [WeiboClient client];
    [client setCompletionBlock:^(WeiboClient *client) {
        if (!client.hasError) {
            [self clearData];
            NSDictionary *dict = client.responseJSONObject ;
            
            
            WeiboUser *usr = [WeiboUser insertUser:dict inManagedObjectContext:self.managedObjectContext];
            NSMutableDictionary *userDict = [NSMutableDictionary dictionaryWithDictionary:self.currentUserDict];
            [userDict setObject:usr forKey:kWeiboUser];                
            [NSNotificationCenter postSelectFriendNotificationWithUserDict:userDict];
            
        }
        [self doneLoadingTableViewData];
        _loadingFlag = NO;
    }];
    [client getUserWithName:userName];
    
}

#pragma mark - 
#pragma mark GIF methos


-(void)selectWeibo:(NSString *)weibo
{
    [self loadNewWeiboAt:weibo];
}


-(void)selectRenren:(NSString *)renren
{
    [self loadNewRenrenAt:renren];
}

@end
