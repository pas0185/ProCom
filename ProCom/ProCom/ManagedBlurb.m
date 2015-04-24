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
//@dynamic profilePic;

#pragma mark - JSQMessageData Methods

- (NSDate *)date {
    return self.createdAt;
}

- (NSString *)senderId {
    return self.userId;
}

#pragma mark - Helper Methods

- (NSString *)senderDisplayName {
    return self.username;
}

- (NSUInteger)messageHash {
    return self.text.hash;
}

- (NSString *) userPic {
    NSString *profilePicURL = currentUser[@"profilePicture"];
    return profilePicURL;
}

- (BOOL)isMediaMessage {
    return false;
}

@end
