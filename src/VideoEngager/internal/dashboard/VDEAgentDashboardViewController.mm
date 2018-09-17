//
//  VanityViewController.m
//  demo
//
//  Created by Bozhko Terziev on 2.01.18.
//  Copyright © 2018 VideoEngager. All rights reserved.
//

#import "VDEAgentDashboardViewController.h"
#import "VDEAgentDashboardViewController+Internal.h"
#import "VDEAgentViewController.h"
#import "VDEAgentViewController+Internal.h"

#import "VDEAgentDashboardTableViewCell.h"
#import <MessageUI/MFMailComposeViewController.h>

#import "DashboardFooterView.h"
#import "DashboardHeaderView.h"
#import "UIColor+Additions.h"

static NSString* const kVDEAgentDashboardTableViewCellIdentifier = @"VDEAgentDashboardTableViewCell";

@interface AgentAvailabilityItem : NSObject

@property(nonatomic, strong) NSString* title;
@property(nonatomic, assign) SEL selector;
@property(nonatomic, strong) id target;

@end

@implementation AgentAvailabilityItem
@end

@interface VDEAgentDashboardViewController () <MFMailComposeViewControllerDelegate, VDEAgentDashboardTableViewCellDelegate, DashboardFooterViewDelegate>

@property (strong, nonatomic) NSMutableArray* dataSource;
@property (nonatomic) VDEInternal* vde;
@property (nonatomic,weak) VDEAgentViewController* parentController;

@end

@implementation VDEAgentDashboardViewController

-(NSMutableArray *)buildDataSource {
    if (nil != self.vde.externalServerAddress) {
        return [self buildExetrnalDataSource];
    }
    
    return [self buildInternalDataSource];
}

-(NSMutableArray *)buildInternalDataSource {
    
    NSMutableArray* dataSource = [NSMutableArray new];
    
    if ( ![self isAgentAvailable] ) {

        if (self.vde.vdeAgent.phone.length > 0) {

            AgentAvailabilityItem* aiPhone = [AgentAvailabilityItem new];
            aiPhone.title = @"Phone";
            aiPhone.selector = @selector(onPhone);
            aiPhone.target = self;
            [dataSource addObject:aiPhone];
        }

        if (self.vde.vdeAgent.email.length > 0) {

            AgentAvailabilityItem* aiEmail = [AgentAvailabilityItem new];
            aiEmail.title = @"Email";
            aiEmail.selector = @selector(onEmail);
            aiEmail.target = self;
            [dataSource addObject:aiEmail];
        }

    } else {

        if ([self isAgentChatCapable]) {

            AgentAvailabilityItem* aiChat = [AgentAvailabilityItem new];
            aiChat.title = @"Text";
            aiChat.selector = @selector(onChat);
            aiChat.target = self;
            [dataSource addObject:aiChat];
        }

        if ([self isAgentVideoCapable]) {

            AgentAvailabilityItem* aiAudio = [AgentAvailabilityItem new];
            aiAudio.title = @"Audio Only";
            aiAudio.selector = @selector(onAudio);
            aiAudio.target = self;
            [dataSource addObject:aiAudio];

            AgentAvailabilityItem* aiVideo = [AgentAvailabilityItem new];
            aiVideo.title = @"Video";
            aiVideo.selector = @selector(onVideo);
            aiVideo.target = self;
            [dataSource addObject:aiVideo];
        }
    }
    
    return dataSource;
}

-(NSMutableArray *)buildExetrnalDataSource {
    
    NSMutableArray* dataSource = [NSMutableArray new];

    AgentAvailabilityItem* aiCall = [AgentAvailabilityItem new];
    aiCall.title = @"Call";
    aiCall.selector = @selector(onCallExternal);
    aiCall.target = self;
    [dataSource addObject:aiCall];
    
    return dataSource;
}

#pragma mark Private Methods

- (void) dealloc
{
    IMLogDbg("Deallocating... %s", self.description.UTF8String);
    
    [[VDENotificationCenter vdeCenter] removeObserver: self
                                                    name: kParticipantAvailabilityChanged
                                                  object: nil];
    

}

- (void) initMe
{
    [[VDENotificationCenter vdeCenter] addObserver: self
                                          selector: @selector(participantAvailabilityChanged:)
                                              name: kParticipantAvailabilityChanged
                                            object: nil];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    NSBundle* bundle = [NSBundle bundleForClass: [self class]];
    [self.tableView registerNib:[UINib nibWithNibName:@"VDEAgentDashboardTableViewCell" bundle:bundle]
         forCellReuseIdentifier:kVDEAgentDashboardTableViewCellIdentifier];

    [self.tableView setBackgroundView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background"]]];
    
    self.tableView.tableFooterView = [UIView new];
    
    self.tableView.backgroundColor = [UIColor appBackgroundColor];
    
    self.dataSource = [self buildDataSource];
}

-(void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- ( BOOL ) isAgentAvailable {
    
    BOOL available = NO;

    if ( nil != self.vde.vdeAgent )
        available = self.vde.vdeAgent.isAvailable;
    
    return available;
}

- ( BOOL ) isAgentChatCapable {
    
    BOOL capable = NO;
    
    if ( nil != self.vde.vdeAgent )
        capable = self.vde.vdeAgent.isChatCapable;
    
    return capable;
}

- ( BOOL ) isAgentVideoCapable {
    
    BOOL capable = NO;
    
    if ( nil != self.vde.vdeAgent )
        capable = self.vde.vdeAgent.isVideoCapable;
    
    return capable;
}

-(void)participantAvailabilityChanged: (NSNotification*) aNotification
{
    NSDictionary* userInfo = [aNotification userInfo];
    if (nil != userInfo)
    {
        LSParticipant* participant = [userInfo objectForKey: kParticipantAvailabilityChangedParticipantKey];
        if (nil != participant)
        {
            self.dataSource = [self buildDataSource];
            [self.tableView reloadData];
        }
    }
}



#pragma mark UITableView delegates

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.dataSource.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    
    return 54.0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    return 81.0;
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    
    DashboardFooterView *footer = [[[NSBundle bundleForClass:[self class]] loadNibNamed:@"DashboardFooterView" owner:self options:nil] objectAtIndex:0];
    
    if ( nil != footer ) {
        
        footer.delegate = self;
    }

    return footer;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    DashboardHeaderView *header = [[[NSBundle bundleForClass:[self class]] loadNibNamed:@"DashboardHeaderView" owner:self options:nil] objectAtIndex:0];
    
    if ( nil != header ) {
        
        NSString* first = self.vde.vdeAgent.firstName;
        NSString* last  = self.vde.vdeAgent.lastName;
        
        header.strName   = [NSString stringWithFormat:@"%@ %@", first, last];
        header.strPhone  = self.vde.vdeAgent.phone;
        header.strEmail  = self.vde.vdeAgent.email;
        
        [header updateView];
    }
    
    return header;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    VDEAgentDashboardTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:kVDEAgentDashboardTableViewCellIdentifier
                                                                           forIndexPath:indexPath];

    cell.delegate = self;
    
    if ( nil != cell ) {
        
        AgentAvailabilityItem* ai = [self.dataSource objectAtIndex:indexPath.row];
        
        if ( nil != ai ) {
            
            cell.buttonTitle = ai.title;
            cell.ip = indexPath;
            
            [cell updateCell];
        }
    }
    
    return cell;
}

- (nullable NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return indexPath;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 54.0;
}

#pragma mark VDEAgentDashboardTableViewCell Delegate

-(void)didPressButtonForCell:(VDEAgentDashboardTableViewCell*)cell
{
    AgentAvailabilityItem* item = [self.dataSource objectAtIndex: cell.ip.row];
    if (item != nil && item.target != nil && item.selector != nil) {
        [item.target performSelector: item.selector];
    }
}

#pragma mark - MFMailComposeViewControllerDelegate
- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [controller dismissViewControllerAnimated:YES
                                   completion:nil];
}

#pragma mark Footer View Delegates

-(void)didPressCancel {
    NSLog(@"%@", NSStringFromSelector(_cmd));
    [self.parentController wantToClose];
}

#pragma mark Availability Actions

-(void) onPhone {
    
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
    
    if ( self.vde.vdeAgent.phone.length > 0 ) {

        NSURL* phoneUrl = [NSURL URLWithString:[NSString stringWithFormat:@"telprompt:%@", self.vde.vdeAgent.phone]];

        if ([[UIApplication sharedApplication] canOpenURL:phoneUrl])
        {
            [[UIApplication sharedApplication] openURL:phoneUrl options:@{} completionHandler:^(BOOL success) {

            }];
        }
    }
}

-(void) onEmail {
    
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
    
    if ( self.vde.vdeAgent.email.length > 0 ) {

        if([MFMailComposeViewController canSendMail]) {

            MFMailComposeViewController *mailCont = [[MFMailComposeViewController alloc] init];
            mailCont.mailComposeDelegate = self;

            [mailCont setSubject:@""];
            [mailCont setToRecipients:[NSArray arrayWithObject:self.vde.vdeAgent.email]];
            [mailCont setMessageBody:@"" isHTML:NO];

            [self presentViewController:mailCont animated:YES completion:^{

            }];
        }
    }
}

-(void) onChat {
    NSLog(@"%@", NSStringFromSelector(_cmd));
    [self.parentController startChat];
}

-(void) onAudio{
    NSLog(@"%@", NSStringFromSelector(_cmd));
    [self.parentController startAudioCall];
}

-(void) onVideo {
    NSLog(@"%@", NSStringFromSelector(_cmd));
    [self.parentController startVideoCall];
}

-(void) onCallExternal {
    NSLog(@"%@", NSStringFromSelector(_cmd));
    [self.parentController startExternalVideoCall];
}

@end

@implementation VDEAgentDashboardViewController (Internal)

- (instancetype) initWithInternal: (VDEInternal*) vde
          andParentViewController: (VDEAgentViewController*) parentController {
    
    self = [super initWithNibName: @"VDEAgentDashboardViewController"
                           bundle: [NSBundle bundleForClass:[self class]]];
    
    if (nil != self) {
        self.vde = vde;
        self.parentController = parentController;
        
        [self initMe];
    }
    
    return self;
}

@end

