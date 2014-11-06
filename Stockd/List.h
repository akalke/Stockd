//
//  List.h
//  Stockd
//
//  Created by Amaeya Kalke on 11/6/14.
//  Copyright (c) 2014 Amaeya Kalke. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class User;

@interface List : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * user_id;
@property (nonatomic, retain) NSNumber * isQuickList;
@property (nonatomic, retain) NSNumber * isShared;
@property (nonatomic, retain) NSSet *lists_with_item;
@property (nonatomic, retain) NSSet *lists_for_user;
@end

@interface List (CoreDataGeneratedAccessors)

- (void)addLists_with_itemObject:(NSManagedObject *)value;
- (void)removeLists_with_itemObject:(NSManagedObject *)value;
- (void)addLists_with_item:(NSSet *)values;
- (void)removeLists_with_item:(NSSet *)values;

- (void)addLists_for_userObject:(User *)value;
- (void)removeLists_for_userObject:(User *)value;
- (void)addLists_for_user:(NSSet *)values;
- (void)removeLists_for_user:(NSSet *)values;

@end
