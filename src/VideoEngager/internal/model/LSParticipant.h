//
//  LSParticipant.h
//  leadsecure
//
//  Created by ivan shulev on 9/12/15.
//  Copyright (c) 2015 SoftAvail. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LSParticipant : NSObject

- (id) initWithModel: (const void *) modelPtr;
- (NSString*)identifier;
- (NSString*)visitorId;
- (NSString*)callerType;
- (NSString*)email;
- (NSString*)image;
- (NSString*)name;
- (NSString*)referrer;
- (NSString*)telephone;
- (NSString*)title;
- (double)updatedAt;
- (double)createdAt;
- (NSString*)location;
- (NSString*)url;
- (NSString*)user;
- (BOOL)isInactive;
- (NSArray*)videoCalls;
- (NSArray*)chatCalls;
- (NSArray*)activeVideoCalls;
- (NSArray*)activeChatCalls;

@end
