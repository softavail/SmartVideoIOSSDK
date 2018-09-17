//
//  VideoEngager.h
//  VideoEngager
//
//  Created by Angel Terziev on 2.01.18.
//  Copyright © 2018 VideoEngager. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import <VideoEngager/VDEAgent.h>
#import <VideoEngager/VDEAgentViewController.h>

NS_ASSUME_NONNULL_BEGIN

@protocol VideoEngagerDelegate;

/**
 * VideoEngager. Handles configuration and initialization of VideoEngager.
 */
@interface VideoEngager : NSObject

@property (nonatomic, readonly, copy) NSURL* serverAddress;
@property (nonatomic, readonly, nullable) VDEAgent* agent;
@property (nonatomic, weak, nullable) id<VideoEngagerDelegate> delegate;

/**
 *  The recommended way to install VideoEngager into your application is to place a call to +startWithContainerPath:andServerAddress:
 *  in your -application:didFinishLaunchingWithOptions: or -applicationDidFinishLaunching:
 *  method.
 *
 *  @param containerPath The path where the sdk can cache its data
 *  @param serverAddress The address of the VideoEngager server
 *
 *  @return The singleton VideoEngager instance
 */
+ (VideoEngager *)startWithContainerPath: (NSURL*) containerPath
                        andServerAddress: (NSURL*) serverAddress;

/**
 *  Access the singleton VideoEngager instance.
 *
 *  @return The singleton VideoEngager instance
 */
+ (VideoEngager *)sharedInstance;


/**
 *  Joins the agent by the given path. The process is asynhcronous.
 *
 *  @param agentPath The agent's path (e.g. "john" or "sales/john")
 *  @param name Optional visitor's name
 *  @param email Optional visitor's email address
 *  @param phone Optional visitor's phone number
 *  @param completionHandler A callback called once the join process has been completed
 *
 */
- (void) joinWithAgentPath: (NSString*) agentPath
                  withName: (NSString*) name
                 withEmail: (NSString*) email
                 withPhone: (NSString*) phone
            withCompletion: (void (^__nonnull)(NSError* __nullable error, VDEAgent* __nullable agent)) completionHandler;

/**
 *  Joins the agent by the given url. The process is asynhcronous.
 *
 *  @param agentPath The agent's path (e.g. "john" or "sales/john")
 *  @param externalServerAddress The address of the external system
 *  @param firstName Mandatory visitor's first name
 *  @param lastName Mandatory visitor's last name
 *  @param email Optional visitor's email address
 *  @param subject Optional visitor's subject for the video call
 *  @param completionHandler A callback called once the join process has been completed
 */
- (void) joinWithAgentPath: (NSString*) agentPath
     externalServerAddress: (NSURL   *) externalServerAddress
             withFirstName: (NSString*) firstName
              withLastName: (NSString*) lastName
                 withEmail: (NSString*) email
               withSubject: (NSString*) subject
           withCompletion: (void (^__nonnull)(NSError* __nullable error, VDEAgent* __nullable agent)) completionHandler;

/**
 *  Disconnects from the connected agent if any. The process is asynhcronous.
 *
 *  @param completionHandler A callback called once the disconnect process has been completed
 */
- (void) disconnectWithCompletion: (void (^__nonnull)(NSError* __nullable error)) completionHandler;

- (VDEAgentViewController*) agentViewController;

@end


NS_ASSUME_NONNULL_END
