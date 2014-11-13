//
//  Item.h
//  Stockd
//
//  Created by Amaeya Kalke on 11/7/14.
//  Copyright (c) 2014 Amaeya Kalke. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>
#import "User.h"
#import "List.h"

@interface Item : PFObject <PFSubclassing>

@property NSString *type;
@property NSString *brand;
@property NSInteger *quantity;
@property UIImage *photo;
@property BOOL isInQuickList;
@property BOOL isInFavoriteList;
@property BOOL isInInventory;
@property NSString *listID;
@property NSString *userID;

-(void)createNewItemWithType: (NSString *)itemType forUser:(PFUser *)user inList: (NSString *)list inInventory: (BOOL)isInInventory inFavorites: (BOOL) isInFavoritesList;
-(void)deleteItem;
-(NSArray *)getItemsForList: (NSString *)currentListID;
-(void) getItemsForUser: (PFUser *)currentUser andComplete:(void(^)(NSArray *items))complete;
@end
