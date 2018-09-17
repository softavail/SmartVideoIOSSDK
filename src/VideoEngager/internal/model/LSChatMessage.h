//
//  LSChatMessage.h
//  leadsecure
//
//  Created by ivan shulev on 9/1/15.
//  Copyright (c) 2015 SoftAvail. All rights reserved.
//

typedef NS_ENUM(NSInteger, LSChatMessageType)
{
    LSChatMessageTypeIncoming,
    LSChatMessageTypeOutgoing
};

@interface LSChatMessage : NSObject

- (instancetype)initWithModel:(const void*)modelPtr;
- (LSChatMessageType)type;
- (NSString*)text;
- (NSTimeInterval)time;

@end
