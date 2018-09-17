//
//  AvatarView.m
//  leadsecure
//
//  Created by Angel Terziev on 3/12/17.
//  Copyright © 2017 SoftAvail. All rights reserved.
//

#import "AvatarView.h"

@interface AvatarView ()
@property (nonatomic, weak) UIImageView* backgroundImageView;
@property (nonatomic, weak) UILabel* initialsView;
@property (nonatomic, weak) UIView* statusView;
@end

@implementation AvatarView

- (void) configureDefaults {
    self.initialsBackgroundColor = [UIColor clearColor];
    _backgroundImageHidden = YES;
    self.clipsToBounds = YES;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (nil != (self = [super initWithFrame:frame])) {
        [self configureDefaults];
        [self configureInitialsViewWithString: _initials];
    }
    
    return self;
}

- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if(nil != (self = [super initWithCoder:aDecoder])) {
        [self configureDefaults];
    }
    
    return self;
}

#pragma mark - Constraints

- (void) removeConstraintsToItem: (nonnull id) item {
    NSMutableArray<NSLayoutConstraint*>* constraintsToRemove = [[NSMutableArray alloc] init];
    
    for (NSLayoutConstraint* constraint in self.constraints) {
        if (constraint.firstItem == item || constraint.secondItem == item) {
            [constraintsToRemove addObject: constraint];
        }
    }
    
    if ([constraintsToRemove count]) {
        [self removeConstraints: constraintsToRemove];
    }
}

- (void) installInitialsViewConstraints {
    if (self.initialsView != nil) {
        CGFloat width = MIN(self.bounds.size.width, self.bounds.size.height);
        [self addConstraint:
         [NSLayoutConstraint constraintWithItem:self.initialsView
                                        attribute:NSLayoutAttributeCenterX
                                      relatedBy:NSLayoutRelationEqual
                                         toItem:self
                                      attribute:NSLayoutAttributeCenterX
                                     multiplier:1.0
                                       constant:0.0]];

        [self addConstraint:
         [NSLayoutConstraint constraintWithItem:self.initialsView
                                      attribute:NSLayoutAttributeCenterY
                                      relatedBy:NSLayoutRelationEqual
                                         toItem:self
                                      attribute:NSLayoutAttributeCenterY
                                     multiplier:1.0
                                       constant:0.0]];

        [self.initialsView addConstraint:
         [NSLayoutConstraint constraintWithItem:self.initialsView
                                      attribute:NSLayoutAttributeWidth
                                      relatedBy:NSLayoutRelationEqual
                                         toItem:nil
                                      attribute:NSLayoutAttributeNotAnAttribute
                                     multiplier:1.0
                                       constant:width]];

        [self.initialsView addConstraint:
         [NSLayoutConstraint constraintWithItem:self.initialsView
                                      attribute:NSLayoutAttributeHeight
                                      relatedBy:NSLayoutRelationEqual
                                         toItem:nil
                                      attribute:NSLayoutAttributeNotAnAttribute
                                     multiplier:1.0
                                       constant:width]];
    }
}

- (void) installBackgroundImageViewConstraints {
    if (self.backgroundImageView != nil) {
        CGFloat width = MIN(self.bounds.size.width, self.bounds.size.height);
        [self addConstraint:
         [NSLayoutConstraint constraintWithItem:self.backgroundImageView
                                      attribute:NSLayoutAttributeCenterX
                                      relatedBy:NSLayoutRelationEqual
                                         toItem:self
                                      attribute:NSLayoutAttributeCenterX
                                     multiplier:1.0
                                       constant:0.0]];
        
        [self addConstraint:
         [NSLayoutConstraint constraintWithItem:self.backgroundImageView
                                      attribute:NSLayoutAttributeCenterY
                                      relatedBy:NSLayoutRelationEqual
                                         toItem:self
                                      attribute:NSLayoutAttributeCenterY
                                     multiplier:1.0
                                       constant:0.0]];
        
        [self.backgroundImageView addConstraint:
         [NSLayoutConstraint constraintWithItem:self.backgroundImageView
                                      attribute:NSLayoutAttributeWidth
                                      relatedBy:NSLayoutRelationEqual
                                         toItem:nil
                                      attribute:NSLayoutAttributeNotAnAttribute
                                     multiplier:1.0
                                       constant:width]];
        
        [self.backgroundImageView addConstraint:
         [NSLayoutConstraint constraintWithItem:self.backgroundImageView
                                      attribute:NSLayoutAttributeHeight
                                      relatedBy:NSLayoutRelationEqual
                                         toItem:nil
                                      attribute:NSLayoutAttributeNotAnAttribute
                                     multiplier:1.0
                                       constant:width]];
    }
}

#pragma mark - Initials View

- (void) configureInitialsViewWithString: (NSString *)initials {
    if (self.initialsView == nil) {
        CGFloat width = MIN(self.bounds.size.width, self.bounds.size.height);
        UILabel* label = [[UILabel alloc] initWithFrame: CGRectMake(0, 0, width, width)];
        label.numberOfLines = 1;
        label.textColor = self.initialsTextColor;
        label.backgroundColor = self.initialsBackgroundColor;
        label.font = [UIFont systemFontOfSize:15 weight:UIFontWeightMedium];
        label.adjustsFontSizeToFitWidth = YES;
        label.minimumScaleFactor = 8.0;
        label.layer.borderWidth = 0.0;
        label.layer.cornerRadius = label.bounds.size.width / 2.0;
        label.layer.masksToBounds = YES;
        label.textAlignment = NSTextAlignmentCenter;
        label.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview: label];
        self.initialsView = label;
        [self installInitialsViewConstraints];
    }
    
    self.initialsView.text = initials;
}

- (void)setInitials:(NSString *)initials {
    NSUInteger index = MIN(2, initials.length);
    NSString* uppercaseInitials;
    if (index > 0)
        uppercaseInitials = [[initials substringToIndex: index] localizedUppercaseString];
    
    _initials = uppercaseInitials;
    [self configureInitialsViewWithString: _initials];
}

- (void)setInitialsHidden:(BOOL)initialsHidden {
    [self setInitialsHidden:initialsHidden animated:NO];
}

- (void) setInitialsHidden: (BOOL) hidden animated: (BOOL) animated {
    if (self.initialsView.hidden != hidden) {
        if (animated) {
            [UIView animateWithDuration: 0.5
                                  delay: 0.0
                                options: 0
                             animations:^ {
                                 self.initialsView.hidden = hidden;
                             }
                             completion:^(BOOL finished) {
                             }];
        } else {
            self.initialsView.hidden = hidden;
        }
    }
}

- (void)setInitialsTextColor:(UIColor *)initialsTextColor {
    _initialsTextColor = initialsTextColor;
    self.initialsView.textColor = initialsTextColor;
}

- (void)setInitialsBackgroundColor:(UIColor *)initialsBackgroundColor {
    _initialsBackgroundColor = initialsBackgroundColor;
    self.initialsView.backgroundColor = initialsBackgroundColor;
}
#pragma mark - Background Image View

- (void) configureImageViewWithImage: (UIImage*) image {
    if (image != nil) {
        if (self.backgroundImageView == nil) {
            UIImageView* imageView = [[UIImageView alloc] initWithImage: image];
            imageView.contentMode = UIViewContentModeScaleAspectFill;
            imageView.layer.borderWidth = 0.0;
            imageView.layer.cornerRadius = imageView.bounds.size.width / 2.0;
            imageView.layer.masksToBounds = YES;
            imageView.translatesAutoresizingMaskIntoConstraints = NO;
            [self addSubview: imageView];
            self.backgroundImageView = imageView;
            self.backgroundImageView.hidden = self.backgroundImageHidden;
            [self installBackgroundImageViewConstraints];
        } else {
            self.backgroundImageView.image = image;
        }
        
        [self setNeedsUpdateConstraints];
        [self setNeedsLayout];
        
    } else {
        if (self.backgroundImageView != nil) {
            [self removeConstraintsToItem: self.backgroundImageView];
            [self.backgroundImageView removeFromSuperview];
            self.backgroundImageView = nil;
        }
    }
}

- (void)setBackgroundImage:(UIImage *)backgroundImage {
    _backgroundImage = backgroundImage;
    [self configureImageViewWithImage: _backgroundImage];
}
- (void)setBackgroundImageHidden:(BOOL)backgroundImageHidden {
    [self setBackgroundImageHidden:backgroundImageHidden animated:NO];
}

- (void) setBackgroundImageHidden: (BOOL) hidden animated: (BOOL) animated {
    _backgroundImageHidden = hidden;

    if (self.backgroundImageView.hidden != hidden) {
        if (animated) {
            [UIView animateWithDuration: 0.5
                                  delay: 0.0
                                options: 0
                             animations:^ {
                                 self.backgroundImageView.hidden = hidden;
                             }
                             completion:^(BOOL finished) {
                             }];
        } else {
            self.backgroundImageView.hidden = hidden;
        }
    }
}

#pragma mark - Status View
- (void)setStatusHidden:(BOOL)statusHidden {
    [self setStatusHidden:statusHidden animated:NO];
}

- (void) setStatusHidden: (BOOL) hidden animated: (BOOL) animated {
    if (self.statusView.hidden != hidden) {
        if (animated) {
            [UIView animateWithDuration: 0.5
                                  delay: 0.0
                                options: 0
                             animations:^ {
                                 self.statusView.hidden = hidden;
                             }
                             completion:^(BOOL finished) {
                             }];
        } else {
            self.statusView.hidden = hidden;
        }
    }
}

@end
