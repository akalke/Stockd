//
//  List.m
//  Stockd
//
//  Created by Amaeya Kalke on 11/7/14.
//  Copyright (c) 2014 Amaeya Kalke. All rights reserved.
//

#import "List.h"

@interface List ()
@property NSArray *listsArray;
@end

@implementation List

@dynamic userID;
@dynamic name;
@dynamic isQuickList;

#pragma mark Register Parse Subclass
+(NSString *)parseClassName{
    return @"List";
}

+(void)load{
    [self registerSubclass];
}


#pragma mark Modify List Data
-(void)createNewList: (User *)user :(NSString *)listName{
    self.userID = user.objectId;
    self.isQuickList = NO;

    if(![listName isEqualToString:@"Quick List"] || ![listName isEqualToString:@""]){
        self.name = listName;
        [self saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if(error){
                NSLog(@"%@", error);
            }
            else{
                NSLog(@"List Created");
            }
        }];
    }
    else{
        return;
    }
}

-(void)createNewQuickList:(PFUser *)user{
    self.userID = user.objectId;
    self.name = @"Quick List";
    self.isQuickList = YES;

    [self saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if(error){
            NSLog(@"%@", error);
        }
        else{
            NSLog(@"List Created");
        }
    }];
}

-(NSArray *)getListsForUser: (NSString *)userID{
    NSPredicate *findLists = [NSPredicate predicateWithFormat:@"userID = %@", userID];
    PFQuery *listQuery = [PFQuery queryWithClassName:[List parseClassName] predicate: findLists];
    [listQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if(error) {
            NSLog(@"%@", error);
            NSArray *array = [NSArray new];
            self.listsArray = array;
        }
        else{
            self.listsArray = objects;
        }
    }];
    return self.listsArray;
}

-(void)deleteList{
    [self deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if(error){
            NSLog(@"%@", error);
        }
        else{
            NSLog(@"List Deleted");
        }
    }];
}

@end
