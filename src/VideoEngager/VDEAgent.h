//
//  VDEAgent.h
//  VideoEngager
//
//  Created by Angel Terziev on 3.01.18.
//  Copyright © 2018 VideoEngager. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol VDEAgentDelegate;

@interface VDEAgent : NSObject

@property (nonatomic, weak) id<VDEAgentDelegate> delegate;
@property (nonatomic, assign, getter = isAvailable) BOOL available;


- (id) initWithInfo: (const void *) info;
- (NSString*)userId;
- (NSString*)email;
- (NSString*)firstName;
- (NSString*)lastName;
- (NSString*)phone;
- (NSString*)company;
- (NSString*)tenantId;
- (UIImage*)avatar;

- (void) setAvatar: (UIImage*) avatar;

- (BOOL)isChatCapable;
- (BOOL)isVideoCapable;

@end
