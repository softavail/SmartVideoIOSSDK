//
//  LoginTextViewModel.m
//  leadsecure
//
//  Created by Bozhko Terziev on 9/22/15.
//  Copyright © 2015 SoftAvail. All rights reserved.
//

#import "LoginTextFieldModel.h"
#import "AppSettings.h"

@implementation LoginTextFieldModel

+(NSString*)loginPlaceholderForCellGenesys:(SignInCellGenesys)cell {
    
    NSString* placeHolder = nil;
    
    switch (cell) {
        case SignInCellGenesysServerUrl:
            placeHolder = @"Server Url";
            break;

        case SignInCellGenesysAgentUrl:
            placeHolder = @"Agent Url";
            break;

        case SignInCellGenesysFirstName:
            placeHolder = @"First Name";
            break;

        case SignInCellGenesysLastName:
            placeHolder = @"Last Name";
            break;

        case SignInCellGenesysEmail:
            placeHolder = @"Email";
            break;

        case SignInCellGenesysSubject:
            placeHolder = @"Subject";
            break;

        default:
            break;
    }
    
    return placeHolder;
}

+(UIImage*)loginImageForCellGenesys:(SignInCellGenesys)cell {
    
    UIImage* img = nil;
    
    switch (cell) {
        case SignInCellGenesysServerUrl:
            img = [UIImage imageNamed:@"imageLink"];
            break;
            
        case SignInCellGenesysAgentUrl:
            img = [UIImage imageNamed:@"imageLink"];
            break;
            
        case SignInCellGenesysFirstName:
            img = [UIImage imageNamed:@"imageFirstLast"];
            break;
            
        case SignInCellGenesysLastName:
            img = [UIImage imageNamed:@"imageFirstLast"];
            break;
            
        case SignInCellGenesysEmail:
            img = [UIImage imageNamed:@"imageEmail"];
            break;
            
        case SignInCellGenesysSubject:
            img = [UIImage imageNamed:@"imageSubject"];
            break;
            
        default:
            break;
    }
    
    return img;
}


+(UIReturnKeyType)loginReturnKeyTypeForCellTypeGenesys:(SignInCellGenesys)cell {
    
    return (cell != SignInCellGenesysSubject) ? UIReturnKeyNext : UIReturnKeyDone;
}

+(UIKeyboardType)loginKeyboardTypeForCellTypeGenesys:(SignInCellGenesys)cell {
    
    UIKeyboardType kt = UIKeyboardTypeDefault;
    
    if ( cell == SignInCellGenesysServerUrl || cell == SignInCellGenesysAgentUrl) {
        
        kt = UIKeyboardTypeURL;
        
    } else if ( cell == SignInCellGenesysFirstName || cell == SignInCellGenesysLastName || cell == SignInCellGenesysSubject ) {
        
        kt = UIKeyboardTypeDefault;
        
    } else if ( cell == SignInCellGenesysEmail ){
    
        kt = UIKeyboardTypeEmailAddress;
        
    } else {
        
        kt = UIKeyboardTypeDefault;
    }
        
    return kt;
}



+(NSString*)loginPlaceholderForCell:(SignInCell)cell {
    
    NSString* placeholder = nil;
    
    switch (cell) {
        case SignInCellAgentPath:
            placeholder = @"Agent Path";
            break;

        case SignInCellName:
            placeholder = @"Name";
            break;

        case SignInCellEmail:
            placeholder = @"Email";
            break;

        case SignInCellPhone:
            placeholder = @"Phone";
            break;

        default:
            break;
    }
    
    return placeholder;
}

+(UIImage*)loginImageForCell:(SignInCell)cell {
    
    UIImage* img = nil;
    
    switch (cell) {
        case SignInCellAgentPath:
            img = [UIImage imageNamed:@"imageLink"];
            break;
            
        case SignInCellName:
            img = [UIImage imageNamed:@"imageFirstLast"];
            break;
            
        case SignInCellEmail:
            img = [UIImage imageNamed:@"imageEmail"];
            break;
            
        case SignInCellPhone:
            img = [UIImage imageNamed:@"imagePhone"];
            break;
            
        default:
            break;
    }
    
    return img;
}

+(UIReturnKeyType)loginReturnKeyTypeForCellType:(SignInCell)cell {
    
    return (cell != SignInCellPhone) ? UIReturnKeyNext : UIReturnKeyDone;

}

+(UIKeyboardType)loginKeyboardTypeForCellType:(SignInCell)cell {
    
    UIKeyboardType kt = UIKeyboardTypeDefault;

    switch (cell) {
        case SignInCellAgentPath:
            kt = UIKeyboardTypeURL;
            break;
            
        case SignInCellName:
            kt = UIKeyboardTypeDefault;
            break;
            
        case SignInCellEmail:
            kt = UIKeyboardTypeEmailAddress;
            break;
            
        case SignInCellPhone:
            kt = UIKeyboardTypeNamePhonePad;
            break;
            
        default:
            break;
    }
    
    return kt;
}

+(NSString*)enteredTextForCell:(SignInCell)cell {
    
    NSString* enteredText = nil;
    
    switch (cell) {
            
        case SignInCellAgentPath:
            enteredText = [[AppSettings instance] agentPath];
            break;
            
        case SignInCellName:
            enteredText = [[AppSettings instance] name];
            break;
            
        case SignInCellEmail:
            enteredText = [[AppSettings instance] email];
            break;
            
        case SignInCellPhone:
            enteredText = [[AppSettings instance] phone];
            break;
            
        default:
            break;
    }
    
    return enteredText;
}

+(NSString*)enteredTextForCellGenesys:(SignInCellGenesys)cell {
    
    NSString* enteredText = nil;
    
    switch (cell) {
        case SignInCellGenesysServerUrl:
            enteredText = [[AppSettings instance] serverUrl];
            break;
            
        case SignInCellGenesysAgentUrl:
            enteredText = [[AppSettings instance] serverUrl];
            break;
            
        case SignInCellGenesysFirstName:
            enteredText = [[AppSettings instance] firstName];
            break;
            
        case SignInCellGenesysLastName:
            enteredText = [[AppSettings instance] lastName];
            break;
            
        case SignInCellGenesysEmail:
            enteredText = [[AppSettings instance] emailGenesys];
            break;
            
        case SignInCellGenesysSubject:
            enteredText = [[AppSettings instance] subject];
            break;
            
        default:
            break;
    }
    
    return enteredText;
}

@end
