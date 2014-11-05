//
//  Store.h
//  Stockd
//
//  Created by Adam Duflo on 11/5/14.
//  Copyright (c) 2014 Amaeya Kalke. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface Store : NSObject
@property NSString *name;
@property NSString *phoneNumber;
@property CLPlacemark *placemark;
@property CLLocationDegrees latitude;
@property CLLocationDegrees longitude;
@property CGFloat distance;

@end
