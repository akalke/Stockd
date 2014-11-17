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
#import "ListDetailViewController.h"
#import "List.h"

@interface HomeViewController () <UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UITextField *listName;
@property List *list;
@property NSArray *lists;
@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UITabBar *tabBar = self.tabBarController.tabBar;
    tabBar.barTintColor = stockdBlueColor;
    tabBar.tintColor = stockdOrangeColor;
    tabBar.translucent = NO;
    
    [[UITabBarItem appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName:stockdOrangeColor} forState:UIControlStateSelected];
    
    self.tableView.backgroundColor = [UIColor lightGrayColor];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self getLists: [PFUser currentUser]];
    
    self.navigationController.navigationBar.barTintColor = stockdBlueColor;
    self.navigationController.navigationBar.tintColor = stockdOrangeColor;
    self.navigationController.navigationBar.translucent = NO;
    [self.navigationController.navigationBar setBarStyle:UIBarStyleBlackTranslucent];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([segue.identifier isEqualToString:@"listDetailsSegue"]){
        ListDetailViewController *listDetailVC = segue.destinationViewController;
        listDetailVC.listID = [[self.lists objectAtIndex:self.tableView.indexPathForSelectedRow.row] sourceListID];
        List *list = [self.lists objectAtIndex:self.tableView.indexPathForSelectedRow.row];
        listDetailVC.list = list;
    }
}

#pragma mark - TableView Methods

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

}

- (NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    List *list =[self.lists objectAtIndex:indexPath.row];


    UITableViewRowAction *delete = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"Delete" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
        [list deleteListWithBlock:^{
            [self getLists:[PFUser currentUser]];
            [self.tableView setEditing:NO];
        }];
    }];

    UITableViewRowAction *share = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"Share It" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {

        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Share this list?" message:@"Enter the email address of the person you would like to share this list with" preferredStyle:UIAlertControllerStyleAlert];
        [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
            // Need to address this warning!
            textField = alert.textFields[0];
        }];
        UIAlertAction *share = [UIAlertAction actionWithTitle:@"Share!" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            List *shareList = [[List alloc] init];
            NSLog(@"Share List Alert: %@", alert.textFields[0]);
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

#pragma mark - Helper Methods

-(void) getLists: (PFUser *)currentUser{
    NSPredicate *quickListPredicate = [NSPredicate predicateWithFormat:@"(userID = %@) AND (isQuickList = true)", currentUser.objectId];
    PFQuery *quickListQuery = [PFQuery queryWithClassName:[List parseClassName] predicate: quickListPredicate];
    //listQuery.cachePolicy = kPFCachePolicyCacheElseNetwork;
    [quickListQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if(error) {
            NSLog(@"Error finding Quick List: %@", error);
        }
        else{
            NSArray *quickList = objects;
            
            NSPredicate *findListsForUser = [NSPredicate predicateWithFormat:@"(userID = %@) AND (isQuickList = false)", currentUser.objectId];
            PFQuery *listQuery = [PFQuery queryWithClassName:[List parseClassName] predicate: findListsForUser];
            //listQuery.cachePolicy = kPFCachePolicyCacheElseNetwork;
            [listQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                if(error) {
                    NSLog(@"Error finding lists: %@", error);
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

#pragma mark - IBActions

- (IBAction)createListOnButtonPress:(id)sender {
    if([self.listName.text isEqualToString:@""]){
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Oops!" message:@"Title missing!" preferredStyle:UIAlertControllerStyleActionSheet];
        UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [self.listName becomeFirstResponder];
        }];
        [alert addAction:ok];
        [self presentViewController:alert animated:YES completion:nil];
    }
    else{
        List *list = [[List alloc]init];
        PFUser *user = [PFUser currentUser];
        [list createNewList:user :self.listName.text withBlock:^{
            self.listName.text = @"";
            [self.listName resignFirstResponder];
            [self getLists:user];
        }];
    }
}

@end
