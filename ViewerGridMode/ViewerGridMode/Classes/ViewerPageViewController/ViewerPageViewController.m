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

@interface ViewerPageViewController () <ViewerCollectionViewDelegate, UIViewControllerTransitioningDelegate, ViewerTransitionProtocol, UIScrollViewDelegate, UIGestureRecognizerDelegate>

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
    BOOL _isZoomImage;
    
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
    
    if (!_indexPath) {
        _indexPath = 0;
    }
    
    _imv.image = [UIImage imageNamed:[NSString stringWithFormat:@"image%ld",_indexPath%10]];

    [self configGesture];
    [self initInteractiveTransition];
    [self configScrollView];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
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

- (void)didTapOnGirdMode {
    _selectedButton = YES;
    [self presentViewController:_vcPresent animated:YES completion:^{
        [self.view removeGestureRecognizer:self.panGestureVC];
    }];
}

#pragma mark - Init Interactive
- (void)initInteractiveTransition {
    _vcPresent = [self.storyboard instantiateViewControllerWithIdentifier:@"ViewerCollectionView"];
    _interactiveTransitionPresent = [[ViewerInteractiveTransitioning alloc] init];
    
    _vcPresent.transitioningDelegate = self;
    _vcPresent.currentIndexPath = [NSIndexPath indexPathForRow:_indexPath inSection:0];
    _vcPresent.delegate = self;
}

#pragma mark - UIScrollView

- (void)configScrollView {
    
    _scrPageView.delegate = self;
    _scrPageView.contentSize = self.imv.frame.size;
    _scrPageView.scrollEnabled = YES;
    _scrPageView.maximumZoomScale = 3.0;
    _scrPageView.minimumZoomScale = 1.0;

}

- (void)setIsZoomImage:(BOOL)isZoomImage {
    _isZoomImage = isZoomImage;
}

- (UIView*)viewForZoomingInScrollView:(UIScrollView *)aScrollView {
    return self.imv;
}


#pragma mark - ViewerCollectionViewDelegate

- (void)viewerCollectionView:(ViewerCollectionView *)vc DismissViewController:(NSInteger)index {

    if (_delegate && [_delegate respondsToSelector:@selector(viewerPageViewController:clv:jumpToViewControllerAtIndex:)]) {
        [_delegate viewerPageViewController:self clv:vc jumpToViewControllerAtIndex:index];
    }
}


#pragma mark - UIViewControllerTransitioningDelegate

- (nullable id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    _transition = [[ViewerTransition alloc] init];
    if (_selectedButton) {
        _transition.enabledInteractive = NO;
        _selectedButton = NO;
    }
    _transition.isPresent = YES;
    _transition.snapShot = _imv;
    _transition.frameSnapShot = _defaultView.frame;

    return _transition;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    _transition = [[ViewerTransition alloc] init];
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
                if (!_interactionInProgress && _isZoomImage == NO) {
                    
                    _vcPresent.isProcessingTransition = YES;
                    [self presentViewController:_vcPresent animated:YES completion:^{
                        [self.view removeGestureRecognizer:self.panGestureVC];
                    }];
                    
                    _interactionInProgress = YES;
                }

            }
        }
            break;
            
        case UIGestureRecognizerStateChanged: {
            
            if (!_isZoomImage) {
                if (gestureRecognizer.scale < kMaxScale && gestureRecognizer.scale > kMinScale) {
                    [gestureRecognizer view].transform = CGAffineTransformScale(CGAffineTransformIdentity, gestureRecognizer.scale, gestureRecognizer.scale);
                    
                    if (_interactionInProgress == YES) {
                        if (_interactionInProgress && gestureRecognizer.scale < 1) {
                            CGFloat fraction = fabs((1 - gestureRecognizer.scale) / 0.4);
                            fraction = fminf(fmaxf(fraction, 0.0), 0.7);
                            _shouldCompleteTransition = (fraction > 0.4);
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
        
        UIImageView *endView = [_vcPresent getImageViewPresent];
        CGRect frame = endView.frame;
        frame.origin.y -= 20;
        [endView setFrame:frame];
        UIView *currentView = self.pinchGesture.view;
        [self.interactiveTransitionPresent finishInteractiveTransition];
        
        [UIView animateWithDuration:0.3 animations:^{
            [self setEnableGesture:NO];
            currentView.transform = CGAffineTransformIdentity;
            currentView.frame = endView.frame;
        } completion:^(BOOL finished) {
            [self setEnableGesture:YES];
            _vcPresent.isProcessingTransition = NO;
        }];
        
    } else {
        
        if (!_isZoomImage) {
            UIView *currentView = self.pinchGesture.view;
            _interactionInProgress = NO;
            
            [self.interactiveTransitionPresent cancelInteractiveTransition];
            
            [UIView animateWithDuration:0.3 animations:^{
                [self setEnableGesture:NO];
                currentView.transform = CGAffineTransformIdentity;
            } completion:^(BOOL finished) {
                [self setEnableGesture:YES];
                [self.view removeGestureRecognizer:_panGestureVC];
            }];
        } else {
            if (self.pinchGesture.scale < 1) {
                _isZoomImage = NO;
                UIView *currentView = self.pinchGesture.view;
                _interactionInProgress = NO;
                
                [UIView animateWithDuration:0.3 animations:^{
                    [self setEnableGesture:NO];
                    currentView.transform = CGAffineTransformIdentity;
                } completion:^(BOOL finished) {
                    [self setEnableGesture:YES];
                    [self.view removeGestureRecognizer:_panGestureVC];
                }];
            } else {
                //[self setEnableGesture:NO];
                //[self configScrollView];
            }
        }
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
