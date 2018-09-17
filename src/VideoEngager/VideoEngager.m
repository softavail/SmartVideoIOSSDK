//
//  VideoEngager.m
//  VideoEngager
//
//  Created by Angel Terziev on 2.01.18.
//  Copyright © 2018 VideoEngager. All rights reserved.
//

#import "VideoEngager.h"

#import "VDEInternal.h"
#import "VideoEngagerDelegate.h"
#import "AudioManager.h"

static VideoEngager* _videoEngagerInstance = nil;


@interface VideoEngager()
@property (nonatomic, strong) VDEInternal* vde;
@end

@interface VideoEngager(VDEInternalDelegate)<VDEInternalDelegate>
@end

@implementation VideoEngager

@dynamic agent;

//MARK: Accessors

-(VDEAgent *)agent {
    
    return self.vde.vdeAgent;
}

//MARK: Initialize

- (instancetype) init
{
    self = [super init];
    
    if (nil != self) {
    }
    
    return self;
}

- (void) initializeVDEWithContainerPath: (NSURL*) containerPath
                       andServerAddress: (NSURL*) serverAddress
{
    _vde = [[VDEInternal alloc] initWithContainerPath:containerPath
                                    withServerAddress:serverAddress
                                          andDelegate:self];
}

- (void) initializeServerAddress:(NSURL*) serverAddress
{
    _serverAddress = serverAddress;
}

//MARK: Public Interface
+ (VideoEngager *)startWithContainerPath: (NSURL*) containerPath
                        andServerAddress: (NSURL*) serverAddress
{
    VideoEngager* videoEngager = [[self class] sharedInstance];

    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        [videoEngager initializeServerAddress: serverAddress];
        [videoEngager initializeVDEWithContainerPath:containerPath
                                    andServerAddress:serverAddress];
        
        [[AudioManager sharedInstance] requestRecordPermissionsIfNotYet];
    });

    return videoEngager;
}

+ (VideoEngager *)sharedInstance
{
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        _videoEngagerInstance = [[VideoEngager alloc] init];
    });
    
    return _videoEngagerInstance;
}

- (void) joinWithAgentPath: (NSString*) agentPath
                  withName: (NSString*) name
                 withEmail: (NSString*) email
                 withPhone: (NSString*) phone
            withCompletion: (void (^__nonnull)(NSError* __nullable error, VDEAgent* __nullable agent)) completionHandler
{
    [_vde joinWithAgentPath: agentPath
                   withName: name
                  withEmail: email
                  withPhone: phone
             withCompletion: completionHandler];
}

- (void) joinWithAgentPath: (NSString*) agentPath
     externalServerAddress: (NSURL   *) externalServerAddress
             withFirstName: (NSString*) firstName
              withLastName: (NSString*) lastName
                 withEmail: (NSString*) email
               withSubject: (NSString*) subject
            withCompletion: (void (^__nonnull)(NSError* __nullable error, VDEAgent* __nullable agent)) completionHandler
{
    [_vde joinWithAgentPath:agentPath
      externalServerAddress:externalServerAddress
              withFirstName:firstName
               withLastName:lastName
                  withEmail:email
                withSubject:subject
             withCompletion:completionHandler];
}

- (void) disconnectWithCompletion: (void (^__nonnull)(NSError* __nullable error)) completionHandler
{
    [_vde disconnectWithCompletion: completionHandler];
}

- (void) rejectIncomingCall: (nonnull VDECall *) call
{
    [_vde rejectIncomingCall:call];
}

- (void) acceptIncomingCall: (nonnull VDECall *) call
{
    [_vde acceptIncomingCall:call];
}

- (VDEAgentViewController*) agentViewController
{
    return [_vde agentViewController];
}

@end

@implementation VideoEngager(VDEInternalDelegate)

/*
- (void) didReceiveIncomingCall: (nonnull VDECall *) call {

    if ([self.delegate respondsToSelector:@selector(didReceiveIncomingCall:)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate didReceiveIncomingCall:call];
        });
    }
}

- (void) didCancelIncomingCall: (nonnull VDECall *) call {
    if ([self.delegate respondsToSelector:@selector(didCancelIncomingCall:)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate didCancelIncomingCall:call];
        });
    }
}

- (void) didHangupCall: (nonnull VDECall *) call {
    
    if ([self.delegate respondsToSelector:@selector(didHangupCall:)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate didHangupCall:call];
        });
    }
}
*/

- (void)didChangeAgentAvailability:(BOOL)available {
    
    if ([self.delegate respondsToSelector:@selector(didChangeAgentAvailability:)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate didChangeAgentAvailability:available];
        });
    }
}

@end
