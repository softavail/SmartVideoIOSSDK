//
//  DashboardHeaderView.m
//  VideoEngager
//
//  Created by Bozhko Terziev on 11.01.18.
//  Copyright © 2018 VideoEngager. All rights reserved.
//

#import "DashboardHeaderView.h"
#import "UIColor+Additions.h"
#import "UIImage+Additions.h"

@interface DashboardHeaderView ()

@property (weak, nonatomic) IBOutlet UILabel *labelName;
@property (weak, nonatomic) IBOutlet UILabel *labelEmail;
@property (weak, nonatomic) IBOutlet UILabel *labelPhone;

@end

@implementation DashboardHeaderView

-(void)awakeFromNib {
    
    [super awakeFromNib];
    
    self.backgroundColor = [UIColor appBackgroundColor];
    
    self.labelName.textColor = [UIColor textFieldColor];
    self.labelEmail.textColor = [UIColor textFieldColor];
    self.labelPhone.textColor = [UIColor textFieldColor];
    
    self.labelName.font = [UIFont systemFontOfSize:17 weight:UIFontWeightBold];
    self.labelEmail.font = [UIFont systemFontOfSize:14 weight:UIFontWeightRegular];
    self.labelPhone.font = [UIFont systemFontOfSize:14 weight:UIFontWeightRegular];
}

- (void) updateView {
    
    self.labelName.text = self.strName;
    self.labelEmail.text = [NSString stringWithFormat:@"%@: %@", @"Email", self.strEmail];
    self.labelPhone.text = [NSString stringWithFormat:@"%@: %@", @"Phone", self.strPhone];
}

@end
