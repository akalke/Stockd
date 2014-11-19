//
//  ListDetailViewController.m
//  Stockd
//
//  Created by Amaeya Kalke on 11/10/14.
//  Copyright (c) 2014 Amaeya Kalke. All rights reserved.
//

#define peachBackground [UIColor colorWithRed:255.0/255.0 green:223.0/255.0 blue:181.0/255.0 alpha:1.0]
#define navBarColor [UIColor colorWithRed:231.0/255.0 green:95.0/255.0 blue:73.0/255.0 alpha:1.0]
#define turqouise [UIColor colorWithRed:0.0/255.0 green:191.0/255.0 blue:255.0/255.0 alpha:0.80]

#import "ListDetailViewController.h"
#import "CreateItemViewController.h"
#import "MyPantryViewController.h"
#import "Item.h"

@interface ListDetailViewController () <UITableViewDataSource, UITableViewDelegate, UITabBarControllerDelegate>
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *addItemButton;
@property NSArray *items;
@property BOOL didSelectItem;
@end

@implementation ListDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // Calls method to get items for list
    [self getItemsForConditional];
    
    // Making sure navbar properties are set when screen is selected
    self.navigationController.navigationBar.barTintColor = navBarColor;
    self.navigationController.navigationBar.tintColor = [UIColor blackColor];
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.titleTextAttributes = @{NSFontAttributeName:[UIFont fontWithName:@"Avenir" size:18.0],NSForegroundColorAttributeName:[UIColor blackColor]};
    [self.navigationController.navigationBar setBarStyle:UIBarStyleDefault];
    
    // Makes tabBarController delegate self so it can popToRootVC when tab[0] is seleceted
    // from other VCs/tabs
    self.tabBarController.delegate = self;
    
    // Sets bool for didSelectItem
    self.didSelectItem = NO;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    // Removes self as delegate
    self.tabBarController.delegate = nil;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([[segue identifier] isEqualToString:@"createNewItemFromListSegue"]) {
        CreateItemViewController *createItemVC = segue.destinationViewController;
        if (self.didSelectItem == YES) {
            createItemVC.editingFromListDetails = YES;
            
            Item *item = [self.items objectAtIndex:self.tableView.indexPathForSelectedRow.row];
            createItemVC.item = item;
        } else {
            createItemVC.fromListDetails = YES;
            createItemVC.listID = self.listID;
        }
    }
}

#pragma mark - TabBarController Methods

// Method that pops to the rootVC of the navcontroller when tab[0] is selected
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
    if (tabBarController.selectedIndex == 0) {
        [(UINavigationController *)viewController popToRootViewControllerAnimated:NO];
    }
}

#pragma mark - TableView Methods

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.items.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    Item *item = [self.items objectAtIndex:indexPath.row];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ListDetailCell" forIndexPath: indexPath];
    cell.textLabel.font = [UIFont fontWithName:@"Avenir" size:26.0];
    cell.textLabel.text = item.type;
    
    return cell;
}

// Need method for editActionsForRowAtIndexPath to work (it doesn't need anything declared inside)
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    
}

// Creates custom cell actions
- (NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    Item *item = [self.items objectAtIndex:indexPath.row];
    UITableViewRowAction *removeQuickList = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"Remove" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
        
        [item setObject:[NSNumber numberWithBool:NO] forKey:@"isInQuickList"];
        [item saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            [self getItemsForQuickList];
            [self.tableView setEditing:NO];
        }];
    }];
    removeQuickList.backgroundColor = turqouise;
    
    UITableViewRowAction *delete = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"Delete" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
        [item deleteItemWithBlock:^{
            [self getItems:self.listID];
            [self.tableView setEditing:NO];
        }];
    }];
    
    if (self.list.isQuickList == YES) {
        return @[removeQuickList];
    } else {
        return @[delete];
    }
}

// Method used when cell is selected
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    self.didSelectItem = YES;
    [self performSegueWithIdentifier:@"createNewItemFromListSegue" sender:self];
}

#pragma mark - Helper Methods

// Method that gets items based on conditional
- (void)getItemsForConditional {
    if (self.list.isQuickList == YES) {
        self.addItemButton.tintColor = [UIColor clearColor];
        self.addItemButton.enabled = NO;
        [self getItemsForQuickList];
    } else {
        [self getItems:self.listID];
    }
}

// Method that gets items if the list is QuickList
-(void)getItemsForQuickList{
    PFUser *user = [PFUser currentUser];
    NSPredicate *findQuickList = [NSPredicate predicateWithFormat:@"(userID = %@) AND (isInQuickList = true)", user.objectId];
    PFQuery *itemQuery = [PFQuery queryWithClassName:[Item parseClassName] predicate: findQuickList];
    itemQuery.cachePolicy = kPFCachePolicyCacheThenNetwork;
    [itemQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if(error) {
            NSLog(@"Error finding Item: %@", error);
        }
        else{
            self.items = objects;
            [self.tableView reloadData];
            self.title = [NSString stringWithFormat:@"%@ (%lu)", self.list.name, (unsigned long)self.items.count];
        }
    }];
}

// Method that gets items for any other list
-(void)getItems: (NSString *)listID{
    NSPredicate *findItemsForList = [NSPredicate predicateWithFormat:@"listID = %@", listID];
    PFQuery *itemQuery = [PFQuery queryWithClassName:[Item parseClassName] predicate: findItemsForList];

    if([itemQuery hasCachedResult]){
        itemQuery.cachePolicy = kPFCachePolicyCacheThenNetwork;
    }
    else{
        itemQuery.cachePolicy = kPFCachePolicyNetworkOnly;
    }
    [itemQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if(error) {
            NSLog(@"%@", error);
        }
        else{
            self.items = objects;
            [self.tableView reloadData];
            
            self.title = [NSString stringWithFormat:@"%@ (%lu)", self.list.name, (unsigned long)self.items.count];
        }
    }];
}

#pragma mark - IBActions

- (IBAction)addItemOnButtonPress:(id)sender {
    [self performSegueWithIdentifier:@"createNewItemFromListSegue" sender:self];
}

@end
