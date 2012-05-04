//
//  BlogDetailController.h
//  SocialFusion
//
//  Created by He Ruoyun on 12-1-29.
//  Copyright (c) 2012年 Tongji Apple Club. All rights reserved.
//

#import "StatusDetailControllerWithWeb.h"
#import "WebStringToImageConverter.h"

@interface BlogDetailController : StatusDetailControllerWithWeb<WebStringToImageConverterDelegate>
{
    
    NSString* _blogDetail;

}


@end
