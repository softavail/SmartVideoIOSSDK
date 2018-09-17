//
//  DeviceData.m
//  instac
//
//  Created by Bozhko Terziev on 9/9/14.
//  Copyright (c) 2014 SoftAvail. All rights reserved.
//

#import "DeviceData.h"
#import <sys/utsname.h> // for machine name


@implementation DeviceData

static DeviceData	* sharedInstance_;

-(CGFloat)visibleOpenedArea {
    
    CGFloat screenWidth = CGRectGetWidth([[UIScreen mainScreen] bounds]);
    CGFloat openedArea = floorf(0.4 * screenWidth);
    CGFloat minOpenedArea = (screenWidth - 216);
    _visibleOpenedArea  = MIN(minOpenedArea, openedArea);
    
    return _visibleOpenedArea;
}

- ( NSString* )deviceModelName {
    
    struct utsname systemInfo;
    uname(&systemInfo);
    
    return [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
}

- (NSString*) constructUserAgent {
    
    NSString* ua = nil;
    
    NSBundle* mainBundle = [NSBundle mainBundle];
    id appVersion = [mainBundle objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    
#if !TARGET_IPHONE_SIMULATOR
    NSString* model = [self deviceModelName];
#else
    NSString* model = [[UIDevice currentDevice] model];
#endif
    
    NSString* systemVersion = [[UIDevice currentDevice] systemVersion];
    NSString* appName       = [mainBundle objectForInfoDictionaryKey:@"CFBundleName"];
    
    ua = [NSString stringWithFormat:@"%@ OS %@;%@ %@", model, systemVersion, appName, appVersion];
    
    return ua;
}

- ( BOOL )
isiPhoneScreenHigher
{
    if( !self.isiPad )
    {
        if ([[UIScreen mainScreen] respondsToSelector: @selector(scale)])
        {
            CGSize result = [[UIScreen mainScreen] bounds].size;
            result = CGSizeMake(result.width * [UIScreen mainScreen].scale, result.height * [UIScreen mainScreen].scale);
            return (result.height == 960 || result.height == 480) ? NO : YES;
        }
    }
    
    return NO;
}

+ ( DeviceData* )
instance
{
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        sharedInstance_ = [[DeviceData alloc] init];
    });
	
	return sharedInstance_;
}

- ( id )
init
{
	if ( ( self = [super init] ) != nil )
	{
        self.slideoutLeft           = YES;
        self.isiPad                 = ( UIUserInterfaceIdiomPad == UI_USER_INTERFACE_IDIOM());
        self.isiPhone               = ( UIUserInterfaceIdiomPhone == UI_USER_INTERFACE_IDIOM());
        self.isTaller               = [self isiPhoneScreenHigher];
        self.isiOS7andHigher        = ( [[[[[UIDevice currentDevice] systemVersion] componentsSeparatedByString:@"."] objectAtIndex:0] integerValue] >= 7 );
        self.isiOS8andHigher        = ( [[[[[UIDevice currentDevice] systemVersion] componentsSeparatedByString:@"."] objectAtIndex:0] integerValue] >= 8 );
        self.isiOS10andHigher       = ( [[[[[UIDevice currentDevice] systemVersion] componentsSeparatedByString:@"."] objectAtIndex:0] integerValue] >= 10 );
        self.userAgent              = [self constructUserAgent];
	}
	
	return self;
}

- ( BOOL )
isPortrait
{
    return UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation]);
}

- ( void )
dealloc
{
}

@end
