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
#import "ReadingBreakController.h"
#import "BaseViewerPageViewController.h"



@interface PageViewController () <UIPageViewControllerDataSource, UIPageViewControllerDelegate, BaseViewerPageViewControllerDelegate>


@property (nonatomic) NSInteger totalImage;
@property (nonatomic) CGPoint contentOffSetClv;
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

- (void)didTapOnGirdMode {
    if ([_currentVC isKindOfClass:[ViewerPageViewController class]]) {
        [(ViewerPageViewController *)_currentVC didTapOnGirdMode];
    } else {
        [(ReadingBreakController*)_currentVC didTapOnGirdMode];
    }
}

- (ViewerPageViewController *)viewControllerAtIndex:(NSInteger)index {
    
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main"
                                                         bundle:nil];
    ViewerPageViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"ViewerPageViewController"];
    vc.indexPath = index;
    vc.contentOffSetClv = _contentOffSetClv;
    vc.delegate = self;
    
    return vc;
}

- (ReadingBreakController *)viewControllerEndChapter {
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main"
                                                         bundle:nil];
    ReadingBreakController *vc = [storyboard instantiateViewControllerWithIdentifier:@"ReadingBreakController"];
    vc.indexPath = _totalImage;
    vc.contentOffSetClv = _contentOffSetClv;
    vc.delegate = self;
    
    return vc;
}

- (NSInteger)getIndexViewController {
    return [_currentVC indexPath];
}


#pragma mark - PageViewControllerDataSource

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(BaseViewerPageViewController *)viewController {
    
    _index = [viewController indexPath];
    
    if (_index > 0 ) {
        return [self viewControllerAtIndex:_index - 1];
    } else if (_index == _totalImage -1) {
        return [self viewControllerEndChapter];
    }
    
    return nil;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(BaseViewerPageViewController *)viewController {
    
    _index = [viewController indexPath];
    
    if (_index < _totalImage -1 ) {
        return [self viewControllerAtIndex:_index+1];
    } else if (_index == _totalImage - 1) {
        return [self viewControllerEndChapter];
    }
    
    return nil;
}


#pragma mark - ViewerPageViewControllerDelegate

- (void)viewerPageViewController:(BaseViewerPageViewController *)vc clv:(ViewerCollectionView *)clv jumpToViewControllerAtIndex:(NSInteger)index {
    
    
    _contentOffSetClv = clv.collectionView.contentOffset;
    _contentOffSetClv = CGPointMake(_contentOffSetClv.x, _contentOffSetClv.y+20);
    
    if (index == _totalImage) {
        _currentVC = [self viewControllerEndChapter];
    } else {
        _currentVC = [self viewControllerAtIndex:index];
    }

    [self setViewControllers:@[_currentVC] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:^(BOOL finished) {
        if (finished) {
            [clv dismissViewControllerAnimated:YES completion:nil];
        }
    }];
}


- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed {
    _currentVC = [pageViewController.viewControllers lastObject];
}


@end
