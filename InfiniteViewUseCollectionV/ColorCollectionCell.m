//
//  ColorCollectionCell.m
//  InfiniteViewUseCollectionV
//
//  Created by April Lee on 2015/5/21.
//  Copyright (c) 2015年 april. All rights reserved.
//

#import "ColorCollectionCell.h"

@implementation ColorCollectionCell


- (void)createCellComponents
{
    CGFloat viewY = self.bounds.size.height - (self.bounds.size.height / 3);
    
    UIView *textView = [[UIView alloc] initWithFrame:CGRectMake(0, viewY, self.bounds.size.width, (self.bounds.size.height / 3))];
    textView.backgroundColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.7];
    
    self.TitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, (textView.bounds.size.height / 3), self.bounds.size.width, 30)];
    self.TitleLabel.tag = 4;
    self.TitleLabel.textAlignment = NSTextAlignmentCenter;

    self.ColorView = [[UIImageView alloc] initWithFrame:self.bounds];
    self.ColorView.tag = 3;
    
    [self addSubview:self.ColorView];
    
    [textView addSubview:self.TitleLabel];
    [self addSubview:textView];
}

@end
