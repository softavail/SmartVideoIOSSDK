//
//  VDENotificationCenter.m
//  VideoEngager
//
//  Created by Angel Terziev on 9.01.18.
//  Copyright © 2018 VideoEngager. All rights reserved.
//

#import "VDENotificationCenter.h"

NSString *const kIncomingCallRingtone = @"icoming_call_ringing";
NSString *const kIncomingCallDuringCallRingtone = @"icoming_call_during_call_ringing";

NSString *const kIncomingChatRingtone                   = @"icoming_chat_ringing";
NSString *const kIncomingChatDuringCallRingtone         = @"icoming_chat_during_call_ringing";
NSString *const kNewChatMessageRingtone                 = @"new_chat_message_ringtone";
NSString *const kReturningVisitorRingtone               = @"returning_visitor_ringtone";

NSString *const NotificationIncomingCallRinging         = @"NotificationIncomingCallRinging";
NSString *const NotificationIncomingCallDuringCallRinging = @"NotificationIncomingCallDuringCallRinging";

NSString *const NotificationIncomingChatRinging         = @"NotificationIncomingChatRinging";
NSString *const NotificationIncomingChatDuringCallRinging = @"NotificationIncomingChatDuringCallRinging";
NSString *const NotificationPlayChatMessageReceivedRingtone= @"NotificationPlayChatMessageReceivedRingtone";

NSString *const NotificationRingActionKey               = @"NotificationRingActionKey";
NSString *const NotificationParticipantKey              = @"NotificationParticipantKey";

NSString *const DidAnswerIncomingCallNotification       = @"DidAnswerIncomingCallNotification";
NSString *const DidRejectIncomingCallNotification       = @"DidRejectIncomingCallNotification";

NSString *const kDidSendTextNotification                 = @"kDidSendTextNotification";
NSString *const kDidCallBackNotification                 = @"kDidCallBackNotification";
NSString *const kVisitorIdKey                            = @"kVisitorIdKey";
NSString *const kVisitorNameKey                          = @"kVisitorNameKey";
NSString *const kDidViewNewChatMessageNotification       = @"kDidViewNewChatMessageNotification";
NSString *const kDidSendTextReturningVisitorNotification = @"kDidSendTextReturningVisitorNotification";
NSString *const kDidCallBackReturningVisitorNotification = @"kDidCallBackReturningVisitorNotification";

NSString *const IncomingCallFromBackgroundToAnswerKey   = @"IncomingCallFromBackgroundToAnswerKey";
NSString *const SendTextForMissedCallKey                = @"SendTextForMissedCallKey";
NSString *const CallBackForMissedCallKey                = @"CallBackForMissedCallKey";
NSString *const ViewChatMessageKey                      = @"ViewChatMessageKey";
NSString *const SendTextReturningVisitorKey             = @"SendTextReturningVisitorKey";
NSString *const CallBackReturningVisitorKey             = @"CallBackReturningVisitorKey";

NSString* const kNotificationCategoryIncomingCall       = @"kNotificationCategoryIncomingCall";
NSString* const kNotificationCategoryIncomingCallDuringCall = @"kNotificationCategoryIncomingCallDuringCall";
NSString* const kNotificationActionAnswer               = @"kNotificationActionAnswer";
NSString* const kNotificationActionReject               = @"kNotificationActionReject";
NSString* const kNotificationActionReply                = @"kNotificationActionReply";
NSString* const kNotificationActionView                 = @"kNotificationActionView";

NSString* const kNotificationCategoryMissedCall         = @"kNotificationCategoryMissedCall";
NSString* const kNotificationActionSendText             = @"kNotificationActionSendText";
NSString* const kNotificationActionCallBack             = @"kNotificationActionCallBack";

NSString* const kNotificationCategoryAcceptedCall       = @"kNotificationCategoryAcceptedCall";

NSString* const kNotificationCategoryIncomingChat       = @"kNotificationCategoryIncomingChat";
NSString* const kNotificationCategoryIncomingChatDuringCall = @"kNotificationCategoryIncomingChatDuringCall";
NSString* const kNotificationCategoryNewChatMessage     = @"kNotificationCategoryNewChatMessage";

NSString* const kNotificationCategoryReturningVisitor   = @"kNotificationCategoryReturningVisitor";
NSString* const kNotificationActionSendTextToReturningVisitor = @"kNotificationActionSendTextToReturningVisitor";
NSString* const kNotificationActionCallBackReturningVisitor = @"kNotificationActionCallBackReturningVisitor";

NSString *const NotificationDidHandleUrl                = @"NotificationProspectSceneDidDissappear";

NSString *const kNotificationSwitchUI                   = @"kNotificationSwitchUI";

NSString* const kAudioRouteChangeNotification           = @"kAudioRouteChangeNotification";
NSString* const kDidSetVideoRouteNotification           = @"kDidSetVideoRouteNotification";

NSString* const kNetworkStatusNotReachableNotification  = @"kNetworkStatusNotReachableNotification";

NSString* const kDidReceiveCallAnswerTime               = @"kDidReceiveCallAnswerTime";
NSString* const kCallIdKey                              = @"kCallIdKey";
NSString* const kVideoRouteKey                          = @"kVideoRouteKey";

NSString* kIsBackgroundCallDispatched = @"kIsBackgroundCallDispatched";

NSString* const kDidUpdateAccountPreferences            = @"kDidUpdateAccountPreferences";

NSString *const startCallToPersonKey                    = @"startCallToPersonKey";
NSString *const callWithVideoKey                        = @"callWithVideoKey";

NSString *const kDidStartCallWithVisitorNotification    = @"kDidStartCallWithVisitorNotification";
NSString *const kDidStartCallWithVisitorSuccessKey      = @"kDidStartCallWithVisitorSuccessKey";
NSString *const kDidStartCallWithVisitorVisitorKey      = @"kDidStartCallWithVisitorVisitorKey";
NSString *const kDidStartCallWithVisitorVideoKey        = @"kDidStartCallWithVisitorVideoKey";
NSString *const kInitiateLogout                         = @"kInitiateLogout";


NSString* const kVideoCallManagerActiveVideoCallNotification = @"kVideoCallManagerActiveVideoCallNotification";
//keys:
NSString* const kVideoCallManagerActiveVideoCallKey = @"kVideoCallManagerActiveVideoCallKey";
NSString* const kVideoCallManagerActiveVideoCallIdKey = @"kVideoCallManagerActiveVideoCallIdKey";
NSString* const kVideoCallManagerTransferVideoCallKey = @"kVideoCallManagerTransferVideoCallKey";

NSString* const kVideoCallManagerActiveVideoCallStateKey = @"kVideoCallManagerActiveVideoCallStateKey";
NSString* const kVideoCallManagerActiveVideoCallStateErrorKey = @"kVideoCallManagerActiveVideoCallStateErrorKey";
//values:
NSString* const kVideoCallManagerActiveVideoCallStateEstablished = @"kVideoCallManagerActiveVideoCallStateEstablished";
NSString* const kVideoCallManagerActiveVideoCallStateFailed = @"kVideoCallManagerActiveVideoCallStateFailed";
NSString* const kVideoCallManagerActiveVideoCallStateEnded = @"kVideoCallManagerActiveVideoCallStateEnded";
NSString* const kVideoCallManagerActiveVideoCallStateDialing = @"kVideoCallManagerActiveVideoCallStateDialing";
/*
 Userinfo: kVideoCallManagerActiveVideoCallStateKey: kVideoCallManagerActiveVideoCallStateEstablished
 kVideoCallManagerActiveVideoCallKey: call id -> NSString*
 
 Userinfo: kVideoCallManagerActiveVideoCallStateKey: kVideoCallManagerActiveVideoCallStateEnded
 
 Userinfo: kVideoCallManagerActiveVideoCallStateKey: kVideoCallManagerActiveVideoCallStateFailed
 kVideoCallManagerActiveVideoCallStateErrorKey: error code -> NSNumber* with unsigned int
 
 Userinfo: kVideoCallManagerActiveVideoCallStateKey: kVideoCallManagerActiveVideoCallStateDialing
 kVideoCallManagerActiveVideoCallKey: video call -> LSCall*
 */


NSString* const kVideoCallManagerActiveChatCallNotification = @"kVideoCallManagerActiveChatCallNotification";
//keys:
NSString* const kVideoCallManagerActiveChatCallStateKey = @"kVideoCallManagerActiveChatCallStateKey";
NSString* const kVideoCallManagerActiveChatCallKey = @"kVideoCallManagerActiveChatCallKey";
NSString* const kVideoCallManagerActiveChatCallMessagesKey = @"kVideoCallManagerActiveChatCallMessagesKey";
NSString* const kVideoCallManagerMessagesOfVisitorKey = @"kVideoCallManagerMessagesOfVisitorKey";
//values:
NSString* const kVideoCallManagerActiveChatCallStateEstablished = @"kVideoCallManagerActiveChatCallStateEstablished";
NSString* const kVideoCallManagerActiveChatCallStateEnded = @"kVideoCallManagerActiveChatCallStateEnded";
/*
 Userinfo: kVideoCallManagerActiveChatCallStateKey: kVideoCallManagerActiveChatCallStateEstablished
 kVideoCallManagerActiveChatCallKey: chat call -> LSCall*
 
 Userinfo: kVideoCallManagerActiveChatCallStateKey: kVideoCallManagerActiveChatCallStateEnded
 kVideoCallManagerActiveChatCallKey: chat call -> LSCall*
 
 Userinfo: kVideoCallManagerActiveChatCallMessagesKey: @(YES)
 kVideoCallManagerMessagesOfVisitor: visitor -> LSParticipant*
 */


NSString* const kVideoCallManagerDidUpdateVisitor = @"kVideoCallManagerDidUpdateVisitor";
//keys:
NSString* const kVideoCallManagerVisitorKey = @"kVideoCallManagerVisitorKey";
/*
 Userinfo: kVideoCallManagerVisitorKey: visitor -> LSParticipant*
 */

NSString* const kVideoCallManagerVisitorDidBecomeInactive = @"kVideoCallManagerVisitorDidBecomeInactive";
/*
 Userinfo: kVideoCallManagerVisitorKey: visitor -> LSParticipant*
 */

NSString* const kParticipantAvailabilityChanged = @"kParticipantAvailabilityChanged";
/*
 Userinfo: kParticipantAvailabilityChangedParticipantKey: participant -> LSParticipant*
 */
NSString* const kParticipantAvailabilityChangedParticipantKey = @"kParticipantAvailabilityChangedParticipantKey";

NSString* const kQoSValueDidChange = @"kQoSValueDidChange";
NSString* const kQoSLastValueKey = @"kQoSLastValueKey";

static NSNotificationCenter* _theVDECenter;

@implementation VDENotificationCenter

+ (NSNotificationCenter*) vdeCenter {

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _theVDECenter = [[NSNotificationCenter alloc] init];
    });
    
    return _theVDECenter;
}

@end
