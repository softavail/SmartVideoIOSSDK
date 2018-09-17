//
//  RTCVideoView.h
//  leadsecure
//
//  Created by ivan shulev on 9/8/15.
//  Copyright (c) 2015 SoftAvail. All rights reserved.
//

#import "WebRTC/RTCEAGLVideoView.h"

@interface RTCVideoView : RTCEAGLVideoView

- (void)setSkipFramesCount:(unsigned int)framesCountToSkip;

@end
