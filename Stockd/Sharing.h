//
//  Sharing.h
//  Stockd
//
//  Created by Amaeya Kalke on 11/19/14.
//  Copyright (c) 2014 Amaeya Kalke. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>
#import "List.h"

@interface Sharing : PFObject <PFSubclassing>

@property NSString *listID;
@property NSString *sharedUserID;
@property NSString *sharedUsername;
@property NSString *ownerListID;
@property NSString *ownerUsername;

-(void)shareThisListWithID: (List *)list createdByUser:(PFUser *)createdBy andSharedToUser:(PFUser *)sharedUser;

@end
