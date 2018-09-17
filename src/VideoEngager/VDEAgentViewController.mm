//
//  VDEAgentViewController.m
//  VideoEngager
//
//  Created by Angel Terziev on 4.01.18.
//  Copyright © 2018 VideoEngager. All rights reserved.
//

#import "VDEAgentViewController.h"
#import "VDEAgentViewController+Internal.h"

#import "SDKChatViewController.h"
#import "VideoSceneViewController.h"
#import "CallViewController.h"
#import "VDEAgentDashboardViewController.h"
#import "VDEAgentDashboardViewController+Internal.h"

#import "VDEInternal.h"
#import "UIBarButtonItem+Additions.h"
#import "UIView+Constraints.h"

#import "IRTCManager.h"
#import "RtcEventsListener.h"
#import "LSCall.h"


#import "CallObject.h"


@interface VDEAgentViewController ()

@property(nonatomic, strong) SDKChatViewController* chatController;
@property(nonatomic, strong) VideoSceneViewController* videoSceneController;
@property(nonatomic, strong) CallViewController* callRingingController;
@property(nonatomic, strong) VDEAgentDashboardViewController* dashboardController;

@property(nonatomic, weak) UIViewController* shown;
@property(nonatomic,strong) VDEInternal* vde;

@property (nonatomic, copy, nullable) void (^disposeCompletion)(NSError* __nullable error);

@property(nonatomic,copy) NSDictionary* externalChatResponseBody;
@property(nonatomic,strong) NSString* rtcEventsListenerItemIncomingVideoCall;

@end

@interface VDEAgentViewController(CallViewController) <CallViewControllerDelegate>
@end

@interface VDEAgentViewController(SDKChatViewController) <SDKChatViewControllerDelegate>
@end

@implementation VDEAgentViewController

-(void) dealloc {
    NSLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
}

#pragma mark Private

- (BOOL) addChildViewControllerIfNecessary:(UIViewController *)childController {
    
    UIViewController* existing = nil;
    
    for(UIViewController* vc in self.childViewControllers)
    {
        if (vc == childController)
        {
            existing = vc;
            break;
        }
    }
    
    if (!existing) {
        [self addChildViewController: childController];
        return YES;
    }
    
    return NO;
}

- (void)showController: ( UIViewController* ) controllerToShow animated:(BOOL)animated {
    
    if (nil == controllerToShow || self.shown == controllerToShow)
        return;
    
    BOOL fAdded = [self addChildViewControllerIfNecessary: controllerToShow];

    controllerToShow.view.frame = self.view.bounds;
    
    if (nil == self.shown) {
        
        [self.view addSubview: controllerToShow.view];

        [controllerToShow.view resizesToSuperviewWithEdgeInsets: UIEdgeInsetsZero];
        
        if(fAdded) {
            [controllerToShow didMoveToParentViewController:self];
        }
        
        self.shown = controllerToShow;

        return;
    }
    
    UIViewAnimationOptions op = UIViewAnimationOptionTransitionCrossDissolve;
    
    if( [self.shown isKindOfClass:[SDKChatViewController class]] )
        op = UIViewAnimationOptionTransitionFlipFromRight;
    else if( [self.shown isKindOfClass:[VDEAgentDashboardViewController class]] )
        op = UIViewAnimationOptionTransitionFlipFromLeft;
    else
        op = UIViewAnimationOptionTransitionCrossDissolve;
    
    [self transitionFromViewController: self.shown
                      toViewController: controllerToShow
                              duration: animated ? 0.5 : 0.0
                               options: op
                            animations:^{}
                            completion:^(BOOL finished) {
                                
                                NSLog(@"Did Transition %@ animation from %@ to %@", finished ? @"with" : @"without",
                                      [self.shown class], [controllerToShow class]);

                                if (fAdded) {
                                    [controllerToShow didMoveToParentViewController:self];
                                }

                                [controllerToShow.view resizesToSuperviewWithEdgeInsets: UIEdgeInsetsZero];

                                self.shown = controllerToShow;
                            }];
}

- (void)viewDidLoad {

    [super viewDidLoad];
    
    self.dashboardController = [[VDEAgentDashboardViewController alloc] initWithInternal: self.vde
                                                                 andParentViewController: self];
    [self showController:self.dashboardController animated: NO];
}

- (void)continueStartingCallWithVideo: ( BOOL ) withVideo
{
    __weak typeof(self) weakSelf = self;
    
    NSArray* eventActions = @[@(instac::IRTCManager::ActionCallInitiated),
                              @(instac::IRTCManager::ActionOutgoingCallRequest),
                              @(instac::IRTCManager::ActionCallFailed)];
    
    NSString* rtcEventsListenerItemIdentifier =
    [[RtcEventsListener sharedInstance] notifyOnEventActions:eventActions
                                                     timeout:10.0
                                           completionHandler:^(instac::RTCEvent *event, BOOL isTimedOut, BOOL *stop)
     {
         if (isTimedOut)
         {
             //TODO: Present timeout error in the UI
             return;
         }
         
         NSString* callId = nil;
         
         if (event->getAction() == instac::IRTCManager::ActionCallInitiated)
         {
             callId = OBJCStringA(event->getCallId());
         }
         else if (event->getAction() == instac::IRTCManager::ActionOutgoingCallRequest)
         {
             const instac::CallArgs& args = event->getCallArgs();
             callId = OBJCStringA(args.identifier());
         }
         else if (event->getAction() == instac::IRTCManager::ActionCallFailed)
         {
             *stop = YES;
         }
         
         if (nil != callId) {
             IMLogDbg("Will listen for outgoing call id %s", callId.UTF8String);
             NSString* participantId = weakSelf.vde.vdeAgent.email;
             [weakSelf notifyOnOutgoingCallAvailability: callId
                                          participantId: participantId
                                      completionHandler:^(LSCall *call, BOOL isSuccessful)
              {
                  IMLogDbg("Outgoing call id %s, isSuccessful %d", callId.UTF8String, isSuccessful);
                  
                  if (isSuccessful)
                  {
                      [weakSelf showCallDialingForCall:call];
                  }
                  
                  *stop = YES;
              }];
         } else {
             //TODO: Present call failure in the UI
         }
     }];
    
    IMLogDbg("continueStartingCallWithVideo create RtcEventsListener with id: %s", rtcEventsListenerItemIdentifier.UTF8String);
}


- (void)notifyOnOutgoingCallAvailability:(NSString*)expectedCallId
                           participantId:(NSString*)participantId
                       completionHandler:(void (^)(LSCall* call, BOOL isSuccessful))completionHandler
{
    LSCall* call = [self.vde callById:expectedCallId];
    
    if (call)
    {
        if ([participantId isEqualToString:[call participantId]])
        {
            completionHandler(call, YES);
            return;
        }
    }
    
    NSArray* eventActions = @[@(instac::IRTCManager::ActionOutgoingCallRequest)];
    
    NSString* rtcEventsListenerItemIdentifier =
    [[RtcEventsListener sharedInstance] notifyOnEventActions:eventActions
                                                     timeout:5*60
                                           completionHandler:^(instac::RTCEvent* event, BOOL isTimedOut, BOOL* stop)
     {
         if (isTimedOut)
         {
             completionHandler(nil, NO);
             return;
         }
         
         const instac::CallArgs& args = event->getCallArgs();
         NSString* callId = OBJCStringA(args.identifier());
         
         if ([expectedCallId isEqualToString:callId])
         {
             LSCall* call = [self.vde callById:expectedCallId];
             
             if (call)
             {
                 if ([participantId isEqualToString:[call participantId]])
                 {
                     *stop = YES;
                     completionHandler(call, YES);
                 }
             }
         }
     }];
    IMLogDbg("notifyOnOutgoingCallAvailability create RtcEventsListener with id: %s", rtcEventsListenerItemIdentifier.UTF8String);
}

- (void)showCallDialingForCall:(LSCall*)call
{
    CallViewController* callViewController = [[CallViewController alloc] initWithType:CallViewControllerTypeDialing
                                                                              andCall:call];
    callViewController.delegate = self;
    
    self.callRingingController = callViewController;

    [self showController: self.callRingingController animated:NO];
    
    [self listenForInitiatedVideoCallResponse:call
                            callViewController:self.callRingingController];
}

- (void)showCallDialingExternal
{
    CallViewController* callViewController = [[CallViewController alloc] initWithType:CallViewControllerTypeDialing
                                                                              andCall:nil];
    callViewController.delegate = self;
    
    self.callRingingController = callViewController;
    
    [self showController: self.callRingingController animated:NO];
    
    [self listenForIncomingExternalVideoCall];
}

- (void)listenForInitiatedVideoCallResponse:(LSCall*)initiatedCall
                         callViewController:(CallViewController*)callViewController
{
    __weak typeof(self) weakSelf = self;

    NSArray* eventActions = @[@(instac::IRTCManager::ActionCallConnected),
                              @(instac::IRTCManager::ActionCallEnded),
                              @(instac::IRTCManager::ActionCommunicationChannelDidFail),
                              @(instac::IRTCManager::ActionDidRestoreCommunicationChannel)];
    
    NSString* rtcEventsListenerItemIdentifier =
    [[RtcEventsListener sharedInstance] notifyOnEventActions:eventActions
                                                     timeout:5*60
                                           completionHandler:^(instac::RTCEvent *event, BOOL isTimedOut, BOOL *stop)
     {
         if (isTimedOut)
         {
             return;
         }
         
         const instac::CallArgs& args = event->getCallArgs();
         NSString* callId = OBJCStringA(args.identifier());
         
         if ([initiatedCall.callId isEqualToString:callId])
         {
             if (event->getAction() == instac::IRTCManager::ActionCallConnected)
             {
                 *stop = YES;

                 IMLogDbg("Will dismiss callViewController", 0);
                 NSString* participantId = weakSelf.vde.vdeAgent.email;
                 
                 if (nil == weakSelf.videoSceneController) {
                     weakSelf.videoSceneController =
                     [[VideoSceneViewController alloc] initWithCallId: callId
                                                        participantId: participantId
                                                          callManager: weakSelf.vde
                                                 parentViewController: self];
                 }
                 
                 [weakSelf showController:weakSelf.videoSceneController animated:NO];

                 [weakSelf.callRingingController removeFromParentViewController];
                 weakSelf.callRingingController.delegate = nil;
                 weakSelf.callRingingController = nil;
             }
             else if (event->getAction() == instac::IRTCManager::ActionCallEnded)
             {
                 *stop = YES;
                 
                 IMLogDbg("Will dismiss callViewController", 0);
                 [weakSelf showController: weakSelf.dashboardController animated:NO];

                 [weakSelf.callRingingController removeFromParentViewController];
                 weakSelf.callRingingController.delegate = nil;
                 weakSelf.callRingingController = nil;
             }
         }
         
         if (event->getAction() == instac::IRTCManager::ActionCommunicationChannelDidFail)
         {
             IMLogDbg("ActionCommunicationChannelDidFail while dialing view is shown.", 0);
         }
         else if (event->getAction() == instac::IRTCManager::ActionDidRestoreCommunicationChannel)
         {
             IMLogDbg("ActionDidRestoreCommunicationChannel while dialing view is shown.", 0);
         }
     }];
    
    IMLogDbg("listenForInitiatedVideoCallResponse create RtcEventsListener with id: %s", rtcEventsListenerItemIdentifier.UTF8String);
}

-(void) listenForIncomingExternalVideoCall
{
    __weak typeof(self) weakSelf = self;
    
    NSArray* eventActions = @[@(instac::IRTCManager::ActionIncomingCallRequest),
                              @(instac::IRTCManager::ActionCommunicationChannelDidFail)];
    
    self.rtcEventsListenerItemIncomingVideoCall =
    [[RtcEventsListener sharedInstance] notifyOnEventActions:eventActions
                                                     timeout:180
                                           completionHandler:^(instac::RTCEvent *event, BOOL isTimedOut, BOOL *stop)
     {
         self.rtcEventsListenerItemIncomingVideoCall = nil;
         
         if (isTimedOut)
         {
             [weakSelf showController:weakSelf.dashboardController animated:NO];
             
             [weakSelf.callRingingController removeFromParentViewController];
             weakSelf.callRingingController.delegate = nil;
             weakSelf.callRingingController = nil;
             return;
         }
         
         if (event->getAction() == instac::IRTCManager::ActionIncomingCallRequest)
         {
             const instac::CallArgs& args = event->getCallArgs();
             NSString* callId = OBJCStringA(args.identifier());
             *stop = YES;

             if( [weakSelf.vde acceptCall: callId]) {
                 NSString* participantId = weakSelf.vde.vdeAgent.email;
                 
                 if (nil == weakSelf.videoSceneController) {
                     weakSelf.videoSceneController =
                     [[VideoSceneViewController alloc] initWithCallId: callId
                                                        participantId: participantId
                                                          callManager: weakSelf.vde
                                                 parentViewController: self];
                 }
                 
                 [weakSelf showController:weakSelf.videoSceneController animated:NO];
             } else {
                 [weakSelf showController:weakSelf.dashboardController animated:NO];
             }
             
             IMLogDbg("Will dismiss callViewController", 0);
             [weakSelf.callRingingController removeFromParentViewController];
             weakSelf.callRingingController.delegate = nil;
             weakSelf.callRingingController = nil;
         }
         else if (event->getAction() == instac::IRTCManager::ActionCommunicationChannelDidFail)
         {
             IMLogDbg("ActionCommunicationChannelDidFail while dialing view is shown.", 0);
             *stop = YES;

             [weakSelf showController:weakSelf.dashboardController animated:NO];

             [weakSelf.callRingingController removeFromParentViewController];
             weakSelf.callRingingController.delegate = nil;
             weakSelf.callRingingController = nil;
         }
     }];
    
    IMLogDbg("listenForIncomingExternalVideoCall create RtcEventsListener with id: %s",
             self.rtcEventsListenerItemIncomingVideoCall.UTF8String);
}

- (NSError*) startCallWithVideo: (BOOL) withVideo {
    
    NSError* error = [self.vde startCallWithVideo: withVideo];
    if (nil != error) {
        return error;
    }
    
    [self continueStartingCallWithVideo: withVideo];
    
    return nil;
}

//MARK: Navigation

-(void) didClickDashboard: (id) sender {
}

-(void) didClickChat: (id) sender {
}

-(void) didClickVideo: (id) sender {
}

//MARK: Interface
- (NSError*) startChat {

    if (![NSThread isMainThread])
        return [NSError errorWithDomain:@"VideoEngager" code:8001 userInfo:nil];

    if (nil == self.chatController) {
        self.chatController =
        [[SDKChatViewController alloc] initWithParticipantId: [self.vde.vdeAgent email]
                                          andInternalManager: self.vde];
        self.chatController.delegate = self;
    }
    
    [self showController: self.chatController animated: YES];
    
    return nil;
}

- (NSError*) startAudioCall {
    
    if (![NSThread isMainThread])
        return [NSError errorWithDomain:@"VideoEngager" code:8001 userInfo:nil];

    if (self.videoSceneController != nil) {
        [self showController:self.videoSceneController animated:YES];
    }
    
    return [self startCallWithVideo: NO];
}

- (NSError*) startVideoCall {

    if (![NSThread isMainThread])
        return [NSError errorWithDomain:@"VideoEngager" code:8001 userInfo:nil];
    
    if (self.videoSceneController != nil) {
        [self showController:self.videoSceneController animated:YES];
    }

    return [self startCallWithVideo: YES];
}

- (NSError*) startExternalVideoCall {
    if (![NSThread isMainThread])
        return [NSError errorWithDomain:@"VideoEngager" code:8001 userInfo:nil];
    
    [self showCallDialingExternal];

    [self.vde requestChatFirstName: self.vde.externalSystemParameters[@"firstName"]
                          lastName: self.vde.externalSystemParameters[@"lastName"]
                          nickname: self.vde.externalSystemParameters[@"nickname"]
                           subject: self.vde.externalSystemParameters[@"subject"]
                      emailAddress: self.vde.externalSystemParameters[@"email"]
                        completion:^(NSData * _Nullable data, NSError * _Nullable error)
    {
        
        if (nil != data) {
            NSError* jsonError = nil;
            id jsonObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
            if (nil != jsonObject && [jsonObject isKindOfClass: [NSDictionary class]]) {
                NSDictionary* json = (NSDictionary*) jsonObject;
                IMLogDbg("externalChatResponseBody: %s", json.description.UTF8String);
                self.externalChatResponseBody = json;
            }
        } else {
            // Error
            dispatch_async(dispatch_get_main_queue(), ^{
                [self showController:self.dashboardController animated:NO];
                
                [self.callRingingController removeFromParentViewController];
                self.callRingingController.delegate = nil;
                self.callRingingController = nil;
            });
        }
    }];
    
    return nil;
}


- (void) disposeWithCompletion: (void (^__nonnull)(NSError* __nullable error)) completion {
    
    // 1. If there is not active video call in progress we can safely return
    
    // Dont wait for the chat call to end
    [self.vde endActiveChatCalls];
    
    NSArray<NSString*>* activeVideoCallIDs = [self.vde endActiveVideoCalls];
    if (0 == [activeVideoCallIDs count]) {
        if(completion) {
            completion(nil);
        }
        
        return;
    }
    
    // now wait for the active video call to end
    
    __block NSMutableSet<NSString*>* waitingCallIDs = [[NSMutableSet alloc] initWithArray: activeVideoCallIDs];
    
    NSArray* eventActions = @[@(instac::IRTCManager::ActionCallEnded)];
    
    [[RtcEventsListener sharedInstance] notifyOnEventActions:eventActions
                                                     timeout:10.0
                                           completionHandler:^(instac::RTCEvent* event, BOOL isTimedOut, BOOL* stop)
     {
        if (isTimedOut)
        {
            NSError* error = [NSError errorWithDomain:@"VideoEngager" code:E_Timeout userInfo:nil];
            completion(error);
            return;
        }
         
        if( event->getAction() == instac::IRTCManager::ActionCallEnded)
        {
            NSString* callid = OBJCStringA(event->getCallId());
            if([waitingCallIDs containsObject: callid]) {
                [waitingCallIDs removeObject:callid];
                
                if ([waitingCallIDs count] == 0) {
                    // last callid was ended
                    completion(nil);
                    *stop = YES;
                }
            }
        }
    }];
    
    
}

@end

@implementation VDEAgentViewController (Internal)

- (instancetype) initWithInternal: (VDEInternal*) vde
{
    if (nil != (self = [super initWithNibName:@"VDEAgentViewController"
                                       bundle:[NSBundle bundleForClass:[self class]]]))
    {
        self.vde = vde;
    }
    
    return self;
}

- (void) removeVideoSceneViewController {

    [self showController:self.dashboardController animated:NO];
    
    [self.videoSceneController removeFromParentViewController];
    self.videoSceneController = nil;
    
    // Disconnect chat if this was extenral video call
    if (nil != self.externalChatResponseBody) {
        // this is a fake outgoing call. We actually wait for incoming video call
        // disconnect chat now
        
        [self.vde disconnectChatWithId:self.externalChatResponseBody[@"chatId"]
                                userId:self.externalChatResponseBody[@"userId"]
                             secureKey:self.externalChatResponseBody[@"secureKey"]
                                 alias:self.externalChatResponseBody[@"alias"]
                            completion:^(NSData * _Nullable data, NSError * _Nullable error)
         {
             self.externalChatResponseBody = nil;
         }];
    }
}

- (void) wantToClose {

    if ([self.delegate respondsToSelector:@selector(controllerWantsDispose:)]) {
        [self.delegate controllerWantsDispose:self];
    }
}

@end


@implementation VDEAgentViewController (CallViewController)
- (LSParticipant *)callViewController:(CallViewController *)callController participantInCall:(LSCall*)call
{
    if (nil != call)
        return [self.vde participantWithId:[call participantId]];
    
    return [self.vde participantWithId: [self.vde.agent email]];
}

- (void)callViewControllerDidPressHangup:(CallViewController *)callController
{
    if(nil != self.rtcEventsListenerItemIncomingVideoCall) {
        [[RtcEventsListener sharedInstance] removeListenerWithIdentifier: self.rtcEventsListenerItemIncomingVideoCall];
    }

    if (nil != callController.call) {
        [self.vde hangupCall:callController.call];
    } else if (nil != self.externalChatResponseBody) {
        // this is a fake outgoing call. We actually wait for incoming video call
        // disconnect chat now

        [self.vde disconnectChatWithId:self.externalChatResponseBody[@"chatId"]
                                userId:self.externalChatResponseBody[@"userId"]
                             secureKey:self.externalChatResponseBody[@"secureKey"]
                                 alias:self.externalChatResponseBody[@"alias"]
                            completion:^(NSData * _Nullable data, NSError * _Nullable error)
        {
            self.externalChatResponseBody = nil;
        }];
    }
    
    IMLogDbg("Will dismiss callViewController", 0);
    [callController dismissViewControllerAnimated:NO completion:^{
        IMLogDbg("Did dismiss callViewController", 0);
    }];
}

- (void)callViewControllerDidPressAnswer:(CallViewController *)callController
{
}

- (void)callViewController:(CallViewController *)callController pressedDeclineWithCompletion:(void (^)(BOOL success))completion
{
}

- (void)callViewController:(CallViewController *)callController pressedHoldAndAnswerWithCompletion:(void (^)(BOOL success))completion
{
}

- (void)callViewController:(CallViewController *)callController pressedEndAndAnswerWithCompletion:(void (^)(BOOL success))completion
{
}
@end


@implementation VDEAgentViewController(SDKChatViewController)

- (void)chatViewControllerDidClickTrashButton:(SDKChatViewController*)chatViewController
{
    
}

- (void)chatViewControllerDidClickCameraButton:(SDKChatViewController*)chatViewController
{
    [self startVideoCall];
}

- (NSString*) chatViewControllerDidRequestDefaultChatMessage:(SDKChatViewController*)chatViewController
{
    return @"";
}

- (void)chatViewControllerDidClickBackButton:(SDKChatViewController*)chatViewController
{
    [self showController:self.dashboardController animated:YES];
}


@end
