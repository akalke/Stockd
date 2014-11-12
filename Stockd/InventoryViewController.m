//
//  InventoryViewController.m
//  Stockd
//
//  Created by Adam Duflo on 11/5/14.
//  Copyright (c) 2014 Amaeya Kalke. All rights reserved.
//

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

@end

@implementation InventoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    PFUser *currentUser = [PFUser currentUser];
    [self getInventory:currentUser];

    if(self.fromListDetail == YES){
        self.fromListDetail = YES;
    }
    else{
        self.fromListDetail = NO;
    }
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    PFUser *currentUser = [PFUser currentUser];
    [self getInventory:currentUser];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"createNewItemFromInventorySegue"]) {
        CreateItemViewController *createItemVC = segue.destinationViewController;
        createItemVC.fromInventory = YES;
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.inventory.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

    Item *item = [self.inventory objectAtIndex:indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MyInventoryCell" forIndexPath: indexPath];
    cell.textLabel.text = item.type;
    return cell;
}

-(void) getInventory: (PFUser *)currentUser{
    NSPredicate *findItemsForUser = [NSPredicate predicateWithFormat:@"(userID = %@) AND (isInInventory = true)", currentUser.objectId];
    PFQuery *itemQuery = [PFQuery queryWithClassName:[Item parseClassName] predicate: findItemsForUser];
    itemQuery.cachePolicy = kPFCachePolicyNetworkElseCache;
    [itemQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if(error) {
            NSLog(@"%@", error);
        }
        else{
            self.inventory = objects;
            [self.tableView reloadData];
        }
    }];
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    PFUser *user = [PFUser currentUser];
    Item *item =[self.inventory objectAtIndex:indexPath.row];

    if(editingStyle == UITableViewCellEditingStyleDelete){
        [item deleteItem];
        [self getInventory:user];
    }
}

-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (cell.accessoryType == UITableViewCellAccessoryNone && self.fromListDetail == YES) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }else{
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
}

-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(self.fromListDetail == YES){
        return UITableViewCellEditingStyleNone;
    }
    else{
        return UITableViewCellEditingStyleDelete;
    }
}

- (IBAction)addItemOnButtonPress:(id)sender {

    if(self.fromListDetail != YES){
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
    else{
        //Add multiple
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Add item?" message:@"Add these items?" preferredStyle:UIAlertControllerStyleActionSheet];

        UIAlertAction *ok = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            return;
        }];

        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            return;
        }];

        [alert addAction:ok];
        [alert addAction:cancel];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

@end
