//
//  SOSMessengerMineTableViewCell.m
//  SoSho
//
//  Created by Artur Minasjan on 14/09/14.
//  Copyright (c) 2014 SoSho. All rights reserved.
//

#import "SOSMessengerMineTableViewCell.h"

@implementation SOSMessengerMineTableViewCell


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        [self setBackgroundColor:[UIColor colorWithRed:245.0f/255.0f
                                                 green:240.0f/255.0f
                                                  blue:245.0f/255.0f
                                                 alpha:1.0f]];
        
        CGRect myFrame = CGRectMake(10.0, 0.0, 42.0, 21.0);
        UILabel *youLabel = [[UILabel alloc] initWithFrame:myFrame];
        youLabel.font = [UIFont systemFontOfSize:16.0];
        youLabel.textColor = [UIColor lightGrayColor];
        youLabel.textAlignment = NSTextAlignmentLeft;
        youLabel.text = @"YOU";
        [self.contentView addSubview:youLabel];
        
        CGRect messageFrame = CGRectMake(50, 0, 250, 30);
        self.mineMessageLabel = [[UILabel alloc] initWithFrame:messageFrame];
        _mineMessageLabel.font = [UIFont systemFontOfSize:14.0];
        _mineMessageLabel.textColor = [UIColor blackColor];
        [_mineMessageLabel setBackgroundColor:[UIColor clearColor]];
        
        _mineMessageLabel.textAlignment = NSTextAlignmentLeft;
        [_mineMessageLabel setBackgroundColor:[UIColor whiteColor]];
        
        _mineMessageLabel.layer.cornerRadius = 5;
        _mineMessageLabel.clipsToBounds = YES;
        _mineMessageLabel.textAlignment = NSTextAlignmentCenter;
        _mineMessageLabel.numberOfLines = 0;
        
        _mineMessageLabel.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        
        [self.contentView addSubview:_mineMessageLabel];
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
