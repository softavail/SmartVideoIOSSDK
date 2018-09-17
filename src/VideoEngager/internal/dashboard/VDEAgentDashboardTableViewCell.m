//
//  VDEAgentDashboardTableViewCell.m
//  VideoEngager
//
//  Created by Bozhko Terziev on 10.01.18.
//  Copyright © 2018 VideoEngager. All rights reserved.
//

#import "VDEAgentDashboardTableViewCell.h"
#import "UIImage+Additions.h"
#import "UIColor+Additions.h"

@interface VDEAgentDashboardTableViewCell()

@property (weak, nonatomic) IBOutlet UIButton *buttonAction;

@end

@implementation VDEAgentDashboardTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.buttonAction.backgroundColor = [UIColor clearColor];
    
    [self.buttonAction setBackgroundImage:[[UIImage sdkImageNamed:@"buttonBlue"] resizableImageWithCapInsets:UIEdgeInsetsMake(10.0, 10.0, 10.0, 10)]
                                 forState:UIControlStateNormal];
    
    [self.buttonAction setBackgroundImage:[[UIImage sdkImageNamed:@"buttonBluePress"] resizableImageWithCapInsets:UIEdgeInsetsMake(10.0, 10.0, 10.0, 10)]
                                 forState:UIControlStateSelected];
    
    [self.buttonAction setBackgroundImage:[[UIImage sdkImageNamed:@"buttonBluePress"] resizableImageWithCapInsets:UIEdgeInsetsMake(10.0, 10.0, 10.0, 10)]
                                 forState:UIControlStateHighlighted];

    [self.buttonAction setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.buttonAction setTitleColor:[UIColor lightGrayColor] forState:UIControlStateSelected];
    [self.buttonAction setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];

    self.buttonAction.titleLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightLight];
    self.selectionStyle = UITableViewCellSelectionStyleNone;

    self.contentView.backgroundColor = [UIColor appBackgroundColor];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)updateCell {
    
    [self.buttonAction setTitle:self.buttonTitle forState:UIControlStateNormal];
}

- (IBAction)onButton:(id)sender {
    
    if ( nil != self.delegate && [self.delegate respondsToSelector:@selector(didPressButtonForCell:)])
        [self.delegate didPressButtonForCell:self];
}

@end
