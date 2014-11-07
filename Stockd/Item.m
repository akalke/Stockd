//
//  Item.m
//  Stockd
//
//  Created by Amaeya Kalke on 11/7/14.
//  Copyright (c) 2014 Amaeya Kalke. All rights reserved.
//

#import "Item.h"

@interface Item ()
@end

@implementation Item

@dynamic brand;
@dynamic type;
@dynamic quantity;
@dynamic userID;
@dynamic photo;
@dynamic listID;

#pragma mark Register Parse Subclass
+(NSString *)parseClassName{
    return @"Item";
}

+(void)load{
    [self registerSubclass];
}

@end
