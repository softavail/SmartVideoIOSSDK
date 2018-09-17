//
//  AvatarView.h
//  leadsecure
//
//  Created by Angel Terziev on 3/12/17.
//  Copyright © 2017 SoftAvail. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AvatarView : UIView

// initials
@property (nonatomic, strong) NSString* initials;
@property (nonatomic, assign) BOOL initialsHidden;
-(void) setInitialsHidden: (BOOL) hidden animated: (BOOL) animated;
@property (nonatomic, strong) UIColor* initialsTextColor;
@property (nonatomic, strong) UIColor* initialsBackgroundColor;

// background image
@property (nonatomic, weak) UIImage* backgroundImage;
@property (nonatomic, assign) BOOL backgroundImageHidden;
-(void) setBackgroundImageHidden: (BOOL) hidden animated: (BOOL) animated;

// status
@property (nonatomic, assign) BOOL statusHidden;
-(void) setStatusHidden: (BOOL) hidden animated: (BOOL) animated;
@property (nonatomic, strong) UIColor* statusColor;

@end
