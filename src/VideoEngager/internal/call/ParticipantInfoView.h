//
//  ParticipantInfoView.h
//  leadsecure
//
//  Created by ivan shulev on 4/6/16.
//  Copyright © 2016 SoftAvail. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ParticipantInfoItem.h"

@interface ParticipantInfoView : UIView

- (instancetype)initWithParticipantInfoItems:(NSArray<ParticipantInfoItem*>*)participantInfoItems;

- (void)updateValueWithText:(NSString*)text
                   forTitle:(NSString*)title;

- (void)willTransitionToTraitCollection:(UITraitCollection *)newCollection;

@end
