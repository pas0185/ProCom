//
//  Group.h
//  ProCom
//
//  Created by Patrick Sheehan on 4/7/15.
//  Copyright (c) 2015 Abraid. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Group : NSManagedObject

@property (nonatomic, retain) NSString * objectId;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * parentId;
@property (nonatomic, retain) NSDate * createdAt;

@end
