//
//  Store.m
//  Stockd
//
//  Created by Adam Duflo on 11/5/14.
//  Copyright (c) 2014 Amaeya Kalke. All rights reserved.
//

#import "Store.h"

@implementation Store

- (CLLocationCoordinate2D)coordinate {
    return self.placemark.location.coordinate;
}

- (NSString *)title {
    return self.name;
}

- (NSString *)subtitle {
    return [NSString stringWithFormat:@"Tap to Call: %@", self.phoneNumber];
}

@end
