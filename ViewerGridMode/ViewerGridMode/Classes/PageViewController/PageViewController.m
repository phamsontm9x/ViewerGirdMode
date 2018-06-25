//
//  PageViewController.m
//  ViewerGridMode
//
//  Created by Son Pham on 6/18/18.
//  Copyright © 2018 Son Pham. All rights reserved.
//

#import "PageViewController.h"
#import "ViewerPageViewController.h"
#import "ViewerInteractiveTransitioning.h"



@interface PageViewController () <UIPageViewControllerDataSource, UIPageViewControllerDelegate, ViewerPageViewControllerDelegate, ViewerInteractiveTransitioningDelegate>


@property (nonatomic) NSInteger totalImage;
@property (nonatomic) BOOL enableGesture;

@end


@implementation PageViewController

- (instancetype)initWithTransitionStyle:(UIPageViewControllerTransitionStyle)style navigationOrientation:(UIPageViewControllerNavigationOrientation)navigationOrientation options:(NSDictionary<NSString *,id> *)options {
    self = [super initWithTransitionStyle:style navigationOrientation:navigationOrientation options:options];
    if (self) {

        return self;
    }
    return nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.dataSource = self;
    self.delegate = self;
    [self initData];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)initData {

    self.dataSource = self;
    self.delegate = self;
    
    _totalImage = 20;
    _enableGesture = YES;
    _currentVC = [self viewControllerAtIndex:_index];

    [self setViewControllers:@[_currentVC] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];    
    [self addChildViewController:_currentVC];
    
}

- (ViewerPageViewController *)viewControllerAtIndex:(NSInteger)index {
    
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main"
                                                         bundle:nil];
    ViewerPageViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"ViewerPageViewController"];
                                     
    vc.indexPath = index;
    vc.delegate = self;
    
    return vc;
}


#pragma mark - PageViewControllerDataSource

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(ViewerPageViewController *)viewController {
    
    _currentVC = viewController;
    _currentVC.interactiveTransitionPresent.delegateGesture = self;
    _index = [_currentVC indexPath];
    
    if (_index > 0 ) {
        return [self viewControllerAtIndex:_index - 1];
    }
    
    return nil;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(ViewerPageViewController *)viewController {
    _currentVC = viewController;
    _currentVC.interactiveTransitionPresent.delegateGesture = self;
    _index = [_currentVC indexPath];
    
    if (_index < _totalImage -1 ) {
        return [self viewControllerAtIndex:_index+1];
    }
    
    return nil;
}

#pragma mark - ViewerPageViewControllerDelegate

- (void)viewerPageViewController:(ViewerPageViewController *)vc clv:(ViewerCollectionView *)clv jumpToViewControllerAtIndex:(NSInteger)index {
    ViewerPageViewController *currentPage = [self viewControllerAtIndex:index];
    currentPage.interactiveTransitionPresent.delegateGesture = self;
    
    [self setViewControllers:@[currentPage] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:^(BOOL finished) {
        if (finished) {
            [clv dismissViewControllerAnimated:YES completion:nil];
        }
    }];
    [clv dismissViewControllerAnimated:YES completion:nil];
}



- (void)pageViewController:(UIPageViewController *)pageViewController willTransitionToViewControllers:(NSArray<UIViewController *> *)pendingViewControllers {
    _currentVC.interactiveTransitionPresent.enableGesture = NO;
}

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray<UIViewController *> *)previousViewControllers transitionCompleted:(BOOL)completed {
    if (finished) {
         _currentVC.interactiveTransitionPresent.enableGesture = YES;
    }
}

@end
