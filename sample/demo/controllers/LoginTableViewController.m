//
//  LoginTableViewController.m
//  demo
//
//  Created by Bozhko Terziev on 31.01.18.
//  Copyright © 2018 VideoEngager. All rights reserved.
//

#import "LoginTableViewController.h"
#import "RootViewController.h"
#import "LoginTextFieldCell.h"
#import "LoginButtonCell.h"
#import "UIColor+Additions.h"
#import "SwitchView.h"
#import "AppSettings.h"
#import "NotificationManager.h"

#import "AppDelegate.h"

static NSString* const kServerAddress = @"https://videome.leadsecure.com";
static NSString* const kServerAddressTest = @"https://test.videoengager.com";
static NSString* const kServerAddressExternal = @"https://gme-004.devcloud.genesys.com:18180";

@interface LoginTableViewController () <LoginTextFieldCellDelegate, LoginButtonCellDelegate, SwitchViewDelegate>

@property(nonatomic, strong) NSMutableArray* dataSource;
@property(nonatomic, strong) NSMutableArray* dataSourceGenesys;
@property(nonatomic, strong) NSMutableArray* dataSourceNotGenesys;
@property(nonatomic, strong) NSIndexPath* focusedIndexPath;


@end

@implementation LoginTableViewController

#pragma mark Accessors

-(NSMutableArray *)dataSourceGenesys {
    
    if ( nil == _dataSourceGenesys ) {
        
        _dataSourceGenesys = [NSMutableArray new];
            
        for ( SignInCellGenesys sCell = SignInCellGenesysServerUrl; sCell < SignInCellGenesysLast; ++sCell ) {
            
            LoginTextFieldModel* model = [LoginTextFieldModel new];
            
            if ( nil != model )
            {
                model.enteredText   = [[model class] enteredTextForCellGenesys:sCell];
                model.textFieldType = sCell;
                model.hasBorder     = NO;
                model.placeholder   = [[model class] loginPlaceholderForCellGenesys:sCell];
                model.image         = [[model class] loginImageForCellGenesys:sCell];
                model.returnKeyType = [[model class] loginReturnKeyTypeForCellTypeGenesys:sCell];
                model.keybordType   = [[model class] loginKeyboardTypeForCellTypeGenesys:sCell];
                model.securityText  = NO;
                model.textFieldFont = [UIFont systemFontOfSize:17 weight:UIFontWeightRegular];
                
                [_dataSourceGenesys addObject:model];
            }
        }
            
        LoginButtonModel* btnModel = [LoginButtonModel new];
        
        if ( nil != btnModel )
        {
            ButtonType btnType          = ButtonTypeSignIn;
            btnModel.buttonTitle        = [[btnModel class] buttonTitleByType:btnType];
            btnModel.buttonImages       = [[btnModel class] buttonImagesByType:btnType];
            
            btnModel.buttonType         = btnType;
            btnModel.buttonTitleFont    = [UIFont systemFontOfSize:16 weight:UIFontWeightLight];
            btnModel.buttonTitleColor   = [UIColor buttonTextColor];
            btnModel.enabled            =  NO;
            
            [_dataSourceGenesys addObject:btnModel];
        }
    }
    
    return _dataSourceGenesys;
}

-(NSMutableArray *)dataSourceNotGenesys {
    
    if ( nil == _dataSourceNotGenesys ) {
        
        _dataSourceNotGenesys = [NSMutableArray new];
        
        for ( SignInCell sCell = SignInCellAgentPath; sCell < SignInCellLast; ++sCell ) {
            
            LoginTextFieldModel* model = [LoginTextFieldModel new];
            
            if ( nil != model )
            {
                model.enteredText   = [[model class] enteredTextForCell:sCell];
                model.textFieldType = sCell;
                model.hasBorder     = NO;
                model.placeholder   = [[model class] loginPlaceholderForCell:sCell];
                model.image         = [[model class] loginImageForCell:sCell];
                model.returnKeyType = [[model class] loginReturnKeyTypeForCellType:sCell];
                model.keybordType   = [[model class] loginKeyboardTypeForCellType:sCell];
                model.securityText  = NO;
                model.textFieldFont = [UIFont systemFontOfSize:17 weight:UIFontWeightRegular];
                
                [_dataSourceNotGenesys addObject:model];
            }
        }
        
        LoginButtonModel* btnModel = [LoginButtonModel new];
        
        if ( nil != btnModel )
        {
            ButtonType btnType          = ButtonTypeSignIn;
            btnModel.buttonTitle        = [[btnModel class] buttonTitleByType:btnType];
            btnModel.buttonImages       = [[btnModel class] buttonImagesByType:btnType];
            
            btnModel.buttonType         = btnType;
            btnModel.buttonTitleFont    = [UIFont systemFontOfSize:16 weight:UIFontWeightLight];
            btnModel.buttonTitleColor   = [UIColor buttonTextColor];
            btnModel.enabled            =  NO;
            
            [_dataSourceNotGenesys addObject:btnModel];
        }
    }
    
    return _dataSourceNotGenesys;
}

#pragma mark Private

-(void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    [self becomeFirstResponderForIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
}

- ( void )
becomeFirstResponderForIndexPath: ( NSIndexPath* ) ip
{
    LoginTextFieldCell  *cell       = nil;
    
    cell = [self.tableView cellForRowAtIndexPath:ip];
    
    if ( [cell isKindOfClass:[LoginTextFieldCell class]] )
        [cell showKeypad];
}

- (void)setupTableHeader {
    
    SwitchView *swView = [[[NSBundle mainBundle] loadNibNamed:@"SwitchView" owner:self options:nil] lastObject];

    if ( nil != swView ) {
        
        swView.backgroundColor = [UIColor cellBackgroundColorLight];
        swView.delegate = self;
        swView.isOn = [[[AppSettings instance] genesys] boolValue];
        
        [swView updateSwitchView];
        
        swView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        
        self.tableView.tableHeaderView = swView;
    }
}

- (void)changeDataSource {
    
    if ( [[[AppSettings instance] genesys] boolValue] ) {
        
        self.dataSource = self.dataSourceGenesys;
        
    } else {
        
        self.dataSource = self.dataSourceNotGenesys;
    }
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.tableView.backgroundColor = [UIColor appBackgroundColor];
    self.tableView.tableFooterView = [UIView new];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [self setupTableHeader];
    [self changeDataSource];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"LoginTextFieldCell" bundle:nil] forCellReuseIdentifier:NSStringFromClass([LoginTextFieldCell class])];
    [self.tableView registerNib:[UINib nibWithNibName:@"LoginButtonCell" bundle:nil] forCellReuseIdentifier:NSStringFromClass([LoginButtonCell class])];
    
    [self updateButtonSignIn];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- ( void )
resignFirstResponderFromTextFields
{
    NSIndexPath         *indexPath  = nil;
    LoginTextFieldCell  *cell       = nil;
    BOOL foundFirstResponder        = NO;
    
    NSInteger sectionCount = [self.tableView numberOfSections];
    for (NSInteger section = 0; section < sectionCount; ++section)
    {
        NSInteger rowCount = [self.tableView numberOfRowsInSection:section];
        
        for ( NSInteger row = 0; row < rowCount; ++row )
        {
            indexPath = [NSIndexPath indexPathForRow:row inSection:section];
            cell = [self.tableView cellForRowAtIndexPath:indexPath];
            
            if ( [cell isKindOfClass:[LoginTextFieldCell class]] )
            {
                if ( cell.model.hasBorder )
                {
                    [cell hideKeypad];
                    self.focusedIndexPath = nil;
                    
                    foundFirstResponder = YES;
                    break;
                }
            }
        }
        
        if ( foundFirstResponder )
            break;
    }
}

- ( void )
goToNextTextViewFromFirstResponder: ( UITextField * ) tf
{
    LoginTextFieldCell* cell = [LoginTextFieldCell cellForTextField:tf];
    
    if ( nil != cell && [cell isKindOfClass:[LoginTextFieldCell class]] )
    {
        if ( cell.model.returnKeyType == UIReturnKeyDone )
        {
            [self resignFirstResponderFromTextFields];
        }
        else
        {
            NSIndexPath* ipCurrent = [self.tableView indexPathForCell:cell];
            
            CGFloat delay = 0.0;
            
            if ( nil == ipCurrent )
            {
                ipCurrent = self.focusedIndexPath;
                [self.tableView scrollToRowAtIndexPath:ipCurrent atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
                delay = 0.3;
            }
            
            if ( nil != ipCurrent )
            {
                NSIndexPath* ipNext = [NSIndexPath indexPathForRow:ipCurrent.row + 1 inSection:ipCurrent.section];
                
                if ( nil != ipNext )
                {
                    LoginTextFieldCell* next = [self.tableView cellForRowAtIndexPath:ipNext];
                    
                    if ( nil != next && [next isKindOfClass:[LoginTextFieldCell class]] )
                    {
                        [self.tableView scrollToRowAtIndexPath:ipNext atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
                        
                        if ( 0.0 == delay )
                            [next showKeypad];
                        else
                            [next performSelector:@selector(showKeypad) withObject:nil afterDelay:delay];
                        
                        self.focusedIndexPath = ipNext;
                    }
                }
            }
        }
    }
}

- (void)saveDataForTextField: ( UITextField* ) tf {
    
    LoginTextFieldCell* cell = [LoginTextFieldCell cellForTextField:tf];
    
    if ( nil != cell )
        cell.model.enteredText = tf.text;
}

- (void)updateButtonSignIn {
    
    LoginTextFieldModel* tfModel = nil;
    LoginButtonModel* btnModel = nil;
    BOOL genesys = [[[AppSettings instance] genesys] boolValue];
    BOOL enable = YES;
    
    NSInteger count = genesys ? 4 : 1;
    
    for ( NSInteger idx = 0; idx < count; ++idx ) {
        
        id model = [_dataSource objectAtIndex:idx];
        
        if ( [model isKindOfClass:[LoginTextFieldModel class]] ) {
            
            tfModel = (LoginTextFieldModel*)model;
            
            if ( 0 == tfModel.enteredText.length ) {
                enable = NO;
            }
        }
    }
    
    if ( _dataSource.count > ( genesys ? (SignInCellGenesysLast - 1) : (SignInCellLast - 1) ) ) {
        
        btnModel = [_dataSource objectAtIndex:genesys ? SignInCellGenesysLast : SignInCellLast];
        
        if ( [btnModel isKindOfClass:[LoginButtonModel class]] )
            btnModel.enabled = enable;
    }
    
    if ( [[[AppSettings instance] genesys] boolValue] ) {
        
        if ([self.tableView numberOfRowsInSection: 0] > SignInCellGenesysSubject)
        {
            [self.tableView beginUpdates];
            [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:SignInCellGenesysLast
                                                                                               inSection:0]]
                                  withRowAnimation:UITableViewRowAnimationNone];
            [self.tableView endUpdates];
        }
        
    } else {
        
        if ([self.tableView numberOfRowsInSection: 0] > SignInCellPhone)
        {
            [self.tableView beginUpdates];
            [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:SignInCellLast
                                                                                               inSection:0]]
                                  withRowAnimation:UITableViewRowAnimationNone];
            [self.tableView endUpdates];
        }
    }
}

- (void)animatedReloadData {
    
    [self.tableView beginUpdates];
    
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation: [[[AppSettings instance] genesys] boolValue] ? UITableViewRowAnimationRight : UITableViewRowAnimationLeft];
    
    [self.tableView endUpdates];
    
    [self becomeFirstResponderForIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
}

#pragma mark SWitchView Delegates
-(void)didChangeSwitchView:(SwitchView *)swv {
    
    [self resignFirstResponderFromTextFields];
    
    [[AppSettings instance] setGenesys:@(swv.isOn)];
    [[AppSettings instance] synchronize];
    
    [self changeDataSource];
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self performSelector:@selector(animatedReloadData) withObject:nil afterDelay:0.25];
}

#pragma mark UIbutton Delegates

-(void)didPressButton: (UIButton*) button forCell:(LoginButtonCell*) cell {
 
     if ( ![[[AppSettings instance] genesys] boolValue] ) {
         
         if ( self.dataSourceNotGenesys.count > (SignInCellLast - 1) ) {
             
             NSString* agentPath    = nil;
             NSString* name         = nil;
             NSString* email        = nil;
             NSString* phone        = nil;

             LoginTextFieldModel* modelAgentPath    = [self.dataSourceNotGenesys objectAtIndex:SignInCellAgentPath];
             LoginTextFieldModel* modelName         = [self.dataSourceNotGenesys objectAtIndex:SignInCellName];
             LoginTextFieldModel* modelEmail        = [self.dataSourceNotGenesys objectAtIndex:SignInCellEmail];
             LoginTextFieldModel* modelPhone        = [self.dataSourceNotGenesys objectAtIndex:SignInCellPhone];

             if (  SignInCellAgentPath == modelAgentPath.textFieldType )
                 agentPath = modelAgentPath.enteredText;

             if (  SignInCellName == modelName.textFieldType )
                 name = modelName.enteredText;

             if (  SignInCellEmail == modelEmail.textFieldType )
                 email = modelEmail.enteredText;

             if (  SignInCellPhone == modelPhone.textFieldType )
                 phone = modelPhone.enteredText;

             if ( [agentPath length] > 0) {
                 
                 [[AppSettings instance] setAgentPath:agentPath];
                 [[AppSettings instance] setName:name];
                 [[AppSettings instance] setEmail:email];
                 [[AppSettings instance] setPhone:phone];
                 [[AppSettings instance] synchronize];

                 [self joinWithAgentPath: agentPath
                                withName: name
                               withEmail: email
                               withPhone: phone];
                 
                 [[NotificationManager instance] showActivityViewWithText:@"Signing in ..."];
             }
         }
         
     } else {
         
         if ( self.dataSourceGenesys.count > (SignInCellGenesysLast - 1) ) {
         
             NSURL* serverUrl    = nil;
             NSString* agentUrl     = nil;
             NSString* firstName    = nil;
             NSString* lastName     = nil;
             NSString* email        = nil;
             NSString* subject      = nil;

             LoginTextFieldModel* modelServerUrl    = [self.dataSourceGenesys objectAtIndex:SignInCellGenesysServerUrl];
             LoginTextFieldModel* modelAgentUrl     = [self.dataSourceGenesys objectAtIndex:SignInCellGenesysAgentUrl];
             LoginTextFieldModel* modelFirstName    = [self.dataSourceGenesys objectAtIndex:SignInCellGenesysFirstName];
             LoginTextFieldModel* modelLastName     = [self.dataSourceGenesys objectAtIndex:SignInCellGenesysLastName];
             LoginTextFieldModel* modelEmail        = [self.dataSourceGenesys objectAtIndex:SignInCellGenesysEmail];
             LoginTextFieldModel* modelSubject      = [self.dataSourceGenesys objectAtIndex:SignInCellGenesysSubject];
             
             if (  SignInCellGenesysServerUrl == modelServerUrl.textFieldType ){
                 if (modelServerUrl.enteredText.length > 0) {
                     serverUrl = [NSURL URLWithString: modelServerUrl.enteredText];
                 }
             }
             
             if (  SignInCellGenesysAgentUrl == modelAgentUrl.textFieldType )
                 agentUrl = modelAgentUrl.enteredText;

             if (  SignInCellGenesysFirstName == modelFirstName.textFieldType )
                 firstName = modelFirstName.enteredText;

             if (  SignInCellGenesysLastName == modelLastName.textFieldType )
                 lastName = modelLastName.enteredText;
             
             if (  SignInCellGenesysEmail == modelEmail.textFieldType )
                 email = modelEmail.enteredText;

             if (  SignInCellGenesysSubject == modelSubject.textFieldType )
                 subject = modelSubject.enteredText;

             if ( serverUrl != nil && agentUrl.length > 0 && firstName.length > 0 && lastName.length > 0 ) {

                 [[AppSettings instance] setServerUrl:serverUrl.absoluteString];
                 [[AppSettings instance] setAgentUrl:agentUrl];
                 [[AppSettings instance] setFirstName:firstName];
                 [[AppSettings instance] setLastName:lastName];
                 [[AppSettings instance] setEmailGenesys:email];
                 [[AppSettings instance] setSubject:subject];
                 [[AppSettings instance] synchronize];
                
                 [[NotificationManager instance] showActivityViewWithText:@"Signing in ..."];
                 
                 [self joinWithAgentPath:agentUrl
                   externalServerAddress:serverUrl
                           withFirstName:firstName
                            withLastName:lastName
                               withEmail:email
                             withSubject:subject];
             }
         }
     }
}

#pragma mark TextField Delegates

-(void)textFieldCell:(LoginTextFieldCell*)cell textFieldDidChange: ( UITextField* ) textField {
    
    [self saveDataForTextField:textField];
    [self updateButtonSignIn];
}

-(BOOL)textFieldCell:(LoginTextFieldCell*)cell textFieldShouldClear:(UITextField *)textField {
 
    [self saveDataForTextField:textField];
    return YES;
}

-(void)textFieldCell:(LoginTextFieldCell*)cell textFieldDidBeginEditing:(UITextField*)textField {
    
    if ( nil != cell )
    {
        cell.model.hasBorder = YES;
        [cell changeBorder];
        
        self.focusedIndexPath = [self.tableView indexPathForCell:cell];
    }
}

-(void)textFieldCell:(LoginTextFieldCell*)cell textFieldDidEndEditing:(UITextField *)textField {
    
    if ( nil != cell )
    {
        cell.model.hasBorder = NO;
        [cell changeBorder];
        
        self.focusedIndexPath = nil;
    }
}

-(BOOL)textFieldCell:(LoginTextFieldCell*)cell textFieldShouldReturn: ( UITextField * ) textField {
    
    [self goToNextTextViewFromFirstResponder:textField];

    return YES;
}

#pragma mark - Table View Datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.dataSource.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    id model = [self.dataSource objectAtIndex:indexPath.row];
    
    UITableViewCell* cell = nil;
    
    if ( [model isKindOfClass:[LoginButtonModel class]] )
    {
        LoginButtonModel* btnModel = (LoginButtonModel*)model;
        
        LoginButtonCell *buttonCell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([LoginButtonCell class]) forIndexPath:indexPath];
        
        if ( buttonCell ) {
            
            buttonCell.model = btnModel;
            buttonCell.delegate = self;
            
            [buttonCell updateCell];
            
            cell = buttonCell;
        }
        
    } else {
        
        LoginTextFieldModel*tfModel = (LoginTextFieldModel*)model;
        
        LoginTextFieldCell *tfCell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([LoginTextFieldCell class]) forIndexPath:indexPath];
        
        if ( tfCell ) {
            
            tfModel.idxPath = indexPath;
            tfCell.model = tfModel;
            tfCell.delegate = self;
            
            [tfCell updateCell];
            
            cell = tfCell;
        }
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CGFloat height = 54.0;
    
    id model = [self.dataSource objectAtIndex:indexPath.row];
    
    if ( [model isKindOfClass:[LoginButtonModel class]] )
        height = 100.0;
    
    return height;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    return 0.0;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    return nil;
//    SwitchView *swView = [[[NSBundle mainBundle] loadNibNamed:@"SwitchView" owner:self options:nil] lastObject];
//
//    if ( nil != swView ) {
//
//        swView.backgroundColor = [UIColor cellBackgroundColorLight];
//        swView.delegate = self;
//        swView.isOn = [[[AppSettings instance] genesys] boolValue];
//
//        [swView updateSwitchView];
//
//        swView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
//    }
//
//    return swView;
}

//MARK: Login Helpers

-(void)showErrorWithDescription:(NSString*) dsescription {
    
    //A SIMPLE ALERT DIALOG
    UIAlertController *alert =   [UIAlertController alertControllerWithTitle:@"Info"
                                                                     message:dsescription
                                                              preferredStyle:UIAlertControllerStyleAlert];
    
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Ok"
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction *action) {
                                                         
                                                         NSLog(@"OK action");
                                                     }];
    
    [alert addAction:okAction];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void) didJoin
{
    RootViewController* rvc = (RootViewController*)self.parentViewController.parentViewController;
    
    if ( [rvc isKindOfClass:[RootViewController class]] ) {
        [rvc showAgentControllerAnimated: YES];
    }
}

- (void) joinWithAgentPath: (NSString*) agentPath
                  withName: (NSString*) name
                 withEmail: (NSString*) email
                 withPhone: (NSString*) phone
{
    AppDelegate* appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    [appDelegate initializeVideoEngagerWithServerAddress: [NSURL URLWithString: kServerAddressTest]];
    
    [appDelegate.videoEngager joinWithAgentPath: agentPath
                                       withName: name
                                      withEmail: email
                                      withPhone: phone
                                 withCompletion:^(NSError * _Nullable error, VDEAgent * _Nullable agent)
    {
        [[NotificationManager instance] hideActivityView];
        
        if (nil == error) {
            [self didJoin];
        } else {
            [self showErrorWithDescription:error.localizedDescription];
        }
    }];

}

- (void) joinWithAgentPath: (NSString*) agentPath
     externalServerAddress: (NSURL   *) externalServerAddress
             withFirstName: (NSString*) firstName
              withLastName: (NSString*) lastName
                 withEmail: (NSString*) email
               withSubject: (NSString*) subject
{
    AppDelegate* appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    [appDelegate initializeVideoEngagerWithServerAddress: [NSURL URLWithString: kServerAddressTest]];
    
    [appDelegate.videoEngager joinWithAgentPath:agentPath
                          externalServerAddress:externalServerAddress
                                  withFirstName:firstName
                                   withLastName:lastName
                                      withEmail:email
                                    withSubject:subject
                                 withCompletion:^(NSError * _Nullable error, VDEAgent * _Nullable agent)
     {
         [[NotificationManager instance] hideActivityView];
         
         if (nil == error) {
             [self didJoin];
         } else {
             [self showErrorWithDescription:error.localizedDescription];
         }
     }];
    
}

@end
