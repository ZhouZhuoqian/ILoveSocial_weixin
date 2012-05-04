//
//  StatusDetailController.m
//  SocialFusion
//
//  Created by He Ruoyun on 11-10-18.
//  Copyright (c) 2011年 Tongji Apple Club. All rights reserved.
//
#import "StatusDetailController.h"
#import "WeiboClient.h"
#import "RenrenClient.h"
#import "StatusCommentData.h"
#import "NewFeedStatusCell.h"
#import "NewFeedRootData+Addition.h"
#import "NewFeedData+NewFeedData_Addition.h"
#import "NewFeedBlog+NewFeedBlog_Addition.h"
#import "Image+Addition.h"
#import "UIImageView+Addition.h"
//#import "StatusDetailController.h"
#import "StatusCommentData+StatusCommentData_Addition.h"
#import "CommonFunction.h"
#import "NSString+HTMLSet.h"
#import "RenrenUser.h"
#import "WeiboUser.h"
#import "DetailImageViewController.h"
#import "NSNotificationCenter+Addition.h"

@implementation StatusDetailController

@synthesize feedData = _feedData;
@synthesize delegate=_delegate;
@synthesize scrollView;

- (void)dealloc {
    [_commentCel release];
    [_headImage release];
    [_time release];
    [_nameLabel release];
    [_titleView release];
    
    [_style release];
    [_feedData release];
    
    [super dealloc];
}

- (void)viewDidUnload
{
    
    [super viewDidUnload];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.scrollView = (UIScrollView *)self.view;
    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width * 2, self.scrollView.frame.size.height); 

}

- (void)showBigImage
{

}


- (void)clearData
{
    if(!_clearDataFlag)
        return;
    _clearDataFlag = NO;
    
    _noAnimationFlag = YES;
    //  NSLog(@"%@",self.feedData.comments);
    [self.feedData removeComments:self.feedData.comments];
    
    [StatusCommentData deleteAllObjectsInManagedObjectContext:self.managedObjectContext];
    
}

- (void)setFixedInfo
{
    _nameLabel.text = [_feedData getAuthorName];
    NSData *imageData = nil;
    if([Image imageWithURL:_feedData.owner_Head inManagedObjectContext:self.managedObjectContext]) {
        imageData = [Image imageWithURL:_feedData.owner_Head inManagedObjectContext:self.managedObjectContext].imageData.data;
    }
    if(imageData != nil) {
        _headImage.image = [UIImage imageWithData:imageData];
    }
    _time.text = [CommonFunction getTimeBefore:_feedData.update_Time]; 
    self.scrollView.pagingEnabled = YES;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.directionalLockEnabled = YES;
    self.scrollView.delegate = self;
    
    self.tableView.frame = CGRectMake(306, 40, 306, 320);
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [self.scrollView addSubview:self.tableView];
    
    self.tableView.allowsSelection = NO;    
    
       
    [self addCommentButton];
    [self addWeixinButton];
    
  
    if ([_feedData.style intValue] == 0)
    {
        [_style setImage:[UIImage imageNamed:@"detail_renren.png"]];
    }
    else
    {
        [_style setImage:[UIImage imageNamed:@"detail_weibo.png"]];
    }
    
}
-(void)addCommentButton{
    UIButton* _commentButton;
    _commentButton = [[UIButton alloc] init];
    [_commentButton addTarget:self action:@selector(comment:) forControlEvents:UIControlEventTouchUpInside];
    _commentButton.frame = CGRectMake(306 , 0, 320-165, 50);
    [_commentButton setBackgroundImage:[UIImage imageNamed:@"btn_msg_new.png"] forState:UIControlStateNormal];
    _commentButton.showsTouchWhenHighlighted = YES;
    _commentButton.adjustsImageWhenHighlighted = NO;
    [self.scrollView addSubview:_commentButton];
    [_commentButton release];
    
    //*****************************
    UILabel *commentButtonLabel = [[UILabel alloc] initWithFrame:CGRectMake(306 + 10 , 0, 100, 40)];
    commentButtonLabel.text = @"写点评论吧...";
    commentButtonLabel.backgroundColor = [UIColor clearColor];
    commentButtonLabel.textColor = [UIColor grayColor];
    commentButtonLabel.font = [UIFont boldSystemFontOfSize:14.0f];
    [self.scrollView addSubview:commentButtonLabel];
    [commentButtonLabel release];
    //*****************************

    UIButton *smallCommentButton = [[UIButton alloc] init];
    [smallCommentButton addTarget:self action:@selector(comment:) forControlEvents:UIControlEventTouchUpInside];
    smallCommentButton.frame = CGRectMake(306 + 266 -160, 0, 40, 40);
    [smallCommentButton setImage:[UIImage imageNamed:@"btn_msg.png"] forState:UIControlStateNormal];
    smallCommentButton.showsTouchWhenHighlighted = YES;
    smallCommentButton.adjustsImageWhenHighlighted = NO;
    [self.scrollView addSubview:smallCommentButton];
    [smallCommentButton release]; 
}

-(void)addWeixinButton{
    
    UIButton* repostToWexinButton;
    repostToWexinButton = [[UIButton alloc] init];
    [repostToWexinButton addTarget:self action:@selector(repostToWeixin:) forControlEvents:UIControlEventTouchUpInside];
    repostToWexinButton.frame = CGRectMake(306 + 150, 0, 320-160, 50);
    [repostToWexinButton setBackgroundImage:[UIImage imageNamed:@"btn_msg_new.png"] forState:UIControlStateNormal];
    repostToWexinButton.showsTouchWhenHighlighted = YES;
    repostToWexinButton.adjustsImageWhenHighlighted = NO;
    [self.scrollView addSubview:repostToWexinButton];
    [repostToWexinButton release];
    //*****************************

    UILabel *repostToWexinButtonLabel = [[UILabel alloc] initWithFrame:CGRectMake(306 + 10 + 160, 0, 100, 40)];
    repostToWexinButtonLabel.text = @"转发到微信...";
    repostToWexinButtonLabel.backgroundColor = [UIColor clearColor];
    repostToWexinButtonLabel.textColor = [UIColor grayColor];
    repostToWexinButtonLabel.font = [UIFont boldSystemFontOfSize:14.0f];
    [self.scrollView addSubview:repostToWexinButtonLabel];
    [repostToWexinButtonLabel release];
    //*****************************

    UIButton *smallRepostButton = [[UIButton alloc] init];
    [smallRepostButton addTarget:self action:@selector(repostToWeixin:) forControlEvents:UIControlEventTouchUpInside];
    smallRepostButton.frame = CGRectMake(306 + 266 , 0, 40, 40);
    [smallRepostButton setImage:[UIImage imageNamed:@"btn_repost.png"] forState:UIControlStateNormal];
    smallRepostButton.showsTouchWhenHighlighted = YES;
    smallRepostButton.adjustsImageWhenHighlighted = NO;
    [self.scrollView addSubview:smallRepostButton];
    [smallRepostButton release];
}

- (void)addOriStatus {
    [self setFixedInfo];
    [self loadMainView];
    
}

- (void) loadMainView {
    
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        // _commentArray = [[NSMutableArray alloc] init];
        
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    [self addOriStatus];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    _pageNumber = 0;
    [self refresh];
}

- (void)viewDidDisappear:(BOOL)animated
{
    //[_feedStatusCel removeFromSuperview];
    //[_feedStatusCel release];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
   // NSLog(@"clear all cache");
    [Image clearAllCacheInContext:self.managedObjectContext];
}

- (void)configureRequest:(NSFetchRequest *)request
{
    [request setEntity:[NSEntityDescription entityForName:@"StatusCommentData" inManagedObjectContext:self.managedObjectContext]];
    NSPredicate *predicate;
    NSSortDescriptor *sort;
    
    predicate = [NSPredicate predicateWithFormat:@"SELF IN %@",self.feedData.comments];
    // NSLog(@"%@",self.feedData.comments);
    sort = [[NSSortDescriptor alloc] initWithKey:@"update_Time" ascending:YES];
    [request setPredicate:predicate];
    NSArray *descriptors = [NSArray arrayWithObject:sort];
    
    [request setSortDescriptors:descriptors]; 
    [sort release];
    request.fetchBatchSize = 5;
    
}

#pragma mark - EGORefresh Method
- (void)refresh {    
    [self hideLoadMoreDataButton];
    _clearDataFlag = YES;
    
    

    if ([_feedData getStyle] == 0)
    {
        _pageNumber = [_feedData getComment_Count]/10+1;
    }
    else
    {
        _pageNumber = 1;
    }
    [self loadData];
}

- (void)loadMoreData {
    if(_loadingFlag)
        return;
   
        [self startLoading];
    if ([_feedData getStyle] == 0)
    {
        _pageNumber--;
    }
    else
    {
        _pageNumber++;
    }
    [self loadData];
}

- (void)ProcessRenrenData:(NSArray*)array
{
    for(NSDictionary *dict in array) {
        StatusCommentData* commentsData = [StatusCommentData insertNewComment:0 Dic:dict inManagedObjectContext:self.managedObjectContext];
        
        
        if ([self.currentRenrenUser.userID isEqualToString:commentsData.actor_ID] )
        {
            commentsData.actor_ID = [NSString stringWithString:@"self"];
        }
        [_feedData addCommentsObject:commentsData];
        
        
    }
    if (_pageNumber != 1)
    {
        _showMoreButton = YES;
    }
    else
    {
        _showMoreButton = NO;
    }
    
    _loadingFlag = NO;
    
    [self stopLoading];
    [self doneLoadingTableViewData];
    [self.tableView reloadData];
}

- (void)ProcessWeiboData:(NSArray*)array
{
    for(NSDictionary *dict in array) {
        
        StatusCommentData* commentsData = [StatusCommentData insertNewComment:1 Dic:dict inManagedObjectContext:self.managedObjectContext];
        
        if ([self.currentWeiboUser.userID isEqualToString:commentsData.actor_ID] )
        {
            commentsData.actor_ID = [NSString stringWithString:@"self"];
        }
        [_feedData addCommentsObject:commentsData]; 
    }
    if ([_feedData.comments count]<[_feedData getComment_Count])
    {
        _showMoreButton = YES;
    }
    else
    {
        _showMoreButton = NO;
    }
    _loadingFlag = NO;
    
    [self stopLoading];

    [self doneLoadingTableViewData];
    [self.tableView reloadData];
    
}

- (void)loadData
{
    if(_loadingFlag)
        return;
    _loadingFlag = YES;
    
    if ([_feedData getStyle] == 0)
    {
        RenrenClient *renren = [RenrenClient client];
        [renren setCompletionBlock:^(RenrenClient *client) {
            if(!client.hasError) {
                [self clearData];
                NSArray *array = client.responseJSONObject;
                [self ProcessRenrenData:array];
                
                //[self.tableView reloadData];
            }
            
        }];
        [renren getComments:[_feedData getActor_ID] status_ID:[_feedData getSource_ID] pageNumber:_pageNumber];
    }
    else
    {
        WeiboClient *weibo = [WeiboClient client];
        [weibo setCompletionBlock:^(WeiboClient *client) {
            if(!client.hasError) {
                [self clearData];
                NSArray *array = [client.responseJSONObject objectForKey:@"comments"];
                [self ProcessWeiboData:array];
            }
        }];
        [weibo getCommentsOfStatus:[_feedData getSource_ID] page:_pageNumber count:10];
    }
}

- (float) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_showMoreButton == YES)
    {
        
        if (indexPath.row == 0)
        {
            return 60;
        }
        else
        {
            NSIndexPath* index = [NSIndexPath indexPathForRow:indexPath.row-1 inSection:indexPath.section];
            
            // indexPath = [[indexPath indexPathByRemovingLastIndex] indexPathByRemovingLastIndex];
            return [StatusCommentCell heightForCell:[self.fetchedResultsController objectAtIndexPath:index]];
        }
    }
    else
    {
        //     indexPath = [indexPath indexPathByRemovingLastIndex];
        return [StatusCommentCell heightForCell:[self.fetchedResultsController objectAtIndexPath:indexPath]];
        
    }
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    int number = [super tableView:tableView numberOfRowsInSection:section];
    if (_showMoreButton == NO)
    {
        return number;
    }
    else
    {
        return number+1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *StatusComentCell = @"StatusCommentCell";
    if (_showMoreButton == NO)
    {
        StatusCommentCell* cell;
        cell = (StatusCommentCell *)[tableView dequeueReusableCellWithIdentifier:StatusComentCell];
        if (cell == nil) {
            [[NSBundle mainBundle] loadNibNamed:@"StatusCommentCell" owner:self options:nil];
            cell = _commentCel;
        }
        
        if (indexPath.row %2 == 0)
        {
            [cell configureCell:[self.fetchedResultsController objectAtIndexPath:indexPath] colorStyle:YES];
            
        }
        else
        {
            [cell configureCell:[self.fetchedResultsController objectAtIndexPath:indexPath] colorStyle:NO];
        }
        
        return cell;
    }
    else
    {
        if (indexPath.row == 0)
        {
            UITableViewCell* cell = [[UITableViewCell alloc] initWithFrame:CGRectMake(0, 0, 306, 60)]; 
            [cell.contentView addSubview:self.loadMoreDataButton];
            return cell;
        }
        else
        {
            StatusCommentCell* cell;
            
            cell = (StatusCommentCell *)[tableView dequeueReusableCellWithIdentifier:StatusComentCell];
            if (cell == nil) {
                [[NSBundle mainBundle] loadNibNamed:@"StatusCommentCell" owner:self options:nil];
                cell = _commentCel;
            }
            
            NSIndexPath* index = [NSIndexPath indexPathForRow:indexPath.row-1 inSection:indexPath.section];
            
            if (index.row %2 == 0)
            {
                [cell configureCell:[self.fetchedResultsController objectAtIndexPath:index] colorStyle:YES];
            }
            else
            {
                [cell configureCell:[self.fetchedResultsController objectAtIndexPath:index] colorStyle:NO];
            }
            return cell;
        }
    }
}
-(IBAction)repost
{
    
}

-(IBAction)repostToWeixin:(id)sender{
    // super class
    NSLog(@"reposttoweixin super class");
}

-(IBAction)comment:(id)sender
{
    
}

-(IBAction)selectUser
{
    NewFeedRootData* feedData =self.feedData;
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


-(IBAction)selectCommentUser:(id)sender
{
    UITableViewCell* cell=(UITableViewCell*)((UIButton*)sender).superview.superview;

    
    NSIndexPath* indexPath=[self.tableView indexPathForCell:cell];

    StatusCommentData* data=[self.fetchedResultsController objectAtIndexPath:indexPath];
    
    if ([data.style intValue]==0)
    {
        [self.delegate selectRenren:data.actor_ID];
    }
    else
    {
        [self.delegate selectWeibo:data.owner_Name];
    }
}
@end
