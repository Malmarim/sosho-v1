//
//  SOSVoteViewController.h
//  SoSho
//
//  Created by Mikko Malmari on 11.7.2014.
//  Copyright (c) 2014 SoSho. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SOSItem.h"

@interface SOSVoteViewController : UIViewController

@property (strong, nonatomic) NSNumber *pid;
@property (strong, nonatomic) NSString *fbId;
@property (strong, nonatomic) NSDictionary *item;

@end
