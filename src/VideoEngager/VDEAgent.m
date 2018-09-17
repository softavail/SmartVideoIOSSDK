//
//  VDEAgent.m
//  VideoEngager
//
//  Created by Angel Terziev on 3.01.18.
//  Copyright © 2018 VideoEngager. All rights reserved.
//

#import "VDEAgent.h"
#import "VDECall.h"
#import "VDEAgent+Internal.h"

#include "AccountInfo.h"
#include "IRefCount.h"
#include "RefCountPtr.h"

@interface VDEAgent()

@property (nonatomic) VDECall* call;
@property (nonatomic, strong) UIImage* _avatar;

@end

@implementation VDEAgent
{
    instac::RefCountPtr<instac::AccountInfo> _accountInfo;
}

- (id) initWithInfo: (const void *) info
{
    if (nil != (self = [super init]))
    {
        ASSERT_AND_LOG(info != NULL, "Account Info pointer should not be NULL", 0);
        
        if (info == NULL)
        {
            IMLogErr("Cannot instantiate VDEAgent, info is NULL", 0);
            return nil;
        }
        
        instac::RefCountPtr<instac::AccountInfo>* pAccountInfo = (instac::RefCountPtr<instac::AccountInfo> *) info;
        _accountInfo = *pAccountInfo;
        
        if (_accountInfo == NULL)
        {
            IMLogErr("Cannot instantiate VDEAgent, _accountInfo is NULL", 0);
            return nil;
        }
        
        const instac::String& avData = _accountInfo->getAvatar();
        
        int pos1 = avData.find(":");
        int pos2 = avData.find(";");
        int pos3 = avData.find(",");
        
        if (pos1 >= 0 && pos2 >= 0 && pos3 >= 0)
        {
            instac::String sType = avData.substring(0, pos1);
            instac::String sImg = avData.substring(pos1+1, pos2 - pos1);
            instac::String sEnc = avData.substring(pos2+1, pos3 - pos2);
            instac::String sData = avData.substring(pos3+1, -1);
            
            @autoreleasepool {
                NSString* base64String = [[NSString alloc] initWithUTF8String: sData.c_str()];
                NSData *decodedData = [[NSData alloc] initWithBase64EncodedString:base64String options:NSDataBase64DecodingIgnoreUnknownCharacters];
                self._avatar = [UIImage imageWithData: decodedData];
            }
        }
    }

    return self;
}

- (NSString*) userId
{
    return OBJCStringA(_accountInfo->getUserId());
}

- (NSString*) email
{
    return OBJCStringA(_accountInfo->getEmail());
}

- (NSString*) firstName
{
    return OBJCStringA(_accountInfo->getFirstName());
}

- (NSString*) lastName
{
    return OBJCStringA(_accountInfo->getLastName());
}

- (NSString*) phone
{
    return OBJCStringA(_accountInfo->getPhone());
}

- (NSString*) company
{
    return OBJCStringA(_accountInfo->getCompany());
}

- (NSString*) tenantId
{
    return OBJCStringA(_accountInfo->getTenantId());
}

- (UIImage*) avatar
{
    return self._avatar;
}

- (void) setAvatar: (UIImage*) avatar
{
    self._avatar = avatar;
}

- (BOOL)isChatCapable
{
    return (_accountInfo->isChatCapable() ? YES : NO);
}

- (BOOL) isVideoCapable
{
    return (_accountInfo->isVideoCapable() ? YES : NO);
}

@end

//MARK: VDEAgent(VDECall)
@implementation VDEAgent(Internal)

- (BOOL) handleIncomingCall: (nonnull VDECall *) call
{
    if (self.call == nil) {
        self.call = call;
        return YES;
    }
    
    return NO;
}

- (BOOL) rejectIncomingCall: (nonnull VDECall *) call
{
    if (self.call == call) {
        return YES;
    }
    
    return NO;
}

- (BOOL) acceptIncomingCall: (nonnull VDECall *) call
{
    if (self.call == call) {
        return YES;
    }
    
    return NO;
}

- (void) setAgentAvailability: (BOOL) available {
    
    _available = available;
}


@end
