//
//  DashboardFooterView.m
//  VideoEngager
//
//  Created by Bozhko Terziev on 11.01.18.
//  Copyright © 2018 VideoEngager. All rights reserved.
//

#import "DashboardFooterView.h"
#import "UIColor+Additions.h"
#import "UIImage+Additions.h"

@interface DashboardFooterView ()

@property (weak, nonatomic) IBOutlet UIButton *buttonCancel;


@end

@implementation DashboardFooterView

-(void)awakeFromNib {
    
    [super awakeFromNib];
    
    self.backgroundColor = [UIColor appBackgroundColor];
    
    self.buttonCancel.backgroundColor = [UIColor clearColor];
    
    [self.buttonCancel setBackgroundImage:[[UIImage sdkImageNamed:@"buttonBlue"] resizableImageWithCapInsets:UIEdgeInsetsMake(10.0, 10.0, 10.0, 10)]
                                 forState:UIControlStateNormal];
    
    [self.buttonCancel setBackgroundImage:[[UIImage sdkImageNamed:@"buttonBluePress"] resizableImageWithCapInsets:UIEdgeInsetsMake(10.0, 10.0, 10.0, 10)]
                                 forState:UIControlStateSelected];
    
    [self.buttonCancel setBackgroundImage:[[UIImage sdkImageNamed:@"buttonBluePress"] resizableImageWithCapInsets:UIEdgeInsetsMake(10.0, 10.0, 10.0, 10)]
                                 forState:UIControlStateHighlighted];
    
    [self.buttonCancel setTitleColor:[UIColor statusRedColor] forState:UIControlStateNormal];
    [self.buttonCancel setTitleColor:[UIColor lightGrayColor] forState:UIControlStateSelected];
    [self.buttonCancel setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
    
    self.buttonCancel.titleLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightLight];
}

- (IBAction)onButtonCancel:(id)sender {
    
    if ( nil != self.delegate && [self.delegate respondsToSelector:@selector(didPressCancel)])
        [self.delegate didPressCancel];
}

@end
