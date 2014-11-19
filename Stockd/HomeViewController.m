//
//  HomeViewController.m
//  Stockd
//
//  Created by Adam Duflo on 11/5/14.
//  Copyright (c) 2014 Amaeya Kalke. All rights reserved.
//

#define stockdBlueColor [UIColor colorWithRed:32.0/255.0 green:59.0/255.0 blue:115.0/255.0 alpha:1.0]
#define stockdOrangeColor [UIColor colorWithRed:217.0/255.0 green:126.0/255.0 blue:0.0/255.0 alpha:1.0]
#define peachBackground [UIColor colorWithRed:255.0/255.0 green:223.0/255.0 blue:181.0/255.0 alpha:1.0]
#define navBarColor [UIColor colorWithRed:231.0/255.0 green:95.0/255.0 blue:73.0/255.0 alpha:1.0]

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
    tabBar.barTintColor = navBarColor;
//    tabBar.tintColor = [UIColor colorWithRed:0.0/255.0 green:191.0/255.0 blue:255.0/255.0 alpha:0.80];
    tabBar.tintColor = peachBackground;
    tabBar.translucent = NO;
    
    [[UITabBarItem appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]} forState:UIControlStateNormal];
    [[UITabBarItem appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]} forState:UIControlStateSelected];
    
    UITabBarItem *item0 = [tabBar.items objectAtIndex:0];
    item0.image = [[UIImage imageNamed:@"stockd_tabbaricon-lists"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    item0.selectedImage = [UIImage imageNamed:@"stockd_tabbaricon-lists"];
    
    UITabBarItem *item1 = [tabBar.items objectAtIndex:1];
    item1.image = [[UIImage imageNamed:@"stockd_tabbaricon-mypantry"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    item1.selectedImage = [UIImage imageNamed:@"stockd_tabbaricon-mypantry"];
    
    UITabBarItem *item2 = [tabBar.items objectAtIndex:2];
    item2.image = [[UIImage imageNamed:@"stockd_tabbaricon-storesnearby"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    item2.selectedImage = [UIImage imageNamed:@"stockd_tabbaricon-storesnearby"];
    
    UITabBarItem *item3 = [tabBar.items objectAtIndex:3];
    item3.image = [[UIImage imageNamed:@"stockd_tabbaricon-settings"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    item3.selectedImage = [UIImage imageNamed:@"stockd_tabbaricon-settings"];
    
    self.listName.font = [UIFont fontWithName:@"Avenir" size:15.0];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self getLists: [PFUser currentUser]];
    self.navigationController.navigationBar.barTintColor = navBarColor;
    self.navigationController.navigationBar.tintColor = stockdBlueColor;
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.titleTextAttributes = @{NSFontAttributeName:[UIFont fontWithName:@"Avenir" size:18.0f],NSForegroundColorAttributeName:[UIColor blackColor]};
    [self.navigationController.navigationBar setBarStyle:UIBarStyleDefault];
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
    //cell.imageView.image = [UIImage imageNamed:@"stockd_icon-400p"];

    if (list.isQuickList == YES) {
        cell.detailTextLabel.text = @"";
    }
    
    if(list.isShared == NO && list.isQuickList == NO) {
        cell.detailTextLabel.text = @"Not shared";
    }
    else if (list.isShared == YES && list.isQuickList == NO){

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
    
    UITableViewRowAction *edit = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"Edit" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Edit List" message:nil preferredStyle:UIAlertControllerStyleAlert];
        
        [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
            textField.placeholder = @"List name";
            textField.text = list.name;
        }];
        
        UIAlertAction *save = [UIAlertAction actionWithTitle:@"Save" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [list setObject:[alert.textFields[0] valueForKey:@"text"] forKey:@"name"];
            [list saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                [self getLists:[PFUser currentUser]];
            }];
        }];
        
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            return;
        }];
        
        [alert addAction:save];
        [alert addAction:cancel];
        [self presentViewController:alert animated:YES completion:nil];
        
        [self.tableView setEditing:NO];
    }];

    UITableViewRowAction *share = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"Share It" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {

        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Share this list?" message:@"Enter the email address of the person you would like to share this list with" preferredStyle:UIAlertControllerStyleAlert];

        [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
            textField.placeholder = @"Enter email address";
            textField.keyboardType = UIKeyboardTypeEmailAddress;
        }];
        UIAlertAction *share = [UIAlertAction actionWithTitle:@"Share!" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
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
    
    edit.backgroundColor = stockdBlueColor;
    unshare.backgroundColor = [UIColor darkGrayColor];
    share.backgroundColor = [UIColor lightGrayColor];

    if(list.isShared == NO){
        return @[delete, edit, share];
    }
    else{
        return @[delete, edit, unshare];
    }
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
