//
//  ManagedBlurb.m
//  ProCom
//
//  Created by Patrick Sheehan on 4/9/15.
//  Copyright (c) 2015 Abraid. All rights reserved.
//

#import "ManagedBlurb.h"
#import "ManagedConvo.h"


@implementation ManagedBlurb

@dynamic convoId;
@dynamic pfId;
@dynamic text;
@dynamic createdAt;
@dynamic userId;
@dynamic username;

#pragma mark - JSQMessageData Methods

- (NSString *)senderDisplayName {
    return self.username;
}

- (NSDate *)date {
    return self.createdAt;
}

- (NSString *)senderId {
    return self.userId;
}

- (NSUInteger)messageHash {
    return 0;
}

- (BOOL)isMediaMessage {
    return false;
}

@end
