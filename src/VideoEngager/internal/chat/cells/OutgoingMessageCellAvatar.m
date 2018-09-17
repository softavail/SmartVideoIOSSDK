//
//  OutgoingMessageCellAvatar.m
//  leadsecure
//
//  Created by Angel Terziev on 3/13/17.
//  Copyright © 2017 SoftAvail. All rights reserved.
//

#import "OutgoingMessageCellAvatar.h"
#import "AvatarView.h"
#import "UIColor+Additions.h"
#import "UIImage+Additions.h"

@interface OutgoingMessageCellAvatar()
@property (weak, nonatomic) IBOutlet UIImageView *imageViewBubble;
@property (weak, nonatomic) IBOutlet AvatarView *avatarView;

@end

@implementation OutgoingMessageCellAvatar

- (void)awakeFromNib {
    [super awakeFromNib];
    
    // Initialization code
    [self configureBaloon];
    [self configureLabelRceiver];
    [self configureTextViewMessage];
    [self configureLabelTime];
    [self configureAvatar];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

#pragma mark - configuration

- (void) configureBaloon
{
    UIImage* stretchableImage = [[UIImage sdkImageNamed:@"bubbleOutgoingMessage"] bubbleOutgoingMessageCapInsets];
    self.imageViewBubble.image = stretchableImage;
}

- (void) configureLabelRceiver
{
    self.labelSender.textColor = [UIColor incomingMessageReceiverColor];
    self.labelSender.font = [UIFont systemFontOfSize:14 weight:UIFontWeightLight];
}

- (void) configureTextViewMessage
{
    self.textViewMessage.textColor = [UIColor outgoingMessageTextColor];
    self.textViewMessage.font = [UIFont systemFontOfSize:15 weight:UIFontWeightLight];
    self.textViewMessage.tintColor = [UIColor incomingMessageReceiverColor];
}

- (void) configureLabelTime
{
    self.labelTime.textColor = [UIColor outgoingMessageDateColor];
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
