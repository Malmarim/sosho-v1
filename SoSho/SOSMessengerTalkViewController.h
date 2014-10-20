//
//  SOSMessengerTalkViewController.h
//  SoSho
//
//  Created by Artur Minasjan on 11/09/14.
//  Copyright (c) 2014 SoSho. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SOSFacebookFriend.h"

@interface SOSMessengerTalkViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>
@property (strong, nonatomic) IBOutlet UITableView *messengerTableView;
@property (strong, nonatomic) IBOutlet UITextField *messageTextField;
@property (strong, nonatomic) IBOutlet UIView *sendingMessageView;
@property (strong, nonatomic) IBOutlet UIButton *addPictureButton;
@property (weak, nonatomic) IBOutlet UIImageView *itemImage;
-(id)initWithFriend:(SOSFacebookFriend *)friend;
-(void)setFriend:(SOSFacebookFriend *)friend;
-(void)setItemImage:(UIImageView *)image;
- (IBAction)sendMessageAction:(id)sender;
- (IBAction)addPictureAction:(id)sender;

@end
