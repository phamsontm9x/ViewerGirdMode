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



@interface ReadingBreakController () <UIViewControllerTransitioningDelegate, ReadingBreakTransitionProtocol>

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


- (IBAction)btnPresentListCredits:(id)sender {
    ReadingBreakPageViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:NSStringFromClass([ReadingBreakPageViewController class])];
    

    _interactiveTransitionPresent = [[ReadingBreakInteractiveTransitioning alloc] init];
    [_interactiveTransitionPresent attachToPresentViewController:vc withView:vc.view];

    vc.transitioningDelegate = self;


    [self presentViewController:vc animated:nil completion:nil];
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

- (nullable id <UIViewControllerInteractiveTransitioning>)interactionControllerForPresentation:(id <UIViewControllerAnimatedTransitioning>)animator {
    
    return _interactiveTransitionPresent;
}


#pragma mark - ReadingBreakTransitionProtocol

- (UIImageView *)getImageViewPresentWithTransition {
    return nil;
}

- (UIImageView *)getImageViewDismissWithTransition {
    return nil;
}

@end
