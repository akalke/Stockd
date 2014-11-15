//
//  List.h
//  Stockd
//
//  Created by Amaeya Kalke on 11/7/14.
//  Copyright (c) 2014 Amaeya Kalke. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

@interface List : PFObject <PFSubclassing>

@property NSString *userID;
@property NSString *name;
@property BOOL isQuickList;
@property PFUser *user;
@property NSString *sharedListID;
@property NSString *sourceListID;

-(void)createNewList: (PFUser *)user :(NSString *)listName withBlock:(void(^)(void))block;
-(void)createNewQuickList:(PFUser *)user withBlock:(void(^)(void))block;
-(NSArray *)getListsForUser: (PFUser *)user;
-(void)deleteListWithBlock:(void(^)(void))block;
-(void)shareThisList:(List *)list withThisUser:(NSString *)username;

@end
