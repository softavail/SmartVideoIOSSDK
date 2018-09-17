//
//  LSParticipantsResult.h
//  leadsecure
//
//  Created by ivan shulev on 3/25/16.
//  Copyright © 2016 SoftAvail. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "LSParticipant.h"
#import "VanityCellState.h"

@interface LSParticipantsResult : NSObject

- (instancetype)initWithModel:(const void*)modelPtr;

- (void)fetch;
- (NSUInteger)itemsCount;
- (LSParticipant*)itemAtRow:(NSUInteger)rowIndex;

@end
