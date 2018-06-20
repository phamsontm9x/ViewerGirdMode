//
//  PageViewController.m
//  ViewerGridMode
//
//  Created by Son Pham on 6/18/18.
//  Copyright © 2018 Son Pham. All rights reserved.
//

#import "PageViewController.h"
#import "ViewerPageViewController.h"



@interface PageViewController () <UIPageViewControllerDataSource, UIPageViewControllerDelegate, ViewerPageViewControllerDelegate>

@property (nonatomic) NSInteger index;
@property (nonatomic) NSInteger totalImage;
@property (nonatomic) ViewerPageViewController *currentVC;

@end


@implementation PageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initData];
    [self setupPageControl];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)initData {
    
    self.dataSource = self;
    self.delegate = self;
    
    _totalImage = 20;
    
    _currentVC = [self viewControllerAtIndex:0];
    
    [self setViewControllers:@[_currentVC] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    
    [self addChildViewController:_currentVC];
}

- (ViewerPageViewController *)viewControllerAtIndex:(NSInteger)index {
    
    ViewerPageViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"ViewerPageViewController"];
    vc.indexPath = index;
    vc.delegate = self;
    
    return vc;
}

- (void)setupPageControl {
    [[UIPageControl appearance] setPageIndicatorTintColor:[UIColor grayColor]];
    [[UIPageControl appearance] setCurrentPageIndicatorTintColor:[UIColor whiteColor]];
    [[UIPageControl appearance] setBackgroundColor:[UIColor darkGrayColor]];
}


#pragma mark - PageViewControllerDataSource

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    
    NSInteger index = [(ViewerPageViewController *)viewController indexPath];
    _currentVC.interactiveTransitionPresent.enableGesture = NO;
    if (index > 0) {
        return [self viewControllerAtIndex:index - 1];
    }
    
    return nil;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    
    NSInteger index = [(ViewerPageViewController *)viewController indexPath];
    _currentVC.interactiveTransitionPresent.enableGesture = NO;
    if (index < _totalImage -1) {
        return [self viewControllerAtIndex:index+1];
    }
    
    return nil;
}

- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController {
    return _totalImage;
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController {
    
    return 0;
}


#pragma mark - ViewerPageViewControllerDelegate

- (void)viewerPageViewController:(ViewerPageViewController *)vc clv:(ViewerCollectionView *)clv jumpToViewControllerAtIndex:(NSInteger)index {
    ViewerPageViewController *currentPage = [self viewControllerAtIndex:index];

    [self setViewControllers:@[currentPage] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:^(BOOL finished) {
        if (finished) {
            [clv dismissViewControllerAnimated:YES completion:nil];
        }
    }];
    [clv dismissViewControllerAnimated:YES completion:nil];
}



- (void)pageViewController:(UIPageViewController *)pageViewController willTransitionToViewControllers:(NSArray<UIViewController *> *)pendingViewControllers {
    _currentVC = (ViewerPageViewController *) pendingViewControllers.firstObject;
}

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray<UIViewController *> *)previousViewControllers transitionCompleted:(BOOL)completed {
    if (!completed) {
        _currentVC = (ViewerPageViewController *) previousViewControllers.firstObject;
    }
    _currentVC.interactiveTransitionPresent.enableGesture = YES;
}



@end
