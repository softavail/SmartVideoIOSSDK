//
//  VideoViewContainer.h
//  leadsecure
//
//  Created by Angel Terziev on 12/22/14.
//  Copyright (c) 2014 SoftAvail. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <WebRTC/RTCEAGLVideoView.h>
#import "RTCVideoView.h"

typedef enum {
    VVCScalingModeNone,
    VVCScalingModeAspectFit,
    VVCScalingModeAspectFill,
    VVCScalingModeFill
} VVCScalingMode;

@interface VideoViewContainer : UIView

@property (nonatomic, strong, readonly) RTCVideoView* rtcVideoView;
@property (nonatomic, assign, readonly) CGSize rtcVideoSize;

@property (nonatomic, strong) NSString* name;
@property (nonatomic, assign) VVCScalingMode scalingMode;

@property (nonatomic, assign) BOOL enableChangeScalingMode;
//This frame is used because of a very annoying bug where
//local video view is changing its frame by itself
//setting it ensures that when redrawing the frame of the view
//will be exactly the one in this property
@property (nonatomic, assign) CGRect aHackFrame;

- (void) pauseRenderer;
- (void) resumeRenderer;

- (void)setSkipFramesCount:(unsigned int)framesCountToSkip;

@end
