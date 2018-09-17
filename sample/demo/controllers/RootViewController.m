//
//  RootViewController.m
//  demo
//
//  Created by Bozhko Terziev on 2.01.18.
//  Copyright © 2018 VideoEngager. All rights reserved.
//

#import "RootViewController.h"
#import "LoginNavigationController.h"

#import "AppDelegate.h"
#import <VideoEngager/VDEAgentViewController.h>
#import "UIColor+Additions.h"

@interface RootViewController () <VDEAgentViewControllerDelegate>

@property(strong, nonatomic) LoginNavigationController* login;
@property(strong, nonatomic) VDEAgentViewController* agentView;
@property(strong, nonatomic) UIViewController* shown;

@end

@implementation RootViewController

#pragma mark Accessors

-(LoginNavigationController *)createLoginView {
    
    LoginNavigationController* login = [self.storyboard instantiateViewControllerWithIdentifier:NSStringFromClass([LoginNavigationController class])];
    
    return login;
}

-(VDEAgentViewController *)createAgentView {
    AppDelegate* appDelegate = (AppDelegate*) [[UIApplication sharedApplication] delegate];
    VDEAgentViewController* controller = [appDelegate.videoEngager agentViewController];
    controller.delegate = self;
    
    return controller;
}

#pragma mark Private Methods

- (void) addChildViewControllerIfNecessary:(UIViewController *)childController {
    
    UIViewController* existing = nil;
    
    for(UIViewController* vc in self.childViewControllers)
    {
        if (vc == childController)
        {
            existing = vc;
            break;
        }
    }
    
    if (!existing) {
        [self addChildViewController: childController];
    }
}

- (void)showController: ( UIViewController* ) controller {
    
    [self addChildViewControllerIfNecessary: controller];
    
    controller.view.frame = self.view.bounds;
    [self.view addSubview:controller.view];
    [controller didMoveToParentViewController:self];
    self.shown = controller;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.login = [self createLoginView];
    
    [self showController:self.login];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    
    UIView *statusBar = [[[UIApplication sharedApplication] valueForKey:@"statusBarWindow"] valueForKey:@"statusBar"];
    
    if ([statusBar respondsToSelector:@selector(setBackgroundColor:)]) {
        statusBar.backgroundColor = [UIColor appBackgroundColor];
    }
    
    return UIStatusBarStyleLightContent;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


- (void)showController:(UIViewController*) viewController animated:(BOOL)animated {

    if (nil == viewController  |self.shown == viewController)
        return;

    if (nil == self.shown) {
        [self showController: viewController];
        return;
    }
    
    [self addChildViewControllerIfNecessary: viewController];

    [self.shown willMoveToParentViewController:nil];
    
    viewController.view.frame = self.view.bounds;
    
    [self transitionFromViewController: self.shown
                      toViewController: viewController
                              duration: animated ? 0.5 : 0.0
                               options:UIViewAnimationOptionTransitionFlipFromLeft
                            animations:^{}
                            completion:^(BOOL finished) {
                                self.shown = viewController;
                                [viewController didMoveToParentViewController:self];
                                
                                NSLog(@"CHILD VIEW CONTROLLERS COUNT: %@", self.childViewControllers);
                            }];
}

- (void)showAgentControllerAnimated:(BOOL)animated {
    if (self.agentView == nil) {
        self.agentView = [self createAgentView];
    }
    
    [self showController:self.agentView animated:YES];
}

- (void)removeAgentController {

    [self showController:self.login animated:NO];

    if (self.agentView != nil) {
        [self.agentView removeFromParentViewController];
        self.agentView.delegate = nil;
        self.agentView = nil;
    }
}


//MARK: VDEAgentViewController delegate

-(void)controllerWantsDispose:(VDEAgentViewController *)controller {
    if (controller == self.agentView) {
        [controller disposeWithCompletion:^(NSError * _Nullable error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                AppDelegate* appDelegate = (AppDelegate*) [[UIApplication sharedApplication] delegate];
                [appDelegate.videoEngager disconnectWithCompletion:^(NSError * _Nullable error) {
                    [self removeAgentController];
                }];
            });
        }];
    }
}

@end
