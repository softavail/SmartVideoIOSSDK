//
//  VDEAgentViewController.h
//  VideoEngager
//
//  Created by Angel Terziev on 4.01.18.
//  Copyright © 2018 VideoEngager. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol VDEAgentViewControllerDelegate;

@interface VDEAgentViewController : UIViewController

@property (nonatomic, weak, nullable) id<VDEAgentViewControllerDelegate> delegate;

- (NSError* __nullable) startChat;
- (NSError* __nullable) startAudioCall;
- (NSError* __nullable) startVideoCall;
- (NSError* __nullable) startExternalVideoCall;

- (void) disposeWithCompletion: (void (^__nonnull)(NSError* __nullable error)) completion;

@end


@protocol VDEAgentViewControllerDelegate <NSObject>

- (void) controllerWantsDispose: (VDEAgentViewController *) controller;

@end

NS_ASSUME_NONNULL_END
