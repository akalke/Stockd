//
//  ListDetailViewController.h
//  Stockd
//
//  Created by Amaeya Kalke on 11/10/14.
//  Copyright (c) 2014 Amaeya Kalke. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "List.h"

@interface ListDetailViewController : UIViewController
@property NSString *listID;
@property List *list;

@end
