//
//  SwitchView.m
//  demo
//
//  Created by Bozhko Terziev on 31.01.18.
//  Copyright © 2018 VideoEngager. All rights reserved.
//

#import "SwitchView.h"

@interface SwitchView()

@property (weak, nonatomic) IBOutlet UISwitch *sw;


@end

@implementation SwitchView

-(void)awakeFromNib {
    
    [super awakeFromNib];
}

-(void) updateSwitchView {
    
    self.sw.on = self.isOn;
}

- (IBAction)onSwitch:(id)sender {
    
    UISwitch* sw = (UISwitch*)sender;
    
    if ( [sw isKindOfClass:[UISwitch class]] ) {
        
        self.isOn = sw.on;
        
        if ( nil != self.delegate && [self.delegate respondsToSelector:@selector(didChangeSwitchView:)] )
            [self.delegate didChangeSwitchView:self];
    }
}

@end
