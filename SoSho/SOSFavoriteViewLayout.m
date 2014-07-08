//
//  SOSFavoriteViewLayout.m
//  SoSho
//
//  Created by Mikko Malmari on 11.6.2014.
//  Copyright (c) 2014 SoSho. All rights reserved.
//

#import "SOSFavoriteViewLayout.h"

@implementation SOSFavoriteViewLayout


- (id) init
{
    self = [super init];
    if(self){
        [self setup];
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if(self){
        [self setup];
    }
    
    return self;
}

- (void)setup
{
    self.itemInsets = UIEdgeInsetsMake(22.0f, 22.0f, 13.0f, 22.0f);
    self.itemSize = CGSizeMake(125.0f, 125.0f);
    self.interItemSpacingY = 12.0f;
    self.numberOfColumns = 2;
}

@end
