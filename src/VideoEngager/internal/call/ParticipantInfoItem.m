//
//  ParticipantInfoItem.m
//  leadsecure
//
//  Created by ivan shulev on 4/6/16.
//  Copyright © 2016 SoftAvail. All rights reserved.
//

#import "ParticipantInfoItem.h"

@implementation ParticipantInfoItem

- (instancetype)initWithTitle:(NSString*)title
                        value:(NSString*)value
{
    self = [super init];
    
    if (self == nil)
    {
        return nil;
    }
    
    _title = title;
    _value = value;
    
    return self;
}

@end
