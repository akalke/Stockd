//
//  HomeViewController.m
//  Stockd
//
//  Created by Adam Duflo on 11/5/14.
//  Copyright (c) 2014 Amaeya Kalke. All rights reserved.
//

#define stockdBlueColor [UIColor colorWithRed:32.0/255.0 green:59.0/255.0 blue:115.0/255.0 alpha:1.0]
#define stockdOrangeColor [UIColor colorWithRed:217.0/255.0 green:126.0/255.0 blue:0.0/255.0 alpha:1.0]

#import "HomeViewController.h"
#import <Parse/Parse.h>
#import "List.h"
#import "ListDetailViewController.h"

@interface HomeViewController () <UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UITextField *listName;
@property List *list;
@property NSArray *lists;
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
    
    UITabBar *tabBar = self.tabBarController.tabBar;
    tabBar.barTintColor = stockdBlueColor;
    tabBar.tintColor = stockdOrangeColor;
    tabBar.translucent = NO;
    [[UITabBarItem appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName:stockdOrangeColor} forState:UIControlStateSelected];
    
    self.navigationController.navigationBar.barTintColor = stockdBlueColor;
    self.navigationController.navigationBar.tintColor = stockdOrangeColor;
    self.navigationController.navigationBar.translucent = NO;
    
    [self.navigationController.navigationBar setBarStyle:UIBarStyleBlackTranslucent];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.lists.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    List *list = [self.lists objectAtIndex:indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MyListsCell" forIndexPath: indexPath];
    cell.textLabel.text = list.name;
    cell.imageView.image = [UIImage imageNamed:@"stockd_annotation"];

    if(list.isShared == NO) {
        cell.detailTextLabel.text = @"Not shared";
    }
    else{

        cell.detailTextLabel.text = @"Shared";
    }

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
        [list deleteListWithBlock:^{
            [self getLists:user];
        }];
//        [list deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
//            [self getLists:user];
//        }];
    }
}

- (NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    List *list =[self.lists objectAtIndex:indexPath.row];


    UITableViewRowAction *delete = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"Delete" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
        // need completion block from deleteInBackgroundWithBlock method
        NSString *listIDString = list.objectId;
        [self.deletedListArray addObject:listIDString];
        [list deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            [self getLists:[PFUser currentUser]];
            [self.tableView setEditing:NO];
        }];
    }];

    UITableViewRowAction *share = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"Share It" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {

        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Share this list?" message:@"Enter the email address of the person you would like to share this list with" preferredStyle:UIAlertControllerStyleAlert];

        [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
            textField.placeholder = @"Enter email address";;
        }];
        UIAlertAction *share = [UIAlertAction actionWithTitle:@"Share!" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            NSLog(@"share");
            List *shareList = [[List alloc] init];
            [shareList shareThisList:list withThisUser: [alert.textFields[0] valueForKey:@"text"]];
            list.isShared = YES;
        }];

        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            return;
        }];


        [alert addAction:share];
        [alert addAction:cancel];

        [self presentViewController:alert animated:YES completion:nil];

        [self.tableView setEditing:NO];
    }];

    UITableViewRowAction *unshare = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"Unshare" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
        if(list.objectId != list.sourceListID && list.isShared == YES) {
            [list deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if(error){
                    NSLog(@"ERROR: CANNOT UNSHARE %@", error);
                }
                else{
                    NSLog(@"SUCCESS: List Unshared");
                }
            }];
        }
        else{
            list.isShared = NO;
            [tableView reloadData];
        }
        [self.tableView setEditing:NO];
    }];

    unshare.backgroundColor = [UIColor darkGrayColor];
    share.backgroundColor = [UIColor lightGrayColor];

    if(list.isShared == NO){
        return @[delete, share];
    }
    else{
        return @[delete, unshare];
    }
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
        [list createNewList:user :self.listName.text withBlock:^{
            self.listName.text = @"";
            [self getLists:user];
        }];
    }
}

-(void) getLists: (PFUser *)currentUser{
    NSPredicate *quickListPredicate = [NSPredicate predicateWithFormat:@"(userID = %@) AND (isQuickList = true)", currentUser.objectId];
    PFQuery *quickListQuery = [PFQuery queryWithClassName:[List parseClassName] predicate: quickListPredicate];
    //listQuery.cachePolicy = kPFCachePolicyCacheElseNetwork;
    [quickListQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if(error) {
            NSLog(@"%@", error);
        }
        else{
            NSArray *quickList = objects;
            
            NSPredicate *findListsForUser = [NSPredicate predicateWithFormat:@"(userID = %@) AND (isQuickList = false)", currentUser.objectId];
            PFQuery *listQuery = [PFQuery queryWithClassName:[List parseClassName] predicate: findListsForUser];
            //listQuery.cachePolicy = kPFCachePolicyCacheElseNetwork;
            [listQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                if(error) {
                    NSLog(@"%@", error);
                }
                else{
                    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"createdAt" ascending:NO];
                    NSArray *sortedListsArray = [objects sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
                    self.lists = [quickList arrayByAddingObjectsFromArray:sortedListsArray];
                    [self.tableView reloadData];
                }
            }];
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
