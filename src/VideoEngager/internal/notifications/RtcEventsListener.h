//
//  RtcEventsListener.h
//  leadsecure
//
//  Created by ivan shulev on 1/13/16.
//  Copyright © 2016 SoftAvail. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "RtcEventsListenerItem.h"
#import "RTCEvent.h"

@interface RtcEventsListener : NSObject <RtcEventsListenerItemDelegate>

+ (instancetype)sharedInstance;

- (NSString*)notifyOnEventActions:(NSArray*)eventsActions
                          timeout:(NSTimeInterval)timeout
                completionHandler:(RtcEventCompletionHandler)completionHandler;

- (void)removeListenerWithIdentifier:(NSString*)identifier;

@end
