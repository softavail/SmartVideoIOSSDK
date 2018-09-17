//
//  LoginTextFieldCell.h
//  leadsecure
//
//  Created by Bozhko Terziev on 9/22/15.
//  Copyright © 2015 SoftAvail. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LoginTextFieldModel.h"

@protocol LoginTextFieldCellDelegate;

@interface LoginTextFieldCell : UITableViewCell
{
}

@property (nonatomic, strong) LoginTextFieldModel* model;
@property (nonatomic, weak) id <LoginTextFieldCellDelegate> delegate;

+ ( LoginTextFieldCell* ) cellForTextField: ( UITextField* ) tf;

-(void)changeBorder;
-(void)hideKeypad;
-(void)showKeypad;
-(void)updateCell;
-(void)hideContent:(BOOL)hide;

@end

@protocol LoginTextFieldCellDelegate <NSObject>

-(void)textFieldCell:(LoginTextFieldCell*)cell textFieldDidChange: ( UITextField* ) textField;

-(BOOL)textFieldCell:(LoginTextFieldCell*)cell textFieldShouldClear:(UITextField *)textField;
-(void)textFieldCell:(LoginTextFieldCell*)cell textFieldDidBeginEditing:(UITextField*)textField;
-(void)textFieldCell:(LoginTextFieldCell*)cell textFieldDidEndEditing:(UITextField *)textField;
-(BOOL)textFieldCell:(LoginTextFieldCell*)cell textFieldShouldReturn: ( UITextField * ) textField;


@end
