//
//  ManagedBlurb.h
//  ProCom
//
//  Created by Patrick Sheehan on 4/9/15.
//  Copyright (c) 2015 Abraid. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class ManagedConvo;

@interface ManagedBlurb : NSManagedObject

@property (nonatomic, retain) NSString * objectId;
@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) NSDate * createdAt;
@property (nonatomic, retain) ManagedConvo *convo;

@end
