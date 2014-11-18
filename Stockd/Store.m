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
    NSString *address = [NSString stringWithFormat:@"%@ %@", self.placemark.subThoroughfare, self.placemark.thoroughfare];
    NSString *fixedAddress = [address stringByReplacingOccurrencesOfString:@"(null) " withString:@""];
    
    return [NSString stringWithFormat:@"%@", fixedAddress];
}

@end
