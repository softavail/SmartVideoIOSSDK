//
//  AppDelegate.h
//  demo
//
//  Created by Angel Terziev on 2.01.18.
//  Copyright © 2018 VideoEngager. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <VideoEngager/VideoEngager.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property(strong, nonatomic,readonly) VideoEngager* videoEngager;

- (void) initializeVideoEngagerWithServerAddress: (NSURL*) serverAddress;

@end

