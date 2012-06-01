//
//  LNContentViewController.m
//  SocialFusion
//
//  Created by 王紫川 on 12-1-19.
//  Copyright (c) 2012年 Tongji Apple Club. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "LNContentViewController.h"
#import "LabelConverter.h"
#import "CoreDataViewController.h"
#import "User.h"
#import "PublicationViewController.h"
#import "NewFeedListController.h"
#import "FriendListViewController.h"
#import "UserInfoViewController.h"

@interface LNContentViewController()
- (id)addContentViewWithIndentifier:(NSString *)identifier andUsers:(NSDictionary *)userDict;
@property (nonatomic, retain) NSMutableArray *contentViewIndentifierHeap;
@end

@implementation LNContentViewController

@synthesize scrollView = _scrollView;
@synthesize contentViewControllerHeap = _contentViewControllerHeap;
@synthesize currentContentIndex = _currentContentIndex;
@synthesize contentViewIndentifierHeap = _contentViewIndentifierHeap;
@synthesize delegate = _delegate;
@synthesize bgView = _bgView;
@synthesize delegateWX;

- (void)dealloc {
    [_contentViewControllerHeap release];
    [_contentViewIndentifierHeap release];
    [_scrollView release];
    [_bgView release];
    self.delegate = nil;
    [super dealloc];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.scrollView = nil;
    self.bgView = nil;
}

- (void)refreshScrollViewContentSize {
    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width * self.contentViewCount, self.scrollView.frame.size.height);
}

- (void)scrollContentViewAtIndexPathToVisble:(NSUInteger)index animated:(BOOL)animate{
    if(animate)
        animate = abs(index - _currentContentIndex) <= 3 && index / 4 == _currentContentIndex / 4 ? YES : NO;
    [self.scrollView scrollRectToVisible:CGRectMake(self.scrollView.frame.size.width * index, 0, self.scrollView.frame.size.width, self.scrollView.frame.size.height) animated:animate];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self refreshScrollViewContentSize];
    [self.contentViewControllerHeap enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        UIViewController *vc = obj;
        CGRect frame = vc.view.frame;
        frame.origin.x = self.scrollView.frame.size.width * idx;
        vc.view.frame = frame;
        [self.scrollView addSubview:vc.view];
    }];
    self.scrollView.delegate = self;
    
    self.bgView.layer.masksToBounds = YES;
    self.bgView.layer.cornerRadius = 5.0f;
    
    self.scrollView.scrollsToTop = NO;
}

- (id)init {
    self = [super init];
    if(self) {
        _contentViewControllerHeap = [[NSMutableArray alloc] init];
        _contentViewIndentifierHeap = [[NSMutableArray alloc] init];
    }
    return self;
}
- (id)initWithLabelIdentifiers:(NSArray *)identifiers andUsers:(NSDictionary *)userDict andWXDelegate:(id<sendMsgToWeChatViewDelegate>) var_delegate{
    NSLog(@"ln content view did load");

    self = [self init];
    if(self) {
        self.delegateWX = var_delegate;
        for(NSString *identifier in identifiers) {
            [self addUserContentViewWithIndentifier:identifier andUsers:userDict];
        }
    }
    return self;
    
}

- (id)initWithLabelIdentifiers:(NSArray *)identifiers andUsers:(NSDictionary *)userDict {
    self = [self init];
    if(self) {
        NSLog(@"ln root view controller");

        for(NSString *identifier in identifiers) {
            [self addUserContentViewWithIndentifier:identifier andUsers:userDict];
        }
    }
    return self;
}

- (void)addLastContentViewToScrollView {
    [self refreshScrollViewContentSize];
    UIViewController *vc = [self.contentViewControllerHeap lastObject];
    CGRect frame = vc.view.frame;
    frame.origin.x = self.scrollView.frame.size.width * (self.contentViewCount - 1);
    vc.view.frame = frame;
    [self.scrollView addSubview:vc.view];
}

- (void)removeContentViewAtIndexFromScrollView:(NSUInteger)index {
    UIViewController *vc = [self.contentViewControllerHeap objectAtIndex:index];
    [vc.view removeFromSuperview];
    [self.contentViewControllerHeap enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if(idx > index) {
            UIViewController *vc = obj;
            CGRect frame = vc.view.frame;
            frame.origin.x -= self.scrollView.frame.size.width;
            vc.view.frame = frame;
        }
    }];
    [self.contentViewControllerHeap removeObjectAtIndex:index];
    [self refreshScrollViewContentSize];
    if(_currentContentIndex == index) {
        self.currentContentIndex = self.currentContentIndex - 1;
    }

}

- (id)addContentViewWithIndentifier:(NSString *)identifier andUsers:(NSDictionary *)userDict {

    id result = nil;
    if([identifier isEqualToString:kChildAllSelfNewFeed]) {
//        result = [NewFeedListController getNewFeedListControllerwithStyle:kAllSelfFeed];
        NSLog(@"all feed");
        result = [NewFeedListController getNewFeedListControllerwithStyle:kAllSelfFeed andWXDelegate:self.delegateWX];
//          result = [NewFeedListController getNewFeedListControllerwithStyle:kAllSelfFeed andWXDelegate:self];

    }
    else if([identifier isEqualToString:kChildRenrenSelfNewFeed]) {
//        result = [NewFeedListController getNewFeedListControllerwithStyle:kRenrenSelfFeed];
        result = [NewFeedListController getNewFeedListControllerwithStyle:kRenrenSelfFeed andWXDelegate:self.delegateWX];

    }
    else if([identifier isEqualToString:kChildWeiboSelfNewFeed]) {
//        result = [NewFeedListController getNewFeedListControllerwithStyle:kWeiboSelfFeed];
        result = [NewFeedListController getNewFeedListControllerwithStyle:kWeiboSelfFeed andWXDelegate:self.delegateWX];

    }
    else if([identifier isEqualToString:kChildRenrenFriend]) {
        result = [FriendListViewController getNewFeedListControllerWithType:RelationshipViewTypeRenrenFriends];
    }
    else if([identifier isEqualToString:kChildWeiboFriend] || [identifier isEqualToString:kChildCurrentWeiboFriend]) {
        NSLog(@"weibo friend");
        result = [FriendListViewController getNewFeedListControllerWithType:RelationshipViewTypeWeiboFriends];
    }
    else if([identifier isEqualToString:kChildWeiboFollower] || [identifier isEqualToString:kChildCurrentWeiboFollower]) {
        result = [FriendListViewController getNewFeedListControllerWithType:RelationshipViewTypeWeiboFollowers];
    }
    else if([identifier isEqualToString:kChildRenrenNewFeed]) {
//        result = [NewFeedListController getNewFeedListControllerwithStyle:kRenrenUserFeed];
        result = [NewFeedListController getNewFeedListControllerwithStyle:kRenrenUserFeed andWXDelegate:self.delegateWX];

    }
    else if([identifier isEqualToString:kChildWeiboNewFeed]) {
//        result = [NewFeedListController getNewFeedListControllerwithStyle:kWeiboUserFeed];
        result = [NewFeedListController getNewFeedListControllerwithStyle:kWeiboUserFeed andWXDelegate:self.delegateWX];

    }
    else if([identifier isEqualToString:kParentPublication]) {
        result = [[[PublicationViewController alloc] init] autorelease];
    }
    else if([identifier isEqualToString:kChildWeiboInfo] || [identifier isEqualToString:kChildCurrentWeiboInfo]) {
        result = [UserInfoViewController getUserInfoViewControllerWithType:kWeiboUserInfo];
    }
    else if([identifier isEqualToString:kChildRenrenInfo] || [identifier isEqualToString:kChildCurrentRenrenInfo]) {
        result = [UserInfoViewController getUserInfoViewControllerWithType:kRenrenUserInfo];
    }
    else {
      //  NSLog(@"nil identifier:%@", identifier);
        abort();
    }
    if([result isKindOfClass:[CoreDataViewController class]]) {
        ((CoreDataViewController *)result).userDict = userDict;
    }
    return result;
}

#pragma mark - weixin delegate
-(void)sendTextContent:(NSString *)nsText{
    NSLog(@"ln content %@",nsText);
}


- (void)forceRefreshScrollsToTopProperty {
    [_contentViewControllerHeap enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        UIViewController *vc = obj;
        if([vc isKindOfClass:[EGOTableViewController class]]) {
            EGOTableViewController *ego = (EGOTableViewController *)vc;
            if(idx == self.currentContentIndex)
                ego.tableView.scrollsToTop = YES;
            else 
                ego.tableView.scrollsToTop = NO;
        }
    }];
}

- (void)setCurrentContentIndex:(NSUInteger)currentContentIndex {
    if(currentContentIndex >= self.contentViewControllerHeap.count)
        return;
    if(currentContentIndex == _currentContentIndex)
        return;
    [self scrollContentViewAtIndexPathToVisble:currentContentIndex animated:YES];
    _currentContentIndex = currentContentIndex;
    [self forceRefreshScrollsToTopProperty];
}

- (NSUInteger)contentViewCount {
    return self.contentViewControllerHeap.count;
}

- (BOOL)isFake{
    return (self.contentViewCount == 0);
}

- (void)setContentViewAtIndex:(NSUInteger)index forIdentifier:(NSString *)identifier {
    if(index >= self.contentViewControllerHeap.count)
        return;
    NSString *currentIdentifier = [self.contentViewIndentifierHeap objectAtIndex:index];
    if([currentIdentifier isEqualToString:identifier])
        return;
    CoreDataViewController *vc = [self.contentViewControllerHeap objectAtIndex:index];

    CoreDataViewController *vc2 = [self addContentViewWithIndentifier:identifier andUsers:vc.userDict];
    NSLog(@"vc2______!!");
    
    if(vc2 == nil)
        return;
    if(identifier == nil) {
     //   NSLog(@"replaceObjectAtIndex! identifier nil!");
        abort();
    }
//    vc2.delegateWX = self.delegateWX;
    vc2.view.frame = vc.view.frame;
    [vc.view removeFromSuperview];
    [self.scrollView addSubview:vc2.view];
    [self.contentViewControllerHeap replaceObjectAtIndex:index withObject:vc2];
    [self.contentViewIndentifierHeap replaceObjectAtIndex:index withObject:identifier];
    
    if([vc2 isKindOfClass:[EGOTableViewController class]]) {
        EGOTableViewController *vc = (EGOTableViewController *)vc2;
        vc.tableView.scrollsToTop = YES;
    }
}

- (void)addUserContentViewWithIndentifier:(NSString *)identifier andUsers:(NSDictionary *)userDict {
    NSString *childIdentifier = [LabelConverter getDefaultChildIdentifierWithParentIdentifier:identifier];
    NSLog(@"add user content view with id");

    id vc = [self addContentViewWithIndentifier:childIdentifier andUsers:userDict];
    if(!vc)
        return;
    [self.contentViewControllerHeap addObject:vc];
    [self addLastContentViewToScrollView];
    [self.contentViewIndentifierHeap addObject:childIdentifier];
}

- (void)removeContentViewAtIndex:(NSUInteger)index {
    [self removeContentViewAtIndexFromScrollView:index];
    [self.contentViewIndentifierHeap removeObjectAtIndex:index];
    if(self.currentContentIndex >= index)
        self.currentContentIndex = self.currentContentIndex - 1;
}

- (NSString *)currentContentIdentifierAtIndex:(NSUInteger)index {
    NSString *result = [self.contentViewIndentifierHeap objectAtIndex:index];
    return result;
}

#pragma mark -
#pragma mark UIScrollView delegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    int index = fabs(scrollView.contentOffset.x) / scrollView.frame.size.width;
    if(index < 0 || index >= self.contentViewCount)
        return;
    self.currentContentIndex = index;
    if([self.delegate respondsToSelector:@selector(contentViewController:didScrollToIndex:)]) {
        [self.delegate contentViewController:self didScrollToIndex:index];
    }
}

@end
