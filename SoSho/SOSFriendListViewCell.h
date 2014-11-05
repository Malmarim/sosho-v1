//
//  SOSFriendListViewCell.h
//  SoSho
//
//  Created by Mikko Malmari on 5.11.2014.
//  Copyright (c) 2014 SoSho. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SOSFriendListViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *picture;
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UILabel *message;

@end
