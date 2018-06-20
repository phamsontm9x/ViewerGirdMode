//
//  ViewerInteractiveTransitioning.m
//  ViewerGridMode
//
//  Created by Son Pham on 6/18/18.
//  Copyright © 2018 Son Pham. All rights reserved.
//

#import "ViewerInteractiveTransitioning.h"
#import <objc/runtime.h>
#import "ViewerPageViewController.h"
#import "ViewerCollectionView.h"


@interface ViewerInteractiveTransitioning () <UIGestureRecognizerDelegate>
@property (nonatomic, assign) CGFloat startScale;
@property (nonatomic) ViewerPageViewController *viewController;
@property (nonatomic) ViewerCollectionView<ViewerTransitionProtocol> *presentViewController;
@property (nonatomic) UIPanGestureRecognizer *panGesture;
@property (nonatomic) UIPinchGestureRecognizer *pinchGesture;
@property (nonatomic) UIRotationGestureRecognizer *roationGesture;

@end



@implementation ViewerInteractiveTransitioning {
    BOOL _shouldCompleteTransition;
    NSMutableSet *_activeRecognizers;
    CGPoint center;
    CGPoint centerTemp;
    ViewerPageViewController *viewVC;
    CGAffineTransform transformDefault;
    CGAffineTransform transformZoom;
    CGAffineTransform transformRotate;
    CGAffineTransform transformMove;
    CGFloat currentScale;
    CGRect defaultView;
}

const CGFloat kMaxScale = 3.0;
const CGFloat kMinScale = 0.3;

- (void)attachToViewController:(ViewerPageViewController *)viewController withView:(UIView *)view presentViewController:(ViewerCollectionView<ViewerTransitionProtocol> *)presentViewController {
    
    self.viewController = viewController;
    self.presentViewController = presentViewController;
    [self.viewController.imv setUserInteractionEnabled:YES];
    defaultView = self.viewController.imv.frame;
    
    // remove gestures
    [self.viewController.imv removeGestureRecognizer:_panGesture];
    [self.viewController.imv removeGestureRecognizer:_pinchGesture];
    [self.viewController.imv removeGestureRecognizer:_roationGesture];
    
    // add gesture
    self.panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGestureRecognizer:)];
    self.panGesture.delegate = self;
    self.panGesture.minimumNumberOfTouches = 2;
    self.panGesture.maximumNumberOfTouches = 2;
    
    self.pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinch:)];
    self.pinchGesture.delegate = self;
    self.startScale = 1;
    currentScale = 1;
    
    self.roationGesture = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(handleRotateGestureRecognizer:)];
    self.roationGesture.delegate = self;
    
    [self.viewController.imv addGestureRecognizer:self.pinchGesture];
    [self.viewController.imv addGestureRecognizer:self.panGesture];
    [self.viewController.imv addGestureRecognizer:self.roationGesture];
    
    transformDefault = CGAffineTransformIdentity;
}

- (void)setInteractionInProgress:(BOOL)interactionInProgress {
    _interactionInProgress = interactionInProgress;
}

- (CGFloat)completionSpeed {
    return 1 - self.percentComplete;
}

- (void)handlePinch:(UIPinchGestureRecognizer*)gestureRecognizer {
    
    switch (gestureRecognizer.state) {
        case UIGestureRecognizerStateBegan: {
            
            if (gestureRecognizer.scale > 1.0) {
                [self.roationGesture setEnabled:NO];
            } else {
                if (!_interactionInProgress) {
                    self.presentViewController.isProcessingTransition = YES;
                    [self.viewController presentViewController:self.presentViewController animated:YES completion:nil];
                    _interactionInProgress = YES;
                }
            }
        }
            break;
            
        case UIGestureRecognizerStateChanged: {
            
            UIView *currentView = self.panGesture.view;
            //NSLog(@"%f--- %f",currentView.frame.size.width, currentView.frame.size.height);
            NSLog(@"%f",gestureRecognizer.scale);
            transformDefault = CGAffineTransformScale(CGAffineTransformIdentity, gestureRecognizer.scale, gestureRecognizer.scale);
            [gestureRecognizer view].transform = transformDefault;
            
            if (_interactionInProgress == YES) {
                if (_interactionInProgress && gestureRecognizer.scale < 1) {
                    CGFloat fraction = fabs((1 - gestureRecognizer.scale) / 0.7);
                    fraction = fminf(fmaxf(fraction, 0.0), 1.0);
                    _shouldCompleteTransition = (fraction > 0.5);
                    if (fraction >= 1.0)
                        fraction = 0.99;
                    
                    [self updateInteractiveTransition:fraction];
                }
            }
        }
            break;
            
        case UIGestureRecognizerStateFailed:
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateEnded: {
            
            currentScale = [gestureRecognizer scale];
            [self animationEndGesture];
            
        }
            break;
        default:
            break;
    }
    
}

- (void)handlePanGestureRecognizer:(UIPanGestureRecognizer *)gestureRecognizer {
    
    CGPoint pointGesture = [gestureRecognizer translationInView: gestureRecognizer.view];
    switch (gestureRecognizer.state) {
        case UIGestureRecognizerStateBegan: {
            
        }
            break;
            
        case UIGestureRecognizerStateChanged: {
            transformMove = CGAffineTransformTranslate([gestureRecognizer view].transform, pointGesture.x, pointGesture.y);
            [gestureRecognizer view].transform = transformMove;
        }
            break;
            
        case UIGestureRecognizerStateEnded: {
            
        }
            break;
            
        default:
            break;
    }
}

- (void)handleRotateGestureRecognizer:(UIRotationGestureRecognizer *)gestureRecognizer {
    
    switch (gestureRecognizer.state) {
        case UIGestureRecognizerStateBegan: {
            
        }
            break;
            
        case UIGestureRecognizerStateChanged: {
            CGFloat rotate = [gestureRecognizer rotation];
            
            transformDefault = CGAffineTransformRotate([gestureRecognizer view].transform, rotate);
            [gestureRecognizer view].transform = transformDefault;
        }
            break;
            
        case UIGestureRecognizerStateEnded: {
            
        }
            break;
            
        default:
            break;
    }
}

- (void)animationEndGesture {
    
    if (_shouldCompleteTransition) {
        _shouldCompleteTransition = NO;
        
        UIImageView *endView = [self.presentViewController getImageViewPresent];
        UIView *currentView = self.pinchGesture.view;
        
        [UIView animateWithDuration:0.2 animations:^{
            currentView.transform = CGAffineTransformIdentity;
            currentView.frame = endView.frame;
        } completion:^(BOOL finished) {
            self.presentViewController.isProcessingTransition = NO;
            [self finishInteractiveTransition];
        }];
    } else {
        _interactionInProgress = NO;
        UIView *currentView = self.pinchGesture.view;
        
        [UIView animateWithDuration:0.2 animations:^{
            currentView.transform = CGAffineTransformIdentity;
        } completion:^(BOOL finished) {
            [self cancelInteractiveTransition];
        }];
    }

}




#pragma mark - TransitionControllerGestureTarget

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    
    return YES;
}

@end
