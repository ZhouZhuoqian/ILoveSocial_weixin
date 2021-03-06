//
//  SocialFusionAppDelegate.h
//  SocialFusion
//
//  Created by He Ruoyun on 11-8-8.
//  Copyright 2011年 Tongji Apple Club. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WXApi.h"
#import "StatusDetailController.h"
#import "CommonFunction.h"
#import "AwesomeMenu.h"


//@protocol sendMsgToWeChatViewDelegate;

@class LNRootViewController;
@interface SocialFusionAppDelegate : NSObject <UIApplicationDelegate,WXApiDelegate,sendMsgToWeChatViewDelegate >

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) LNRootViewController *rootViewController;

// core data
@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;  
@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;  
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;  
- (NSURL *)applicationDocumentsDirectory;  
 
@end
