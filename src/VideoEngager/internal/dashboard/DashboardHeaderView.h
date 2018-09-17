//
//  DashboardHeaderView.h
//  VideoEngager
//
//  Created by Bozhko Terziev on 11.01.18.
//  Copyright © 2018 VideoEngager. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DashboardHeaderView : UIView

@property(nonatomic, strong) NSString* strName;
@property(nonatomic, strong) NSString* strEmail;
@property(nonatomic, strong) NSString* strPhone;

-(void)updateView;

@end

