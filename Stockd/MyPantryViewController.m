//
//  MyPantryViewController.m
//  Stockd
//
//  Created by Adam Duflo on 11/5/14.
//  Copyright (c) 2014 Amaeya Kalke. All rights reserved.
//

#define stockdBlueColor [UIColor colorWithRed:32.0/255.0 green:59.0/255.0 blue:115.0/255.0 alpha:1.0]
#define stockdOrangeColor [UIColor colorWithRed:217.0/255.0 green:126.0/255.0 blue:0.0/255.0 alpha:1.0]
#define peachBackground [UIColor colorWithRed:255.0/255.0 green:223.0/255.0 blue:181.0/255.0 alpha:1.0]
#define navBarColor [UIColor colorWithRed:231.0/255.0 green:95.0/255.0 blue:73.0/255.0 alpha:1.0]

#import "MyPantryViewController.h"
#import "CreateItemViewController.h"
#import "Item.h"

@interface MyPantryViewController () <UITableViewDelegate, UITableViewDataSource>
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property Item *items;
@property NSArray *pantryArray;
@property NSMutableArray *addItemsToList;
@property BOOL didSelectItem;

@end

@implementation MyPantryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self getPantry:[PFUser currentUser]];
    
    self.navigationController.navigationBar.barTintColor = navBarColor;
    self.navigationController.navigationBar.tintColor = stockdBlueColor;
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.titleTextAttributes = @{NSFontAttributeName:[UIFont fontWithName:@"Avenir" size:18.0],NSForegroundColorAttributeName:[UIColor blackColor]};
    [self.navigationController.navigationBar setBarStyle:UIBarStyleDefault];
    
    self.didSelectItem = NO;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"createNewItemFromMyPantrySegue"]) {
        CreateItemViewController *createItemVC = segue.destinationViewController;
        if (self.didSelectItem == YES) {
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
    PFFile *image = [item objectForKey:@"image"];
    [image getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        if (error) {
            NSLog(@"Error: %@", error);
        } else {
            cell.imageView.image = [UIImage imageWithData:data];
        }
    }];
    cell.textLabel.font = [UIFont fontWithName:@"Avenir" size:26.0];
    if (item.isInQuickList == YES) {
        cell.textLabel.textColor = stockdOrangeColor;
    } else {
        cell.textLabel.textColor = [UIColor blackColor];
    }
    cell.textLabel.text = item.type;
    return cell;
}

// needed for editActionsForRowAtIndexPath to work (it doesn't need anything inside)
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    
}

- (NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    Item *item = [self.pantryArray objectAtIndex:indexPath.row];
    PFUser *user = [PFUser currentUser];
    UITableViewRowAction *quickList = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"Quick List" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
        if (item.isInQuickList == YES) {
            [item setObject:[NSNumber numberWithBool:NO] forKey:@"isInQuickList"];
        } else if (item.isInQuickList == NO) {
            [item setObject:[NSNumber numberWithBool:YES] forKey:@"isInQuickList"];
        }
        [item saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            [self getPantry:user];
            [self.tableView setEditing:NO];
        }];
    }];
    quickList.backgroundColor = stockdOrangeColor;
    
    UITableViewRowAction *delete = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"Delete" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
        [item deleteItemWithBlock:^{
            [self getPantry:user];
            [self.tableView setEditing:NO];
        }];
    }];
    
    return @[delete, quickList];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    self.didSelectItem = YES;
    [self performSegueWithIdentifier:@"createNewItemFromMyPantrySegue" sender:self];
}

#pragma mark - Helper Methods

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

#pragma mark - IBActions

- (IBAction)addItemOnButtonPress:(id)sender {
    [self performSegueWithIdentifier:@"createNewItemFromMyPantrySegue" sender:nil];
}

@end
