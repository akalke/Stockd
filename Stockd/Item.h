//
//  Item.h
//  Stockd
//
//  Created by Amaeya Kalke on 11/6/14.
//  Copyright (c) 2014 Amaeya Kalke. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class List, User;

@interface Item : NSManagedObject

@property (nonatomic, retain) NSString * user_id;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * brand;
@property (nonatomic, retain) NSNumber * quantity;
@property (nonatomic, retain) NSData * image;
@property (nonatomic, retain) NSNumber * isRunningLow;
@property (nonatomic, retain) NSString * list_id;
@property (nonatomic, retain) User *item_of_user;
@property (nonatomic, retain) List *item_of_list;

@end
