//
//  User.h
//  Stockd
//
//  Created by Amaeya Kalke on 11/6/14.
//  Copyright (c) 2014 Amaeya Kalke. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface User : NSManagedObject

@property (nonatomic, retain) NSString * username;
@property (nonatomic, retain) NSString * password;
@property (nonatomic, retain) NSSet *users_lists;
@property (nonatomic, retain) NSSet *users_items;
@end

@interface User (CoreDataGeneratedAccessors)

- (void)addUsers_listsObject:(NSManagedObject *)value;
- (void)removeUsers_listsObject:(NSManagedObject *)value;
- (void)addUsers_lists:(NSSet *)values;
- (void)removeUsers_lists:(NSSet *)values;

- (void)addUsers_itemsObject:(NSManagedObject *)value;
- (void)removeUsers_itemsObject:(NSManagedObject *)value;
- (void)addUsers_items:(NSSet *)values;
- (void)removeUsers_items:(NSSet *)values;

@end
