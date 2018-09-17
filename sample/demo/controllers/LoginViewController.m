//
//  LoginViewController.m
//  demo
//
//  Created by Bozhko Terziev on 2.01.18.
//  Copyright © 2018 VideoEngager. All rights reserved.
//

#import "LoginViewController.h"
#import "RootViewController.h"
#import "UIColor+Additions.h"
#import "AppSettings.h"

#import "AppDelegate.h"

static NSString* const regexUrl     = @"(((http|https)://)|(www\\.))+(([a-zA-Z0-9\\._-]+\\.[a-zA-Z]{2,6})|([0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}))(/[a-zA-Z0-9\\&amp;%_\\./-~-]*)?";

#define REGEX_TEST(candidate, pattern) \
[[NSPredicate predicateWithFormat:@"SELF MATCHES %@", pattern] evaluateWithObject: candidate]

#define URL_TEST(candidate) \
REGEX_TEST(candidate, regexUrl)

@interface LoginViewController ()

@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UIButton *buttonOk;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activity;
@property (weak, nonatomic) IBOutlet UIView *blueView;
@property (weak, nonatomic) IBOutlet UIImageView *underlineImage;

@end

@implementation LoginViewController

#pragma mark Private Methods

- (UIImage *)imageWithColor:(UIColor *)color {
    
    CGRect rect = CGRectMake(0.0f, 0.0f, 10.0f, 10.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

- (BOOL) isValidUrl:(NSString*) url {
    
    BOOL valid = URL_TEST(url);
    
    return valid;
}

- (void)updateButtonState {
    
    self.buttonOk.enabled = (self.textField.text.length > 0);
}

-(void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
        
    if ( ![self.textField isFirstResponder] ) {
        
        [self.textField becomeFirstResponder];
    }
}

- (void)startActivity: (BOOL) start {
    
    self.activity.hidden = !start;
    self.textField.enabled = !start;
    self.textField.alpha = start ? 0.5 : 1.0;
    
    if ( start )
        [self.activity startAnimating];
    else
        [self.activity stopAnimating];
}

- ( void ) didLogin {
    
    [[AppSettings instance] setUrlText:self.textField.text];
    [[AppSettings instance] synchronize];
    
    RootViewController* rvc = (RootViewController*)self.parentViewController.parentViewController;
    
    if ( [rvc isKindOfClass:[RootViewController class]] ) {
        [rvc showAgentControllerAnimated: YES];
    }
    
    [self startActivity:NO];
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.buttonOk.backgroundColor = [UIColor clearColor];
    
    [self.buttonOk setBackgroundImage:[[UIImage imageNamed:@"buttonNormalState"] resizableImageWithCapInsets:UIEdgeInsetsMake(10.0, 10.0, 10.0, 10)]
                             forState:UIControlStateNormal];
    
    [self.buttonOk setBackgroundImage:[[UIImage imageNamed:@"buttonSelectedState"] resizableImageWithCapInsets:UIEdgeInsetsMake(10.0, 10.0, 10.0, 10)]
                             forState:UIControlStateSelected];
    
    [self.buttonOk setBackgroundImage:[[UIImage imageNamed:@"buttonSelectedState"] resizableImageWithCapInsets:UIEdgeInsetsMake(10.0, 10.0, 10.0, 10)]
                             forState:UIControlStateHighlighted];
    
    [self.textField addTarget:self
                       action:@selector(textFieldDidChange:)
             forControlEvents:UIControlEventEditingChanged];
    
    [self.textField setKeyboardType:UIKeyboardTypeURL];
    
    [self.activity setColor:[UIColor whiteColor]];
    [self.activity setBackgroundColor:[UIColor clearColor]];
    
    [self updateButtonState];
    [self startActivity:NO];
    
    self.blueView.backgroundColor = [UIColor cellBackgroundColor];
    
    self.textField.tintColor = [UIColor whiteColor];
    self.textField.backgroundColor = [UIColor cellBackgroundColor];
    self.textField.textColor = [UIColor textFieldColor];
    self.textField.leftView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"textFieldImageShortUrl"]];
    self.textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Enter short url"
                                                                           attributes:@{ NSFontAttributeName: [UIFont systemFontOfSize:14 weight:UIFontWeightThin],
                                                                                                               NSForegroundColorAttributeName:[UIColor textFieldPlaceholderColor]}];
    
    [self.underlineImage setImage:[[UIImage imageNamed:@"underline"] stretchableImageWithLeftCapWidth:5 topCapHeight:0]];
    
    self.textField.text = [[AppSettings instance] urlText];
    [self updateButtonState];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Actions

-(void)textFieldDidChange: (UITextField*) textField {
    
    if (textField == self.textField) {

        [self updateButtonState];
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    if (textField == self.textField) {
        
    }
    
    return YES;
}

- (IBAction)onOk:(id)sender {
    [self.textField resignFirstResponder];

    [self startActivity: YES];
/*
    AppDelegate* appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    [appDelegate.videoEngager joinWithShortUrl:self.textField.text
                                withCompletion:^(NSError * _Nullable error,
                                                 VDEAgent * _Nullable agent)
    {
        [self startActivity: NO];
        
        if (nil == error) {
            
            [self didLogin];
            
        } else {
            
        }
        
    }];*/
}

@end
