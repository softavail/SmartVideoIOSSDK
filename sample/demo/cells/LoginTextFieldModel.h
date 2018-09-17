//
//  LoginTextViewModel.h
//  leadsecure
//
//  Created by Bozhko Terziev on 9/22/15.
//  Copyright © 2015 SoftAvail. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, SignInCell)
{
    SignInCellAgentPath,
    SignInCellName,
    SignInCellEmail,
    SignInCellPhone,
    SignInCellLast,
};

typedef NS_ENUM(NSUInteger, SignInCellGenesys)
{
    SignInCellGenesysServerUrl,
    SignInCellGenesysAgentUrl,
    SignInCellGenesysFirstName,
    SignInCellGenesysLastName,
    SignInCellGenesysEmail,
    SignInCellGenesysSubject,
    SignInCellGenesysLast,
};


@interface LoginTextFieldModel : NSObject
{
    
}

@property ( nonatomic, strong ) NSString*       enteredText;
@property ( nonatomic, strong ) NSString*       placeholder;
@property ( nonatomic, strong ) UIImage*        image;
@property ( nonatomic, assign ) BOOL            hasBorder;
@property ( nonatomic, assign ) BOOL            securityText;
@property ( nonatomic, assign ) UIReturnKeyType returnKeyType;
@property ( nonatomic, assign ) UIKeyboardType  keybordType;
@property ( nonatomic, assign ) NSInteger       textFieldType;
@property ( nonatomic, strong ) UIFont*         textFieldFont;
@property ( nonatomic, strong ) NSIndexPath*    idxPath;

+(NSString*)loginPlaceholderForCellGenesys:(SignInCellGenesys)cell;
+(UIImage*)loginImageForCellGenesys:(SignInCellGenesys)cell;
+(UIReturnKeyType)loginReturnKeyTypeForCellTypeGenesys:(SignInCellGenesys)cell;
+(UIKeyboardType)loginKeyboardTypeForCellTypeGenesys:(SignInCellGenesys)cell;

+(NSString*)loginPlaceholderForCell:(SignInCell)cell;
+(UIImage*)loginImageForCell:(SignInCell)cell;
+(UIReturnKeyType)loginReturnKeyTypeForCellType:(SignInCell)cell;
+(UIKeyboardType)loginKeyboardTypeForCellType:(SignInCell)cell;
+(NSString*)enteredTextForCell:(SignInCell)cell;
+(NSString*)enteredTextForCellGenesys:(SignInCellGenesys)cell;

@end

