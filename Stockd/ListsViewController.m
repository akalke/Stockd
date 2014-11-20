//
//  HomeViewController.m
//  Stockd
//
//  Created by Adam Duflo on 11/5/14.
//  Copyright (c) 2014 Amaeya Kalke. All rights reserved.
//

#define peachBackground [UIColor colorWithRed:255.0/255.0 green:223.0/255.0 blue:181.0/255.0 alpha:1.0]
#define navBarColor [UIColor colorWithRed:231.0/255.0 green:95.0/255.0 blue:73.0/255.0 alpha:1.0]
#define turqouise [UIColor colorWithRed:0.0/255.0 green:191.0/255.0 blue:255.0/255.0 alpha:0.80]

#import "ListsViewController.h"
#import "ListDetailViewController.h"
#import "List.h"
#import "Sharing.h"

@interface ListsViewController () <UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate>
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UITextField *listName;
@property List *list;
@property NSArray *lists;
@end

@implementation ListsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setNavBarDisplay];
    [self setTapGesture];
    
    self.listName.font = [UIFont fontWithName:@"Avenir" size:15.0];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self getLists: [PFUser currentUser]];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([segue.identifier isEqualToString:@"listDetailsSegue"]){
        ListDetailViewController *listDetailVC = segue.destinationViewController;
        listDetailVC.listID = [[self.lists objectAtIndex:self.tableView.indexPathForSelectedRow.row] sourceListID];
        List *list = [self.lists objectAtIndex:self.tableView.indexPathForSelectedRow.row];
        listDetailVC.list = list;
    }
}

#pragma mark - GestureRecognizer Methods

// Method that determines tapGesture should receive a touch
// if touch is anywhere but a tableviewcell to dismiss keyboard
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([touch.view class] == self.tableView.class) {
        return NO;
    }
    
    return YES;
}

#pragma mark - TableView Methods

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.lists.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    List *list = [self.lists objectAtIndex:indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MyListsCell" forIndexPath: indexPath];
    cell.textLabel.text = list.name;

    if (list.isQuickList == YES) {
        cell.detailTextLabel.text = @"";
    }
    
    if(list.isShared == NO && list.isQuickList == NO) {
        cell.detailTextLabel.text = @"Not shared";
    }
    else if (list.isShared == YES && list.isQuickList == NO){
        NSPredicate *predicate = [NSPredicate predicateWithFormat: @"listID = %@", list.sourceListID];
        PFQuery *query = [PFQuery queryWithClassName:[Sharing parseClassName] predicate:predicate];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            for(Sharing *share in objects){
                NSLog(@"%@, %@, %@", share.ownerUsername, [[PFUser currentUser] username], share.sharedUsername);
                if([share.ownerUsername isEqualToString:[[PFUser currentUser] username]]){
                    cell.detailTextLabel.text = [NSString stringWithFormat:@"Sharing with %@", share.sharedUsername];
                }
                else{
                    cell.detailTextLabel.text = [NSString stringWithFormat:@"Sharing with %@", share.ownerUsername];
                }
            }
        }];
    }

    return cell;
}

// Removes editing for QuickList
-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    List *list = [self.lists objectAtIndex:indexPath.row];
    if([list.name isEqualToString:@"Quick List"]){
        return UITableViewCellEditingStyleNone;
    }
    else{
        return UITableViewCellEditingStyleDelete;
    }
}

// Need method for editActionsForRowAtIndexPath to work (it doesn't need anything declared inside)
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    
}

// Creates custom cell actions
- (NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    List *list =[self.lists objectAtIndex:indexPath.row];


    UITableViewRowAction *delete = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"Delete" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
        [self deleteActionForList:list];

    }];
    
    UITableViewRowAction *edit = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"Edit" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
        [self editActionForList:list];
    }];

    UITableViewRowAction *share = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"Share" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
        [self shareActionForList:list];
    }];

    UITableViewRowAction *unshare = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"Unshare" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
        [self unshareActionForList:list];
    }];

    edit.backgroundColor = [UIColor orangeColor];
    unshare.backgroundColor = [UIColor darkGrayColor];
    share.backgroundColor = [UIColor lightGrayColor];

    if(list.isShared == NO){
        return @[delete, edit, share];
    }
    else if(list.isShared == YES && list.objectId != list.sourceListID){
        return @[edit, unshare];
    }
    else{
        return @[delete, edit, unshare];
    }
}

#pragma mark - Helper Methods

-(void)setNavBarDisplay{
    // Setting navigation bar properties
    self.navigationController.navigationBar.barTintColor = navBarColor;
    self.navigationController.navigationBar.tintColor = [UIColor blackColor];
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.titleTextAttributes = @{NSFontAttributeName:[UIFont fontWithName:@"Avenir" size:18.0f],NSForegroundColorAttributeName:[UIColor blackColor]};
    [self.navigationController.navigationBar setBarStyle:UIBarStyleDefault];
}

- (void)setTapGesture {
    // Setting up tap gesture to resign keyboard
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(resignKeyboardOnTap:)];
    [tapGesture setNumberOfTapsRequired:1];
    [tapGesture setNumberOfTouchesRequired:1];
    [tapGesture setCancelsTouchesInView:NO];
    [self.view addGestureRecognizer:tapGesture];
}

// Method used by tapGesture to resign keyboard
- (void)resignKeyboardOnTap:(UITapGestureRecognizer *)sender {
    [self.listName resignFirstResponder];
}

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
            
            NSPredicate *findListsForUser = [NSPredicate predicateWithFormat:@"(userID = %@) AND (isQuickList = false) AND (isActive = true)", currentUser.objectId];
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

-(void)deleteActionForList: (List *)list{
    if(list.isShared == YES){
        //Delete shared lists if deleting source list
        NSPredicate *sharedLists = [NSPredicate predicateWithFormat:@"sourceListID = %@", list.sourceListID];
        PFQuery *sharedQuery = [PFQuery queryWithClassName:[List parseClassName] predicate:sharedLists];
        [sharedQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if(error){
                NSLog(@"%@", error);
            }
            else{
                for(List *listObj in objects){
                    if(list.objectId != listObj.objectId){
                        [listObj setObject:[NSNumber numberWithBool:NO] forKey:@"isActive"];
                        [listObj saveInBackground];
                    }
                }
            }
        }];
    }

    //Delete selected list
    [list setObject:[NSNumber numberWithBool:NO] forKey:@"isActive"];
    [list saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        [self getLists:[PFUser currentUser]];
        [self.tableView setEditing:NO];
    }];
}

-(void)shareActionForList: (List *)list{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Share this list?" message:@"Enter the email address of the person you would like to share this list with." preferredStyle:UIAlertControllerStyleAlert];

    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"Enter email address";
        textField.keyboardType = UIKeyboardTypeEmailAddress;
    }];
    UIAlertAction *share = [UIAlertAction actionWithTitle:@"Share!" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        List *shareList = [[List alloc] init];
        [shareList shareThisList:list withThisUser: [alert.textFields[0] valueForKey:@"text"]];
        [list setObject:[NSNumber numberWithBool:YES] forKey:@"isShared"];
        [list saveInBackground];
        Sharing *sharing = [[Sharing alloc] init];
        [sharing shareThisListWithID:list createdByUser:[PFUser currentUser] andSharedToUser:[alert.textFields[0] valueForKey:@"text"]];
        [self getLists:[PFUser currentUser]];
    }];

    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        return;
    }];


    [alert addAction:share];
    [alert addAction:cancel];
    [self presentViewController:alert animated:YES completion:nil];

    [self.tableView setEditing:NO];
}

-(void)editActionForList:(List *)list{
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
}

-(void)unshareActionForList: (List *)list{
    if(list.isShared == YES) {
        //Unshare from person that shared list
        NSPredicate *sharedLists = [NSPredicate predicateWithFormat:@"sourceListID = %@", list.sourceListID];
        PFQuery *query = [PFQuery queryWithClassName:[List parseClassName] predicate:sharedLists];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            for(List *listObject in objects){
                NSLog(@"%@", list);
                if(listObject.objectId == listObject.sourceListID){
                    [listObject setObject:[NSNumber numberWithBool:NO] forKey:@"isShared"];
                    [listObject saveInBackground];
                    [self getLists:[PFUser currentUser]];
                }
                else{
                    [listObject deleteInBackground];
                    [self getLists:[PFUser currentUser]];
                }
            }
        }];
    }
    else{
        return;
    }
}

#pragma mark - IBActions

- (IBAction)createListOnButtonPress:(id)sender {
    
    if([self.listName.text isEqualToString:@""]){
        return;
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
