//
//  SOSMessengerImageTableViewCell.m
//  SoSho
//
//  Created by RamiF on 11/7/14.
//  Copyright (c) 2014 SoSho. All rights reserved.
//

#import "SOSMessengerImageTableViewCell.h"

@implementation SOSMessengerImageTableViewCell

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
        self.youLabel = [[UILabel alloc] initWithFrame:myFrame];
        _youLabel.font = [UIFont systemFontOfSize:16.0];
        _youLabel.textColor = [UIColor lightGrayColor];
        _youLabel.textAlignment = NSTextAlignmentLeft;
        _youLabel.text = @"YOU";
        [self.contentView addSubview:_youLabel];
        
        self.pictureImage = [[UIImageView alloc] initWithFrame:CGRectMake(60, 0, 220, 220)];
        _pictureImage.frame = CGRectMake(60, 0, 220, 220);
        _pictureImage.contentMode = UIViewContentModeScaleAspectFit;
        
        [self.contentView addSubview:_pictureImage];
    }
    return self;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
