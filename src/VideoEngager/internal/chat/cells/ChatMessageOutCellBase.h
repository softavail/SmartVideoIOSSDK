//
//  ChatMessageOutCellBase.h
//  instac
//
//  Created by Bozhko Terziev on 11/20/14.
//  Copyright (c) 2014 SoftAvail. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ChatMessageOutCellBaseDelegate;

@interface ChatMessageOutCellBase : UITableViewCell
{
    
}

@property(weak, nonatomic) id <ChatMessageOutCellBaseDelegate> delegate;

@property ( strong, nonatomic   ) NSString* messageId;
@property ( strong, nonatomic   ) NSString* labelBodyText;
@property ( strong, nonatomic   ) NSString* labelTimeText;
@property ( nonatomic           ) BOOL      failedToSend;
@property ( nonatomic           ) BOOL      enableTapGesture;

@end

@protocol ChatMessageOutCellBaseDelegate <NSObject>

- (void) didSelectOutgoingCell: ( ChatMessageOutCellBase* ) outCell;

@end
