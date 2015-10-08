//
//  ColorCollectionCell.h
//  InfiniteViewUseCollectionV
//
//  Created by April Lee on 2015/5/21.
//  Copyright (c) 2015年 april. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ColorCollectionCell : UICollectionViewCell

@property (strong, nonatomic) UILabel *TitleLabel;
@property (strong, nonatomic) UIImageView *ColorView;


- (void)createCellComponents;

@end
