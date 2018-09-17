//
//  ICOLLTextField.m
//  instac
//
//  Created by Bozhko Terziev on 1/10/14.
//  Copyright (c) 2014 SoftAvail. All rights reserved.
//

#import "ICOLLTextField.h"
#import "UIColor+Additions.h"

@interface ICOLLTextField ()

@property (nonatomic, strong)   UIColor*    phColor;
@property (nonatomic)           CGFloat     placeholderFontSize;

@end

@implementation ICOLLTextField

- ( void )
initMe
{
    self.phColor = [UIColor textFieldPlaceholderColor];
    self.placeholderFontSize = 15;
    self.textColor = [ UIColor textFieldColor];
    self.font = [UIFont systemFontOfSize:16 weight:UIFontWeightLight];
    self.contentVerticalAlignment   = UIControlContentVerticalAlignmentCenter;
    self.autocorrectionType         = UITextAutocorrectionTypeNo;
    self.autocapitalizationType     = UITextAutocapitalizationTypeNone;
    self.spellCheckingType          = UITextSpellCheckingTypeNo;
}

- ( id )
initWithFrame   : ( CGRect ) rect
{
    self = [ super initWithFrame:rect];
    
    if ( nil != self )
    {
        [self initMe];
    }
    
    return self;
}

- ( id )
initWithCoder: ( NSCoder * ) aDecoder
{
    self = [ super initWithCoder:aDecoder];
    
    if ( nil != self )
    {
        [self initMe];
    }
    
    return self;
}

-  ( void )
drawPlaceholderInRect:( CGRect ) rect
{
    // Placeholder text color, the same like default
    UIColor *placeholderColor = self.phColor;
    [placeholderColor setFill];
    
    UIFont* font = [UIFont systemFontOfSize:self.placeholderFontSize weight:UIFontWeightLight];
    
    // Get the size of placeholder text. We will use height to calculate frame Y position
    CGSize size = CGSizeZero;
    
    size = [self.placeholder sizeWithAttributes:@{ NSFontAttributeName : font }];
    
    // Vertically centered frame
    CGRect placeholderRect = CGRectMake(rect.origin.x, (rect.size.height - size.height)/2, rect.size.width, size.height);
    

    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineBreakMode = NSLineBreakByTruncatingTail;
    style.alignment = self.textAlignment;
    NSDictionary *attr = [NSDictionary dictionaryWithObjectsAndKeys:style, NSParagraphStyleAttributeName,
                                                                    font, NSFontAttributeName,
                                                                    placeholderColor, NSForegroundColorAttributeName, nil];
    
    [self.placeholder drawInRect:placeholderRect withAttributes:attr];
}

- (  void )
changePlaceholderFontSize: ( CGFloat ) newPHSize
{
    self.placeholderFontSize = newPHSize;
    [self setNeedsLayout];
}

- ( void )
changePlaceHolderColorWithColor: ( UIColor* ) newColor
{
    self.phColor = newColor;
    [ self setNeedsLayout];
}


@end
