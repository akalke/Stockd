//
//  StoresNearbyViewController.m
//  Stockd
//
//  Created by Adam Duflo on 11/5/14.
//  Copyright (c) 2014 Amaeya Kalke. All rights reserved.
//

#import "StoresNearbyViewController.h"
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import "Store.h"

@interface StoresNearbyViewController () <MKMapViewDelegate, CLLocationManagerDelegate>
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property CLLocationManager *locationManager;
@property NSMutableArray *storeArray;

@end

@implementation StoresNearbyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.locationManager = [[CLLocationManager alloc] init];
    [self.locationManager requestWhenInUseAuthorization];
    self.locationManager.delegate = self;
    
    self.storeArray = [NSMutableArray array];
}

#pragma mark - MapView Methods

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    if (annotation == mapView.userLocation) {
        return nil;
    }
    
    MKPinAnnotationView *pin = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"Pin"];
    pin.canShowCallout = YES;
    pin.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    
    return pin;
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    NSString *storePin = [NSString stringWithFormat:@"%@", view.annotation.title];
    for (Store *store in self.storeArray) {
        if ([store.name isEqualToString:storePin]) {
            NSString *address = [NSString stringWithFormat:@"%@ %@, %@, %@", store.placemark.subThoroughfare, store.placemark.thoroughfare, store.placemark.locality, store.placemark.administrativeArea];
            self.textView.text = [NSString stringWithFormat:@"Store Details: \n%@ \n%@ \n%@ \n%@", store.name, address, store.placemark.postalCode, store.phoneNumber];
        }
    }
}

#pragma mark - LocationManager Methods

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"Failure Error: %@", error);
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    for (CLLocation *location in locations) {
        if (location.verticalAccuracy < 1000 && location.horizontalAccuracy < 1000) {
            self.textView.text = @"Found Your Location";
            
            [self reverseGeocode:location];
            [self.locationManager stopUpdatingLocation];
            break;
        }
    }
}

- (void)reverseGeocode:(CLLocation *)location {
    CLGeocoder *geocoder = [CLGeocoder new];
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        CLPlacemark *placemark = placemarks.firstObject;
        NSString *address = [NSString stringWithFormat:@"%@ %@, %@, %@", placemark.subThoroughfare, placemark.thoroughfare, placemark.locality, placemark.administrativeArea];
        self.textView.text = [NSString stringWithFormat:@"Your location: %@", address];
        [self findStoresNearby:location];
    }];
}

- (void)findStoresNearby:(CLLocation *)location {
    MKLocalSearchRequest *request = [MKLocalSearchRequest new];
    request.naturalLanguageQuery = @"grocery";
    request.region = MKCoordinateRegionMake(location.coordinate, MKCoordinateSpanMake(0.1, 0.1));
    MKLocalSearch *search = [[MKLocalSearch alloc] initWithRequest:request];
    [search startWithCompletionHandler:^(MKLocalSearchResponse *response, NSError *error) {
        NSMutableArray *array = [NSMutableArray array];
        NSArray *mapItems = response.mapItems;
        for (MKMapItem *item in mapItems) {
            Store *store = [[Store alloc] init];
            store.name = item.name;
            store.phoneNumber = item.phoneNumber;
            store.placemark = item.placemark;
            
            CLLocation *location = item.placemark.location;
            store.latitude = location.coordinate.latitude;
            store.longitude = location.coordinate.longitude;
            
            store.distance = [store.placemark.location distanceFromLocation:location];
            [array addObject:store];
        }
        self.storeArray = array;
        [self setStorePins];
    }];
}

#pragma mark - Helper Methods

- (void)setStorePins {
    for (Store *store in self.storeArray) {
        CLLocationCoordinate2D coord;
        coord.latitude = store.latitude;
        coord.longitude = store.longitude;
        
        MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
        annotation.coordinate = coord;
        annotation.title = store.name;

        [self.mapView addAnnotation:annotation];
    }
}

#pragma mark - IBActions

- (IBAction)onButtonPressed:(id)sender {
    [self.locationManager startUpdatingLocation];
    self.textView.text = @"Locating Nearby Stores";
    
    CLLocationCoordinate2D center = self.mapView.userLocation.location.coordinate;
    MKCoordinateSpan span;
    span.latitudeDelta = 0.105;
    span.longitudeDelta = 0.105;
    
    MKCoordinateRegion region;
    region.center = center;
    region.span = span;
    
    [self.mapView setRegion:region animated:YES];
}

@end
