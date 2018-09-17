//
//  LoginButtonModel.m
//  leadsecure
//
//  Created by Bozhko Terziev on 9/28/15.
//  Copyright © 2015 SoftAvail. All rights reserved.
//

#import "LoginButtonModel.h"

@implementation LoginButtonModel

+(NSString*) cellIdentifier
{
    return @"LoginButtonCell";
}

+ ( NSString* )
buttonTitleByType: ( ButtonType ) buttonType
{
    NSString* title = nil;
    
    switch (buttonType)
    {
        case ButtonTypeSignIn:
            title = @"Sign in";
            break;
            
        default:
            break;
    }
    
    return title;
}

+ ( NSArray* )
buttonImagesByType : ( ButtonType ) buttonType
{
    NSArray* array = nil;
    switch (buttonType)
    {
        case ButtonTypeSignIn:
            array = [NSArray arrayWithObjects:[UIImage imageNamed:@"buttonNormalState"], [UIImage imageNamed:@"buttonSelectedState"], nil];
            break;
            
        default:
            break;
    }
    
    return array;
}

@end
