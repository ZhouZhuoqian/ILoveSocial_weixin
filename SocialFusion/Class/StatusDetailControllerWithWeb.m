//
//  StatusDetailControllerWithWeb.m
//  SocialFusion
//
//  Created by He Ruoyun on 12-2-11.
//  Copyright (c) 2012年 Tongji Apple Club. All rights reserved.
//

#import "StatusDetailControllerWithWeb.h"
#import "UIImage+Addition.h"
#import "NSData+NSData_Base64.h"
#import "NSString+DataURI.h"
#import "NewFeedData+NewFeedData_Addition.h"
#import "Image+Addition.h"
#import "NSString+HTMLSet.h"
#import "RepostViewController.h"
#import "UIApplication+Addition.h"
#import "StatusCommentData+StatusCommentData_Addition.h"
#import "DetailImageViewController.h"
#import "CardBrowserViewController.h"



@implementation StatusDetailControllerWithWeb

-(void)dealloc
{
    [_webView release];
    [super dealloc];
}

- (void)loadMainView
{
    _activity=[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    _activity.center=CGPointMake(153, 300);
    [self.view addSubview:_activity];
    [_activity startAnimating];
    [self loadWebView];
}
- (void)loadWebView
{
    _webView.hidden=YES;
    
    
    if ([(NewFeedData*)self.feedData getPostName]==nil)
    {
        if (((NewFeedData*)self.feedData).pic_URL!=nil)
        {
            NSString *infoSouceFile = [[NSBundle mainBundle] pathForResource:@"photocelldetail" ofType:@"html"];
            NSString *infoText = [[NSString alloc] initWithContentsOfFile:infoSouceFile encoding:NSUTF8StringEncoding error:nil];
            infoText = [infoText setWeibo:[((NewFeedData*)self.feedData).message replaceHTMLSignWithoutJS:[((NewFeedData*)self.feedData).style intValue]]];
            
            Image* image = [Image imageWithURL:((NewFeedData*)self.feedData).pic_big_URL inManagedObjectContext:self.managedObjectContext];
            if (!image)
            {
                [UIImage loadImageFromURL:((NewFeedData*)self.feedData).pic_big_URL completion:^{
                    Image *image1 = [Image imageWithURL:((NewFeedData*)self.feedData).pic_big_URL inManagedObjectContext:self.managedObjectContext];
                    
                    _photoData=[[NSData alloc] initWithData: image1.imageData.data];
                    [_webView loadHTMLString:infoText baseURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] resourcePath]]];
                    
                    
                } cacheInContext:self.managedObjectContext];
            }
            else
            {
                _photoData=[[NSData alloc] initWithData: image.imageData.data];
                [_webView loadHTMLString:infoText baseURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] resourcePath]]];
                
            }
            
            
            
            
            [infoText release];
        }
        else
        {
            NSString *infoSouceFile = [[NSBundle mainBundle] pathForResource:@"normalcelldetail" ofType:@"html"];
            NSString *infoText=[[NSString alloc] initWithContentsOfFile:infoSouceFile encoding:NSUTF8StringEncoding error:nil];
            infoText=[infoText setWeibo:[((NewFeedData*)self.feedData).message replaceHTMLSignWithoutJS:[((NewFeedData*)self.feedData).style intValue]]];
            [_webView loadHTMLString:infoText baseURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] resourcePath]]];
            [infoText release];
        }
    }
    else
    {
        if (((NewFeedData*)self.feedData).pic_URL!=nil)
        {
            NSString *infoSouceFile = [[NSBundle mainBundle] pathForResource:@"repostcellwithphotodetail" ofType:@"html"];
            NSString *infoText=[[NSString alloc] initWithContentsOfFile:infoSouceFile encoding:NSUTF8StringEncoding error:nil];
            infoText=[infoText setWeibo:[((NewFeedData*)self.feedData).message replaceHTMLSignWithoutJS:[((NewFeedData*)self.feedData).style intValue]]];
            infoText=[infoText setRepost:[(NewFeedData*)self.feedData getPostMessagewithOutJS]];
            Image* image = [Image imageWithURL:((NewFeedData*)self.feedData).pic_big_URL inManagedObjectContext:self.managedObjectContext];
            if (!image)
            {
                [UIImage loadImageFromURL:((NewFeedData*)self.feedData).pic_big_URL completion:^{
                    Image *image1 = [Image imageWithURL:((NewFeedData*)self.feedData).pic_big_URL inManagedObjectContext:self.managedObjectContext];
                    
                    _photoData=[[NSData alloc] initWithData: image1.imageData.data];
                    [_webView loadHTMLString:infoText baseURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] resourcePath]]];
                    
                    
                } cacheInContext:self.managedObjectContext];
            }
            else
            {
                _photoData=[[NSData alloc] initWithData: image.imageData.data];
                [_webView loadHTMLString:infoText baseURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] resourcePath]]];
                
            }
            
            [infoText release];
        }
        else
        {
            NSString *infoSouceFile = [[NSBundle mainBundle] pathForResource:@"repostcelldetail" ofType:@"html"];
            NSString *infoText=[[NSString alloc] initWithContentsOfFile:infoSouceFile encoding:NSUTF8StringEncoding error:nil];
            infoText=[infoText setWeibo:[((NewFeedData*)self.feedData).message replaceHTMLSignWithoutJS:[((NewFeedData*)self.feedData).style intValue]]];
            infoText=[infoText setRepost:[(NewFeedData*)self.feedData getPostMessagewithOutJS]];
            [_webView loadHTMLString:infoText baseURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] resourcePath]]];
            [infoText release];
        }
    }
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    
    UIImage* image1=[UIImage imageWithData:_photoData];
    
    NSData* imagedata=UIImageJPEGRepresentation(image1, 1.0);
    
    NSString *imgB64 = [[imagedata base64Encoding] jpgDataURIWithContent];
    
    NSString* javascript = [NSString stringWithFormat:@"document.getElementById('upload').src='%@'", imgB64];
    
    [_webView stringByEvaluatingJavaScriptFromString:javascript];
    
    [_webView stringByEvaluatingJavaScriptFromString: @"document.body.scrollHeight"];
    
    
    [_photoData release];
    
    [_activity stopAnimating];
    //[_activity removeFromSuperview];
    [_activity release];
    
    _webView.hidden=NO;
    if( webView.scrollView.contentSize.height<_titleView.frame.size.height+_webView.frame.size.height)
    {
        _webView.scrollView.delegate=nil;
    }
    
}
- (void)setFixedInfo
{
    [super setFixedInfo];
    for (UIView *aView in [_webView subviews])  
    { 
        if ([aView isKindOfClass:[UIScrollView class]])  
        { 
            for (UIView *shadowView in aView.subviews)  
            { 
                if ([shadowView isKindOfClass:[UIImageView class]]) 
                { 
                    shadowView.hidden = YES;  //上下滚动出边界时的黑色的图片 也就是拖拽后的上下阴影
                } 
            } 
        } 
    }  
    _webView.delegate=self;
    _webView.backgroundColor=[UIColor clearColor];
    _webView.opaque=NO;
    _webView.scrollView.delegate=self;
    
}

-(IBAction)repost
{
    NSLog(@"statusdetail controller with web REPOST");
    
    RepostViewController *vc = [[RepostViewController alloc] init];
    vc.managedObjectContext = self.managedObjectContext;
    
    // 转发状态
    if ([self.feedData getStyle]==0)
    {
        [vc setStyle:kRenrenStatus];
    }
    else
    {
        [vc setStyle:kWeiboStatus];
    }
    
    vc.feedData=self.feedData;
    
    [vc setcommentPage:NO];
    [[UIApplication sharedApplication] presentModalViewController:vc];
    [vc release];
}

-(IBAction)repostToWeixin:(id)sender{
    
    
    
    NSLog(@"repost to weixin __ web");
    // todo
    NewFeedData * newFeedData = (NewFeedData*)self.feedData;
    NSString * outString;
    
    if ([newFeedData getStyle]==0)
    {
        NSLog(@"renren");
        if (newFeedData.repost_ID!=nil){
            NSLog(@"repo id");
            
            outString = [NSString stringWithFormat:@"%@:%@ [来自人人网]", 
                        newFeedData.repost_Name  , newFeedData.repost_Status];
            
        }else{
            
            outString=[NSString stringWithFormat:@"%@:%@ [来自人人网]",[newFeedData.author name],newFeedData.message];
            
        }
        
        
    }else{       
        NSLog(@"weibo");
        if (newFeedData.repost_ID!=nil){
            NSLog(@"repo id");
            outString = [NSString stringWithFormat:@"//@%@:%@转自%@：%@ [来自新浪微博]", [self.feedData.author name]  , newFeedData.message,newFeedData.repost_Name,newFeedData.repost_Status];
        }else{
            outString = [NSString stringWithFormat:@"//@%@:%@ [来自新浪微博]",[self.feedData.author name] , newFeedData.message];
        }
        
    }
    
    
    if (newFeedData.pic_URL!=nil){
        NSData *imageData = nil;
        
        if (NO) {
            Image *image = [Image imageWithURL:newFeedData.pic_big_URL inManagedObjectContext:self.managedObjectContext];
            if (image==nil)
            {
                imageData = [Image imageWithURL:newFeedData.pic_big_URL  inManagedObjectContext:self.managedObjectContext].imageData.data;
            }else
            {
                imageData=image.imageData.data;
            }
            
        }else {
            Image *image = [Image imageWithURL:newFeedData.pic_URL inManagedObjectContext:self.managedObjectContext];
            if (image==nil)
            {
                imageData = [Image imageWithURL:newFeedData.pic_URL  inManagedObjectContext:self.managedObjectContext].imageData.data;
            }else
            {
                imageData=image.imageData.data;
            }
            
        }
        if ([outString length] <=0 || [imageData length]<=0 ) {
            
            [[UIApplication sharedApplication] presentToast:@"正在载入数据,请稍后" withVerticalPos:kToastBottomVerticalPosition];

        }else {
            [[UIApplication sharedApplication] presentToast:@"已发送" withVerticalPos:kToastBottomVerticalPosition];
            [self.delegateWX sendImageContent:imageData withTextMsg:outString andBigImageUrl:newFeedData.pic_big_URL];

        }
        
    }else {
        
        if ([outString length] <=0   ) {
            [[UIApplication sharedApplication] presentToast:@"正在载入数据,请稍后" withVerticalPos:kToastBottomVerticalPosition];

            
        }else {
            [[UIApplication sharedApplication] presentToast:@"已发送" withVerticalPos:kToastBottomVerticalPosition];
            [self.delegateWX sendTextContent:outString];
            
        }
        
    }
    
    
}
-(IBAction)comment:(id)sender
{
    UITableViewCell* cell=(UITableViewCell*)((UIButton*)sender).superview.superview;
    NSIndexPath* indexPath=[self.tableView indexPathForCell:cell];
    
    StatusCommentData* data=[self.fetchedResultsController objectAtIndexPath:indexPath];
    
    RepostViewController *vc = [[RepostViewController alloc] init];
    vc.managedObjectContext = self.managedObjectContext;
    // 评论状态
    if ([self.feedData getStyle]==0)
    {
        [vc setStyle:kRenrenStatus];
    }
    else
    {
        [vc setStyle:kWeiboStatus];
    }
    [vc setcommentPage:YES];
    vc.feedData=self.feedData;
    vc.commetData=data;
    
    [[UIApplication sharedApplication] presentModalViewController:vc];
    [vc release];
}

-(void)showBigImage
{
    [DetailImageViewController showDetailImageWithURL:((NewFeedData*)self.feedData).pic_big_URL context:self.managedObjectContext];
    
    
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    
    
    NSString* tempString = [NSString stringWithFormat:@"%@",[request URL]];
    tempString=[tempString stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString* commandString = [tempString substringFromIndex:7];
    NSString* startString = [tempString substringToIndex:5];
    
    
    if ([commandString isEqualToString:@"showimage"])
    {
        [self showBigImage];
        return NO;
    }
    
    
    
    
    else if ([[[tempString stringByDeletingLastPathComponent] lastPathComponent] isEqualToString:@"renren"])
    {
        
        
        [self.delegate selectRenren:[tempString lastPathComponent]];
        return NO;
    }
    else if ([[[tempString stringByDeletingLastPathComponent] lastPathComponent] isEqualToString:@"weibo"])
    {
        
        
        [self.delegate selectWeibo:[tempString lastPathComponent]];   
        
        
        return NO;
    }
    else if ([startString isEqualToString:@"file:"])//本地request读取
    {
        return YES;
    }
    
    
    else//其他url，调用safari
    {
        
        [CardBrowserViewController showCardBrowserWithLink:request.URL];
        return NO;
    }
}




@end
