//
//  CallViewController.h
//  leadsecure
//
//  Created by Vladimir Savov on 29.11.15 г..
//  Copyright © 2015 г. SoftAvail. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "LSCall.h"
#import "LSParticipant.h"

typedef NS_ENUM(NSInteger, CallViewControllerType) {
    CallViewControllerTypeDialing,
    CallViewControllerTypeRinging,
    CallViewControllerTypeRingingDuringCall
};

@class CallViewController;

@protocol CallViewControllerDelegate <NSObject>

- (LSParticipant *)callViewController:(CallViewController *)callController participantInCall:(LSCall*)call;

- (void)callViewControllerDidPressHangup:(CallViewController *)callController;
- (void)callViewControllerDidPressAnswer:(CallViewController *)callController;
- (void)callViewController:(CallViewController *)callController pressedDeclineWithCompletion:(void (^)(BOOL success))completion;
//- (void)callViewController:(CallViewController *)callController pressedHoldAndAnswerWithCompletion:(void (^)(BOOL success))completion;
//- (void)callViewController:(CallViewController *)callController pressedEndAndAnswerWithCompletion:(void (^)(BOOL success))completion;

@end

@interface CallViewController : UIViewController

@property (nonatomic, assign, readonly) CallViewControllerType type;
@property (nonatomic, readonly) LSCall* call;

@property (nonatomic, weak) id<CallViewControllerDelegate> delegate;

- (instancetype)initWithType:(CallViewControllerType)type andCall:(LSCall*)call;

@end
