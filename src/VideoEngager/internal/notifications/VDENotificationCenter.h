//
//  VDENotificationCenter.h
//  VideoEngager
//
//  Created by Angel Terziev on 9.01.18.
//  Copyright © 2018 VideoEngager. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VDENotificationCenter : NSObject

+ (NSNotificationCenter*) vdeCenter;

@end

extern NSString *const kIncomingCallRingtone;
extern NSString *const kIncomingCallDuringCallRingtone;

extern NSString *const kIncomingChatRingtone;
extern NSString *const kIncomingChatDuringCallRingtone;
extern NSString *const kNewChatMessageRingtone;
extern NSString *const kReturningVisitorRingtone;

extern NSString *const NotificationIncomingCallRinging;
extern NSString *const NotificationIncomingCallDuringCallRinging;
extern NSString *const NotificationIncomingChatRinging;
extern NSString *const NotificationIncomingChatDuringCallRinging;
extern NSString *const NotificationPlayChatMessageReceivedRingtone;
extern NSString *const NotificationRingingActionKey;
extern NSString *const NotificationParticipantKey;

extern NSString *const IncomingCallFromBackgroundToAnswerKey;

extern NSString *const DidAnswerIncomingCallNotification;
extern NSString *const DidRejectIncomingCallNotification;

extern NSString *const kDidSendTextNotification;
extern NSString *const kDidCallBackNotification;
extern NSString *const kVisitorIdKey;
extern NSString *const kVisitorNameKey;
extern NSString *const kDidViewNewChatMessageNotification;
extern NSString *const kDidSendTextReturningVisitorNotification;
extern NSString *const kDidCallBackReturningVisitorNotification;

extern NSString *const NotificationDidHandleUrl;

extern NSString *const kNotificationCategoryIncomingCall;
extern NSString *const kNotificationCategoryIncomingCallDuringCall;
extern NSString *const kNotificationActionAnswer;
extern NSString *const kNotificationActionReject;
extern NSString* const kNotificationActionReply;
extern NSString* const kNotificationActionView;

extern NSString *const kNotificationCategoryMissedCall;
extern NSString* const kNotificationActionSendText;
extern NSString* const kNotificationActionCallBack;

extern NSString* const kNotificationCategoryAcceptedCall;

extern NSString* const kNotificationCategoryIncomingChat;
extern NSString* const kNotificationCategoryIncomingChatDuringCall;
extern NSString* const kNotificationCategoryNewChatMessage;

extern NSString* const kNotificationCategoryReturningVisitor;
extern NSString* const kNotificationActionSendTextToReturningVisitor;
extern NSString* const kNotificationActionCallBackReturningVisitor;

extern NSString *const kNotificationSwitchUI;

extern NSString *const kAudioRouteChangeNotification;
extern NSString *const kDidSetVideoRouteNotification;

extern NSString* const kNetworkStatusNotReachableNotification;

extern NSString* const kDidReceiveCallAnswerTime;
extern NSString* const kCallIdKey;
extern NSString* const kVideoRouteKey;

extern NSString* const kDidUpdateAccountPreferences;
extern NSString *const kDidStartCallWithVisitorNotification;
extern NSString *const kDidStartCallWithVisitorSuccessKey;
extern NSString *const kDidStartCallWithVisitorVisitorKey;
extern NSString *const kDidStartCallWithVisitorVideoKey;
extern NSString *const kInitiateLogout;


// notifications
extern NSString* const kVideoCallManagerActiveVideoCallNotification;
extern NSString* const kVideoCallManagerActiveChatCallNotification;
extern NSString* const kVideoCallManagerDidUpdateVisitor;
extern NSString* const kVideoCallManagerVisitorDidBecomeInactive;
extern NSString* const kParticipantAvailabilityChanged;

extern NSString* const kQoSValueDidChange;


// keys
extern NSString* const kVideoCallManagerActiveVideoCallKey; // userInfo contains LSCall with video call
extern NSString* const kVideoCallManagerActiveVideoCallIdKey;
extern NSString* const kVideoCallManagerTransferVideoCallKey;
extern NSString* const kVideoCallManagerActiveVideoCallStateKey; // userInfo contains NSString with video call state
extern NSString* const kVideoCallManagerActiveVideoCallStateErrorKey; // userInfo contains NSNumber with the error code

extern NSString* const kVideoCallManagerActiveChatCallStateKey;
extern NSString* const kVideoCallManagerActiveChatCallKey;
extern NSString* const kVideoCallManagerActiveChatCallMessagesKey;
extern NSString* const kVideoCallManagerMessagesOfVisitorKey;

extern NSString* const kVideoCallManagerVisitorKey;
extern NSString* const kParticipantAvailabilityChangedParticipantKey;
extern NSString* const kQoSLastValueKey;


// values
extern NSString* const kVideoCallManagerActiveVideoCallStateEstablished;
extern NSString* const kVideoCallManagerActiveVideoCallStateFailed;
extern NSString* const kVideoCallManagerActiveVideoCallStateEnded;
extern NSString* const kVideoCallManagerActiveVideoCallStateDialing;

extern NSString* const kVideoCallManagerActiveChatCallStateEstablished;
extern NSString* const kVideoCallManagerActiveChatCallStateEnded;
