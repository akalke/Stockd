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
@dynamic sharedListID;
@dynamic sourceListID;

#pragma mark Register Parse Subclass
+(NSString *)parseClassName{
    return @"List";
}

+(void)load{
    [self registerSubclass];
}


#pragma mark Modify List Data
-(void)createNewList: (PFUser *)user :(NSString *)listName{
    self.userID = user.objectId;
    self.isQuickList = NO;
    //self.sourceListID =  self.objectId;

    if(![listName isEqualToString:@"Quick List"] || ![listName isEqualToString:@""]){
        self.name = listName;
        [self saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if(error){
                NSLog(@"%@", error);
            }
            else{
                NSLog(@"List Created");
                [self setObject:self.objectId forKey:@"sourceListID"];
                [self saveInBackground];
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

-(void)shareThisList:(List *)list withThisUser:(NSString *)username{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"username = %@", username];
    PFQuery *userQuery = [PFQuery queryWithClassName:[PFUser parseClassName] predicate:predicate];
    [userQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if(error){
            NSLog(@"%@", error);
        }
        else if (objects.count != 0){
            self.userID = [objects[0] objectId];
            self.isQuickList = NO;
            self.name = [NSString stringWithFormat:@"%@ (Shared)", list.name];
            self.sourceListID = list.objectId;

            [self saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if(error){
                    NSLog(@"%@", error);
                }
                else{
                    NSLog(@"List Created");
                    [list setObject:list.objectId forKey:@"sourceListID"];
                    [list saveInBackground];
                }
            }];
        }
        else{
            NSLog(@"Can't share");
        }
    }];
}

@end
