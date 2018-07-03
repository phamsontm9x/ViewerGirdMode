//
//  ReadingBreakInteractiveTransitioning.m
//  ViewerGridMode
//
//  Created by Son Pham on 6/28/18.
//  Copyright © 2018 ThanhSon. All rights reserved.
//

#import "ReadingBreakInteractiveTransitioning.h"
#import "ReadingBreakPageViewController.h"



@interface ReadingBreakInteractiveTransitioning () <UIGestureRecognizerDelegate>

@property (nonatomic) BOOL shouldCompleteTransition;
@property (nonatomic) UIViewController *viewController;
@property (nonatomic) ReadingBreakPageViewController *presentViewController;
@property (nonatomic) UIPanGestureRecognizer *panGesture;

@end

@implementation ReadingBreakInteractiveTransitioning

- (void)attachToViewController:(UIViewController *)viewController withView:(UIView *)view presentViewController:(UIViewController *)presentViewController {
    
    self.viewController = viewController;
    self.presentViewController = (ReadingBreakPageViewController *)presentViewController;
    self.panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)];
    self.panGesture.delegate = self;
    
    if (_isPresent) {
        [view addGestureRecognizer:self.panGesture];
    } else {
        [self.presentViewController.view addGestureRecognizer:self.panGesture];
    }
}

- (void)attachToPresentViewController:(UIViewController *)presentController withView:(UIView *)view {
    self.panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)];
    self.panGesture.delegate = self;
    [view addGestureRecognizer:self.panGesture];
    _interactionInProgress = YES;
    _presentViewController = (ReadingBreakPageViewController *)presentController;
}

- (void)setInteractionInProgress:(BOOL)interactionInProgress {
    _interactionInProgress = interactionInProgress;
}

- (CGFloat)completionSpeed {
    return 1 - self.percentComplete;
}

- (void)handleGesture:(UIPanGestureRecognizer*)gestureRecognizer {
    CGPoint translation = [gestureRecognizer translationInView:gestureRecognizer.view.superview];
    
    NSLog(@"%f",translation.y);
    if (_interactionInProgress) {
        
        switch (gestureRecognizer.state) {
                
            case UIGestureRecognizerStateBegan: {
                
//                CGPoint locationInView = [gestureRecognizer locationInView:self.presentViewController.viewDismiss];
//
//                if (CGRectContainsPoint(self.presentViewController.viewDismiss.frame, locationInView)) {
//                    [_presentViewController dismissViewControllerAnimated:YES completion:nil];
//                }
                
                [_presentViewController dismissViewControllerAnimated:YES completion:nil];
            }
                break;
                
            case UIGestureRecognizerStateChanged: {
                if (self.interactionInProgress) {
                    
                    CGFloat fraction = fabs(translation.y / (self.presentViewController.view.frame.size.height));
                    NSLog(@"%f----",fraction);
                    fraction = fminf(fmaxf(fraction, 0.0), 1.0);
                    _shouldCompleteTransition = (fraction > 0.3);

                    if (fraction >= 1.0)
                        fraction = 0.99;

                    [self updateInteractiveTransition:fraction];
                }
                break;
            }
                
            case UIGestureRecognizerStateEnded:
            case UIGestureRecognizerStateCancelled:
                
                if (self.interactionInProgress) {
                    [gestureRecognizer setEnabled:YES];
                    if (!_shouldCompleteTransition || gestureRecognizer.state == UIGestureRecognizerStateCancelled) {
                        [self cancelInteractiveTransition];
                    }
                    else {
//                        self.interactionInProgress = NO;
                        [self finishInteractiveTransition];
                    }
                }
                break;
            default:
                break;
        }
    }
}

@end
