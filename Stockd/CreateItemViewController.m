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
    Item *item = [[Item alloc] init];
    [item createNewItem:@"chicken" :@"perdue" :nil :@"my list"];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
