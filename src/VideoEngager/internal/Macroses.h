//
//  Macroses.h
//  VideoEngager
//
//  Created by Angel Terziev on 4.01.18.
//  Copyright © 2018 VideoEngager. All rights reserved.
//

#ifndef Macroses_h
#define Macroses_h

#define ICOLLString(key)    [[NSBundle bundleForClass:[self class]] localizedStringForKey:(key) value:nil table:nil]

#define OBJCStringA(str)    [NSString stringWithUTF8String: str.c_str()]

#define UI_IPAD()     ([[DeviceData instance] isiPad])
#define UI_IPHONE()   ([[DeviceData instance] isiPhone])

#endif /* Macroses_h */
