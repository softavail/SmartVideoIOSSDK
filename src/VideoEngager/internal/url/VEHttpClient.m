//
//  VEHttpClient.m
//  VideoEngager
//
//  Created by Angel Terziev on 30.01.18.
//  Copyright © 2018 VideoEngager. All rights reserved.
//

NSInteger const DEFAULT_MAX_RETRY_COUNT = 3;
int64_t const DEFAULT_RETRY_DELAY = 200;
NSInteger const DEFAULT_REQUEST_TIMEOUT_INTERVAL = 30;

#import "VEHttpClient.h"

#import "VEHttpMultiPartComposer.h"

@interface VEHttpClient()

@property (readonly) NSURLSessionConfiguration* configuration;
@property (readonly) NSURLSession* session;

@end


@implementation VEHttpClient

@synthesize configuration=_configuration, session=_session;

//MARK: accessors

-(NSURLSessionConfiguration *)configuration {
    
    if (nil == _configuration) {
        _configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    }
    
    return _configuration;
}

-(NSURLSession *)session {

    if (nil == _session) {
        _session = [NSURLSession sessionWithConfiguration:self.configuration];
    }
    
    return _session;
}

- (void) get: (NSURL*) url
     headers: (NSDictionary* _Nullable) headers
  completion: (void (^_Nonnull)(NSData* _Nullable data, NSError* _Nullable error)) completion
{
    NSLog(@"Debug: [VECLI] %@ URL: %@", NSStringFromSelector(_cmd), url.absoluteString);

    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL: url];
    request.HTTPMethod = @"GET";
    request.timeoutInterval = DEFAULT_REQUEST_TIMEOUT_INTERVAL;
    
    NSArray* allKeys = [headers allKeys];
    for (NSString* key in allKeys) {
        [request addValue: headers[key] forHTTPHeaderField: key];
    }
    
    NSURLSessionDataTask* dataTask =
    [self.session dataTaskWithRequest: request
                    completionHandler:^(NSData * _Nullable data,
                                        NSURLResponse * _Nullable response,
                                        NSError * _Nullable error)
    {
        if (error != nil) {
            if (nil != completion) {
                completion(nil,error);
            }
        } else {
            NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*) response;
            NSLog(@"Debug: [VECLI] %@ didReceiveResponse: %@",
                  NSStringFromSelector(_cmd),
                  httpResponse.description);
            
            if (httpResponse.statusCode >= 200 && httpResponse.statusCode < 300) {
                
                if (nil != completion) {
                    completion(data, nil);
                }
            } else {
                NSDictionary<NSErrorUserInfoKey, id> *userInfo = @{NSLocalizedDescriptionKey: httpResponse.description};
                NSError* httpError = [NSError errorWithDomain: NSStringFromClass(self.class)
                                                         code: httpResponse.statusCode
                                                     userInfo: userInfo];
                if (nil != completion) {
                    completion(nil,httpError);
                }
            }
        }
    }];
    
    [dataTask resume];
}

- (void) post: (NSURL*) url
      headers: (NSDictionary* _Nullable) headers
  formOptions: (NSDictionary* _Nullable) formOptions
   completion: (void (^_Nonnull)(NSData* _Nullable data, NSError* _Nullable error)) completion
{
    NSLog(@"Debug: [VECLI] %@ URL: %@", NSStringFromSelector(_cmd), url.absoluteString);
    
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL: url];
    request.HTTPMethod = @"POST";
    request.timeoutInterval = DEFAULT_REQUEST_TIMEOUT_INTERVAL;
    
    NSArray* allKeys = [headers allKeys];
    for (NSString* key in allKeys) {
        [request addValue: headers[key] forHTTPHeaderField: key];
    }

    // make it x-www-form-urlencoded
    [request addValue: @"application/x-www-form-urlencoded" forHTTPHeaderField: @"Content-Type"];
    
    NSData* formDataBody = [VEHttpMultiPartComposer formDataWithParameters: formOptions];
    
    NSURLSessionUploadTask *uploadTask =
    [self.session uploadTaskWithRequest: request
                               fromData: formDataBody
                      completionHandler: ^(NSData * _Nullable data,
                                           NSURLResponse * _Nullable response,
                                           NSError * _Nullable error)
    {
        if (error != nil) {
            if (nil != completion) {
                completion(nil,error);
            }
        } else {
            NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*) response;
            NSLog(@"Debug: [VECLI] %@ didReceiveResponse: %@",
                  NSStringFromSelector(_cmd),
                  httpResponse.description);
            
            if (httpResponse.statusCode >= 200 && httpResponse.statusCode < 300) {
                
                if (nil != completion) {
                    completion(data,nil);
                }
            } else {
                NSDictionary<NSErrorUserInfoKey, id> *userInfo = @{NSLocalizedDescriptionKey: httpResponse.description};
                NSError* httpError = [NSError errorWithDomain: NSStringFromClass(self.class)
                                                         code: httpResponse.statusCode
                                                     userInfo: userInfo];
                if (nil != completion) {
                    completion(nil,httpError);
                }
            }
        }
    }];
    
    [uploadTask resume];
}
@end
