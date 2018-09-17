//
//  Contact.h
//  instac
//
//  Created by Bozhko Terziev on 11/26/14.
//  Copyright (c) 2014 SoftAvail. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Contact : NSObject

@property(nonatomic, strong) NSString* name;
@property(nonatomic, strong) NSString* email;
@property(nonatomic, strong) NSString* phone;
@property(nonatomic, strong) NSString* viewing;
@property(nonatomic, strong) UIImage* contactImage;
@property(nonatomic, assign) NSInteger rating;
@property(nonatomic, strong) NSString* userAgent;

@end
