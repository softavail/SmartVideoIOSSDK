//
//  LoginButtonModel.h
//  leadsecure
//
//  Created by Bozhko Terziev on 9/28/15.
//  Copyright © 2015 SoftAvail. All rights reserved.
//

typedef NS_ENUM(NSUInteger, ButtonType)
{
    ButtonTypeSignIn,
    ButtonTypeLast,
};

@interface LoginButtonModel : NSObject
{
}

@property (nonatomic, weak) id buttonTarget;

@property (nonatomic, assign) BOOL enabled;
@property (nonatomic, assign) ButtonType buttonType;

@property (nonatomic, strong) NSString* buttonTitle;
@property (nonatomic, strong) NSArray*  buttonImages;
@property (nonatomic, strong) UIFont*   buttonTitleFont;
@property (nonatomic, strong) UIColor*  buttonTitleColor;
@property (nonatomic, strong) NSIndexPath* idxPath;
@property (nonatomic, assign) SEL       action;

+(NSString*)buttonTitleByType:(ButtonType)buttonType;
+(NSArray*)buttonImagesByType:(ButtonType)buttonType;

@end
