//
//  NotificationManager.mm
//  instac
//
//  Created by Bozhko Terziev on 11/19/14.
//  Copyright (c) 2014 SoftAvail. All rights reserved.
//

#import "NotificationManager.h"

#import <AVFoundation/AVFoundation.h>


@interface NotificationManager ()
{
}

@end

@implementation NotificationManager

static NotificationManager	*	instance;


+ ( NotificationManager* )
instance
{
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        instance = [[super alloc] init];
    });
	
	return instance;
}

#pragma mark Private
- ( id )
init
{
	if ( nil != (self = [super init]))
	{
        
    }
	
	return self;
}

- (void) dealloc {
    
}

- ( UIViewController* ) rootController {
    
    UIViewController *rootController =[[[[UIApplication sharedApplication] delegate] window] rootViewController];
    
    return rootController;
}

#pragma mark
#pragma Activiti View

- ( void )
showActivityViewWithText: ( NSString * ) text
{
    [self hideActivityViewAnimated:NO];
    
    ICOLLActivityView* av = [[ICOLLActivityView alloc] initWithFrame:[self rootController].view.bounds andActivitySize:ActivitySizeBig];
    
    if ( nil != av )
    {
        _activityView = av;
        
        [av setActivityText: text];
        
        [[self rootController].view addSubview:av];
        [[self rootController].view bringSubviewToFront:av];
    }
}

- ( void )
hideActivityViewAnimated: ( BOOL ) animated
{
    ICOLLActivityView * av = [self activityView];
    
    if ( nil != av )
    {
        [av hideWithAnimation:animated];
        _activityView = nil;
    }
}

- ( void )
hideActivityViewNow
{
    [self hideActivityViewAnimated:NO];
}

- ( void )
hideActivityView
{
    [self hideActivityViewAnimated:YES];
}

@end

