//
//  VDEInternal.m
//  VideoEngager
//
//  Created by Angel Terziev on 2.01.18.
//  Copyright © 2018 VideoEngager. All rights reserved.
//

#import "VDEInternal.h"

#import "RefCountPtr.h"
#import "AutoPtr.h"
#import "IEventSink.h"
#import "RestEvent.h"
#import "RTCEvent.h"
#import "IFacade.h"
#import "IRTCManager.h"
#import "IRestManager.h"
#import "SystemProfile.hpp"
#import "TraceMacros.h"
#include "AccountInfo.h"
#import "AudioManager.h"
#import "VEHttpClient.h"

#import "VDEEventListener.h"
#import "VDEAgent+Internal.h"
#import "VDECall+Internal.h"
#import "VDEAgentViewController+Internal.h"

#import "RtcEventsListener.h"

#import <sys/utsname.h> // for machine name

#define LOG_BUNDLE_KEY(bundle, key) \
 NSLog(@"%s: %@", #key, [bundle objectForInfoDictionaryKey:key]);

static VDEInternal* _VDEInternalInstance = nil;

@interface VDEInternal()

@property(nonatomic,readonly) NSString* systemName;
@property(nonatomic,readonly) NSString* systemVersion;
@property(nonatomic,readonly) NSString* deviceModelName;
@property(nonatomic,readonly) NSString* sdkName;
@property(nonatomic,readonly) NSString* sdkVersion;
@property(nonatomic,readonly) NSString* buildVersion;
@property(nonatomic,readonly) NSString* bundleIdentifier;
@property(nonatomic) NSString* logPath;
@property(nonatomic) NSString* dbPath;
@property(nonatomic) NSBundle* sdkBundle;
@property(nonatomic) NSString* userAgent;

@property(nonatomic,copy) NSString* containerPath;
@property(nonatomic,copy) NSString* serverAddress;
@property(nonatomic) int serverPort;
@property(nonatomic, getter=isSecureAddress) BOOL secureAddress;

@property(nonatomic,assign) instac::RefCountPtr<instac::IFacade> facade;
@property(nonatomic,assign) instac::AutoPtr<instac::IEventSink<instac::RTCEvent> > rtcEventListener;
@property(nonatomic,assign) instac::RefCountPtr<instac::IRTCManager> rtcManager;
@property(nonatomic,assign) instac::AutoPtr<instac::IEventSink<instac::RestEvent> > restEventListener;
@property(nonatomic,assign) instac::RefCountPtr<instac::IRestManager> restManager;

@property (nonatomic, copy, nullable) void (^joinCompletion)(NSError* __nullable error, VDEAgent* __nullable agent);
@property (nonatomic, copy, nullable) void (^startCallCompletion)(NSError* __nullable error);
@property (nonatomic, copy, nullable) void (^disconnectCompletion)(NSError* __nullable error);
@property (nonatomic, nullable) VDECall* call;

@property (nonatomic, strong) VEHttpClient* httpClient;

@end


@implementation VDEInternal

@dynamic systemName,systemVersion,deviceModelName,sdkName,sdkVersion,buildVersion,bundleIdentifier;
@dynamic hasRemoteAudio, hasRemoteVideo;

@synthesize deviceId = _deviceId;

//MARK: Accessors
-(NSString *)deviceId {
    
    if (nil == _deviceId) {
        NSUUID *oNSUUID = [[UIDevice currentDevice] identifierForVendor];
        if(nil != oNSUUID) {
            _deviceId = [oNSUUID UUIDString];
        } else {
            _deviceId = [[NSUUID UUID] UUIDString];
        }
    }
    
    return _deviceId;
}

-(VEHttpClient *)httpClient {
    
    if (nil == _httpClient) {
        _httpClient = [[VEHttpClient alloc] init];
    }
    
    return _httpClient;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _VDEInternalInstance = [super allocWithZone:zone];
    });
    
    return _VDEInternalInstance;
}

-(NSString *)systemName {
    return [[UIDevice currentDevice] systemName];
}

-(NSString *)systemVersion {
    return [[UIDevice currentDevice] systemVersion];
}

-(NSString *)deviceModelName {

    struct utsname systemInfo;
    uname(&systemInfo);
    
    return [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
}

- (NSString *)sdkName {
    return [self.sdkBundle objectForInfoDictionaryKey:@"CFBundleName"];
}

-(NSString *)sdkVersion {
    return [self.sdkBundle objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
}

-(NSString *)buildVersion {
    return [self.sdkBundle objectForInfoDictionaryKey:@"CFBundleVersion"];
}

-(NSString *)bundleIdentifier {
    return [self.sdkBundle objectForInfoDictionaryKey:@"CFBundleIdentifier"];
}

-(NSString *)logPath {
    if (nil == _logPath) {
        NSFileManager* fm = [NSFileManager defaultManager];
        NSString* dir = [[self containerPath] stringByAppendingPathComponent:@"log"];
        BOOL isDir = NO;
        if (![fm fileExistsAtPath:dir isDirectory:&isDir])
        {
            if ([fm createDirectoryAtPath:dir withIntermediateDirectories:YES attributes:nil error:nil])
            {
                _logPath = dir;
            }
        }
        else if (isDir)
        {
            _logPath = dir;
        }
    }
    
    return _logPath;
}

-(NSString *)dbPath {
    if (nil == _dbPath) {
        NSFileManager* fm = [NSFileManager defaultManager];
        NSString* dir = [[self containerPath] stringByAppendingPathComponent:@"db"];
        BOOL isDir = NO;
        if (![fm fileExistsAtPath:dir isDirectory:&isDir])
        {
            if ([fm createDirectoryAtPath:dir withIntermediateDirectories:YES attributes:nil error:nil])
            {
                _dbPath = dir;
            }
        }
        else if (isDir)
        {
            _dbPath = dir;
        }
    }
    
    return _dbPath;
}

-(NSBundle *)sdkBundle {
    if (nil == _sdkBundle) {
        _sdkBundle = [NSBundle bundleForClass:[self class]];
    }
    
    return _sdkBundle;
}

-(NSString *)userAgent {
    if (nil == _userAgent) {
        _userAgent = [NSString stringWithFormat:@"%@ OS %@;%@ %@", self.deviceModelName, self.systemVersion, self.sdkName, self.sdkVersion];
    }
    return _userAgent;
}

-(BOOL)hasRemoteAudio
{
    if (_rtcManager != NULL) {
        return (_rtcManager->hasRemoteAudio() == true);
    }
    
    return NO;
}

-(BOOL)hasRemoteVideo
{
    if (_rtcManager != NULL) {
        return (_rtcManager->hasRemoteVideo() == true);
    }
    
    return NO;
}

- (instancetype) initWithContainerPath: (NSURL*) containerPath
                     withServerAddress: (NSURL*) serverAddress
                           andDelegate: (id<VDEInternalDelegate>) delegate
{
    if (nil != (self = [super init]))
    {
        _delegate = delegate;
        self.containerPath = containerPath.path;
        self.serverAddress = serverAddress.host;
        NSNumber* port = serverAddress.port;
        self.secureAddress = (NSOrderedSame == [serverAddress.scheme caseInsensitiveCompare:@"https"]);
        self.serverPort = port.intValue > 0 ? port.intValue : (self.secureAddress ? 443 : 80);

        // initializeAppLogging
#if defined (DEBUG) && (0 != DEBUG)
        initializeAppLogging(self.logPath.UTF8String, self.sdkName.UTF8String, IML_VBS);
#else
        initializeAppLogging(self.logPath.UTF8String, self.sdkName.UTF8String, IML_DBG);
#endif

        _facade = instac::IFacade::getInstance();
        _facade->initialize(self.bundleIdentifier.UTF8String,
                            self.dbPath.UTF8String);

        _restEventListener = new VDEEventListener<VDEInternal, instac::RestEvent>(self, @selector(onRestEvent:));
        _facade->getRestManager(_restManager);
        _restManager->subscribeForEvents(*_restEventListener);

        _rtcEventListener = new VDEEventListener<VDEInternal, instac::RTCEvent>(self, @selector(onRtcEvent:));
        _facade->getRTCManager(_rtcManager);
        _rtcManager->subscribeForEvents(*_rtcEventListener);
        
        instac::RefCountPtr<instac::SystemProfile> systemProfile(new instac::SystemProfile());
        systemProfile->setOsName(self.systemName.UTF8String);
        systemProfile->setOsVersion(self.systemVersion.UTF8String);
        systemProfile->setDeviceModel(self.deviceModelName.UTF8String);
        systemProfile->setAppName(self.sdkName.UTF8String);
        systemProfile->setAppVersion(self.sdkVersion.UTF8String);
        systemProfile->setBuild(self.buildVersion.UTF8String);
        _facade->setSystemProfile(systemProfile);

        _facade->setServerInfo(self.serverAddress.UTF8String, self.serverPort, self.isSecureAddress);
        
        _rtcManager->setDeviceInfo(self.deviceId.UTF8String);
        
        _rtcManager->didChangeAudioSessionActiveState(true);
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleProximityChange:)
                                                     name:UIDeviceProximityStateDidChangeNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(applicationDidEnterBackground:)
                                                     name:UIApplicationDidEnterBackgroundNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(applicationDidEnterForeground:)
                                                     name:UIApplicationWillEnterForegroundNotification
                                                   object:nil];

    }
    
    return self;
}

- (void) callLocalVideoStateUpdate: (BOOL) show
{
    if (show)
    {
        if (self.activeCallId && VideoRouteNone != self.videoRoute )
        {
            _rtcManager->sendEvent(instac::String(self.activeCallId.UTF8String), "VideoStarted");
            _rtcManager->muteVideo( false );
        }
    }
    else
    {
        //Switch call to audio only
        if (self.activeCallId)
        {
            _rtcManager->sendEvent(instac::String(self.activeCallId.UTF8String), "VideoStopped");
            _rtcManager->muteVideo( true );
        }
    }
}

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIDeviceProximityStateDidChangeNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationDidEnterBackgroundNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationWillEnterForegroundNotification
                                                  object:nil];


    if (_rtcManager != NULL && _rtcEventListener != nil)
    {
        _rtcManager->unsubscribeForEvents(*_rtcEventListener);
    }
    
    if (_restManager != NULL)
    {
        _restManager->unsubscribeForEvents(*_restEventListener.get());
    }
}

//MARK: Internal usage only

#pragma mark -
#pragma mark ProximityNotifications

- ( void )
handleProximityChange:(NSNotification *)notification
{
    BOOL proximityIsActive = [[UIDevice currentDevice] proximityState];
    [self callLocalVideoStateUpdate: !proximityIsActive];
    if (proximityIsActive)
    {
        //Switch call to audio only
        if (self.activeCallId)
        {
            _rtcManager->sendEvent(instac::String(self.activeCallId.UTF8String), "VideoStopped");
            _rtcManager->muteVideo( true );
            
            // automaticalluy switch to earpiece (receiver)
            IMLogDbg("set PreferredAudioOutput: AudioOutputReceiver", 0);
            [[AudioManager sharedInstance] setPreferredAudioOutput:AudioOutputReceiver];
        }
        
    }
    else
    {
        if (self.activeCallId && VideoRouteNone != self.videoRoute )
        {
            _rtcManager->sendEvent(instac::String(self.activeCallId.UTF8String), "VideoStarted");
            _rtcManager->muteVideo( false );
        }
        
        // automaticalluy switch to speaker
        IMLogDbg("set PreferredAudioOutput: AudioOutputSpeaker", 0);
        [[AudioManager sharedInstance] setPreferredAudioOutput:AudioOutputSpeaker];
    }
}

#pragma mark Foreground/Background

- ( void ) applicationDidEnterBackground:(NSNotification *)notification
{
    [self callLocalVideoStateUpdate: NO];
}

- ( void ) applicationDidEnterForeground:(NSNotification *)notification
{
    [self callLocalVideoStateUpdate: YES];
}

#pragma mark - Notifications

- (void) notifyVideoCallDidEstablishTransferCallId:(NSString*)transferCallId
{
//    _qosMonitor->start();
    
    NSMutableDictionary* userInfo = [[NSMutableDictionary alloc] init];
    
    userInfo[kVideoCallManagerActiveVideoCallStateKey] = kVideoCallManagerActiveVideoCallStateEstablished;
    userInfo[kVideoCallManagerActiveVideoCallKey] = [self callById: self.activeCallId];
    
    if (transferCallId != nil)
    {
        userInfo[kVideoCallManagerTransferVideoCallKey] = transferCallId;
    }
    
    [[VDENotificationCenter vdeCenter] postNotificationName: kVideoCallManagerActiveVideoCallNotification
                                                        object: self
                                                      userInfo: userInfo];
}

- (void) notifyVideoCallDidEnd:(NSString*)callId
{
    IMLogDbg("notifyVideoCallDidEnd: %s", callId != nil ? callId.UTF8String : "null");
    
//    _qosMonitor->stop();
    
    if (callId == nil)
    {
        IMLogErr("Cannot send notification for ended call, callId is nil.", 0);
        return;
    }
    
    
    NSMutableDictionary* userInfo = [[NSMutableDictionary alloc] init];
    userInfo[kVideoCallManagerActiveVideoCallStateKey] = kVideoCallManagerActiveVideoCallStateEnded;
    userInfo[kVideoCallManagerActiveVideoCallIdKey] = callId;
    
    [[VDENotificationCenter vdeCenter] postNotificationName: kVideoCallManagerActiveVideoCallNotification
                                                        object: self
                                                      userInfo: userInfo];
}

- (void) notifyVideoCallDidFail: (ErrorCode) code
{
    NSDictionary* userInfo = @{kVideoCallManagerActiveVideoCallStateKey: kVideoCallManagerActiveVideoCallStateFailed,
                               kVideoCallManagerActiveVideoCallStateErrorKey: [NSNumber numberWithUnsignedInt: code]};
    
    [[VDENotificationCenter vdeCenter] postNotificationName: kVideoCallManagerActiveVideoCallNotification
                                                        object: self
                                                      userInfo: userInfo];
}

- (void) notifyChatCallDidEstablish:(LSCall*)chatCall
{
    if (chatCall == nil)
    {
        IMLogErr("Cannot send notification for ended chat call, chatCall is nil.", 0);
        return;
    }
    
    NSDictionary* userInfo = @{kVideoCallManagerActiveChatCallStateKey: kVideoCallManagerActiveChatCallStateEstablished,
                               kVideoCallManagerActiveChatCallKey: chatCall};
    
    [[VDENotificationCenter vdeCenter] postNotificationName: kVideoCallManagerActiveChatCallNotification
                                                        object: self
                                                      userInfo: userInfo];
}

- (void) notifyChatCallDidEnd:(LSCall*)chatCall
{
    if (chatCall == nil)
    {
        IMLogErr("Cannot send notification for ended chat call, chatCall is nil.", 0);
        return;
    }
    
    NSDictionary* userInfo = @{kVideoCallManagerActiveChatCallStateKey: kVideoCallManagerActiveChatCallStateEnded,
                               kVideoCallManagerActiveChatCallKey: chatCall};
    
    [[VDENotificationCenter vdeCenter] postNotificationName: kVideoCallManagerActiveChatCallNotification
                                                        object: self
                                                      userInfo: userInfo];
}

- (void) notifyVideoCallDidStartDialing: (LSCall*) videoCall
{
    if (videoCall == nil)
    {
        IMLogErr("Cannot send notification for video call started dialing, videoCall is nil.", 0);
        return;
    }
    
    NSDictionary* userInfo = @{kVideoCallManagerActiveVideoCallStateKey: kVideoCallManagerActiveVideoCallStateDialing,
                               kVideoCallManagerActiveVideoCallKey: videoCall};
    
    [[VDENotificationCenter vdeCenter] postNotificationName: kVideoCallManagerActiveVideoCallNotification
                                                        object: self
                                                      userInfo: userInfo];
}

- (void) notifyChatCallDidUpdateMessages:(LSParticipant*)visitor
{
    if (visitor == nil)
    {
        IMLogErr("Cannot send notification that chat updated messages, visitor is nil.", 0);
        return;
    }
    
    NSDictionary* userInfo = @{kVideoCallManagerActiveChatCallMessagesKey: @(YES),
                               kVideoCallManagerMessagesOfVisitorKey: visitor};
    
    [[VDENotificationCenter vdeCenter] postNotificationName: kVideoCallManagerActiveChatCallNotification
                                                        object: self
                                                      userInfo: userInfo];
}

- (void) notifyDidUpdateVisitor:(LSParticipant*)visitor
{
    if (visitor == nil)
    {
        IMLogErr("Cannot send notification for updated visitor, visitor is nil.", 0);
        return;
    }
    
    NSDictionary* userInfo = @{kVideoCallManagerVisitorKey: visitor};
    
    [[VDENotificationCenter vdeCenter] postNotificationName: kVideoCallManagerDidUpdateVisitor
                                                        object: self
                                                      userInfo: userInfo];
}

- (void) notifyVisitorDidBecomeInactive:(LSParticipant*)visitor
{
    if (visitor == nil)
    {
        IMLogErr("Cannot send notification that visitor become inactive, visitor is nil.", 0);
        return;
    }
    
    NSDictionary* userInfo = @{kVideoCallManagerVisitorKey: visitor};
    
    [[VDENotificationCenter vdeCenter] postNotificationName: kVideoCallManagerVisitorDidBecomeInactive
                                                        object: self
                                                      userInfo: userInfo];
}

- (void)notifyParticipantAvailabilityChanged:(LSParticipant*)participant
{
    if (participant == nil)
    {
        IMLogErr("Cannot send notification that participant availability changed, particiapnt is nil.", 0);
        return;
    }
    
    NSDictionary* userInfo = @{kParticipantAvailabilityChangedParticipantKey:participant};
    
    [[VDENotificationCenter vdeCenter] postNotificationName: kParticipantAvailabilityChanged
                                                        object: self
                                                      userInfo: userInfo];
}

//MARK: RestEvent
- (void) onRestActionAnonymousLogin: (instac::RestEvent*) event
{
    if (event->getErrorCode() != S_Ok) {
        NSError* error = nil;
        error = [NSError errorWithDomain:@"VideoEngager" code:event->getErrorCode() userInfo:nil];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.joinCompletion(error, nil);
            self.joinCompletion = nil;
        });
    } else {
       IMLogDbg("REST: ActionAnonymousLogin will continue with RTC WS  conection ... ", 0);
    }
}

- (void) onRestEvent: (NSValue*) obj
{
    instac::RestEvent * event = (instac::RestEvent*)[obj pointerValue];
    
    switch (event->getType())
    {
        case instac::RestEvent::ActionCompletion:
        {
            switch (event->getAction()) {
                case instac::IRestManager::ActionAnonymousLogin:
                    IMLogDbg("REST: ActionAnonymousLogin", 0);
                    [self onRestActionAnonymousLogin: event];
                    break;
                default:
                    break;
            }
            
        }
            break;
            
        default:
            break;
    }
}

//MARK: RTCEvent
- (void) onRtcActionDidEstablishCommunicationChannel: (instac::RTCEvent*) event
{
    @synchronized(self)
    {
        if (self.joinCompletion != nil && self.vdeAgent == nil)
        {
            NSError* error = nil;
            
            if (event->getErrorCode() == S_Ok) {
                instac::RefCountPtr<instac::AccountInfo> accountInfo;
                _restManager->getAccountInfo(accountInfo);
                _vdeAgent = [[VDEAgent alloc] initWithInfo:&accountInfo];
                
                const instac::RefCountPtr<instac::IParticipant> participant = _rtcManager->getAgent();
                if (participant.get()) {
                    BOOL available = NO;
                    if (participant->isAvailableForAction(instac::IParticipant::ParticipantActionChat) ||
                        participant->isAvailableForAction(instac::IParticipant::ParticipantActionVideo))
                    {
                        available = YES;
                    }
                    [self.vdeAgent setAvailable: available];
                }
            } else {
                error = [NSError errorWithDomain:@"VideoEngager" code:event->getErrorCode() userInfo:nil];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                self.joinCompletion(error, self.vdeAgent);
                self.joinCompletion = nil;
            });
        }
    }
}

- (void) onRtcActionDidRestoreCommunicationChannel: (instac::RTCEvent*) event
{
}

- (void) onRtcActionDidCloseCommunicationChannel: (instac::RTCEvent*) event
{
}

- (void) processDisconnectEvent:(instac::RTCEvent*) event {
    
    @synchronized(self)
    {
        if (self.disconnectCompletion != nil)
        {
            NSError* error = nil;
            
            if (event->getErrorCode() != S_Ok) {
                error = [NSError errorWithDomain:@"VideoEngager" code:event->getErrorCode() userInfo:nil];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                self.disconnectCompletion(error);
                self.disconnectCompletion = nil;
            });
        }

        // clear the agent now
        _vdeAgent = nil;
    }
}

- (void) onRtcActionCommunicationChannelDidFail: (instac::RTCEvent*) event
{
    [self processDisconnectEvent:event];
}

- (void) onRtcActionCommunicationChannelDidEnd: (instac::RTCEvent*) event
{
    [self processDisconnectEvent:event];
}

- (void) onRtcActionCommunicationChannelDidSuspend: (instac::RTCEvent*) event
{
}

- (void) onRtcActionIncomingCallRequest:  (instac::RTCEvent*) event
{
    /*
    const instac::CallArgs& args = event->getCallArgs();
    NSUUID* uuid = [[NSUUID alloc] initWithUUIDString: OBJCStringA(args.identifier())];
    instac::String name = args.name();
    if (name.empty()) {
        name = instac::IParticipant::identifier2Name(args.visitorId());
    }

    VDECall* call = [VDECall incomingCallWithUUID: uuid
                                       withHandle: OBJCStringA(args.identifier())
                                         withName: OBJCStringA(name)
                                   withTransferId: OBJCStringA(args.refId())
                                         andVideo: YES];
    
    if([self.vdeAgent handleIncomingCall: call]) {
        if([self.delegate respondsToSelector:@selector(didReceiveIncomingCall:)]) {
            [self.delegate didReceiveIncomingCall: call];
        }
    }
     */
}

-(void)onRtcActionParticipantAvailabilityChanged: (instac::RTCEvent*) event
{
    BOOL available = NO;
    const instac::RefCountPtr<instac::IParticipant> participant = event->getParticipant();
    
    if (participant->isAvailableForAction(instac::IParticipant::ParticipantActionChat) ||
        participant->isAvailableForAction(instac::IParticipant::ParticipantActionVideo))
    {
        available = YES;
    }
    
    [self.vdeAgent setAvailable:available];
    
    if([self.delegate respondsToSelector:@selector(didChangeAgentAvailability:)]) {
        [self.delegate didChangeAgentAvailability: available];
    }
    
    LSParticipant* lsPart = [[LSParticipant alloc] initWithModel: &participant];
    [self notifyParticipantAvailabilityChanged: lsPart];

}

- (void)postNotificationDidSetVideoRoute:(NSString*)callId
                              videoRoute:(RTCVideoRoute)videoRoute
{
    NSMutableDictionary* userInfo = [[NSMutableDictionary alloc] init];
    
    if (callId != nil)
    {
        userInfo[kCallIdKey] = callId;
    }
    
    userInfo[kVideoRouteKey] = @(videoRoute);
    
    [[VDENotificationCenter vdeCenter] postNotificationName:kDidSetVideoRouteNotification
                                                     object:self
                                                   userInfo:userInfo];
}

-(void)onRtcActionDidSetVideoRoute: (instac::RTCEvent*) event {
    self.videoRoute = [self rtcVideoRouteFromVideoRoute:event->getVideoRoute()];
    
    LSCall* call = nil;
    
    if (!event->getCallId().empty())
    {
        call = [self callById:OBJCStringA(event->getCallId())];
    }
    
    if (call != nil && self.activeCallId != nil)
    {
        if ([call.callId isEqualToString: self.activeCallId])
        {
            if (VideoRouteNone == _videoRoute)
                _rtcManager->sendEvent(instac::String(call.callId.UTF8String), "VideoStopped");
            else
                _rtcManager->sendEvent(instac::String(call.callId.UTF8String), "VideoStarted");
        }
    }
    
    self.isVideoRouteValueApplied = YES;
    [self postNotificationDidSetVideoRoute:call.callId videoRoute:self.videoRoute];
}

- (void) handleCallEnded: (NSString*) callId
{
    if (callId == nil)
    {
        IMLogErr("Cannot handle call ended, callId is nil.", 0);
        return;
    }
    
//    [[NotificationManager instance] postNotificationStopRinging];
//    [[NotificationManager instance] postNotificationStopRingingDuringCall];
    
    if ([self.activeCallId isEqualToString: callId])
    {
        IMLogDbg("handleCallEnded activeCallId is the same as callId", 0);
        self.activeCallId = nil;
        
        // unmute video on call end in case the call was ended while proximity was on and the local stream was muted
        _rtcManager->muteVideo( false );
        
        [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
        
        [self notifyVideoCallDidEnd:callId];
        
        if (!_rtcManager->hasWebRtcConnection()) {
            [self enableProximitySensor: NO];
        }
    } else {
        IMLogDbg("will not handleCallEnded - activeCallId differs", 0);
    }
}

- (void)onRtcActionDidReceiveCallAnswerTime:(instac::RTCEvent*)event
{
    
    const instac::CallArgs& args = event->getCallArgs();
    if (args.identifier().empty())
    {
        IMLogErr("Cannot handle did receive call answer time, callId is nil.", 0);
        return;
    }

    NSString* callId = OBJCStringA(args.identifier());
    NSDictionary* userInfo = @{kCallIdKey:callId};
    
    [[VDENotificationCenter vdeCenter] postNotificationName:kDidReceiveCallAnswerTime
                                                        object:self
                                                      userInfo:userInfo];
}

- (void) handleCallConnected: (NSString*) callId
              transferCallId:(NSString*)transferCallId
{
    if ([self.activeCallId isEqualToString:callId])
    {
        // this call id is the same call as the current one. ignore this connected event
        return;
    }
    
    self.activeCallId = callId;
    
    [self enableProximitySensor: YES];
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    
    LSCall* call = [self callById:callId];
    call.mute = [self isMuted];
    [self mute:[self isMuted]];
    
    // Notify call was established successfully
    [self notifyVideoCallDidEstablishTransferCallId:transferCallId];
}

- (void) onRtcActionCallConnected: (instac::RTCEvent*) event
{
    const instac::CallArgs& args = event->getCallArgs();
    const instac::CallArgs& transferArgs = event->getTransferCallArgs();
    
    NSString* callIdToUpdate = OBJCStringA(args.identifier());
    NSString* transferCallId = event->hasTransferCallArgs() ? OBJCStringA(transferArgs.identifier()) : nil;
    
    [self handleCallConnected: callIdToUpdate
               transferCallId:transferCallId];
}

- (void) onRtcActionCallPickedupByMe: (instac::RTCEvent*) event
{
    const instac::CallArgs& args = event->getCallArgs();
    NSString* callIdToUpdate = OBJCStringA(args.identifier());
    
    [self handleCallConnected: callIdToUpdate
               transferCallId:nil];
}

- (void) onRtcActionCallPickedupByOther: (instac::RTCEvent*) event
{
    IMLogDbg("%s", __FUNCTION__);
    
    const instac::CallArgs& args = event->getCallArgs();
    NSString* callToHangup = OBJCStringA(args.identifier());
    [self handleCallEnded: callToHangup];
    
//    [self.providerDelegate endCallWithServerId: callToHangup
//                                     andReason:SAEndCallReasonUnspecified];
}

- (void) onRtcActionCallEnded: (instac::RTCEvent*) event
{
    IMLogDbg("%s", __FUNCTION__);
    
    const instac::CallArgs& args = event->getCallArgs();
    NSString* callToHangup = OBJCStringA(args.identifier());
    [self handleCallEnded: callToHangup];
    
//    [self.providerDelegate endCallWithServerId: callToHangup
//                                     andReason: SAEndCallReasonRemoteEnded];
}

- (void) onRtcActionCallFailed: (instac::RTCEvent*) event
{
    [self notifyVideoCallDidFail: event->getErrorCode()];
    
//    if (self.providerDelegate) {
//        const instac::CallArgs& args = event->getCallArgs();
//        NSString* callToFail = OBJCStringA(args.identifier());
//        [self.providerDelegate endCallWithServerId: callToFail
//                                         andReason: SAEndCallReasonFailed];
//    }
}

- (void) onRtcActionCallAcceptFailed: (instac::RTCEvent*) event
{
    const instac::CallArgs& args = event->getCallArgs();
    const instac::RefCountPtr<instac::ICall> aCall = _rtcManager->getCall(args.identifier());
    if (NULL == aCall) {
        IMLogErr("Could not find call with id: %s", args.identifier().c_str());
        return;
    }
    
    if(aCall->callType() == instac::CallTypeChat) {
        IMLogDbg("Ignore call accept failure for chat calls", 0);
        return;
    }
    
    [self notifyVideoCallDidFail: event->getErrorCode()];
    
//    NSString* callToFail = OBJCStringA(args.identifier());
//
//    [self.providerDelegate endCallWithServerId: callToFail
//                                     andReason: SAEndCallReasonFailed];
}

- (void) onRtcActionOutgoingCallRequest: (instac::RTCEvent*) event
{
    // Outgoing call request send. Start dial tone
    /*
     if (nil == self.incomingCallId)
     {
     const instac::CallArgs& args = event->getCallArgs();
     self.incomingCallId = OBJCStringA(args.identifier());
     _callArgs = new instac::CallArgs(args);
     
     // TODO: Post notification start dialing
     
     }
     */
    
    const instac::CallArgs& args = event->getCallArgs();
    NSString* callId = OBJCStringA(args.identifier());
    LSCall* call = [self callById: callId];
    
    if (call != nil) {
        [self notifyVideoCallDidStartDialing: call];
        
//        [self.providerDelegate callWithId:call.clientCallId
//                              setServerId:callId];
    }
}

- (void) onRtcActionDidUpdateAgent: (instac::RTCEvent*) event
{
    const instac::RefCountPtr<instac::IParticipant>& agent = event->getParticipant();
    if (agent.get() != NULL &&  nil != self.vdeAgent) {
        instac::RefCountPtr<instac::AccountInfo> accountInfo;
        _restManager->getAccountInfo(accountInfo);
        _vdeAgent = [[VDEAgent alloc] initWithInfo:&accountInfo];
    }
}

- (void) onRtcEvent: (NSValue*) obj
{
    instac::RTCEvent * event = (instac::RTCEvent*)[obj pointerValue];
    
    switch (event->getType())
    {
        case instac::RTCEvent::ActionCompletion:
        {
            switch (event->getAction()) {
                case instac::IRTCManager::ActionDidEstablishCommunicationChannel:
                    IMLogDbg("RTC: ActionDidEstablishCommunicationChannel", 0);
                    [self onRtcActionDidEstablishCommunicationChannel: event];
                    break;
                case instac::IRTCManager::ActionDidRestoreCommunicationChannel:
                    IMLogDbg("RTC: ActionDidRestoreCommunicationChannel", 0);
                    [self onRtcActionDidRestoreCommunicationChannel: event];
                    break;
                case instac::IRTCManager::ActionDidCloseCommunicationChannel:
                    IMLogDbg("RTC: ActionDidCloseCommunicationChannel", 0);
                    [self onRtcActionDidCloseCommunicationChannel: event];
                    break;
                case instac::IRTCManager::ActionCommunicationChannelDidFail:
                    IMLogDbg("RTC: ActionCommunicationChannelDidFail", 0);
                    [self onRtcActionCommunicationChannelDidFail: event];
                    break;
                case instac::IRTCManager::ActionCommunicationChannelDidEnd:
                    IMLogDbg("RTC: ActionCommunicationChannelDidEnd", 0);
                    [self onRtcActionCommunicationChannelDidEnd: event];
                    break;
                case instac::IRTCManager::ActionCommunicationChannelDidSuspend:
                    IMLogDbg("RTC: ActionCommunicationChannelDidSuspend", 0);
                    [self onRtcActionCommunicationChannelDidSuspend: event];
                    break;
                case instac::IRTCManager::ActionIncomingCallRequest:
                    IMLogDbg("RTC: ActionIncomingCallRequest", 0);
                    [self onRtcActionIncomingCallRequest: event];
                    break;
                case instac::IRTCManager::ActionParticipantAvailabilityChanged:
                    IMLogDbg("RTC: ActionIncomingCallRequest", 0);
                    [self onRtcActionParticipantAvailabilityChanged: event];
                    break;
                case instac::IRTCManager::ActionDidSetVideoRoute:
                    [self onRtcActionDidSetVideoRoute:event];
                    break;
                case instac::IRTCManager::ActionDidReceiveCallAnswerTime:
                    [self onRtcActionDidReceiveCallAnswerTime:event];
                    break;
                case instac::IRTCManager::ActionCallConnected:
                    [self onRtcActionCallConnected: event];
                    break;
                case instac::IRTCManager::ActionCallPickedupByMe:
                    [self onRtcActionCallPickedupByMe: event];
                    break;
                case instac::IRTCManager::ActionCallEnded:
                    [self onRtcActionCallEnded: event];
                    break;
                case instac::IRTCManager::ActionCallPickedupByOther:
                    [self onRtcActionCallPickedupByOther: event];
                    break;
                case instac::IRTCManager::ActionCallFailed:
                    [self onRtcActionCallFailed: event];
                    break;
                case instac::IRTCManager::ActionCallAcceptFailed:
                    [self onRtcActionCallAcceptFailed: event];
                    break;
                case instac::IRTCManager::ActionOutgoingCallRequest:
                    [self onRtcActionOutgoingCallRequest: event];
                    break;
                case instac::IRTCManager::ActionDidSetCallResumed:
                {
                    const instac::CallArgs& callArgs = event->getCallArgs();
                    self.activeCallId = OBJCStringA(callArgs.identifier());
                }
                    break;
                case instac::IRTCManager::ActionDidUpdateAgent:
                    [self onRtcActionDidUpdateAgent: event];
                    break;
                default:
                    break;
            }
        }
            break;
            
        default:
            break;
    }
}

//MARK: Interface

- (void) joinWithAgentPath: (NSString*) agentPath
                  withName: (NSString*) name
                 withEmail: (NSString*) email
                 withPhone: (NSString*) phone
            withCompletion: (void (^__nonnull)(NSError* __nullable error, VDEAgent* __nullable agent)) completionHandler
{
    @synchronized(self) {
        self.externalServerAddress = nil;
        _externalSystemParameters = nil;
        if (nil != self.vdeAgent) {
            NSError* error = [NSError errorWithDomain:@"VideoEngager" code: 100 userInfo:nil];
            completionHandler(error, self.vdeAgent);
        } else {
            ErrorCode code = _restManager->sendReqGetShortUrlInfo(agentPath.UTF8String,
                                                                  self.userAgent.UTF8String);
            if (S_Ok != code) {
                NSError* error = [NSError errorWithDomain:@"VideoEngager" code:code  userInfo: nil];
                completionHandler(error, nil);
            } else {
                self.joinCompletion = completionHandler;
            }
        }
    }
}

- (void) joinWithAgentPath: (NSString*) agentPath
     externalServerAddress: (NSURL   *) externalServerAddress
             withFirstName: (NSString*) firstName
              withLastName: (NSString*) lastName
                 withEmail: (NSString*) email
               withSubject: (NSString*) subject
            withCompletion: (void (^__nonnull)(NSError* __nullable error, VDEAgent* __nullable agent)) completionHandler
{
    @synchronized(self) {
        self.externalServerAddress = externalServerAddress;
        
        NSMutableDictionary* d =
        [[NSMutableDictionary alloc] initWithDictionary: @{@"firstName":firstName,
                                                           @"lastName":firstName
                                                           }];
        if (email.length > 0) {
            d[@"email"] = email;
        }
        if (subject.length > 0) {
            d[@"subject"] = subject;
        }

        _externalSystemParameters = [[NSDictionary alloc] initWithDictionary: d];
        
        if (nil != self.vdeAgent) {
            NSError* error = [NSError errorWithDomain:@"VideoEngager" code: 100 userInfo:nil];
            completionHandler(error, self.vdeAgent);
        } else {
            ErrorCode code = _restManager->sendReqGetShortUrlInfo(agentPath.UTF8String,
                                                                  self.userAgent.UTF8String);
            if (S_Ok != code) {
                NSError* error = [NSError errorWithDomain:@"VideoEngager" code:code  userInfo: nil];
                completionHandler(error, nil);
            } else {
                instac::String name = [[NSString stringWithFormat:@"%@ %@", firstName, lastName] UTF8String];
                _restManager->setVisitorPersonalInfo(email.length > 0 ? email.UTF8String : "",
                                                     "",
                                                     name);
                self.joinCompletion = completionHandler;
            }
        }
    }
}

- (RTCVideoTrack*)localVideoTrack
{
    if (_rtcManager == NULL)
    {
        return nil;
    }
    
    void* localVideoTrack = _rtcManager->getLocalVideoTrack();
    
    if (localVideoTrack == NULL)
    {
        return nil;
    }
    
    RTCVideoTrack* rtcVideoTrack = (__bridge RTCVideoTrack*)localVideoTrack;
    
    return rtcVideoTrack;
}

- (RTCVideoTrack*)remoteVideoTrack
{
    if (_rtcManager == NULL)
    {
        return nil;
    }
    
    void* remoteVideoTrack = _rtcManager->getRemoteVideoTrack();
    
    if (remoteVideoTrack == NULL)
    {
        return nil;
    }
    
    RTCVideoTrack* rtcVideoTrack = (__bridge RTCVideoTrack*)remoteVideoTrack;
    
    return rtcVideoTrack;
}

- (NSError*) startCallWithVideo: (BOOL) withVideo
{
    IMLogDbg("startCallWithVideo %d", withVideo);
    NSError* error = nil;

    @synchronized(self) {
        do {
            if (nil == self.vdeAgent) {
                error = [NSError errorWithDomain:@"VideoEngager" code: 100 userInfo:nil];
                break;
            }

            instac::RefCountPtr<instac::IParticipant> participant = _rtcManager->participantWithId([[self.vdeAgent email] UTF8String]);
            
            if (participant.get() == NULL)
            {
                error = [NSError errorWithDomain:@"VideoEngager" code: E_Failed userInfo:nil];
                break;
            }

            IMLogDbg("startCallWithAgent, participant ID = %s", participant->getId().c_str());
            if (participant->isOutgoingCallPending())
            {
                IMLogDbg("Outgoing video call to participant %s is pending.", participant->getId().c_str());
                error = [NSError errorWithDomain:@"VideoEngager" code: E_Failed userInfo:nil];
                break;
            }
            
            NSString * participantId = OBJCStringA(participant->getId());
            const std::vector<instac::RefCountPtr<instac::ICall>> videoCalls = participant->activeVideoCalls();
            
            if (!videoCalls.empty())
            {
                IMLogDbg("Already have active video call to participant %s", participant->getId().c_str());
                error = [NSError errorWithDomain:@"VideoEngager" code: E_Failed userInfo:nil];
                break;
            }
            
            if (_rtcManager == NULL || !_rtcManager->isConnected()) {
                error = [NSError errorWithDomain:@"VideoEngager" code:E_RtcNotConnected  userInfo: nil];
                break;
            }

            _rtcManager->setLocalMediaTracksEnabled(YES);
            NSUUID* uuid = [NSUUID UUID];
            ErrorCode code = _rtcManager->callParticipantWithAudioOrVideo(participantId.UTF8String, [[uuid UUIDString] UTF8String], withVideo);
            
            if (S_Ok != code) {
                _rtcManager->setLocalMediaTracksEnabled(NO);
                error = [NSError errorWithDomain:@"VideoEngager" code:code  userInfo: nil];
                break;
            }

        } while (false);
    }
    
    return error;
}

- (NSError*)callParticipantWithChat:(NSString*)participantId chatMessage:(NSString*)chatMessage
{
    NSError* error = nil;
    @synchronized(self) {
        do {
            if (_rtcManager != NULL && _rtcManager->isConnected())
            {
                if (participantId == nil)
                {
                    IMLogErr("Cannot call participant with chat, participantId is nil.", 0);
                    error = [NSError errorWithDomain:@"VideoEngager" code:E_Failed  userInfo: nil];
                    break;
                }
                
                if (chatMessage == nil)
                {
                    IMLogErr("Cannot call participant with chat, chatMessage is nil.", 0);
                    error = [NSError errorWithDomain:@"VideoEngager" code:E_Failed  userInfo: nil];
                    break;
                }
                
                ErrorCode errorCode = _rtcManager->callParticipantWithChat(participantId.UTF8String, chatMessage.UTF8String);
                error = [NSError errorWithDomain:@"VideoEngager" code:errorCode  userInfo: nil];
            }
        } while (false);
    }
    
    return error;
}


- (void) disconnectWithCompletion: (void (^__nonnull)(NSError* __nullable error)) completionHandler
{
    @synchronized(self) {
        if (nil == self.vdeAgent) {
            NSError* error = [NSError errorWithDomain:@"VideoEngager" code: 100 userInfo:nil];
            completionHandler(error);
        } else {
            ErrorCode code = _restManager->sendReqLogout();
            if (S_Ok != code) {
                NSError* error = [NSError errorWithDomain:@"VideoEngager" code:code  userInfo: nil];
                completionHandler(error);
            } else {
                self.disconnectCompletion = completionHandler;
            }
        }
    }
}

- (void) rejectIncomingCall: (nonnull VDECall *) call
{
    if([self.vdeAgent rejectIncomingCall: call])
    {
        ErrorCode error = _rtcManager->rejectCall( call.uuid.UUIDString.UTF8String );
        if (S_Ok == error)
        {
            // @TODO: Post Notification to Stop Ringing
            return;
        } else {
            IMLogErr("RTC: Failed to reject call! 0x%lx", error);
        }
    } else {
        IMLogErr("Cannot reject call, VDECall doesn't match to current ringing call.", 0);
    }
}

- (void) acceptIncomingCall: (nonnull VDECall *) call
{
    if([self.vdeAgent acceptIncomingCall: call])
    {
        BOOL fOk = [self acceptCall: call.uuid.UUIDString];
        if (!fOk) {
        }
    } else {
        IMLogErr("Cannot accept call, VDECall doesn't match to current ringing call.", 0);
    }
}

- (VDEAgentViewController*) agentViewController
{
    return [[VDEAgentViewController alloc] initWithInternal: self];
}


- (Contact*) contactForCallWithParticipant: (NSString *) participantId
{
    
    if (participantId == nil)
    {
        IMLogDbg("Cannot find contact, participant is nil.", 0);
        return nil;
    }
    
    IMLogDbg("contactForCallWithParticipant %s", participantId.UTF8String);
    
    Contact* contact = NULL;
    
    if (_rtcManager)
    {
        instac::RefCountPtr<instac::IParticipant> participant = _rtcManager->participantWithId(participantId.UTF8String);
        
        if (participant != NULL)
        {
            contact = [Contact new];
            
            contact.name = OBJCStringA(participant->name());
            contact.email = OBJCStringA(participant->email());
            contact.phone = OBJCStringA(participant->telephone());
            contact.viewing = OBJCStringA(participant->title());
            contact.rating = 0;
            contact.userAgent = OBJCStringA(participant->userAgent());
            
            if (!participant->url().empty())
            {
                NSURL * avatarUrl = [NSURL URLWithString: OBJCStringA(participant->url())];
                if (avatarUrl)
                {
                    // background load image for the contact
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0),
                                   ^{
                                       NSData* avatarData = [NSData dataWithContentsOfURL: avatarUrl];
                                       if ( avatarData )
                                       {
                                           dispatch_async(dispatch_get_main_queue(),
                                                          ^{
                                                              contact.contactImage =
                                                              [UIImage imageWithData: avatarData];
                                                          });
                                       }
                                   });
                }
            }
        }
    }
    
    return contact;
}

- (LSCall*) callById: (NSString*) callId
{
    LSCall* call = nil;
    
    if (_rtcManager != NULL && callId != nil)
    {
        const instac::RefCountPtr<instac::ICall> c = _rtcManager->getCall(callId.UTF8String);
        
        if (c != NULL)
        {
            call = [[LSCall alloc] initWithModel: &c];
        }
    }
    
    return call;
}

- (LSParticipant*)participantWithId:(NSString*)participantId
{
    if (participantId == nil)
    {
        IMLogDbg("Cannot find participant, participant is nil.", 0);
        return nil;
    }
    
    instac::RefCountPtr<instac::IParticipant> participant = _rtcManager->participantWithId(participantId.UTF8String);
    
    if (_rtcManager)
    {
        if (participant != NULL)
        {
            return [[LSParticipant alloc] initWithModel:&participant];
        }
    }
    
    return nil;
}

- (BOOL)isAgent
{
    return _rtcManager->isAgent();
}

- (LSParticipant*)agent
{
    const instac::RefCountPtr<instac::IParticipant> agent = _rtcManager->getAgent();
    
    if (agent == NULL)
    {
        return nil;
    }
    
    return [[LSParticipant alloc] initWithModel:&agent];
}


- (BOOL)requestVisitorInfo:(NSString*)visitorId
{
    if (visitorId == nil)
    {
        IMLogErr("Cannot request visitor info, visitorId is nil.", 0);
        return NO;
    }
    
    ErrorCode errorCode = _rtcManager->requestVisitorPersonalInfo(visitorId.UTF8String);
    
    if (errorCode == S_Ok)
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

- (void) muteCall: (LSCall*)call
{
    if (_rtcManager)
    {
        _rtcManager->mute(true);
        call.mute = YES;
    }
}

- (void) unmuteCall: (LSCall*)call
{
    if (_rtcManager)
    {
        _rtcManager->mute(false);
        call.mute = NO;
    }
}

- (void)mute:(BOOL)isMuted
{
    if (_rtcManager)
    {
        _rtcManager->mute(isMuted);
    }
}

- (BOOL)isMuted
{
    if (_rtcManager)
    {
        return _rtcManager->isMuted();
    }
    
    return false;
}

- (void)holdCall:(NSString*)callId
{
    if (callId == nil)
    {
        IMLogErr("Cannot hold call, callId is nil.", 0);
        return;
    }
    
    _rtcManager->holdCall(callId.UTF8String);
}

- (void)resumeCall:(NSString*)callId
{
    if (callId == nil)
    {
        IMLogErr("Cannot resume call, callId is nil.", 0);
        return;
    }
    
    _rtcManager->resumeCall(callId.UTF8String);
}

- (void)hangupTransferCallAndDeleteVisitor:(LSCall*)call
{
    if (call == nil)
    {
        IMLogErr("Cannot hangup and transfer call, call is nil.", 0);
        return;
    }
    
    if (call.callId == nil)
    {
        IMLogErr("Cannot hangup and transfer call, callId is nil.", 0);
        return;
    }
    
    _rtcManager->hangupTransferCallAndDeleteVisitor(call.callId.UTF8String);
    
    if (!_rtcManager->hasWebRtcConnection()) {
        [self enableProximitySensor: NO];
    }
}

- (void)hangupCall:(LSCall*)call
 completionHandler:(void (^)(BOOL isSuccessful))completionHandler
{
    if (call == nil)
    {
        IMLogErr("Cannot hangupCall, call is nil", 0);
        if (completionHandler)
            completionHandler(NO);
        return;
    }
    
    if (call.callId == nil)
    {
        IMLogErr("Cannot hangupCall, callId is nil", 0);
        if (completionHandler)
            completionHandler(NO);
        return;
    }
    
    [[RtcEventsListener sharedInstance] notifyOnEventActions:@[@(instac::IRTCManager::Action::ActionDidClosePeerConnection)]
                                                     timeout:10
                                           completionHandler:^(instac::RTCEvent *event, BOOL isTimedOut, BOOL *stop) {
                                               
                                               if (!isTimedOut)
                                               {
                                                   instac::String closedConnectionCallId = event->getCallId();
                                                   
                                                   IMLogDbg("[call callId] %s", [call callId].UTF8String);
                                                   
                                                   if ([[call callId] isEqualToString:OBJCStringA(closedConnectionCallId)])
                                                   {
                                                       completionHandler(YES);
                                                       *stop = YES;
                                                   }
                                               }
                                               else
                                               {
                                                   completionHandler(NO);
                                               }
                                           }];
    [self hangupCall:call];
}

- (void) hangupCall: (LSCall*) call
{
    if (call == nil)
    {
        IMLogErr("Cannot hangupCall, call is nil", 0);
        return;
    }
    
    if (call.callId == nil)
    {
        IMLogErr("Cannot hangupCall, callId is nil", 0);
        return;
    }
    
    _rtcManager->hangupCall(call.callId.UTF8String);
    
//    if (!_rtcManager->hasWebRtcConnection()) {
//        [self enableProximitySensor: NO];
//    }
}

- (BOOL) requestVideoRoute: (RTCVideoRoute) route
{
    if (!self.isVideoRouteValueApplied)
    {
        return NO;
    }
    
    // Check if new route is the same as old one
    if (route == _videoRoute )
        return NO;
    
    if (_rtcManager != NULL)
    {
        ErrorCode errorCode = _rtcManager->setVideoCamera([self videoRouteFromRtcVideoRoute:route]);
        
        if (errorCode == S_Ok)
        {
            self.requestedVideoRoute = route;
            self.isVideoRouteValueApplied = NO;
            
            return YES;
        }
    }
    
    return NO;
}

- (void) enableProximitySensor:(BOOL) enable
{
    [[UIDevice currentDevice] setProximityMonitoringEnabled: enable];
}

- (BOOL) acceptCall: (NSString*) videoCallId
{
    if (videoCallId == nil)
    {
        IMLogErr("Cannot accept call, videoCallId is nil.", 0);
        return NO;
    }
    
    if (S_Ok == _rtcManager->acceptCall( videoCallId.UTF8String ))
    {
//        [[NotificationManager instance] postNotificationStopRinging];
//        [[NotificationManager instance] postNotificationStopRingingDuringCall];
        
        const instac::RefCountPtr<instac::ICall> call = _rtcManager->getCall(videoCallId.UTF8String);
        
//        if (!call->isTransfer())
//        {
//            NSString* participantId = OBJCStringA(call->participantId());
//            if ([self isAgent])
//                [self initiateChatCallIfNeededForParticipant:participantId];
//        }
        
        return YES;
    }
    
    return NO;
}

- (BOOL) rejectCall: (NSString*) videoCallId
{
    if (_rtcManager != NULL)
    {
        if (videoCallId == nil)
        {
            IMLogErr("Cannot reject call, videoCallId is nil.", 0);
            return NO;
        }
        
        const instac::RefCountPtr<instac::ICall> videoCall = _rtcManager->getCall(videoCallId.UTF8String);
        if (videoCall != NULL && videoCall->callState() == instac::CallStateRinging)
        {
            ErrorCode code = E_Failed;
            
            if (videoCall->isTransfer())
            {
                code = _rtcManager->rejectTransferCallAndDeleteVisitor(videoCallId.UTF8String);
            }
            else
            {
                code = _rtcManager->rejectCall( videoCallId.UTF8String );
            }
            
            if(S_Ok == code)
            {
//                [[NotificationManager instance] postNotificationStopRinging];
//                [[NotificationManager instance] postNotificationStopRingingDuringCall];
                return YES;
            }
        }
    }
    
    return NO;
}

- (BOOL)hasStableSignalingForCall: (NSString*) callId
{
    if ( NULL != _rtcManager ) {
        return _rtcManager->isSignalingStateStableForCall( [callId UTF8String] );
    }
    
    return NO;
}

- (BOOL)hasStableConnectionForCall: (NSString*) callId
{
    if ( NULL != _rtcManager ) {
        return _rtcManager->isConnectionStateStableForCall( [callId UTF8String] );
    }
    
    return NO;
}

- (NSArray<NSString*>*) endActiveChatCalls {
    
    if (NULL == _rtcManager.get())
        return nil;
    
    if (nil == self.vdeAgent)
        return nil;

    const instac::RefCountPtr<instac::IParticipant> participant =
    _rtcManager->participantWithId([self.vdeAgent.email UTF8String]);
    
    if (NULL == participant.get())
        return nil;
    
    const std::vector<instac::RefCountPtr<instac::ICall>> activeCalls = participant->activeChatCalls();
    
    if (activeCalls.size() == 0)
        return nil;

    if(S_Ok == _rtcManager->hangupCall(activeCalls[0]->callId())) {
        NSMutableArray* result = [[NSMutableArray alloc] init];
        [result addObject: OBJCStringA(activeCalls[0]->callId())];
        return result;
    }
    
    return nil;
}

- (NSArray<NSString*>*) endActiveVideoCalls {
    
    if (NULL == _rtcManager.get())
        return nil;
    
    if (nil == self.vdeAgent)
        return nil;
    
    const instac::RefCountPtr<instac::IParticipant> participant =
    _rtcManager->participantWithId([self.vdeAgent.email UTF8String]);
    
    if (NULL == participant.get())
        return nil;
    
    const std::vector<instac::RefCountPtr<instac::ICall>> activeCalls = participant->activeVideoCalls();
    
    if (activeCalls.size() == 0)
        return nil;

    if(S_Ok == _rtcManager->hangupCall(activeCalls[0]->callId())) {
        NSMutableArray* result = [[NSMutableArray alloc] init];
        [result addObject: OBJCStringA(activeCalls[0]->callId())];
        return result;
    }
    
    return nil;
}

- (void) requestChatFirstName: (NSString*) firstName
                     lastName: (NSString*) lastName
                     nickname: (NSString*) nickname
                      subject: (NSString*) subject
                 emailAddress: (NSString*) emailAddress
                   completion: (void (^__nonnull)(NSData* __nullable data, NSError* __nullable error)) completion
{
    if  ( nil == self.externalServerAddress) {
        NSDictionary<NSErrorUserInfoKey, id> *userInfo = @{NSLocalizedDescriptionKey: @"No external server address provided"};
        NSError* error = [NSError errorWithDomain: NSStringFromClass(self.class)
                                             code: -65801
                                         userInfo: userInfo];
        if (nil != completion) {
            completion(nil, error);
        }
        
        return;
    }
    
    if  ( !((firstName.length > 0 && lastName.length > 0) || nickname.length > 0) ) {
        NSDictionary<NSErrorUserInfoKey, id> *userInfo = @{NSLocalizedDescriptionKey: @"Either nickname or both firstName and lastName should be supplied"};
        NSError* error = [NSError errorWithDomain: NSStringFromClass(self.class)
                                             code: -65802
                                         userInfo: userInfo];
        if (nil != completion) {
            completion(nil, error);
        }
        
        return;
    }
    
    NSMutableDictionary* options =
    [[NSMutableDictionary alloc] initWithDictionary: @{@"userData[veVisitorId]": self.deviceId}];
    
    if ((firstName.length > 0 && lastName.length > 0)) {
        options[@"firstName"] = firstName;
        options[@"lastName"] = lastName;
    }
    
    if (nickname.length > 0 ) {
        options[@"nickname"] = nickname;
    }
    
    if (subject.length > 0) {
        options[@"subject"] = subject;
    }
    
    if (emailAddress.length > 0) {
        options[@"emailAddress"] = emailAddress;
    }
    
    NSURL* url = [self.externalServerAddress URLByAppendingPathComponent: @"/genesys/2/chat/request-chat"];
    NSDictionary* headers = nil;
    
    [self.httpClient post: url
                  headers: headers
              formOptions: options
               completion:^(NSData * _Nullable data, NSError * _Nullable error)
     {
         if (nil != completion) {
             completion(data, error);
         }
     }];
}


- (void) disconnectChatWithId: (NSString* __nonnull) chatId
                       userId: (NSString* __nonnull) userId
                    secureKey: (NSString* __nonnull) secureKey
                        alias: (NSString* __nonnull) alias
                   completion: (void (^__nonnull)(NSData* __nullable data, NSError* __nullable error)) completion
{
    if  ( nil == self.externalServerAddress ) {
        NSDictionary<NSErrorUserInfoKey, id> *userInfo = @{NSLocalizedDescriptionKey: @"No external server address provided"};
        NSError* error = [NSError errorWithDomain: NSStringFromClass(self.class)
                                             code: -65801
                                         userInfo: userInfo];
        if (nil != completion) {
            completion(nil, error);
        }
        
        return;
    }
    
    if  ( chatId.length == 0 || userId.length == 0 || secureKey.length == 0 || alias.length == 0 ) {
        NSDictionary<NSErrorUserInfoKey, id> *userInfo = @{NSLocalizedDescriptionKey: @"Invalid parameters"};
        NSError* error = [NSError errorWithDomain: NSStringFromClass(self.class)
                                             code: -65804
                                         userInfo: userInfo];
        if (nil != completion) {
            completion(nil, error);
        }
        
        return;
    }
    
    NSDictionary* options = @{@"userId": userId,
                              @"secureKey": secureKey,
                              @"alias": alias };
    
    NSString* pathComponent = [NSString stringWithFormat:@"/genesys/2/chat/request-chat/%@/disconnect", chatId];
    NSURL* url = [self.externalServerAddress URLByAppendingPathComponent: pathComponent];
    NSDictionary* headers = nil;
    
    [self.httpClient post: url
                  headers: headers
              formOptions: options
               completion:^(NSData * _Nullable data, NSError * _Nullable error)
     {
         if (nil != completion) {
             completion(data, error);
         }
     }];
}

- (instac::IRTCManager::VideoRoute)videoRouteFromRtcVideoRoute:(RTCVideoRoute)videoRoute
{
    switch (videoRoute)
    {
        case VideoRouteNone:
            return instac::IRTCManager::VideoRouteNone;
        case VideoRouteFront:
            return instac::IRTCManager::VideoRouteFrontCamera;
        case VideoRouteBack:
            return instac::IRTCManager::VideoRouteBackCamera;
        case VideoRouteMax:
            return instac::IRTCManager::VideoRouteMax;
    }
}

- (RTCVideoRoute)rtcVideoRouteFromVideoRoute:(instac::IRTCManager::VideoRoute)videoRoute
{
    switch (videoRoute)
    {
        case instac::IRTCManager::VideoRouteNone:
            return VideoRouteNone;
        case instac::IRTCManager::VideoRouteFrontCamera:
            return VideoRouteFront;
        case instac::IRTCManager::VideoRouteBackCamera:
            return VideoRouteBack;
        case instac::IRTCManager::VideoRouteMax:
            return VideoRouteMax;
    }
}

@end
