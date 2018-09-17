//
//  ParticipantInfoItem.h
//  leadsecure
//
//  Created by ivan shulev on 4/6/16.
//  Copyright © 2016 SoftAvail. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ParticipantInfoItem : NSObject

@property (nonatomic, readonly) NSString* title;
@property (nonatomic, readonly) NSString* value;

- (instancetype)initWithTitle:(NSString*)title
                        value:(NSString*)value;

@end
