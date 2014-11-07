//
//  User.h
//  Stockd
//
//  Created by Amaeya Kalke on 11/7/14.
//  Copyright (c) 2014 Amaeya Kalke. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

@interface User : PFObject <PFSubclassing>

@property NSString *username;
@property NSString *password;
@property NSString *emailAddress;

@end
