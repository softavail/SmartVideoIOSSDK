//
//  SAAudioDevice.m
//  leadsecure
//
//  Created by Angel Terziev on 2/17/17.
//  Copyright © 2017 SoftAvail. All rights reserved.
//

#import "SAAudioDevice.h"

@interface SAAudioDevice ()
@property (nonatomic, strong) AVAudioSessionPortDescription* port;
@end

@implementation SAAudioDevice

- (instancetype) initWithPortDescription: (AVAudioSessionPortDescription*) portDescription
{
    self = [super init];
    
    if (nil != self) {
        self.port = portDescription;
        _type = [[self class] portDescriptionToType: self.port.portType];
    }
    
    return self;
}

//MARK: - private
+ (SAAudioDeviceType) portDescriptionToType: (NSString*) stype
{
    SAAudioDeviceType type = SAAudioDeviceBuiltInSpeaker;
    
    if ([stype isEqualToString: AVAudioSessionPortLineIn])
        type = SAAudioDeviceLineIn;
    else if ([stype isEqualToString: AVAudioSessionPortBuiltInMic])
        type = SAAudioDeviceBuiltInMic;
    else if ([stype isEqualToString: AVAudioSessionPortHeadsetMic])
        type = SAAudioDeviceHeadsetMic;
    else if ([stype isEqualToString: AVAudioSessionPortLineOut])
        type = SAAudioDeviceLineOut;
    else if ([stype isEqualToString: AVAudioSessionPortHeadphones])
        type = SAAudioDeviceHeadphones;
    else if ([stype isEqualToString: AVAudioSessionPortBluetoothA2DP])
        type = SAAudioDeviceBluetoothA2DP;
    else if ([stype isEqualToString: AVAudioSessionPortBuiltInReceiver])
        type = SAAudioDeviceBuiltInReceiver;
    else if ([stype isEqualToString: AVAudioSessionPortBuiltInSpeaker])
        type = SAAudioDeviceBuiltInSpeaker;
    else if ([stype isEqualToString: AVAudioSessionPortHDMI])
        type = SAAudioDeviceHDMI;
    else if ([stype isEqualToString: AVAudioSessionPortAirPlay])
        type = SAAudioDeviceAirPlay;
    else if ([stype isEqualToString: AVAudioSessionPortBluetoothLE])
        type = SAAudioDeviceBluetoothLE;
    else if ([stype isEqualToString: AVAudioSessionPortBluetoothHFP])
        type = SAAudioDeviceBluetoothHFP;
    else if ([stype isEqualToString: AVAudioSessionPortUSBAudio])
        type = SAAudioDeviceUSBAudio;
    else if ([stype isEqualToString: AVAudioSessionPortCarAudio])
        type = SAAudioDeviceCarAudio;
    
    return type;
}

//MARK: - interface
- (BOOL) isBluetooth
{
    return (SAAudioDeviceBluetoothHFP == self.type ||
            SAAudioDeviceBluetoothA2DP == self.type ||
            SAAudioDeviceBluetoothLE == self.type);
}

- (BOOL) isSpeaker
{
    return (SAAudioDeviceBuiltInSpeaker == self.type);
}

- (BOOL) isReceiver
{
    return (SAAudioDeviceBuiltInReceiver == self.type);
}

//MARK: - accessors
- (NSString *) name
{
    return self.port.portName;
}

-(AVAudioSessionPortDescription *)portDescription
{
    return self.port;
}

@end
