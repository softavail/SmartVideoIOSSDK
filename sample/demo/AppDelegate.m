//
//  AppDelegate.m
//  demo
//
//  Created by Angel Terziev on 2.01.18.
//  Copyright © 2018 VideoEngager. All rights reserved.
//

#import "AppDelegate.h"
#import "UIColor+Additions.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (void) setupAppearence {
    
    [[[[UIApplication sharedApplication] delegate] window] setBackgroundColor:[UIColor navigationBarColor]]; // fixed native navigation controller's bar tint color
    
    [[UIBarButtonItem appearance] setTintColor:[UIColor barButtonItemColor]];
    
    [[UIBarButtonItem appearanceWhenContainedInInstancesOfClasses:@[[UINavigationBar class]]] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                                                                      [UIFont systemFontOfSize:18 weight:UIFontWeightRegular],
                                                                                                                      NSFontAttributeName,
                                                                                                                      nil]
                                                                                                            forState:UIControlStateNormal];
    
    [[UINavigationBar appearance] setTintColor:[UIColor barButtonItemColor]]; // this will change the back button tint
    [[UINavigationBar appearance] setBarTintColor:[UIColor navigationBarColor]];
    
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:20 weight:UIFontWeightLight],
                                                           NSForegroundColorAttributeName : [UIColor barButtonItemColor]}];
    
    [[UITextField appearance] setTintColor:[UIColor textFieldColor]];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    // Override point for customization after application launch.

    [self setupAppearence];

    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- ( NSString* )
supportDirectory
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    NSString *supportDirectory = [paths objectAtIndex:0];
    return supportDirectory;
}

- (void) initializeVideoEngagerWithServerAddress: (NSURL*) serverAddress {

    //NSURL* serverAddress = [NSURL URLWithString:@"https://videome.leadsecure.com"];
    //NSURL* serverAddress = [NSURL URLWithString:@"https://test.videoengager.com"];
    //NSURL* externalServerAddress = [NSURL URLWithString:@"https://gme-004.devcloud.genesys.com:18180"];

    if (nil == _videoEngager) {
        NSURL* containerPath = [NSURL fileURLWithPath: [self supportDirectory]];
        _videoEngager = [VideoEngager startWithContainerPath:containerPath
                                            andServerAddress:serverAddress];
    }
}

@end
