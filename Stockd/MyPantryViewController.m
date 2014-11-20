//
//  MyPantryViewController.m
//  Stockd
//
//  Created by Adam Duflo on 11/5/14.
//  Copyright (c) 2014 Amaeya Kalke. All rights reserved.
//

#define peachBackground [UIColor colorWithRed:255.0/255.0 green:223.0/255.0 blue:181.0/255.0 alpha:1.0]
#define navBarColor [UIColor colorWithRed:231.0/255.0 green:95.0/255.0 blue:73.0/255.0 alpha:1.0]
#define turqouise [UIColor colorWithRed:0.0/255.0 green:191.0/255.0 blue:255.0/255.0 alpha:0.80]

#import "MyPantryViewController.h"
#import "CreateItemViewController.h"
#import "Item.h"

@interface MyPantryViewController () <UITableViewDelegate, UITableViewDataSource>
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property Item *items;
@property NSArray *pantryArray;
@property NSMutableArray *addItemsToList;
@property BOOL didSelectItemToEdit;

@end

@implementation MyPantryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setNavBarDisplay];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // Calls method to get pantry items
    [self getPantry:[PFUser currentUser]];
    
    self.didSelectItemToEdit = NO;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"createNewItemFromMyPantrySegue"]) {
        CreateItemViewController *createItemVC = segue.destinationViewController;
        if (self.didSelectItemToEdit == YES) {
            createItemVC.editingFromMyPantry = YES;
            
            Item *item = [self.pantryArray objectAtIndex:self.tableView.indexPathForSelectedRow.row];
            createItemVC.item = item;
        } else {
            createItemVC.fromMyPantry = YES;
        }
    }
}

#pragma mark - TableView Methods

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.pantryArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    Item *item = [self.pantryArray objectAtIndex:indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MyPantryCell" forIndexPath: indexPath];

    cell.textLabel.font = [UIFont fontWithName:@"Avenir" size:26.0];
    cell.textLabel.text = item.type;
    
    // Method that sets properties if item is set as QuickList item
    if (item.isInQuickList == YES) {
        cell.textLabel.textColor = turqouise;
    } else {
        cell.textLabel.textColor = [UIColor blackColor];
    }
    
    return cell;
}

// Need method for editActionsForRowAtIndexPath to work (it doesn't need anything declared inside)
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    
}

// Creates custom cell actions
- (NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    Item *item = [self.pantryArray objectAtIndex:indexPath.row];
    UITableViewRowAction *quickList = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"Quick List" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
        [self setQuickListActionFor:item];
    }];
    
    UITableViewRowAction *delete = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"Delete" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
        [item deleteItemWithBlock:^{
            [self getPantry:[PFUser currentUser]];
            [self.tableView setEditing:NO];
        }];
    }];
    
    quickList.backgroundColor = turqouise;
    
    return @[delete, quickList];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    self.didSelectItemToEdit = YES;
    [self performSegueWithIdentifier:@"createNewItemFromMyPantrySegue" sender:self];
}

#pragma mark - Helper Methods

- (void)setNavBarDisplay {
    // Setting navigation bar properties
    self.navigationController.navigationBar.barTintColor = navBarColor;
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.titleTextAttributes = @{NSFontAttributeName:[UIFont fontWithName:@"Avenir" size:18.0],NSForegroundColorAttributeName:[UIColor whiteColor]};
    [self.navigationController.navigationBar setBarStyle:UIBarStyleBlackTranslucent];
}

// Method that gets pantry items based on currentUser
-(void) getPantry: (PFUser *)currentUser{
    NSPredicate *findItemsForUser = [NSPredicate predicateWithFormat:@"(userID = %@) AND (isInPantry = true)", currentUser.objectId];
    PFQuery *itemQuery = [PFQuery queryWithClassName:[Item parseClassName] predicate: findItemsForUser];
    [itemQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if(error) {
            NSLog(@"%@", error);
        }
        else{
            NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"type" ascending:YES];
            self.pantryArray = [objects sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
            self.navigationItem.title = [NSString stringWithFormat:@"My Pantry (%lu)", (unsigned long)self.pantryArray.count];
            [self.tableView reloadData];
        }
    }];
}

- (void)setQuickListActionFor:(Item *)item {
    if (item.isInQuickList == YES) {
        [item setObject:[NSNumber numberWithBool:NO] forKey:@"isInQuickList"];
    } else if (item.isInQuickList == NO) {
        [item setObject:[NSNumber numberWithBool:YES] forKey:@"isInQuickList"];
    }
    [item saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        [self getPantry:[PFUser currentUser]];
        [self.tableView setEditing:NO];
    }];
}

#pragma mark - IBActions

- (IBAction)addItemOnButtonPress:(id)sender {
    [self performSegueWithIdentifier:@"createNewItemFromMyPantrySegue" sender:nil];
}

@end
