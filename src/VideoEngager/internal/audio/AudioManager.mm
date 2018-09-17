//
//  AudioManager.m
//
//  Created by Nikolay Markov on 11/4/14.
//  Copyright (c) 2014 SoftAvail. All rights reserved.
//

#import "AudioManager.h"
#import <AVFoundation/AVFoundation.h>

#define BLUETOOTH_AVAILABILITY_TIMER 10.0f

static NSString* recordPermissionToString(AVAudioSessionRecordPermission permisiion)
{
    NSString* sPermisiion;
    
    switch (permisiion) {
        case AVAudioSessionRecordPermissionUndetermined:
            sPermisiion = @"Undetermined";
            break;
        case AVAudioSessionRecordPermissionGranted:
            sPermisiion = @"Granted";
            break;
        case AVAudioSessionRecordPermissionDenied:
            sPermisiion = @"Denied";
            break;
        default:
            sPermisiion = @"Unknown";
            break;
    }
    
    return sPermisiion;
}

@interface  AudioManager()

@property (nonatomic, assign) AVAudioSessionRecordPermission recordPermission;
@property (nonatomic, weak) AVAudioSession* audioSession;
@property (nonatomic, strong) NSArray<SAAudioDevice*>* availableInputDevices;

@end

@implementation AudioManager
static id sharedInstance = nil;

+(instancetype) sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSLog(@"Instantiate AudioManager");
        sharedInstance = [[[self class] alloc] init];
    });
    
    return sharedInstance;
}

-(instancetype) init
{
	self = [super init];
	if (self)
	{
        self.audioSession = [AVAudioSession sharedInstance];
        
        [self rebuildInputDevices];
        
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(handleRouteChangeNotification:)
													 name:AVAudioSessionRouteChangeNotification
												   object:nil];
	}
	return self;
}

#pragma mark - private

- (NSArray<SAAudioDevice*> *) getAvailableInputDevices
{
    BOOL hasBT = NO;
    
    NSArray<AVAudioSessionPortDescription *> * inputs = [self.audioSession availableInputs];
    NSMutableArray<SAAudioDevice *> * inputDevices = [[NSMutableArray alloc] initWithCapacity: inputs.count];
    
    for (AVAudioSessionPortDescription* port in inputs) {
        SAAudioDevice* audioDevice = [[SAAudioDevice alloc] initWithPortDescription: port];
        if (audioDevice.isBluetooth)
            hasBT = YES;

        [inputDevices addObject: audioDevice];
    }
    
    _bluetoothAvailable = hasBT;
    
    return [NSArray arrayWithArray: inputDevices];
}

- (void) rebuildInputDevices {
    @synchronized (self) {
        self.availableInputDevices = [self getAvailableInputDevices];
    }
}

- (void) requestRecordPermissionsIfNotYet
{
    self.recordPermission = [self.audioSession recordPermission];
    NSLog(@"AVAudioSessionRecordPermission is: %@", recordPermissionToString(self.recordPermission));
    
    if (AVAudioSessionRecordPermissionUndetermined == self.recordPermission) {
        
        NSLog(@"UIApplication state is: %ld", (long) [UIApplication sharedApplication].applicationState);
        if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive)
        {
            [self.audioSession requestRecordPermission:^(BOOL granted) {
                self.recordPermission = [self.audioSession recordPermission];
            }];
        }
    }
}

- (BOOL) isBluetoothCurrentAudioOutput
{
    BOOL isBT = NO;
    AVAudioSessionRouteDescription * route = [self.audioSession currentRoute];

    for (AVAudioSessionPortDescription* port in route.outputs)
    {
        SAAudioDevice* audioDevice = [[SAAudioDevice alloc] initWithPortDescription: port];
        if (audioDevice.isBluetooth) {
            isBT = YES;
            break;
        }
    }
    
    return isBT;
}

- (BOOL) isSpeakerCurrentAudioOutput
{
    BOOL isSP = NO;
    AVAudioSessionRouteDescription * route = [self.audioSession currentRoute];
    
    for (AVAudioSessionPortDescription* port in route.outputs)
    {
        SAAudioDevice* audioDevice = [[SAAudioDevice alloc] initWithPortDescription: port];
        if (audioDevice.isSpeaker) {
            isSP = YES;
            break;
        }
    }
    
    return isSP;
}

- (BOOL) isReceiverCurrentAudioOutput
{
    BOOL isRE = NO;
    AVAudioSessionRouteDescription * route = [self.audioSession currentRoute];
    
    for (AVAudioSessionPortDescription* port in route.outputs)
    {
        SAAudioDevice* audioDevice = [[SAAudioDevice alloc] initWithPortDescription: port];
        if (audioDevice.isReceiver) {
            isRE = YES;
            break;
        }
    }
    
    return isRE;
}

- (void) changeAudioOutputToReceiver
{
    NSError* error = nil;
    if (![self.audioSession setCategory: AVAudioSessionCategoryPlayAndRecord
                                  error: &error])
    {
        IMLogErr("Could not set category: %s", error.localizedDescription.UTF8String);
    }
}

- (void)setAudioOutputSpeaker:(BOOL)enabled {
    
    NSError *error;
    [self.audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:&error];
    [self.audioSession setMode:AVAudioSessionModeVoiceChat error:&error];
    
    if (enabled){// Enable speaker
        
        [self.audioSession overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:&error];
        
    } else {// Disable speaker
        
        [self.audioSession overrideOutputAudioPort:AVAudioSessionPortOverrideNone error:&error];
    }
    
    [self.audioSession setActive:YES error:&error];
}

- (void) changeAudioOutputToSpeaker
{
    [self setAudioOutputSpeaker:YES];
    
//    AVAudioSessionCategoryOptions options = AVAudioSessionCategoryOptionDefaultToSpeaker | AVAudioSessionCategoryOptionAllowBluetooth | AVAudioSessionCategoryOptionAllowBluetoothA2DP;
//    NSError* error = nil;
//    if (![self.audioSession setCategory: AVAudioSessionCategoryPlayAndRecord
//                            withOptions: options
//                                  error: &error])
//    {
//        IMLogErr("Could not set category: %s", error.localizedDescription.UTF8String);
//    }
}

- (void) changeAudioOutputToBluetooth
{
    
    AVAudioSessionCategoryOptions options = AVAudioSessionCategoryOptionAllowBluetooth | AVAudioSessionCategoryOptionAllowBluetoothA2DP;
    NSError* error = nil;
    if (![self.audioSession setCategory: AVAudioSessionCategoryPlayAndRecord
                            withOptions: options
                                  error: &error])
    {
        IMLogErr("Could not set category: %s", error.localizedDescription.UTF8String);
        return;
    }

    /*
    SAAudioDevice* btDevice = [self bluetootheDevice];
    if (nil != btDevice) {
        NSError* error = nil;
        [self.audioSession setPreferredInput:btDevice.portDescription error:&error];
        
        if (error != nil) {
            IMLogErr("Could not set audio port to bluetooth [%s]", error.localizedDescription.UTF8String);
        }
    }
    */
}

#pragma mark - Audio routes

- (void)handleRouteChangeNotification:(NSNotification *)notification {
    // Get reason for current route change.
    NSNumber* reasonNumber =
    notification.userInfo[AVAudioSessionRouteChangeReasonKey];
    AVAudioSessionRouteChangeReason reason =
    (AVAudioSessionRouteChangeReason)reasonNumber.unsignedIntegerValue;
    IMLogDbg("Audio route changed:", 0);
    switch (reason) {
        case AVAudioSessionRouteChangeReasonUnknown:
            IMLogDbg("Audio route changed: ReasonUnknown", 0);
            break;
        case AVAudioSessionRouteChangeReasonNewDeviceAvailable:
            IMLogDbg("Audio route changed: NewDeviceAvailable", 0);
            break;
        case AVAudioSessionRouteChangeReasonOldDeviceUnavailable:
            IMLogDbg("Audio route changed: OldDeviceUnavailable", 0);
            break;
        case AVAudioSessionRouteChangeReasonCategoryChange:
            IMLogDbg("Audio route changed: CategoryChange to :%s",
                   self.audioSession.category.UTF8String);
            break;
        case AVAudioSessionRouteChangeReasonOverride:
            IMLogDbg("Audio route changed: Override", 0);
            break;
        case AVAudioSessionRouteChangeReasonWakeFromSleep:
            IMLogDbg("Audio route changed: WakeFromSleep", 0);
            break;
        case AVAudioSessionRouteChangeReasonNoSuitableRouteForCategory:
            IMLogDbg("Audio route changed: NoSuitableRouteForCategory", 0);
            break;
        case AVAudioSessionRouteChangeReasonRouteConfigurationChange:
            IMLogDbg("Audio route changed: RouteConfigurationChange", 0);
            break;
    }
    
    AVAudioSessionRouteDescription* previousRoute =
    notification.userInfo[AVAudioSessionRouteChangePreviousRouteKey];

    // Log previous route configuration.
    if (nil != previousRoute) {
        IMLogDbg("Previous route: %s",
                 previousRoute.description.UTF8String);
    }

    if (nil != self.audioSession.currentRoute) {
        IMLogDbg("Current route:%s",
                 self.audioSession.currentRoute.description.UTF8String);
    }
    
    [self rebuildInputDevices];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [[VDENotificationCenter vdeCenter] postNotificationName:kAudioRouteChangeNotification
                                                            object:nil];
    });
}

//MARK: - Interface

- (BOOL) hasReceiver
{
    return UI_IPHONE();
}

- (SAAudioDevice*) bluetootheDevice
{
    SAAudioDevice* btDevice = nil;
    
    @synchronized (self) {
        for (SAAudioDevice* audioDevice in self.availableInputDevices) {
            if (audioDevice.isBluetooth) {
                btDevice = audioDevice;
                break;
            }
        }
    }
    
    return btDevice;
}

- (void) setBluetoothActive
{
    SAAudioDevice* btDevice = [self bluetootheDevice];
    if (nil != btDevice) {
        NSError* error = nil;
        [self.audioSession setPreferredInput:btDevice.portDescription error:&error];
        
        if (error != nil) {
            IMLogErr("Could not set audio port to bluetooth [%s]", error.localizedDescription.UTF8String);
        }
    }
}

- (void) setBluetoothInactive
{
    NSError* error = nil;
    [self.audioSession setPreferredInput:nil error:&error];
    
    if (error != nil) {
        IMLogErr("Could not set deactivate bluetooth audio port [%s]", error.localizedDescription.UTF8String);
    }
}

- (void) setPreferredAudioOutput: (AudioOutput) audioOutput
{    
    switch (audioOutput)
    {
        case AudioOutputSpeaker:
            [self changeAudioOutputToSpeaker];
            break;
        case AudioOutputBluetooth:
            [self changeAudioOutputToBluetooth];
            break;
        case AudioOutputReceiver:
            [self changeAudioOutputToReceiver];
        default:
            [self changeAudioOutputToReceiver];
            break;
    }
}

@end
