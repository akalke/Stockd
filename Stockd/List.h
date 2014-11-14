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

-(void)createNewList: (PFUser *)user :(NSString *)listName;
-(void)createNewQuickList:(PFUser *)user;
-(NSArray *)getListsForUser: (PFUser *)user;
-(void)deleteList;

@end
