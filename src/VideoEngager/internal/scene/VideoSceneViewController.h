//
//  VideoSceneViewController.h
//  leadsecure
//
//  Created by Angel Terziev on 8/11/15.
//  Copyright (c) 2015 SoftAvail. All rights reserved.
//

//#import "CallRingingPresenter.h"
//#import "ICOLLViewController.h"
//#import "ChatViewController.h"
#import "VDEInternal.h"
#import "CallInProgressView.h"
#import "CallsOnHoldView.h"

@class VDEAgentViewController;

@interface VideoSceneViewController : UIViewController <CallInProgressViewDelegate,
                                                        CallsOnHoldViewDelegate>
                                                        /* ChatViewControllerDelegate,
                                                           UIActionSheetDelegate */

@property (nonatomic, readonly) NSString* callId;
//@property (nonatomic, weak) id <VideoSceneShowController> videoSceneShowController;
@property (nonatomic, readonly) LSCall* call;
@property (nonatomic, readonly) NSString* participantId;
@property (nonatomic) BOOL autoStartCamera;

- (id) initWithCallId:(NSString *)callId
        participantId:(NSString *)participantId
          callManager:(VDEInternal*)vde
 parentViewController:(VDEAgentViewController*) parentViewController;

- (void)showCallControls;
- (void)hideCallControls;

@end
