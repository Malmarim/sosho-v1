//
//  SOSMessengerFriendTableViewCell.m
//  SoSho
//
//  Created by Artur Minasjan on 14/09/14.
//  Copyright (c) 2014 SoSho. All rights reserved.
//

#import "SOSMessengerFriendTableViewCell.h"

@implementation SOSMessengerFriendTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        [self setBackgroundColor:[UIColor colorWithRed:245.0f/255.0f
                                                 green:240.0f/255.0f
                                                  blue:245.0f/255.0f
                                                 alpha:1.0f]];
        
        CGRect messageFrame = CGRectMake(50, 0, 250, 30);
        self.mineMessageLabel = [[UILabel alloc] initWithFrame:messageFrame];
        _mineMessageLabel.font = [UIFont systemFontOfSize:14.0];
        _mineMessageLabel.textColor = [UIColor blackColor];
        
        _mineMessageLabel.textAlignment = NSTextAlignmentLeft;
        [_mineMessageLabel setBackgroundColor:[UIColor purpleColor]];
        
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
