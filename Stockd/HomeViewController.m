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
    [self getLists: [PFUser currentUser]];
    [self checkForQuickList];
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    PFUser *user = [PFUser currentUser];
    [self getLists: user];
}

-(void)checkForQuickList{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if([[userDefaults stringForKey:@"QUICKLIST_EXISTS"] isEqualToString:@"YES"]){
        NSLog(@"Quick list exists");
        return;
    }
    else{
        NSLog(@"Creating quick list");
        List *list = [[List alloc]init];
        [list createNewQuickList:[PFUser currentUser]];
        [userDefaults setValue:@"YES" forKey:@"QUICKLIST_EXISTS"];
    }
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

-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    List *list = [self.lists objectAtIndex:indexPath.row];
    if([list.name isEqualToString:@"Quick List"]){
        return UITableViewCellEditingStyleNone;
    }
    else{
        return UITableViewCellEditingStyleDelete;
    }
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    PFUser *user = [PFUser currentUser];
    List *list =[self.lists objectAtIndex:indexPath.row];

    if(editingStyle == UITableViewCellEditingStyleDelete){
        [list deleteList];
        [self getLists:user];
    }

}

- (IBAction)createListOnButtonPress:(id)sender {
    List *list = [[List alloc]init];
    PFUser *user = [PFUser currentUser];
    [list createNewList:user :self.listName.text];
    self.listName.text = @"";
    [self getLists:user];
}


-(void) getLists: (PFUser *)currentUser{
    NSPredicate *findListsForUser = [NSPredicate predicateWithFormat:@"userID = %@", currentUser.objectId];
    PFQuery *listQuery = [PFQuery queryWithClassName:[List parseClassName] predicate: findListsForUser];
    listQuery.cachePolicy = kPFCachePolicyCacheElseNetwork;
    [listQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if(error) {
            NSLog(@"%@", error);
        }
        else{
            self.lists = objects;
            [self.tableView reloadData];
        }
    }];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([segue.identifier isEqualToString:@"listDetailsSegue"]){
        ListDetailViewController *listDetailVC = segue.destinationViewController;
        listDetailVC.listID = [[self.lists objectAtIndex:self.tableView.indexPathForSelectedRow.row] objectId];
    }
}

@end
