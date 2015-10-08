//
//  ViewController.m
//  InfiniteViewUseCollectionV
//
//  Created by April Lee on 2015/4/30.
//  Copyright (c) 2015年 april. All rights reserved.
//

#import "ViewController.h"
#import "ColorCollectionCell.h"


static NSString *const infiniteViewCellIdentifier = @"infiniteViewCellIdentifier";

@interface ViewController () <UICollectionViewDataSource, UICollectionViewDelegate , UICollectionViewDelegateFlowLayout,UIScrollViewDelegate>

@property (nonatomic) NSArray *ColorItems;
@property (nonatomic) NSArray *ColorNameItems;
@property (strong, nonatomic) NSTimer *autoScrollTimer;

@property (weak, nonatomic) IBOutlet UICollectionView *infiniteView;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;

@end

@implementation ViewController

- (void)viewDidLoad {

    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self setupColorItems];
    [self setInfiniteViewAttributeWithCustomCell];
    [self setPageControlAttribute];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // scroll to the 2nd page, which is showing the first item.
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // scroll to the first page, note that this call will trigger scrollViewDidScroll: once and only once
        [self.infiniteView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:1 inSection:0] atScrollPosition:UICollectionViewScrollPositionLeft animated:NO];
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - setupInfiniteData

- (void)setupColorItems
{
    NSDictionary *grayColor = @{@"Name" : @"grayColor", @"Color" : [UIColor grayColor]};
    NSDictionary *purpleColor = @{@"Name" : @"purpleColor",@"Color" : [UIColor purpleColor]};
    NSDictionary *brownColor = @{@"Name" : @"brownColor" , @"Color" : [UIColor brownColor]};
    
    NSArray *original = @[grayColor, purpleColor, brownColor];
    
    self.ColorItems = [self setupInfiniteDataWithOriginalData:original];
}

- (NSArray *)setupInfiniteDataWithOriginalData:(NSArray *)originalData
{
    id firstItem = originalData[0];
    id lastItem = [originalData lastObject];
    
    NSMutableArray *workingArray = [originalData mutableCopy];
    
    [workingArray insertObject:lastItem atIndex:0];
    [workingArray addObject:firstItem];
    
    return workingArray;
}

#pragma mark - setInfiniteViews

- (void)setInfiniteViewAttributeWithCustomCell
{
    [self.infiniteView registerClass:[ColorCollectionCell class] forCellWithReuseIdentifier:infiniteViewCellIdentifier];
    self.infiniteView.dataSource = self;
    self.infiniteView.delegate =self;
}

#pragma mark - pageControl

- (void)setPageControlAttribute
{
    self.pageControl.numberOfPages = self.ColorItems.count - 2;
}

- (IBAction)pageControlChanged:(id)sender
{
    CGFloat pageWidth = self.infiniteView.frame.size.width;
    CGPoint scrollTo = CGPointMake(pageWidth * (self.pageControl.currentPage + 1), 0);
    
    [self.infiniteView setContentOffset:scrollTo animated:YES];
}

#pragma mark - AutoScroll

- (IBAction)RightScrollButtonDidSelected:(id)sender
{
    [self startAutoScroll];
}

- (void)startAutoScroll
{
    if ([self.ColorItems count] < 1) {
        return;
    }
  
    [self.autoScrollTimer invalidate];
    self.autoScrollTimer = nil;
    
    self.autoScrollTimer = [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(autoScroll) userInfo:nil repeats:YES];
}

- (void)autoScroll
{
    CGFloat offset = self.infiniteView.contentOffset.x + self.infiniteView.frame.size.width;
    
    [self.infiniteView setContentOffset:CGPointMake(offset, 0) animated:YES];
}

#pragma mark - collectionViewFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return self.infiniteView.bounds.size;
}

#pragma mark - collectionViewDataSource and Delegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.ColorItems.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return [self createCustomCollectionCell:collectionView ForIndexPath:indexPath];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"Item No:%i",(int)indexPath.row);
}

#pragma mark - CollectionView Cell

- (ColorCollectionCell *)createCustomCollectionCell:(UICollectionView *)collectionView ForIndexPath:(NSIndexPath *)indexPath
{
    ColorCollectionCell *cell = (ColorCollectionCell *)[self.infiniteView dequeueReusableCellWithReuseIdentifier:infiniteViewCellIdentifier forIndexPath:indexPath];

    NSDictionary *currentItem = [self.ColorItems objectAtIndex:indexPath.row];
    
    [cell createCellComponents];
    cell.TitleLabel.text = [currentItem objectForKey:@"Name"];
    cell.ColorView.backgroundColor = [currentItem objectForKey:@"Color"];
    
    return cell;
}

#pragma mark - ScrollViewDelegate
//reference for someone, I forget...
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    static CGFloat lastContentOffsetX = FLT_MIN;

    //Ignore the first time scroll, because it is caused by the call scrollToItemAtIndexPath: in ViewDidAppear
    if (FLT_MIN == lastContentOffsetX) {
        lastContentOffsetX = scrollView.contentOffset.x;
        return;
    }
    
    CGFloat currentOffsetX = scrollView.contentOffset.x;
    CGFloat currentOffsetY = scrollView.contentOffset.y;
    
    CGFloat pageWidth = scrollView.frame.size.width;
    CGFloat offset = pageWidth * (self.ColorItems.count - 2);
    
    //the first page(showing the last item) is visible and user is still scrolling to the left
    if (currentOffsetX < pageWidth && lastContentOffsetX > currentOffsetX)
    {
        lastContentOffsetX = currentOffsetX + offset;
        scrollView.contentOffset = (CGPoint){lastContentOffsetX, currentOffsetY};
        
    }
    // the last page (showing the first item) is visible and user is still scrolling to the right
    else if (currentOffsetX > offset && lastContentOffsetX < currentOffsetX) {
        
        lastContentOffsetX =  currentOffsetX - offset;
        scrollView.contentOffset = (CGPoint){lastContentOffsetX, currentOffsetY};
        
    } else {
        
        lastContentOffsetX = currentOffsetX;
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self setPageControlCurrentPage:scrollView];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    [self setPageControlCurrentPage:scrollView];
}

- (void)setPageControlCurrentPage:(UIScrollView *)scrollView
{
    CGFloat pageWidth = self.infiniteView.frame.size.width;
    CGFloat contentOffsetX = scrollView.contentOffset.x;
    
    // The first page actually is second page in collection view.
    self.pageControl.currentPage = ((contentOffsetX / pageWidth) - 1);
}

@end
