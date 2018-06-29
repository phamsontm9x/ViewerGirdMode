//
//  ReadingBreakController.m
//  ViewerGridMode
//
//  Created by Son Pham on 6/28/18.
//  Copyright © 2018 ThanhSon. All rights reserved.
//

#import "ReadingBreakController.h"
#import "ReadingBreakPageViewController.h"
#import "ReadingBreakTransition.h"
#import "ReadingBreakInteractiveTransitioning.h"
#import "ReadingBreakPresentationController.h"



@interface ReadingBreakController () <UIViewControllerTransitioningDelegate, ViewerCollectionViewDelegate>

@property (nonatomic) ReadingBreakInteractiveTransitioning *interactiveTransitionPresent;

@end

@implementation ReadingBreakController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)didTapOnGirdMode {
    _vcPresent = [self.storyboard instantiateViewControllerWithIdentifier:@"ViewerCollectionView"];
    _vcPresent.delegate = self;
    _vcPresent.collectionView.contentOffset = _contentOffSetClv;
    
    if (![self.presentedViewController isBeingDismissed]) {
        [self presentViewController:_vcPresent animated:YES completion:nil];
    }
    
    
}


- (IBAction)btnPresentListCredits:(id)sender {
    ReadingBreakPageViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:NSStringFromClass([ReadingBreakPageViewController class])];
    
    _interactiveTransitionPresent = [[ReadingBreakInteractiveTransitioning alloc] init];
    [_interactiveTransitionPresent attachToPresentViewController:vc withView:vc.view];
    vc.transitioningDelegate = self;
    
    vc.modalPresentationStyle = UIModalPresentationCustom;
    
    [self presentViewController:vc animated:YES completion:nil];
}


#pragma mark - UIViewControllerTransitioningDelegate

- (nullable id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    
    ReadingBreakTransition *transition = [[ReadingBreakTransition alloc] init];
    transition.isPresent = YES;
    
    return transition;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    
    ReadingBreakTransition *transition = [[ReadingBreakTransition alloc] init];
    transition.isPresent = NO;
    
    return transition;
}

- (nullable id <UIViewControllerInteractiveTransitioning>)interactionControllerForDismissal:(id <UIViewControllerAnimatedTransitioning>)animator {
    _interactiveTransitionPresent.interactionInProgress = YES;
    
    return _interactiveTransitionPresent;
}


#pragma mark - ViewerCollectionViewDelegate

- (void)viewerCollectionView:(ViewerCollectionView *)vc DismissViewController:(NSInteger)index {
    if (_delegate && [_delegate respondsToSelector:@selector(readingBreakController:clv:jumpToViewControllerAtIndex:)]) {
        [_delegate readingBreakController:self clv:vc jumpToViewControllerAtIndex:index];
    }
}



@end
