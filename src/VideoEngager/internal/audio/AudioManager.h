//
//  AudioManager.h
//
//  Created by Nikolay Markov on 11/4/14.
//  Copyright (c) 2014 SoftAvail. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SAAudioDevice.h"

@class AVAudioSessionPortDescription;

typedef NS_ENUM(NSInteger, AudioOutput)
{
    AudioOutputReceiver,
    AudioOutputSpeaker,
    AudioOutputBluetooth
};

@interface AudioManager : NSObject

@property (nonatomic, readonly, getter=isBluetoothAvailable) BOOL bluetoothAvailable;

+(id) sharedInstance;

- (void) requestRecordPermissionsIfNotYet;
- (BOOL) hasReceiver;
- (SAAudioDevice*) bluetootheDevice;
- (void) setBluetoothActive;
- (void) setBluetoothInactive;

- (void) setPreferredAudioOutput: (AudioOutput) audioOutput;

- (BOOL) isBluetoothCurrentAudioOutput;
- (BOOL) isSpeakerCurrentAudioOutput;
- (BOOL) isReceiverCurrentAudioOutput;

@end
