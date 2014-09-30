//
//  SOSMessengerTalkViewController.h
//  SoSho
//
//  Created by Artur Minasjan on 11/09/14.
//  Copyright (c) 2014 SoSho. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SOSFacebookFriend.h"

@interface SOSMessengerTalkViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) IBOutlet UITableView *messengerTableView;
-(id)initWithFriend:(SOSFacebookFriend *)friend;
-(void)setFriend:(SOSFacebookFriend *)friend;

@end
