//
//  ICOLLActivityView.h
//  instac
//
//  Created by Bozhko Terziev on 11/19/14.
//  Copyright (c) 2014 SoftAvail. All rights reserved.
//
#import <UIKit/UIKit.h>

typedef NS_ENUM ( NSInteger, ActivitySize )
{
    ActivitySizeBig = 0,
    ActivitySizeSmall
};

@interface ICOLLActivityView : UIView
{
}

@property ( nonatomic, strong ) UIView* baseView;
@property ( nonatomic, strong ) UILabel* labelActivity;
@property ( nonatomic, strong ) UIActivityIndicatorView* activityIndicator;

@property ( nonatomic ) BOOL animating;
@property ( nonatomic ) ActivitySize activitySize;

@property (nonatomic) BOOL isHideActivityInProgress;

- (void)setActivityText:(NSString*)text;
- (id)initWithFrame:(CGRect)frame andActivitySize:(ActivitySize)aSize;
- (void)hideWithAnimation: (BOOL)yorn;

@end

extern NSInteger kTagActivityView;

