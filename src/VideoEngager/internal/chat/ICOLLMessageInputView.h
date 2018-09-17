//
//  ICOLLMessageInputView.h
//  instac
//
//  Created by Bozhko Terziev on 11/20/14.
//  Copyright (c) 2014 SoftAvail. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "ICOLLMessageTextView.h"


typedef enum
{
  JSInputBarStyleDefault,
  JSInputBarStyleFlat
} JSInputBarStyle;

@interface ICOLLMessageInputView : UIImageView

@property (strong, nonatomic) ICOLLMessageTextView *textView;
@property (strong, nonatomic) UIButton *sendButton;
@property (strong, nonatomic) UIButton *micrButton;

#pragma mark - Initialization
- (id)initWithFrame:(CGRect)frame delegate:(id<UITextViewDelegate>)delegate;

#pragma mark - Message input view
- (void)adjustTextViewHeightBy:(CGFloat)changeInHeight;

+ (CGFloat)textViewLineHeight;
+ (CGFloat)maxLines;
+ (CGFloat)maxHeight;
+ (JSInputBarStyle)inputBarStyle;

@end