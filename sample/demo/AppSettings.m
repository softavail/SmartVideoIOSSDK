//
//  AppSettings.m
//  instac
//
//  Created by Bozhko Terziev on 9/9/14.
//  Copyright (c) 2014 SoftAvail. All rights reserved.
//

#import "AppSettings.h"

//@property (strong, nonatomic)   NSString* serverUrl;
//@property (strong, nonatomic)   NSString* agentUrl;
//@property (strong, nonatomic)   NSString* firstName;
//@property (strong, nonatomic)   NSString* lastName;
//@property (strong, nonatomic)   NSString* emailGenesys;
//@property (strong, nonatomic)   NSString* subject;
//
//@property (strong, nonatomic)   NSString* agentPath;
//@property (strong, nonatomic)   NSString* name;
//@property (strong, nonatomic)   NSString* email;
//@property (strong, nonatomic)   NSString* phone;

static NSString* const kVEUrlText               = @"kVEUrlText";
static NSString* const kVEGenesys               = @"kVEGenesys";

static NSString* const kVEServerUrl             = @"kVEServerUrl";
static NSString* const kVEAgentUrl              = @"kVEAgentUrl";
static NSString* const kVEFirstName             = @"kVEFirstName";
static NSString* const kVELastName              = @"kVELastName";
static NSString* const kVEEmailGenesys          = @"kVEEmailGenesys";
static NSString* const kVESubject               = @"kVESubject";

static NSString* const kVEAgentPath             = @"kVEAgentPath";
static NSString* const kVEName                  = @"kVEName";
static NSString* const kVEEmail                 = @"kVEEmail";
static NSString* const kVEPhone                 = @"kVEPhone";

@interface AppSettings ()
@end

@implementation AppSettings

#define DEFAULTS_SET(defaults, key, value) \
if ( value ) \
[defaults setObject:value forKey: key]; \
else \
[defaults removeObjectForKey: key];

static AppSettings	*	instance;

+ ( AppSettings* )
instance
{
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        instance = [[super alloc] init];
    });
	
	return instance;
}

- ( id )
init
{
	if ( nil != (self = [super init]) )
	{
        // preferences Push Notification
        NSString* urlText = (NSString*)[[NSUserDefaults standardUserDefaults] objectForKey:kVEUrlText];
        
        if ( nil != urlText )
        {
            self.urlText = urlText;
        }
        else
        {
            NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
            self.urlText = @"";
            DEFAULTS_SET(defaults, kVEUrlText, self.urlText);
        }
        
        NSNumber* genesys = [[NSUserDefaults standardUserDefaults] objectForKey:kVEGenesys];
        
        if ( nil != genesys )
        {
            self.genesys = genesys;
        }
        else
        {
            NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
            self.genesys = @(NO);
            DEFAULTS_SET(defaults, kVEGenesys, self.genesys);
        }
        
        // Genesys Login
        NSString* serverUrl = [[NSUserDefaults standardUserDefaults] objectForKey:kVEServerUrl];
        
        if ( nil != serverUrl )
        {
            self.serverUrl = serverUrl;
        }
        else
        {
            NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
            self.serverUrl = @"";
            DEFAULTS_SET(defaults, kVEServerUrl, self.serverUrl);
        }
        
        NSString* agentUrl = [[NSUserDefaults standardUserDefaults] objectForKey:kVEAgentUrl];
        
        if ( nil != agentUrl )
        {
            self.agentUrl = agentUrl;
        }
        else
        {
            NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
            self.agentUrl = @"";
            DEFAULTS_SET(defaults, kVEAgentUrl, self.agentUrl);
        }
        
        NSString* firstName = [[NSUserDefaults standardUserDefaults] objectForKey:kVEFirstName];
        
        if ( nil != firstName )
        {
            self.firstName = firstName;
        }
        else
        {
            NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
            self.firstName = @"";
            DEFAULTS_SET(defaults, kVEFirstName, self.firstName);
        }

        NSString* lastName = [[NSUserDefaults standardUserDefaults] objectForKey:kVELastName];
        
        if ( nil != lastName )
        {
            self.lastName = lastName;
        }
        else
        {
            NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
            self.lastName = @"";
            DEFAULTS_SET(defaults, kVELastName, self.lastName);
        }

        NSString* emailGenesys = [[NSUserDefaults standardUserDefaults] objectForKey:kVEEmailGenesys];
        
        if ( nil != emailGenesys )
        {
            self.emailGenesys = emailGenesys;
        }
        else
        {
            NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
            self.emailGenesys = @"";
            DEFAULTS_SET(defaults, kVEEmailGenesys, self.emailGenesys);
        }

        NSString* subject = [[NSUserDefaults standardUserDefaults] objectForKey:kVESubject];
        
        if ( nil != subject )
        {
            self.subject = subject;
        }
        else
        {
            NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
            self.subject = @"";
            DEFAULTS_SET(defaults, kVESubject, self.subject);
        }

        // NON Genesys Login
        NSString* agentPath = [[NSUserDefaults standardUserDefaults] objectForKey:kVEAgentPath];
        
        if ( nil != agentPath )
        {
            self.agentPath = agentPath;
        }
        else
        {
            NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
            self.agentPath = @"";
            DEFAULTS_SET(defaults, kVEAgentPath, self.agentPath);
        }

        NSString* name = [[NSUserDefaults standardUserDefaults] objectForKey:kVEName];
        
        if ( nil != name )
        {
            self.name = name;
        }
        else
        {
            NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
            self.name = @"";
            DEFAULTS_SET(defaults, kVEName, self.name);
        }

        NSString* email = [[NSUserDefaults standardUserDefaults] objectForKey:kVEEmail];
        
        if ( nil != email )
        {
            self.email = email;
        }
        else
        {
            NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
            self.email = @"";
            DEFAULTS_SET(defaults, kVEEmail, self.email);
        }

        NSString* phone = [[NSUserDefaults standardUserDefaults] objectForKey:kVEPhone];
        
        if ( nil != phone )
        {
            self.phone = phone;
        }
        else
        {
            NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
            self.phone = @"";
            DEFAULTS_SET(defaults, kVEPhone, self.phone);
        }
    }
    
    return self;
}

-( void )
synchronize
{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];

    DEFAULTS_SET(defaults, kVEUrlText, self.urlText);
    DEFAULTS_SET(defaults, kVEGenesys, self.genesys);
    
    DEFAULTS_SET(defaults, kVEServerUrl,        self.serverUrl);
    DEFAULTS_SET(defaults, kVEAgentUrl,         self.agentUrl);
    DEFAULTS_SET(defaults, kVEFirstName,        self.firstName);
    DEFAULTS_SET(defaults, kVELastName,         self.lastName);
    DEFAULTS_SET(defaults, kVEEmailGenesys,     self.emailGenesys);
    DEFAULTS_SET(defaults, kVESubject,          self.subject);

    DEFAULTS_SET(defaults, kVEAgentPath,        self.agentPath);
    DEFAULTS_SET(defaults, kVEName,             self.name);
    DEFAULTS_SET(defaults, kVEEmail,            self.email);
    DEFAULTS_SET(defaults, kVEPhone,            self.phone);

    [defaults synchronize];
}

@end
