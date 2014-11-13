//
//  Photo.h
//  Stockd
//
//  Created by Amaeya Kalke on 11/13/14.
//  Copyright (c) 2014 Amaeya Kalke. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

@interface Photo : PFObject <PFSubclassing>
@property NSString *uploadedBy;
@property NSString *itemID;

-(void)createPhotoObject: (NSString *)itemID :(PFUser *)uploadByUser;

@end
