//
//  ViewController.m
//  InfiniteViewUseCollectionV
//
//  Created by April Lee on 2015/4/30.
//  Copyright (c) 2015年 april. All rights reserved.
//

#import "ViewController.h"
#import "ALInfiniteView.h"


@interface ViewController () <ALInfiniteViewDelegate>

@property (nonatomic) NSArray *colorItems;
@property (weak, nonatomic) IBOutlet UIView *colorView;

@property (strong, nonatomic) ALInfiniteView *infiniteView;

@end

@implementation ViewController

- (void)viewDidLoad {

    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self createInfiniteView];
    [self createColorItems];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - createInfiniteView

- (void)createInfiniteView {
    _infiniteView = [[ALInfiniteView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetMaxX(_colorView.bounds), CGRectGetMaxY(_colorView.bounds)) owner:self];
    _infiniteView.delegate = self;
    [_infiniteView setAutoScrolled:YES];
    
    [_colorView addSubview:_infiniteView];
}


#pragma mark - setupInfiniteData

- (void)createColorItems {
    NSDictionary *grayColor = @{@"Name" : @"grayColor", @"Color" : [UIColor grayColor]};
    NSDictionary *purpleColor = @{@"Name" : @"purpleColor",@"Color" : [UIColor purpleColor]};
    NSDictionary *brownColor = @{@"Name" : @"brownColor" , @"Color" : [UIColor brownColor]};
    
    _colorItems = @[grayColor, purpleColor, brownColor];
    
    [_infiniteView createInfiniteItems:_colorItems];
}

#pragma mark - ALInfiniteViewDelegate

- (void)ALInfiniteViewDidSelectedItem:(ALInfiniteView *)infinteView selectedIndex:(NSInteger)selectedIndex {
    NSDictionary *selectedDic = _colorItems[selectedIndex];
    
    [self showAlertView:selectedDic[@"Name"]];
}

#pragma mark - AlertView Controller

- (void)showAlertView:(NSString *)message {
    UIAlertController *alertView = [UIAlertController alertControllerWithTitle:@"Color name" message:message preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {}];
    
    [alertView addAction:okAction];
    
    [self presentViewController:alertView animated:YES completion:nil];
}

@end
