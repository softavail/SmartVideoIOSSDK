
//
//  SDKChatViewController.mm
//  instac
//
//  Created by Bozhko Terziev on 11/19/14.
//  Copyright (c) 2014 SoftAvail. All rights reserved.
//

#import "SDKChatViewController.h"
#import "UIColor+Additions.h"
#import "NSString+ICOLLMessagesView.h"
//#import "UIView+AnimationOptionsForCurve.h"
//#import "ICOLLDismissiveTextView.h"
//#import "UINavigationController+Additions.h"
//#import "FakeMessage.h"
#import "UIImage+Additions.h"

#import "CallEventCell.h"
#import "IncomingMessageCellAvatar.h"
#import "OutgoingMessageCellAvatar.h"
#import "DateMarkerCell.h"
//
//#import "CallsContainer.h"
//
#include "IFacade.h"
#include "IRTCManager.h"
#include "RTCEvent.h"
#include "IEventSink.h"
#import "RtcEventsListener.h"
#include "AutoPtr.h"

#import "LSCall.h"
#import "LSParticipant.h"

//#import "LSQoSMonitor.h"
//
//#import "ChatTableHeaderView.h"
//#import "ChatCallTransferStatusView.h"
//
//#import "CallTransferNavigationController.h"
//#import "CallTransferViewController.h"
//#import "LSEndPoint.h"
//
//#import "RtcMediator.h"
//#import "AvatarView.h"
//#import "SAAvatarManager.h"
//#import "ChatTableFooterView.h"
//
static NSString* const CallEventCellIdentifier      = @"CallEventCellIdentifier";
static NSString* const IncomingMessageCellAvatarIdentifier= @"IncomingMessageCellAvatarIdentifier";
static NSString* const OutgoingMessageCellAvatarIdentifier=@"OutgoingMessageCellAvatarIdentifier";
static NSString* const DateMarkerCellIdentifier     = @"DateMarkerCellIdentifier";
//
//#ifdef DEBUG
//static void printViewConstraints(UIView* aView);
//#endif
//
#define INPUT_HEIGHT 46.0f

#define TEST_MESSAGE_COUNT 10
#define RIGHT_BAR_BUTTON_ITEM_OFFSET            6
#define MAX_MESSAGE_LENGTH                      1000

static NSInteger kTagTopLabel                      = 8033;

typedef NS_ENUM(NSInteger, LSChatControllerState)
{
    kChatControllerStateNoCall,
    kChatControllerStateCallNotAccepted,
    kChatControllerStateCallAccepted,
    kChatControllerStateCallEnded,
    kChatControllerStateParticipantLeft
};

@interface SDKChatViewController ()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *toolbarBottom;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textInputHeight;
@property (weak, nonatomic) IBOutlet ICOLLMessageTextView *textView;
@property (weak, nonatomic) IBOutlet UIImageView *imgViewUnderline;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *sendButton;
- (IBAction)onClickButtonSend:(id)sender;
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintMediaViewHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintTextViewVerticalSpace;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintTextViewBottomSpace;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintTextViewLeadingSpace;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintSendButtonTrailingSpace;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintTextViewHorizontalSpaceToSendButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintSendButtonWidth;
@property (weak, nonatomic) IBOutlet UIView *separatorInputBar;
@property (nonatomic) NSString* rtcEventsListenerIdentifier;

@property (assign, nonatomic) CGFloat keypadHeight;

@property (nonatomic, strong) UITapGestureRecognizer* tapGesture;
@property (nonatomic, strong) NSDateFormatter* todayFormatter;
@property (nonatomic, strong) NSDateFormatter* dayOnlyFormatter;
@property (nonatomic, strong) NSDateFormatter* dateOnlyFormatter;
@property (nonatomic) BOOL shouldScrollToBottom;
@property (nonatomic, strong) NSString* recipientName;
@property (nonatomic, weak)VDEInternal* vdeInternal;

@property (nonatomic, strong) UIPopoverPresentationController* popOverPresController;

@property (nonatomic, weak) UIRefreshControl* refreshControl;
@property (nonatomic) BOOL needToScrollToBottomAfterLoad;

@end


@implementation SDKChatViewController
{
    instac::RefCountPtr<instac::IParticipant> _participant;
    instac::RefCountPtr<instac::IRTCManager> _rtcManager;
    instac::AutoPtr<instac::IEventSink<instac::RTCEvent> > _rtcEventListener;
}
#pragma mark - UIViewController delegates

- (instancetype) initWithParticipantId: (NSString    *) participantId
                    andInternalManager: (VDEInternal *) vdeInternal
{
    NSBundle* nibBundleOrNil = [NSBundle bundleForClass:[self class]];
    
    if(nil != (self = [super initWithNibName:@"SDKChatViewController" bundle:nibBundleOrNil])) {
        self.todayFormatter = [NSDateFormatter new];
        [self.todayFormatter setDateFormat: @"h:mm a"];
        [self.todayFormatter setTimeZone: [NSTimeZone localTimeZone]];

        instac::IFacade::getInstance()->getRTCManager(_rtcManager);
        _rtcManager->setToPrefetchChatMessages();
        
        self.vdeInternal = vdeInternal;
        [self setParticipantId:participantId];
        [self setupChatListener];
    }
    
    return self;
}

- (void)setParticipantId:(NSString*)participantId
{
    instac::RefCountPtr<instac::IParticipant> participant = _rtcManager->participantWithId(participantId.UTF8String);

    if ((participant == NULL) || (participant.get() == NULL))
    {
        IMLogErr("Could not initialize SDKChatViewController, could not find participant with id %s", participantId.UTF8String);
        return;
    }

    _participant = participant;
}

- (void) setupChatListener
{
    NSArray* eventActions = @[
                              @(instac::IRTCManager::ActionParticipantAvailabilityChanged),
                              @(instac::IRTCManager::ActionDidDeleteVisitor),
                              @(instac::IRTCManager::ActionChatAccepted),
                              @(instac::IRTCManager::ActionChatEnded),
                              @(instac::IRTCManager::ActionOutgoingChatRequest),
                              @(instac::IRTCManager::ActionDidEnqueueChatMessage),
                              @(instac::IRTCManager::ActionDidReceiveChatMessage),
                              @(instac::IRTCManager::ActionDidRetrieveMessagesForVisitor),
                              @(instac::IRTCManager::ActionDidUpdateVisitor),
                              @(instac::IRTCManager::ActionIncomingChatRequest),
                              @(instac::IRTCManager::ActionDidResetVisitors),
                              @(instac::IRTCManager::ActionDidEstablishCommunicationChannel),
                              ];

    __weak typeof(self) weakSelf = self;

    _rtcEventsListenerIdentifier = [[RtcEventsListener sharedInstance] notifyOnEventActions:eventActions
                                                                                    timeout:0
                                                                          completionHandler:^(instac::RTCEvent* event, BOOL isTimedOut, BOOL* stop)
     {
         switch (event->getType())
         {
             case instac::RTCEvent::ActionCompletion:
             {
                 IMLogVbs("Did ActionCompletion %d", event->getAction());
                 switch (event->getAction())
                 {
                     case instac::IRTCManager::ActionParticipantAvailabilityChanged:
                     {
                         const instac::RefCountPtr<instac::IParticipant> participant = event->getParticipant();
                         
                         if (participant->getId().compare(_participant->getId()) == 0)
                         {
                             [weakSelf.navigationItem setTitle:OBJCStringA(_participant->name())];
                             [weakSelf setupInputViewsState];
                             [weakSelf updateBarButtonItems];
                         }
                     }
                         break;
                     case instac::IRTCManager::ActionDidDeleteVisitor:
                     {
                         const instac::RefCountPtr<instac::IParticipant> participant = event->getParticipant();
                         
                         if (participant->getId().compare(_participant->getId()) == 0)
                         {
                             [self goToPrevious];
                         }
                     }
                         break;
                     case instac::IRTCManager::ActionChatAccepted:
                     {
                         const instac::CallArgs& callArgs = event->getCallArgs();
                         const instac::String& callId = callArgs.identifier();
                         
                         instac::RefCountPtr<instac::ICall> call = _rtcManager->getCall(callId);
                         
                         if ([weakSelf isCallForThisParticipant:call])
                         {
                             _rtcManager->resetParticipantUnreadChatMessages(weakSelf.participant->getId());
                             
                             [weakSelf setInputViewsState:kChatControllerStateCallAccepted];
                             
                             [weakSelf updateBarButtonItems];
                             [weakSelf updateTableHeaderView];
                             [weakSelf showTableFooterView:NO];
                             
                             _rtcManager->resetMessagesForParticipant(weakSelf.participant);
                             IMLogVbs("[chatview] reload table from line %d", __LINE__);
                             [weakSelf.tableView reloadData];
                             IMLogDbg("[CH] loadMoreMessages from %d", __LINE__);
                             if(1 == [weakSelf loadMoreMessages])
                                 weakSelf.needToScrollToBottomAfterLoad = YES;
                         }
                     }
                         break;
                     case instac::IRTCManager::ActionChatEnded:
                     {
                         const instac::CallArgs& callArgs = event->getCallArgs();
                         const instac::String& callId = callArgs.identifier();
                         
                         instac::RefCountPtr<instac::ICall> call = _rtcManager->getCall(callId);;
                         
                         if ([weakSelf isCallForThisParticipant:call])
                         {
                             [weakSelf updateTableHeaderView];
                             [weakSelf showTableFooterView: NO];
                             [weakSelf setInputViewsState:kChatControllerStateCallEnded];
                             [weakSelf updateBarButtonItems];
                         }
                         else
                         {
                             IMLogDbg("Could not handle event 'ActionChatEnded', could not find call with id %s", callId.c_str());
                         }
                     }
                         break;
                     case instac::IRTCManager::ActionOutgoingChatRequest:
                     {
                         const instac::CallArgs& callArgs = event->getCallArgs();
                         const instac::String& callId = callArgs.identifier();
                         
                         instac::RefCountPtr<instac::ICall> call = _rtcManager->getCall(callId);
                         
                         if ([weakSelf isCallForThisParticipant:call])
                         {
                             [weakSelf updateTableHeaderView];
                             [weakSelf showTableFooterView: YES];
                         }
                         else
                         {
                             IMLogDbg("Could not handle event 'ActionChatEnded', could not find call with id %s", callId.c_str());
                         }
                     }
                         break;
                     case instac::IRTCManager::ActionDidEnqueueChatMessage:
                     {
                         IMLogDbg("[chatview] Did receive ActionDidEnqueueChatMessage. Will finish send", 0);
                         [weakSelf finishSend];
                     }
                         break;
                         //                case instac::IRTCManager::ActionDidSendChatMessage:
                         //                {
                         //                    IMLogDbg("[chatview] Did receive ActionDidSendChatMessage. Will reload data", 0);
                         //                    IMLogVbs("reload table from line %d", __LINE__);
                         //                    [weakSelf.tableView reloadData];
                         //                }
                         //                    break;
                     case instac::IRTCManager::ActionDidReceiveChatMessage:
                     {
                         const instac::RefCountPtr<instac::IParticipant> participant = event->getParticipant();
                         
                         if (participant->getId().compare(_participant->getId()) == 0)
                         {
                             IMLogVbs("[chatview] reload table from line %d", __LINE__);
                             [weakSelf.tableView reloadData];
                             
                             unsigned long msgsCount = [weakSelf.tableView numberOfRowsInSection:0];
                             if (msgsCount > 0)
                             {
                                 unsigned long lastMessageIndex = msgsCount - 1;
                                 
                                 IMLogVbs("[chatview] scroll anim to index: %d", lastMessageIndex);
                                 [weakSelf.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:lastMessageIndex
                                                                                           inSection:0]
                                                       atScrollPosition:UITableViewScrollPositionBottom
                                                               animated:YES];
                             }
                             
                             if (_rtcManager != NULL)
                             {
                                 if ((_participant != NULL) && (_participant.get() != NULL))
                                 {
                                     _rtcManager->resetParticipantUnreadChatMessages(participant->getId());
                                 }
                             }
                         }
                     }
                         break;
                     case instac::IRTCManager::ActionDidRetrieveMessagesForVisitor:
                     {
                         const instac::RefCountPtr<instac::IParticipant> participant = event->getParticipant();
                         
                         if (participant->getId().compare(_participant->getId()) == 0)
                         {
                             if (event->customValue1() > 0) {
                                 [weakSelf stopAnimationRefreshing];
                                 [weakSelf updateRefreshControlTitle];
                                 [weakSelf updateTableHeaderView];
                                 IMLogVbs("[chatview] reload table from line %d", __LINE__);
                                 [weakSelf.tableView reloadData];
                                 if (weakSelf.needToScrollToBottomAfterLoad) {
                                     [weakSelf scrollToBottomWithoutAnimation];
                                     weakSelf.needToScrollToBottomAfterLoad = NO;
                                 }
                             } else if (weakSelf.participant->hasMoreMessages()) {
                                 IMLogDbg("[CH] loadMoreMessages from %d", __LINE__);
                                 [weakSelf loadMoreMessages];
                                 // will load more, do not clear flag to scrool to bottom when next portion is received
                             } else {
                                 IMLogDbg("[CH] no more messages", 0);
                                 [weakSelf stopAnimationRefreshing];
                                 [weakSelf updateRefreshControlTitle];
                                 
                                 // clear tthe flag to scroll to bottom, wont load more
                                 if (weakSelf.needToScrollToBottomAfterLoad) {
                                     weakSelf.needToScrollToBottomAfterLoad = NO;
                                 }
                             }
                         }
                         
                     }
                         break;
                     case instac::IRTCManager::ActionDidUpdateVisitor:
                     {
                         instac::RefCountPtr<instac::IParticipant> visitor = event->getVisitor();
                         
                         if (visitor->getId().compare(_participant->getId()) == 0)
                         {
                             [weakSelf updateBanner];
                         }
                     }
                         break;
                         break;
                     case instac::IRTCManager::ActionIncomingChatRequest:
                     {
                         const instac::CallArgs& callArgs = event->getCallArgs();
                         const instac::String& callId = callArgs.identifier();
                         instac::RefCountPtr<instac::ICall> chatCall = _rtcManager->getCall(callId);
                         if ([weakSelf isCallForThisParticipant:chatCall])
                         {
                             _rtcManager->acceptCall(chatCall->callId());
                         }
                     }
                         break;
                     case instac::IRTCManager::ActionDidResetVisitors:
                     {
                         IMLogDbg("[chatview] Visitors have been reset, reload chat screen", 0);
                         _rtcManager->resetMessagesForParticipant(weakSelf.participant);
                         [weakSelf updateRefreshControlTitle];
                         IMLogVbs("[chatview] reload table from line %d", __LINE__);
                         [weakSelf.tableView reloadData];
                     }
                         break;
                     case instac::IRTCManager::ActionDidEstablishCommunicationChannel:
                     {
                         /*
                          Need to recreate participant object because it maight change during session renew/bind.
                          This could happen when the app was in background with chat screen opened
                          Then when the appreturns in foreground we reestablish the session which clears all the objects
                          */
                         [weakSelf reCreateParticipantObject];
                         
                         // Then need to reload all messages in case we have received some in background
                         IMLogVbs("[chatview] reload table from line %d", __LINE__);
                         [weakSelf.tableView reloadData];
                         
                         unsigned long count = [weakSelf.tableView numberOfRowsInSection:0];
                         if ( count > 0 )
                         {
                             unsigned long lastMessageIndex = count - 1;
                             
                             IMLogVbs("[chatview] scroll anim to index: %d of %d", lastMessageIndex, count);
                             [weakSelf.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:lastMessageIndex
                                                                                       inSection:0]
                                                   atScrollPosition:UITableViewScrollPositionBottom
                                                           animated:YES];
                         } else {
                             // just load some  messages
                             IMLogDbg("[CH] loadMoreMessages from %d", __LINE__);
                             [weakSelf loadMoreMessages];
                         }
                     }
                         break;
                     default:
                         break;
                 }
             }
                 break;
             default:
                 break;
         }
     }];
}

- ( void )
dealloc
{
//    if (_rtcManager != NULL)
//    {
//        _rtcManager->unsubscribeForEvents(*_rtcEventListener.get());
//    }
    
    [[RtcEventsListener sharedInstance] removeListenerWithIdentifier:_rtcEventsListenerIdentifier];
}

//- (LSCallRingingType)callRingingType
//{
//    return kFullScreenCallRingingType;
//}

- (instac::RefCountPtr<instac::IParticipant>)participant
{
    return _participant;
}

////@@@@ TODO: Revisit this method
- ( void )
viewWillTransitionToSize        : ( CGSize                                      ) size
withTransitionCoordinator       : ( id <UIViewControllerTransitionCoordinator>  ) coordinator
{
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    IMLogVbs("[chatview] reload table from line %d", __LINE__);
    [self.tableView reloadData];
    [self.tableView setNeedsLayout];

    [self.textView setNeedsDisplay];

    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context)
     {
         // do whatever
     } completion:^(id<UIViewControllerTransitionCoordinatorContext> context)
     {

     }];
}

- ( void )
viewWillAppear: ( BOOL ) animated
{
    [super viewWillAppear:animated];

    self.tableView.scrollsToTop = NO;

//    [[LSQoSMonitor sharedInstance] addQoSImageView: [self getGaugeView]];
//
//    NSString * participantId = OBJCStringA(_participant->getId());
//    [[NotificationManager instance] setActiveChatParticipant: participantId];
}

- ( void )
viewDidAppear: ( BOOL ) animated
{
    [super viewDidAppear:animated];


    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleWillShowKeyboard:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleWillHideKeyboard:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];

    self.tableView.scrollsToTop = YES;

    [self showKeypad];

    // for Agents only
    //[self sendFirstChatMessageIfNeccessary];

    if(0 == _rtcManager->getParticipantMessagesCount(_participant->getId())) {
        IMLogDbg("[CH] loadMoreMessages from %d", __LINE__);
        if(1 == [self loadMoreMessages])
            self.needToScrollToBottomAfterLoad = YES;
    }

    [self updateTableFooterView];
}

- ( void )
viewWillDisappear: ( BOOL ) animated
{
    [super viewWillDisappear:animated];

//    [[NotificationManager instance] setActiveChatParticipant: nil];

    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

//- ( void )
//viewDidDisappear: ( BOOL ) animated
//{
//    [super viewDidDisappear:animated];
//
//    [[LSQoSMonitor sharedInstance] removeQoSImageView:[self getGaugeView]];
//}
//
- ( void )
viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];

    if ( self.shouldScrollToBottom )
    {
        // Scroll table view to the last row
        [self scrollToBottomWithoutAnimation];

        self.shouldScrollToBottom = NO;
    }

    [self updateQoSViewSize];
}

- (void)updateQoSViewSize
{
    UIImageView* qosImageView = self.navigationItem.rightBarButtonItem.customView;
    CGFloat navigationBarHeight = self.navigationController.navigationBar.frame.size.height - RIGHT_BAR_BUTTON_ITEM_OFFSET;
    qosImageView.bounds = CGRectMake(0.0, 0.0, navigationBarHeight, navigationBarHeight);
}

- (void)showTableHeaderWithText: (NSString*) headerText withBackgroundColor:(UIColor*) color {

    [[self.view viewWithTag:kTagTopLabel] removeFromSuperview];

    if ( nil == headerText || [headerText length] == 0 ) {

        UIEdgeInsets tableInsets = self.tableView.contentInset;

        self.tableView.contentInset = UIEdgeInsetsMake(0.0,
                                                       tableInsets.left,
                                                       tableInsets.bottom,
                                                       tableInsets.right);

        self.tableView.scrollIndicatorInsets = self.tableView.contentInset;

    } else {

        CGFloat labelHeight = 35.0f;

        UILabel* lbl = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, CGRectGetWidth(self.view.bounds), labelHeight)];

        if ( nil != lbl ) {

            lbl.tag = kTagTopLabel;
            lbl.textColor = [UIColor whiteColor];
            lbl.font = [UIFont systemFontOfSize:15 weight:UIFontWeightRegular];
            lbl.backgroundColor = (nil == color) ? [UIColor statusRedColor] : color;
            lbl.numberOfLines = 0;
            lbl.text = headerText;
            lbl.textAlignment = NSTextAlignmentCenter;
            lbl.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;

            [self.view addSubview:lbl];

            UIEdgeInsets tableInsets = self.tableView.contentInset;

            self.tableView.contentInset = UIEdgeInsetsMake(labelHeight,
                                                           tableInsets.left,
                                                           tableInsets.bottom,
                                                           tableInsets.right);

            self.tableView.scrollIndicatorInsets = self.tableView.contentInset;
        }
    }
}

- (void) showPopoverFormBbi:(UIBarButtonItem*)bbi {
//
//    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Leadsecure" bundle:[NSBundle mainBundle]];
//
//    if ( nil != sb ) {
//
//        CallTransferNavigationController* nc = [sb instantiateViewControllerWithIdentifier:@"CallTransferNavigationController"];
//
//        CallTransferViewController* root = [[nc viewControllers] firstObject];
//
//        if ( [root isKindOfClass:[CallTransferViewController class]] ) {
//
//            root.delegate = self;
//        }
//
//        nc.preferredContentSize = CGSizeMake(CGRectGetWidth(self.view.bounds) - 6*DEFAULT_OFFSET, MAX_CALL_TRANSFER_POPOVER_HEIGHT);
//        nc.modalPresentationStyle = UIModalPresentationPopover;
//        self.popOverPresController = nc.popoverPresentationController;
//        self.popOverPresController.delegate = self;
//        self.popOverPresController.barButtonItem = bbi;
//
//        self.popOverPresController.permittedArrowDirections = UIPopoverArrowDirectionDown | UIPopoverArrowDirectionUp;
//
//        [self presentViewController:nc animated:YES completion:nil];
//    }
}

//- (void) updateChatCallTransferFooterView
//{
//    CallTransferStatus callTrStatus = CallTransferStatusRemove;
//    instac::RefCountPtr<instac::ICall> trCall = self.participant->getTransferCall();
//    NSString* recipientName = @"";
//
//    if (trCall.get() != NULL)
//    {
//        recipientName = OBJCStringA(trCall->participantName());
//
//        switch (trCall->callState()) {
//            case instac::CallStateRinging:
//                callTrStatus = CallTransferStatusInProgress;
//                break;
//            case instac::CallStateAccepted:
//                callTrStatus = CallTransferStatusAccepted;
//                break;
//            case instac::CallStateEnded:
//                if(0 == trCall->endReason().compareNoCase("rejected")) {
//                    callTrStatus = CallTransferStatusRejected;
//                } else if(0 == trCall->endReason().compareNoCase("caller hangup")) {
//                    if(trCall->answerTime() > 0) {
//                        callTrStatus = CallTransferStatusAccepted;
//                    } else {
//                        callTrStatus = CallTransferStatusCanceled;
//                    }
//                } else {
//                    if(trCall->answerTime() > 0) {
//                        callTrStatus = CallTransferStatusAccepted;
//                    } else {
//                        callTrStatus = CallTransferStatusFailed;
//                    }
//                }
//                break;
//            default:
//                callTrStatus = CallTransferStatusFailed;
//                break;
//        }
//    }
//
//    [self updateChatCallTransferFooterViewWithState: callTrStatus
//                                      withRecipient: recipientName];
//}
//
//- (void) updateChatCallTransferFooterViewWithState:(CallTransferStatus) transferStatus withRecipient:(NSString*) recipient {
//
//    self.transferStatus = transferStatus;
//    self.recipientName = recipient;
//
//    IMLogVbs("[chatview] reload table from line %d", __LINE__);
//    [self.tableView reloadData];
//}

- (void) updateBarButtonItems {

    [self rightBarButtons];
    [self updateToolbarItems];
}

- ( void )viewDidLoad
{
    [super viewDidLoad];

    self.separatorInputBar.backgroundColor = [UIColor separatorInputBarColor];
    
    // fix for ipad modal form presentations
    if([self.view isKindOfClass:[UIScrollView class]])
        ((UIScrollView *)self.view).scrollEnabled = NO;

    [self.view setBackgroundColor:[UIColor whiteColor]];

    [self.navigationItem setTitle:OBJCStringA(_participant->name())];

    self.shouldScrollToBottom = YES;

//    [self addLeftBarButtons];

    [self configureTableView];
    [self configureTextView];
//
    [self setupRefreshControl];
    [self updateRefreshControlTitle];

    [self setupInputViewsState];

    if ( nil != self.navigationController )
    {

        if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {

            self.navigationController.interactivePopGestureRecognizer.enabled = NO;
        }
    }

    self.toolbar.tintColor = [UIColor barButtonItemColor];
    self.toolbar.barTintColor = [UIColor cellBackgroundColor];
    [self.sendButton setTitle:ICOLLString(@"Chat:Button:Send") forState:UIControlStateNormal];
    [self.sendButton setTitleColor:[UIColor chatToolbarTintColor] forState:UIControlStateNormal];
    [self updateBarButtonItems];
//
//    _rtcEventListener = new EventListener<SDKChatViewController, instac::RTCEvent>(self, @selector(onRtcEvent:));
//
//    if (NULL != _rtcManager)
//    {
//        _rtcManager->subscribeForEvents(*_rtcEventListener.get());
//    }
//
//    NSString * participantId = OBJCStringA(_participant->getId());
//    [[NotificationManager instance] postNotificationStopChatRingingWithParticipant: participantId];
//
    _rtcManager->resetParticipantUnreadChatMessages(_participant->getId());

    [self updateTableHeaderView];

    [self updateBanner];
//    [self updateChatCallTransferFooterView];
}

- (void) updateTableHeaderView {

    if (self.participant->activeChatCalls().size() == 0 &&
        0 == _rtcManager->getParticipantMessagesCount(_participant->getId()))
    {
        [self showTableHeaderView:YES];
    } else {
        [self showTableHeaderView:NO];
    }
}

- (void) updateTableFooterView {
    BOOL hasOutgoingChatRinging = NO;
    const std::vector<instac::RefCountPtr<instac::ICall>> chatCalls = self.participant->chatCalls();
    for (std::vector<instac::RefCountPtr<instac::ICall>>::const_iterator it = chatCalls.begin(); it != chatCalls.end(); ++it)
    {
        if ((*it)->callState() == instac::CallStateRinging)
        {
            if((*it)->callDirection() == instac::ICall::CallDirectionOutgoing) {
                hasOutgoingChatRinging = YES;
                break;
            }
        }
    }

    [self showTableFooterView:hasOutgoingChatRinging];
}

-(NSAttributedString*) attributedTextForParticipantName:(NSString*) name {

    NSMutableAttributedString* res = nil;

    if ( name.length <= 0 ) {

        res = [[NSMutableAttributedString alloc] initWithString:ICOLLString(@"Chat:Tap:To:Send:Anonimous") attributes:nil];

    } else {

        NSString* strForAttributing = [NSString stringWithFormat:ICOLLString(@"Chat:Tap:To:Send"), name];

        UIFont *nameFont        = [UIFont systemFontOfSize:18 weight:UIFontWeightBold];

        NSDictionary *attrName = [NSDictionary dictionaryWithObjectsAndKeys:
                                  nameFont, NSFontAttributeName,
                                  [UIColor vanityNameColor], NSForegroundColorAttributeName, nil];


        res = [[NSMutableAttributedString alloc] initWithString:strForAttributing attributes:nil];

        NSRange rangeName = [strForAttributing rangeOfString:name];

        if ( NSNotFound != rangeName.location ) {

            [res addAttributes:attrName range:rangeName];
        }
    }

    return res;
}

-(NSAttributedString*) attributedText2ForParticipantName:(NSString*) name {

    NSMutableAttributedString* res = nil;

    if ( name.length <= 0 ) {

        res = [[NSMutableAttributedString alloc] initWithString:ICOLLString(@"Chat:Waiting:For:Accept:Anonymous") attributes:nil];

    } else {

        NSString* strForAttributing = [NSString stringWithFormat:ICOLLString(@"Chat:Waiting:For:Accept"), name];

        UIFont *nameFont        = [UIFont systemFontOfSize:18 weight:UIFontWeightBold];

        NSDictionary *attrName = [NSDictionary dictionaryWithObjectsAndKeys:
                                  nameFont, NSFontAttributeName,
                                  [UIColor vanityNameColor], NSForegroundColorAttributeName, nil];


        res = [[NSMutableAttributedString alloc] initWithString:strForAttributing attributes:nil];

        NSRange rangeName = [strForAttributing rangeOfString:name];

        if ( NSNotFound != rangeName.location ) {

            [res addAttributes:attrName range:rangeName];
        }
    }

    return res;
}

- (UIView*)headerViewWithText: (NSString*) headerText
{
    UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.tableView.bounds), 275.0f)];

    if ( nil != header ) {

        header.backgroundColor = [self.tableView backgroundColor];
        header.autoresizingMask = UIViewAutoresizingFlexibleWidth;

        UIImageView* iv = [[UIImageView alloc] initWithImage:[UIImage sdkImageNamed:@"imageCallerTransparent"]];

        if ( nil != iv ) {

            iv.contentMode = UIViewContentModeCenter;
            iv.frame = CGRectMake(0.0f, 10.0f, CGRectGetWidth(header.bounds), 200.0f);
            iv.backgroundColor = header.backgroundColor;
            iv.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth;

            [header addSubview:iv];
        }

        UILabel* lbl = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 210.0f, CGRectGetWidth(header.bounds), 65.0f)];

        if ( nil != lbl ) {

            lbl.numberOfLines = 0;
            lbl.backgroundColor = header.backgroundColor;
            lbl.font = [UIFont systemFontOfSize:16 weight:UIFontWeightLight];
            lbl.textColor = [UIColor cellTextColor];
            lbl.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
            lbl.textAlignment = NSTextAlignmentCenter;

            NSAttributedString* attrText = [self attributedTextForParticipantName:headerText];

            if ( nil != attrText )
                lbl.attributedText = attrText;
            else
                lbl.text = headerText;

            [header addSubview:lbl];
        }
    }

    return header;
}

//- (UIView*)footerViewWithParticipantName: (NSString*) participantName
//{
//    ChatTableFooterView* footerView;
//    NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"ChatTableFooterView"
//                                                     owner:nil options:nil];
//    if ( [objects count] > 0 ) {
//        for ( UIView* v in objects ) {
//            if ( [v isKindOfClass:[ChatTableFooterView class]] ) {
//
//                footerView = (ChatTableFooterView*)v;
//                NSAttributedString* attrText = [self attributedText2ForParticipantName:participantName];
//
//                [footerView setAttributedTitle: attrText];
//                break;
//            }
//        }
//    }
//
//    return footerView;
//}
//
- (void)showTableHeaderView:(BOOL) show {

    if ( !show ) {
        self.tableView.tableHeaderView = nil;
    } else {
        self.tableView.tableHeaderView = [self headerViewWithText:OBJCStringA(_participant->name())];
    }
}

- (void)showTableFooterView:(BOOL) show {

//    if ( !show ) {
        self.tableView.tableFooterView = nil;
//    } else {
//        self.tableView.tableFooterView = [self footerViewWithParticipantName:OBJCStringA(_participant->name())];
//    }
}


- (void)rightBarButtons {

//    NSMutableArray* buttons = [NSMutableArray new];
//
//    // Gauge
//    [buttons addObject:[self gaugeBbi]];
//
//#if 0
//    // Camera
//    if ([self needCameraBBi])
//        [buttons addObject:[self cameraBbi]];
//
//    // Info
//    if ([self needCallTransferBBi])
//        [buttons addObject:[self callTransferBBi]];
//
//    // Info
//    if ([self needInfoBBi])
//        [buttons addObject:[self infoBbi]];
//#endif
//
//    self.navigationItem.rightBarButtonItems = buttons;
}

- (void) updateToolbarItems
{
    NSMutableArray<UIBarButtonItem*>* buttons = [NSMutableArray new];

//    // Info
//    if ([self needInfoBBi]) {
//        [buttons addObject:[self infoBbi]];
//    }
//
//    // Transfer
//    if ([self needCallTransferBBi]) {
//        if (buttons.count)
//            [buttons addObject: [self spacerBbi]];
//
//        [buttons addObject:[self callTransferBBi]];
//    }

    // back button
    [buttons addObject:[self backBbi]];
    
    // Camera
    if ([self needCameraBBi]) {
        if (buttons.count)
            [buttons addObject: [self spacerBbi]];

        [buttons addObject:[self cameraBbi]];
    }
//
//    // Trash
//    if ([self needTrashBBi]) {
//        if (buttons.count)
//            [buttons addObject: [self spacerBbi]];
//
//        [buttons addObject:[self trashBBi]];
//    }

    [self.toolbar setItems: buttons animated:NO];
}

- (NSString*) getInitials {
    NSMutableString* initials = [[NSMutableString alloc] initWithCapacity: 2];
    NSString* fc = nil;
    NSString* lc = nil;

    NSString* name = OBJCStringA(_participant->name());
    NSArray<NSString *> * components = [name componentsSeparatedByString: @" "];

    if (components.count > 0) {
        NSString* fname = components[0];
        if (fname.length > 0)
            fc = [fname substringToIndex: 1];
    }

    if (components.count > 1) {
        NSString* lname = components[components.count - 1];
        if (lname.length)
            lc = [lname substringToIndex: 1];
    }

    if (fc)
        [initials appendString: fc];
    if (lc)
        [initials appendString: lc];

    return [NSString stringWithString: initials];
}

//- (AvatarView*) getAvatarView {
//
//    AvatarView* avatarView = nil;
//
//    if (self.navigationItem.leftBarButtonItems.count > 1) {
//        UIBarButtonItem* bbi = self.navigationItem.leftBarButtonItems[1];
//        if ([bbi.customView isKindOfClass: [AvatarView class]]) {
//            avatarView = bbi.customView;
//        }
//    }
//
//    return avatarView;
//}

-(void)addLeftBarButtons
{
    NSMutableArray *leftButtons = [[NSMutableArray alloc] initWithCapacity:2];
    [leftButtons addObject:[self backBBi]];

    if (_rtcManager->isAgent()){
//        // display avatar only when logged as agent
//        [leftButtons addObject: [self avatarBBi]];
    }

    self.navigationItem.leftBarButtonItems = leftButtons;
}
//
//-(UIButton*) getGaugeView
//{
//    UIButton* gaugeView = nil;
//
//    NSArray* arr = self.navigationItem.rightBarButtonItems;
//
//    if ( [arr count] > 0 )
//        gaugeView = [(UIBarButtonItem*)arr[0] customView];
//
//    return gaugeView;
//}
//
- ( void )
configureTableView
{
    self.tableView.accessibilityIdentifier = @"Chat Screen";

    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];

    NSBundle* bundle = [NSBundle bundleForClass: [self class]];
    [self.tableView registerNib:[UINib nibWithNibName:@"CallEventCell"          bundle:bundle] forCellReuseIdentifier:CallEventCellIdentifier];
    [self.tableView registerNib:[UINib nibWithNibName:@"IncomingMessageCellAvatar"    bundle:bundle] forCellReuseIdentifier:IncomingMessageCellAvatarIdentifier];
    [self.tableView registerNib:[UINib nibWithNibName:@"OutgoingMessageCellAvatar"    bundle:bundle] forCellReuseIdentifier:OutgoingMessageCellAvatarIdentifier];
    [self.tableView registerNib:[UINib nibWithNibName:@"DateMarkerCell"         bundle:bundle] forCellReuseIdentifier:DateMarkerCellIdentifier];

    if ( nil == self.tapGesture )
        self.tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];

    if ( nil != self.tapGesture )
    {
        [self.tableView removeGestureRecognizer:self.tapGesture];
        [self.tableView addGestureRecognizer:self.tapGesture];
    }
}
//
- (void) configureTextView
{
    self.imgViewUnderline.image = [[UIImage sdkImageNamed:@"underlineDark"] stretchableImageWithLeftCapWidth:5 topCapHeight:0];
    self.imgViewUnderline.backgroundColor = [UIColor clearColor];

    self.textView.textColor = [UIColor chatToolbarTintColor];
    self.textView.font = [UIFont systemFontOfSize:17 weight:UIFontWeightRegular];
}
//
- (IBAction)onClickButtonSend:(id)sender {
    NSString* messBody = [self.textView text];
    messBody = [[messBody stringByTrimmingLeadingWhitespaceAndNewLine] stringByTrimmingTrailingWhitespaceAndNewLine];

    if ( nil == messBody || 0 == [messBody length] )
    {
//        [MagicAlert showInfoOK:ICOLLString(@"Chat:Empty:Message:Error")];
        return;
    }

    if ([self shouldWarnBeforeSendMessage]) {
//        [MagicAlert showQuestion:ICOLLString(@"ChatScreen:Warning:AngagedBySomeoneElse") completion:^(BOOL positive) {
//            if (positive) {
//                [self sendMessageWithText: messBody];
//            }
//        }];
    } else {
        [self sendMessageWithText: messBody];
    }
}

- (void) sendMessageWithText: (NSString*) messBody
{
    if (messBody.length)
    {
        IMLogDbg("[chatview] sendMessageWithText: '%s' to: '%s'", messBody.UTF8String, _participant->getId().c_str());
        NSError* error = [self.vdeInternal callParticipantWithChat:OBJCStringA(_participant->getId()) chatMessage:messBody];

        ErrorCode errorCode = (ErrorCode) error.code;
        if (errorCode == E_RtcChatCallIsAlreadyCreated)
        {
            IMLogDbg("[chatview] E_RtcChatCallIsAlreadyCreated", 0);
            [self sendMessageWithString:messBody];
        }
    }
}

- ( void )
sendMessageWithString: ( NSString* ) strMessage
{
    NSString* messBody = [NSString stringWithString:strMessage];

    messBody = [[messBody stringByTrimmingLeadingWhitespaceAndNewLine] stringByTrimmingTrailingWhitespaceAndNewLine];

    if ( [messBody length] > MAX_MESSAGE_LENGTH )
    {
//        [MagicAlert showInfoOK:[NSString stringWithFormat:ICOLLString(@"Chat:Max:Message:Length:Error"), [NSString stringWithFormat:@"%d", MAX_MESSAGE_LENGTH]]];
        return;
    }

    [self.textView setText:@""];

    [self updateButtonSendWithText:self.textView.text];

    if (messBody != nil)
    {
        _rtcManager->sendChatMessageToParticipantWithId(_participant->getId(), messBody.UTF8String);
    }
    else
    {
        IMLogErr("Cannot send chat message, messBody is nil", 0);
    }
}

-  ( void )
finishSend
{
    [self.textView setText:nil];
    IMLogVbs("[chatview] reload table from line %d", __LINE__);
    [self.tableView reloadData];
    [self changeTextViewLayoutAnimated:NO];
    [self scrollToBottomAnimated];
}

- ( void )
goToPrevious
{
//    if ([self.callerViewController respondsToSelector:@selector(willShowController)])
//    {
//        [self.callerViewController performSelector:@selector(willShowController)];
//    }
//
//    IMLogDbg("Will pop current view controller. %s",
//             [[self.navigationController.topViewController description] UTF8String]);
//    [self.navigationController popViewControllerAnimated:YES];
}

//- (BOOL)needCallTransferBBi {
//
//    if (self.participant->isInactive())
//        return NO;
//
//    return (_rtcManager->isAgent() && self.participant->activeChatCalls().size() > 0) ? YES : NO;
//}
//
- (BOOL)needInfoBBi {

    if (self.participant->isInactive())
        return NO;

    return (_rtcManager->isAgent() && self.participant->activeChatCalls().size() > 0) ? YES : NO;
}

- (BOOL)needCameraBBi {

    if (self.participant->isInactive())
        return NO;

    return [self.vdeInternal.vdeAgent isVideoCapable];
}

- (BOOL)needTrashBBi {

    if (_rtcManager->isAgent() && self.participant->isInactive())
        return YES;

    return NO;
}

- (UIBarButtonItem*) bbiWithImageName:(NSString*) imgName andSelector:(SEL) selector {

    UIBarButtonItem* bbi = [[UIBarButtonItem alloc] initWithImage:[[UIImage sdkImageNamed:imgName] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]
                                                            style:UIBarButtonItemStylePlain
                                                           target:self
                                                           action:selector];

    return bbi;
}

//- ( UIBarButtonItem*) callTransferBBi {
//
//    UIBarButtonItem* bbi = [self bbiWithImageName:@"callTransferSmall" andSelector:@selector(didClickCallTransferButton:)];
//
//    return bbi;
//}

- (UIBarButtonItem *)backBBi {

    UIBarButtonItem* bbi = nil;
    UIImage* img = [UIImage sdkImageNamed:@"backArrow"];
    UIButton* btn = [UIButton buttonWithType: UIButtonTypeCustom];

    if ( nil != img && nil != btn ) {

        btn.imageEdgeInsets = UIEdgeInsetsMake(0, -15, 0, 0);
        [btn setBounds:CGRectMake(0,0, img.size.width + 30, img.size.height + 30)];
        [btn setImage:img forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(goToPrevious) forControlEvents:UIControlEventTouchUpInside];

        bbi = [[UIBarButtonItem alloc] initWithCustomView: btn];

        if ( nil != bbi )
            bbi.enabled = YES;
    }

    return bbi;
}

//- (UIBarButtonItem *)avatarBBi {
//
//    UIBarButtonItem* bbi = nil;
//    UIImage* avatarImage = nil;
//
//    if (_participant.get() && !_participant->avatar().empty()) {
//        Avatar* avatar = [[SAAvatarManager sharedInstance] avatarWithId: OBJCStringA(_participant->getId())
//                                                                 andUrl: OBJCStringA(_participant->avatar())];
//
//        if (avatar != nil ) {
//            UIImage* tmpImage = [[UIImage alloc] initWithData: avatar.image];
//            CGFloat maxDimension = MAX(tmpImage.size.width, tmpImage.size.height);
//            CGFloat scale = maxDimension / 32.0;
//            avatarImage = [[UIImage alloc] initWithData: avatar.image scale: scale];
//        }
//    }
//
//    AvatarView* avatarView = [[AvatarView alloc] initWithFrame: CGRectMake(0, 0, 28, 28)];
//    NSString* participantName = OBJCStringA(_participant->name());
//    avatarView.initials = [participantName stringByExtractingInitials];
//    avatarView.initialsTextColor = [UIColor whiteColor];
//    avatarView.initialsBackgroundColor = [UIColor grayColor];
//
//    if (avatarImage) {
//        avatarView.backgroundImage = avatarImage;
//        avatarView.backgroundImageHidden = NO;
//    }
//
//    bbi = [[UIBarButtonItem alloc] initWithCustomView: avatarView];
//    bbi.enabled = YES;
//
//    return bbi;
//}

- (UIBarButtonItem *)infoBbi {

    UIBarButtonItem* bbi = [self bbiWithImageName:@"requestInfoSmall" andSelector:@selector(requestUserInfo)];

    return bbi;
}

- (UIBarButtonItem *)spacerBbi {

    UIBarButtonItem* spacer =
    [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                  target:nil
                                                  action:nil];

    return spacer;
}

- ( UIBarButtonItem*) gaugeBbi {

    UIBarButtonItem* bbi = [self bbiWithImageName:@"gauge-excellent" andSelector:nil];
    bbi.enabled = NO;

    UIButton* btn = bbi.customView;

    if ( [btn isKindOfClass:[UIButton class]] )
        [btn setImage:[UIImage sdkImageNamed:@"gauge-excellent"] forState:UIControlStateDisabled];

    return bbi;
}


- ( UIBarButtonItem* )backBbi {
    
    UIBarButtonItem* bbi = [self bbiWithImageName:@"backArrow" andSelector:@selector(didClickBackButton)];
    
    return bbi;
}

- ( UIBarButtonItem* )cameraBbi {

    UIBarButtonItem* bbi = [self bbiWithImageName:@"videoCameraSmall" andSelector:@selector(didClickCameraButton)];

    return bbi;
}

- (UIBarButtonItem*) trashBBi
{
    UIBarButtonItem* bbi = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash
                                                                                   target:self
                                                                                   action:@selector(didClickTrashButton:)];
    return bbi;
}

-(void) requestUserInfo {
    _rtcManager->requestVisitorPersonalInfo(_participant->getId());
    NSLog(@"Request button clicked");
}

- (void)didClickTrashButton:(id)sender
{
    [self.delegate chatViewControllerDidClickTrashButton:self];
    IMLogDbg("Will pop current view controller. %s",
             [[self.navigationController.topViewController description] UTF8String]);
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didClickBackButton {
    
    [self hideKeypad];
    
    [self.delegate chatViewControllerDidClickBackButton:self];
}

- (void)didClickCameraButton {
    
    [self hideKeypad];

    [self.delegate chatViewControllerDidClickCameraButton:self];
}

//- (void)didClickCallTransferButton:(UIBarButtonItem*)bbi {
//
//    [self showPopoverFormBbi:bbi];
//}

- ( void )
scrollToBottomWithoutAnimation
{
    NSInteger numRows = [self.tableView numberOfRowsInSection:0];

    if ( numRows < 1 )
        return;

    IMLogVbs("[chatview] scroll to index: %d", numRows-1);
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:numRows - 1 inSection:0]
                          atScrollPosition:UITableViewScrollPositionTop
                                  animated:NO];
}

- ( void )
scrollToBottomAnimated
{
    NSInteger numRows = [self.tableView numberOfRowsInSection:0];

    if ( numRows < 1 )
        return;

    IMLogVbs("[chatview] scroll anim to index: %d", numRows-1);
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:numRows - 1 inSection:0]
                          atScrollPosition:UITableViewScrollPositionTop
                                  animated:YES];
}

- ( void )
updateButtonSendWithText: ( NSString* ) str
{
    NSString* messBody = [[str stringByTrimmingLeadingWhitespaceAndNewLine] stringByTrimmingTrailingWhitespaceAndNewLine];

    NSInteger messLength = [messBody length];

    BOOL bEnabled = ( messLength > 0 );

    [self.sendButton setEnabled:bEnabled];
}

- ( void )
hideKeypad
{
    [self.textView resignFirstResponder];
}

- ( void )
showKeypad
{
    [self.textView becomeFirstResponder];
}

- ( CGFloat )
rowHeightByCallEvent: (const instac::RefCountPtr<instac::IChatMessage>& ) chatMessage
        withMaxWidth: (CGFloat) maxWidth
{
    CallEventCell* cell = (CallEventCell*) [self.tableView dequeueReusableCellWithIdentifier: CallEventCellIdentifier];

    cell.labelBody.text = [self callEventBodyFromMessage: chatMessage];
    cell.labelDuration.text = [self callEventDurationFromMessage: chatMessage];
    NSDate *timeSent        = [NSDate dateWithTimeIntervalSince1970: chatMessage->getTime()];
    cell.labelDate.text     = [self.todayFormatter stringFromDate: timeSent];


    // vertical offset to be added to the calculated label body height as cell height
    CGFloat labelDurationHeight = cell.labelDuration.intrinsicContentSize.height;
    CGFloat verticalOffset =
    ABS(cell.constraintLabelDateTop.constant) +
    ABS(cell.constraintLabelBodyVerticalSpaceToLabelDuration.constant) +
    labelDurationHeight +
    ABS(cell.constraintLabelDurationBottom.constant);

    // horizontal offset to be extracted to get labelBody width
    CGFloat labelDateWidth = cell.labelDate.intrinsicContentSize.width;
    CGFloat horizontalOffset =
    ABS(cell.constraintLabelBodyLeft.constant) +
    ABS(cell.constraintLabelBodyHorizontalSpaceToLabelDate.constant) +
    labelDateWidth +
    ABS(cell.constraintLabelDateRight.constant);
    CGFloat labelBodyWidth = maxWidth - horizontalOffset;

    // calculate label's height by passing fixed witdth and max float for height
    CGSize boundingSize =
    [cell.labelBody.text boundingRectWithSize:CGSizeMake(labelBodyWidth, CGFLOAT_MAX)
                                      options:NSStringDrawingUsesLineFragmentOrigin
                                   attributes:@{NSFontAttributeName:cell.labelBody.font}
                                      context:nil].size;

    return MAX(30, boundingSize.height + verticalOffset);
}

- ( CGFloat )
rowHeightByMissedCallEvent: (const instac::RefCountPtr<instac::IChatMessage>& ) chatMessage
              withMaxWidth: (CGFloat) maxWidth
{
    CallEventCell* cell = (CallEventCell*) [self.tableView dequeueReusableCellWithIdentifier: CallEventCellIdentifier];

    cell.labelBody.text     = [self missedCallEventBodyFromMessage: chatMessage];
    cell.labelDuration.text = @"";
    NSDate *timeSent        = [NSDate dateWithTimeIntervalSince1970: chatMessage->getTime()];
    cell.labelDate.text     = [self.todayFormatter stringFromDate: timeSent];

    // vertical offset to be added to the calculated label body height as cell height
    CGFloat labelDurationHeight = cell.labelDuration.intrinsicContentSize.height;
    CGFloat verticalOffset =
    ABS(cell.constraintLabelDateTop.constant) +
    ABS(cell.constraintLabelBodyVerticalSpaceToLabelDuration.constant) +
    labelDurationHeight +
    ABS(cell.constraintLabelDurationBottom.constant);

    // horizontal offset to be extracted to get labelBody width
    CGFloat labelDateWidth = cell.labelDate.intrinsicContentSize.width;
    CGFloat horizontalOffset =
    ABS(cell.constraintLabelBodyLeft.constant) +
    ABS(cell.constraintLabelBodyHorizontalSpaceToLabelDate.constant) +
    labelDateWidth +
    ABS(cell.constraintLabelDateRight.constant);
    CGFloat labelBodyWidth = maxWidth - horizontalOffset;

    // calculate label's height by passing fixed witdth and max float for height
    CGSize boundingSize =
    [cell.labelBody.text boundingRectWithSize:CGSizeMake(labelBodyWidth, CGFLOAT_MAX)
                                      options:NSStringDrawingUsesLineFragmentOrigin
                                   attributes:@{NSFontAttributeName:cell.labelBody.font}
                                      context:nil].size;

    return MAX(30, boundingSize.height + verticalOffset);
}

- ( CGFloat )
rowHeightByMissedChatEvent: (const instac::RefCountPtr<instac::IChatMessage>& ) chatMessage
              withMaxWidth: (CGFloat) maxWidth
{
    CallEventCell* cell = (CallEventCell*) [self.tableView dequeueReusableCellWithIdentifier: CallEventCellIdentifier];

    cell.labelBody.text = [self missedChatEventBody];
    cell.labelDuration.text = @"";
    NSDate *timeSent        = [NSDate dateWithTimeIntervalSince1970: chatMessage->getTime()];
    cell.labelDate.text     = [self.todayFormatter stringFromDate: timeSent];


    // vertical offset to be added to the calculated label body height as cell height
    CGFloat labelDurationHeight = cell.labelDuration.intrinsicContentSize.height;
    CGFloat verticalOffset =
    ABS(cell.constraintLabelDateTop.constant) +
    ABS(cell.constraintLabelBodyVerticalSpaceToLabelDuration.constant) +
    labelDurationHeight +
    ABS(cell.constraintLabelDurationBottom.constant);

    // horizontal offset to be extracted to get labelBody width
    CGFloat labelDateWidth = cell.labelDate.intrinsicContentSize.width;
    CGFloat horizontalOffset =
    ABS(cell.constraintLabelBodyLeft.constant) +
    ABS(cell.constraintLabelBodyHorizontalSpaceToLabelDate.constant) +
    labelDateWidth +
    ABS(cell.constraintLabelDateRight.constant);
    CGFloat labelBodyWidth = maxWidth - horizontalOffset;

    // calculate label's height by passing fixed witdth and max float for height
    CGSize boundingSize =
    [cell.labelBody.text boundingRectWithSize:CGSizeMake(labelBodyWidth, CGFLOAT_MAX)
                                      options:NSStringDrawingUsesLineFragmentOrigin
                                   attributes:@{NSFontAttributeName:cell.labelBody.font}
                                      context:nil].size;

    return MAX(30, boundingSize.height + verticalOffset);
}

- ( CGFloat )
rowHeightByDateMarker
{
    return 20;
}

- ( CGFloat )
rowHeightByIncomingMessageAvatar  : ( NSString*   ) messBody
withTimeDescription: (NSString* ) timeDescription
withMaxWidth: (CGFloat) maxWidth
{
    /*
     constraintBubbleTop;
     constraintBubbleBottom;
     constraintTextViewBottom;
     constraintLabelTimeTop;
     constraintTextViewVerticalSpaceToLabelTime;
     constraintBubbleWidth;
     constraintTextViewLeft;
     constraintTextViewRight;
     */

    IncomingMessageCellAvatar* cell = (IncomingMessageCellAvatar*) [self.tableView dequeueReusableCellWithIdentifier: IncomingMessageCellAvatarIdentifier];
    cell.labelTime.text = timeDescription;
    cell.textViewMessage.text = messBody;

    CGFloat labelHeight = cell.labelSender.intrinsicContentSize.height;
    CGFloat bubbleWidth = maxWidth * cell.constraintBubbleWidth.multiplier;
    CGFloat textViewWidth = bubbleWidth - ABS(cell.constraintTextViewLeft.constant) - ABS(cell.constraintTextViewRight.constant);
    CGFloat verticalOffset =
    ABS(cell.constraintBubbleTop.constant) + ABS(cell.constraintLabelSenderTop.constant) +
    labelHeight +
    ABS(cell.constraintTextViewVerticalSpaceToLabelSender.constant) +
    ABS(cell.constraintBubbleBottom.constant) + ABS(cell.constraintTextViewBottom.constant);
    CGSize boundingSize = [cell.textViewMessage sizeThatFits:CGSizeMake(textViewWidth, CGFLOAT_MAX)];
    return MAX(64, boundingSize.height + verticalOffset);
}

- ( CGFloat )
rowHeightByOutgoingMessageAvatar  : ( NSString*   ) messBody
withTimeDescription: (NSString* ) timeDescription
withMaxWidth: (CGFloat) maxWidth
{
    /*
     constraintBubbleTop;
     constraintBubbleBottom;
     constraintTextViewBottom;
     constraintLabelTimeTop;
     constraintTextViewVerticalSpaceToLabelTime;
     constraintBubbleWidth;
     constraintTextViewLeft;
     constraintTextViewRight;
     */

    OutgoingMessageCellAvatar* cell = (OutgoingMessageCellAvatar*) [self.tableView dequeueReusableCellWithIdentifier: OutgoingMessageCellAvatarIdentifier];
    cell.labelTime.text = timeDescription;
    cell.textViewMessage.text = messBody;

    CGFloat labelHeight = cell.labelSender.intrinsicContentSize.height;
    CGFloat bubbleWidth = maxWidth * cell.constraintBubbleWidth.multiplier;
    CGFloat textViewWidth = bubbleWidth - ABS(cell.constraintTextViewLeft.constant) - ABS(cell.constraintTextViewRight.constant);
    CGFloat verticalOffset =
    ABS(cell.constraintBubbleTop.constant) + ABS(cell.constraintLabelSenderTop.constant) +
    labelHeight +
    ABS(cell.constraintTextViewVerticalSpaceToLabelSender.constant) +
    ABS(cell.constraintBubbleBottom.constant) + ABS(cell.constraintTextViewBottom.constant);
    CGSize boundingSize = [cell.textViewMessage sizeThatFits:CGSizeMake(textViewWidth, CGFLOAT_MAX)];
    return MAX(64, boundingSize.height + verticalOffset);
}

- (void) sendFirstChatMessageIfNeccessary
{
    if (_rtcManager->isAgent())
    {
        // agent only
        if ((self.participant->activeChatCalls().size() == 0) &&
            (_rtcManager->getParticipantMessagesCount(_participant->getId()) == 0))
        {
            // Send chat message
            if ([self.delegate respondsToSelector:@selector(chatViewControllerDidRequestDefaultChatMessage:)])
            {
                NSString* defaultChatMessage = [self.delegate chatViewControllerDidRequestDefaultChatMessage:self];
                [self.textView setText:defaultChatMessage];
                [self.textView selectAll:nil];
                [self.sendButton setEnabled:YES];
                [self changeTextViewLayoutAnimated: NO];
                IMLogVbs("set defaultChatMessage", 0);
            }
        }
    }
}

- (void) updateBanner
{
    NSString* bannerText;
    if (NULL == _participant.get())
        return;

    switch (_participant->getState()) {
        case instac::IParticipant::StateCallRingingBySomeoneElse:
        case instac::IParticipant::StateChatRingingBySomeoneElse:
        {
            NSString* answeredByUser = OBJCStringA(_participant->peerName());
            NSString* formatStr = ICOLLString(@"ChatScreen:StateContactedBySomeoneElse");
            bannerText = [NSString stringWithFormat: formatStr, answeredByUser];
        }
            break;
        case instac::IParticipant::StateCallInProgressBySomeoneElse:
        case instac::IParticipant::StateChatInProgressBySomeoneElse:
        {
            NSString* answeredByUser = OBJCStringA(_participant->peerName());
            NSString* formatStr = ICOLLString(@"ChatScreen:StateHelpedBySomeoneElse");
            bannerText = [NSString stringWithFormat: formatStr, answeredByUser];
        }
            break;
        case instac::IParticipant::StateCallRinging:
        case instac::IParticipant::StateCallInProgress:
        case instac::IParticipant::StateCallInProgressByOtherMe:
        case instac::IParticipant::StateCallTransferWaiting:
        case instac::IParticipant::StateCallOnHold:
        case instac::IParticipant::StateChatRinging:
        case instac::IParticipant::StateChatInProgress:
        case instac::IParticipant::StateChatInProgressByOtherMe:
        case instac::IParticipant::StateActivated:
        case instac::IParticipant::StateIdle:
            break;
        default:
            break;
    }

    [self showTableHeaderWithText:bannerText withBackgroundColor:[UIColor statusBlueColor]];
}

- (BOOL) shouldWarnBeforeSendMessage
{
    if (NULL == _participant.get())
        return NO;

    switch (_participant->getState()) {
        case instac::IParticipant::StateCallRingingBySomeoneElse:
        case instac::IParticipant::StateChatRingingBySomeoneElse:
        case instac::IParticipant::StateCallInProgressBySomeoneElse:
        case instac::IParticipant::StateChatInProgressBySomeoneElse:
            return YES;
        default:
            break;
    }

    return NO;
}

//#pragma mark - ChatCallTransferStatusView Delegates
//
//-(void)transferFooterView:(ChatCallTransferStatusView *)footerView didPressCancelButton:(UIButton *)button {
//
//    _rtcManager->cancelTransferCall(self.participant);
//}
//
//#pragma mark - CallTransferViewController Delegates
//
//-(void)didCloseCallTransferViewController:(CallTransferViewController *)controller {
//
//    [self dismissViewControllerAnimated:YES completion:^{
//        self.popOverPresController.delegate = nil;
//        self.popOverPresController = nil;
//    }];
//}
//
//-(void)controller:(CallTransferViewController *)controller didSelectRecipient:(LSEndPoint *)recipient {
//
//    [self dismissViewControllerAnimated:YES completion:^{
//
//        self.popOverPresController.delegate = nil;
//        self.popOverPresController = nil;
//
//        std::vector<instac::RefCountPtr<instac::ICall>> activeChatCalls = self.participant->activeChatCalls();
//
//        if (activeChatCalls.size() > 0) {
//
//            activeChatCalls[0]->callId();
//            if(controller.withVideo)
//                _rtcManager->transferCall(activeChatCalls[0]->callId(), [recipient.identifier UTF8String], !recipient.isIndividal);
//            else
//                _rtcManager->transferChat(activeChatCalls[0]->callId(), [recipient.identifier UTF8String], !recipient.isIndividal);
//        }
//    }];
//}
//
#pragma mark - UIPopoverControllerDelegate methods

- (UIModalPresentationStyle) adaptivePresentationStyleForPresentationController: (UIPresentationController * ) controller {

    return UIModalPresentationNone;
}

- (void)popoverPresentationControllerDidDismissPopover:(UIPopoverPresentationController *)popoverPresentationController {

    self.popOverPresController.delegate = nil;
    self.popOverPresController = nil;
}

#pragma mark - UITableView delegates

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {

    return 0.0f;
//    return ( self.transferStatus < CallTransferStatusCanceled || self.transferStatus > CallTransferStatusInProgress ) ? 0.0f : DEFAULT_CONTROL_HEIGHT;
}

//-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
//
//    if ( self.transferStatus < CallTransferStatusCanceled || self.transferStatus > CallTransferStatusInProgress ) {
//
//        return nil;
//    }
//
//    NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"ChatCallTransferStatusView" owner:self options:nil];
//
//    if ( [objects count] > 0 ) {
//
//        for ( UIView* v in objects ) {
//
//            if ( [v isKindOfClass:[ChatCallTransferStatusView class]] ) {
//
//                ChatCallTransferStatusView* ctsv = (ChatCallTransferStatusView*)v;
//
//                ctsv.delegate = self;
//                [ctsv updateCallTransferStatusViewWithState:self.transferStatus forRecipient:self.recipientName];
//
//                return ctsv;
//            }
//        }
//    }
//
//    return nil;
//}

- ( CGFloat )
tableView               : ( UITableView * ) tableView
heightForRowAtIndexPath : ( NSIndexPath * ) indexPath
{
    CGFloat rowHeight = 0.0;
    instac::RefCountPtr<instac::IChatMessage> chatMessage;
    _rtcManager->getParticipantMessageAtIndex(indexPath.row, _participant->getId(), chatMessage);
    IMLogVbs("[chatview] height for row: %d", indexPath.row);

    if (chatMessage.get() == NULL) {
        IMLogWrn("[chatview] zero height because of no chat message", 0);
        return 0.0;
    }

    switch (chatMessage->getType()) {
        case instac::IChatMessage::ChatMessageTypeIncoming:
        {
            NSDate *timeSent            = [NSDate dateWithTimeIntervalSince1970:chatMessage->getTime()];
            NSString* timeDescription   = [self.todayFormatter stringFromDate: timeSent];

            rowHeight = [self rowHeightByIncomingMessageAvatar: OBJCStringA(chatMessage->getText())
                                           withTimeDescription: timeDescription
                                                  withMaxWidth: tableView.frame.size.width];
        }
            break;
        case instac::IChatMessage::ChatMessageTypeOutgoing:
        {
            NSDate *timeSent            = [NSDate dateWithTimeIntervalSince1970:chatMessage->getTime()];
            NSString* timeDescription   = [self.todayFormatter stringFromDate: timeSent];
            rowHeight = [self rowHeightByOutgoingMessageAvatar: OBJCStringA(chatMessage->getText())
                                           withTimeDescription: timeDescription
                                                  withMaxWidth: tableView.frame.size.width];
        }
            break;
        case instac::IChatMessage::ChatMessageTypeMissedCall:
        case instac::IChatMessage::ChatMessageTypeUnAnsweredCall:
            rowHeight = [self rowHeightByMissedCallEvent: chatMessage
                                            withMaxWidth: tableView.frame.size.width];
            break;
        case instac::IChatMessage::ChatMessageTypeMissedChat:
        case instac::IChatMessage::ChatMessageTypeUnAnsweredChat:
            rowHeight = [self rowHeightByMissedChatEvent: chatMessage
                                            withMaxWidth: tableView.frame.size.width];
            break;
        case instac::IChatMessage::ChatMessageTypeIncomingCall:
        case instac::IChatMessage::ChatMessageTypeOutgoingCall:
            rowHeight = [self rowHeightByCallEvent: chatMessage
                                      withMaxWidth: tableView.frame.size.width];
            break;
        case instac::IChatMessage::ChatMessageTypeDateMarker:
            rowHeight = [self rowHeightByDateMarker];
            break;
        default:
            break;
    }

    return rowHeight;
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}

- ( NSInteger )
tableView               : ( UITableView *   ) tableView
numberOfRowsInSection   : ( NSInteger       ) section
{
    if (_participant.get() == NULL) {
        IMLogWrn("[chatview] zero rows because no participant", 0);
        return 0;
    }

    unsigned long count = _rtcManager->getParticipantMessagesCount(_participant->getId());
    IMLogVbs("[chatview] number of cells: %ld", count);
    return count;
}

- (void) configureIncomingMessageCellAvatar: (IncomingMessageCellAvatar*) cell
                                withMessage: (const instac::RefCountPtr<instac::IChatMessage>& ) chatMessage
                                 showAvatar: (BOOL) showAvatar
{
    cell.selectionStyle         = UITableViewCellSelectionStyleNone;
    cell.textViewMessage.text   = OBJCStringA(chatMessage->getText());
    NSDate *timeSent            = [NSDate dateWithTimeIntervalSince1970:chatMessage->getTime()];
    cell.labelTime.text         = [self.todayFormatter stringFromDate: timeSent];

    NSString* senderName;
    if (!chatMessage->getSender().empty())
        senderName       = OBJCStringA(chatMessage->getSender());
    else
        senderName       = OBJCStringA(_participant->name());

    cell.labelSender.text = senderName;

    // No avatar
    UIImage* avatarImage = nil;
    [cell setAvatarImage: avatarImage];

    if (showAvatar) {
        cell.constraintAvatarViewWidth.constant = 48.0;
        cell.constraintAvatarViewLeft.constant = 5.0;

        [cell setInitials: [senderName stringByExtractingInitials]];
    } else {
        cell.constraintAvatarViewWidth.constant = 0.0;
        cell.constraintAvatarViewLeft.constant = 0.0;
        [cell setInitials: @""];
    }
}

- (void) configureOutgoingMessageCellAvatar: (OutgoingMessageCellAvatar*) cell
                                withMessage: (const instac::RefCountPtr<instac::IChatMessage>& ) chatMessage
{
    cell.selectionStyle         = UITableViewCellSelectionStyleNone;
    cell.textViewMessage.text   = OBJCStringA(chatMessage->getText());
    NSDate *timeSent            = [NSDate dateWithTimeIntervalSince1970:chatMessage->getTime()];
    cell.labelTime.text         = [self.todayFormatter stringFromDate: timeSent];

    cell.labelSender.text       = chatMessage->isRelatedMe() ? ICOLLString(@"History:Me") : OBJCStringA(chatMessage->getSender());
    UIImage* avatarImage = nil;

    if (chatMessage->isRelatedMe() == false) {
        cell.constraintAvatarWidth.constant = 48.0;
        cell.constraintBubbleHorizontalSpaceToAvatar.constant = 5.0;

        NSString* agentName = OBJCStringA(chatMessage->getSender());
        [cell setInitials: [agentName stringByExtractingInitials]];

    } else {
        cell.constraintAvatarWidth.constant = 0.0;
        cell.constraintBubbleHorizontalSpaceToAvatar.constant = 0.0;

        [cell setInitials: @""];
    }

    // No avatar
    [cell setAvatarImage: avatarImage];
}

- (NSString*) callEventBodyFromMessage: (const instac::RefCountPtr<instac::IChatMessage>& ) chatMessage
{
    NSString* eventDescription;

    switch (chatMessage->getType()) {
        case instac::IChatMessage::ChatMessageTypeIncomingCall:
        {
            NSString* senderName = chatMessage->getSender().empty() ? OBJCStringA(_participant->name()) : OBJCStringA(chatMessage->getSender());
            if (chatMessage->isRelatedMe()) {
                // Someone called you
                eventDescription = [NSString stringWithFormat:ICOLLString(@"History:Event:IncomingCall:Me"), senderName];
            } else {
                // Someone called somebody
                NSString* receiverName = OBJCStringA(chatMessage->getReceiver());
                eventDescription = [NSString stringWithFormat:ICOLLString(@"History:Event:IncomingCall:Other"), senderName, receiverName];
            }
        }
            break;
        case instac::IChatMessage::ChatMessageTypeOutgoingCall:
        {
            NSString* receiverName = chatMessage->getSender().empty() ? OBJCStringA(_participant->name()) : OBJCStringA(chatMessage->getReceiver());
            if (chatMessage->isRelatedMe()) {
                // You called someone
                eventDescription = [NSString stringWithFormat:ICOLLString(@"History:Event:OutgoingCall:Me"), receiverName];
            } else {
                // Someone called somebody
                NSString* senderName = OBJCStringA(chatMessage->getSender());
                eventDescription = [NSString stringWithFormat:ICOLLString(@"History:Event:OutgoingCall:Other"), senderName, receiverName];
            }
        }
            break;
        default:
            eventDescription = ICOLLString(@"History:Event:OutgoingCall");
            break;
    }

    return eventDescription;
}

- (NSString*) missedCallEventBodyFromMessage: (const instac::RefCountPtr<instac::IChatMessage>& ) chatMessage
{
    NSString* eventDescription;

    switch (chatMessage->getType()) {
        case instac::IChatMessage::ChatMessageTypeMissedCall:
        {
            NSString* senderName = chatMessage->getSender().empty() ? OBJCStringA(_participant->name()) : OBJCStringA(chatMessage->getSender());
            eventDescription = [NSString stringWithFormat:ICOLLString(@"History:Event:MissedCall:From"), senderName];
        }
            break;
        case instac::IChatMessage::ChatMessageTypeUnAnsweredCall:
        default:
            eventDescription = ICOLLString(@"History:Event:UnAnsweredCall");
            break;
    }

    return eventDescription;
}

- (NSString*) missedChatEventBody
{
    return ICOLLString(@"History:Event:UnAnsweredChat");
}

- (NSString*) callEventDurationFromMessage: (const instac::RefCountPtr<instac::IChatMessage>& ) chatMessage
{
    NSString* duration;
    int durationInSecs = (int) (chatMessage->duration() / 1000);
    int minutes = durationInSecs / 60;
    int seconds = durationInSecs % 60;
    int hours = minutes / 60;
    minutes = minutes % 60;

    if (hours > 0) {
        if (minutes > 0) {
            if (seconds > 0) {
                duration = [NSString stringWithFormat:ICOLLString(@"Duration:Hours:Minutes:Seconds"), hours, minutes, seconds];
            } else {
                duration = [NSString stringWithFormat:ICOLLString(@"Duration:Hours:Minutes"), hours, minutes];
            }
        } else {
            if (seconds > 0) {
                duration = [NSString stringWithFormat:ICOLLString(@"Duration:Hours:Seconds"), hours, seconds];
            } else {
                duration = [NSString stringWithFormat:ICOLLString(@"Duration:Hours"), hours];
            }
        }
    } else if (minutes > 0) {
        if (seconds > 0) {
            duration = [NSString stringWithFormat:ICOLLString(@"Duration:Minutes:Seconds"), minutes, seconds];
        } else {
            duration = [NSString stringWithFormat:ICOLLString(@"Duration:Minutes"), minutes];
        }
    } else {
        duration = [NSString stringWithFormat:ICOLLString(@"Duration:Seconds"), seconds];
    }


    return duration;
}

- (void) configureMissedCallEventCell: (CallEventCell*) cell
                          withMessage: (const instac::RefCountPtr<instac::IChatMessage>& ) chatMessage
{
    cell.selectionStyle     = UITableViewCellSelectionStyleNone;

    cell.labelBody.text     = [self missedCallEventBodyFromMessage: chatMessage];
    NSDate *timeSent        = [NSDate dateWithTimeIntervalSince1970:chatMessage->getTime()];
    cell.labelDate.text     = [self.todayFormatter stringFromDate: timeSent];
    cell.labelDuration.text = @"";
}

- (void) configureMissedChatEventCell: (CallEventCell*) cell
                          withMessage: (const instac::RefCountPtr<instac::IChatMessage>& ) chatMessage
{
    cell.selectionStyle     = UITableViewCellSelectionStyleNone;

    cell.labelBody.text     = [self missedChatEventBody];
    NSDate *timeSent        = [NSDate dateWithTimeIntervalSince1970:chatMessage->getTime()];
    cell.labelDate.text     = [self.todayFormatter stringFromDate: timeSent];
    cell.labelDuration.text = @"";
}

- (void) configureCallEventCell: (CallEventCell*) cell
                    withMessage: (const instac::RefCountPtr<instac::IChatMessage>& ) chatMessage
{
    cell.selectionStyle     = UITableViewCellSelectionStyleNone;

    cell.labelBody.text     = [self callEventBodyFromMessage: chatMessage];
    NSDate *timeSent        = [NSDate dateWithTimeIntervalSince1970:chatMessage->getTime()];
    cell.labelDate.text     = [self.todayFormatter stringFromDate: timeSent];
    cell.labelDuration.text = [self callEventDurationFromMessage: chatMessage];
}

- (void) configureDateMarkerCell: (DateMarkerCell*)cell
                     withMessage: (const instac::RefCountPtr<instac::IChatMessage>& ) chatMessage
{
    cell.selectionStyle     = UITableViewCellSelectionStyleNone;
    NSDate *timeSent        = [NSDate dateWithTimeIntervalSince1970:chatMessage->getTime()];

//    if ([timeSent dateIsToday]) {
//        cell.labelDay.text = ICOLLString(@"History:Date:Today");
//    } else if ([timeSent dateIsYesterday]) {
//        cell.labelDay.text = ICOLLString(@"History:Date:Yesterday");
//    } else if ([timeSent dateIsThisYear]) {
//        cell.labelDay.text = [self.dayOnlyFormatter stringFromDate: timeSent];
//    } else {
        cell.labelDay.text = [self.dateOnlyFormatter stringFromDate: timeSent];
//    }
}

- ( UITableViewCell * )
tableView               : ( UITableView * ) tableView
cellForRowAtIndexPath   : ( NSIndexPath * ) indexPath
{
    UITableViewCell* cell;
    instac::RefCountPtr<instac::IChatMessage> chatMessage;
    _rtcManager->getParticipantMessageAtIndex(indexPath.row, _participant->getId(), chatMessage);

    IMLogVbs("[chatview] cell for row: %ld", indexPath.row);

    if (chatMessage.get() == NULL) {
        IMLogWrn("[chatview] empty cell because of no chat message", 0);
        return [tableView dequeueReusableCellWithIdentifier:OutgoingMessageCellAvatarIdentifier forIndexPath:indexPath];
    }

    switch (chatMessage->getType()) {
        case instac::IChatMessage::ChatMessageType::ChatMessageTypeIncoming:
            cell = [tableView dequeueReusableCellWithIdentifier:IncomingMessageCellAvatarIdentifier forIndexPath:indexPath];
            if (_rtcManager->isAgent()) {
                [self configureIncomingMessageCellAvatar: (IncomingMessageCellAvatar*)cell withMessage: chatMessage showAvatar: NO];
            } else {
                [self configureIncomingMessageCellAvatar: (IncomingMessageCellAvatar*)cell withMessage: chatMessage showAvatar: YES];
            }
            break;
        case instac::IChatMessage::ChatMessageTypeMissedCall:
        case instac::IChatMessage::ChatMessageTypeUnAnsweredCall:
            cell = [tableView dequeueReusableCellWithIdentifier:CallEventCellIdentifier forIndexPath:indexPath];
            [self configureMissedCallEventCell: (CallEventCell*)cell withMessage: chatMessage];
            break;
        case instac::IChatMessage::ChatMessageTypeMissedChat:
        case instac::IChatMessage::ChatMessageTypeUnAnsweredChat:
            cell = [tableView dequeueReusableCellWithIdentifier:CallEventCellIdentifier forIndexPath:indexPath];
            [self configureMissedChatEventCell: (CallEventCell*)cell withMessage: chatMessage];
            break;
        case instac::IChatMessage::ChatMessageTypeIncomingCall:
        case instac::IChatMessage::ChatMessageTypeOutgoingCall:
            cell = [tableView dequeueReusableCellWithIdentifier:CallEventCellIdentifier forIndexPath:indexPath];
            [self configureCallEventCell: (CallEventCell*)cell withMessage: chatMessage];
            break;
        case instac::IChatMessage::ChatMessageTypeDateMarker:
            cell = [tableView dequeueReusableCellWithIdentifier:DateMarkerCellIdentifier forIndexPath:indexPath];
            [self configureDateMarkerCell: (DateMarkerCell*)cell withMessage: chatMessage];
            break;
        case instac::IChatMessage::ChatMessageType::ChatMessageTypeOutgoing:
        default:
        {
            cell = [tableView dequeueReusableCellWithIdentifier:OutgoingMessageCellAvatarIdentifier forIndexPath:indexPath];
            [self configureOutgoingMessageCellAvatar: (OutgoingMessageCellAvatar*)cell
                                         withMessage: chatMessage];
        }
            break;
    }

    return cell;
}

#pragma mark - Keyboard notifications

- (void)enableDisableTextViewScroll {

    CGFloat tableHeight         = CGRectGetHeight(self.tableView.bounds);
    CGFloat navBarHeight        = CGRectGetHeight(self.navigationController.navigationBar.bounds);
    CGFloat statusBarHeight     = CGRectGetHeight([[UIApplication sharedApplication] statusBarFrame]);

    BOOL enabled = (tableHeight <= (navBarHeight + statusBarHeight));
    self.textView.scrollEnabled = enabled;

    NSLog(@"Scroll is:%@ (%.f)", enabled ? @"Enabled" : @"Disabled", self.textView.contentSize.height);
}

-(CGFloat) maximumInputBarHeight {

    CGFloat viewHeight          = CGRectGetHeight(self.view.frame);
    CGFloat navBarHeight        = CGRectGetHeight(self.navigationController.navigationBar.bounds);
    CGFloat statusBarHeight     = CGRectGetHeight([[UIApplication sharedApplication] statusBarFrame]);
    CGFloat toolbarHeight       = CGRectGetHeight(self.toolbar.bounds);

    return viewHeight - statusBarHeight - toolbarHeight - navBarHeight - self.toolbarBottom.constant/*keypad height*/;
}

- (void) redrawControllerAnimated: (BOOL) animated {

    [UIView animateWithDuration:animated ? 0.5 : 0.0
                          delay:0.0
                        options: UIViewAnimationOptionCurveEaseOut
                     animations:^
     {
         [self.view layoutIfNeeded];
     }
                     completion:^(BOOL finished)
     {
         [self scrollToBottomAnimated];
         [self enableDisableTextViewScroll];
     }];
}

-(void)changeTextViewLayoutAnimated:(BOOL) animated {

    CGFloat minimumTextInputHeight = self.textView.font.pointSize + 10;
    CGFloat maximumTextInputHeight = [self maximumInputBarHeight];
    CGFloat calculatedTextInputHeight = minimumTextInputHeight;

    CGFloat textViewWidth = CGRectGetWidth(self.textView.bounds);
    CGSize textViewBoundingSize = [self.textView sizeThatFits:CGSizeMake(textViewWidth, MAXFLOAT)];

    calculatedTextInputHeight = textViewBoundingSize.height +
                                ABS(self.constraintMediaViewHeight.constant) +
                                ABS(self.constraintTextViewVerticalSpace.constant) +
                                ABS(self.constraintTextViewBottomSpace.constant);

    if ( calculatedTextInputHeight < minimumTextInputHeight )
        calculatedTextInputHeight = minimumTextInputHeight;

    if ( calculatedTextInputHeight > maximumTextInputHeight )
        calculatedTextInputHeight = maximumTextInputHeight;

    if (self.textInputHeight.constant != calculatedTextInputHeight) {
        self.textInputHeight.constant = calculatedTextInputHeight;
        [self redrawControllerAnimated:animated];
    }
}

- (void)handleWillShowKeyboard:(NSNotification *)notification
{
    NSDictionary *keyboardInfo = [notification userInfo];

    NSValue *keyboardFrameBegin = [keyboardInfo valueForKey:UIKeyboardFrameEndUserInfoKey];

    CGRect keyboardEndingFrame = [keyboardFrameBegin CGRectValue];

    self.toolbarBottom.constant = keyboardEndingFrame.size.height;

    [self changeTextViewLayoutAnimated:NO];
}

- (void)handleWillHideKeyboard:(NSNotification *)notification
{
    self.toolbarBottom.constant     = 0.0;

    [self changeTextViewLayoutAnimated:NO];
}

//- (void) handleDownloadAvatarNotification: (NSNotification *) aNotification
//{
//    IMLogDbg("handleDownloadAvatarNotification", 0);
//    Avatar* avatar = aNotification.userInfo[kDidDownloadAvatarKey];
//    if (nil != avatar && nil != avatar.image) {
//        [self addLeftBarButtons];
//    }
//}
//
#pragma mark UITextViewMethods
- ( void )
textViewDidChange: ( UITextView * ) textView
{
    [self changeTextViewLayoutAnimated:NO];
}

- ( BOOL )
textView                : ( UITextView *    ) textView
shouldChangeTextInRange : ( NSRange         ) range
replacementText         : ( NSString *      ) text
{
    // Fixed crash on iPad when pressed 'Undo' in sertain cases which overflow buffer in textView.text
    if ( range.location + range.length > textView.text.length )
        return NO;

    NSString * tvStr = [textView.text stringByReplacingCharactersInRange:range withString:text];

    [self updateButtonSendWithText: tvStr];

    return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    [textView becomeFirstResponder];

    [self scrollToBottomAnimated];
}

#pragma mark Gestures
- ( void )
tap: ( UITapGestureRecognizer* ) gesture
{
    if ( ![self.textView isFirstResponder] )
    {
        [self showKeypad];
    }
    else
    {
        [self hideKeypad];

        NSArray* visCells = [self.tableView visibleCells];

        if ( [visCells count] > 0 )
        {
            NSIndexPath* ip = [self.tableView indexPathForCell:[visCells lastObject]];
            IMLogVbs("[chatview] scroll anim to index: %d", ip.row);
            [self.tableView scrollToRowAtIndexPath:ip
                                  atScrollPosition:UITableViewScrollPositionBottom
                                          animated:YES];
        }
    }
}
//
//- (void) onRtcEvent: (NSValue*) obj
//{
//    instac::RTCEvent * event = (instac::RTCEvent*)[obj pointerValue];
//
//    switch (event->getType())
//    {
//        case instac::RTCEvent::ActionCompletion:
//        {
//            IMLogVbs("Did ActionCompletion %d", event->getAction());
//            switch (event->getAction())
//            {
//                case instac::IRTCManager::ActionParticipantAvailabilityChanged:
//                {
//                    const instac::RefCountPtr<instac::IParticipant> participant = event->getParticipant();
//
//                    if (participant->getId().compare(_participant->getId()) == 0)
//                    {
//                        [self.navigationItem setTitle:OBJCStringA(_participant->name())];
//                        [self setupInputViewsState];
//                        [self updateBarButtonItems];
//                    }
//                }
//                    break;
//                case instac::IRTCManager::ActionDidDeleteVisitor:
//                {
//                    const instac::RefCountPtr<instac::IParticipant> participant = event->getParticipant();
//
//                    if (participant->getId().compare(_participant->getId()) == 0)
//                    {
//                        [self goToPrevious];
//                    }
//                }
//                    break;
//                case instac::IRTCManager::ActionChatAccepted:
//                {
//                    const instac::CallArgs& callArgs = event->getCallArgs();
//                    const instac::String& callId = callArgs.identifier();
//
//                    instac::RefCountPtr<instac::ICall> call = _rtcManager->getCall(callId);
//
//                    if ([self isCallForThisParticipant:call])
//                    {
//                        _rtcManager->resetParticipantUnreadChatMessages(self.participant->getId());
//
//                        [self setInputViewsState:kChatControllerStateCallAccepted];
//
//                        [self updateBarButtonItems];
//                        [self updateTableHeaderView];
//                        [self showTableFooterView:NO];
//
//                        _rtcManager->resetMessagesForParticipant(self.participant);
//                        IMLogVbs("[chatview] reload table from line %d", __LINE__);
//                        [self.tableView reloadData];
//                        IMLogDbg("[CH] loadMoreMessages from %d", __LINE__);
//                        if(1 == [self loadMoreMessages])
//                            self.needToScrollToBottomAfterLoad = YES;
//                    }
//                }
//                    break;
//                case instac::IRTCManager::ActionChatEnded:
//                {
//                    const instac::CallArgs& callArgs = event->getCallArgs();
//                    const instac::String& callId = callArgs.identifier();
//
//                    instac::RefCountPtr<instac::ICall> call = _rtcManager->getCall(callId);;
//
//                    if ([self isCallForThisParticipant:call])
//                    {
//                        [self updateTableHeaderView];
//                        [self showTableFooterView: NO];
//                        [self setInputViewsState:kChatControllerStateCallEnded];
//                        [self updateBarButtonItems];
//                    }
//                    else
//                    {
//                        IMLogDbg("Could not handle event 'ActionChatEnded', could not find call with id %s", callId.c_str());
//                    }
//                }
//                    break;
//                case instac::IRTCManager::ActionOutgoingChatRequest:
//                {
//                    const instac::CallArgs& callArgs = event->getCallArgs();
//                    const instac::String& callId = callArgs.identifier();
//
//                    instac::RefCountPtr<instac::ICall> call = _rtcManager->getCall(callId);
//
//                    if ([self isCallForThisParticipant:call])
//                    {
//                        [self updateTableHeaderView];
//                        [self showTableFooterView: YES];
//                    }
//                    else
//                    {
//                        IMLogDbg("Could not handle event 'ActionChatEnded', could not find call with id %s", callId.c_str());
//                    }
//                }
//                    break;
//                case instac::IRTCManager::ActionDidEnqueueChatMessage:
//                {
//                    IMLogDbg("[chatview] Did receive ActionDidEnqueueChatMessage. Will finish send", 0);
//                    [self finishSend];
//                }
//                    break;
////                case instac::IRTCManager::ActionDidSendChatMessage:
////                {
////                    IMLogDbg("[chatview] Did receive ActionDidSendChatMessage. Will reload data", 0);
////                    IMLogVbs("reload table from line %d", __LINE__);
////                    [self.tableView reloadData];
////                }
////                    break;
//                case instac::IRTCManager::ActionDidReceiveChatMessage:
//                {
//                    const instac::RefCountPtr<instac::IParticipant> participant = event->getParticipant();
//
//                    if (participant->getId().compare(_participant->getId()) == 0)
//                    {
//                        IMLogVbs("[chatview] reload table from line %d", __LINE__);
//                        [self.tableView reloadData];
//
//                        unsigned long msgsCount = [self.tableView numberOfRowsInSection:0];
//                        if (msgsCount > 0)
//                        {
//                            unsigned long lastMessageIndex = msgsCount - 1;
//
//                            IMLogVbs("[chatview] scroll anim to index: %d", lastMessageIndex);
//                            [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:lastMessageIndex
//                                                                                      inSection:0]
//                                                  atScrollPosition:UITableViewScrollPositionBottom
//                                                          animated:YES];
//                        }
//
//                        [self.callManager clearUnreadMessagesForParticipantId:OBJCStringA(_participant->getId())];
//                    }
//                }
//                    break;
//                case instac::IRTCManager::ActionDidRetrieveMessagesForVisitor:
//                {
//                    const instac::RefCountPtr<instac::IParticipant> participant = event->getParticipant();
//
//                    if (participant->getId().compare(_participant->getId()) == 0)
//                    {
//                        if (event->customValue1() > 0) {
//                            [self stopAnimationRefreshing];
//                            [self updateRefreshControlTitle];
//                            [self updateTableHeaderView];
//                            IMLogVbs("[chatview] reload table from line %d", __LINE__);
//                            [self.tableView reloadData];
//                            if (self.needToScrollToBottomAfterLoad) {
//                                [self scrollToBottomWithoutAnimation];
//                                self.needToScrollToBottomAfterLoad = NO;
//                            }
//                        } else if (self.participant->hasMoreMessages()) {
//                            IMLogDbg("[CH] loadMoreMessages from %d", __LINE__);
//                            [self loadMoreMessages];
//                            // will load more, do not clear flag to scrool to bottom when next portion is received
//                        } else {
//                            IMLogDbg("[CH] no more messages", 0);
//                            [self stopAnimationRefreshing];
//                            [self updateRefreshControlTitle];
//
//                            // clear tthe flag to scroll to bottom, wont load more
//                            if (self.needToScrollToBottomAfterLoad) {
//                                self.needToScrollToBottomAfterLoad = NO;
//                            }
//                        }
//                    }
//
//                }
//                    break;
//                case instac::IRTCManager::ActionDidUpdateVisitor:
//                {
//                    instac::RefCountPtr<instac::IParticipant> visitor = event->getVisitor();
//
//                    if (visitor->getId().compare(_participant->getId()) == 0)
//                    {
//                        [self updateBanner];
//                    }
//                }
//                    break;
//                case instac::IRTCManager::ActionCallTransferDidBegin:
//                {
//                    const instac::CallArgs& args = event->getCallArgs();
//                    [self updateChatCallTransferFooterViewWithState:CallTransferStatusInProgress
//                                                      withRecipient: OBJCStringA(args.name())];
//                }
//                    break;
//                case instac::IRTCManager::ActionCallTransferDidFinish:
//                {
//                    const instac::RefCountPtr<instac::IParticipant>& participant = event->getVisitor();
//                    if (participant.get() != NULL) {
//                        if (!participant->getId().compareNoCase(self.participant->getId())) {
//                            [self updateChatCallTransferFooterView];
//                        }
//                    }
//                }
//                    break;
//                case instac::IRTCManager::ActionIncomingChatRequest:
//                {
//                    const instac::CallArgs& callArgs = event->getCallArgs();
//                    const instac::String& callId = callArgs.identifier();
//                    instac::RefCountPtr<instac::ICall> chatCall = _rtcManager->getCall(callId);
//                    if ([self isCallForThisParticipant:chatCall])
//                    {
//                        _rtcManager->acceptCall(chatCall->callId());
//                    }
//                }
//                    break;
//                case instac::IRTCManager::ActionDidResetVisitors:
//                {
//                    IMLogDbg("[chatview] Visitors have been reset, reload chat screen", 0);
//                    _rtcManager->resetMessagesForParticipant(self.participant);
//                    [self updateRefreshControlTitle];
//                    IMLogVbs("[chatview] reload table from line %d", __LINE__);
//                    [self.tableView reloadData];
//                }
//                    break;
//                case instac::IRTCManager::ActionDidEstablishCommunicationChannel:
//                {
//                    /*
//                     Need to recreate participant object because it maight change during session renew/bind.
//                     This could happen when the app was in background with chat screen opened
//                     Then when the appreturns in foreground we reestablish the session which clears all the objects
//                     */
//                    [self reCreateParticipantObject];
//
//                    // Then need to reload all messages in case we have received some in background
//                    IMLogVbs("[chatview] reload table from line %d", __LINE__);
//                    [self.tableView reloadData];
//
//                    unsigned long count = [self.tableView numberOfRowsInSection:0];
//                    if ( count > 0 )
//                    {
//                        unsigned long lastMessageIndex = count - 1;
//
//                        IMLogVbs("[chatview] scroll anim to index: %d of %d", lastMessageIndex, count);
//                        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:lastMessageIndex
//                                                                                  inSection:0]
//                                              atScrollPosition:UITableViewScrollPositionBottom
//                                                      animated:YES];
//                    } else {
//                        // just load some  messages
//                        IMLogDbg("[CH] loadMoreMessages from %d", __LINE__);
//                        [self loadMoreMessages];
//                    }
//                }
//                    break;
//                default:
//                    break;
//            }
//        }
//            break;
//        default:
//            break;
//    }
//}

- (void) reCreateParticipantObject
{
    if (_participant.get() != NULL) {
        instac::RefCountPtr<instac::IParticipant> participant = _rtcManager->participantWithId(_participant->getId());
        if (participant.get() != NULL && participant.get() != _participant.get()) {
            // assign the new
            _participant = participant;
        }
    }
}

- (BOOL)isCallForThisParticipant:(instac::RefCountPtr<instac::ICall>)call
{
    if ((call != NULL) && (call.get() != NULL))
    {
        if (call->participantId().compare(_participant->getId()) == 0)
        {
            return YES;
        }
    }

    return NO;
}

- (void)setupInputViewsState
{
    if (!_participant->isAvailableForAction(instac::IParticipant::ParticipantAction::ParticipantActionChat))
    {
        [self setInputViewsState:kChatControllerStateParticipantLeft];
        return;
    }

//    CallsContainer* callsContainer = [self.callManager callsContainerForParticipantWithId:OBJCStringA(_participant->getId())];
    instac::RefCountPtr<instac::ICall> chatCall = nil;//[callsContainer chatCall];

    LSCall* lsChatCall = nil;

    if ((chatCall == NULL) || (chatCall.get() == NULL))
    {
        lsChatCall = nil;
    }
    else
    {
        lsChatCall = [[LSCall alloc] initWithModel:&chatCall];
    }

    if (lsChatCall == nil)
    {
        [self setInputViewsState:kChatControllerStateNoCall];
    }
    else if ([lsChatCall callState] == LSCallStateRinging)
    {
        [self setInputViewsState:kChatControllerStateCallNotAccepted];
    }
    else if ([lsChatCall callState] == LSCallStateAccepted)
    {
        [self setInputViewsState:kChatControllerStateCallAccepted];
    }
    else if ([lsChatCall callState] == LSCAllStateEnded)
    {
        [self setInputViewsState:kChatControllerStateCallEnded];
    }
}

- (void)setInputViewsState:(LSChatControllerState)state
{
    NSString* placeholderText = nil;

    switch (state)
    {
        case kChatControllerStateNoCall:
        case kChatControllerStateCallNotAccepted:
        case kChatControllerStateCallAccepted:
        {
            placeholderText = ICOLLString(@"Alert:Edit:Placeholder");
            [self setInputViewsEnabled:YES];
        }
            break;
        case kChatControllerStateCallEnded:
        {
            placeholderText = ICOLLString(@"Alert:Edit:Placeholder:ChatEnded");
            [self setInputViewsEnabled:YES];
        }
            break;
        case kChatControllerStateParticipantLeft:
        {
            placeholderText = ICOLLString(@"Alert:Edit:Placeholder:ProspectLeftThePage");
            [self setInputViewsEnabled:NO];
        }
            break;
    }

    self.textView.placeHolder = placeholderText;
}

- (void)setInputViewsEnabled:(BOOL)isInputViewsEnabled
{
    self.textView.editable = isInputViewsEnabled;
    self.textView.alpha = isInputViewsEnabled ? 1.0 : 0.8;
    [self.sendButton setEnabled:isInputViewsEnabled];
}

#pragma mark - Refresh

- (void) setupRefreshControl
{
    if (self.participant) {
        UIRefreshControl* refreshControl = [[UIRefreshControl alloc] init];
        [refreshControl addTarget:self
                           action:@selector(refreshOptions:)
                 forControlEvents:UIControlEventValueChanged];

        NSMutableAttributedString* attrString = nil;
        
        UIFont *fnt     = [UIFont systemFontOfSize:13 weight:UIFontWeightLight];
        UIColor* clr    = [UIColor grayColor];
        
        // Create the attributes
        NSDictionary *attr = [NSDictionary dictionaryWithObjectsAndKeys:
                              fnt, NSFontAttributeName,
                              clr, NSForegroundColorAttributeName, nil];
        
        if(self.participant->hasMoreMessages()) {

            attrString = [[NSMutableAttributedString alloc] initWithString:ICOLLString(@"History:Pull:Load") attributes:attr];
            
        } else {
            
            attrString = [[NSMutableAttributedString alloc] initWithString:ICOLLString(@"History:Full:Load") attributes:attr];
        }
        
        refreshControl.attributedTitle = attrString;
        refreshControl.tintColor = [UIColor grayColor];

        if ([self.tableView respondsToSelector:@selector(setRefreshControl:)]) {
            self.tableView.refreshControl = refreshControl;
        } else {
            [self.tableView addSubview:refreshControl];
        }

        self.refreshControl = refreshControl;
    }
}

- (void) updateRefreshControlTitle
{
    if (self.participant) {
        
        NSMutableAttributedString* attrString = nil;
        
        UIFont *fnt     = [UIFont systemFontOfSize:13 weight:UIFontWeightLight];
        UIColor* clr    = [UIColor grayColor];
        
        // Create the attributes
        NSDictionary *attr = [NSDictionary dictionaryWithObjectsAndKeys:
                              fnt, NSFontAttributeName,
                              clr, NSForegroundColorAttributeName, nil];
        
        if(self.participant->hasMoreMessages()) {
            
            attrString = [[NSMutableAttributedString alloc] initWithString:ICOLLString(@"History:Pull:Load") attributes:attr];
            
        } else {
            
            attrString = [[NSMutableAttributedString alloc] initWithString:ICOLLString(@"History:Full:Load") attributes:attr];
        }
        
        self.refreshControl.attributedTitle = attrString;
        self.refreshControl.tintColor = [UIColor grayColor];
    }
}

- (void) refreshOptions: (UIRefreshControl*) sender
{
    int err = _rtcManager->getNextMessagesForParticipant(self.participant);
    if (1 == err) {
        sender.attributedTitle = [[NSAttributedString alloc] initWithString: ICOLLString(@"History:Loading:More")];
    } else {
        // wont load anything
        [sender endRefreshing];
    }
}

- (void) stopAnimationRefreshing
{
    if ([self.refreshControl isRefreshing])
        [self.refreshControl endRefreshing];
}

- (int) loadMoreMessages {
    int err = 0;

    if (self.participant) {
        err = _rtcManager->getNextMessagesForParticipant(self.participant);
        if (1 == err) {
            if (![self.refreshControl isRefreshing])
                [self.refreshControl beginRefreshing];
        } else {
            if ([self.refreshControl isRefreshing])
                [self.refreshControl endRefreshing];
        }
    }

    return err;
}

#pragma mark - accessors

- (NSDateFormatter *)dayOnlyFormatter {
    if (_dayOnlyFormatter == nil) {
        _dayOnlyFormatter = [NSDateFormatter new];
        _dayOnlyFormatter.dateFormat = @"MMMM d"; // September 1
        _dayOnlyFormatter.timeZone = [NSTimeZone localTimeZone];
    }

    return _dayOnlyFormatter;
}

- (NSDateFormatter *)dateOnlyFormatter {
    if (_dateOnlyFormatter == nil) {
        _dateOnlyFormatter = [NSDateFormatter new];
        _dateOnlyFormatter.dateFormat = @"MMMM d, yyyy"; // September 1, 2016
        _dateOnlyFormatter.timeZone = [NSTimeZone localTimeZone];
    }

    return _dateOnlyFormatter;
}
@end


#ifdef DEBUG
void printViewConstraints(UIView* aView)
{
    NSLog(@"%@ constraints: %@",
          [aView class], aView.constraints);
    
    for (UIView* childView in aView.subviews) {
        printViewConstraints(childView);
    }
}
#endif
