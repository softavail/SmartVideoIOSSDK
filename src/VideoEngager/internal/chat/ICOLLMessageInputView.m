//
//  ICOLLMessageInputView.m
//  instac
//
//  Created by Bozhko Terziev on 11/20/14.
//  Copyright (c) 2014 SoftAvail. All rights reserved.
//



#import "ICOLLMessageInputView.h"
#import "UIColor+Additions.h"
#import "NSString+ICOLLMessagesView.h"

@interface ICOLLMessageInputView ()

- (void)setup;
- (void)setupTextView;

@end

@implementation ICOLLMessageInputView

@synthesize sendButton;
@synthesize micrButton;

#pragma mark - Initialization
- (id)initWithFrame:(CGRect)frame delegate:(id<UITextViewDelegate>)delegate
{
    self = [super initWithFrame:frame];
    if(self) {
        [self setup];
        self.textView.delegate = delegate;
    }
    return self;
}

+ (JSInputBarStyle)inputBarStyle
{
    return JSInputBarStyleDefault;
}

- (void)dealloc
{
    self.textView   = nil;
    self.sendButton = nil;
    self.micrButton = nil;
}

- (BOOL)resignFirstResponder
{
    [self.textView resignFirstResponder];
    return [super resignFirstResponder];
}
#pragma mark - Setup
- (void)setup
{
    self.image = nil;
    self.backgroundColor = [UIColor whiteColor];
    self.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin);
    self.opaque = YES;
    self.userInteractionEnabled = YES;
    [self setupTextView];
    self.accessibilityIdentifier = @"Action Bar";
}

- ( void )
setupTextView
{
    CGFloat width = self.frame.size.width;
    CGFloat height = [ICOLLMessageInputView textViewLineHeight];
    
    self.textView = [[ICOLLMessageTextView  alloc] initWithFrame:CGRectMake(8.0f, 3.0f, width, height)];
    self.textView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.textView.backgroundColor = [UIColor whiteColor];
    self.textView.textColor = [UIColor blackColor];
    
    self.textView.layer.borderColor = [UIColor separatorEndColor].CGColor;
    self.textView.layer.borderWidth = 1.0f;
    self.textView.layer.cornerRadius = 5.0f;
    
    self.textView.font = [UIFont systemFontOfSize:16 weight:UIFontWeightLight];

    [self addSubview:self.textView];
}

#pragma mark - Setters
- (void)setSendButton:(UIButton *)btn
{
    if(sendButton)
        [sendButton removeFromSuperview];
    
    sendButton = btn;
    [self addSubview:self.sendButton];
}

- (void)setMicrButton:(UIButton *)btn
{
    if(micrButton)
        [micrButton removeFromSuperview];
    
    micrButton = btn;
    [self addSubview:self.micrButton];
}

#pragma mark - Message input view
- (void)adjustTextViewHeightBy:(CGFloat)changeInHeight
{
    CGRect prevFrame = self.textView.frame;
    
    int numLines = MAX((int)[self.textView numberOfLinesOfText],
                       (int)[self.textView.text numberOfLines]);
    
    NSLog(@"number line == %d",numLines);
    
    CGRect rect = CGRectMake(prevFrame.origin.x,
                             prevFrame.origin.y,
                             prevFrame.size.width,
                             CGRectGetHeight(self.textView.superview.bounds) - 10);
    
    self.textView.frame = rect;
    
    self.textView.contentInset = UIEdgeInsetsMake((numLines >= 6 ? 4.0f : 0.0f),
                                                  0.0f,
                                                  (numLines >= 6 ? 4.0f : 0.0f),
                                                  0.0f);
    
    self.textView.scrollEnabled = (numLines >= 4);
    
    if(numLines >= 6) {
        CGPoint bottomOffset = CGPointMake(0.0f, self.textView.contentSize.height - self.textView.bounds.size.height);
        [self.textView setContentOffset:bottomOffset animated:YES];
    }
}

+ (CGFloat)textViewLineHeight
{
    return 36.0f; // for fontSize 16.0f
}

+ (CGFloat)maxLines
{
    return 4.0f;
}

+ (CGFloat)maxHeight
{
    return ([ICOLLMessageInputView maxLines] + 1.0f) * [ICOLLMessageInputView textViewLineHeight];
}

@end
