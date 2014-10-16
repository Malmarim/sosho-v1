//
//  SOSOptionsViewController.h
//  SoSho
//
//  Created by Mikko Malmari on 5.9.2014.
//  Copyright (c) 2014 SoSho. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "GAITrackedViewController.h"

@interface SOSOptionsViewController : GAITrackedViewController <UIScrollViewDelegate>

@property (nonatomic, strong) IBOutlet UIScrollView *scrollView;

@end
