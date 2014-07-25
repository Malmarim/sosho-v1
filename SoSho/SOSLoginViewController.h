//
//  SOSLoginViewController.h
//  SoSho
//
//  Created by Mikko Malmari on 16.5.2014.
//  Copyright (c) 2014 SoSho. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FacebookSDK/FacebookSDK.h"
#import "SOSVoteViewController.h"

@interface SOSLoginViewController : UIViewController

- (void) login;
- (void) logout;
- (void) goVote;

@property BOOL vote;
@property NSString *fbId;
@property NSNumber  *pid;

@end
