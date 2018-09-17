//
//  CallInProgressView.m
//  instac
//
//  Created by Bozhko Terziev on 12/4/14.
//  Copyright (c) 2014 SoftAvail. All rights reserved.
//

#import "CallInProgressView.h"

#import "PureLayout.h"
#import "UIColor+Additions.h"
#import "UIImage+Additions.h"

@interface MyImgView : UIImageView

@end

@implementation MyImgView

- ( void )
roundMe
{
    self.layer.masksToBounds = YES;
    self.layer.cornerRadius = CGRectGetWidth(self.bounds)/2;
    self.contentMode = UIViewContentModeScaleAspectFill;
    self.layer.borderWidth = 1.0f;
    self.layer.borderColor = [[UIColor whiteColor] CGColor];
}

- ( void )
layoutSubviews
{
    [super layoutSubviews];
    
    [self roundMe];
}

@end

@interface CallInProgressView ()

@property (weak, nonatomic) IBOutlet UILabel *labelName;
@property (weak, nonatomic) IBOutlet UILabel *labelEmail;
@property (weak, nonatomic) IBOutlet UILabel *labelPhone;
@property (weak, nonatomic) IBOutlet UIButton *requestVisitorInfoButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *requestVisitorActivityIndicator;


@property (weak, nonatomic) IBOutlet UILabel *labelTotal;

@property (weak, nonatomic) IBOutlet UIView *viewContactInfo;
@property (weak, nonatomic) IBOutlet UIView *viewStars;
@property (weak, nonatomic) IBOutlet UIView *viewButtonOptions;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *callWaitingActivityIndicator;
@property (weak, nonatomic) IBOutlet UIButton *buttonDecline;
@property (weak, nonatomic) IBOutlet UIButton *buttonMessage;
@property (weak, nonatomic) IBOutlet UIButton *buttonCamera;
@property (weak, nonatomic) IBOutlet UIButton *buttonMute;
@property (weak, nonatomic) IBOutlet UIButton *buttonSpeaker;
@property (weak, nonatomic) IBOutlet MyImgView *userAvatarImageView;

@property (nonatomic, strong) NSTimer* callDurationTimer;
@property (nonatomic, strong) NSTimer* controlsTimer;

@property (nonatomic, assign) BOOL controlsHidden;

- (IBAction)messageAction:(UIButton*)sender;
- (IBAction)cameraAction:(UIButton *)sender;
- (IBAction)muteAction:(UIButton *)sender;
- (IBAction)declineAction:(UIButton *)sender;
- (IBAction)speakerAction:(UIButton *)sender;


@end

@implementation CallInProgressView
{
    NSTimeInterval _callStartTime;
    BOOL _didSetConstraints;
}

- (void)
awakeFromNib
{
    [super awakeFromNib];

    self.requestVisitorInfoButton.titleLabel.font = [UIFont systemFontOfSize:CONTACT_INFO_NAME_LABEL_FONT_SIZE weight:UIFontWeightRegular];
    self.requestVisitorInfoButton.titleLabel.textColor = [UIColor contactInfoLightLabelsColor];
    self.requestVisitorInfoButton.layer.borderColor = [[UIColor whiteColor] CGColor];
    self.requestVisitorInfoButton.layer.borderWidth = 1.0;
    self.requestVisitorInfoButton.layer.cornerRadius = 10.0;

    self.requestVisitorActivityIndicator.hidden = YES;

    self.labelName.font         = [UIFont systemFontOfSize:CONTACT_INFO_PHONE_LABEL_FONT_SIZE weight:UIFontWeightRegular];
    self.labelName.textColor    = [UIColor contactInfoLightLabelsColor];

    self.labelEmail.font        = [UIFont systemFontOfSize:CONTACT_INFO_PHONE_LABEL_FONT_SIZE weight:UIFontWeightLight];
    self.labelEmail.textColor   = [UIColor contactInfoLightLabelsColor];

    self.labelPhone.font        = [UIFont systemFontOfSize:CONTACT_INFO_PHONE_LABEL_FONT_SIZE weight:UIFontWeightLight];
    self.labelPhone.textColor   = [UIColor contactInfoLightLabelsColor];

    self.labelTotal.font        = [UIFont systemFontOfSize:CONTACT_INFO_PHONE_LABEL_FONT_SIZE weight:UIFontWeightLight];
    self.labelTotal.textColor   = [UIColor loginLabelColor];

    self.viewContactInfo.backgroundColor = [UIColor contactInfoViewColor];

    [self.buttonMessage setBackgroundImage:[UIImage sdkImageNamed:@"imageRoundMessage"] forState:UIControlStateNormal];
    [self.buttonMessage setBackgroundImage:[UIImage sdkImageNamed:@"imageRoundMessagePress"] forState:UIControlStateSelected];
    [self.buttonMessage setBackgroundImage:[UIImage sdkImageNamed:@"imageRoundMessagePress"] forState:UIControlStateHighlighted];
    [self.buttonMessage setBackgroundImage:[UIImage sdkImageNamed:@"imageRoundMessage"] forState:UIControlStateDisabled];

    [self.buttonCamera setBackgroundImage:[UIImage sdkImageNamed:@"imageRoundCamera"] forState:UIControlStateNormal];
    [self.buttonCamera setBackgroundImage:[UIImage sdkImageNamed:@"imageRoundCameraPress"] forState:UIControlStateSelected];
    [self.buttonCamera setBackgroundImage:[UIImage sdkImageNamed:@"imageRoundCameraPress"] forState:UIControlStateHighlighted];
    [self.buttonCamera setBackgroundImage:[UIImage sdkImageNamed:@"imageRoundCamera"] forState:UIControlStateDisabled];

    [self.buttonMute setBackgroundImage:[UIImage sdkImageNamed:@"imageRoundMute"] forState:UIControlStateNormal];
    [self.buttonMute setBackgroundImage:[UIImage sdkImageNamed:@"imageRoundMutePress"] forState:UIControlStateSelected];
    [self.buttonMute setBackgroundImage:[UIImage sdkImageNamed:@"imageRoundMutePress"] forState:UIControlStateHighlighted];
    [self.buttonMute setBackgroundImage:[UIImage sdkImageNamed:@"imageRoundMute"] forState:UIControlStateDisabled];

    [self.buttonSpeaker setBackgroundImage:[UIImage sdkImageNamed:@"imageRoundSpeaker"] forState:UIControlStateNormal];
    [self.buttonSpeaker setBackgroundImage:[UIImage sdkImageNamed:@"imageRoundSpeakerPress"] forState:UIControlStateSelected];
    [self.buttonSpeaker setBackgroundImage:[UIImage sdkImageNamed:@"imageRoundSpeakerPress"] forState:UIControlStateHighlighted];
    [self.buttonSpeaker setBackgroundImage:[UIImage sdkImageNamed:@"imageRoundSpeaker"] forState:UIControlStateDisabled];

    [self addTapRecognizer];
}

- (void)updateConstraints
{
    if (self.callsOnHoldView)
    {
        if (!_didSetConstraints)
        {
            [self.callsOnHoldView autoPinEdgesToSuperviewEdges];
            _didSetConstraints = YES;
        }
    }

    [super updateConstraints];
}

- ( void )
layoutSubviews
{
    [super layoutSubviews];
}

- ( void )
dealloc
{
    IMLogDbg("deallocated - %s", self.description.UTF8String);

    [self stopCallDurationTimer];
}

#pragma mark - Gesture Recognizer

- ( void )
addTapRecognizer
{
    UITapGestureRecognizer* tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                    action:@selector(toggleControls:)];
    [self addGestureRecognizer:tapRecognizer];
}

#pragma mark - Timers

- ( void )
startControlsTimer
{
    self.controlsTimer = [NSTimer scheduledTimerWithTimeInterval:5.0
                                                          target:self
                                                        selector:@selector(hideControls)
                                                        userInfo:nil
                                                         repeats:NO];
}

- ( void )
startCallDurationTimerWithStartTime:(NSTimeInterval)callStartTime
{
    if (callStartTime != 0)
    {
        if (![self hasCallDurationTimerRunning])
        {
            [self scheduleTimer:callStartTime];
        }
    }
}

- (void)startCallWaitingActivityIndicator
{
    self.callWaitingActivityIndicator.hidden = NO;
    [self.callWaitingActivityIndicator startAnimating];
}

- (void)stopCallWaitingActivityIndicator
{
    self.callWaitingActivityIndicator.hidden = YES;
    [self.callWaitingActivityIndicator stopAnimating];
}

- (void)scheduleTimer:(NSTimeInterval)callStartTime
{
    if (self.callDurationTimer)
    {
        return;
    }

    _callStartTime = callStartTime;

    self.callDurationTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                              target:self
                                                            selector:@selector(updateDurationLabel)
                                                            userInfo:nil
                                                             repeats:YES];
}

- ( void )
stopControlsTimer
{
    [self.controlsTimer invalidate];
    self.controlsTimer = nil;
}

- (BOOL)hasCallDurationTimerRunning
{
    return self.callDurationTimer != nil;
}

- ( void )
stopCallDurationTimer
{
    [self.callDurationTimer invalidate];
    self.callDurationTimer = nil;
}

- ( void )
setBluetoothAvailable: (BOOL) bluetoothAvailable
{
    if (bluetoothAvailable)
    {
        [self.buttonSpeaker setBackgroundImage:[UIImage sdkImageNamed:@"imageRoundBluetooth"] forState:UIControlStateNormal];
        [self.buttonSpeaker setBackgroundImage:[UIImage sdkImageNamed:@"imageRoundBluetoothPress"] forState:UIControlStateSelected];
        [self.buttonSpeaker setBackgroundImage:[UIImage sdkImageNamed:@"imageRoundBluetoothPress"] forState:UIControlStateHighlighted];
        [self.buttonSpeaker setBackgroundImage:[UIImage sdkImageNamed:@"imageRoundBluetooth"] forState:UIControlStateDisabled];
    }
    else
    {
        [self.buttonSpeaker setBackgroundImage:[UIImage sdkImageNamed:@"imageRoundSpeaker"] forState:UIControlStateNormal];
        [self.buttonSpeaker setBackgroundImage:[UIImage sdkImageNamed:@"imageRoundSpeakerPress"] forState:UIControlStateSelected];
        [self.buttonSpeaker setBackgroundImage:[UIImage sdkImageNamed:@"imageRoundSpeakerPress"] forState:UIControlStateHighlighted];
        [self.buttonSpeaker setBackgroundImage:[UIImage sdkImageNamed:@"imageRoundSpeaker"] forState:UIControlStateDisabled];
    }
}

- ( void )
setMuteButtonSelected: (BOOL) selected
{
    if (self.buttonMute.isSelected != selected)
    {
        [self.buttonMute setSelected:selected];
    }
}

- ( void )
setSpeakerButtonSelected: (BOOL) selected
{
    if (self.buttonSpeaker.isSelected != selected)
    {
        [self.buttonSpeaker setSelected:selected];
    }
}

#pragma mark - Helper Methods

- ( void )
showContactInfoForContact:( Contact* ) contact
{
    if (self.isAgent)
    {
        [self showContactLoggedInAsAgent:contact];
    }
    else
    {
        [self showContactWhenLoggedInAsProspect:contact];
    }
}

- (void)showContactLoggedInAsAgent:(Contact*)contact
{
    if (([contact.email isEqualToString:@""]) &&
        ([contact.phone isEqualToString:@""]))
    {
        [self setupRequestInfoButton];
    }
    else
    {
        [self setupContactInfoForContact:contact];
    }

    if ([self.requestVisitorActivityIndicator isAnimating])
    {
        [self.requestVisitorActivityIndicator stopAnimating];
    }

    self.requestVisitorActivityIndicator.hidden = YES;

    [self customizeStarsViewForRating:contact.rating];
}

- (void)setupRequestInfoButton
{
    self.requestVisitorInfoButton.titleLabel.text = ICOLLString(@"Call:RequestVisitorInfo:Button");

    self.requestVisitorInfoButton.hidden = NO;
    self.labelName.hidden = YES;
    self.labelEmail.hidden = YES;
    self.labelPhone.hidden = YES;
}

- (void)setupContactInfoForContact:(Contact*)contact
{
    self.labelName.text           = contact.name;
    self.labelEmail.text          = [NSString stringWithFormat:@"%@ %@", ICOLLString(@"Call:Title:Email"), contact.email];
    self.labelPhone.text          = [NSString stringWithFormat:@"%@ %@", ICOLLString(@"Call:Title:Phone"), contact.phone];

    self.requestVisitorInfoButton.hidden = YES;
    self.labelName.hidden = NO;
    self.labelEmail.hidden = (contact.email.length == 0);
    self.labelPhone.hidden = (contact.phone.length == 0);
}

- (void)showContactWhenLoggedInAsProspect:(Contact*)contact
{
    self.labelName.text           = contact.name;
    self.labelEmail.text          = [NSString stringWithFormat:@"%@ %@", ICOLLString(@"Call:Title:Email"), contact.email];
    self.labelPhone.text          = [NSString stringWithFormat:@"%@ %@", ICOLLString(@"Call:Title:Phone"), contact.phone];

    self.requestVisitorInfoButton.hidden = YES;
    self.labelName.hidden = NO;
    self.labelEmail.hidden = NO;
    self.labelPhone.hidden = NO;
}

- ( void )
customizeStarsViewForRating:( NSInteger )rating
{
    NSArray* subviews = [[self viewStars] subviews];

    for ( UIView* subview in subviews ) {
        if ( [subview isKindOfClass:[UIButton class]] ) {
            NSString* imageName = nil;
            if ( ((UIButton*)subview).tag <=  rating)
                imageName = @"imageStarFull";
            else
                imageName = @"imageStarEmptyBright";

            [(UIButton*)subview setBackgroundImage:[UIImage sdkImageNamed:imageName] forState:UIControlStateNormal];
            [(UIButton*)subview setBackgroundImage:[UIImage sdkImageNamed:imageName] forState:UIControlStateDisabled];
        }
    }
}

- ( void )
hideControls
{
    [self stopControlsTimer];

    [UIView animateWithDuration:CONTROLS_ANIMATION_DURATION
                          delay:0.0f
                        options:UIViewAnimationOptionTransitionCrossDissolve
                     animations:^{
                         self.viewContactInfo.alpha     = 0.0;
                         self.viewButtonOptions.alpha   = 0.0;
                         self.callsOnHoldContainerView.alpha = 0.0;
                     }
                     completion:^(BOOL finished) {
                         self.controlsHidden = YES;

                         self.viewContactInfo.hidden     = self.controlsHidden;
                         self.viewButtonOptions.hidden   = self.controlsHidden;
                         self.callsOnHoldContainerView.hidden = self.controlsHidden;
                     }
     ];
}

- (void)showControlsIfNeeded
{
    if (self.controlsHidden)
    {
        [self showControls];
    }
}

- ( void )
showControls
{
    [self startControlsTimer];

    self.controlsHidden = NO;

    self.viewContactInfo.hidden     = self.controlsHidden;
    self.viewButtonOptions.hidden   = self.controlsHidden;
    self.callsOnHoldContainerView.hidden = self.controlsHidden;

    [UIView animateWithDuration:CONTROLS_ANIMATION_DURATION
                          delay:0.0f
                        options:UIViewAnimationOptionTransitionCrossDissolve
                     animations:^{
                         self.viewContactInfo.alpha     = 1.0;
                         self.viewButtonOptions.alpha   = 1.0;
                         self.callsOnHoldContainerView.alpha = 1.0;
                     }
                     completion:^(BOOL finished) {
                         self.controlsHidden = NO;

                         self.viewContactInfo.hidden     = self.controlsHidden;
                         self.viewButtonOptions.hidden   = self.controlsHidden;
                         self.callsOnHoldContainerView.hidden = self.controlsHidden;
                     }
     ];
}

- (void)showContactInfo
{
    [self stopControlsTimer];
    [self startControlsTimer];
    self.viewContactInfo.hidden = NO;

    [UIView animateWithDuration:CONTROLS_ANIMATION_DURATION
                          delay:0.0f
                        options:UIViewAnimationOptionTransitionCrossDissolve
                     animations:^{
                         self.viewContactInfo.alpha = 1.0;
                     }
                     completion:^(BOOL finished) {
                     }
     ];
}

- (void) enableCameraButton: (BOOL) bEnable {
    self.buttonCamera.enabled = bEnable;
    self.buttonCamera.hidden = !bEnable;
}

- ( void )
toggleControls:( UITapGestureRecognizer* )recognizer
{
    if ( self.controlsHidden )
        [self showControls];
    else
        [self hideControls];
}

- ( void )
updateDurationLabel
{
    NSTimeInterval callDuration = [[NSDate date] timeIntervalSince1970] - _callStartTime;
    [self.labelTotal setText:[self formattedStringForCallDuration:callDuration]];
}

- ( NSString* )
formattedStringForCallDuration:( NSTimeInterval ) duration
{
    int totalSeconds = duration;

    int hours = totalSeconds / 3600;
    int minutes = (totalSeconds / 60) % 60;
    int seconds = totalSeconds % 60;

    NSString* timeText = nil;

    if (hours > 0)
    {
        timeText = [NSString stringWithFormat:@"%02d:%02d:%02d", hours, minutes, seconds];
    }
    else
    {
        timeText = [NSString stringWithFormat:@"%02d:%02d", minutes, seconds];
    }

    return timeText;
}

#pragma mark - Button Actions

- (IBAction)requestVisitorInfoAction:(id)sender
{
    if (!self.isAgent)
    {
        IMLogDbg("requestVisitorInfoAction, do nothing when logged in as prospect.", 0);
        return;
    }

    [self.delegate callInProgressView:self
           onRequestVisitorInfoAction:sender
                    completionHandler:^(BOOL succeededSendingRequest)
     {
         if (succeededSendingRequest)
         {
             self.requestVisitorInfoButton.hidden = YES;
             self.requestVisitorActivityIndicator.hidden = NO;

             [self.requestVisitorActivityIndicator startAnimating];
         }
     }];
}

- ( IBAction )
messageAction:( UIButton* ) sender
{
    if ( [self.delegate respondsToSelector:@selector(callInProgressView:onMessageButtonAction:)] )
        [self.delegate performSelector:@selector(callInProgressView:onMessageButtonAction:) withObject:self withObject:sender];
}

- ( IBAction )
cameraAction:(UIButton *)sender
{
    if ( [self.delegate respondsToSelector:@selector(callInProgressView:onCameraButtonAction:)] )
        [self.delegate performSelector:@selector(callInProgressView:onCameraButtonAction:) withObject:self withObject:sender];
}

- ( IBAction )
muteAction:(UIButton *)sender
{
    if ( [self.delegate respondsToSelector:@selector(callInProgressView:onMuteButtonAction:)] )
        [self.delegate performSelector:@selector(callInProgressView:onMuteButtonAction:) withObject:self withObject:sender];
}

- ( IBAction )
declineAction:(UIButton *)sender
{
    if ( [self.delegate respondsToSelector:@selector(callInProgressView:onDeclineButtonAction:)] )
        [self.delegate performSelector:@selector(callInProgressView:onDeclineButtonAction:) withObject:self withObject:sender];
}

- (IBAction)speakerAction:(UIButton *)sender {
    if ( [self.delegate respondsToSelector:@selector(callInProgressView:onSpeakerButtonAction:)] )
        [self.delegate performSelector:@selector(callInProgressView:onSpeakerButtonAction:) withObject:self withObject:sender];
}


- ( void )
hideContactAvatar
{
    self.userAvatarImageView.hidden = YES;
}

- ( void )
showContactAvatar:(UIImage *)image
{
    if (image != nil)
        self.userAvatarImageView.image = image;

    self.userAvatarImageView.hidden = NO;
}

@end
