//
//  NotificationManager.h
//  instac
//
//  Created by Bozhko Terziev on 11/19/14.
//  Copyright (c) 2014 SoftAvail. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ICOLLActivityView.h"

#import <Intents/INPerson.h>

typedef NS_ENUM(NSInteger, NotificationRingAction) {
    NotificationRingActionStart = 0,
    NotificationRingActionStop  = 1
};

@interface NotificationManager : NSObject
{
}

@property (nonatomic, strong) NSDictionary* lastIncomingCallFromBackground;
@property (nonatomic, readonly, strong) ICOLLActivityView* activityView;
@property (nonatomic, strong) NSString* activeChatParticipant;
@property (nonatomic, assign) BOOL incomincallRingingDisabled;

+ (NotificationManager *)instance;

- (void)showActivityViewWithText:(NSString*)text;
- (void)hideActivityView;
- (void)hideActivityViewNow;

@end
