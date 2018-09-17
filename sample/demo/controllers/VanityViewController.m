//
//  VanityViewController.m
//  demo
//
//  Created by Bozhko Terziev on 2.01.18.
//  Copyright © 2018 VideoEngager. All rights reserved.
//

#import "VanityViewController.h"
#import "RootViewController.h"
#import "VanityTableViewCell.h"
#import <VideoEngager/VideoEngagerDelegate.h>
#import <VideoEngager/VDEAgentViewController.h>
#import <MessageUI/MFMailComposeViewController.h>

#import "AppDelegate.h"

@interface AgentAvailabilityItem : NSObject

@property(nonatomic, strong) NSString* title;
@property(nonatomic, assign) SEL selector;
@property(nonatomic, strong) id target;

@end

@implementation AgentAvailabilityItem
@end

@interface VanityViewController () <VideoEngagerDelegate, MFMailComposeViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray* dataSource;

@end

@implementation VanityViewController

-(NSMutableArray *)buildDataSource {
    
    AppDelegate* appDelegate = (AppDelegate*) [[UIApplication sharedApplication] delegate];
                                  
    NSMutableArray* dataSource = [NSMutableArray new];
    
    if ( ![self isAgentAvailable] ) {
        
        if (appDelegate.videoEngager.agent.phone.length > 0) {
            
            AgentAvailabilityItem* aiPhone = [AgentAvailabilityItem new];
            aiPhone.title = @"Phone";
            aiPhone.selector = @selector(onPhone);
            aiPhone.target = self;
            [dataSource addObject:aiPhone];
        }

        if (appDelegate.videoEngager.agent.email.length > 0) {
            
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

#pragma mark Private Methods

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.tableView setBackgroundView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background"]]];
    
    self.tableView.tableFooterView = [UIView new];
    
    AppDelegate* appDelegate = (AppDelegate*) [[UIApplication sharedApplication] delegate];
    appDelegate.videoEngager.delegate = self;
    
    self.dataSource = [self buildDataSource];
}

-(void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- ( BOOL ) isAgentAvailable {

    BOOL available = NO;
    
    AppDelegate* appDelegate = (AppDelegate*) [[UIApplication sharedApplication] delegate];
    
    if ( nil != appDelegate.videoEngager.agent )
        available = appDelegate.videoEngager.agent.isAvailable;

    return available;
}

- ( BOOL ) isAgentChatCapable {
    
    BOOL capable = NO;
    
    AppDelegate* appDelegate = (AppDelegate*) [[UIApplication sharedApplication] delegate];
    
    if ( nil != appDelegate.videoEngager.agent )
        capable = appDelegate.videoEngager.agent.isChatCapable;
    
    return capable;
}

- ( BOOL ) isAgentVideoCapable {
    
    BOOL capable = NO;
    
    AppDelegate* appDelegate = (AppDelegate*) [[UIApplication sharedApplication] delegate];
    
    if ( nil != appDelegate.videoEngager.agent )
        capable = appDelegate.videoEngager.agent.isVideoCapable;
    
    return capable;
}


#pragma mark UITableView delegates

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    VanityTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([VanityTableViewCell class]) forIndexPath:indexPath];

    if ( nil != cell ) {
        
        AgentAvailabilityItem* ai = [self.dataSource objectAtIndex:indexPath.row];
        
        cell.textLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightLight];
        
        cell.userInteractionEnabled = YES;
        cell.selectionStyle = UITableViewCellSelectionStyleGray;

        if ( nil != ai ) {
            
            cell.textLabel.text = ai.title;
        }
    }
    
    return cell;
}

- (nullable NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return indexPath;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    AgentAvailabilityItem* ai = [self.dataSource objectAtIndex:indexPath.row];
    
    if ( nil != ai ) {
        [ai.target performSelector:ai.selector];
    }
}

#pragma mark Actions

- (IBAction)onLogout:(id)sender {
    
    AppDelegate* appDelegate = (AppDelegate*) [[UIApplication sharedApplication] delegate];
                                
    [appDelegate.videoEngager disconnectWithCompletion:^(NSError * _Nullable error) {
        RootViewController* rvc = (RootViewController*)self.parentViewController.parentViewController;
        if ( [rvc isKindOfClass:[RootViewController class]] ) {
            [rvc removeAgentController];
        }
    }];
}

#pragma mark Video Engager Delegate

-(void)didChangeAgentAvailability:(BOOL)available {
    
    self.dataSource = [self buildDataSource];
    [self.tableView reloadData];
}

#pragma mark - MFMailComposeViewControllerDelegate
- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [controller dismissViewControllerAnimated:YES
                                   completion:nil];
}

#pragma mark Availability Actions

-(void) onPhone {
    
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];

    AppDelegate* appDelegate = (AppDelegate*) [[UIApplication sharedApplication] delegate];

    if ( appDelegate.videoEngager.agent.phone.length > 0 ) {
        
        NSURL* phoneUrl = [NSURL URLWithString:[NSString stringWithFormat:@"telprompt:%@", appDelegate.videoEngager.agent.phone]];
        
        if ([[UIApplication sharedApplication] canOpenURL:phoneUrl])
        {
            [[UIApplication sharedApplication] openURL:phoneUrl options:@{} completionHandler:^(BOOL success) {
                
            }];
        }
    }
}

-(void) onEmail {
    
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];

    AppDelegate* appDelegate = (AppDelegate*) [[UIApplication sharedApplication] delegate];
    
    if ( appDelegate.videoEngager.agent.email.length > 0 ) {
        
        if([MFMailComposeViewController canSendMail]) {
            
            MFMailComposeViewController *mailCont = [[MFMailComposeViewController alloc] init];
            mailCont.mailComposeDelegate = self;
            
            [mailCont setSubject:@""];
            [mailCont setToRecipients:[NSArray arrayWithObject:appDelegate.videoEngager.agent.email]];
            [mailCont setMessageBody:@"" isHTML:NO];
            
            [self presentViewController:mailCont animated:YES completion:^{
                
            }];
        }
    }
}

-(void) onChat {
    
    AppDelegate* appDelegate = (AppDelegate*) [[UIApplication sharedApplication] delegate];
    VDEAgentViewController* vc = [appDelegate.videoEngager agentViewController];
    
    [self.navigationController pushViewController:vc animated:YES];
    
    [vc startChat];
}

-(void) onAudio {
    
    AppDelegate* appDelegate = (AppDelegate*) [[UIApplication sharedApplication] delegate];
    VDEAgentViewController* vc = [appDelegate.videoEngager agentViewController];
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [self.navigationController pushViewController:vc animated:YES];
    
    [vc startAudioCall];
}

-(void) onVideo {
    
    AppDelegate* appDelegate = (AppDelegate*) [[UIApplication sharedApplication] delegate];
    VDEAgentViewController* vc = [appDelegate.videoEngager agentViewController];
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [self.navigationController pushViewController:vc animated:YES];
    
    [vc startVideoCall];
}

@end
