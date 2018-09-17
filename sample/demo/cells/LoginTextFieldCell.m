//
//  LoginTextFieldCell.m
//  leadsecure
//
//  Created by Bozhko Terziev on 9/22/15.
//  Copyright © 2015 SoftAvail. All rights reserved.
//

#import "LoginTextFieldCell.h"
#import "ICOLLTextField.h"
#import "ICOLLRoundedTextFieldView.h"
#import "UIColor+Additions.h"

@interface LoginTextFieldCell () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet ICOLLTextField *textField;
@property (weak, nonatomic) IBOutlet UIImageView *imgView;
@property (weak, nonatomic) IBOutlet ICOLLRoundedTextFieldView *baseRoundedView;
@property (weak, nonatomic) IBOutlet UIImageView *imgViewUnderline;

@end

@implementation LoginTextFieldCell

+ ( LoginTextFieldCell* ) cellForTextField: ( UITextField* ) tf
{
    LoginTextFieldCell* tfCell = nil;
    UIView* sView = tf.superview;
    
    while (sView)
    {
        if ( [sView isKindOfClass:[LoginTextFieldCell class]] )
        {
            tfCell = (LoginTextFieldCell*) sView;
            break;
        }
        
        sView = sView.superview;
    }
    
    return tfCell;
}

- (void)
layoutSubviews
{
    [super layoutSubviews];
}

-(void)hideContent:(BOOL)hide {
    
    self.baseRoundedView.hidden = hide;
    self.imgView.hidden = hide;
    self.textField.hidden = hide;
    self.imgViewUnderline.hidden = hide;
}

- ( void )
setModel:(LoginTextFieldModel *)model
{
    _model = model;
}

- (void)updateCell {
    
    self.baseRoundedView.hasBorder  = self.model.hasBorder;
    self.imgView.image              = self.model.image;
    self.textField.placeholder      = self.model.placeholder;
    self.textField.returnKeyType    = self.model.returnKeyType;
    self.textField.keyboardType     = self.model.keybordType;
    self.textField.secureTextEntry  = self.model.securityText;
    self.textField.text             = self.model.enteredText;
    self.textField.font             = self.model.textFieldFont;
    self.textField.delegate         = self;
    
    NSArray* actions = [self.textField actionsForTarget:self forControlEvent:UIControlEventEditingChanged];
    
    for ( NSString* action in actions )
        [self.textField removeTarget:self action:NSSelectorFromString(action) forControlEvents:UIControlEventEditingChanged];
    
    [self.textField addTarget:self
                       action:@selector(textFieldDidChange:)
             forControlEvents:UIControlEventEditingChanged];
    
    if (nil ==  self.model.idxPath ) {
        
        self.backgroundColor = [UIColor clearColor];
        
    } else {
        
        if (0 == self.model.idxPath.row%2)
            self.backgroundColor = [UIColor cellBackgroundColor];
        else
            self.backgroundColor = [UIColor cellBackgroundColorLight];
    }

    self.baseRoundedView.backgroundColor = self.backgroundColor;
    self.textField.backgroundColor = self.backgroundColor;
}

- ( void )
textFieldDidChange: ( UITextField* ) textField {
    
    if ( nil != self.delegate && [self.delegate respondsToSelector:@selector(textFieldCell:textFieldDidChange:)] )
        [self.delegate textFieldCell:self textFieldDidChange:textField];
    
}

- ( BOOL )
textField                       : ( UITextField *   ) textField
shouldChangeCharactersInRange   : ( NSRange         ) range
replacementString               : ( NSString *      ) string
{
    // Fixed crash on iPad when pressed 'Undo' in sertain cases which overflow buffer in textView.text
    if ( range.location + range.length > textField.text.length )
        return NO;
    
    NSString* newText = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    if ( newText.length > 100 )
        return NO; // Change not allowed
    
    return YES;
}

- ( BOOL )
textFieldShouldClear: ( UITextField * ) textField
{
    return [self.delegate textFieldCell:self textFieldShouldClear:textField];
}

- ( void )
textFieldDidBeginEditing: ( UITextField * ) textField
{
    [self.delegate textFieldCell:self textFieldDidBeginEditing:textField];
}

- ( void )
textFieldDidEndEditing: ( UITextField * ) textField
{
    [self.delegate textFieldCell:self textFieldDidEndEditing:textField];
}

- ( BOOL )
textFieldShouldReturn: ( UITextField * ) textField
{
    return [self.delegate textFieldCell:self textFieldShouldReturn:textField];
}

- ( void )
awakeFromNib
{
    [super awakeFromNib];
    // Initialization code
    
    self.selectionStyle  = UITableViewCellSelectionStyleNone;
    self.textField.backgroundColor = [UIColor cellTextFieldBackgroundColor];
    
    self.imgViewUnderline.backgroundColor = [UIColor clearColor];
    self.imgViewUnderline.image = [[UIImage imageNamed:@"underline"] stretchableImageWithLeftCapWidth:5 topCapHeight:0];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:[UIImage imageNamed:@"clearButton"] forState:UIControlStateNormal];
    [button setFrame:CGRectMake(0.0f, 0.0f, 10.0f, 10.0f)]; // Required for iOS7
    self.textField.rightView = button;
    self.textField.rightViewMode = UITextFieldViewModeWhileEditing;
    [button addTarget:self
               action:@selector(clearText)
     forControlEvents:UIControlEventTouchUpInside];
}

- (void) clearText {
    [self.textField setText:@""];
    
    [self textFieldDidChange:self.textField];
}

- ( void )
setSelected : ( BOOL ) selected
animated    : ( BOOL ) animated
{
    [super setSelected:selected animated:animated];
}

- ( void )
changeBorder
{
    self.baseRoundedView.hasBorder  = self.model.hasBorder;
}

- ( void )
hideKeypad
{
    if ( [self.textField isFirstResponder] )
        [self.textField resignFirstResponder];
}

- ( void )
showKeypad
{
    if ( ![self.textField isFirstResponder] )
        [self.textField becomeFirstResponder];
}

@end
