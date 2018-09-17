//
//  VDEInternal.h
//  VideoEngager
//
//  Created by Angel Terziev on 2.01.18.
//  Copyright © 2018 VideoEngager. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "VDEAgent.h"
#import "VDECall.h"
#import "VDEAgentViewController.h"

#import "LSCall.h"
#import "LSParticipant.h"
#import "Contact.h"

#import "WebRTC/RTCVideoTrack.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, RTCVideoRoute)
{
    VideoRouteNone      = 0,
    VideoRouteFront     = 1,
    VideoRouteBack      = 2,
    VideoRouteMax       = 3
};

typedef NS_ENUM(NSInteger, LSWorkingMode)
{
    LSWorkingModeAgent,
    LsWorkingModeVisitor
};

@protocol VDEInternalDelegate;

@interface VDEInternal : NSObject

@property (nonatomic, readonly, nullable) VDEAgent* vdeAgent;
@property (nonatomic, readonly, weak) id<VDEInternalDelegate> delegate;

@property (nonatomic, assign) RTCVideoRoute videoRoute;
@property (nonatomic, assign) RTCVideoRoute requestedVideoRoute;
@property (nonatomic) BOOL isVideoRouteValueApplied;

@property (nonatomic) BOOL hasRemoteAudio;
@property (nonatomic) BOOL hasRemoteVideo;

@property (nullable) NSString* activeCallId;

@property (nullable, copy) NSURL* externalServerAddress;
@property (nonatomic, readonly) NSString* deviceId;

@property (nonatomic, readonly) NSDictionary* externalSystemParameters;

- (instancetype) initWithContainerPath: (NSURL*) containerPath
                      withServerAddress: (NSURL*) serverAddress
                           andDelegate: (id<VDEInternalDelegate>) delegate;

- (void) joinWithAgentPath: (NSString*) agentPath
                  withName: (NSString*) name
                 withEmail: (NSString*) email
                 withPhone: (NSString*) phone
            withCompletion: (void (^__nonnull)(NSError* __nullable error, VDEAgent* __nullable agent)) completionHandler;

- (void) joinWithAgentPath: (NSString*) agentPath
     externalServerAddress: (NSURL   *) externalServerAddress
             withFirstName: (NSString*) firstName
              withLastName: (NSString*) lastName
                 withEmail: (NSString*) email
               withSubject: (NSString*) subject
            withCompletion: (void (^__nonnull)(NSError* __nullable error, VDEAgent* __nullable agent)) completionHandler;

- (void) disconnectWithCompletion: (void (^__nonnull)(NSError* __nullable error)) completionHandler;

- (void) rejectIncomingCall: (nonnull VDECall *) call;

- (void) acceptIncomingCall: (nonnull VDECall *) call;

- (VDEAgentViewController*) agentViewController;

- (void) callLocalVideoStateUpdate: (BOOL) show;


//MARK: Internal use only
- (RTCVideoTrack*)localVideoTrack;
- (RTCVideoTrack*)remoteVideoTrack;

- (NSError*) startCallWithVideo: (BOOL) withVideo;
- (Contact*) contactForCallWithParticipant: (NSString *) participantId;
- (NSError*) callParticipantWithChat:(NSString*)participantId chatMessage:(NSString*)chatMessage;
- (LSCall*) callById: (NSString*) callId;
- (LSParticipant*)participantWithId:(NSString*)participantId;

- (BOOL)isAgent;
- (LSParticipant*)agent;

- (BOOL)requestVisitorInfo:(NSString*)visitorId;
- (void) muteCall: (LSCall*)call;
- (void) unmuteCall: (LSCall*)call;
- (void)mute:(BOOL)isMuted;
- (BOOL)isMuted;


- (void)holdCall:(NSString*)callId;
- (void)resumeCall:(NSString*)callId;

- (void)hangupTransferCallAndDeleteVisitor:(LSCall*)call;
- (void)hangupCall:(LSCall*)call completionHandler:(void (^)(BOOL isSuccessful))completionHandler;
- (void) hangupCall: (LSCall*) call;
- (BOOL) requestVideoRoute: (RTCVideoRoute) route;

- (void) enableProximitySensor:(BOOL) enable;

- (BOOL) acceptCall: (NSString*) videoCallId;
- (BOOL) rejectCall: (NSString*) videoCallId;


- (BOOL)hasStableSignalingForCall: (NSString*) callId;
- (BOOL)hasStableConnectionForCall: (NSString*) callId;

- (NSArray<NSString*>*) endActiveChatCalls;
- (NSArray<NSString*>*) endActiveVideoCalls;

- (void) requestChatFirstName: (NSString* __nullable) firstName
                     lastName: (NSString* __nullable) lastName
                     nickname: (NSString* __nullable) nickname
                      subject: (NSString* __nullable) subject
                 emailAddress: (NSString* __nullable) emailAddress
                   completion: (void (^__nonnull)(NSData* __nullable data, NSError* __nullable error)) completion;

- (void) disconnectChatWithId: (NSString* __nonnull) chatId
                       userId: (NSString* __nonnull) userId
                    secureKey: (NSString* __nonnull) secureKey
                        alias: (NSString* __nonnull) alias
                   completion: (void (^__nonnull)(NSData* __nullable data, NSError* __nullable error)) completion;

@end


@protocol VDEInternalDelegate<NSObject>

- (void) didReceiveIncomingCall: (nonnull VDECall *) call;
- (void) didCancelIncomingCall: (nonnull VDECall *) call;
- (void) didHangupCall: (nonnull VDECall *) call;
- (void) didChangeAgentAvailability:(BOOL)available;

@end

NS_ASSUME_NONNULL_END
