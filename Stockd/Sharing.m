//
//  Sharing.m
//  Stockd
//
//  Created by Amaeya Kalke on 11/19/14.
//  Copyright (c) 2014 Amaeya Kalke. All rights reserved.
//

#import "Sharing.h"

@interface Sharing ()


@end

@implementation Sharing

@dynamic listID;
@dynamic sharedUserID;
@dynamic sharedUsername;
@dynamic ownerListID;
@dynamic ownerUsername;

#pragma mark Register Parse Subclass
+(NSString *)parseClassName{
    return @"Sharing";
}

+(void)load{
    [self registerSubclass];
}

-(void)shareThisListWithID: (List *)list createdByUser:(PFUser *)createdBy andSharedToUser:(NSString *)sharedUser{
    self.listID = list.objectId;
    self.ownerUsername = createdBy.username;
    self.ownerListID = createdBy.objectId;
    self.sharedUsername = sharedUser;

    [self saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if(error){
            NSLog(@"%@", error);
        }
        else if(succeeded){
            NSLog(@"Success");
        }
        else{
            NSLog(@"No success");
        }
    }];
}

@end
