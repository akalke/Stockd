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
@dynamic isShared;
@dynamic sourceListID;

#pragma mark Register Parse Subclass
+(NSString *)parseClassName{
    return @"List";
}

+(void)load{
    [self registerSubclass];
}


#pragma mark Modify List Data
-(void)createNewList: (PFUser *)user :(NSString *)listName withBlock:(void(^)(void))block{
    self.userID = user.objectId;
    self.isQuickList = NO;
    self.isShared = NO;
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
                [self saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    if (error) {
                        NSLog(@"%@", error);
                    } else {
                        block();
                    }
                }];
            }
        }];
    }
    else{
        return;
    }
}

-(void)createNewQuickList:(PFUser *)user withBlock:(void(^)(void))block{
    self.userID = user.objectId;
    self.name = @"Quick List";
    self.isQuickList = YES;
    self.isShared = NO;
    
    [self saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if(error){
            NSLog(@"%@", error);
        }
        else{
            NSLog(@"List Created");
            block();
        }
    }];
}

-(void)deleteListWithBlock:(void(^)(void))block{
    [self deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if(error){
            NSLog(@"%@", error);
        }
        else{
            NSLog(@"List Deleted");
            block();
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
            self.isShared = YES;
            //self.name = [NSString stringWithFormat:@"%@ (Shared)", list.name];
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
