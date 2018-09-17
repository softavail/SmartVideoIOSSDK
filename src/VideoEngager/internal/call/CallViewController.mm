//
//  CallViewController.m
//  leadsecure
//
//  Created by Vladimir Savov on 29.11.15 г..
//  Copyright © 2015 г. SoftAvail. All rights reserved.
//

#import "CallViewController.h"

#import "ParticipantInfoView.h"
#import "TimeUtils.h"
#import "UIUtils.h"
#import "PureLayout.h"
#import "ICOLLAlertController.h"

@interface CallViewController ()

@property (nonatomic, weak) IBOutlet UILabel *callerLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *callerInfoCallerLabelVerticalConstraint;

@property (nonatomic, weak) IBOutlet UIView *ringingContainer;
@property (weak, nonatomic) IBOutlet UILabel *answerLabel;
@property (weak, nonatomic) IBOutlet UILabel *declineLabel;

@property (nonatomic, weak) IBOutlet UIView *dialingContainer;
@property (weak, nonatomic) IBOutlet UILabel *hangupLabel;

@property (nonatomic, weak) IBOutlet UIView *duringCallContainer;
@property (weak, nonatomic) IBOutlet UILabel *holdAndAnswerLabel;
@property (weak, nonatomic) IBOutlet UILabel *endAndAnswerLabel;
@property (weak, nonatomic) IBOutlet UILabel *declineCallRingiingLabel;

@property (weak, nonatomic) IBOutlet UIView *participantInfoContainer;


@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *activityIndicator;

@property NSTimer* timeElapsedTimer;

@end

@implementation CallViewController
{
    CallViewControllerType _type;
    LSCall* _call;
    LSParticipant* _participant;
    ParticipantInfoView* _participantInfoView;

    BOOL _didSetConstraints;
    
}

#pragma mark - Accessor methods

- (void)setType:(CallViewControllerType)type {

    [self willChangeValueForKey:@"type"];
    _type = type;
    [self didChangeValueForKey:@"type"];

    [self updateUIForType];
}

- (void) decline {

    IMLogDbg("[UX] %s", __FUNCTION__);

    [self setupLoadingState];

    if (self.delegate && [self.delegate respondsToSelector:@selector(callViewController:pressedDeclineWithCompletion:)]) {
        __weak typeof(self) weakSelf = self;

        [self.delegate callViewController:self pressedDeclineWithCompletion:^(BOOL success) {
            [weakSelf handleCompletionWithSuccess:success andAlertMessage:ICOLLString(@"Failed to decline call!")];
        }];
    }
}

#pragma mark - Action methods

- (IBAction)hangUpPressed:(UIButton *)sender {

    IMLogDbg("[UX] %s", __FUNCTION__);

    [self setupLoadingState];

    if (self.delegate && [self.delegate respondsToSelector:@selector(callViewControllerDidPressHangup:)]) {
        [self.delegate callViewControllerDidPressHangup:self];
    }
}

- (IBAction)answerPressed:(UIButton *)sender {

    IMLogDbg("[UX] %s", __FUNCTION__);

    [self setupLoadingState];

    if (self.delegate && [self.delegate respondsToSelector:@selector(callViewControllerDidPressAnswer:)])
    {
        [self.delegate callViewControllerDidPressAnswer:self];
    }
}

- (IBAction)declinePressed:(UIButton *)sender {

    [self decline];
}

- (IBAction)holdAndAcceptPressed:(UIButton *)sender {

    IMLogDbg("[UX] %s", __FUNCTION__);

//    [self setupLoadingState];
//
//    if (self.delegate && [self.delegate respondsToSelector:@selector(callViewController:pressedHoldAndAnswerWithCompletion:)]) {
//        __weak typeof(self) weakSelf = self;
//
//        [self.delegate callViewController:self pressedHoldAndAnswerWithCompletion:^(BOOL success) {
//            [weakSelf handleCompletionWithSuccess:success andAlertMessage:ICOLLString(@"Failed to hold the call and answer the new one!")];
//        }];
//    }
}

- (IBAction)endAndAcceptPressed:(UIButton *)sender {

    IMLogDbg("[UX] %s", __FUNCTION__);

//    [self setupLoadingState];
//
//    if (self.delegate && [self.delegate respondsToSelector:@selector(callViewController:pressedEndAndAnswerWithCompletion:)]) {
//        __weak typeof(self) weakSelf = self;
//
//        [self.delegate callViewController:self pressedEndAndAnswerWithCompletion:^(BOOL success) {
//            [weakSelf handleCompletionWithSuccess:success andAlertMessage:ICOLLString(@"Failed to end the call and answer the new one!")];
//        }];
//    }
}

// Call ringing during active call
- (IBAction)declineCallRingingPressed:(id)sender {

    [self decline];
}

#pragma mark - Initialization methods

- (instancetype)initWithType:(CallViewControllerType)type andCall:(LSCall*)call {

    self = [self initWithNibName:NSStringFromClass([self class])
                          bundle:[NSBundle bundleForClass: [self class]]];

    if (self) {
        _type = type;
        _call = call;
    }

    return self;
}

- (void)dealloc
{
    IMLogDbg("dealloc - %s", self.description.UTF8String);
}


- (void)dismissViewControllerAnimated:(BOOL)flag completion:(void (^)())completion
{
    [self killAllTimers];

    [super dismissViewControllerAnimated:flag completion:completion];
}

#pragma mark - View lifecycle methods

- (void)viewDidLoad {

    [super viewDidLoad];

    IMLogVbs("viewDidLoad %s", self.description.UTF8String);

    [self updateUIForType];
    [self updateUIForContact];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    IMLogVbs("viewWillAppear %s", self.description.UTF8String);
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

    IMLogVbs("viewWillDisappear %s", self.description.UTF8String);

}

- (void)didReceiveMemoryWarning {

    [super didReceiveMemoryWarning];
}

#pragma amrk - Private methods

- (void)updateUIForType {

    switch (self.type) {
        case CallViewControllerTypeDialing:
            self.ringingContainer.hidden = YES;
            self.dialingContainer.hidden = NO;
            self.duringCallContainer.hidden = YES;
            self.hangupLabel.text = ICOLLString(@"Hang Up");

            break;
        case CallViewControllerTypeRinging:
            self.ringingContainer.hidden = NO;
            self.dialingContainer.hidden = YES;
            self.duringCallContainer.hidden = YES;
            self.answerLabel.text = ICOLLString(@"Answer");
            self.declineLabel.text = ICOLLString(@"Decline");

            break;
        case CallViewControllerTypeRingingDuringCall:
            self.ringingContainer.hidden = YES;
            self.dialingContainer.hidden = YES;
            self.duringCallContainer.hidden = NO;
            self.holdAndAnswerLabel.text = ICOLLString(@"Hold & Answer");
            self.endAndAnswerLabel.text = ICOLLString(@"End & Answer");
            self.declineCallRingiingLabel.text = ICOLLString(@"Decline");

            break;
        default:
            self.ringingContainer.hidden = YES;
            self.dialingContainer.hidden = YES;
            self.duringCallContainer.hidden = YES;

            break;
    }
}

- (void)updateUIForContact {

    if (self.delegate && [self.delegate respondsToSelector:@selector(callViewController:participantInCall:)]) {

        _participant = [self.delegate callViewController:self participantInCall:self.call];

        NSString* callerName = @"Caller";

        if ((_participant != nil) &&
            ([_participant name]) &&
            [_participant name].length > 0)
        {
            callerName = [_participant name];
        }

        self.callerLabel.text = callerName;

        [self setupParticipantInfoViewWithParticipant:_participant];

        self.timeElapsedTimer = [NSTimer scheduledTimerWithTimeInterval:1
                                                             target:self
                                                           selector:@selector(updateElapsedTime:)
                                                           userInfo:nil
                                                            repeats:YES];
    }
}

- (void)setupLoadingState {

    self.ringingContainer.hidden = YES;
    self.dialingContainer.hidden = YES;
    self.duringCallContainer.hidden = YES;

    [self.activityIndicator startAnimating];
}

- (void)handleCompletionWithSuccess:(BOOL)success andAlertMessage:(NSString *)alertMessage {

    [self.activityIndicator stopAnimating];

    if (success) {
        IMLogDbg("Will dismiss callViewController", 0);
        [self dismissViewControllerAnimated:YES completion:^{
            IMLogDbg("Did dismiss callViewController", 0);
        }];
    } else {

        ICOLLAlertController *alertController = [ICOLLAlertController alertControllerWithTitle:ICOLLString(@"Alert:Error")
                                                                                 message:alertMessage
                                                                          preferredStyle:UIAlertControllerStyleAlert];

        UIAlertAction *okAction = [UIAlertAction actionWithTitle:ICOLLString(@"Alert:Ok")
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * _Nonnull action) {
                                                             IMLogDbg("Will dismiss callViewController", 0);
                                                             [self dismissViewControllerAnimated:YES completion:^{
                                                                 IMLogDbg("Did dismiss callViewController", 0);
                                                             }];
                                                         }];

        [alertController addAction:okAction];

        [self presentViewController:alertController animated:YES completion:nil];
    }
}

- (void)updateElapsedTime:(NSTimer*)timer
{
    NSString* viewingValue = [TimeUtils timeElapsedStringFromTitle:[_participant title] updatedAt:[_participant updatedAt]];
    [_participantInfoView updateValueWithText:viewingValue forTitle:@"Viewing"];
}

- (void)setupParticipantInfoViewWithParticipant:(LSParticipant*)participant
{
    NSMutableArray<ParticipantInfoItem*>* participantInfoItems = [[NSMutableArray alloc] init];

    if (([participant email]) && ([participant email].length > 0))
    {
        [participantInfoItems addObject:[[ParticipantInfoItem alloc] initWithTitle:@"Email"
                                                                             value:[participant email]]];
    }

    if (([participant telephone]) && ([participant telephone].length > 0))
    {
        [participantInfoItems addObject:[[ParticipantInfoItem alloc] initWithTitle:@"Phone"
                                                                             value:[participant telephone]]];
    }

    if (([participant location]) && ([participant location].length > 0))
    {
        [participantInfoItems addObject:[[ParticipantInfoItem alloc] initWithTitle:@"Location"
                                                                             value:[participant location]]];
    }

    if (([participant title]) && ([participant title].length > 0))
    {
        NSString* title = [TimeUtils timeElapsedStringFromTitle:[participant title] updatedAt:[participant updatedAt]];
        [participantInfoItems addObject:[[ParticipantInfoItem alloc] initWithTitle:@"Viewing"
                                                                             value:title]];
    }

    _participantInfoView = [[ParticipantInfoView alloc] initWithParticipantInfoItems:participantInfoItems];
    [_participantInfoContainer addSubview:_participantInfoView];

    [self.view setNeedsUpdateConstraints];
}

- (void)updateViewConstraints
{
    [super updateViewConstraints];

    if (!_didSetConstraints)
    {
        [_participantInfoView autoPinEdgesToSuperviewEdges];

        _didSetConstraints = YES;
    }
}

- (void)willTransitionToTraitCollection:(UITraitCollection *)newCollection withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [super willTransitionToTraitCollection:newCollection withTransitionCoordinator:coordinator];

    if ([UIUtils isIphone5Screen])
    {
        CGFloat verticalDistance = 0.0;

        if (newCollection.verticalSizeClass == UIUserInterfaceSizeClassRegular)
        {
            self.callerLabel.font = [UIFont systemFontOfSize:40 weight:UIFontWeightRegular];
            verticalDistance = 20.0;
        }
        else if (newCollection.verticalSizeClass == UIUserInterfaceSizeClassCompact)
        {
            self.callerLabel.font = [UIFont systemFontOfSize:21 weight:UIFontWeightRegular];
            verticalDistance = 6.0;
        }

        self.callerInfoCallerLabelVerticalConstraint.constant = verticalDistance;
    }

    [_participantInfoView willTransitionToTraitCollection:newCollection];
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
}

#pragma mark - private helpers

- (void) killTimerElapsed
{
    if ([self.timeElapsedTimer isValid])
        [self.timeElapsedTimer invalidate];

    self.timeElapsedTimer = nil;
}

#pragma mark - Interface

- (void)killAllTimers
{
    [self killTimerElapsed];
}

@end
