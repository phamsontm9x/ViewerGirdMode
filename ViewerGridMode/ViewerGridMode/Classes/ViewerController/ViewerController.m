//
//  ViewerController.m
//  ViewerGridMode
//
//  Created by Son Pham on 6/22/18.
//  Copyright © 2018 ThanhSon. All rights reserved.
//

#import "ViewerController.h"

@interface ViewerController () <UIGestureRecognizerDelegate>

@property (nonatomic, strong) PageViewController *pageViewController;

@end

@implementation ViewerController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
    tapGesture.delegate = self;
    [self.view addGestureRecognizer:tapGesture];
    [self.topView setHidden:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    

    if ([segue.destinationViewController isKindOfClass:[PageViewController class]]) {
        self.pageViewController = segue.destinationViewController;
    } else {
        [super prepareForSegue:segue sender:sender];
    }
}

- (void)handleTapGesture:(UITapGestureRecognizer *)gesture {
    _topView.hidden = NO;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        _topView.hidden = YES;
    });
}


- (IBAction)selectedHorizontol:(id)sender {
    
    [self changeModeTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOritentation:UIPageViewControllerNavigationOrientationHorizontal withOptions:@{UIPageViewControllerOptionInterPageSpacingKey: @(16)}];
}

- (IBAction)selectedVertical:(id)sender {
    
    [self changeModeTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOritentation:UIPageViewControllerNavigationOrientationVertical withOptions:@{UIPageViewControllerOptionInterPageSpacingKey: @(16)}];
}

- (IBAction)selectedPageCurl:(id)sender {
    
    [self changeModeTransitionStyle:UIPageViewControllerTransitionStylePageCurl navigationOritentation:UIPageViewControllerNavigationOrientationHorizontal withOptions:@{UIPageViewControllerOptionInterPageSpacingKey: @(16)}];

}

- (void)changeModeTransitionStyle:(UIPageViewControllerTransitionStyle)transitionStyle navigationOritentation:(UIPageViewControllerNavigationOrientation)navigationOrientation withOptions:(NSDictionary<NSString *,id> *)options {
    NSInteger index = [self.pageViewController.currentVC indexPath];
    
    [self.pageViewController willMoveToParentViewController:nil];
    [self.pageViewController.view removeFromSuperview];
    [self.pageViewController removeFromParentViewController];
    [self.pageViewController didMoveToParentViewController:nil];
    
    self.pageViewController = [[PageViewController alloc] initWithTransitionStyle:transitionStyle navigationOrientation:navigationOrientation options:options];
    
    self.pageViewController.index = index;
    [self.pageViewController initData];
    
    [self addChildViewController:self.pageViewController];
    [self.view addSubview:self.pageViewController.view];
    
    [self.view bringSubviewToFront:self.topView];
}


@end
