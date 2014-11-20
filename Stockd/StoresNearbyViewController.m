//
//  StoresNearbyViewController.m
//  Stockd
//
//  Created by Adam Duflo on 11/5/14.
//  Copyright (c) 2014 Amaeya Kalke. All rights reserved.
//

#define peachBackground [UIColor colorWithRed:255.0/255.0 green:223.0/255.0 blue:181.0/255.0 alpha:1.0]
#define navBarColor [UIColor colorWithRed:231.0/255.0 green:95.0/255.0 blue:73.0/255.0 alpha:1.0]
#define turqouise [UIColor colorWithRed:0.0/255.0 green:191.0/255.0 blue:255.0/255.0 alpha:0.80]

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
    
    [self setNavBarDisplay];
    [self setTapGesture];
    [self setViewElements];
}

#pragma mark - MapView Methods

// Assigning properties for annotations
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    // Returning no changes if annotation is userLocation
    if (annotation == mapView.userLocation) {
        return nil;
    }
    
    // Setting annotation properties for store annotations
    MKPinAnnotationView *pin = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"Pin"];
    pin.image = [UIImage imageNamed:@"stockd_annotation"];
    pin.canShowCallout = YES;
    
    return pin;
}

// Method to check if user location was updated
- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
    // Setting bool for when location is updated
    self.userLocationUpdated = YES;
}

// Method to check if region changed
- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    // Conditional that checks if a search happened
    if (self.didSearchForNearbyStores == YES) {
        // Removes all store annotations and calls findStoresNearby when region finished changing
        [self.mapView removeAnnotations:self.mapView.annotations];
        [self findStoresNearby:mapView.centerCoordinate];
    }
}

// Method to show annotation callout
- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    // Doesn't show callout if annotation is userLocation and hides buttons for directions/call
    if (view.annotation == mapView.userLocation) {
        self.viewForButtons.hidden = YES;
        return;
    }
    
    // Assigning the annotation to store (uses title property in store.h)
    Store *store = view.annotation;
    // Calls method to create mapItem for use by Directions button
    [self makeMapItemWith:store];
}

#pragma mark - LocationManager Methods

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"Failure Error: %@", error);
}

// Method that gets location of when Current Location is searched
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    for (CLLocation *location in locations) {
        if (location.verticalAccuracy < 1000 && location.horizontalAccuracy < 1000) {
            // Calls reverseGeocode method to get location information
            [self reverseGeocode:location];
            [self.locationManager stopUpdatingLocation];
            // Breaks out of loop
            break;
        }
    }
}

#pragma mark - FindLocations Methods

// Method that gets location information from location parameter
- (void)reverseGeocode:(CLLocation *)location {
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        // Calls findStoresNearby method on coordinate property of location
        [self findStoresNearby:location.coordinate];
    }];
}

// Method used to find stores nearby
- (void)findStoresNearby:(CLLocationCoordinate2D)coordinate {
    // Initializing MKLocalSearchRequest to use "grocery" as keyword
    MKLocalSearchRequest *request = [[MKLocalSearchRequest alloc] init];
    request.naturalLanguageQuery = @"grocery";
    request.region = MKCoordinateRegionMake(coordinate, MKCoordinateSpanMake(0.03, 0.03));
    // Initializing MKLocalSearch with *request to find nearby stores
    MKLocalSearch *search = [[MKLocalSearch alloc] initWithRequest:request];
    [search startWithCompletionHandler:^(MKLocalSearchResponse *response, NSError *error) {
        // Initializing mutable array
        NSMutableArray *array = [NSMutableArray array];
        // Making array and assigning it to response.mapItems
        NSArray *mapItems = response.mapItems;
        // For loop to create store for each item in mapItems & add object to mutable array
        for (MKMapItem *item in mapItems) {
            Store *store = [[Store alloc] init];
            store.name = item.name;
            store.phoneNumber = item.phoneNumber;
            store.placemark = item.placemark;
            [array addObject:store];
        }
        // Setting storeArray to *array (mutable array)
        self.storeArray = array;
        // Calling setStorePins to create annotations for all stores nearby
        [self setStorePins];
    }];
}

#pragma mark - SearchBar Methods

// Method that for when "Search" button is tapped in keyboard
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    self.viewForButtons.hidden = YES;
    // Searches current location if text is "Current Location"
    if ([self.searchBar.text isEqualToString:@"Current Location"]) {
        if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied) {
            // If location isn't set in settings, alert is presented
            [self currentLocationOffAlert];
        } else {
            // Removes annotations, calls useCurrentLocation, sets bool for didSearchForNearbyStores
            [self.mapView removeAnnotations:self.mapView.annotations];
            
            [self useCurrentLocation];
            
            self.didSearchForNearbyStores = YES;
        }
    } else {
        // Removes annotations
        [self.mapView removeAnnotations:self.mapView.annotations];
        
        // Initializes *geocoder and searches for location based on text in searchBar
        CLGeocoder *geocoder = [[CLGeocoder alloc] init];
        NSString *searchQuery = [NSString stringWithFormat:@"%@", self.searchBar.text];
        [geocoder geocodeAddressString:searchQuery completionHandler:^(NSArray *placemarks, NSError *error) {
            for (CLPlacemark *placemark in placemarks) {
                // Uses coordinate for searched location and calls findStoresNearby
                [self findStoresNearby:placemark.location.coordinate];
                
                // Zoomes onto searched area
                [self zoomMapWith:placemark.location];
                
                // Sets bool for didSearchForNearbyStores
                self.didSearchForNearbyStores = YES;
            }
        }];
    }
    // Hiding cancel button and resigning keyboard when search is pressed
    [self.searchBar setShowsCancelButton:NO animated:YES];
    [self.searchBar resignFirstResponder];
}

// Method shows cancel button when text in searchBar begins editing
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    [self.searchBar setShowsCancelButton:YES animated:YES];
}

// Method that sets searchBar text to nothing, hides cancel button, and resigns keyboard when cancel is pressed
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    self.searchBar.text = @"";
    [self.searchBar setShowsCancelButton:NO animated:YES];
    [self.searchBar resignFirstResponder];
}

#pragma mark - Helper Methods

- (void) setViewElements {
    // Seting up locationManager
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    [self.locationManager requestWhenInUseAuthorization];
    
    // Setting up searchBar
    self.searchBar = [[UISearchBar alloc] init];
    self.searchBar.delegate = self;
    self.searchBar.placeholder = @"Search by City, Zip, or Current Location";
    
    // Assigning searchBar as titleView
    self.navigationItem.titleView = self.searchBar;
    
    // Initializing storeArray
    self.storeArray = [NSMutableArray array];
    
    // Hiding directions & call store buttons & setting background of
    self.viewForButtons.hidden = YES;
}

- (void) setNavBarDisplay {
    // Setting navigation bar properties
    self.navigationController.navigationBar.barTintColor = navBarColor;
    self.navigationController.navigationBar.tintColor = [UIColor blackColor];
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.titleTextAttributes = @{NSFontAttributeName:[UIFont fontWithName:@"Avenir" size:18.0f],NSForegroundColorAttributeName:[UIColor blackColor]};
    [self.navigationController.navigationBar setBarStyle:UIBarStyleDefault];
}

- (void) setTapGesture {
    // Setting up tap gesture to resign keyboard
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(resignKeyboardOnTap:)];
    [tapGesture setNumberOfTapsRequired:1];
    [tapGesture setNumberOfTouchesRequired:1];
    [self.view addGestureRecognizer:tapGesture];
}

// Method used by tapGesture to hide cancel button in searchBar and resign keyboard
- (void)resignKeyboardOnTap:(UITapGestureRecognizer *)sender {
    [self.searchBar setShowsCancelButton:NO animated:YES];
    [self.searchBar resignFirstResponder];
}

- (void)makeMapItemWith:(Store *)store {
    // Sets storePhoneNumber to selected stores phoneNumber property
    self.storePhoneNumber = store.phoneNumber;
    
    // Initializes MKPlacemark for Maps app to use
    MKPlacemark *mkPlacemark = [[MKPlacemark alloc] initWithPlacemark:store.placemark];
    self.mapItem = [[MKMapItem alloc] initWithPlacemark:mkPlacemark];
    
    // Shows call and directions buttons
    self.viewForButtons.hidden = NO;
}

// Sets annotations for each store within storeArray
- (void)setStorePins {
    for (Store *store in self.storeArray) {
        [self.mapView addAnnotation:store];
    }
}

// Method used to zoom on searched area
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

// Searches for current location (either searched from searchBar or when button is tapped)
- (void)useCurrentLocation {
    if (self.userLocationUpdated == YES) {
        self.searchBar.text = @"Current Location";
        
        [self.locationManager startUpdatingLocation];
        
        [self zoomMapWith:self.mapView.userLocation.location];
    }
}

// Shows alert if Location is set to off, and gives options to go to settings, or keep it off
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
