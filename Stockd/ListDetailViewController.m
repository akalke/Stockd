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
#import "List.h"

@interface ListDetailViewController () <UITableViewDataSource, UITableViewDelegate>
@property NSArray *items;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@end

@implementation ListDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.items.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ListDetailCell" forIndexPath: indexPath];
    return cell;
}

-(void) getItems: (List *)list{
    NSPredicate *findItemsForList = [NSPredicate predicateWithFormat:@"listID = %@", list.objectId];

    NSLog(@"running query");
    PFQuery *itemQuery = [PFQuery queryWithClassName:[Item parseClassName] predicate: findItemsForList];
    NSLog(@"query complete");

    [itemQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if(error) {
            NSLog(@"%@", error);
        }
        else{
            self.items = objects;
            [self.tableView reloadData];
        }
    }];
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
