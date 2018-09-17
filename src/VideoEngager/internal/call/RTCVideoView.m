//
//  RTCVideoView.m
//  leadsecure
//
//  Created by ivan shulev on 9/8/15.
//  Copyright (c) 2015 SoftAvail. All rights reserved.
//

#import "RTCVideoView.h"

@implementation RTCVideoView
{
    int _framesIndex;
    unsigned int _framesCountToSkip;
}

- (void)renderFrame:(RTCVideoFrame*)frame
{
    if (_framesCountToSkip == 0)
    {
        [super renderFrame:frame];
    }
    else if (_framesIndex % _framesCountToSkip == 0)
    {
        [super renderFrame:frame];
    }
    
    if (_framesCountToSkip > 0)
    {
        _framesIndex++;
    }
}

- (void)setSkipFramesCount:(unsigned int)framesCountToSkip
{
    _framesCountToSkip = framesCountToSkip;
}

@end
