//
//  CreateListViewController.h
//  Stockd
//
//  Created by Adam Duflo on 11/5/14.
//  Copyright (c) 2014 Amaeya Kalke. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Item.h"

@interface CreateItemViewController : UIViewController
@property BOOL fromInventory;
@property BOOL fromListDetails;
@property BOOL editingFromInventory;
@property BOOL editingFromListDetails;
@property NSString *listID;
@property Item *item;

@end
