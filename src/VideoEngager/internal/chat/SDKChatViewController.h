//
//  SDKChatViewController.h
//  instac
//
//  Created by Bozhko Terziev on 11/19/14.
//  Copyright (c) 2014 SoftAvail. All rights reserved.
//


#import <UIKit/UIKit.h>

//#import "CallRingingPresenter.h"
#import "ICOLLMessageInputView.h"
//#import "ICOLLViewController.h"
#import "VDEInternal.h"
#import "IParticipant.h"

#import "IRTCManager.h"
#import "RefCountPtr.h"

@protocol SDKChatViewControllerDelegate;

@interface SDKChatViewController : UIViewController <ICOLLMessageTextViewDelegate, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, UITextViewDelegate/*,CallRingingPresenter*/>
{
}

@property (weak, nonatomic) id <SDKChatViewControllerDelegate> delegate;
@property (weak) id callerViewController;

- (instac::RefCountPtr<instac::IParticipant>)participant;

- (instancetype) initWithParticipantId: ( NSString    *) participantId
                    andInternalManager: ( VDEInternal *) vdeInternal;


@end

@protocol SDKChatViewControllerDelegate <NSObject>

@optional
- (void)chatViewControllerDidClickTrashButton:(SDKChatViewController*)chatViewController;
- (void)chatViewControllerDidClickCameraButton:(SDKChatViewController*)chatViewController;
- (NSString*) chatViewControllerDidRequestDefaultChatMessage:(SDKChatViewController*)chatViewController;
- (void)chatViewControllerDidClickBackButton:(SDKChatViewController*)chatViewController;


@end

