//
//  ListDetailViewController.m
//  Stockd
//
//  Created by Amaeya Kalke on 11/10/14.
//  Copyright (c) 2014 Amaeya Kalke. All rights reserved.
//

#define stockdBlueColor [UIColor colorWithRed:32.0/255.0 green:59.0/255.0 blue:115.0/255.0 alpha:1.0]
#define stockdOrangeColor [UIColor colorWithRed:217.0/255.0 green:126.0/255.0 blue:0.0/255.0 alpha:1.0]
#define peachBackground [UIColor colorWithRed:255.0/255.0 green:223.0/255.0 blue:181.0/255.0 alpha:1.0]
#define navBarColor [UIColor colorWithRed:231.0/255.0 green:95.0/255.0 blue:73.0/255.0 alpha:1.0]

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
    
    [self getItemsForConditional];
    
    self.navigationController.navigationBar.barTintColor = navBarColor;
    self.navigationController.navigationBar.tintColor = stockdBlueColor;
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.titleTextAttributes = @{NSFontAttributeName:[UIFont fontWithName:@"Avenir" size:18.0],NSForegroundColorAttributeName:[UIColor blackColor]};
    [self.navigationController.navigationBar setBarStyle:UIBarStyleDefault];
    
    self.tabBarController.delegate = self;
    self.didSelectItem = NO;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
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

#pragma mark - TableView Methods

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
    if (tabBarController.selectedIndex == 0) {
        [(UINavigationController *)viewController popToRootViewControllerAnimated:NO];
    }
}

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

// needed for editActionsForRowAtIndexPath to work (it doesn't need anything inside)
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    
}

- (NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    Item *item = [self.items objectAtIndex:indexPath.row];
    UITableViewRowAction *removeQuickList = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"Remove" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
        
        [item setObject:[NSNumber numberWithBool:NO] forKey:@"isInQuickList"];
        [item saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            [self getItemsForQuickList];
            [self.tableView setEditing:NO];
        }];
    }];
    removeQuickList.backgroundColor = stockdOrangeColor;
    
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

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    self.didSelectItem = YES;
    [self performSegueWithIdentifier:@"createNewItemFromListSegue" sender:self];
}

#pragma mark - Helper Methods

- (void)getItemsForConditional {
    if (self.list.isQuickList == YES) {
        self.addItemButton.tintColor = [UIColor clearColor];
        self.addItemButton.enabled = NO;
        [self getItemsForQuickList];
    } else {
        [self getItems:self.listID];
    }
}

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
