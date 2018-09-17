//
//  ICOLLMessageTextView.m
//  instac
//
//  Created by Bozhko Terziev on 11/20/14.
//  Copyright (c) 2014 SoftAvail. All rights reserved.
//

#import "ICOLLMessageTextView.h"
#import "UIColor+Additions.h"
#import "NSString+ICOLLMessagesView.h"

@interface ICOLLMessageTextView ()

- (void)setup;

- (void)didReceiveTextDidChangeNotification:(NSNotification *)notification;

@end



@implementation ICOLLMessageTextView

#pragma mark - Initialization

- ( void )
setup
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveTextDidChangeNotification:)
                                                 name:UITextViewTextDidChangeNotification
                                               object:self];
    
    _placeHolderTextColor = [UIColor placeholderChatScreenColor];
    
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.scrollIndicatorInsets = UIEdgeInsetsMake(10.0f, 0.0f, 10.0f, 8.0f);
    self.contentInset = UIEdgeInsetsZero;
    self.scrollEnabled = YES;
    self.scrollsToTop = NO;
    self.userInteractionEnabled = YES;
    self.font = [UIFont systemFontOfSize:16 weight:UIFontWeightLight];
    self.textColor = [UIColor blackColor];
    self.backgroundColor = [UIColor whiteColor];
    self.keyboardAppearance = UIKeyboardAppearanceDefault;
    self.keyboardType = UIKeyboardTypeDefault;
    self.returnKeyType = UIReturnKeyDefault;
    self.textAlignment = NSTextAlignmentLeft;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self) {
        [self setup];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(self) {
        [self setup];
    }
    return self;
}

- (void)dealloc
{
    _placeHolder = nil;
    _placeHolderTextColor = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UITextViewTextDidChangeNotification
                                                  object:self];
}

#pragma mark - Setters

- (void)setPlaceHolder:(NSString *)placeHolder
{
    if([placeHolder isEqualToString:_placeHolder]) {
        return;
    }
    
    NSUInteger maxChars = [ICOLLMessageTextView maxCharactersPerLine];
    if([placeHolder length] > maxChars) {
        placeHolder = [placeHolder substringToIndex:maxChars - 8];
        placeHolder = [[placeHolder trimWhitespace] stringByAppendingFormat:@"..."];
    }
    
    _placeHolder = placeHolder;
    [self setNeedsDisplay];
}

- (void)setPlaceHolderTextColor:(UIColor *)placeHolderTextColor
{
    if([placeHolderTextColor isEqual:_placeHolderTextColor]) {
        return;
    }
    
    _placeHolderTextColor = placeHolderTextColor;
    [self setNeedsDisplay];
}

#pragma mark - Message text view

- (NSUInteger)numberOfLinesOfText
{
    return [ICOLLMessageTextView numberOfLinesForMessage:self.text];
}

+ (NSUInteger)maxCharactersPerLine
{
    return ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) ? 33 : 109;
}

+ (NSUInteger)numberOfLinesForMessage:(NSString *)text
{
    return (text.length / [ICOLLMessageTextView maxCharactersPerLine]) + 1;
}

#pragma mark - Text view overrides

- (void)setText:(NSString *)text
{
    [super setText:text];
    [self setNeedsDisplay];
}

- (void)insertText:(NSString *)text
{
    [super insertText:text];
    [self setNeedsDisplay];
}

- (void)setAttributedText:(NSAttributedString *)attributedText
{
    [super setAttributedText:attributedText];
    [self setNeedsDisplay];
}

- (void)setContentInset:(UIEdgeInsets)contentInset
{
    [super setContentInset:contentInset];
    [self setNeedsDisplay];
}

- (void)setFont:(UIFont *)font
{
    [super setFont:font];
    [self setNeedsDisplay];
}

- (void)setTextAlignment:(NSTextAlignment)textAlignment
{
    [super setTextAlignment:textAlignment];
    [self setNeedsDisplay];
}

#pragma mark - Drawing

- ( void )
drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    if([self.text length] == 0 && self.placeHolder) {
        CGRect placeHolderRect = CGRectMake(7.0f,
                                            7.0f,
                                            rect.size.width,
                                            rect.size.height);
        
        [self.placeHolderTextColor set];
        
        NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
        style.lineBreakMode = NSLineBreakByTruncatingTail;
        style.alignment = self.textAlignment;
        NSDictionary *attr = [NSDictionary dictionaryWithObjectsAndKeys:style, NSParagraphStyleAttributeName,
                                                                        self.font, NSFontAttributeName,
                                                                        _placeHolderTextColor, NSForegroundColorAttributeName, nil];
        
        [self.placeHolder drawInRect:placeHolderRect withAttributes:attr];
    }
}

#pragma mark - Notifications

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    UIPasteboard * pasteBoard = [UIPasteboard generalPasteboard];
    UIImage* img = [pasteBoard image];
    
    NSString* textBody = self.text;
    
    if ( nil == img || [textBody length] > 0 )
    {
       return [super canPerformAction:action withSender:sender];
    }
    else
    {
        if (action == @selector(cut:))
            return NO;
        else if (action == @selector(copy:))
            return NO;
        else if (action == @selector(paste:))
            return YES;
        else if (action == @selector(select:) || action == @selector(selectAll:))
            return NO;
        else
            return [super canPerformAction:action withSender:sender];
    }
}

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- ( void )
didReceiveTextDidChangeNotification: ( NSNotification * ) notification
{
    [self setNeedsDisplay];
}

- ( void )
paste: ( id ) sender
{
    UIPasteboard * pasteBoard = [UIPasteboard generalPasteboard];
    UIImage* img = [pasteBoard image];
    
    if ( nil == img )
    {
        [super paste:sender];
    }
    else
    {
        if ( nil != self.delegate && [self.delegate respondsToSelector:@selector(didSelectPasteWithImage:)] )
        {
            [self.delegate performSelector:@selector(didSelectPasteWithImage:) withObject:img];
        }
        else
        {
            [super paste:sender];
        }
    }
}

@end
