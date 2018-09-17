//
//  VDECall.h
//  VideoEngager
//
//  Created by Angel Terziev on 4.01.18.
//  Copyright © 2018 VideoEngager. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, VDECallType) {
    CallTypeMessaging,
    CallTypeAudioOnly,
    CallTypeVideo
};


@interface VDECall : NSObject

@property (nonatomic, readonly) NSUUID* uuid;
@property (nonatomic, readonly) NSString* handle;
@property (nonatomic, readonly) NSString* name;
@property (nonatomic, readonly) BOOL hasVideo;

@end
