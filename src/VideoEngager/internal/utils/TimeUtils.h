//
//  TimeUtils.h
//  leadsecure
//
//  Created by ivan shulev on 3/11/16.
//  Copyright © 2016 SoftAvail. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TimeUtils : NSObject

+ (NSString*)timeElapsedStringFromTitle:(NSString*)title
                              updatedAt:(double)updatedAt;

+ (NSString* )
appleTimeShortDescriptionBySeconds: ( NSTimeInterval ) seconds;

@end
