//
//  CallsOnHoldView.m
//  leadsecure
//
//  Created by ivan shulev on 3/25/16.
//  Copyright © 2016 SoftAvail. All rights reserved.
//

#import "CallsOnHoldView.h"

#import "PureLayout.h"
#import "UIColor+Additions.h"

#import "LSParticipantsResult.h"

static NSString* kCallOnHoldTableViewCell = @"kCallOnHoldTableViewCell";
static CGFloat kRowHeight = 50.0;
static NSUInteger kMaxRowsCount = 4;

@interface CallsOnHoldView ()

@property (nonatomic) ListParticipantsOnHoldOperation* listParticipantsOnHoldOperation;
@property (nonatomic) LSParticipantsResult* participantsResult;
@property (nonatomic, weak) UITableView* tableView;
@property (nonatomic) NSLayoutConstraint* tableViewHeightConstraint;

@end

@implementation CallsOnHoldView
{
    
    BOOL _didSetConstraints;
}

+ (BOOL)requiresConstraintBasedLayout
{
    return YES;
}

- (instancetype)initWithListParticipants:(ListParticipantsOnHoldOperation*)listParticipantsOnHoldOperation
{
    self = [super init];
    
    if (self == nil)
    {
        return nil;
    }


    self.listParticipantsOnHoldOperation = listParticipantsOnHoldOperation;
    self.participantsResult = self.listParticipantsOnHoldOperation.participantsResult;
    
    self.translatesAutoresizingMaskIntoConstraints = NO;
    self.backgroundColor = [UIColor clearColor];
    
    [self setupTableView];
    [self setupChangesListener];
    
    return self;
}

- (void) dealloc
{
    IMLogDbg("Deallocating ... %s", self.description.UTF8String);
}

- (void)setupTableView
{
    UITableView* tableView = [[UITableView alloc] init];
    tableView.translatesAutoresizingMaskIntoConstraints = NO;
    tableView.backgroundColor = [UIColor contactInfoViewColor];
    tableView.rowHeight = kRowHeight;
    tableView.separatorColor = [UIColor clearColor];
    tableView.dataSource = self;
    tableView.delegate = self;
    tableView.allowsSelection = NO;
    [tableView registerClass:[CallOnHoldTableViewCell class] forCellReuseIdentifier:kCallOnHoldTableViewCell];
    
    [self addSubview: tableView];
    self.tableView = tableView;
}

- (void)setupChangesListener
{
    __weak typeof (CallsOnHoldView*) weakSelf = self;
    
    [self.listParticipantsOnHoldOperation notifyOnChangesCompletionHandler:^(BOOL isSuccessful, BOOL *stop)
    {
        if (isSuccessful)
        {
            [weakSelf.participantsResult fetch];
            weakSelf.tableViewHeightConstraint.constant = [weakSelf tableViewHeight];
            
            [weakSelf.tableView reloadData];
        }
    }];
}

- (void)updateConstraints
{
    if (!_didSetConstraints)
    {
        [self.tableView autoPinEdgeToSuperviewEdge:ALEdgeLeading];
        [self.tableView autoPinEdgeToSuperviewEdge:ALEdgeTrailing];
        [self.tableView autoPinEdgeToSuperviewEdge:ALEdgeBottom];
        self.tableViewHeightConstraint = [self.tableView autoSetDimension:ALDimensionHeight toSize:[self tableViewHeight]];
        
        _didSetConstraints = YES;
    }
    
    [super updateConstraints];
}

- (CGFloat)tableViewHeight
{
    NSUInteger rowsCount = MIN(kMaxRowsCount, [self.participantsResult itemsCount]);
    return rowsCount * kRowHeight;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.participantsResult itemsCount];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CallOnHoldTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:kCallOnHoldTableViewCell];
    cell.delegate = self;
    
    LSParticipant* participant = [self.participantsResult itemAtRow:indexPath.row];
    [cell setupWithParticipant:participant];
    
    [cell setNeedsUpdateConstraints];
    [cell updateConstraintsIfNeeded];
    
    return cell;
}

- (void)callOnHoldTableViewCell:(CallOnHoldTableViewCell*)callOnHoldTableViewCell
   didPressResumeForParticipant:(LSParticipant*)participant
{
    [self.delegate callsOnHoldView:self didPressResumeOnParticipant:participant];
}

@end
