//
//  VDECall+Internal.h
//  VideoEngager
//
//  Created by Angel Terziev on 4.01.18.
//  Copyright © 2018 VideoEngager. All rights reserved.
//

#import <VideoEngager/VDECall.h>

@interface VDECall (Internal)

+ (instancetype) incomingCallWithUUID: (NSUUID *)uuid
                           withHandle: (NSString *) handle
                             withName: (NSString *) name
                       withTransferId: (NSString *) refId
                             andVideo: (BOOL) withVideo;
@end
