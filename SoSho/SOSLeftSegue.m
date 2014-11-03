//
//  SOSLeftSegue.m
//  SoSho
//
//  Created by Mikko Malmari on 2.11.2014.
//  Copyright (c) 2014 SoSho. All rights reserved.
//

#import "SOSLeftSegue.h"

@implementation SOSLeftSegue


- (void)perform{
    
    UIViewController *sourceViewController = (UIViewController*)[self sourceViewController];
    UIViewController *destinationViewController = (UIViewController*)[self destinationViewController];
    
    CATransition* transition = [CATransition animation];
    transition.duration = 0.4;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault];
    transition.type = kCATransitionPush;
    transition.subtype = kCATransitionFromLeft;
    
    [sourceViewController.navigationController.view.layer addAnimation:transition forKey:kCATransition];
    [sourceViewController.navigationController pushViewController:destinationViewController animated:YES];
}



@end
