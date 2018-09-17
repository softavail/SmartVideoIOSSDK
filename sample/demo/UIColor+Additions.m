//
//  UIColor+Additions.m
//  instac
//
//  Created by Bozhko Terziev on 11/20/14.
//  Copyright (c) 2014 SoftAvail. All rights reserved.
//

#import "UIColor+Additions.h"

#define RGBA_COLOR(r,g,b,a) \
    [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]

#define RGBA_GRAY_COLOR_ALPHA(g,a) \
[UIColor colorWithRed:g/255.0 green:g/255.0 blue:g/255.0 alpha:a]

#define RGBA_GRAY_COLOR(g) \
[UIColor colorWithRed:g/255.0 green:g/255.0 blue:g/255.0 alpha:1.0]

@implementation UIColor (Additions)

// redesign UI

+ ( UIColor* )
appBackgroundColor
{
    return RGBA_COLOR(47.0, 47.0, 84.0, 1.0);
}

+ ( UIColor* )
navigationBarColor
{
    return RGBA_GRAY_COLOR(37.0);
}

+ ( UIColor* )
navigationTitleColor
{
    //return RGBA_COLOR(244.0, 213.0, 34.0, 1.0);
    return RGBA_GRAY_COLOR(255.0);
}

+ ( UIColor* )
navigationBarTintColor
{
    //return RGBA_GRAY_COLOR(37.0);
    return RGBA_GRAY_COLOR(255.0);
}

+ ( UIColor* )
barButtonItemColor
{
//    return RGBA_COLOR(244.0, 213.0, 34.0, 1.0);
    return RGBA_GRAY_COLOR(255.0);
}

+ ( UIColor* )
buttonTransferCancelColor
{
    return RGBA_COLOR(201.0, 45.0, 116.0, 1.0);
}

+ ( UIColor* )
loginSectionStartColor
{
    return RGBA_COLOR(71.0, 82.0, 163.0, 1.0);
}

+ ( UIColor* )
loginSectionEndColor
{
    return RGBA_COLOR(0.0, 183.0, 233.0, 1.0);
}

+ ( UIColor* )
cellBackgroundColor
{
    return RGBA_COLOR(44.0, 44.0, 76.0, 1.0);
}

+ ( UIColor* )
cellBackgroundColorLight
{
    return RGBA_COLOR(47.0, 47.0, 84.0, 1.0);
}

+ ( UIColor* )
shareLinkColor
{
    return RGBA_COLOR(139.0, 139.0, 175.0, 1.0);
}

+ ( UIColor* )
placeholderChatScreenColor
{
    return RGBA_COLOR(47.0, 47.0, 84.0, 0.33);
}

+ ( UIColor* )
cellTextFieldBackgroundColor
{
    return RGBA_COLOR(47.0, 47.0, 84.0, 1.0);
}

+ ( UIColor* )
loginSectionTextColor
{
    return RGBA_GRAY_COLOR(255.0);
}

+ ( UIColor* )
loginSectionTextColorHighlighted
{
    return RGBA_GRAY_COLOR(255.0);
}

+ ( UIColor* )
separatorStartColor
{
    return RGBA_COLOR(66.0, 141.0, 198.0, 1.0);
}

+ ( UIColor* )
separatorEndColor
{
    return RGBA_COLOR(177.0, 226.0, 250.0, 1.0);
}

+ ( UIColor* )
vanitySeparatorColor
{
    return RGBA_GRAY_COLOR(233.0);
}

+ ( UIColor* )
buttonTextColor
{
    return RGBA_GRAY_COLOR(0.0);
}

+ ( UIColor* )
textFieldColor
{
    return RGBA_GRAY_COLOR(255.0);
}

+ ( UIColor* )
textFieldPlaceholderColor
{
    return RGBA_COLOR(176.0, 176.0, 214.0, 1.0);
}

+ ( UIColor* )
underlinedButtonColor
{
    return RGBA_GRAY_COLOR(255.0);
}

+ ( UIColor* )
underlinedButtonPressColor
{
    return RGBA_COLOR(176.0, 176.0, 213.0, 1.0);
}

+ ( UIColor* )
cellSelectedStartColor
{
    return RGBA_COLOR(36.0, 132.0, 198.0, 1.0);
}

+ ( UIColor* )
cellSelectedEndColor
{
    return RGBA_COLOR(154.0, 219.0, 244.0, 1.0);
}

+ ( UIColor* )
switchOffColor
{
    return RGBA_GRAY_COLOR(255.0);
}

+ ( UIColor* )
switchOnColor
{
    return RGBA_COLOR(10.0, 165.0, 242.0, 1.0);
}

+ ( UIColor* )
switchViewStartColor
{
    return RGBA_GRAY_COLOR(233.0);
}

+ ( UIColor* )
switchViewEndColor
{
    return RGBA_COLOR(209.0, 210.0, 212.0, 1.0);
}

+ ( UIColor* )
switchTextColor
{
    return RGBA_GRAY_COLOR(0.0);
}

+ ( UIColor* )
chatToolbarTintColor
{
    return RGBA_COLOR(44.0, 44.0, 76.0, 1.0);
}

+ ( UIColor* )
chatToolbarSendButtonColor
{
    return RGBA_COLOR(94.0, 94.0, 173.0, 1.0);
}

+ ( UIColor* )
separatorInputBarColor {
    
    return RGBA_GRAY_COLOR(173.0);
}

+ ( UIColor* )
buttonDeleteRedColor
{
    return RGBA_COLOR(186.0, 37.0, 98.0, 1.0);
}

+ ( UIColor* )
buttonCallGreenColor
{
    return RGBA_COLOR(94.0, 94.0, 173.0, 1.0);
}

+ ( UIColor* )
buttonCallYellowColor
{
    return RGBA_COLOR(242.0, 178.0, 0.0, 1.0);
}

+ ( UIColor* )
statusRedColor {
    
    return RGBA_COLOR(186.0, 37.0, 98.0, 1.0);
}

+ ( UIColor* )
statusGreenColor {
    
    return RGBA_COLOR(94.0, 94.0, 173.0, 1.0);
}

+ ( UIColor* )
statusYellowColor {
    
    return RGBA_COLOR(242.0, 178.0, 0.0, 1.0);
}

+ ( UIColor* )
statusBlueColor {
    
    return RGBA_COLOR(10.0, 165.0, 242.0, 1.0);
}

+ ( UIColor* )
chatSenderColor
{
    return RGBA_COLOR(94.0, 94.0, 173.0, 1.0);
}

+ ( UIColor* )
chatOutBodyColor
{
    return RGBA_GRAY_COLOR(0.0);
}

+ ( UIColor* )
linkColor
{
    return [UIColor blueColor];
}

+ ( UIColor* )
chatTimeOutStatusColor
{
    return RGBA_GRAY_COLOR(137.0);
}

+ ( UIColor* )
chatTimeInStatusColor
{
    return RGBA_GRAY_COLOR(137.0);
}

+ ( UIColor* )
failedToSendColor
{
    return RGBA_COLOR(211.0, 39.0, 42.0, 1.0);
}

+ ( UIColor* )
chatInBodyColor
{
    return RGBA_GRAY_COLOR(0.0);
}

+ (UIColor*) notificationExclamationColor
{
    return RGBA_COLOR(0xCD, 0x07, 0x1E, 1.0);
}

+ (UIColor*) outgoingMessageTextColor
{
    return RGBA_GRAY_COLOR(0.0);
}

+ (UIColor*) outgoingMessageDateColor
{
    return RGBA_GRAY_COLOR(137.0);
}

+ (UIColor*) incomingMessageTextColor
{
    return RGBA_GRAY_COLOR(0.0);
}

+ (UIColor*) incomingMessageDateColor
{
    return RGBA_GRAY_COLOR(137.0);
}

+ (UIColor*) incomingMessageSenderColor
{
    return RGBA_COLOR(10.0, 165.0, 242.0, 1.0);
}

+ (UIColor*) incomingMessageReceiverColor
{
    return RGBA_COLOR(94.0, 94.0, 173.0, 1.0);
}

+ (UIColor*) avatarInCellBackgroundColor
{
    return RGBA_COLOR(94.0, 94.0, 173.0, 1.0);
}

+ (UIColor*) avatarInCellTextColor
{
    return RGBA_COLOR(255.0, 255.0, 255.0, 1.0);
}

+ (UIColor*) callEventTextColor
{
    return RGBA_GRAY_COLOR(0.0);
}

+ ( UIColor* )
aboutTitleColor
{
    return RGBA_COLOR(71.0, 82.0, 163.0, 1.0);
}

+ ( UIColor* )
aboutSubtitleColor
{
    return RGBA_GRAY_COLOR(0.0);
}

+ ( UIColor* )
grayButtonTextColor
{
    return RGBA_GRAY_COLOR(0.0);
}

+ ( UIColor* )
loginLabelColor
{
    return RGBA_GRAY_COLOR(255.0);
}

+ ( UIColor* )
greenBorderColor
{
    return RGBA_COLOR(24.0, 51.0, 50.0, 1.0);
}

+ ( UIColor* )
blueBorderColor
{
    return [self navigationBarTintColor];
}

+ ( UIColor* )
contactInfoViewColor
{
    return RGBA_COLOR(0.0, 0.0, 0.0, 0.7);
}

+ ( UIColor* )
contactInfoLightLabelsColor
{
    return RGBA_COLOR(204.0, 203.0, 203.0, 1.0);
}

+ ( UIColor* )
videoSceneResumeButtonLabelsColor
{
    return RGBA_COLOR(94.0, 167.0, 46.0, 1.0);
}

+ ( UIColor* )
activityTextColor
{
    return RGBA_GRAY_COLOR(255.0);
}

+ ( UIColor* )
cellTextColor
{
    return RGBA_GRAY_COLOR(102.0);
}

+ ( UIColor* )
activityBackgroundColor
{
    return RGBA_COLOR(0.0, 0.0, 10.0, 0.87);
}

+ ( UIColor* )
unreadMsgColor
{
    return RGBA_GRAY_COLOR(255.0);
}

+ ( UIColor* )
unreadMsgBckgdColor
{
    return RGBA_COLOR(44.0, 44.0, 76.0, 1.0);
}

+ ( UIColor* )
vanityNameColor
{
    return RGBA_COLOR(0.0, 0.0, 0.0, 1.0);
}

+ ( UIColor* )
vanityEmailNameColor
{
    return RGBA_COLOR(0.0, 7.0, 45.0, 1.0);
}

+ ( UIColor* )
vanityIpAddressColor
{
    return RGBA_COLOR(0.0, 7.0, 45.0, 1.0);
}

+ ( UIColor* )
vanityBottomViewColor
{
    return RGBA_COLOR(0.0, 183.0, 233.0, 1.0);
}

+ ( UIColor* )
vanityStripesBottomViewColor
{
    return RGBA_COLOR(180.0, 186.0, 201.0, 0.5);
}

+ ( UIColor* )
availabilitySiteControlsViewBackgroundColor
{
    return RGBA_COLOR(0.0, 0.0, 0.0, 0.7);
}

+ ( UIColor* )
notificationTextColor
{
    return RGBA_GRAY_COLOR(255.0);
}

+ ( UIColor* )
cellSelectedTopColor
{
    return RGBA_COLOR(71.0, 82.0, 163.0, 1.0);
}

+ ( UIColor* )
cellSelectedBottomColor
{
    return RGBA_COLOR(0.0, 183.0, 233.0, 1.0);
}

+ ( UIColor* )
popoverBackgroundColor
{
    return RGBA_GRAY_COLOR(214.0);
}

+ ( UIColor* )
popoverTextColor
{
    return RGBA_GRAY_COLOR(0.0);
}

+ ( UIColor* )
alertViewTextColor
{
    return RGBA_COLOR(47.0, 47.0, 84.0, 1.0);
}

+ ( UIColor* )
actionSheetTextColor
{
    return RGBA_COLOR(47.0, 47.0, 84.0, 1.0);
}

+ ( UIColor* )
callTransferCellTextColor
{
    return RGBA_COLOR(44.0, 44.0, 76.0, 1.0);
}

+ ( UIColor* )
callTransferSeparatorColor
{
    return RGBA_COLOR(44.0, 44.0, 76.0, 1.0);
}

@end
