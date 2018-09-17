//
//  LSChatMessage.m
//  leadsecure
//
//  Created by ivan shulev on 9/1/15.
//  Copyright (c) 2015 SoftAvail. All rights reserved.
//

#import "LSChatMessage.h"

#import "RefCountPtr.h"
#import "IChatMessage.h"

@implementation LSChatMessage
{
    instac::RefCountPtr<instac::IChatMessage> _chatMessage;
}

- (instancetype)initWithModel:(const void*)modelPtr
{
    if (nil != (self = [super init]))
    {
        ASSERT_AND_LOG(modelPtr != NULL, "Chat Message Model pointer should not be NULL", 0);
        
        if (modelPtr == NULL)
        {
            IMLogErr("Cannot instantiate LSChatMessage, modelPtr is NULL.", 0);
            return nil;
        }
        
        instac::RefCountPtr<instac::IChatMessage>* pChatMessage = (instac::RefCountPtr<instac::IChatMessage>*)modelPtr;
        _chatMessage = *pChatMessage;
        
        ASSERT_AND_LOG(_chatMessage != NULL, "Chat Message Model should not be NULL", 0);
        
        if (_chatMessage == NULL)
        {
            IMLogErr("Cannot instantiate LSChatMessage, _chatMessage is NULL", 0);
            return nil;
        }
    }
    
    return self;
}

- (LSChatMessageType)type
{
    LSChatMessageType type = LSChatMessageTypeIncoming;
    
    switch (_chatMessage->getType())
    {
        case instac::IChatMessage::ChatMessageTypeOutgoing:
            type = LSChatMessageTypeOutgoing;
            break;
        case instac::IChatMessage::ChatMessageTypeIncoming:
        default:
            type = LSChatMessageTypeIncoming;
            break;
    }
    
    return type;
}

- (NSString*)text
{
    return OBJCStringA(_chatMessage->getText());
}

- (NSTimeInterval)time
{
    return _chatMessage->getTime();
}

@end
