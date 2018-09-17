//
//  VDEAgentDashboardViewController+Internal.h
//  VideoEngager
//
//  Created by Angel Terziev on 10.01.18.
//  Copyright © 2018 VideoEngager. All rights reserved.
//

#import "VDEInternal.h"

@class VDEInternal;
@class VDEAgentViewController;

@interface VDEAgentDashboardViewController (Internal)

- (instancetype) initWithInternal: (VDEInternal*) vde
          andParentViewController: (VDEAgentViewController*) parentViewController;

@end
