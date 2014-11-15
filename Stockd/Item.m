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
@dynamic isInFavoriteList;
@dynamic isInQuickList;
@dynamic isInInventory;
@dynamic photo;
@dynamic listID;
@dynamic image;

#pragma mark Register Parse Subclass
+(NSString *)parseClassName{
    return @"Item";
}

+(void)load{
    [self registerSubclass];
}

#pragma mark Modify/Grab Item Data
-(void)createNewItem: (NSString *)itemType forUser:(PFUser *)user inList: (NSString *)list inInventory: (BOOL)isInInventory isInQuickList: (BOOL) isInQuickList withImage: (UIImage *)image withBlock:(void(^)(void))block{

    if(image){
        self.type = itemType;
        self.userID = user.objectId;
        self.listID = list;
        self.isInQuickList = isInQuickList;
        self.isInInventory = isInInventory;

        NSData *data = UIImagePNGRepresentation(image);
        PFFile *imageFile = [PFFile fileWithData:data];
        self.image = imageFile;

        [self saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if(error){
                NSLog(@"%@", error);
            }
            else{
                NSLog(@"Item Created");
                block();
            }
        }];
    }
    else{
        self.type = itemType;
        self.userID = user.objectId;
        self.listID = list;
        self.isInQuickList = isInQuickList;
        self.isInInventory = isInInventory;

        [self saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if(error){
                NSLog(@"%@", error);
            }
            else{
                NSLog(@"Item Created");
                block();
            }
        }];

    }
}


-(void)deleteItemWithBlock:(void(^)(void))block{
    [self deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if(error){
            NSLog(@"%@", error);
        }
        else{
            NSLog(@"Item Deleted");
            block();
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

@end
