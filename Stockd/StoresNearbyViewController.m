//
//  StoresNearbyViewController.m
//  Stockd
//
//  Created by Adam Duflo on 11/5/14.
//  Copyright (c) 2014 Amaeya Kalke. All rights reserved.
//

#define stockdBlueColor [UIColor colorWithRed:32.0/255.0 green:59.0/255.0 blue:115.0/255.0 alpha:1.0]
#define stockdOrangeColor [UIColor colorWithRed:217.0/255.0 green:126.0/255.0 blue:0.0/255.0 alpha:1.0]
#define peachBackground [UIColor colorWithRed:255.0/255.0 green:223.0/255.0 blue:181.0/255.0 alpha:1.0]
#define navBarColor [UIColor colorWithRed:231.0/255.0 green:95.0/255.0 blue:73.0/255.0 alpha:1.0]

#import "StoresNearbyViewController.h"
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import "Store.h"

@interface StoresNearbyViewController () <MKMapViewDelegate, CLLocationManagerDelegate, UISearchBarDelegate, UIGestureRecognizerDelegate>
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UIView *viewForButtons;
@property CLLocationManager *locationManager;
@property NSMutableArray *storeArray;
@property MKMapItem *mapItem;
@property UISearchBar *searchBar;
@property NSString *storePhoneNumber;
@property BOOL userLocationUpdated;
@property BOOL didSearchForNearbyStores;

@end

@implementation StoresNearbyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    [self.locationManager requestWhenInUseAuthorization];
    
    self.searchBar = [[UISearchBar alloc] init];
    self.searchBar.delegate = self;
    self.searchBar.placeholder = @"Search by City, Zip, or Current Location";
    
    self.navigationItem.titleView = self.searchBar;
    
    self.storeArray = [NSMutableArray array];
    
    self.viewForButtons.hidden = YES;
    self.viewForButtons.backgroundColor = peachBackground;
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(resignKeyboardOnTap:)];
    [tapGesture setNumberOfTapsRequired:1];
    [tapGesture setNumberOfTouchesRequired:1];
    [self.view addGestureRecognizer:tapGesture];
    self.view.backgroundColor = peachBackground;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBar.barTintColor = navBarColor;
    self.navigationController.navigationBar.tintColor = stockdBlueColor;
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.titleTextAttributes = @{NSFontAttributeName:[UIFont fontWithName:@"Arial-BoldMT" size:18.0f],NSForegroundColorAttributeName:[UIColor blackColor]};
    [self.navigationController.navigationBar setBarStyle:UIBarStyleDefault];
}

#pragma mark - MapView Methods

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    if (annotation == mapView.userLocation) {
        return nil;
    }
    
    MKPinAnnotationView *pin = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"Pin"];
    pin.image = [UIImage imageNamed:@"stockd_annotation"];
    pin.canShowCallout = YES;
    
    return pin;
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
    self.userLocationUpdated = YES;
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    if (self.didSearchForNearbyStores == YES) {
        [self.mapView removeAnnotations:self.mapView.annotations];
        [self findStoresNearby:mapView.centerCoordinate];
    }
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    if (view.annotation == mapView.userLocation) {
        self.viewForButtons.hidden = YES;
        return;
    }
    
    Store *store = view.annotation;
    [self makeMapItemWith:store];
}

#pragma mark - LocationManager Methods

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"Failure Error: %@", error);
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    for (CLLocation *location in locations) {
        if (location.verticalAccuracy < 1000 && location.horizontalAccuracy < 1000) {
            [self reverseGeocode:location];
            [self.locationManager stopUpdatingLocation];
            break;
        }
    }
}

#pragma mark - FindLocations Methods

- (void)reverseGeocode:(CLLocation *)location {
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        [self findStoresNearby:location.coordinate];
    }];
}

- (void)findStoresNearby:(CLLocationCoordinate2D)coordinate {
    MKLocalSearchRequest *request = [[MKLocalSearchRequest alloc] init];
    request.naturalLanguageQuery = @"grocery";
    request.region = MKCoordinateRegionMake(coordinate, MKCoordinateSpanMake(0.03, 0.03));
    MKLocalSearch *search = [[MKLocalSearch alloc] initWithRequest:request];
    [search startWithCompletionHandler:^(MKLocalSearchResponse *response, NSError *error) {
        NSMutableArray *array = [NSMutableArray array];
        NSArray *mapItems = response.mapItems;
        for (MKMapItem *item in mapItems) {
            Store *store = [[Store alloc] init];
            store.name = item.name;
            store.phoneNumber = item.phoneNumber;
            store.placemark = item.placemark;
            [array addObject:store];
        }
        self.storeArray = array;
        [self setStorePins];
    }];
}

#pragma mark - SearchBar Methods

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    self.viewForButtons.hidden = YES;
    if ([self.searchBar.text isEqualToString:@"Current Location"]) {
        if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied) {
            [self currentLocationOffAlert];
        } else {
            [self.mapView removeAnnotations:self.mapView.annotations];
            
            [self useCurrentLocation];
            
            self.didSearchForNearbyStores = YES;
        }
    } else {
        [self.mapView removeAnnotations:self.mapView.annotations];
        
        CLGeocoder *geocoder = [[CLGeocoder alloc] init];
        NSString *searchQuery = [NSString stringWithFormat:@"%@", self.searchBar.text];
        [geocoder geocodeAddressString:searchQuery completionHandler:^(NSArray *placemarks, NSError *error) {
            for (CLPlacemark *placemark in placemarks) {
                [self findStoresNearby:placemark.location.coordinate];
                
                [self zoomMapWith:placemark.location];
                
                self.didSearchForNearbyStores = YES;
            }
        }];
    }
    [self.searchBar setShowsCancelButton:NO animated:YES];
    [self.searchBar resignFirstResponder];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    [self.searchBar setShowsCancelButton:YES animated:YES];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    self.searchBar.text = @"";
    [self.searchBar setShowsCancelButton:NO animated:YES];
    [self.searchBar resignFirstResponder];
}

#pragma mark - Helper Methods

- (void)resignKeyboardOnTap:(UITapGestureRecognizer *)sender {
    [self.searchBar setShowsCancelButton:NO animated:YES];
    [self.searchBar resignFirstResponder];
}

- (void)makeMapItemWith:(Store *)store {
    self.storePhoneNumber = store.phoneNumber;
    
    MKPlacemark *mkPlacemark = [[MKPlacemark alloc] initWithPlacemark:store.placemark];
    self.mapItem = [[MKMapItem alloc] initWithPlacemark:mkPlacemark];
    
    self.viewForButtons.hidden = NO;
}

- (void)setStorePins {
    for (Store *store in self.storeArray) {
        [self.mapView addAnnotation:store];
    }
}

- (void)zoomMapWith:(CLLocation *)location {
    CLLocationCoordinate2D center = location.coordinate;
    MKCoordinateSpan span;
    span.latitudeDelta = 0.03;
    span.longitudeDelta = 0.03;
    
    MKCoordinateRegion region;
    region.center = center;
    region.span = span;
    
    [self.mapView setRegion:region animated:NO];
}

- (void)useCurrentLocation {
    if (self.userLocationUpdated == YES) {
        self.searchBar.text = @"Current Location";
        
        [self.locationManager startUpdatingLocation];
        
        [self zoomMapWith:self.mapView.userLocation.location];
    }
}

- (void)currentLocationOffAlert {
    NSString *title = @"Allow Stock'd to Access Location to Determine Your Current Location";
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *settings = [UIAlertAction actionWithTitle:@"Settings" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
    }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        self.searchBar.text = @"";
    }];
    
    [alert addAction:settings];
    [alert addAction:cancel];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - IBActions

- (IBAction)onUseCurrentLocationButtonPressed:(id)sender {
    self.viewForButtons.hidden = YES;
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied) {
        [self currentLocationOffAlert];
    } else {
        [self.mapView removeAnnotations:self.mapView.annotations];
        
        [self useCurrentLocation];
        
        self.didSearchForNearbyStores = YES;
    }
}

- (IBAction)onOpenMapsButtonPressed:(id)sender {
    [self.mapItem openInMapsWithLaunchOptions:nil];
}

- (IBAction)onPhoneButtonPressed:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel:%@", self.storePhoneNumber]]];
}

@end
