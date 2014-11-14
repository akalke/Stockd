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

-(void)createNewList: (PFUser *)user :(NSString *)listName;
-(void)createNewQuickList:(PFUser *)user;
-(NSArray *)getListsForUser: (PFUser *)user;
-(void)deleteList;
-(void)shareThisList:(List *)list withThisUser:(NSString *)username;

@end
