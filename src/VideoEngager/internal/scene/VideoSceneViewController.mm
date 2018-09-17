//
//  VideoSceneViewController.m
//  leadsecure
//
//  Created by Angel Terziev on 8/11/15.
//  Copyright (c) 2015 SoftAvail. All rights reserved.
//

#import "VideoSceneViewController.h"
#import "VideoViewContainer.h"

#import "AudioManager.h" // for kAudioRouteChangeNotification
#import <AVFoundation/AVFoundation.h>

//#import "LSQoSMonitor.h"
#import "ListParticipantsOnHoldOperation.h"
#import "HoldResumeCallOperation.h"
#import "RtcEventsListener.h"
//
//#import "CallTransferNavigationController.h"
//#import "CallTransferViewController.h"

#include "IFacade.h"
#include "IRTCManager.h"
//
//#import "SAAvatarManager.h"

#import "DeviceData.h"
#import "ICOLLAlertController.h"

#import "UIColor+Additions.h"
#import "UIImage+Additions.h"

#import "VDEAgentViewController.h"
#import "VDEAgentViewController+Internal.h"


#define AUDIO_ACTION_SHEET_TAG 101

#define SELECTED_AUDIO_SOURCE_BUTTON_TITLE_FORMAT @"%@ *"

NSString* const chksymbol = @"\u2713";

@interface PoorNetrworkLabel : UILabel
@end

@interface VideoSceneViewController ()
@property (weak, nonatomic) IBOutlet VideoViewContainer *remoteViewContainer;
@property (weak, nonatomic) IBOutlet VideoViewContainer *localViewContainer;
@property (weak, nonatomic) IBOutlet UIButton *backButton;

@property (nonatomic, weak) CallInProgressView * callInProgressView;

@property (nonatomic, weak) VDEInternal* callManager;
@property (nonatomic) NSString* rtcEventsListenerIdentifier;

@property (nonatomic) NSString* videoTracksListenerIdentifier;

@property (nonatomic) NSMutableArray* localVideoTracks;
@property (nonatomic) NSMutableArray* remoteVideoTracks;
@property (weak, nonatomic) IBOutlet UIView *oneWayCallView;
@property (weak, nonatomic) IBOutlet UILabel *oneWayInfoLabel;
@property (weak, nonatomic) IBOutlet UIImageView *oneWayMicNA;
@property (weak, nonatomic) IBOutlet UIImageView *oneWayCamNA;
@property (weak, nonatomic) IBOutlet UIImageView *avatarView;

@property (nonatomic, strong) UIPopoverPresentationController* popOverPresController;
@property (assign, nonatomic) NSUInteger ntwkQualityFlags;

@property (weak, nonatomic) UILabel *poorNetworkView;

@property (nonatomic, weak) VDEAgentViewController* parentController;

@end

//@interface VideoSceneViewController (VideoCallRenderer) <VideoCallRenderer, UIPopoverPresentationControllerDelegate, CallTransferViewControllerDelegate>
//@end

@implementation VideoSceneViewController
{
    instac::RefCountPtr<instac::IRTCManager> _rtcManager;
}

- (void) initThis
{
    [[VDENotificationCenter vdeCenter] addObserver: self
                                          selector: @selector(audioRouteChanged:)
                                              name: kAudioRouteChangeNotification
                                            object: nil];

    [[VDENotificationCenter vdeCenter] addObserver: self
                                          selector: @selector(didChangeVideoCallState:)
                                              name: kVideoCallManagerActiveVideoCallNotification
                                            object: nil];

    instac::IFacade::getInstance()->getRTCManager(_rtcManager);
}

- ( id )
initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];

    if ( nil != self )
    {
        [self initThis];
    }

    return self;
}

- (id) initWithCallId:(NSString *)callId
        participantId:(NSString *)participantId
          callManager:(VDEInternal*)callManager
 parentViewController:(VDEAgentViewController*) parentController {
    self = [super initWithNibName: @"VideoSceneViewController"
                           bundle: [NSBundle bundleForClass:[self class]]];

    if ( nil != self )
    {
        _callId = callId;
        self.callManager = callManager;
        [self initThis];
        _participantId = participantId;

        _call = [self.callManager callById:callId];
        self.ntwkQualityFlags = _rtcManager->networkQualityFlagsForCall(callId.UTF8String);

        self.localVideoTracks = [[NSMutableArray alloc] init];
        self.remoteVideoTracks = [[NSMutableArray alloc] init];
        
        self.parentController = parentController;
    }

    IMLogDbg("init %s", self.description.UTF8String);
    return self;
}

//- (LSCallRingingType)callRingingType
//{
//    return kBannerCallRingingType;
//}

- (void)viewDidLoad
{
    IMLogDbg("viewDidLoad %s", self.description.UTF8String);
    [super viewDidLoad];

    self.backButton.hidden = YES;

    self.view.backgroundColor = [UIColor appBackgroundColor];
    
    self.edgesForExtendedLayout = UIRectEdgeNone;

    Contact* contact = [self currentContact];

    if ( nil != contact )
        [self.navigationItem setTitle:contact.name];

    self.localViewContainer.name = @"localVideo"; // Internal use only, no translation needed
    self.remoteViewContainer.name = @"remoteVideo"; // Internal use only, no translation needed

    [self.localViewContainer setSkipFramesCount:2];

    self.localViewContainer.scalingMode = VVCScalingModeAspectFill;
    self.remoteViewContainer.scalingMode = VVCScalingModeAspectFit;

    self.localViewContainer.hidden = YES;
    self.remoteViewContainer.hidden = YES;

    self.localViewContainer.enableChangeScalingMode = NO;
    self.remoteViewContainer.enableChangeScalingMode = YES;

    [self addSceneCallInProgress];

    ListParticipantsOnHoldOperation* operation = [[ListParticipantsOnHoldOperation alloc] init];
    [operation perform];
    CallsOnHoldView* callsOnHoldView = [[CallsOnHoldView alloc] initWithListParticipants:operation];
    callsOnHoldView.delegate = self;
    [self.callInProgressView.callsOnHoldContainerView addSubview: callsOnHoldView];
    self.callInProgressView.callsOnHoldView = callsOnHoldView;
    [self.callInProgressView setNeedsUpdateConstraints];

    [self.callInProgressView setMuteButtonSelected:[self.callManager isMuted]];
    [self.callInProgressView setSpeakerButtonSelected: _rtcManager->getLaudspeakerStatus()];

//    [self rightBarButtonItems];

    [self.view setNeedsLayout];
    [self.view layoutIfNeeded];

    [self.callInProgressView stopCallWaitingActivityIndicator];

    if (([self.call callState] == LSCallStateRinging) || ([self.call isTransfer]))
    {
        [self.callInProgressView startCallWaitingActivityIndicator];
    }

    [[VDENotificationCenter vdeCenter] addObserver: self
                                             selector: @selector(didChangeChatCallState:)
                                                 name: kVideoCallManagerActiveChatCallNotification
                                               object: nil];

    [[VDENotificationCenter vdeCenter] addObserver: self
                                             selector: @selector(visitorDidBecomeInactive:)
                                                 name: kVideoCallManagerVisitorDidBecomeInactive
                                               object: nil];

    [[VDENotificationCenter vdeCenter] addObserver: self
                                             selector: @selector(didReceiveCallAnswerTime:)
                                                 name: kDidReceiveCallAnswerTime
                                               object: nil];

    [[VDENotificationCenter vdeCenter] addObserver: self
                                             selector: @selector(didSetVideoRoute:)
                                                 name: kDidSetVideoRouteNotification
                                               object: nil];

    [[VDENotificationCenter vdeCenter] addObserver: self
                                             selector: @selector(visitorDidUpdate:)
                                                 name: kVideoCallManagerDidUpdateVisitor
                                               object: nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidBecomeActive:)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationWillResignActive:)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:nil];

    [[VDENotificationCenter vdeCenter] addObserver:self
                                             selector:@selector(handleStartCallToVisitorNotification:)
                                                 name:kDidStartCallWithVisitorNotification
                                               object:nil];

    [self setupListenerParticipantChangesListener];

    if ( nil != self.navigationController ) {

        if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {

            self.navigationController.interactivePopGestureRecognizer.enabled = NO;
        }
    }

    [self setupVideoTracksListener];

    [self hideOneWayCallInfo];

    IMLogVbs("viewDidLoad end %s", self.description.UTF8String);

//    [self loadAvatar];

    if (self.autoStartCamera) {
        IMLogDbg("autoStartCamera is true", 0);
        _rtcManager->enableLocalVideo(true);

        switch (_rtcManager->videoCameraRoute())
        {
            case instac::IRTCManager::VideoRouteFrontCamera:
                [self.callManager requestVideoRoute: VideoRouteBack];
                break;
            case instac::IRTCManager::VideoRouteBackCamera:
            case instac::IRTCManager::VideoRouteNone:
            default:
                [self.callManager requestVideoRoute: VideoRouteFront];
                break;
        }
    }
}
//
//- (UIBarButtonItem*) bbiWithImageName:(NSString*) imgName andSelector:(SEL) selector {
//
//    UIBarButtonItem* bbi = nil;
//
//    UIImage* img = [UIImage imageNamed:imgName];
//
//    if ( nil != img ) {
//
//        UIButton* btn = [[UIButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, img.size.width, img.size.height)];
//
//        if ( nil != btn ) {
//
//            [btn setImage:img forState:UIControlStateNormal];
//
//            btn.contentMode = UIViewContentModeScaleAspectFill;
//            btn.backgroundColor = [UIColor clearColor];
//            [btn addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
//
//            bbi = [[UIBarButtonItem alloc] initWithCustomView:btn];
//
//            if ( nil != bbi )
//                bbi.enabled = YES;
//        }
//    }
//
//    return bbi;
//}
//
//- (BOOL) needCallTransferBBi
//{
//    return ([[VideoCallManager instance] workingMode] == LSWorkingModeAgent);
//}
//
//- ( UIBarButtonItem*) callTransferBBi {
//
//    UIBarButtonItem* bbi = [self bbiWithImageName:@"callTransferSmall" andSelector:@selector(didClickCallTransferButton:)];
//
//    return bbi;
//}
//
//- ( UIBarButtonItem*) gaugeBbi {
//
//    UIBarButtonItem* bbi = [self bbiWithImageName:@"gauge-excellent" andSelector:nil];
//    bbi.enabled = NO;
//
//    UIButton* btn = bbi.customView;
//
//    if ( [btn isKindOfClass:[UIButton class]] )
//        [btn setImage:[UIImage imageNamed:@"gauge-excellent"] forState:UIControlStateDisabled];
//
//    return bbi;
//}
//
//
//- (void)rightBarButtonItems {
//
//    NSMutableArray* buttons = [NSMutableArray new];
//
//    // Gauge
//    [buttons addObject:[self gaugeBbi]];
//
//    // Call Transfer
//    if ([self needCallTransferBBi])
//        [buttons addObject:[self callTransferBBi]];
//
//    self.navigationItem.rightBarButtonItems = buttons;
//}
//
//- (void)didReceiveMemoryWarning {
//    [super didReceiveMemoryWarning];
//    // Dispose of any resources that can be recreated.
//}
//
//- (void)didClickCallTransferButton:(UIButton*)button {
//
//    [self showPopoverFormButton:button];
//}
//
//
//- (void)dumpPoorNetworkStats {
//
//    NSMutableArray<NSString*>* records = [[NSMutableArray alloc] init];
//
//    std::vector<std::map<instac::String, instac::String>> stats =
//    _rtcManager->getPoorNetworkStats(_callId.UTF8String);
//
//    if (stats.size() == 0)
//        return;
//
//    records = [[NSMutableArray alloc] init];
//
//    for (std::vector<std::map<instac::String, instac::String>>::const_iterator it = stats.begin();
//         it != stats.end(); ++it)
//    {
//        NSMutableString* line = [[NSMutableString alloc] init];
//        BOOL isVideo = NO;
//
//        const std::map<instac::String, instac::String> &stat = *it;
//        const instac::String& kMediaType("mediaType");
//        if(stat.find(kMediaType) != stat.end()) {
//            const instac::String& mediaType = stat.at(kMediaType);
//            [line appendFormat:@"%s", mediaType.c_str()];
//
//            if (0 == mediaType.compareNoCase("video")) {
//                isVideo = YES;
//            }
//        }
//
//        const instac::String& kRtt("rtt");
//        if(stat.find(kRtt) != stat.end()) {
//            const instac::String& rtt = stat.at(kRtt);
//            [line appendFormat:@" ,%s ", rtt.c_str()];
//        }
//
//        if (isVideo) {
//            const instac::String& kRate("frameRate");
//            if(stat.find(kRate) != stat.end()) {
//                const instac::String& value = stat.at(kRate);
//                [line appendFormat:@" ,%s ", value.c_str()];
//            }
//
//            const instac::String& kRes("res");
//            if(stat.find(kRes) != stat.end()) {
//                const instac::String& value = stat.at(kRes);
//                [line appendFormat:@" ,%s ", value.c_str()];
//            }
//        }
//
//        [records addObject: [line copy]];
//    }
//
//
//    IMLogVbs("GAUGE STATS: %s", records.description.UTF8String);
//}
//
//- (void) showPopoverFormButton:(UIButton*)button {
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
//        self.popOverPresController.sourceView = button;
//        self.popOverPresController.sourceRect = CGRectMake(CGRectGetWidth([button frame])/2,
//                                                           CGRectGetHeight([button frame]),
//                                                           2.0f,
//                                                           2.0f);
//
//        self.popOverPresController.permittedArrowDirections = UIPopoverArrowDirectionDown | UIPopoverArrowDirectionUp;
//
//        [self presentViewController:nc animated:YES completion:nil];
//    }
//}
//
- ( void )
dealloc
{
    IMLogDbg("Deallocating... %s", self.description.UTF8String);

    [[RtcEventsListener sharedInstance] removeListenerWithIdentifier:_rtcEventsListenerIdentifier];
    [[RtcEventsListener sharedInstance] removeListenerWithIdentifier:_videoTracksListenerIdentifier];


    [[VDENotificationCenter vdeCenter] removeObserver:self
                                                 name:kAudioRouteChangeNotification
                                               object:nil];

    [[VDENotificationCenter vdeCenter] removeObserver: self
                                                    name: kVideoCallManagerActiveVideoCallNotification
                                                  object: nil];

    [[VDENotificationCenter vdeCenter] removeObserver: self
                                                    name: kVideoCallManagerActiveChatCallNotification
                                                  object: nil];

    [[VDENotificationCenter vdeCenter] removeObserver: self
                                                    name: kVideoCallManagerVisitorDidBecomeInactive
                                                  object: nil];

    [[VDENotificationCenter vdeCenter] removeObserver: self
                                                    name: kDidSetVideoRouteNotification
                                                  object: nil];

    [[VDENotificationCenter vdeCenter] removeObserver: self
                                                    name: kDidReceiveCallAnswerTime
                                                  object: nil];


    [[VDENotificationCenter vdeCenter] removeObserver: self
                                                    name: kVideoCallManagerDidUpdateVisitor
                                                  object: nil];

    [[VDENotificationCenter vdeCenter] removeObserver:self
                                                    name:kDidStartCallWithVisitorNotification
                                                  object:nil];

    [[VDENotificationCenter vdeCenter] removeObserver:self
                                                    name:UIApplicationWillResignActiveNotification
                                                  object:nil];

    [[VDENotificationCenter vdeCenter] removeObserver:self
                                                    name:UIApplicationDidBecomeActiveNotification
                                                  object:nil];

    [self.callInProgressView stopCallDurationTimer];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    [self updateQoSViewSize];
}

- (void)updateQoSViewSize
{
//    UIImageView* qosImageView = self.navigationItem.rightBarButtonItem.customView;
//    CGFloat navigationBarHeight = self.navigationController.navigationBar.frame.size.height - RIGHT_BAR_BUTTON_ITEM_OFFSET;
//    qosImageView.bounds = CGRectMake(0.0, 0.0, navigationBarHeight, navigationBarHeight);
}

- ( void )
viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self audioRouteChanged:nil];

    [self.callManager callLocalVideoStateUpdate: YES];

//    [[LSQoSMonitor sharedInstance] addQoSImageView:self.navigationItem.rightBarButtonItem.customView];
}

- ( void )
viewDidAppear:(BOOL)animated
{
    IMLogVbs("viewDidAppear %s", self.description.UTF8String);
    [super viewDidAppear:animated];

    [self addLocalRendererToVideoTrack:self.callManager.localVideoTrack];
    [self addRemoteRendererToVideoTrack:self.callManager.remoteVideoTrack];
    [self updateVideoUI];

}

- (void)viewWillDisappear:(BOOL)animated
{
    [self removeLocalRendererFromVideoTrack:self.callManager.localVideoTrack];
    [self removeRemoteRendererFromVideoTrack:self.callManager.remoteVideoTrack];

//    [[LSQoSMonitor sharedInstance] removeQoSImageView:self.navigationItem.rightBarButtonItem.customView];
}

- (void)viewDidDisappear:(BOOL)animated
{
    IMLogVbs("viewDidDisappear %s", self.description.UTF8String);
    [super viewDidDisappear:animated];
    
    [self.callManager callLocalVideoStateUpdate: NO];
}
//
///*
//#pragma mark - Navigation
//
//// In a storyboard-based application, you will often want to do a little preparation before navigation
//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
//    // Get the new view controller using [segue destinationViewController].
//    // Pass the selected object to the new view controller.
//}
//*/

- (void)callsOnHoldView:(CallsOnHoldView*)callsOnHoldView
didPressResumeOnParticipant:(LSParticipant*)participant
{
//    HoldResumeCallOperation* holdResumeCallOperation = [[HoldResumeCallOperation alloc] initWithParticipant:participant];
//    [holdResumeCallOperation perform];
//    [self.videoSceneShowController showVideoSceneForCall:[holdResumeCallOperation callToBeResumed]];
}

- (void)showCallControls
{
    self.callInProgressView.hidden = NO;
}

- (void)hideCallControls
{
    self.callInProgressView.hidden = YES;
}

- (void)showOneWayCallWithInfo: (NSString*) info
                     withMicNA: (BOOL) micNA
                     withCamNA: (BOOL) camNA
{
    self.oneWayCallView.hidden = NO;
    self.oneWayInfoLabel.text = info;
    self.oneWayMicNA.hidden = !micNA;
    self.oneWayCamNA.hidden = !camNA;
}

- (void)hideOneWayCallInfo
{
    self.oneWayCallView.hidden = YES;
}

- (void)showPoorNetworkView
{
    [self hidePoorNetworkView];

    UILabel* label = [[PoorNetrworkLabel alloc] initWithFrame: CGRectZero];
    label.numberOfLines = 1;
    label.textColor = [UIColor whiteColor];
    label.backgroundColor = [UIColor blackColor];
    label.font = [UIFont systemFontOfSize:15 weight:UIFontWeightRegular];
    label.layer.borderWidth = 1.0;
    label.layer.cornerRadius = 5;
    label.layer.borderColor = [[UIColor whiteColor] CGColor];
    label.layer.masksToBounds = YES;
    label.textAlignment = NSTextAlignmentCenter;
    label.translatesAutoresizingMaskIntoConstraints = NO;
    label.text = ICOLLString(@"Call:PoorNetwork:Description");

    [self.view addSubview: label];

    NSLayoutConstraint* constraintLabelCenterX =
    [NSLayoutConstraint constraintWithItem:label
                                 attribute:NSLayoutAttributeCenterX
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:self.view
                                 attribute:NSLayoutAttributeCenterX
                                multiplier:1.0f
                                  constant:0.0f];

    NSLayoutConstraint* constraintLabelCenterY =
    [NSLayoutConstraint constraintWithItem:label
                                 attribute:NSLayoutAttributeCenterY
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:self.view
                                 attribute:NSLayoutAttributeCenterY
                                multiplier:1.0f
                                  constant:0.0f];

    [self.view addConstraint: constraintLabelCenterX];
    [self.view addConstraint: constraintLabelCenterY];
    [self.view bringSubviewToFront: label];

    self.poorNetworkView = label;
}

- (void)hidePoorNetworkView
{
    [self.poorNetworkView removeFromSuperview];
    self.poorNetworkView = nil;
}

- (void)updatePoorNetworkView
{
    if (nil == self.poorNetworkView && self.ntwkQualityFlags > 0) {
        [self showPoorNetworkView];
    } else if (nil != self.poorNetworkView && 0 == self.ntwkQualityFlags) {
        [self hidePoorNetworkView];
    }
}
//
//- (void) loadAvatar
//{
//    instac::RefCountPtr<instac::IParticipant> participant = _rtcManager->participantWithId(self.participantId.UTF8String);
//    if (participant.get() && !participant->avatar().empty()) {
//        Avatar* avatar =
//        [[SAAvatarManager sharedInstance] avatarWithId:OBJCStringA(participant->getId())
//                                                andUrl:OBJCStringA(participant->avatar())];
//        if (nil != avatar) {
//            self.avatarView.image = [[UIImage alloc] initWithData: avatar.image];
//        }
//    }
//}
//
//#pragma mark -
//#pragma mark Helpers

- ( Contact* )
currentContact
{
    return [self.callManager contactForCallWithParticipant:self.participantId];
}

- ( CallInProgressView* ) createCallInProgressView
{
    Class classType = [CallInProgressView class];

    NSArray *nibContents = [[NSBundle bundleForClass:[self class]] loadNibNamed:NSStringFromClass(classType) owner:self options:nil];

    CallInProgressView* v = nil;

    for (v in nibContents)
    {
        if ( [v isKindOfClass: classType] )
        {
            if ( [v respondsToSelector:@selector(setDelegate:)] )
                [v performSelector:@selector(setDelegate:) withObject:self];

            break;
        }
    }

    return v;
}

- ( void )
autoresizeConstraintsForSubview : ( UIView* ) subview
{
    [subview setTranslatesAutoresizingMaskIntoConstraints:NO];

    [self removeConstraintsForView:subview];

    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:subview
                                                          attribute:NSLayoutAttributeTop
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeTop
                                                         multiplier:1.0
                                                           constant:0.0]];

    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:subview
                                                          attribute:NSLayoutAttributeLeading
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeLeading
                                                         multiplier:1.0
                                                           constant:0.0]];

    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:subview
                                                          attribute:NSLayoutAttributeBottom
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeBottom
                                                         multiplier:1.0
                                                           constant:0.0]];

    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:subview
                                                          attribute:NSLayoutAttributeTrailing
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeTrailing
                                                         multiplier:1.0
                                                           constant:0.0]];

    [self.view layoutIfNeeded];
}

- (void)applicationDidBecomeActive: (NSNotification *) aNotification
{
    IMLogDbg("Video, applicationDidBecomeActive entry", 0);

    if (_localVideoTracks.count > 0)
    {
        IMLogDbg("Video, applicationDidBecomeActive local will resume renderer", 0);
        [self.localViewContainer resumeRenderer];
        IMLogDbg("Video, applicationDidBecomeActive local did resume renderer", 0);
    }

    if (_remoteVideoTracks.count > 0)
    {
        IMLogDbg("Video, applicationDidBecomeActive remote will resume renderer", 0);
        [self.remoteViewContainer resumeRenderer];
        IMLogDbg("Video, applicationDidBecomeActive remote did resume renderer", 0);
    }

    IMLogDbg("Video, applicationDidBecomeActive leave", 0);
}

- (void)applicationWillResignActive: (NSNotification *) aNotification
{
    IMLogDbg("Video, applicationWillResignActive entry", 0);

    if (_localVideoTracks.count > 0)
    {
        IMLogDbg("Video, applicationWillResignActive local will pause renderer", 0);
        [self.localViewContainer pauseRenderer];
        IMLogDbg("Video, applicationWillResignActive local did pause renderer", 0);
    }

    if (_remoteVideoTracks.count > 0)
    {
        IMLogDbg("Video, applicationWillResignActive remote will pause renderer", 0);
        [self.remoteViewContainer pauseRenderer];
        IMLogDbg("Video, applicationWillResignActive remote did pause renderer", 0);
    }

    IMLogDbg("Video, applicationWillResignActive leave", 0);
}

- (void)handleStartCallToVisitorNotification: (NSNotification *) aNotification
{
    BOOL success = [aNotification.userInfo[kDidStartCallWithVisitorSuccessKey] boolValue];
    NSString* visitorId = aNotification.userInfo[kDidStartCallWithVisitorVisitorKey];
    BOOL withVideo = [aNotification.userInfo[kDidStartCallWithVisitorVideoKey] boolValue];

    if ( NSOrderedSame != [visitorId caseInsensitiveCompare:self.participantId]) {
        IMLogDbg("Video, handleStartCallToVisitorNotification, visitor: %s is not the same: %s",
                 visitorId.UTF8String, self.participantId.UTF8String);
        return;
    }

    if (withVideo && success)
    {
        IMLogDbg("Video, handleStartCallToVisitorNotification", 0);

        _rtcManager->enableLocalVideo(true);

        switch (_rtcManager->videoCameraRoute())
        {
            case instac::IRTCManager::VideoRouteFrontCamera:
                [self.callManager requestVideoRoute: VideoRouteBack];
                break;
            case instac::IRTCManager::VideoRouteBackCamera:
            case instac::IRTCManager::VideoRouteNone:
            default:
                [self.callManager requestVideoRoute: VideoRouteFront];
                break;
        }
    }
}


- ( void )
addViewAnimated: ( UIView* ) viewForAdd
{
    viewForAdd.alpha = 0.0;
    NSLog(@"[SCENE] will add scene view: %@", viewForAdd);
    [self.view insertSubview:viewForAdd belowSubview:self.backButton];
    NSLog(@"[SCENE] did add scene view: %@", viewForAdd);

    [self autoresizeConstraintsForSubview:viewForAdd];

    [UIView animateWithDuration:DEFAULT_ANIMATION_DURATION
                          delay:0.0f
                        options:UIViewAnimationOptionTransitionCrossDissolve
                     animations:^{
                         viewForAdd.alpha = 1.0;
                     }
                     completion:^(BOOL finished) {
                         NSLog(@"[SCENE] (finished:%d) did show scene view: %@", finished, viewForAdd);
                     }];
}

- ( void )
addSceneCallInProgress
{
    CallInProgressView* cip = [self createCallInProgressView];

    if ( nil != cip )
    {
        //temp.
        Contact* contact = [self currentContact];
        [cip showContactInfoForContact:contact];

        [self addViewAnimated: cip];
        self.localViewContainer.alpha = 1;
        self.callInProgressView = cip;

        if ((self.call.answerTime != 0) && (![self.call isTransfer]))
        {
            [self.callInProgressView startCallDurationTimerWithStartTime:self.call.answerTime];
        }

        [self.callInProgressView startControlsTimer];

        if (self.ntwkQualityFlags > 0) {
#if WITH_DISABLE_VIDEO_BUTTON_ON_POOR_NETWORK
            [self.callInProgressView enableCameraButton: NO];
#endif
        }
    }
}

- (void)setupListenerParticipantChangesListener
{
    NSArray* eventActions = @[@(instac::IRTCManager::ActionParticipantAvailabilityChanged),
                              @(instac::IRTCManager::ActionDidUpdateAgent)];

    __weak typeof(self) weakSelf = self;

    _rtcEventsListenerIdentifier = [[RtcEventsListener sharedInstance] notifyOnEventActions:eventActions
                                                                                    timeout:0
                                                                          completionHandler:^(instac::RTCEvent* event, BOOL isTimedOut, BOOL* stop)
     {
         const instac::RefCountPtr<instac::IParticipant> participant = event->getParticipant();

         if ((participant != NULL) && (participant.get() != NULL))
         {
             if ([OBJCStringA(participant->getId()) isEqualToString:weakSelf.participantId])
             {
                 Contact* contact = [weakSelf currentContact];
                 [weakSelf.callInProgressView showContactInfoForContact:contact];
                 [weakSelf.callInProgressView showContactInfo];

//                 if (contact)
//                 {
//                     [weakSelf.navigationItem setTitle:contact.name];
//                 }
             }
             else
             {
                 IMLogDbg("Participant ", 0);
             }
         }
     }];
}
//
//- ( UIStatusBarStyle )
//preferredStatusBarStyle
//{
//    return UIStatusBarStyleLightContent;
//}
//
//- ( void )
//viewWillTransitionToSize        : ( CGSize                                      ) size
//withTransitionCoordinator       : ( id <UIViewControllerTransitionCoordinator>  ) coordinator
//{
//    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
//
//    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context)
//     {
//         [self updateVideoUI];
//     } completion:^(id<UIViewControllerTransitionCoordinatorContext> context)
//     {
//     }];
//}

- ( void )
addBorderToLocalFeed
{
    self.localViewContainer.layer.masksToBounds = YES;
    self.localViewContainer.layer.borderWidth = 1.0;
    self.localViewContainer.layer.borderColor = [UIColor whiteColor].CGColor;
}

- ( void )
removeBorderInLocalFeed
{
    self.localViewContainer.layer.masksToBounds = YES;
    self.localViewContainer.layer.borderWidth = 0.0;
}

- ( void )
messageAction
{
    [self showChatViewController];
}

- ( void )
cameraActionWithSender: (UIView*) sender
{
    NSString* frntTitle = ICOLLString(@"Call:CameraSource:Front");
    NSString* backTitle = ICOLLString(@"Call:CameraSource:Back");
    NSString* noneTitle = ICOLLString(@"Call:CameraSource:None");

    switch (_rtcManager->videoCameraRoute()) {
        case instac::IRTCManager::VideoRouteFrontCamera:
            frntTitle = [NSString stringWithFormat:@"%@ %@", chksymbol, frntTitle];
            break;
        case instac::IRTCManager::VideoRouteBackCamera:
            backTitle = [NSString stringWithFormat:@"%@ %@", chksymbol, backTitle];
            break;
        case instac::IRTCManager::VideoRouteNone:
            noneTitle = [NSString stringWithFormat:@"%@ %@", chksymbol, noneTitle];
            break;
        default:
            break;
    }

    __weak typeof(self) weakself = self;

    ICOLLAlertController * actionSheet =
    [ICOLLAlertController alertControllerWithTitle:nil
                                        message:nil
                                 preferredStyle:UIAlertControllerStyleActionSheet];
    /*
     For iPAD ICOLLAllertControllerStyleActionSheet will be presented from popover
     The modalPresentationStyle of a ICOLLAlertController with this style is UIModalPresentationPopover.
     You must provide location information for this popover through the alert controller's popoverPresentationController.
     You must provide either a sourceView and sourceRect or a barButtonItem.
     If this information is not known when you present the alert controller,
     you may provide it in the UIPopoverPresentationControllerDelegate method -prepareForPopoverPresentation.
     */

    if (UI_IPAD()) {
        actionSheet.popoverPresentationController.sourceView = sender;
    }

    UIAlertAction* frnt = [UIAlertAction
                           actionWithTitle: frntTitle
                           style:UIAlertActionStyleDefault
                           handler:^(UIAlertAction * action)
                           {
                               _rtcManager->resetPoorNetworkFlagsForCall(_callId.UTF8String);
                                _rtcManager->enableLocalVideo(true);
                                [weakself.callManager requestVideoRoute: VideoRouteFront];
                           }];
    UIAlertAction* back = [UIAlertAction
                             actionWithTitle: backTitle
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
                                 _rtcManager->resetPoorNetworkFlagsForCall(_callId.UTF8String);
                                 _rtcManager->enableLocalVideo(true);
                                 [weakself.callManager requestVideoRoute: VideoRouteBack];
                             }];
    UIAlertAction* none = [UIAlertAction
                           actionWithTitle: noneTitle
                           style:UIAlertActionStyleDefault
                           handler:^(UIAlertAction * action)
                           {
                               [weakself.callManager requestVideoRoute: VideoRouteNone];
                           }];

    UIAlertAction* cncl = [UIAlertAction
                           actionWithTitle:ICOLLString(@"Call:AudioSource:Cancel")
                           style:UIAlertActionStyleDefault
                           handler:^(UIAlertAction * action)
                           {
                           }];


    [actionSheet addAction:frnt];
    [actionSheet addAction:back];
    [actionSheet addAction:none];

    [actionSheet addAction:cncl];

    [self presentViewController:actionSheet animated:YES completion:nil];
}

- ( void )
muteAction:(UIButton *) button
{
    [self.call setMute:!self.call.isMuted];
    [self.callManager mute:self.call.isMuted];
    [self.callInProgressView setMuteButtonSelected:self.call.isMuted];
}

- ( void )
hangupAction
{
    [self removeRemoteRendererFromVideoTrack:self.callManager.remoteVideoTrack];

    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.call != nil)
        {
            if (self.call.isTransfer)
            {
                [self.callManager hangupTransferCallAndDeleteVisitor:self.call];
            }
            else
            {
                [self.callManager hangupCall:self.call];
            }
        }
    });

    [self updateVideoUI];

    [self removeBorderInLocalFeed];

    // pop to root view controller
    IMLogDbg("Will popToRootViewControllerAnimated - YES", 0);
    if(nil != self.navigationController) {
        [self.navigationController popToRootViewControllerAnimated: YES];
        NSLog(@"self.navigationController.visibleViewController %@", NSStringFromClass(self.navigationController.visibleViewController.class));
    }
}

- ( void )
speakerAction:(UIButton *) button
{
    if ([[AudioManager sharedInstance] isBluetoothAvailable]) {

        [self presentAudioDeviceOptionsWithSender: button];

    } else {
        bool newSpeakerStatus = (button.isSelected == NO);
        bool setSpeakerStatusResult = _rtcManager->setLaudspeakerStatus(newSpeakerStatus);
        IMLogDbg("setLaudspeakerStatus to %d returned %d", newSpeakerStatus, setSpeakerStatusResult)
        if (setSpeakerStatusResult)
            [self.callInProgressView setSpeakerButtonSelected: newSpeakerStatus];
    }
}


- (void) presentAudioDeviceOptionsWithSender: (UIView*) sender
{
    SAAudioDevice* btDevice = [[AudioManager sharedInstance] bluetootheDevice];

    ICOLLAlertController * actionSheet =
    [ICOLLAlertController alertControllerWithTitle:nil
                                        message:nil
                                 preferredStyle:UIAlertControllerStyleActionSheet];
    /*
     For iPAD ICOLLAllertControllerStyleActionSheet will be presented from popover
     The modalPresentationStyle of a ICOLLAlertController with this style is UIModalPresentationPopover.
     You must provide location information for this popover through the alert controller's popoverPresentationController.
     You must provide either a sourceView and sourceRect or a barButtonItem.
     If this information is not known when you present the alert controller,
     you may provide it in the UIPopoverPresentationControllerDelegate method -prepareForPopoverPresentation.
     */

    if (UI_IPAD()) {
        actionSheet.popoverPresentationController.sourceView = sender;
    }

    UIAlertAction*
    blth = [UIAlertAction actionWithTitle: btDevice.name
                                    style: UIAlertActionStyleDefault
                                  handler: ^(UIAlertAction * action)
            {
//                [[AudioManager sharedInstance] setBluetoothActive];
                IMLogDbg("set PreferredAudioOutput: AudioOutputBluetooth", 0);
                [[AudioManager sharedInstance] setPreferredAudioOutput: AudioOutputBluetooth];
            }];


    if([[AudioManager sharedInstance] isBluetoothCurrentAudioOutput])
        [blth setValue:[[UIImage sdkImageNamed:@"checkmark"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forKey:@"image"];
    else
        [blth setValue:nil forKey:@"image"];

    [actionSheet addAction:blth];

    if ([[AudioManager sharedInstance] hasReceiver]) {
        UIAlertAction*
        recv = [UIAlertAction actionWithTitle: ICOLLString(@"Call:AudioSource:Receiver")
                                        style: UIAlertActionStyleDefault
                                      handler: ^(UIAlertAction * action)
                {
//                    [[AudioManager sharedInstance] setBluetoothInactive];
//                    _rtcManager->setLaudspeakerStatus(false);
                    IMLogDbg("set PreferredAudioOutput: AudioOutputReceiver", 0);
                    [[AudioManager sharedInstance] setPreferredAudioOutput: AudioOutputReceiver];
                }];

        if([[AudioManager sharedInstance] isReceiverCurrentAudioOutput])
            [recv setValue:[[UIImage sdkImageNamed:@"checkmark"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forKey:@"image"];
        else
            [recv setValue:nil forKey:@"image"];

        [actionSheet addAction:recv];
    }

    UIAlertAction*
    spkr = [UIAlertAction actionWithTitle: ICOLLString(@"Call:AudioSource:Speaker")
                                    style: UIAlertActionStyleDefault
                                  handler: ^(UIAlertAction * action)
            {
//                [[AudioManager sharedInstance] setBluetoothInactive];
//                _rtcManager->setLaudspeakerStatus(true);
                IMLogDbg("set PreferredAudioOutput: AudioOutputSpeaker", 0);
                [[AudioManager sharedInstance] setPreferredAudioOutput: AudioOutputSpeaker];
            }];

    if([[AudioManager sharedInstance] isSpeakerCurrentAudioOutput])
        [spkr setValue:[[UIImage sdkImageNamed:@"checkmark"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forKey:@"image"];
    else
        [spkr setValue:nil forKey:@"image"];

    [actionSheet addAction:spkr];

    UIAlertAction* hide = [UIAlertAction
                           actionWithTitle:ICOLLString(@"Call:AudioSource:Hide")
                           style:UIAlertActionStyleCancel
                           handler:^(UIAlertAction * action)
                           {

                           }];

    [actionSheet addAction:hide];

    [self presentViewController:actionSheet animated:YES completion:nil];
}

- (void) goBackToRootViewController
{
    IMLogDbg("Will pop current view controller. %s",
             [[self.navigationController.topViewController description] UTF8String]);
    [self.navigationController popViewControllerAnimated: YES];
}
//
//- (void)chatViewControllerDidClickTrashButton:(ChatViewController*)chatViewController
//{
//    IMLogDbg("Will pop current view controller. %s",
//             [[self.navigationController.topViewController description] UTF8String]);
//    [self.navigationController popViewControllerAnimated: YES];
//}
//
//- (void)chatViewControllerDidClickCameraButton:(ChatViewController *)chatViewController
//{
//    IMLogDbg("Will pop current view controller. %s",
//             [[self.navigationController.topViewController description] UTF8String]);
//    [self.navigationController popViewControllerAnimated: YES];
//}
//
#pragma mark - IBActions

- (IBAction)didClickBackButton:(id)sender
{
    // Need to go back
    NSLog(@"%@", NSStringFromSelector(_cmd));
    [self goBackToRootViewController];
}
//
#pragma mark CallInProgress Methods

- (void)callInProgressView:(CallInProgressView*)view
onRequestVisitorInfoAction:(UIButton*)button
         completionHandler:(void(^)(BOOL succeededSendingRequest))completionHandler
{
    BOOL succeededSendingRequest =  [self.callManager requestVisitorInfo:self.participantId];
    completionHandler(succeededSendingRequest);
}

- ( void )
callInProgressView      :( CallInProgressView*  ) view
onMessageButtonAction   :( UIButton*            ) button
{
    [self messageAction];
}

- ( void )
callInProgressView   :( CallInProgressView* ) view
onCameraButtonAction :( UIButton*           ) button
{
    [self cameraActionWithSender: button];
}

- ( void )
callInProgressView  :( CallInProgressView*  ) view
onMuteButtonAction  :( UIButton*            ) button
{
    [self muteAction:button];
}

- ( void )
callInProgressView      :( CallInProgressView*  )view
onDeclineButtonAction   :( UIButton*            )button
{
    [self hangupAction];
}

- (void)
callInProgressView      :( CallInProgressView* ) view
onSpeakerButtonAction   :( UIButton*           ) button
{
    [self speakerAction:button];
}

#pragma mark - AudioRouteChange
- (void)audioRouteChanged:(NSNotification*)notificaiton
{
    if (![NSThread isMainThread]) {
        IMLogDbg("audioRouteChanged invoked on secondary thread", 0);
    }

    BOOL bluetoothAvailable = [[AudioManager sharedInstance] isBluetoothAvailable];
    [self.callInProgressView setBluetoothAvailable:bluetoothAvailable];

    if (bluetoothAvailable) {
        [self.callInProgressView setSpeakerButtonSelected: NO];
    } else {
        BOOL isSpeakerCurrentAudioOutput = [[AudioManager sharedInstance] isSpeakerCurrentAudioOutput];
        [self.callInProgressView setSpeakerButtonSelected: isSpeakerCurrentAudioOutput];
    }
}
//
//- (void) didEnterBackground:(NSNotification*)notificaiton
//{
//}
//
//- (void) willEnterForeground:(NSNotification*)notificaiton
//{
//}

#pragma mark - VideoViewContainer

- ( void )
removeConstraintsForView: ( UIView* ) view
{
    NSMutableArray* ctr = [NSMutableArray new];

    for (NSLayoutConstraint* lc in view.superview.constraints)
    {
        if (lc.firstItem == view )
            [ctr addObject:lc];
    }

    [view.superview removeConstraints:ctr];
}

- ( void )
setAutolayoutUpperRight
{
    [self.localViewContainer setTranslatesAutoresizingMaskIntoConstraints:NO];

    [self removeConstraintsForView:self.localViewContainer];

    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.localViewContainer
                                                          attribute:NSLayoutAttributeTop
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeTop
                                                         multiplier:1.0
                                                           constant:[[DeviceData instance] isPortrait] ? 30.0 : 10.0]];

    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.localViewContainer
                                                          attribute:NSLayoutAttributeTrailing
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeTrailing
                                                         multiplier:1.0
                                                           constant:-10.0]];

    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.localViewContainer
                                                          attribute:NSLayoutAttributeWidth
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:nil
                                                          attribute:NSLayoutAttributeNotAnAttribute
                                                         multiplier:1.0
                                                           constant:80.0]];

    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.localViewContainer
                                                          attribute:NSLayoutAttributeHeight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:nil
                                                          attribute:NSLayoutAttributeNotAnAttribute
                                                         multiplier:1.0
                                                           constant:100.0]];

    [self.view layoutIfNeeded];
}

- ( void )
setAutolayoutFullScreen
{
    [self.localViewContainer setTranslatesAutoresizingMaskIntoConstraints:NO];

    [self removeConstraintsForView:self.localViewContainer];

    NSLog(@"/nSelf constraints ar: /n%@/n", [self.view constraints]);

    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.localViewContainer
                                                          attribute:NSLayoutAttributeTop
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeTop
                                                         multiplier:1.0
                                                           constant:0.0]];

    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.localViewContainer
                                                          attribute:NSLayoutAttributeLeading
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeLeading
                                                         multiplier:1.0
                                                           constant:0.0]];

    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.localViewContainer
                                                          attribute:NSLayoutAttributeBottom
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeBottom
                                                         multiplier:1.0
                                                           constant:0.0]];

    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.localViewContainer
                                                          attribute:NSLayoutAttributeTrailing
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeTrailing
                                                         multiplier:1.0
                                                           constant:0.0]];

    [self.view layoutIfNeeded];
}

- ( void )
updateVideoUI
{
    if (self.callManager.localVideoTrack && !self.callManager.remoteVideoTrack)
    {
        [self setAutolayoutUpperRight];
    }
    else if (!self.callManager.localVideoTrack && self.callManager.remoteVideoTrack)
    {
    }
    else if (self.callManager.localVideoTrack && self.callManager.remoteVideoTrack)
    {
        [self setAutolayoutUpperRight];
        [self.view insertSubview:self.localViewContainer aboveSubview:self.remoteViewContainer];
    }

    // hide/show no audio devices view
    if (![self.callManager hasStableConnectionForCall: self.callId]) {
        IMLogVbs("ONEWAYAUDIO - !hasStableConnectionForCall", 0);
        [self hideOneWayCallInfo];
    } else if (self.callManager.hasRemoteAudio) {
        IMLogVbs("ONEWAYAUDIO - hasRemoteAudio", 0);
        [self hideOneWayCallInfo];
    } else if (self.callManager.hasRemoteVideo) {
        IMLogVbs("ONEWAYAUDIO - !hasRemoteAudio && hasRemoteVideo", 0);
        [self showOneWayCallWithInfo: ICOLLString(@"VideoScene:Info:OneWayAudio")
                           withMicNA: !self.callManager.hasRemoteAudio
                           withCamNA: !self.callManager.hasRemoteVideo];
    } else {
        IMLogVbs("ONEWAYAUDIO - !hasRemoteAudio && !hasRemoteVideo", 0);
        [self showOneWayCallWithInfo: ICOLLString(@"VideoScene:Info:OneWayAudioVideo")
                           withMicNA: !self.callManager.hasRemoteAudio
                           withCamNA: !self.callManager.hasRemoteVideo];
    }

    if (self.avatarView.image) {
        if (self.oneWayCallView.hidden && !self.callManager.remoteVideoTrack) {
            self.avatarView.hidden = NO;
        } else {
            self.avatarView.hidden = YES;
        }
    }

    if ([self.callManager isVideoRouteValueApplied])
    {
        if (VideoRouteNone == self.callManager.videoRoute)
            self.localViewContainer.alpha = 0;
        else
            self.localViewContainer.alpha = 1;
    }

    // finally show or hide poor network view
    [self updatePoorNetworkView];

    NSLog(@"localVideoView: %@", self.localViewContainer);
    NSLog(@"remoteVideoView: %@", self.remoteViewContainer);
    NSLog(@"view: %@", self.view);
}


#pragma mark - VideoCallManager KVO

- (void)setupVideoTracksListener
{
    NSArray* eventsActions = @[@(instac::IRTCManager::ActionDidReceiveLocalVideoTrack),
                               @(instac::IRTCManager::ActionDidReceiveRemoteVideoTrack),
                               @(instac::IRTCManager::ActionWillRemoveLocalVideoTrack),
                               @(instac::IRTCManager::ActionWillRemoveRemoteVideoTrack),
                               @(instac::IRTCManager::ActionDidReceiveVideoStopped),
                               @(instac::IRTCManager::ActionDidReceiveVideoStarted),
                               @(instac::IRTCManager::ActionDidReceivePoorNetwork),
                               @(instac::IRTCManager::ActionDidReceiveClearPoorNetwork),
                               @(instac::IRTCManager::ActionDidDeterminePoorNetwork),
                               @(instac::IRTCManager::ActionDidDetermineGoodNetwork)];

    __weak typeof(self) weakSelf = self;

    _videoTracksListenerIdentifier =
        [[RtcEventsListener sharedInstance] notifyOnEventActions:eventsActions
                                                         timeout:0
                                               completionHandler:^(instac::RTCEvent *event, BOOL isTimedOut, BOOL *stop)
    {
        if (event->getAction() == instac::IRTCManager::ActionDidReceiveLocalVideoTrack)
        {
            [weakSelf actionDidReceiveLocalVideoTrack:[weakSelf rtcVideoTrackFromVideoTrack:event->getVideoTrack()]];
        }
        else if (event->getAction() == instac::IRTCManager::ActionDidReceiveRemoteVideoTrack)
        {
            [weakSelf actionDidReceiveRemoteVideoTrack:[weakSelf rtcVideoTrackFromVideoTrack:event->getVideoTrack()]];
        }
        else if (event->getAction() == instac::IRTCManager::ActionWillRemoveLocalVideoTrack)
        {
            [weakSelf actionWillRemoveLocalVideoTrack:[weakSelf rtcVideoTrackFromVideoTrack:event->getVideoTrack()]];
        }
        else if (event->getAction() == instac::IRTCManager::ActionWillRemoveRemoteVideoTrack)
        {
            [weakSelf actionWillRemoveRemoteVideoTrack:[weakSelf rtcVideoTrackFromVideoTrack:event->getVideoTrack()]];
        }
        else if (event->getAction() == instac::IRTCManager::ActionDidReceiveVideoStopped)
        {
            [weakSelf actionDidReceiveVideoStopped:event->getCallId()];
        }
        else if (event->getAction() == instac::IRTCManager::ActionDidReceiveVideoStarted)
        {
            [weakSelf actionDidReceiveVideoStarted:event->getCallId()];
        }
        else if (event->getAction() == instac::IRTCManager::ActionDidReceivePoorNetwork)
        {
            [weakSelf actionDidReceivePoorNetwork:event->getCallId()];
        }
        else if (event->getAction() == instac::IRTCManager::ActionDidReceiveClearPoorNetwork)
        {
            [weakSelf actionDidReceiveClearPoorNetwork:event->getCallId()];
        }
        else if (event->getAction() == instac::IRTCManager::ActionDidDeterminePoorNetwork)
        {
            [weakSelf actionDidDeterminePoorNetwork:event->getCallId()];
        }
        else if (event->getAction() == instac::IRTCManager::ActionDidDetermineGoodNetwork)
        {
            [weakSelf actionDidDetermineGoodNetwork:event->getCallId()];
        }

    }];
}

- (void)actionDidReceiveLocalVideoTrack:(RTCVideoTrack*)videoTrack
{
    IMLogDbg("Did receive local video track.", 0);

    [self addLocalRendererToVideoTrack:videoTrack];
    [self updateVideoUI];
}

- (void)actionDidReceiveRemoteVideoTrack:(RTCVideoTrack*)videoTrack
{
    IMLogDbg("Did receive remote video track.", 0);

    [self addRemoteRendererToVideoTrack:videoTrack];
    [self updateVideoUI];
}

- (void)actionWillRemoveLocalVideoTrack:(RTCVideoTrack*)videoTrack
{
    IMLogDbg("Did remove local video track.", 0);

    [self removeLocalRendererFromVideoTrack:videoTrack];
    [self updateVideoUI];
}

- (void)actionWillRemoveRemoteVideoTrack:(RTCVideoTrack*)videoTrack
{
    IMLogDbg("Did remove remote video track.", 0);

    [self removeRemoteRendererFromVideoTrack:videoTrack];
    [self updateVideoUI];
}

- (void)actionDidReceiveVideoStopped: (const instac::String&) callId
{
    if ([self.call.callId isEqualToString: OBJCStringA(callId)])
    {
        self.remoteViewContainer.hidden = YES;
    }
}

- (void)actionDidReceiveVideoStarted: (const instac::String&) callId
{
    if ([self.call.callId isEqualToString: OBJCStringA(callId)])
    {
        self.remoteViewContainer.hidden = NO;
    }
}

- (void)actionDidReceivePoorNetwork: (const instac::String&) callId
{
    self.ntwkQualityFlags |= 0x10;

#if WITH_DISABLE_VIDEO_BUTTON_ON_POOR_NETWORK
    // disable video camera button
    [self.callInProgressView enableCameraButton: NO];
#endif

    // show message poor network
    [self showPoorNetworkView];
}

- (void)actionDidReceiveClearPoorNetwork: (const instac::String&) callId
{
    self.ntwkQualityFlags &= ~(0x10);

    // hide message poor network
    if (self.ntwkQualityFlags == 0)
        [self hidePoorNetworkView];
}

- (void)actionDidDeterminePoorNetwork: (const instac::String&) callId
{
    self.ntwkQualityFlags |= 0x01;

#if WITH_DISABLE_VIDEO_BUTTON_ON_POOR_NETWORK
    // disable video camera button
    [self.callInProgressView enableCameraButton: NO];
#endif

    // show message poor network
    [self showPoorNetworkView];
}

- (void)actionDidDetermineGoodNetwork: (const instac::String&) callId
{
    self.ntwkQualityFlags &= ~(0x01);

    if (self.ntwkQualityFlags == 0)
        [self hidePoorNetworkView];
}

- (RTCVideoTrack*)rtcVideoTrackFromVideoTrack:(void*)videoTrack
{
    RTCVideoTrack* rtcVideoTrack = nil;

    if (videoTrack != NULL)
    {
        rtcVideoTrack = (__bridge RTCVideoTrack*)videoTrack;
    }

    return rtcVideoTrack;
}

#pragma mark - videoCallNotifications

- (void) didEstablishVideoCall: (LSCall*) aCall
                transferCallId:(NSString*)transferCallId
{
    if (![aCall isTransfer])
    {
        [self.callInProgressView stopCallWaitingActivityIndicator];
    }

    if (transferCallId == nil)
    {
        return;
    }

    [aCall setMute:self.call.isMuted];
    _callId = aCall.callId;
    _call = aCall;

    BOOL isMuted = self.callManager.isMuted;
    [aCall setMute:isMuted];
    [self.callManager mute:isMuted];

    if (self.call.answerTime != 0)
    {
        [self.callInProgressView startCallDurationTimerWithStartTime:self.call.answerTime];
    }
}

- (void) videoCallDidEnd
{
    [self.callInProgressView stopCallWaitingActivityIndicator];
//    IMLogDbg("Will popToRootViewControllerAnimated - NO", 0);
//    if (nil != self.navigationController)
//        [self.navigationController popToRootViewControllerAnimated: NO];
    
    [self.parentController removeVideoSceneViewController];
}

- (void) videoCallDidFailWithError: (ErrorCode) code
{
    [self.callInProgressView stopCallWaitingActivityIndicator];

    if (code == E_RtcCallNotFound)
    {
        IMLogDbg("code accept failed with error code E_RtcCallNotFound", 0);
        IMLogDbg("Will popToRootViewControllerAnimated - NO", 0);
        if (nil != self.navigationController)
            [self.navigationController popToRootViewControllerAnimated: NO];
    }
}
//
//- (void) videoCallDidStartDialing
//{
//    //####
//}
//
- (void) didEstablishChatCall: (LSCall*) aCall
{
}

- (void)showChatViewController
{
    //TODO: SHOW CHATVIEW
    [self.parentController startChat];
//    LSParticipant* participant = [self.callManager participantWithId:self.participantId];
//
//    if (participant == nil)
//    {
//        return;
//    }
//
//    ChatViewController* vc = (ChatViewController*)[[UIStoryboard storyboardWithName:@"Leadsecure" bundle:nil]
//                                                   instantiateViewControllerWithIdentifier:@"ChatViewController"];
//    [vc setParticipantId: self.participantId];
//    vc.delegate = self;
//    [self.navigationController pushViewController:vc animated:YES];
}

- (void) chatCallDidEnd: (LSCall*) aCall
{
}

- (void) didChangeVideoCallState: (NSNotification*) aNotification
{
    IMLogDbg("%s", __FUNCTION__);

    NSDictionary* userInfo = [aNotification userInfo];
    if (nil != userInfo)
    {
        NSString* videoCallState = [userInfo objectForKey: kVideoCallManagerActiveVideoCallStateKey];
        if (nil != videoCallState)
        {
            if ([videoCallState isEqualToString: kVideoCallManagerActiveVideoCallStateEstablished])
            {
                IMLogDbg("handle kVideoCallManagerActiveVideoCallStateEstablished", 0);
                LSCall* call = [userInfo objectForKey: kVideoCallManagerActiveVideoCallKey];
                NSString* transferCallId = [userInfo objectForKey:kVideoCallManagerTransferVideoCallKey];
                [self didEstablishVideoCall: call
                             transferCallId:transferCallId];
            }
            else if ([videoCallState isEqualToString: kVideoCallManagerActiveVideoCallStateEnded])
            {
                IMLogDbg("handle kVideoCallManagerActiveVideoCallStateEnded", 0);
                NSString* callId = userInfo[kVideoCallManagerActiveVideoCallIdKey];

                if ([callId isEqualToString:self.callId])
                {
                    [self videoCallDidEnd];
                }
                else
                {
                    IMLogDbg("Video call did end for call which is not current for the video scene.", 0);
                }
            }
            else if ([videoCallState isEqualToString: kVideoCallManagerActiveVideoCallStateFailed])
            {
                IMLogDbg("handle kVideoCallManagerActiveVideoCallStateFailed", 0);
                NSNumber* videoCallError = [userInfo objectForKey: kVideoCallManagerActiveVideoCallStateErrorKey];
                ErrorCode code = (ErrorCode) [videoCallError unsignedLongValue];

                [self videoCallDidFailWithError: code];
            }
        }
    }
}

- (void) didChangeChatCallState: (NSNotification*) aNotification
{
    NSDictionary* userInfo = [aNotification userInfo];
    if (nil != userInfo)
    {
        NSString* chatCallState = [userInfo objectForKey: kVideoCallManagerActiveChatCallStateKey];
        if (nil != chatCallState)
        {
            if ([chatCallState isEqualToString: kVideoCallManagerActiveChatCallStateEstablished])
            {
                LSCall* call = [userInfo objectForKey: kVideoCallManagerActiveChatCallKey];
                [self didEstablishChatCall: call];
            }
            else if ([chatCallState isEqualToString: kVideoCallManagerActiveVideoCallStateEnded])
            {
                LSCall* call = [userInfo objectForKey: kVideoCallManagerActiveChatCallKey];
                [self chatCallDidEnd: call];
            }
        }
    }
}

- (void) visitorDidBecomeInactive: (NSNotification*) aNotification
{
    NSDictionary* userInfo = [aNotification userInfo];
    LSParticipant* visitor = [userInfo objectForKey: kVideoCallManagerVisitorKey];

    if ([[visitor visitorId] isEqualToString:self.participantId])
    {

    }
}

- (void)didReceiveCallAnswerTime:(NSNotification*)notification
{
    NSString* callId = [[notification userInfo] objectForKey:kCallIdKey];

    if (![callId isEqualToString:self.call.callId])
    {
        return;
    }

    if (![self.call isTransfer])
    {
        [self.callInProgressView startCallDurationTimerWithStartTime:self.call.answerTime];
    }
}

- (void)didSetVideoRoute:(NSNotification*)notification
{
    NSString* callId = [[notification userInfo] objectForKey:kCallIdKey];

    if ((callId != nil) && (![callId isEqualToString:self.call.callId]))
    {
        return;
    }

    [self updateVideoUI];
}

- (void)visitorDidUpdate:(NSNotification*)notification
{
    LSParticipant* visitor = [[notification userInfo] objectForKey:kVideoCallManagerVisitorKey];

    if ([[visitor visitorId] isEqualToString:self.participantId])
    {
        Contact* contact = [self currentContact];
        [self.callInProgressView showContactInfoForContact:contact];
        [self.callInProgressView showContactInfo];

//        if (contact)
//        {
//            [self.navigationItem setTitle:contact.name];
//        }
    }
}

- (void)participantAvailabilityChanged:(NSNotification*)notification
{
    LSParticipant* participant = [[notification userInfo] objectForKey:kParticipantAvailabilityChangedParticipantKey];

    if ([[participant identifier] isEqualToString:self.participantId])
    {
        Contact* contact = [self currentContact];
        [self.callInProgressView showContactInfoForContact:contact];
        [self.callInProgressView showContactInfo];

//        if (contact)
//        {
//            [self.navigationItem setTitle:contact.name];
//        }
    }
}
//
//+ (id)loadNibNamed:(NSString*)nibName
//           ofClass:(Class)objClass
//             owner:(id)owner
//{
//    NSArray* nibObjects = [[NSBundle mainBundle] loadNibNamed:nibName
//                                                        owner:owner
//                                                      options:nil];
//
//    for (id nibObject in nibObjects)
//    {
//        if ([nibObject isKindOfClass:objClass])
//        {
//            return nibObject;
//        }
//    }
//
//    return nil;
//}

- (void)addLocalRendererToVideoTrack:(RTCVideoTrack*)videoTrack
{
    IMLogDbg("addLocalRendererToVideoTrack", 0);

    if ((self.localViewContainer.rtcVideoView) &&
        (videoTrack != nil) &&
        (![self containsLocalVideoTrack:videoTrack]))
    {
        [self addLocalVideoTrack:videoTrack];
        [videoTrack addRenderer:self.localViewContainer.rtcVideoView];
        [self.localViewContainer resumeRenderer];

        self.localViewContainer.hidden = NO;

        IMLogDbg("addLocalRendererToVideoTrack, added local video track, count %ld, ptr %p", _localVideoTracks.count, videoTrack);
    }
    else
    {
        IMLogDbg("addLocalRendererToVideoTrack, local video track already added, count %ld, ptr %p", _localVideoTracks.count, videoTrack);
    }
}

- (void)removeLocalRendererFromVideoTrack:(RTCVideoTrack*)videoTrack
{
    IMLogDbg("removeLocalRendererFromVideoTrack", 0);

    if ((self.localViewContainer.rtcVideoView) &&
        (videoTrack) &&
        ([self containsLocalVideoTrack:videoTrack]))
    {
        [self removeLocalVideoTrack:videoTrack];
        self.localViewContainer.hidden = YES;
        [self.localViewContainer pauseRenderer];
        [videoTrack removeRenderer:self.localViewContainer.rtcVideoView];

        IMLogDbg("removeLocalRendererFromVideoTrack, removed local video track, count %ld, ptr %p", _localVideoTracks.count, videoTrack);
    }
    else
    {
        IMLogDbg("removeLocalRendererFromVideoTrack, does not contain local video track, count %ld, ptr %p", _localVideoTracks.count, videoTrack);
    }
}

- (void)addRemoteRendererToVideoTrack:(RTCVideoTrack*)videoTrack
{
    if (!self.remoteViewContainer.rtcVideoView) {
        IMLogDbg("addRemoteRendererToVideoTrack - rtcVideoView is null", 0);
        return;
    }

    if (nil == videoTrack) {
        IMLogDbg("addRemoteRendererToVideoTrack - videoTrack is null", 0);
        return;
    }

    if ([self containsRemoteVideoTrack:videoTrack]) {
        IMLogDbg("addRemoteRendererToVideoTrack, videoTrack already added, count %ld, ptr %p", _remoteVideoTracks.count, videoTrack);
        return;
    }

    [self addRemoteVideoTrack:videoTrack];
    [videoTrack addRenderer:self.remoteViewContainer.rtcVideoView];
    [self.remoteViewContainer resumeRenderer];

    self.remoteViewContainer.hidden = NO;

    IMLogDbg("addRemoteRendererToVideoTrack, videoTrack added, count %ld, ptr %p", _remoteVideoTracks.count, videoTrack);
}

- (void)removeRemoteRendererFromVideoTrack:(RTCVideoTrack*)videoTrack
{
    if (!self.remoteViewContainer.rtcVideoView) {
        IMLogDbg("removeRemoteRendererFromVideoTrack - rtcVideoView is null", 0);
        return;
    }

    if (nil == videoTrack) {
        IMLogDbg("removeRemoteRendererFromVideoTrack - videoTrack is null", 0);
        return;
    }

    if (![self containsRemoteVideoTrack:videoTrack])
    {
        IMLogDbg("removeRemoteRendererFromVideoTrack, does not contain remote video track, count %ld, ptr %p", _remoteVideoTracks.count, videoTrack);
        return;
    }

    [videoTrack removeRenderer:self.remoteViewContainer.rtcVideoView];
    [self removeRemoteVideoTrack:videoTrack];

    if (0 == _remoteVideoTracks.count) {
        self.remoteViewContainer.hidden = YES;
        [self.remoteViewContainer pauseRenderer];
    }

    IMLogDbg("removeRemoteRendererFromVideoTrack, removed remote video track, count %ld, ptr %p", _remoteVideoTracks.count, videoTrack);
}

- (BOOL)containsLocalVideoTrack:(RTCVideoTrack*)videoTrack
{
    return [_localVideoTracks containsObject:videoTrack];
}

- (BOOL)containsRemoteVideoTrack:(RTCVideoTrack*)videoTrack
{
    return [_remoteVideoTracks containsObject:videoTrack];
}

- (void)addLocalVideoTrack:(RTCVideoTrack*)videoTrack
{
    [_localVideoTracks addObject:videoTrack];
}

- (void)removeLocalVideoTrack:(RTCVideoTrack*)videoTrack
{
    [_localVideoTracks removeObject:videoTrack];
}

- (void)addRemoteVideoTrack:(RTCVideoTrack*)videoTrack
{
    [_remoteVideoTracks addObject:videoTrack];
}

- (void)removeRemoteVideoTrack:(RTCVideoTrack*)videoTrack
{
    [_remoteVideoTracks removeObject:videoTrack];
}
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
//        instac::RefCountPtr<instac::IParticipant> participant = _rtcManager->participantWithId(self.participantId.UTF8String);
//
//        if (participant.get() != NULL) {
//            std::vector<instac::RefCountPtr<instac::ICall>> activeCalls = participant->activeChatCalls();
//            if(activeCalls.size() == 0 )
//                activeCalls = participant->activeVideoCalls();
//
//            if (activeCalls.size() > 0) {
//
//                ErrorCode errCode = E_Failed;
//
//                activeCalls[0]->callId();
//
//                if(controller.withVideo)
//                    errCode = _rtcManager->transferCall(activeCalls[0]->callId(), [recipient.identifier UTF8String], !recipient.isIndividal);
//                else
//                    errCode = _rtcManager->transferChat(activeCalls[0]->callId(), [recipient.identifier UTF8String], !recipient.isIndividal);
//
//                if (S_Ok == errCode)
//                {
//                    [self showChatViewController];
//                }
//            }
//        }
//    }];
//}
//
//#pragma mark - UIPopoverControllerDelegate methods
//
//- (UIModalPresentationStyle) adaptivePresentationStyleForPresentationController: (UIPresentationController * ) controller {
//
//    return UIModalPresentationNone;
//}
//
//- (void)popoverPresentationControllerDidDismissPopover:(UIPopoverPresentationController *)popoverPresentationController {
//
//    self.popOverPresController.delegate = nil;
//    self.popOverPresController = nil;
//}
//
@end


@implementation PoorNetrworkLabel

- (CGSize) intrinsicContentSize {
    CGSize ics = [super intrinsicContentSize];
    ics.width += 10;
    ics.height += 10;

    return ics;
}

@end

