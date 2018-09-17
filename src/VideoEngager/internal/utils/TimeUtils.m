//
//  TimeUtils.m
//  leadsecure
//
//  Created by ivan shulev on 3/11/16.
//  Copyright © 2016 SoftAvail. All rights reserved.
//

#import "TimeUtils.h"

@implementation TimeUtils

+ (NSString*)timeElapsedStringFromTitle:(NSString*)title
                              updatedAt:(double)updatedAt
{
    if (updatedAt > 0)
    {
        return [NSString stringWithFormat:@"[%@] %@",
                       [self elapsedTimeStringFromTimestamp:updatedAt],
                       title];
    }
    else
    {
        return [NSString stringWithFormat:@"%@",
                        title];
    }
}

+ (NSString* )
appleTimeShortDescriptionBySeconds: ( NSTimeInterval ) seconds
{
    NSDateComponentsFormatter *dateComponentsFormatter = [NSDateComponentsFormatter new];
    dateComponentsFormatter.zeroFormattingBehavior = NSDateComponentsFormatterZeroFormattingBehaviorDropAll;
    dateComponentsFormatter.allowedUnits = [[self class] allowedUnitsBySeconds:seconds];
    dateComponentsFormatter.unitsStyle = NSDateComponentsFormatterUnitsStyleAbbreviated;
    
    return [dateComponentsFormatter stringFromTimeInterval:seconds];
}

+ ( NSCalendarUnit )
allowedUnitsBySeconds: ( NSTimeInterval ) seconds
{
    if (seconds < 60)
    {
        return NSCalendarUnitSecond;
    }
    
    if (seconds < 3600)
    {
        return NSCalendarUnitMinute | NSCalendarUnitSecond;
    }
    
    if (seconds < 24*3600)
    {
        return NSCalendarUnitHour | NSCalendarUnitMinute;
    }
    
    return NSCalendarUnitDay | NSCalendarUnitHour;
}

+ (NSString*)elapsedTimeStringFromTimestamp:(double)timestamp
{
    NSTimeInterval elapsedTime = [[NSDate date] timeIntervalSince1970] - timestamp;
    return [self formattedTimeStringForDuration:elapsedTime];
}

+ ( NSString* )
formattedTimeStringForDuration:( NSTimeInterval ) duration
{
    return [TimeUtils appleTimeShortDescriptionBySeconds:duration];
}

@end
