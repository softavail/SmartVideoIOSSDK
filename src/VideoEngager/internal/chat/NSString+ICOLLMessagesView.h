//
//  NSString+ICOLLMessagesView.h
//  instac
//
//  Created by Bozhko Terziev on 11/20/14.
//  Copyright (c) 2014 SoftAvail. All rights reserved.
//


#import <Foundation/Foundation.h>

@interface NSString (ICOLLMessagesView)

- (NSString *)trimWhitespace;
- (NSUInteger)numberOfLines;
- (NSString*)stringByExtractingInitials;
- (NSString*)stringByTrimmingLeadingWhitespaceAndNewLine;
- (NSString*)stringByTrimmingTrailingWhitespaceAndNewLine;

@end
