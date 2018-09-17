//
//  ListParticipantsOnHoldOperation.h
//  leadsecure
//
//  Created by ivan shulev on 3/25/16.
//  Copyright © 2016 SoftAvail. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "LSParticipantsResult.h"

@interface ListParticipantsOnHoldOperation : NSObject

@property (nonatomic, readonly) LSParticipantsResult* participantsResult;

- (void)perform;
- (void)notifyOnChangesCompletionHandler:(void (^)(BOOL isSuccessful, BOOL* stop))completionHandler;

@end
