//
//  LSEndPoint.h
//  leadsecure
//
//  Created by Bozhko Terziev on 12/13/16.
//  Copyright © 2016 SoftAvail. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LSEndPoint : NSObject

@property (nonatomic) BOOL isIndividal;
@property (nonatomic) BOOL isAvailableForChat;
@property (nonatomic) BOOL isAvailableForVideo;
@property (nonatomic, strong) NSString* name;
@property (nonatomic, strong) NSString* identifier;

@end
