//
//  FriendListViewController.m
//  SocialFusion
//
//  Created by 王紫川 on 11-10-4.
//  Copyright 2011年 Tongji Apple Club. All rights reserved.
//

#import "FriendListViewController.h"
#import "FriendListTableViewCell.h"
#import "RenrenUser.h"
#import "WeiboUser.h"
#import "Image+Addition.h"
#import "UIImageView+Addition.h"
#import "User+Addition.h"
#import "FriendListRenrenViewController.h"
#import "FriendListWeiboViewController.h"
#import "NSNotificationCenter+Addition.h"
#import "LeaveMessageViewController.h"
#import "UIApplication+Addition.h"


@interface FriendListViewController (){
    
}
- (void)updateTableView ;
- (NSArray *)getAllRenrenUserArrayWithHint:(NSString *)text ;
- (void)setScreenNamesWithArray:(NSArray *)array ;
- (NSArray *)getAllWeiboUserArrayWithHint:(NSString *)text ;


@end 

@implementation FriendListViewController

#pragma mark -
#pragma mark Memory management
@synthesize textField;

- (void)dealloc {
    [_atScreenNames release];
    [textField release];
    [super dealloc];
}

- (void)viewDidUnload {
    [self setTextField:nil];
    [super viewDidUnload];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.textField.text = @"";
}

+ (FriendListViewController *)getNewFeedListControllerWithType:(RelationshipViewType)type {
    FriendListViewController *result;
    if(type == RelationshipViewTypeRenrenFriends) {
        result = [[FriendListRenrenViewController alloc] initWithType:type];
    }
    else {
        result = [[FriendListWeiboViewController alloc] initWithType:type];
    }
    [result autorelease];
    return result;
}

#pragma mark -
#pragma mark NSFetchRequestController

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    FriendListTableViewCell *relationshipCell = (FriendListTableViewCell *)cell;
    relationshipCell.delegate = self;
    relationshipCell.headImageView.image = nil;
    relationshipCell.latestStatus.text = nil;
    User *usr ;
    if (self.textField.text.length == 0 ) {
        usr = [self.fetchedResultsController objectAtIndexPath:indexPath];
    }else {
        NSLog(@"configurecell %d   %d"   ,indexPath.row , _atScreenNames.count);
        
        usr =   [_atScreenNames objectAtIndex:[indexPath row]];
    }
    
    relationshipCell.userName.text = usr.name;
    
    NSData *imageData = nil;
    if([Image imageWithURL:usr.tinyURL inManagedObjectContext:self.managedObjectContext]) {
        imageData = [Image imageWithURL:usr.tinyURL inManagedObjectContext:self.managedObjectContext].imageData.data;
    }
    if(imageData == nil) {
        if(self.tableView.dragging == NO && self.tableView.decelerating == NO) {
            if(indexPath.row < kCustomRowCount) {
                [relationshipCell.headImageView loadImageFromURL:usr.tinyURL completion:^{
                    [relationshipCell.headImageView fadeIn];
                } cacheInContext:self.managedObjectContext];
            }
        }
    }
    else {
        relationshipCell.headImageView.image = [UIImage imageWithData:imageData];
    }
    
}

- (NSString *)customCellClassName
{
    return @"FriendListTableViewCell";
}

#pragma mark -
#pragma mark UITableView delegates

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    // 清空选中状态
    cell.highlighted = NO;
    cell.selected = NO;
    User *usr ;
    
    if (self.textField.text.length == 0  ) {
        usr = [self.fetchedResultsController objectAtIndexPath:indexPath];
    }else{
        NSLog(@"%d   %d"   ,indexPath.row , _atScreenNames.count);
        usr = [_atScreenNames objectAtIndex:indexPath.row];
        
    }
    
    NSMutableDictionary *userDict = [NSMutableDictionary dictionaryWithDictionary:self.currentUserDict];
    if([usr isMemberOfClass:[RenrenUser class]])
        [userDict setObject:usr forKey:kRenrenUser];
    else if([usr isMemberOfClass:[WeiboUser class]]) 
        [userDict setObject:usr forKey:kWeiboUser];
    [NSNotificationCenter postSelectFriendNotificationWithUserDict:userDict];
    [self.textField becomeFirstResponder];
    [self.textField resignFirstResponder];
    
}

#pragma mark -
#pragma mark Animations

- (void)loadExtraDataForOnScreenRowsHelp:(NSIndexPath *)indexPath {
    if(self.tableView.dragging || self.tableView.decelerating || _reloadingFlag)
        return;
    User *usr ;
    
    if (self.textField.text.length == 0  ) {
        usr = [self.fetchedResultsController objectAtIndexPath:indexPath];
    }else{
        NSLog(@"loadextradataforonscreenrowshelp %d   %d"   ,indexPath.row , _atScreenNames.count);
        
        usr = [_atScreenNames objectAtIndex:indexPath.row];
    }
    Image *image = [Image imageWithURL:usr.tinyURL inManagedObjectContext:self.managedObjectContext];
    if (image == nil)
    {
        FriendListTableViewCell *relationshipCell = (FriendListTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
        [relationshipCell.headImageView loadImageFromURL:usr.tinyURL completion:^{
            [relationshipCell.headImageView fadeIn];
        } cacheInContext:self.managedObjectContext];
    }
}

- (void)updateCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {    
    User *usr ;
    
    if (self.textField.text.length == 0  ) {
        usr = [self.fetchedResultsController objectAtIndexPath:indexPath];
    }else{
        NSLog(@"updatecell %d   %d"   ,indexPath.row , _atScreenNames.count);
        
        if (  indexPath.row < _atScreenNames.count    ) {
            usr = [_atScreenNames objectAtIndex:indexPath.row];
            
        }else{
            return;
        }
    }
    
    FriendListTableViewCell *relationshipCell = (FriendListTableViewCell *)cell;
    
    //NSLog(@"update user name:%@", usr.name);
    if(![relationshipCell.latestStatus.text isEqualToString:usr.latestStatus]) {
        relationshipCell.latestStatus.text = usr.latestStatus;
        relationshipCell.latestStatus.alpha = 0.3f;
        [UIView animateWithDuration:0.3f delay:0 options:UIViewAnimationOptionAllowUserInteraction animations:^(void) {
            relationshipCell.latestStatus.alpha = 1;
        } completion:nil];
    }
}

#pragma mark -
#pragma mark FriendListTableViewCell delegate

- (void)frientListCellDidClickChatButton:(FriendListTableViewCell *)cell {
    if(_type == RelationshipViewTypeRenrenFriends)
        [[UIApplication sharedApplication] presentToast:@"当前版本暂不支持留言。" withVerticalPos:kToastBottomVerticalPosition];
    else
        [[UIApplication sharedApplication] presentToast:@"当前版本暂不支持私信。" withVerticalPos:kToastBottomVerticalPosition];
    return;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    User *usr ;
    
    if (self.textField.text.length == 0  ) {
        usr = [self.fetchedResultsController objectAtIndexPath:indexPath];
    }else{
        usr = [_atScreenNames objectAtIndex:indexPath.row];
    }
    LeaveMessageViewController *vc = [[LeaveMessageViewController alloc] initWithUser:usr];
    [[UIApplication sharedApplication] presentModalViewController:vc];
    [vc release];
}
#pragma mark -
#pragma mark tf delegate

- (IBAction)atTextFieldEditingChanged:(UITextField*)textField {
    if (self.textField.text.length!=0) {
        [self updateTableView];
    }else{
        [self showEGOHeaderView];
        [self.tableView reloadData];
    }
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{	
    if (self.textField.text.length == 0) {
        [super scrollViewDidScroll:scrollView];
    }
    [self.textField becomeFirstResponder];
    [self.textField resignFirstResponder];
    
    
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {	
    if (self.textField.text.length == 0) {
        [self.egoHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
    }
    
}
-(void)dismissEGOHeaderView{
    self.egoHeaderView.hidden = YES;
    [self hideLoadMoreDataButton];
}

-(void)showEGOHeaderView{
    self.egoHeaderView.hidden = NO;
    [self showLoadMoreDataButton];
}


- (void)updateTableView {
    [self dismissEGOHeaderView];
    
    if (_atScreenNames) {
        [_atScreenNames removeAllObjects];
    }
    else {
        _atScreenNames = [[NSMutableArray alloc] init];
    }
    NSArray *array ;
    if(_type == RelationshipViewTypeRenrenFriends){
        array = [self getAllRenrenUserArrayWithHint:self.textField.text];
    } 
    else{
        array = [self getAllWeiboUserArrayWithHint:self.textField.text];
    }
    [self setScreenNamesWithArray:array];
    [self.tableView reloadData];
}

- (void)setScreenNamesWithArray:(NSArray *)array {
    for (int i = 0; i < [array count]; i++) {
        User *usr = [array objectAtIndex:i];
        [_atScreenNames addObject:usr];
    }
}
- (NSArray *)getAllWeiboUserArrayWithHint:(NSString *)text {
    
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"WeiboUser" inManagedObjectContext:self.managedObjectContext];
    
    NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
    [request setEntity:entityDescription];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:[[[NSString alloc] initWithFormat:@"name like[c] \"*%@*\"", text] autorelease]];
    NSPredicate *predicate2 = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"pinyinName like[c] \"*%@*\"", text]];
    NSPredicate *compoundPredicate = [NSCompoundPredicate orPredicateWithSubpredicates:[NSArray arrayWithObjects:predicate, predicate2, nil]];
    
    [request setPredicate:compoundPredicate];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    
    [request setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    [sortDescriptor release];
    NSError *error;
    NSArray *array = [self.managedObjectContext executeFetchRequest:request error:&error];
    if (error) {
        NSLog(@"error");
    }
    return array;
    
}

- (NSArray *)getAllRenrenUserArrayWithHint:(NSString *)text {
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"RenrenUser" inManagedObjectContext:self.managedObjectContext];
    
    NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
    [request setEntity:entityDescription];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"name like[c] \"*%@*\"", text]];
    NSPredicate *predicate2 = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"pinyinName like[c] \"*%@*\"", text]];
    NSPredicate *compoundPredicate = [NSCompoundPredicate orPredicateWithSubpredicates:[NSArray arrayWithObjects:predicate, predicate2, nil]];
    
    [request setPredicate:compoundPredicate];
    
    NSSortDescriptor *sort = [[[NSSortDescriptor alloc] initWithKey:@"pinyinNameFirstLetter" ascending:YES] autorelease];
    NSSortDescriptor *sort2 = [[[NSSortDescriptor alloc] initWithKey:@"firstName" ascending:YES] autorelease];
    NSSortDescriptor *sort3 = [[[NSSortDescriptor alloc] initWithKey:@"pinyinName" ascending:YES] autorelease];
    NSArray *descriptors = [NSArray arrayWithObjects:sort, sort2, sort3, nil];
    [request setSortDescriptors:descriptors];
    
    NSError *error;
    NSArray *array = [self.managedObjectContext executeFetchRequest:request error:&error];
    return array;
}

#pragma mark - 
#pragma mark UITableView data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.textField.text.length == 0 ) {
        return [super tableView:tableView numberOfRowsInSection:section];
    }
    else {
        return [_atScreenNames count];
    }
    
}


@end
