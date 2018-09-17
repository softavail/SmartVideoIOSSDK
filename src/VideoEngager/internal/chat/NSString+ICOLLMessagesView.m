//
//  NSString+SYNMessagesView.m
//  instac
//
//  Created by Bozhko Terziev on 11/20/14.
//  Copyright (c) 2014 SoftAvail. All rights reserved.
//

#import "NSString+ICOLLMessagesView.h"

@implementation NSString (ICOLLMessagesView)

- (NSString *)trimWhitespace
{
    return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

- (NSUInteger)numberOfLines
{
    return [self componentsSeparatedByString:@"\n"].count + 1;
}

- (NSString*) stringByExtractingInitials
{
    NSMutableString* initials = [[NSMutableString alloc] initWithCapacity: 2];
    NSUInteger fcIndex = 0; // index of the component for the first word
    NSString* fc = nil;
    NSString* lc = nil;
    
    NSString* name = self;
    NSArray<NSString *> * components = [name componentsSeparatedByString: @" "];
    
    if (components.count > 0) {
        for (NSUInteger i = 0; i < components.count; ++i ) {
            NSString* fname = components[i];
            if (fname.length > 0) {
                fc = [fname substringToIndex: 1];
                fcIndex = i;
                break;
            }
        }
    }
    
    if (components.count > (fcIndex + 1)) {
        for (NSUInteger i = components.count - 1; i > fcIndex; --i ) {
            NSString* lname = components[i];
            if (lname.length) {
                lc = [lname substringToIndex: 1];
                break;
            }
        }
    }
    
    if (fc)
        [initials appendString: fc];
    if (lc)
        [initials appendString: lc];
    
    return [NSString stringWithString: initials];
}

- ( NSString * ) stringByTrimmingTrailingCharactersInSet: ( NSCharacterSet * ) characterSet
{
    NSString* resString = nil;
    NSUInteger location = 0;
    NSUInteger length = [self length];
    unichar charBuffer[length];
    [self getCharacters:charBuffer];
    
    for (; length > 0; length--)
    {
        if (![characterSet characterIsMember:charBuffer[length - 1]])
        {
            break;
        }
    }
    
    resString = [self substringWithRange:NSMakeRange(location, length - location)];
    
    return resString;
}

- ( NSString * ) stringByTrimmingLeadingCharactersInSet: ( NSCharacterSet * ) characterSet
{
    NSString* resString = nil;
    NSUInteger location = 0;
    NSUInteger length   = [self length];
    unichar charBuffer[length];
    
    [self getCharacters:charBuffer];
    
    for (; location < length; location++)
    {
        if (![characterSet characterIsMember:charBuffer[location]])
        {
            break;
        }
    }
    
    resString = [self substringWithRange:NSMakeRange(location, length - location)];
    
    return resString;
}

- ( NSString * ) stringByTrimmingLeadingWhitespaceAndNewLine
{
    return [self stringByTrimmingLeadingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

- ( NSString * ) stringByTrimmingTrailingWhitespaceAndNewLine
{
    return [self stringByTrimmingTrailingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

@end
