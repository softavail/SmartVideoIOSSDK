//
//  SAAudioDevice.h
//  leadsecure
//
//  Created by Angel Terziev on 2/17/17.
//  Copyright © 2017 SoftAvail. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <AVFoundation/AVAudioSession.h>

typedef NS_ENUM ( NSInteger, SAAudioDeviceType ) {
    /* input port types */
    SAAudioDeviceLineIn,            /* Line level input on a dock connector */
    SAAudioDeviceBuiltInMic,        /* Built-in microphone on an iOS device */
    SAAudioDeviceHeadsetMic,        /* Microphone on a wired headset.  Headset refers to an */
                                                                                      
    /* output port types */
    SAAudioDeviceLineOut,           /* Line level output on a dock connector */
    SAAudioDeviceHeadphones,        /* Headphone or headset output */
    SAAudioDeviceBluetoothA2DP,     /* Output on a Bluetooth A2DP device */
    SAAudioDeviceBuiltInReceiver,   /* The speaker you hold to your ear when on a phone call */
    SAAudioDeviceBuiltInSpeaker,    /* Built-in speaker on an iOS device */
    SAAudioDeviceHDMI,              /* Output via High-Definition Multimedia Interface */
    SAAudioDeviceAirPlay,           /* Output on a remote Air Play device */
    SAAudioDeviceBluetoothLE,       /* Output on a Bluetooth Low Energy device */
    
    /* port types that refer to either input or output */
    SAAudioDeviceBluetoothHFP,      /* Input or output on a Bluetooth Hands-Free Profile device */
    SAAudioDeviceUSBAudio,          /* Input or output on a Universal Serial Bus device */
    SAAudioDeviceCarAudio           /* Input or output via Car Audio */
};

@interface SAAudioDevice : NSObject

@property (readonly) NSString* name;
@property (readonly) SAAudioDeviceType type;
@property (readonly) AVAudioSessionPortDescription* portDescription;

- (instancetype) initWithPortDescription: (AVAudioSessionPortDescription*) portDescription;

- (BOOL) isBluetooth;
- (BOOL) isSpeaker;
- (BOOL) isReceiver;

@end
