//
//  VEHttpClient.h
//  VideoEngager
//
//  Created by Angel Terziev on 30.01.18.
//  Copyright © 2018 VideoEngager. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface VEHttpClient : NSObject

- (void) get: (NSURL*) url
     headers: (NSDictionary* _Nullable) headers
  completion: (void (^_Nonnull)(NSData* _Nullable data, NSError* _Nullable error)) completion;

- (void) post: (NSURL*) url
      headers: (NSDictionary* _Nullable) headers
  formOptions: (NSDictionary* _Nullable) formOptions
   completion: (void (^_Nonnull)(NSData* _Nullable data, NSError* _Nullable error)) completion;

@end


NS_ASSUME_NONNULL_END
