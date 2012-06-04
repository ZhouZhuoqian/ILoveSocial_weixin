//
//  NewFeedPhotoHeader.m
//  SocialFusion
//
//  Created by Air MacBook on 12-6-2.
//  Copyright (c) 2012年 TJU. All rights reserved.
//

#import "NewFeedPhotoHeader.h"
#import "CommonFunction.h"


@implementation NewFeedPhotoHeader

@synthesize _timeLabel;
@synthesize _userNameLabel;
@synthesize _headFrameImageView;
@synthesize _repostButton ;
@synthesize _headButton ;
@synthesize _headerImageView;


-(void)awakeFromNib{    
    
    NSLog(@"awake from nib");
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        //*****
        self._repostButton = [[UIButton alloc]initWithFrame:CGRectMake(0, -2, 44, 44)];
        self._repostButton.frame = CGRectMake(4, 8, 46, 46);
        self._repostButton.adjustsImageWhenHighlighted = NO;
        self._repostButton.showsTouchWhenHighlighted = YES;
        self._repostButton.imageView.image = [UIImage imageNamed:@"btn_repost.png"];
//        [self addSubview:        self._repostButton];
        
        //*****
        UIImageView * detailheaderImageView = [[UIImageView alloc]initWithFrame:CGRectMake(-14, 0, 320, 50)];
        detailheaderImageView.image = [UIImage imageNamed:@"detail_header_bg@2x.png"];
        [self addSubview:detailheaderImageView];
        [detailheaderImageView release];
        //*****
        self._headerImageView = [[UIImageView alloc]initWithFrame:CGRectMake(8, 3, 34, 34)];
        [self addSubview:self._headerImageView];
        
        //*****
        UIButton * headButton = [[UIButton alloc]initWithFrame:CGRectMake(8, 3, 34, 34)];
        headButton.imageView.image = [UIImage imageNamed:@"detail_head.png"];
        [headButton addTarget:self action:@selector(didClickHeader:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:headButton];
        [headButton release];
        
        //*****
        self._userNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(55, 10, 141, 20)];
        self._userNameLabel.text = @"username";
        self._userNameLabel.font = [UIFont fontWithName:@"Helvetica" size:14.0f ];
        self._userNameLabel.textColor = [UIColor blackColor];

        self._userNameLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:        self._userNameLabel];
        
        //*****
        self._timeLabel= [[UILabel alloc] initWithFrame:CGRectMake(180, 10, 80, 20)];
        self._timeLabel.frame=CGRectMake(246, 11, 50, 18);
        self._timeLabel.text = @"username";
        self._timeLabel.font = [UIFont fontWithName:@"Helvetica" size:9.0f];
        self._timeLabel.textColor  = [UIColor colorWithRed:0.5647f green:0.55686f blue:0.47059 alpha:1];
        self._timeLabel.backgroundColor = [UIColor clearColor];
        self._timeLabel.textAlignment=UITextAlignmentRight;
        self._timeLabel.textColor = [UIColor colorWithRed:0.5647f green:0.55686f blue:0.47059 alpha:1];
        self._timeLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:        self._timeLabel];
        
        
        
        
        [self addSubview:        self._repostButton];

        //*****
        
        UIImageView * headerFrameImageView = [[UIImageView alloc]initWithFrame:CGRectMake(3, -2, 45, 45)];
        headerFrameImageView.image = [UIImage imageNamed:@"head_renren.png"];
        [self addSubview:headerFrameImageView];
        [headerFrameImageView release];
        
    }
    return self;
}

- (void)dealloc {
    self._headerImageView = nil;
    self._timeLabel = nil;
    self._userNameLabel = nil;
    self._headFrameImageView = nil;
    self._repostButton = nil;
    self._headButton = nil;
 
     [super dealloc];
}




- (void)configureCell:(NewFeedRootData*)feedData 
{    
    self._userNameLabel.text  =[feedData getAuthorName] ;
    
    if ([feedData getStyle] == 0)
    {
        self._headFrameImageView.image=[UIImage imageNamed:@"head_renren.png"] ;
    }
    else
    {
        self._headFrameImageView.image=[UIImage imageNamed:@"head_wb.png"] ;
    }
    
    self._timeLabel.text = [CommonFunction getTimeBefore:[feedData getDate]];
//    NSString * imageUrl  = [feedData owner_Head];        
//    self._headerImageView.image= [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:imageUrl]]];
    
    
}




#pragma mark - ib action

- (IBAction)didClickHeader:(id)sender {
}

- (IBAction)didClickRepost:(id)sender {
}
@end
