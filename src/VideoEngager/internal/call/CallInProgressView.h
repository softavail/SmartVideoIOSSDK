//
//  CallInProgressView.h
//  instac
//
//  Created by Bozhko Terziev on 12/4/14.
//  Copyright (c) 2014 SoftAvail. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CallsOnHoldView.h"
#import "Contact.h"
//#import "LSQoSValue.h"

@protocol CallInProgressViewDelegate;

@interface CallInProgressView : UIView
{
}

@property (nonatomic, assign, getter=isAgent) BOOL agent;

@property (nonatomic, weak) id <CallInProgressViewDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIView *callsOnHoldContainerView;
@property (weak, nonatomic) CallsOnHoldView* callsOnHoldView;

- (void)showContactInfoForContact:(Contact*)contact;
- (void)startControlsTimer;
- (void)stopControlsTimer;
- (void)startCallDurationTimerWithStartTime:(NSTimeInterval)callStartTime;
- (void)startCallWaitingActivityIndicator;
- (void)stopCallWaitingActivityIndicator;
- (void)stopCallDurationTimer;
- (BOOL)hasCallDurationTimerRunning;

- (void)setBluetoothAvailable: (BOOL) bluetoothAvailable;
- (void)setMuteButtonSelected:(BOOL) selected;
- (void)setSpeakerButtonSelected: (BOOL) selected;

- (void)hideContactAvatar;
- (void)showContactAvatar:(UIImage *)image;

- (void)showControlsIfNeeded;
- (void)showContactInfo;

- (void) enableCameraButton: (BOOL) bEnable;

@end

@protocol CallInProgressViewDelegate <NSObject>

- (void)callInProgressView:(CallInProgressView*)view
onRequestVisitorInfoAction:(UIButton*)button
         completionHandler:(void(^)(BOOL succeededSendingRequest))completionHandler;
- (void)callInProgressView:(CallInProgressView*)view onMessageButtonAction:(UIButton*)button;
- (void)callInProgressView:(CallInProgressView*)view onCameraButtonAction:(UIButton*)button;
- (void)callInProgressView:(CallInProgressView*)view onMuteButtonAction:(UIButton*)button;
- (void)callInProgressView:(CallInProgressView*)view onDeclineButtonAction:(UIButton*)button;
- (void)callInProgressView:(CallInProgressView*)view onSpeakerButtonAction:(UIButton*)button;

@end
