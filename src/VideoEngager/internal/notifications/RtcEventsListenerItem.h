//
//  RtcEventsListenerItem.h
//  leadsecure
//
//  Created by ivan shulev on 1/13/16.
//  Copyright © 2016 SoftAvail. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "RTCEvent.h"
#import "IRTCManager.h"

typedef void (^RtcEventCompletionHandler)(instac::RTCEvent* event, BOOL isTimedOut, BOOL* stop);
@protocol RtcEventsListenerItemDelegate;

@interface RtcEventsListenerItem : NSObject

@property (nonatomic, weak) id <RtcEventsListenerItemDelegate> delegate;
@property (nonatomic, readonly) NSString* identifier;
@property (nonatomic, assign) NSTimeInterval timeout;

- (instancetype)initWithIdentifier:(NSString*)identifier
                      eventActions:(NSArray*)eventActions
                           timeout:(NSTimeInterval)timeout
                 completionHandler:(RtcEventCompletionHandler)completionHandler;

- (NSString*) printableEventActions;
- (void)startTimer;
- (void)killTimer;

- (BOOL)hasMatchingEventAction:(instac::IRTCManager::Action)eventActionToMatch;

- (RtcEventCompletionHandler)completionHandler;

@end

@protocol RtcEventsListenerItemDelegate <NSObject>
- (void)eventListenerItemDidTimeout:(RtcEventsListenerItem*)eventListenerItem;
@end
