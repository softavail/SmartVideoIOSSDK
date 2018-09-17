//
//  ChatMessageInCellBase.h
//  instac
//
//  Created by Bozhko Terziev on 11/20/14.
//  Copyright (c) 2014 SoftAvail. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ChatMessageInCellBaseDelegate;

@interface ChatMessageInCellBase : UITableViewCell
{
    
}

@property(weak, nonatomic) id <ChatMessageInCellBaseDelegate> delegate;

@property ( strong, nonatomic ) NSString* messageId;
@property ( strong, nonatomic ) NSString* labelBodyText;
@property ( strong, nonatomic ) NSString* labelTimeText;
@property ( strong, nonatomic ) NSString* labelSenderText;
@property ( nonatomic         ) BOOL bHideSender;
@property ( nonatomic         ) BOOL enableTapGesture;
@property (strong, nonatomic  ) NSString *strMDN;

@end

@protocol ChatMessageInCellBaseDelegate <NSObject>

- (void) didSelectIncomingCell: ( ChatMessageInCellBase* ) inCell;

@end
