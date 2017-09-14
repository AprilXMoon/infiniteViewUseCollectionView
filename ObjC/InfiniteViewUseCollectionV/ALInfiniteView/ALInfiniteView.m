//
//  ALInfiniteView.m
//
//
//  Created by April on 2017/7/12.
//  Copyright © 2017年 April. All rights reserved.
//

#import "ALInfiniteView.h"
#import "ALInfiniteViewCell.h"

static NSString *ALInfiniteCellIdentifier = @"ALInfiniteCellIdentifier";

@interface ALInfiniteView () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *ALInfiniteCollectionView;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;
@property (weak, nonatomic) IBOutlet UIView *contentView;

@property (strong, nonatomic) NSArray *originItems;
@property (strong, nonatomic) NSArray *infiniteItems;
@property (strong, nonatomic) NSTimer *autoScrollTimer;

@end

@implementation ALInfiniteView

- (instancetype)initWithFrame:(CGRect)frame owner:(id)owner {
    
    self = [[[NSBundle mainBundle] loadNibNamed:@"ALInfiniteView" owner:owner options:nil] objectAtIndex:0];
    
    if (self) {
        self.frame = frame;
        [self initialView];
    }
    
    return self;
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

#pragma mark - initail

- (void)initialView {
    
    UINib *cellNib = [UINib nibWithNibName:@"ALInfiniteViewCell" bundle:nil];
    [_ALInfiniteCollectionView registerNib:cellNib forCellWithReuseIdentifier:ALInfiniteCellIdentifier];
    _ALInfiniteCollectionView.delegate = self;
    _ALInfiniteCollectionView.dataSource = self;
    
    _ALInfiniteCollectionView.scrollsToTop = false;
}

- (void)createInfiniteItems:(NSArray *)contentItems {
    _originItems = contentItems;
    
    _infiniteItems = [self createInfiniteDataWithOriginialData:_originItems];
    [_ALInfiniteCollectionView reloadData];
    
    _pageControl.numberOfPages = _originItems.count;
}

- (NSArray *)createInfiniteDataWithOriginialData:(NSArray *)orginialData {
    if (orginialData.count <= 1) {
        return orginialData;
    }
    
    id firstItem = [orginialData firstObject];
    id lastItem = [orginialData lastObject];
    
    NSMutableArray *infiniteArray = [orginialData mutableCopy];
    
    [infiniteArray insertObject:lastItem atIndex:0];
    [infiniteArray addObject:firstItem];
    
    return infiniteArray;
}

- (void)scrollToVisibleFirstItem {
    if (_originItems.count <= 1) {
        return;
    }
    
    if (_contentView.isHidden) {
        [_contentView setHidden:NO];
    }
    
    [_ALInfiniteCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:1 inSection:0] atScrollPosition:UICollectionViewScrollPositionLeft animated:NO];
    
    [_pageControl setCurrentPage:0];
}

#pragma mark - pageControl

- (IBAction)pageControlValueChanged:(id)sender {
    CGFloat pageWidth = _ALInfiniteCollectionView.bounds.size.width;
    CGPoint scrollTo = CGPointMake(pageWidth * (_pageControl.currentPage + 1), 0);
    
    [_ALInfiniteCollectionView setContentOffset:scrollTo animated:YES];
}

- (void)setPageControlCurrentPage:(UIScrollView *)scrollView {
    CGFloat pageWidth = _ALInfiniteCollectionView.bounds.size.width;
    CGFloat contentOfffsetX = scrollView.contentOffset.x;
    
    // The first page actually is second page in collection view.
    _pageControl.currentPage = ((contentOfffsetX / pageWidth) - 1);
}

#pragma mark - AutoScroll

- (void)startAutoScroll {
    if (_infiniteItems.count <= 1) {
        return;
    }
    
    if (_autoScrollTimer) {
        [self stopAutoScroll];
    }
    
    [self scrollToVisibleFirstItem];
    
    _isAutoScrolling = YES;
    _autoScrollTimer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(autoScrollAction) userInfo:nil repeats:YES];
}

- (void)stopAutoScroll {
    if(_autoScrollTimer) {
        _isAutoScrolling = NO;
        [_autoScrollTimer invalidate];
        _autoScrollTimer = nil;
    }
}

- (void)autoScrollAction {
    CGFloat offset = _ALInfiniteCollectionView.contentOffset.x + _ALInfiniteCollectionView.bounds.size.width;
    [_ALInfiniteCollectionView setContentOffset:CGPointMake(offset, 0) animated:YES];
}

#pragma mark - CollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return collectionView.bounds.size;
}

#pragma mark - CollectionView DataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _infiniteItems.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    NSDictionary *itemInfo = _infiniteItems[indexPath.row];
    
    ALInfiniteViewCell *infiniteCell = (ALInfiniteViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:ALInfiniteCellIdentifier forIndexPath:indexPath];

    infiniteCell.tag = indexPath.row;
    infiniteCell.NameLabel.text = itemInfo[@"Name"];
    infiniteCell.contentImageView.backgroundColor = itemInfo[@"Color"];
    
    return infiniteCell;
}

#pragma mark -  CollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([_delegate respondsToSelector:@selector(ALInfiniteViewDidSelectedItem:selectedIndex:)]) {
        [_delegate ALInfiniteViewDidSelectedItem:self selectedIndex:indexPath.row];
    }
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    if (_autoScrolled && _autoScrollTimer == nil) {
        [self startAutoScroll];
    } else {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            [self scrollToVisibleFirstItem];
        });
    }
}

#pragma mark - ScrollViewDelegate
//reference for someone, I forget...
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    static CGFloat lastContentOffsetX = FLT_MIN;
    
    //Ignore the first time scroll
    if (FLT_MIN == lastContentOffsetX) {
        lastContentOffsetX = scrollView.contentOffset.x;
    }
    
    CGFloat currentOffsetX = scrollView.contentOffset.x;
    CGFloat currentOffsetY = scrollView.contentOffset.y;
    
    CGFloat pageWidth = scrollView.bounds.size.width;
    CGFloat offset = pageWidth * (_infiniteItems.count - 2);
    
    //the first page(showing the last item) is visible and user is still scrolling to the left
    if (currentOffsetX < pageWidth && lastContentOffsetX > currentOffsetX) {
        lastContentOffsetX = currentOffsetX + offset;
        scrollView.contentOffset = CGPointMake(lastContentOffsetX, currentOffsetY);
        
    } else if (currentOffsetX > offset && lastContentOffsetX < currentOffsetX) {
        // the last page (showing the first item) is visible and user is still scrolling to the right
        lastContentOffsetX = currentOffsetX - offset;
        scrollView.contentOffset = (CGPoint){lastContentOffsetX, currentOffsetY};
    } else {
        lastContentOffsetX = currentOffsetX;
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self setPageControlCurrentPage:scrollView];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    [self setPageControlCurrentPage:scrollView];
}



@end
