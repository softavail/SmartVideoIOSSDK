//
//  AppSettings.h
//  instac
//
//  Created by Bozhko Terziev on 9/9/14.
//  Copyright (c) 2014 SoftAvail. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AppSettings : NSObject
{
}

+(AppSettings *)instance;
-(void)synchronize;

@property (strong, nonatomic)   NSString* urlText;
@property (strong, nonatomic)   NSNumber* genesys;

@property (strong, nonatomic)   NSString* serverUrl;
@property (strong, nonatomic)   NSString* agentUrl;
@property (strong, nonatomic)   NSString* firstName;
@property (strong, nonatomic)   NSString* lastName;
@property (strong, nonatomic)   NSString* emailGenesys;
@property (strong, nonatomic)   NSString* subject;

@property (strong, nonatomic)   NSString* agentPath;
@property (strong, nonatomic)   NSString* name;
@property (strong, nonatomic)   NSString* email;
@property (strong, nonatomic)   NSString* phone;

@end
