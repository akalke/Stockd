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
    self.tableView.backgroundColor = [UIColor lightGrayColor];
    [self getLists: [PFUser currentUser]];
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    PFUser *user = [PFUser currentUser];
    [self getLists: user];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.lists.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    List *list = [self.lists objectAtIndex:indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MyListsCell" forIndexPath: indexPath];
    cell.textLabel.text = list.name;
    cell.imageView.image = [UIImage imageNamed:@"stockd_annotation"];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@",list.createdAt];

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

- (NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    List *list =[self.lists objectAtIndex:indexPath.row];


    UITableViewRowAction *delete = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"Delete" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
        // need completion block from deleteInBackgroundWithBlock method
        [list deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            [self getLists:[PFUser currentUser]];
        }];

        [self.tableView setEditing:NO];
    }];

    UITableViewRowAction *share = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"Share It" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {

        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Share this list?" message:@"Enter the email address of the person you would like to share this list with" preferredStyle:UIAlertControllerStyleAlert];
        [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
            textField = alert.textFields[0];
        }];
        UIAlertAction *share = [UIAlertAction actionWithTitle:@"Share!" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            NSLog(@"share");
            List *shareList = [[List alloc] init];
            NSLog(@"%@", alert.textFields[0]);
            [shareList shareThisList:list withThisUser: @"test@gmail.com"];
        }];

        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            return;
        }];

        [alert addAction:share];
        [alert addAction:cancel];

        [self presentViewController:alert animated:YES completion:nil];

        [self.tableView setEditing:NO];
    }];
    share.backgroundColor = [UIColor lightGrayColor];

    return @[delete, share];
}


- (IBAction)createListOnButtonPress:(id)sender {
    if([self.listName.text isEqualToString:@""]){
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"YO!" message:@"check yourself before you wreck yourself. Need a title buddy" preferredStyle:UIAlertControllerStyleActionSheet];
        UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            return;
        }];
        [alert addAction:ok];
        [self presentViewController:alert animated:YES completion:nil];
    }
    else{
        List *list = [[List alloc]init];
        PFUser *user = [PFUser currentUser];
        [list createNewList:user :self.listName.text];
        self.listName.text = @"";
        [self getLists:user];
    }
}


-(void) getLists: (PFUser *)currentUser{
    NSPredicate *findListsForUser = [NSPredicate predicateWithFormat:@"userID = %@", currentUser.objectId];
    PFQuery *listQuery = [PFQuery queryWithClassName:[List parseClassName] predicate: findListsForUser];
    //listQuery.cachePolicy = kPFCachePolicyCacheElseNetwork;
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

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([segue.identifier isEqualToString:@"listDetailsSegue"]){
        ListDetailViewController *listDetailVC = segue.destinationViewController;
        listDetailVC.listID = [[self.lists objectAtIndex:self.tableView.indexPathForSelectedRow.row] sourceListID];
        List *list = [self.lists objectAtIndex:self.tableView.indexPathForSelectedRow.row];
        listDetailVC.list = list;
    }
}

@end
