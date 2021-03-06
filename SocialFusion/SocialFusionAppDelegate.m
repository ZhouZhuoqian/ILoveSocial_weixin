//
//  SocialFusionAppDelegate.m
//  SocialFusion
//
//  Created by He Ruoyun on 11-8-8.
//  Copyright 2011年 Tongji Apple Club. All rights reserved.
//

#import "SocialFusionAppDelegate.h"
#import "LNRootViewController.h"



@interface SocialFusionAppDelegate () {

}
-(void) onRequestAppMessage;
-(void) onShowMediaMessage:(WXMediaMessage *) message;

@end    



@implementation SocialFusionAppDelegate

@synthesize window = _window;
@synthesize rootViewController = _rootViewController;

@synthesize managedObjectContext = __managedObjectContext;
@synthesize managedObjectModel = __managedObjectModel;  
@synthesize persistentStoreCoordinator = __persistentStoreCoordinator;



-(BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url{
    
    return     [WXApi handleOpenURL:url delegate:self];
}


-(void)registerPushNotification:(UIApplication *)application{
    
//    http://marshal.easymorse.com/archives/3312
    
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0]; 
    NSLog(@"Initiating remoteNoticationssAreActive"); 
    if(!application.enabledRemoteNotificationTypes){ 
        NSLog(@"Initiating remoteNoticationssAreActive1"); 
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeBadge)]; 
    } 
    UIApplication* myapp = [UIApplication sharedApplication]; 
    myapp.idleTimerDisabled = YES; 
     
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    _rootViewController = [[LNRootViewController alloc] init];
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:_rootViewController];
    _rootViewController.managedObjectContext = self.managedObjectContext;
    _rootViewController.delegateWX = self;
    NSLog(@"delegate");
    
    [self    registerPushNotification:application];
        
    navigationController.navigationBarHidden = YES;
    self.window.rootViewController = navigationController;
        
    [self.window makeKeyAndVisible];
    
    // Override point for customization after application launch.   
    //向微信注册
    //    [WXApi registerApp:@"wxd930ea5d5a258f4f"]; 
    [WXApi registerApp:@"wx78f05407662e57d6"]; 
    
    return YES;
}

 
 

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
    [self saveContext];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
    // NSLog(@"%@",self.viewController.managedObjectContext);
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
    [self saveContext];
}

- (void)dealloc
{
    [super dealloc];
    [_window release];
    [_rootViewController release];
    [self.managedObjectModel release];
    [self.managedObjectContext release];
    [self.persistentStoreCoordinator release]; 
}


//相当于持久化方法  
- (void)saveContext  
{  
    NSError *error = nil;  
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;  
    if (managedObjectContext != nil)  
    {  
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error])  
        {  
            /* 
             Replace this implementation with code to handle the error appropriately. 
             
             abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button. 
             */  
            // NSLog(@"Unresolved error %@, %@", error, [error userInfo]);  
            abort();  
        }   
    }  
}  


#pragma mark - Core Data stack 

- (void)clearAllData {
    NSPersistentStore *store = nil;
    NSError *error;
    NSURL *storeURL = store.URL;
    NSPersistentStoreCoordinator *storeCoordinator = [self persistentStoreCoordinator];
    [storeCoordinator removePersistentStore:store error:&error];
    [[NSFileManager defaultManager] removeItemAtPath:storeURL.path error:&error];
}

/** 
 Returns the managed object context for the application. 
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application. 
 */  

//初始化context对象  
- (NSManagedObjectContext *)managedObjectContext  
{  
    if (__managedObjectContext != nil)  
    {  
        return __managedObjectContext;  
    }  
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];  
    if (coordinator != nil)  
    {  
        __managedObjectContext = [[NSManagedObjectContext alloc] init];  
        [__managedObjectContext setPersistentStoreCoordinator:coordinator];  
    }  
    return __managedObjectContext;  
}  

/** 
 Returns the managed object model for the application. 
 If the model doesn't already exist, it is created from the application's model. 
 */  
- (NSManagedObjectModel *)managedObjectModel  
{  
    if (__managedObjectModel != nil)  
    {  
        return __managedObjectModel;  
    }  
    //这里的URLForResource:@"lich" 的url名字（lich）要和你建立datamodel时候取的名字是一样的，至于怎么建datamodel很多教程讲的很清楚  
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"SocialFusion" withExtension:@"momd"];  
    __managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];      
    return __managedObjectModel;  
}  

/** 
 Returns the persistent store coordinator for the application. 
 If the coordinator doesn't already exist, it is created and the application's store added to it. 
 */  
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator  
{  
    if (__persistentStoreCoordinator != nil)
    {
        return __persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"SocialFusion.sqlite"];
    
    //
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
    
    NSError *error = nil;
    __persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![__persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error])
    {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter: 
         [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        //   NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }    
    
    return __persistentStoreCoordinator;
}  

#pragma mark - Application's Documents directory  

/** 
 Returns the URL to the application's Documents directory. 
 */  
- (NSURL *)applicationDocumentsDirectory  
{  
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];  
}  
#pragma mark - weixin api delegate
-(void) onReq:(BaseReq*)req{
    //    onReq是微信终端向第三方程序发起请求，要求第三方程序响应。第三方程序响应完后必须调用sendRsp返回。在调用sendRsp返回时，会切回到微信终端程序界面。
    
    
    if (NO) {
        if([req isKindOfClass:[GetMessageFromWXReq class]])
        {
            [self onRequestAppMessage];
        }
        else if([req isKindOfClass:[ShowMessageFromWXReq class]])
        {
            ShowMessageFromWXReq* temp = (ShowMessageFromWXReq*)req;
            [self onShowMediaMessage:temp.message]; 
        }
        
    }
    
    
}


-(void) onResp:(BaseResp*)resp{
    
    //    如果第三方程序向微信发送了sendReq的请求，那么onResp会被回调。sendReq请求调用后，会切到微信终端程序界面。
    
    
    
    if([resp isKindOfClass:[SendMessageToWXResp class]])
    {
        NSString *strTitle = [NSString stringWithFormat:@"发送结果"];
        NSString *strMsg = [NSString stringWithFormat:@"发送媒体消息结果:%d", resp.errCode];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:strTitle message:strMsg delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        [alert release];
    }
    else if([resp isKindOfClass:[SendAuthResp class]])
    {
        NSString *strTitle = [NSString stringWithFormat:@"Auth结果"];
        NSString *strMsg = [NSString stringWithFormat:@"Auth结果:%d", resp.errCode];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:strTitle message:strMsg delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        [alert release];
    }
    
    
}


-(void) onRequestAppMessage
{
    // 微信请求App提供内容， 需要app提供内容后使用sendRsp返回
    
    //    RespForWeChatViewController* controller = [[RespForWeChatViewController alloc]autorelease];
    //    controller.delegate = self;
    //    [self.viewController presentModalViewController:controller animated:YES];
    
}

-(void) onShowMediaMessage:(WXMediaMessage *) message
{
    // 微信启动， 有消息内容。
    //    [self viewContent:message];
}



- (void) viewContent:(WXMediaMessage *) msg
{
    if (NO) {
        
        //显示微信传过来的内容    
        WXAppExtendObject *obj = msg.mediaObject;
        NSString *strTitle = [NSString stringWithFormat:@"消息来自微信"];
        NSString *strMsg = [NSString stringWithFormat:@"标题：%@ \n内容：%@ \n附带信息：%@ \n缩略图:%u bytes\n\n", msg.title, msg.description, obj.extInfo, msg.thumbData.length];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:strTitle message:strMsg delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];    
        [alert show];
        [alert release];
    } 
    
    
}



#pragma mark - sendmsg to wechat delegate

// send msg to weixin
- (void) sendTextContent:(NSString*)nsText
{
    nsText = [CommonFunction subStringToOneK:nsText withMaxLength:1000*10];
    NSLog(@"__________%@",nsText);
    
    // request
    SendMessageToWXReq* req = [[[SendMessageToWXReq alloc] init]autorelease];
    req.bText = YES;
    req.text = nsText;
    // send request
    if (YES) {
        [WXApi sendReq:req];
    }
    
}

-(WXImageObject * )getWXImageExt : (NSData *) imagedata{
    
    NSLog(@"send image content");
    WXImageObject *ext = [WXImageObject object];
    ext.imageData = imagedata ;
    NSLog(@"imagedata length = %i", [imagedata length]);
    return ext;
    
}

-(void)sendImageContentWith:(UIImage *)image{
    
    //发送内容给微信
    WXMediaMessage *message = [WXMediaMessage message];
    //    [message setThumbImage:image];
    
    message.mediaObject = [self getWXImageExt: UIImageJPEGRepresentation(image, 1.0)];
    
    
    SendMessageToWXReq* req = [[[SendMessageToWXReq alloc] init]autorelease];
    req.bText = NO;
    req.message = message;
    [WXApi sendReq:req];
}


-(void)sendImageContent:(NSData *)imagedata{
    //发送内容给微信
    WXMediaMessage *message = [WXMediaMessage message];
    [message setThumbImage:[UIImage imageWithData:imagedata]];
    message.mediaObject = [self getWXImageExt:imagedata];
    SendMessageToWXReq* req = [[[SendMessageToWXReq alloc] init]autorelease];
    req.bText = NO;
    req.message = message;
    [WXApi sendReq:req];
    
    
}

-(void)sendImageContentWithString:(NSString *)urlString{
    //发送内容给微信
    NSLog(@"image url : %@",urlString);
    if (YES) {
        
        WXMediaMessage *message = [WXMediaMessage message];
        WXImageObject *ext = [WXImageObject object];
        ext.imageUrl = urlString;
        message.mediaObject = ext;
        SendMessageToWXReq* req = [[[SendMessageToWXReq alloc] init]autorelease];
        req.bText = NO;
        req.message = message;
        [WXApi sendReq:req];
        
    }else {
        
        [self sendImageContent:[NSData dataWithContentsOfURL:[NSURL URLWithString:urlString]]];
        
    }
    
}

-(void)sendImageContent:(NSData *)imagedata withTextMsg:(NSString *)msg andBigImageUrl:(NSString *)bigImageUrl{
    
    NSLog(@"SEND IMAGE CONTENT");
    
    msg = [CommonFunction subStringToOneK:msg withMaxLength:1000];
    
    NSLog(@"__________%@",msg);
    
    
    WXMediaMessage *message = [WXMediaMessage message];
    SendMessageToWXReq* req = [[[SendMessageToWXReq alloc] init]autorelease];
    
    //    message.title = @"麦当劳“销售过期食品”其实不是卫生问题";
    message.title = @"转发";
    
    message.description = msg;
    //    if (NO) {
    //        [message setThumbImage:[UIImage imageNamed:@"res2.jpg"]];
    //    }else {
    [message setThumbImage:[UIImage imageWithData: imagedata  ]];
    //    }
    
    WXWebpageObject *ext = [WXWebpageObject object];
    ext.webpageUrl = bigImageUrl;
    message.mediaObject = ext;
    
    req.bText = NO;
    req.message = message;
    
    [WXApi sendReq:req];
    
    if (YES) {
        [WXApi sendReq:req];
        
    }
    
}

- (void) sendAppContent{
    NSLog(@"send app content");
}

-(void)sendNewsContent:(NSString *)title withDetail:(NSString *)blogDetail withImageUrl:(NSString *)url withBigImageUrl : (NSString *) big_image_url{
    
    NSLog(@"%@",blogDetail);
    blogDetail = [CommonFunction subStringToOneK:blogDetail withMaxLength:1000];
    
    WXMediaMessage *message = [WXMediaMessage message];
    message.title = title;
    [message setThumbImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:url]]]];
    
    NSLog(@"____%@",title);
    
    NSLog(@"%@",blogDetail);
    message.description = blogDetail;
    [message setThumbImage:[UIImage imageNamed:@"res2.jpg"]];
    
    WXWebpageObject *ext = [WXWebpageObject object];
    ext.webpageUrl = big_image_url;
    message.mediaObject = ext;
    
    SendMessageToWXReq* req = [[[SendMessageToWXReq alloc] init]autorelease];
    req.bText = NO;
    req.message = message;
    
    [WXApi sendReq:req];
    
}

-(void)sendNewsContent:(NSString *)title withDetail:(NSString *)blogDetail withUrl:(NSString *)url{
    
    NSLog(@"%@",blogDetail);
    blogDetail = [CommonFunction subStringToOneK:blogDetail withMaxLength:1000];
    
    WXMediaMessage *message = [WXMediaMessage message];
    message.title = title;
    
    NSLog(@"____%@",title);
    
    NSLog(@"%@",blogDetail);
    message.description = blogDetail;
    [message setThumbImage:[UIImage imageNamed:@"res2.jpg"]];
    
    WXWebpageObject *ext = [WXWebpageObject object];
    ext.webpageUrl = url;
    message.mediaObject = ext;
    
    SendMessageToWXReq* req = [[[SendMessageToWXReq alloc] init]autorelease];
    req.bText = NO;
    req.message = message;
    
    [WXApi sendReq:req];
}



-(void)sendVideoContent{
    
}
-(void)doAuth{
    SendAuthReq* req = [[[SendAuthReq alloc] init] autorelease];
    req.scope = @"username,post_timeline";
    req.state = @"xxx";
    
    [WXApi sendReq:req];
    
}

@end
