//
//  ListDetailViewController.m
//  Stockd
//
//  Created by Amaeya Kalke on 11/10/14.
//  Copyright (c) 2014 Amaeya Kalke. All rights reserved.
//

#import "ListDetailViewController.h"
#import <Parse/Parse.h>
#import "Item.h"
#import "CreateItemViewController.h"
#import "InventoryViewController.h"

@interface ListDetailViewController () <UITableViewDataSource, UITableViewDelegate, UITabBarControllerDelegate>
@property NSArray *items;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *addItemButton;
@end

@implementation ListDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (self.list.isQuickList == YES) {
        self.addItemButton.enabled = NO;
        self.addItemButton.title = @"";
        [self getItemsForQuickList];
    } else {
        [self getItems:self.listID];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.tabBarController.delegate = self;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.tabBarController.delegate = nil;
}

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
    cell.textLabel.text = item.type;
    return cell;
}

-(void)getItemsForQuickList{
    PFUser *user = [PFUser currentUser];
    NSPredicate *findQuickList = [NSPredicate predicateWithFormat:@"(userID = %@) AND (isInQuickList = true)", user.objectId];
    PFQuery *itemQuery = [PFQuery queryWithClassName:[Item parseClassName] predicate: findQuickList];
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

-(void)getItems: (NSString *)listID{
    NSPredicate *findItemsForList = [NSPredicate predicateWithFormat:@"listID = %@", listID];
    PFQuery *itemQuery = [PFQuery queryWithClassName:[Item parseClassName] predicate: findItemsForList];
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

- (IBAction)addItemOnButtonPress:(id)sender {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Add new item" message:@"Do you want to add item from inventory or create a new item for this list?" preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *createNewItem = [UIAlertAction actionWithTitle:@"Create new item" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self performSegueWithIdentifier:@"createNewItemFromListSegue" sender:self];
    }];
    
    UIAlertAction *addFromInventory = [UIAlertAction actionWithTitle:@"Add item from inventory" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self performSegueWithIdentifier:@"addItemFromInventorySegue" sender:self];
    }];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        return;
    }];
    
    [alert addAction:createNewItem];
    [alert addAction:addFromInventory];
    [alert addAction:cancel];
    [self presentViewController:alert animated:YES completion:nil];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([segue.identifier isEqualToString:@"addItemFromInventorySegue"]){
        InventoryViewController *inventoryVC = segue.destinationViewController;
        inventoryVC.fromListDetail = YES;
    } else if ([[segue identifier] isEqualToString:@"createNewItemFromListSegue"]) {
        CreateItemViewController *createItemVC = segue.destinationViewController;
        createItemVC.fromListDetails = YES;
        createItemVC.listID = self.listID;
    }
}

@end
