//
//  SOSFavoritezViewController.h
//  SoSho
//
//  Created by Mikko Malmari on 10.6.2014.
//  Copyright (c) 2014 SoSho. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GAITrackedViewController.h"

@interface SOSFavoriteViewController : GAITrackedViewController

-(void) loadItem;

@property NSDictionary *favorite;

@end
