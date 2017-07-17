//
//  ALInfiniteView.h
//  
//
//  Created by April on 2017/7/12.
//  Copyright © 2017年 April. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ALInfiniteViewDelegate;

@interface ALInfiniteView : UIView

@property (weak, nonatomic) id <ALInfiniteViewDelegate> delegate;
@property (nonatomic, getter = isAutoScroll) BOOL autoScrolled;
@property (nonatomic, readonly) BOOL hasBannerData;
@property (nonatomic, readonly) BOOL isAutoScrolling;

- (instancetype)initWithFrame:(CGRect)frame owner:(id)owner;

- (void)createInfiniteItems:(NSArray *)contentItems;

- (void)scrollToVisibleFirstItem;
- (void)startAutoScroll;
- (void)stopAutoScroll;

@end

@protocol ALInfiniteViewDelegate <NSObject>

- (void)ALInfiniteViewDidSelectedItem:(ALInfiniteView *)infinteView selectedIndex:(NSInteger)selectedIndex;

@end
