//
//  RtcEventsListener.m
//  leadsecure
//
//  Created by ivan shulev on 1/13/16.
//  Copyright © 2016 SoftAvail. All rights reserved.
//

#import "RtcEventsListener.h"

#import "IFacade.h"
#import "RefCountPtr.h"
#import "AutoPtr.h"
#import "IEventSink.h"

#import "VDEEventListener.h"

static RtcEventsListener* sharedInstance = nil;

@implementation RtcEventsListener
{
    instac::AutoPtr<instac::IEventSink<instac::RTCEvent> > _rtcEventListener;
    instac::RefCountPtr<instac::IRTCManager> _rtcManager;
    NSMutableArray* _eventsListenerItems;
}

+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[[self class] alloc] init];
    });
    
    return sharedInstance;
}

- (instancetype)init
{
    self = [super init];
    
    if (self == nil)
    {
        return nil;
    }
    
    instac::RefCountPtr<instac::IFacade> facade;
    facade = instac::IFacade::getInstance();
    
    if (facade != NULL)
    {
        facade->getRTCManager(_rtcManager);
        
        if (_rtcManager != NULL)
        {
            _rtcEventListener = new VDEEventListener<RtcEventsListener, instac::RTCEvent>(self, @selector(onRtcEvent:));
            _rtcManager->subscribeForEvents(*_rtcEventListener);
        }
        else
        {
            return nil;
        }
    }
    else
    {
        return nil;
    }
    
    _eventsListenerItems = [[NSMutableArray alloc] init];
    
    return self;
}

- (void)dealloc
{
    if (_rtcManager != NULL && _rtcEventListener != nil)
    {
        _rtcManager->unsubscribeForEvents(*_rtcEventListener);
    }
}

- (NSString*)notifyOnEventActions:(NSArray*)eventsActions
                          timeout:(NSTimeInterval)timeout
                completionHandler:(RtcEventCompletionHandler)completionHandler
{
    NSString* rtcEventsListenerItemIdentifier = [[NSUUID UUID] UUIDString];
    
    RtcEventsListenerItem* eventsListenerItem = [[RtcEventsListenerItem alloc] initWithIdentifier:rtcEventsListenerItemIdentifier
                                                                                     eventActions:eventsActions
                                                                                            timeout:timeout
                                                                                  completionHandler:completionHandler];
    eventsListenerItem.delegate = self;
    
    IMLogDbg("Will add eventsListenerItem %s, timeout: %.0f, actions: %s, isMainThread %d",
             eventsListenerItem.identifier.UTF8String,
             eventsListenerItem.timeout,
             [[eventsListenerItem printableEventActions] UTF8String],
             [[NSThread currentThread] isMainThread]);
    
    [_eventsListenerItems addObject:eventsListenerItem];
    
    if (timeout > 0)
    {
        [eventsListenerItem startTimer];
    }
    
    return rtcEventsListenerItemIdentifier;
}

- (void)removeListenerWithIdentifier:(NSString*)identifier
{
    RtcEventsListenerItem* rtcEventsListenerItemToBeRemoved = nil;
    
    for (RtcEventsListenerItem* rtcEventsListenerItem in _eventsListenerItems)
    {
        if ([rtcEventsListenerItem.identifier isEqualToString: identifier]) {
            rtcEventsListenerItemToBeRemoved = rtcEventsListenerItem;
            break;
        }
    }
    
    if (rtcEventsListenerItemToBeRemoved)
    {
        IMLogDbg("removeListenerWithIdentifier, Will remove eventsListenerItem %s, isMainThread %d",
                 rtcEventsListenerItemToBeRemoved.identifier.UTF8String,
                 [[NSThread currentThread] isMainThread]);
        
        [rtcEventsListenerItemToBeRemoved killTimer];
        [_eventsListenerItems removeObject:rtcEventsListenerItemToBeRemoved];
    }
}

- (void)onRtcEvent:(NSValue*)obj
{
    instac::RTCEvent* event = (instac::RTCEvent*)[obj pointerValue];
    
    switch (event->getType())
    {
        case instac::RTCEvent::ActionCompletion:
        {
            [self handleEvent:event];
        }
            break;
        default:
            break;
    }
}

- (void)handleEvent:(instac::RTCEvent*)event
{
    NSMutableArray* matchedListenerItems = [[NSMutableArray alloc] init];
    NSMutableArray* eventsListenerItems = [[NSMutableArray alloc] initWithArray:_eventsListenerItems];
    
    for (RtcEventsListenerItem* eventListenerItem in eventsListenerItems)
    {
        if ([eventListenerItem hasMatchingEventAction:event->getAction()])
        {
            RtcEventCompletionHandler completionHandler = [eventListenerItem completionHandler];
            BOOL stop = NO;
            completionHandler(event, NO, &stop);
            
            if (stop)
            {
                [matchedListenerItems addObject:eventListenerItem];
            }
        }
    }
    
    for (RtcEventsListenerItem* eventListenerItem in matchedListenerItems)
    {
        IMLogDbg("handleEvent, Will remove eventsListenerItem %s, isMainThread %d", eventListenerItem.identifier.UTF8String,
                 [[NSThread currentThread] isMainThread]);

        [eventListenerItem killTimer];
        [_eventsListenerItems removeObject:eventListenerItem];
    }
}

- (void)eventListenerItemDidTimeout:(RtcEventsListenerItem*)eventListenerItem
{
    IMLogDbg("eventListenerItemDidTimeout, Will remove eventsListenerItem %s, isMainThread %d",
             eventListenerItem.identifier.UTF8String,
             [[NSThread currentThread] isMainThread]);
    
    [_eventsListenerItems removeObject:eventListenerItem];
    RtcEventCompletionHandler completionHandler = [eventListenerItem completionHandler];
    BOOL stop = NO;
    completionHandler(NULL, YES, &stop);
}

@end
