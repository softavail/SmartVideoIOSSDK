//
//  VideoEngagerDelegate.h
//  VideoEngager
//
//  Created by Angel Terziev on 4.01.18.
//  Copyright © 2018 VideoEngager. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <VideoEngager/VideoEngager.h>

@protocol VideoEngagerDelegate <NSObject>

/**
 * Notifies the delegate for agent availability changes
 */
- (void) didChangeAgentAvailability:(BOOL)available;

@end
