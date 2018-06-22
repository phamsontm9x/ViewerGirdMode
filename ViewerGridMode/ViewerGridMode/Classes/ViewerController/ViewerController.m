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
    
//    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
//    tapGesture.delegate = self;
//    [self.view addGestureRecognizer:tapGesture];
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

    self.pageViewController = [[PageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:@{UIPageViewControllerOptionInterPageSpacingKey: @(16)}];
    [self.pageViewController initData];
}

- (IBAction)selectedVertical:(id)sender {
    self.pageViewController = [[PageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationVertical options:@{UIPageViewControllerOptionInterPageSpacingKey: @(16)}];

}

- (IBAction)selectedPageCurl:(id)sender {
    self.pageViewController = [[PageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStylePageCurl navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:@{UIPageViewControllerOptionInterPageSpacingKey: @(16)}];
}



@end
