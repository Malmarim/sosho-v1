//
//  SOSDetailsViewController.h
//  SoSho
//
//  Created by Mikko Malmari on 25.7.2014.
//  Copyright (c) 2014 SoSho. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "GAI.h"
#import "GAIDictionaryBuilder.h"

@interface SOSDetailsViewController : GAITrackedViewController

@property NSManagedObject *item;
@property NSNumber *pid;

@end
