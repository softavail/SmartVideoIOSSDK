//
//  IncomingMessageCellAvatar.m
//  leadsecure
//
//  Created by Angel Terziev on 3/8/17.
//  Copyright © 2017 SoftAvail. All rights reserved.
//

#import "IncomingMessageCellAvatar.h"
#import "AvatarView.h"
#import "UIColor+Additions.h"
#import "UIImage+Additions.h"

@interface IncomingMessageCellAvatar()
@property (weak, nonatomic) IBOutlet UIImageView *imageViewBubble;
@property (weak, nonatomic) IBOutlet AvatarView *avatarView;

@end

@implementation IncomingMessageCellAvatar

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    [self configureBaloon];
    [self configureTextViewMessage];
    [self configureLabelSender];
    [self configureLabelTime];
    [self configureAvatar];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - configuration

- (void) configureBaloon
{
    UIImage* stretchableImage = [[UIImage sdkImageNamed:@"bubbleIncomingMessage"] bubbleIncomingMessageCapInsets];
    self.imageViewBubble.image = stretchableImage;
}

- (void) configureTextViewMessage
{
    self.textViewMessage.textColor = [UIColor incomingMessageTextColor];
    self.textViewMessage.font = [UIFont systemFontOfSize:15 weight:UIFontWeightLight];
    self.textViewMessage.tintColor = [UIColor incomingMessageSenderColor];
}

- (void) configureLabelSender
{
    self.labelSender.textColor = [UIColor incomingMessageSenderColor];
    self.labelSender.font = [UIFont systemFontOfSize:14 weight:UIFontWeightLight];
}

- (void) configureLabelTime
{
    self.labelTime.textColor = [UIColor incomingMessageDateColor];
    self.labelTime.font = [UIFont systemFontOfSize:10 weight:UIFontWeightThin];

}

- (void) configureAvatar
{
    self.avatarView.initialsBackgroundColor = [UIColor avatarInCellBackgroundColor];
    self.avatarView.initialsTextColor = [UIColor avatarInCellTextColor];
}

#pragma mark - Interface

-(void) setInitials: (NSString*) initials
{
    self.avatarView.initials = initials;
}

-(void) setAvatarImage: (UIImage*) avatarImage
{
    self.avatarView.backgroundImage = avatarImage;
    
    if (avatarImage != nil)
        self.avatarView.backgroundImageHidden = NO;
    else
        self.avatarView.backgroundImageHidden = YES;
}

@end
