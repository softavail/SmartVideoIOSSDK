//
//  VideoViewContainer.m
//  leadsecure
//
//  Created by Angel Terziev on 12/22/14.
//  Copyright (c) 2014 SoftAvail. All rights reserved.
//

#import "VideoViewContainer.h"


@interface VideoViewContainer()
@property (nonatomic, strong) UITapGestureRecognizer* doubleTapGestureRecognizer;
@end


@interface VideoViewContainer(RTCEAGLVideoView) <RTCEAGLVideoViewDelegate>
- (void)
videoView           : ( RTCEAGLVideoView *) videoView
didChangeVideoSize  : ( CGSize            ) size;

@end

@implementation VideoViewContainer


- (id) initialize
{
    //Content and subviews are clipped to the bounds of the view
    self.clipsToBounds = YES;

    // create rtc video view
    _rtcVideoView = [[RTCVideoView alloc]initWithFrame: self.bounds];
    _rtcVideoView.delegate = self;
    
    self.doubleTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTapGesture:)];
    self.doubleTapGestureRecognizer.numberOfTapsRequired = 2;
    
    // add subview
    [self addSubview: _rtcVideoView];
    
    return self;
}

- (id) initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder])
    {
        return [self initialize];
    }
    
    return nil;
}

- (id) initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        return [self initialize];
    }
    
    return nil;
}

- (void)setSkipFramesCount:(unsigned int)framesCountToSkip
{
    [_rtcVideoView setSkipFramesCount:framesCountToSkip];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void) layoutSubviews
{
    // calculate rtc video view size
    if (_rtcVideoSize.width > 0 && _rtcVideoSize.height > 0)
    {
        CGSize viewSize = self.bounds.size;
        CGFloat ratioWidth = viewSize.width / _rtcVideoSize.width;
        CGFloat ratioHeight = viewSize.height / _rtcVideoSize.height;
        CGRect rtcViewBounds;
        
        switch (self.scalingMode)
        {
            case VVCScalingModeAspectFit:
            {
                CGFloat ratio = MIN(ratioWidth, ratioHeight);
                rtcViewBounds = CGRectMake(0,0,
                                           _rtcVideoSize.width*ratio,
                                           _rtcVideoSize.height*ratio);
            }
                break;
            case VVCScalingModeAspectFill:
            {
                CGFloat ratio = MAX(ratioWidth, ratioHeight);
                rtcViewBounds = CGRectMake(0,0,
                                           _rtcVideoSize.width*ratio,
                                           _rtcVideoSize.height*ratio);
            }
                break;
            case VVCScalingModeFill:
            {
                rtcViewBounds = CGRectMake(0,0,
                                           _rtcVideoSize.width*ratioWidth,
                                           _rtcVideoSize.height*ratioHeight);
            }
                break;
                
            case VVCScalingModeNone:
            default:
            {
                rtcViewBounds = CGRectMake(0,0,
                                           _rtcVideoSize.width,
                                           _rtcVideoSize.height);
            }
                break;
        }
        
        self.rtcVideoView.bounds = rtcViewBounds;
        self.rtcVideoView.center = CGPointMake(CGRectGetMidX(self.bounds),
                                               CGRectGetMidY(self.bounds));

        IMLogDbg("rtcView frame=(%.f %.f; %.f:%.f);",
                 self.rtcVideoView.frame.origin.x,
                 self.rtcVideoView.frame.origin.y,
                 self.rtcVideoView.frame.size.width,
                 self.rtcVideoView.frame.size.height);
        IMLogDbg("%s ViewContainer frame=(%.f %.f; %.f:%.f); mode=%d",
                 [self.name length] ? self.name.UTF8String : "",
                 self.frame.origin.x,
                 self.frame.origin.y,
                 self.frame.size.width,
                 self.frame.size.height,
                 self.scalingMode);
    }
}

- (void) dealloc
{
    _rtcVideoView.delegate = nil;
    _rtcVideoView = nil;    
}

- (void)setEnableChangeScalingMode: ( BOOL ) enable
{
    if (_enableChangeScalingMode != enable)
    {
        _enableChangeScalingMode = enable;
        
        if (_enableChangeScalingMode)
        {
            [self.rtcVideoView addGestureRecognizer: self.doubleTapGestureRecognizer];
        }
        else
        {
            [self.rtcVideoView removeGestureRecognizer: self.doubleTapGestureRecognizer];
        }
        
        IMLogDbg("%s change scaling mode",
                 _enableChangeScalingMode ? "enable" : "disable");
    }
}

// Looked inside WebRTC sources. Call tear down OpenGL renderer prior to swithcing cameras
// Watch for a public method in future builds
- (void) pauseRenderer
{
    if([self.rtcVideoView respondsToSelector:@selector(teardownGL)])
        [self.rtcVideoView performSelector:@selector(teardownGL)];
}

// Looked inside WebRTC sources. Call tear down OpenGL renderer prior to swithcing cameras
// Watch for a public method in future builds
- (void) resumeRenderer
{
    if([self.rtcVideoView respondsToSelector:@selector(setupGL)])
        [self.rtcVideoView performSelector:@selector(setupGL)];
}


- (void) setFrame:(CGRect)frame
{
    [super setFrame: frame];
}

- (void) setBounds:(CGRect)bounds
{
    [super setBounds:bounds];
}

- (void) setCenter:(CGPoint)center
{
    [super setCenter:center];
}

#pragma mark - RTCEAGLVideoViewDelegate

- (void)
videoView           : ( RTCEAGLVideoView *) videoView
didChangeVideoSize  : ( CGSize            ) size
{
    
    IMLogDbg("%s didChangeVideoSize to: (%.f,%.f)",
             [self.name length] ? self.name.UTF8String : self.rtcVideoView.description.UTF8String,
             size.width, size.height);
    
    NSLog(@" current videoViewSize: (%.f,%.f)",
          self.rtcVideoView.bounds.size.width,
          self.rtcVideoView.bounds.size.height);

    // save video size now
    _rtcVideoSize = size;
    
    [self setNeedsLayout];
}

- (void) handleDoubleTapGesture: (UIGestureRecognizer*) recognizer
{
    if (self.enableChangeScalingMode == YES)
    {
        int mode = (int) self.scalingMode;
        int maxMode = ((int)VVCScalingModeFill) + 1;
        self.scalingMode = (VVCScalingMode) (++mode % maxMode);
        IMLogDbg("Did change scaling mode to %d", self.scalingMode);
        
        [self setNeedsLayout];
    }
}

@end
