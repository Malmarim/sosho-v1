//
//  SOSTempViewController.h
//  SoSho
//
//  Created by Artur Minasjan on 24/08/14.
//  Copyright (c) 2014 SoSho. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SOSTempViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@end
