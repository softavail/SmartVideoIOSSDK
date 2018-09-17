//
//  DeviceData.h
//  instac
//
//  Created by Bozhko Terziev on 9/9/14.
//  Copyright (c) 2014 SoftAvail. All rights reserved.
//

@interface DeviceData : NSObject 
{
}

@property (nonatomic) BOOL isTaller;
@property (nonatomic) BOOL isiPad;
@property (nonatomic) BOOL isiPhone;
@property (nonatomic) BOOL isiOS7andHigher;
@property (nonatomic) BOOL isiOS8andHigher;
@property (nonatomic) BOOL isiOS10andHigher;
@property (nonatomic) BOOL slideoutLeft;
@property (nonatomic) CGFloat visibleOpenedArea;

@property(nonatomic, strong) NSString* userAgent;

+ ( DeviceData* )
instance;

- ( id )
init;

- ( NSString* )deviceModelName;

- ( BOOL )
isPortrait;

@end
