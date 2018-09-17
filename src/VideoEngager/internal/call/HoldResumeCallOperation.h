//
//  HoldResumeCallOperation.h
//  leadsecure
//
//  Created by ivan shulev on 3/28/16.
//  Copyright © 2016 SoftAvail. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "LSParticipant.h"
#import "LSCall.h"

@interface HoldResumeCallOperation : NSObject

@property (nonatomic, readonly) LSCall* callToBeResumed;

- (instancetype)initWithParticipant:(LSParticipant*)participant;
- (void)perform;

@end
