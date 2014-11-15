//
//  InventoryViewController.m
//  Stockd
//
//  Created by Adam Duflo on 11/5/14.
//  Copyright (c) 2014 Amaeya Kalke. All rights reserved.
//

#define stockdBlueColor [UIColor colorWithRed:32.0/255.0 green:59.0/255.0 blue:115.0/255.0 alpha:1.0]
#define stockdOrangeColor [UIColor colorWithRed:217.0/255.0 green:126.0/255.0 blue:0.0/255.0 alpha:1.0]

#import "InventoryViewController.h"
#import <Parse/Parse.h>
#import "Item.h"
#import "CreateItemViewController.h"

@interface InventoryViewController () <UITableViewDelegate, UITableViewDataSource>
@property NSArray *inventory;
@property Item *items;
@property NSString *userID;
@property NSMutableArray *addItemsToList;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property BOOL didSelectItem;

@end

@implementation InventoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    PFUser *currentUser = [PFUser currentUser];
    [self getInventory:currentUser];
    
    self.navigationController.navigationBar.barTintColor = stockdBlueColor;
    self.navigationController.navigationBar.tintColor = stockdOrangeColor;
    self.navigationController.navigationBar.translucent = NO;
    //    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"navbar-image"]];
    //    self.navigationItem.titleView = imageView;
    self.navigationItem.title = @"Stock'd";
    self.navigationController.navigationBar.titleTextAttributes = @{NSFontAttributeName:[UIFont fontWithName:@"Arial-BoldMT" size:30.0f],NSForegroundColorAttributeName:[UIColor whiteColor]};
    [self.navigationController.navigationBar setBarStyle:UIBarStyleBlackTranslucent];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    PFUser *currentUser = [PFUser currentUser];
    [self getInventory:currentUser];
    
    self.didSelectItem = NO;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"createNewItemFromInventorySegue"]) {
        CreateItemViewController *createItemVC = segue.destinationViewController;
        if (self.didSelectItem == YES) {
            createItemVC.editingFromInventory = YES;
            
            Item *item = [self.inventory objectAtIndex:self.tableView.indexPathForSelectedRow.row];
            createItemVC.item = item;
        } else {
            createItemVC.fromInventory = YES;
        }
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.inventory.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    Item *item = [self.inventory objectAtIndex:indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MyInventoryCell" forIndexPath: indexPath];
    PFFile *image = [item objectForKey:@"image"];
    [image getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        if (error) {
            NSLog(@"Error: %@", error);
        } else {
            cell.imageView.image = [UIImage imageWithData:data];
        }
    }];
    
    if (item.isInQuickList == YES) {
        cell.textLabel.textColor = [UIColor blueColor];
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
    Item *item = [self.inventory objectAtIndex:indexPath.row];
    PFUser *user = [PFUser currentUser];
    UITableViewRowAction *quickList = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"Quick List" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
        if (item.isInQuickList == YES) {
            [item setObject:[NSNumber numberWithBool:NO] forKey:@"isInQuickList"];
        } else if (item.isInQuickList == NO) {
            [item setObject:[NSNumber numberWithBool:YES] forKey:@"isInQuickList"];
        }
        [item saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            [self getInventory:user];
            [self.tableView setEditing:NO];
        }];
    }];
    quickList.backgroundColor = [UIColor blueColor];
    
    UITableViewRowAction *delete = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"Delete" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
        // need completion block from deleteInBackgroundWithBlock method
        [item deleteItemWithBlock:^{
            [self getInventory:user];
            [self.tableView setEditing:NO];
        }];
//        [item deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
//            [self getInventory:user];
//            [self.tableView setEditing:NO];
//        }];
    }];
    
    return @[delete, quickList];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    self.didSelectItem = YES;
    [self performSegueWithIdentifier:@"createNewItemFromInventorySegue" sender:self];
}

-(void) getInventory: (PFUser *)currentUser{
    NSPredicate *findItemsForUser = [NSPredicate predicateWithFormat:@"(userID = %@) AND (isInInventory = true)", currentUser.objectId];
    PFQuery *itemQuery = [PFQuery queryWithClassName:[Item parseClassName] predicate: findItemsForUser];
    [itemQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if(error) {
            NSLog(@"%@", error);
        }
        else{
            NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"type" ascending:YES];
            self.inventory = [objects sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
            [self.tableView reloadData];
        }
    }];
}

- (IBAction)addItemOnButtonPress:(id)sender {
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Add new item" message:@"Do you want to add item from inventory or create a new item for this list?" preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *createNewItem = [UIAlertAction actionWithTitle:@"Create new item" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self performSegueWithIdentifier:@"createNewItemFromInventorySegue" sender:nil];
    }];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        return;
    }];
    
    [alert addAction:createNewItem];
    [alert addAction:cancel];
    [self presentViewController:alert animated:YES completion:nil];
}

@end
