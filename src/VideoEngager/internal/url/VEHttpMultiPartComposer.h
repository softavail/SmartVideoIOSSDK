//
//  VEHttpMultiPartComposer.h
//  VideoEngager
//
//  Created by Angel Terziev on 31.01.18.
//  Copyright © 2018 VideoEngager. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface VEHttpMultiPartComposer : NSObject

+ (NSData* _Nullable) formDataWithParameters:(NSDictionary * _Nullable)parameters;

@end

NS_ASSUME_NONNULL_END
