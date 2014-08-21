//
//  SOSCollectionHeader.h
//  SoSho
//
//  Created by Mikko Malmari on 25.7.2014.
//  Copyright (c) 2014 SoSho. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SOSCollectionHeader : UICollectionReusableView

@property (weak, nonatomic) IBOutlet UIButton *back;
@property (weak, nonatomic) IBOutlet UIImageView *current;
@property (weak, nonatomic) IBOutlet UIButton *forward;

@end
