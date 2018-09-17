//
//  IncomingMessageCellAvatar.h
//  leadsecure
//
//  Created by Angel Terziev on 3/8/17.
//  Copyright © 2017 SoftAvail. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IncomingMessageCellAvatar : UITableViewCell
@property (weak, nonatomic) IBOutlet UITextView *textViewMessage;
@property (weak, nonatomic) IBOutlet UILabel *labelTime;
@property (weak, nonatomic) IBOutlet UILabel *labelSender;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintBubbleTop;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintBubbleBottom;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintTextViewBottom;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintLabelSenderTop;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintTextViewVerticalSpaceToLabelSender;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintBubbleWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintTextViewLeft;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintTextViewRight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintAvatarViewLeft;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintAvatarViewWidth;

-(void) setInitials: (NSString*) initials;
-(void) setAvatarImage: (UIImage*) avatarImage;

@end
