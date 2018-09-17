//
//  UIImage+Additions.h
//  instac
//
//  Created by Bozhko Terziev on 11/20/14.
//  Copyright (c) 2014 SoftAvail. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UIImage (Additions)

-(UIImage*)imageWithButtonCapInsets;
-(UIImage*)imageWithButtonCapInsetsBig;
-(UIImage*)imageWithButtonLeftCapInsets;
-(UIImage*)imageWithButtonRightCapInsets;
-(UIImage*)chatImageBaloonOutgoingWithButtonCapInsets;
-(UIImage*)chatImageBaloonIncomingWithButtonCapInsets;
-(UIImage*)bubbleEventMessageCapInsets;
-(UIImage*)bubbleIncomingMessageCapInsets;
-(UIImage*)bubbleOutgoingMessageCapInsets;
+(UIImage*)imageWithView:(UIView*)view;
+(UIImage*)imageNamed:(NSString *)name forBundle:(NSBundle*) bundle;
+(UIImage*)sdkImageNamed:(NSString *)name;

@end
