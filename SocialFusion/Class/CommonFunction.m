//
//  CommonFunction.m
//  SocialFusion
//
//  Created by He Ruoyun on 11-10-19.
//  Copyright (c) 2011年 Tongji Apple Club. All rights reserved.
//

#import "CommonFunction.h"

@implementation CommonFunction
+ (NSString *)flattenHTML:(NSString *)html {
    
    NSScanner *theScanner;
    NSString *text = nil;
    theScanner = [NSScanner scannerWithString:html];
    
    while ([theScanner isAtEnd] == NO) {
        
        [theScanner scanUpToString:@"<" intoString:NULL] ; 
        
        [theScanner scanUpToString:@">" intoString:&text] ;
        
        html = [html stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@>", text] withString:@""];
    }
    //
    html = [html stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    return html;
}

+ (NSString *)subStringToOneK:(NSString *)incomestring withMaxLength:(NSInteger)maxlength{
    NSString * outString = @"";

    if ([incomestring length] >=maxlength) {
        outString = [incomestring substringToIndex:maxlength];
    }else{
        outString = incomestring;
    }
    return  outString;
    
}


+(NSString*)getTimeBefore:(NSDate*)date
{
    
    
    //NSLog(@"%@",FeedDate);
    int time=-[date timeIntervalSinceNow];
    
    NSString* tempString;
    
    
    
    if (time<0)
    {
        tempString=[NSString  stringWithFormat:@"0秒前"];
    }
    else if (time<60)
    {
        tempString=[NSString  stringWithFormat:@"%d秒前",time];
    }
    else if (time<3600)
    {
        tempString=[NSString stringWithFormat:@"%d分钟前",time/60];
    }
    else if (time<(3600*24))
    {
        tempString= [NSString   stringWithFormat:@"%d小时前",time/3600];
    }
    else
    {
        tempString= [NSString stringWithFormat:@"%d天前",time/(3600*24)];
    }
    
    return tempString;
}


@end
