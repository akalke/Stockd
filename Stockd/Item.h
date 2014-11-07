//
//  Item.h
//  Stockd
//
//  Created by Amaeya Kalke on 11/7/14.
//  Copyright (c) 2014 Amaeya Kalke. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

@interface Item : PFObject <PFSubclassing>

@property NSString *type;
@property NSString *brand;
@property NSInteger *quantity;
@property UIImage *photo;
@property NSString *listID;
@property NSString *userID;

-(void)createNewItem;
-(void)deleteItem;
-(NSArray *)getItemsForList;
-(NSArray *) getItemsForUser;

@end
