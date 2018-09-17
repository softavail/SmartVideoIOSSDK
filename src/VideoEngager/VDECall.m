//
//  VDECall.m
//  VideoEngager
//
//  Created by Angel Terziev on 4.01.18.
//  Copyright © 2018 VideoEngager. All rights reserved.
//

#import "VDECall.h"
#import "VDECall+Internal.h"

@implementation VDECall

- (instancetype) initWithUUID: (NSUUID *)uuid
                   withHandle: (NSString *) handle
                     withName: (NSString *) name
               withTransferId: (NSString *) refId
                     andVideo: (BOOL) withVideo
{
    if (nil != (self = [super init])) {
        _uuid = uuid;
        _handle = handle;
        _name = name;
        _hasVideo = withVideo;
    }
    
    return self;
}

@end

@implementation VDECall(Internal)

+ (instancetype) incomingCallWithUUID: (NSUUID *)uuid
                           withHandle: (NSString *) handle
                             withName: (NSString *) name
                       withTransferId: (NSString *) refId
                             andVideo: (BOOL) withVideo
{
    return [[VDECall alloc] initWithUUID: uuid
                              withHandle: handle
                                withName: name
                          withTransferId: refId
                                andVideo: withVideo];
}

@end
