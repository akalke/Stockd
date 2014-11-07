//
//  List.h
//  Stockd
//
//  Created by Amaeya Kalke on 11/7/14.
//  Copyright (c) 2014 Amaeya Kalke. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>
#import "User.h"

@interface List : PFObject <PFSubclassing>

@property NSString *userID;
@property NSString *name;
@property BOOL isQuickList;
@property User *user;

-(void)createNewList: (User *)user :(NSString *)listName;
-(void)createNewQuickList:(User *)user;
-(NSArray *)getListsForUser: (User *)user;
-(void)deleteListForUser: (User *)user;

@end
