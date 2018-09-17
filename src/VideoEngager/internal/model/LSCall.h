//
//  VideoCall.h
//  leadsecure
//
//  Created by Angel Terziev on 8/12/15.
//  Copyright (c) 2015 SoftAvail. All rights reserved.
//

#import "LSChatMessage.h"

typedef NS_ENUM(NSInteger, LSCallType)
{
    LSCallTypeVideo = 0,
    LSCallTypeChat,
    LSCallTypeScreenShare,
    
    LSCallTypeUnknown = 100
};

typedef NS_ENUM(NSInteger, LSCallState)
{
    LSCallStateRinging = 0,
    LSCallStateAccepted,
    LSCAllStateEnded
};

typedef NS_ENUM(NSInteger, LSCallDirection)
{
    LSCallDirectionUnknown,
    LSCallDirectionIncoming,
    LSCallDirectionOutgoing
};

@interface LSCall : NSObject

- (id) initWithModel: (const void *) modelPtr;

@property (readonly) NSString* callId;
@property (readonly) NSString* clientCallId;
@property (readonly) NSString* participantId;
@property (nonatomic, getter=isMuted) BOOL mute;

- (LSCallType)callType;
- (LSCallDirection)callDirection;
- (LSCallState)callState;
- (BOOL)isOnHold;
- (BOOL)isTransfer;
- (BOOL)isConnectedToThisDevice;
- (BOOL)isAnsweredByMe;
- (NSString*)answeredByUser;
- (NSTimeInterval)answerTime;
- (NSString*)transferRefId;

@end
