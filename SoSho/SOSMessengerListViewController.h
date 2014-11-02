//
//  SOSTempViewController.h
//  SoSho
//
//  Created by Artur Minasjan on 24/08/14.
//  Copyright (c) 2014 SoSho. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SOSItem.h"

#import "GAI.h"
#import "GAIFields.h"
#import "GAIDictionaryBuilder.h"


@interface SOSMessengerListViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UISearchDisplayDelegate>
@property (strong, nonatomic) IBOutlet UITableView *friendsTableView;
@property (weak, nonatomic) IBOutlet UIImageView *image;
@property (weak, nonatomic) NSString *imageUrl;
@end
