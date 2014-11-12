//
//  CreateListViewController.m
//  Stockd
//
//  Created by Adam Duflo on 11/5/14.
//  Copyright (c) 2014 Amaeya Kalke. All rights reserved.
//

#import "CreateItemViewController.h"
#import "Item.h"

@interface CreateItemViewController ()

@end

@implementation CreateItemViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)addItemOnButtonPress:(id)sender {
    Item *item = [[Item alloc] init];
    PFUser *user = [PFUser currentUser];
    [item createNewItem:@"chicken" :@"perdue" :user :@"my list"];
}

- (IBAction)cancelItemCreationOnButtonPress:(id)sender {
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
