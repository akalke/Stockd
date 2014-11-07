//
//  User.m
//  Stockd
//
//  Created by Amaeya Kalke on 11/7/14.
//  Copyright (c) 2014 Amaeya Kalke. All rights reserved.
//

#import "User.h"

@interface User ()
@end

@implementation User
@dynamic username;
@dynamic password;
@dynamic emailAddress;


#pragma mark Register Parse Subclass
+(NSString *)parseClassName{
    return @"User";
}

+(void)load{
    [self registerSubclass];
}

@end
