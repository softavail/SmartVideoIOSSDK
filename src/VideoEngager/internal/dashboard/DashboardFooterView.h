//
//  DashboardFooterView.h
//  VideoEngager
//
//  Created by Bozhko Terziev on 11.01.18.
//  Copyright © 2018 VideoEngager. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DashboardFooterViewDelegate;

@interface DashboardFooterView : UIView

@property(nonatomic, weak) id<DashboardFooterViewDelegate> delegate;

@end

@protocol DashboardFooterViewDelegate <NSObject>

-(void) didPressCancel;

@end
