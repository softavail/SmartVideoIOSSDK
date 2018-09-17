//
//  VDEAgent+Internal.h
//  VideoEngager
//
//  Created by Angel Terziev on 4.01.18.
//  Copyright © 2018 VideoEngager. All rights reserved.
//

#import <VideoEngager/VDEAgent.h>

@interface VDEAgent (Internal)

- (BOOL) handleIncomingCall: (nonnull VDECall *) call;
- (BOOL) rejectIncomingCall: (nonnull VDECall *) call;
- (BOOL) acceptIncomingCall: (nonnull VDECall *) call;
- (void) setAgentAvailability: (BOOL) available;

@end
