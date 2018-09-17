//
//  SwitchView.h
//  demo
//
//  Created by Bozhko Terziev on 31.01.18.
//  Copyright © 2018 VideoEngager. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SwitchViewDelegate;

@interface SwitchView : UIView

-(void) updateSwitchView;

@property (nonatomic) BOOL isOn;
@property (nonatomic, weak) id <SwitchViewDelegate> delegate;

@end

@protocol SwitchViewDelegate <NSObject>

-(void)didChangeSwitchView:(SwitchView*) swv;

@end

