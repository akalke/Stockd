//
//  Photo.m
//  Stockd
//
//  Created by Amaeya Kalke on 11/13/14.
//  Copyright (c) 2014 Amaeya Kalke. All rights reserved.
//

#import "Photo.h"

@implementation Photo

@dynamic itemID;
@dynamic uploadedBy;


+(NSString *)parseClassName{
    return @"Photo";
}

+(void)load{
    [self registerSubclass];
}

-(void)createPhotoObject: (NSString *)itemID :(PFUser *)uploadByUser{
    self.itemID = itemID;
    self.uploadedBy = uploadByUser.objectId;
}

@end
