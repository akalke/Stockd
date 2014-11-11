//
//  HomeViewController.m
//  Stockd
//
//  Created by Adam Duflo on 11/5/14.
//  Copyright (c) 2014 Amaeya Kalke. All rights reserved.
//

#import "HomeViewController.h"
#import <Parse/Parse.h>
#import "List.h"
#import "ListDetailViewController.h"

@interface HomeViewController () <UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UITextField *listName;
@property List *list;
@property NSArray *lists;
@property NSString *listID;
@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    PFUser *user = [PFUser currentUser];
    [self getLists: user];
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.lists.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

    List *list = [self.lists objectAtIndex:indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MyListsCell" forIndexPath: indexPath];
    cell.textLabel.text = list.name;
    return cell;
}

- (IBAction)createListOnButtonPress:(id)sender {
    List *list = [[List alloc]init];
    PFUser *user = [PFUser currentUser];
    [list createNewList:user :self.listName.text];
    [self.tableView reloadData];
    self.listName.text = @"";
}


-(void) getLists: (PFUser *)currentUser{
    NSPredicate *findListsForUser = [NSPredicate predicateWithFormat:@"userID = %@", currentUser.objectId];

    NSLog(@"running query");
    PFQuery *listQuery = [PFQuery queryWithClassName:[List parseClassName] predicate: findListsForUser];
    NSLog(@"query complete");

    [listQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if(error) {
            NSLog(@"%@", error);
        }
        else{
            self.lists = objects;
            NSLog(@"%@", objects);
            [self.tableView reloadData];
        }
    }];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    self.listID = [[self.lists objectAtIndex:indexPath.row] objectId];
    [self performSegueWithIdentifier:@"listDetailSegue" sender:self];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([segue.identifier isEqualToString:@"listDetailSegue"]){
        ListDetailViewController *listDetailVC = segue.destinationViewController;
        listDetailVC.listID = self.listID;
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
