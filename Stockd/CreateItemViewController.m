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

- (IBAction)addItemOnButtonPress:(id)sender {
    Item *item = [[Item alloc] init];
    PFUser *user = [PFUser currentUser];
    [item createNewItem:@"chicken" :@"perdue" :user :@"my list"];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)cancelItemCreationOnButtonPress:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
