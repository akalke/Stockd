//
//  Item.m
//  Stockd
//
//  Created by Amaeya Kalke on 11/7/14.
//  Copyright (c) 2014 Amaeya Kalke. All rights reserved.
//

#import "Item.h"

@interface Item ()
@property NSArray *itemsForList;
@property NSArray *itemsForUser;
@end

@implementation Item

@dynamic brand;
@dynamic type;
@dynamic quantity;
@dynamic userID;
@dynamic photo;
@dynamic listID;

#pragma mark Register Parse Subclass
+(NSString *)parseClassName{
    return @"Item";
}

+(void)load{
    [self registerSubclass];
}

#pragma mark Modify/Grab Item Data
-(void)createNewItem: (NSString *)itemBrand :(NSString *)itemType :(User *)user :(NSString *)list{
    self.brand = itemBrand;
    self.type = itemType;
    self.userID = user.objectId;
    self.listID = list;

    [self saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if(error){
            NSLog(@"%@", error);
        }
        else{
            NSLog(@"Item Created");
        }
    }];
}

-(void)deleteItem{
    [self deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if(error){
            NSLog(@"%@", error);
        }
        else{
            NSLog(@"Item Deleted");
        }
    }];
}

-(NSArray *)getItemsForList: (NSString *)currentListID{
    NSPredicate *findItemsForList = [NSPredicate predicateWithFormat:@"listID = %@", currentListID];
    PFQuery *itemQuery = [PFQuery queryWithClassName:[List parseClassName] predicate: findItemsForList];
    [itemQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if(error) {
            NSLog(@"%@", error);
            NSArray *array = [NSArray new];
            self.itemsForList = array;
        }
        else{
            self.itemsForList = objects;
        }
    }];
    return self.itemsForList;
}

-(NSArray *) getItemsForUser: (NSString *)currentUserID{
    NSPredicate *findItemsForUser = [NSPredicate predicateWithFormat:@"userID = %@", currentUserID];
    PFQuery *itemQuery = [PFQuery queryWithClassName:[List parseClassName] predicate: findItemsForUser];
    [itemQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if(error) {
            NSLog(@"%@", error);
            NSArray *array = [NSArray new];
            self.itemsForUser = array;
        }
        else{
            self.itemsForUser = objects;
        }
    }];
    return self.itemsForUser;
}

@end
