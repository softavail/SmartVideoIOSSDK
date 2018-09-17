//
//  VDEAgentViewController+Internal.h
//  VideoEngager
//
//  Created by Angel Terziev on 8.01.18.
//  Copyright © 2018 VideoEngager. All rights reserved.
//

#import "VideoEngager.h"
#import "VDECall.h"

@class VDEInternal;

@interface VDEAgentViewController (Internal)

- (instancetype) initWithInternal: (VDEInternal*) vde;

- (void) removeVideoSceneViewController;

- (void) wantToClose;

@end
