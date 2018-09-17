//
//  UIImage+Additions.h
//  instac
//
//  Created by Bozhko Terziev on 11/20/14.
//  Copyright (c) 2014 SoftAvail. All rights reserved.
//

#import "UIImage+Additions.h"

@implementation UIImage (Additions)

- ( UIImage* )
imageWithButtonCapInsets
{
    UIImage* img = [self resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
    
    return img;
}

- ( UIImage* )
imageWithButtonCapInsetsBig
{
    CGSize size = self.size;
    UIImage* img = [self resizableImageWithCapInsets:UIEdgeInsetsMake(ceilf(size.height/2), ceilf(size.width/2), floorf(size.height/2), floorf(size.width/2))];
    
    return img;
}

- ( UIImage* )
imageWithButtonLeftCapInsets
{
    CGSize size = self.size;
    UIImage* img = [self resizableImageWithCapInsets:UIEdgeInsetsMake(ceilf(size.height/2), size.width, floorf(size.height/2), 0.0)];
    
    return img;
}

- ( UIImage* )
imageWithButtonRightCapInsets
{
    CGSize size = self.size;
    UIImage* img = [self resizableImageWithCapInsets:UIEdgeInsetsMake(ceilf(size.height/2), 0.0, floorf(size.height/2), size.width)];
    
    return img;
}

- ( UIImage* )
chatImageBaloonOutgoingWithButtonCapInsets
{
    UIImage* img = [self resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10 + 5, 10 + 5)];
    
    return img;
}

- ( UIImage* )
chatImageBaloonIncomingWithButtonCapInsets
{
    UIImage* img = [self resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10 + 5, 10 + 5, 10)];
    
    return img;
}

-(UIImage*)bubbleEventMessageCapInsets
{
    UIImage* img = [self resizableImageWithCapInsets:UIEdgeInsetsMake(8, 10, 8, 10)];
    
    return img;
}

-(UIImage*)bubbleIncomingMessageCapInsets
{
    return [self resizableImageWithCapInsets: UIEdgeInsetsMake(0,  /*top*/
                                                               8,  /*left*/
                                                               0,  /*bottom*/
                                                               0   /*right*/)];
}

-(UIImage*)bubbleOutgoingMessageCapInsets
{
    return [self resizableImageWithCapInsets: UIEdgeInsetsMake(0,  /*top*/
                                                               0,  /*left*/
                                                               0,  /*bottom*/
                                                               8   /*right*/)];
}

+ (UIImage *) imageWithView:(UIView *)view
{
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.opaque, 0.0);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage * img = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return img;
}

+(UIImage*)imageNamed:(NSString *)name forBundle:(NSBundle*) bundle {
    
    return [UIImage imageNamed:name inBundle:bundle compatibleWithTraitCollection:nil];
}

+(UIImage*)sdkImageNamed:(NSString *)name {
 
    NSBundle* bundle = [NSBundle bundleWithIdentifier:@"com.videoengager.sdk"];
    
    return [UIImage imageNamed:name inBundle:bundle compatibleWithTraitCollection:nil];
}

@end
