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

@interface InventoryViewController () <UITableViewDelegate, UITableViewDataSource>
@property NSArray *inventory;
@property Item *items;
@property NSString *userID;
@property (strong, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation InventoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    PFUser *currentUser = [PFUser currentUser];
    [self getInventory:currentUser];
    // Do any additional setup after loading the view.
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
    NSPredicate *findItemsForUser = [NSPredicate predicateWithFormat:@"userID = %@", currentUser.objectId];
    PFQuery *itemQuery = [PFQuery queryWithClassName:[Item parseClassName] predicate: findItemsForUser];
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


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
