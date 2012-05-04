//
//  CommonFunction.h
//  SocialFusion
//
//  Created by He Ruoyun on 11-10-19.
//  Copyright (c) 2011年 Tongji Apple Club. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CommonFunction : NSObject

+ (NSString*)getTimeBefore:(NSDate*)date;
+ (NSString *)flattenHTML:(NSString *)html ;
+ (NSString *)subStringToOneK:(NSString *)incomestring withMaxLength:(NSInteger)maxlength;

@end
