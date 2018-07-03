//
//  ViewerPageViewController.m
//  ViewerGridMode
//
//  Created by Son Pham on 6/18/18.
//  Copyright © 2018 Son Pham. All rights reserved.
//

#import "ViewerPageViewController.h"
#import "ViewerCollectionView.h"
#import "ViewerTransition.h"
#import "ViewerInteractiveTransitioning.h"

@interface ViewerPageViewController () < UIViewControllerTransitioningDelegate, ViewerTransitionProtocol, UIScrollViewDelegate, UIGestureRecognizerDelegate, ViewerCollectionViewDelegate>

// Transition
@property (nonatomic, strong) ViewerTransition *transition;

// Gesture
@property (nonatomic) UIPanGestureRecognizer *panGestureVC;
@property (nonatomic) UIPanGestureRecognizer *panGesture;
@property (nonatomic) UIPinchGestureRecognizer *pinchGesture;
@property (nonatomic) UIRotationGestureRecognizer *rotationGesture;

@property (nonatomic, weak) IBOutlet UIImageView *imv;

@property (nonatomic) BOOL interactionInProgress;
@property (nonatomic) BOOL isPresent;
@property (nonatomic) BOOL enableGesture;

@property (nonatomic) CGRect frameCellPresent;
@property (nonatomic) BOOL selectedButton;

@end

@implementation ViewerPageViewController {
    
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
}

const CGFloat kMaxScale = 3.0;
const CGFloat kMinScale = 0.4;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (!self.indexPath) {
        self.indexPath = 0;
    }
    
    _imv.image = [UIImage imageNamed:[NSString stringWithFormat:@"image%ld",self.indexPath%10]];
    
    [self configGesture];
    [self initInteractiveTransition];
    [self configScrollView];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//- (UIStatusBarStyle)preferredStatusBarStyle {
//    return UIStatusBarStyleLightContent;
//}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)didTapOnGirdMode {
    _selectedButton = YES;
    if (![self.presentedViewController isBeingDismissed]) {
        self.vcPresent.collectionView.contentOffset = self.contentOffSetClv;
        [self presentViewController:self.vcPresent animated:YES completion:^{
            [self.view removeGestureRecognizer:self.panGestureVC];
        }];
    }
}

#pragma mark - Init Interactive
- (void)initInteractiveTransition {
    self.vcPresent = [self.storyboard instantiateViewControllerWithIdentifier:@"ViewerCollectionView"];
    _interactiveTransitionPresent = [[ViewerInteractiveTransitioning alloc] init];
    self.vcPresent.transitioningDelegate = self;
    self.vcPresent.currentIndexPath = [NSIndexPath indexPathForRow:self.indexPath inSection:0];
    self.vcPresent.delegate = self;
}

- (void)calculateContentOffScrollViewWhenDismiss {
#warning need to calculate
    self.vcPresent.collectionView.contentOffset = self.contentOffSetClv;
    self.vcPresent.isProcessingTransition = YES;
    [self presentViewController:self.vcPresent animated:YES completion:^{
        [self.view removeGestureRecognizer:self.panGestureVC];
    }];
}

#pragma mark - UIScrollView

- (void)configScrollView {
    
    _scrPageView.delegate = self;
    _scrPageView.contentSize = self.imv.frame.size;
    _scrPageView.scrollEnabled = YES;
    _scrPageView.maximumZoomScale = 3.0;
    _scrPageView.minimumZoomScale = 1.0;

}

- (UIView*)viewForZoomingInScrollView:(UIScrollView *)aScrollView {
    return self.imv;
}


#pragma mark - ViewerCollectionViewDelegate

- (void)viewerCollectionView:(ViewerCollectionView *)vc DismissViewController:(NSInteger)index {
    [self viewerPageViewControllerDelegate:self clv:vc jumpToViewControllerAtIndex:index];
}


#pragma mark - UIViewControllerTransitioningDelegate

- (nullable id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(ViewerCollectionView *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    
    presented.isProcessingTransition = YES;
    
    _transition = [[ViewerTransition alloc] init];
    if (_selectedButton) {
        _transition.enabledInteractive = NO;
        _selectedButton = NO;
    }
    _transition.transitionMode = ViewerTransitionModePage;
    _transition.isPresent = YES;
    _transition.snapShot = _imv;
    _transition.frameSnapShot = _defaultView.frame;

    return _transition;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(ViewerCollectionView *)dismissed {
    
    dismissed.isProcessingTransition = YES;
    
    _transition = [[ViewerTransition alloc] init];
    
    if (dismissed.currentIndexPath.row == dismissed.totalItems - 1) {
        _transition.transitionMode = ViewerTransitionModeAds;
    } else {
        _transition.transitionMode = ViewerTransitionModePage;
    }

    _transition.isPresent = NO;
    _transition.toViewDefault = _defaultView.frame;
    _transition.frameSnapShot = _defaultView.frame;
    
    return _transition;
}

- (nullable id <UIViewControllerInteractiveTransitioning>)interactionControllerForPresentation:(id <UIViewControllerAnimatedTransitioning>)animator {

    self.interactionInProgress = YES;

    return self.interactiveTransitionPresent;
}


#pragma mark - ViewerTransition Protocal

- (UIImageView *)getImageViewPresent:(BOOL)isPresent {
    return self.imv;
}


#pragma mark - ConfigGesture

- (void)configGesture {
    
    [self.imv setUserInteractionEnabled:YES];
    
    // remove gestures
    [self.imv removeGestureRecognizer:_panGesture];
    [self.imv removeGestureRecognizer:_pinchGesture];
    [self.imv removeGestureRecognizer:_rotationGesture];
    [self.view removeGestureRecognizer:_panGestureVC];
    
    self.panGestureVC = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanVC:)];
    self.panGestureVC.delegate = self;
    
    // add gesture
    self.panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGestureRecognizer:)];
    self.panGesture.delegate = self;
    self.panGesture.minimumNumberOfTouches = 2;
    self.panGesture.maximumNumberOfTouches = 2;
    
    self.pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinch:)];
    self.pinchGesture.delegate = self;

    currentScale = 1;
    
    self.rotationGesture = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(handleRotateGestureRecognizer:)];
    self.rotationGesture.delegate = self;
    
    [self.imv addGestureRecognizer:self.pinchGesture];
    [self.imv addGestureRecognizer:self.panGesture];
    [self.imv addGestureRecognizer:self.rotationGesture];
}

- (void)setEnableGesture:(BOOL)enableGesture {
    [self.pinchGesture setEnabled:enableGesture];
    [self.panGesture setEnabled:enableGesture];
    [self.rotationGesture setEnabled:enableGesture];
}

#pragma mark - Handler Gesture

- (void)handlePanVC:(UIPanGestureRecognizer*)gestureRecognizer {
    
}

- (void)handlePinch:(UIPinchGestureRecognizer*)gestureRecognizer {
    
    switch (gestureRecognizer.state) {
        case UIGestureRecognizerStateBegan: {
            NSLog(@"%f",gestureRecognizer.velocity);
            if (gestureRecognizer.scale < 1 && gestureRecognizer.velocity < 0) {
                if (!_interactionInProgress ) {
                    [self calculateContentOffScrollViewWhenDismiss];
                    _interactionInProgress = YES;
                }

            }
        }
            break;
            
        case UIGestureRecognizerStateChanged: {
            
                if (gestureRecognizer.scale < kMaxScale && gestureRecognizer.scale > kMinScale) {
                    [gestureRecognizer view].transform = CGAffineTransformScale(CGAffineTransformIdentity, gestureRecognizer.scale, gestureRecognizer.scale);
                    
                    if (_interactionInProgress == YES) {
                        if (_interactionInProgress && gestureRecognizer.scale < 1) {
                            CGFloat fraction = fabs((1 - gestureRecognizer.scale) / 0.4);
                            fraction = fminf(fmaxf(fraction, 0.0), 0.7);
                            _shouldCompleteTransition = (fraction > 0.5);
                            if (fraction >= 1.0)
                                fraction = 0.99;
                            
                            [self.interactiveTransitionPresent updateInteractiveTransition:fraction];
                        }
                    }
                } else {
                    if (gestureRecognizer.scale <= kMinScale) {
                        [self setEnableGesture:NO];
                    }
                }
        }
            break;
            
        case UIGestureRecognizerStateFailed:
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateEnded: {
            NSLog(@"______");
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
        
        [self.view addGestureRecognizer:self.panGestureVC];
        [self.panGestureVC requireGestureRecognizerToFail:self.panGesture];
        
        UIImageView *endView = [self.vcPresent getImageViewPresentWithInteractive];
        CGRect frame = endView.frame;
#warning statusBar 20
        frame.origin.y -= 20;
        [endView setFrame:frame];
        UIView *currentView = self.pinchGesture.view;
        [self.interactiveTransitionPresent finishInteractiveTransition];
        
        [UIView animateWithDuration:0.5 delay:0.0 usingSpringWithDamping:0.8 initialSpringVelocity:1 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            [self setEnableGesture:NO];
            currentView.transform = CGAffineTransformIdentity;
            currentView.frame = endView.frame;
        } completion:^(BOOL finished) {
            [self setEnableGesture:YES];
            self.vcPresent.isProcessingTransition = NO;
        }];
        
    } else {
        
        UIView *currentView = self.pinchGesture.view;
        _interactionInProgress = NO;
        
        [self.interactiveTransitionPresent cancelInteractiveTransition];
        
        [UIView animateWithDuration:0.5 delay:0.0 usingSpringWithDamping:0.8 initialSpringVelocity:1 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            [self setEnableGesture:NO];
            currentView.transform = CGAffineTransformIdentity;
        } completion:^(BOOL finished) {
            [self setEnableGesture:YES];
            [self.view removeGestureRecognizer:_panGestureVC];
        }];
               
    }
}

#pragma mark - TransitionControllerGestureTarget

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    
    if (([gestureRecognizer isKindOfClass:[UIPinchGestureRecognizer class]] || gestureRecognizer == self.panGesture || gestureRecognizer == self.rotationGesture)
        &&([otherGestureRecognizer isKindOfClass:[UIPinchGestureRecognizer class]] || otherGestureRecognizer == self.panGesture || otherGestureRecognizer == self.rotationGesture)) {
        return YES;
    }
    
    return NO;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if (gestureRecognizer != self.panGesture && gestureRecognizer != self.pinchGesture && gestureRecognizer != self.rotationGesture) {
        
        NSLog(@"%@",gestureRecognizer.description);
    }
    
    return YES;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer == self.pinchGesture) {
        if ((self.pinchGesture.velocity < 0 && self.pinchGesture.scale < 1.0 ) && _scrPageView.zoomScale == 1) {
            return YES;
        } else {
            return NO;
        }
    }
    
    return YES;
}

- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view {
    NSLog(@"%f",scrollView.pinchGestureRecognizer.velocity);
    if ((scrollView.pinchGestureRecognizer.velocity < 0 && scrollView.pinchGestureRecognizer.scale <= 1.0 ) && scrollView.zoomScale == 1 && scrollView == _scrPageView) {
        [scrollView.pinchGestureRecognizer setEnabled:NO];
    }
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale  {
    if (scrollView == _scrPageView) {
        [scrollView.pinchGestureRecognizer setEnabled:YES];
    }
}

@end
