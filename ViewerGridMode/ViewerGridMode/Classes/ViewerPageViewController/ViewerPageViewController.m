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

@property (nonatomic) CGFloat rotate;

@property (nonatomic, strong) UIColor *mainColor;

@end

@implementation ViewerPageViewController {
    
    BOOL _shouldCompleteTransition;
    
    ViewerPageViewController *viewVC;
    CGAffineTransform transformDefault;
    CGAffineTransform transformZoom;
    CGAffineTransform transformRotate;
    CGAffineTransform transformMove;
    CGFloat currentScale;
}

const CGFloat kMaxScale = 3.0;
const CGFloat kMinScale = 0.15;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (!self.indexPath) {
        self.indexPath = 0;
    }
    
    _imv.image = [UIImage imageNamed:[NSString stringWithFormat:@"image%ld.jpg",self.indexPath%10]];
    _mainColor = [UIColor colorWithRed:39.0f/255 green:185.0f/255 blue:255.0f/255 alpha:1];
    
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

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
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
    self.vcPresent.isProcessingInteractiveTransition = YES;
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

- (void)viewerCollectionView:(ViewerCollectionView *)vc dismissViewController:(NSInteger)index withModeBackToReading:(BOOL)isBaclToReading {
    [self viewerPageViewControllerDelegate:self clv:vc jumpToViewControllerAtIndex:index];
}


#pragma mark - UIViewControllerTransitioningDelegate

- (nullable id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(ViewerCollectionView *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    
    presented.isProcessingTransition = YES;
    presented.isProcessingInteractiveTransition = YES;
    
    _transition = [[ViewerTransition alloc] init];
    if (_selectedButton) {
        presented.isProcessingInteractiveTransition = NO;
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
    dismissed.isProcessingInteractiveTransition = NO;
    
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
            if (gestureRecognizer.scale < 1 && gestureRecognizer.velocity < 0) {
                if (!_interactionInProgress ) {
                    [self calculateContentOffScrollViewWhenDismiss];
                    _interactionInProgress = YES;
                }

            }
        }
            break;
            
        case UIGestureRecognizerStateChanged: {
            
                if (gestureRecognizer.scale < kMaxScale) {
                    if (_interactionInProgress == YES) {
                        [gestureRecognizer view].transform = CGAffineTransformScale(CGAffineTransformIdentity, gestureRecognizer.scale, gestureRecognizer.scale);
                        if (_interactionInProgress && gestureRecognizer.scale < 1) {
                            CGFloat fraction = fabs((1 - gestureRecognizer.scale) / 0.4);
                            fraction = fminf(fmaxf(fraction, 0.0), 1);
                            _shouldCompleteTransition = (fraction > 0.3);
                            if (fraction >= 1.0)
                                fraction = 0.99;
                            [self.interactiveTransitionPresent updateInteractiveTransition:fraction];
                        }
                    }
                } else {
                    if (gestureRecognizer.scale <= kMinScale && fabs(gestureRecognizer.velocity) > 2) {
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
            [self animationEndGestureWithGesture:gestureRecognizer];
            
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
            _rotate = [gestureRecognizer rotation];
            
            transformDefault = CGAffineTransformRotate([gestureRecognizer view].transform, _rotate);
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

- (void)animationEndGestureWithGesture:(UIPinchGestureRecognizer *)gesture {
    
    if (_shouldCompleteTransition) {
        _shouldCompleteTransition = NO;
        
        [self.view addGestureRecognizer:self.panGestureVC];
        [self.scrPageView.pinchGestureRecognizer setEnabled:NO];
        
        UIImageView *endView = [self.vcPresent getImageViewPresentWithInteractive];
        CGRect frame = endView.frame;
        [endView setFrame:frame];
        
        UIImageView *imageFade = [[UIImageView alloc] initWithFrame:self.pinchGesture.view.frame];
        imageFade.image = self.imv.image;
        imageFade.contentMode = UIViewContentModeScaleAspectFit;
        imageFade.transform = CGAffineTransformRotate(CGAffineTransformIdentity, _rotate);
        
        [self.imv setHidden:YES];
        [self.view addSubview:imageFade];
        
//        CGFloat distance = sqrt(fabs(imageFade.frame.origin.x - endView.frame.origin.x)*fabs(imageFade.frame.origin.x - endView.frame.origin.x) + fabs(imageFade.frame.origin.y - endView.frame.origin.y)*fabs(imageFade.frame.origin.y - endView.frame.origin.y));
        
        CGFloat duration = 0.8;
        
        //begin a new transaction
//        [CATransaction begin];
//        //set the animation duration to 1 second
//        [CATransaction setAnimationDuration:0.8];

    


        
        CABasicAnimation *color = [CABasicAnimation animationWithKeyPath:@"borderColor"];
        // animate from red to blue border ...
        color.fromValue = (id)[UIColor clearColor].CGColor;
        color.toValue   = (id)_mainColor.CGColor;
        // ... and change the model value
        imageFade.layer.borderColor = _mainColor.CGColor;

        CABasicAnimation *width = [CABasicAnimation animationWithKeyPath:@"borderWidth"];
        // animate from 2pt to 4pt wide border ...
        width.fromValue = @0;
        width.toValue   = @4;
        // ... and change the model value
        imageFade.layer.borderWidth = 4;
        

        CAAnimationGroup *both = [CAAnimationGroup animation];
        // animate both as a group with the duration of 0.5 seconds
        both.duration   = 0.01;
        both.beginTime = CACurrentMediaTime() + 0.8;
        both.animations = @[color, width];

        
        // optionally add other configuration (that applies to both animations)
        both.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];

        [imageFade.layer addAnimation:both forKey:@"color and width"];
        

//        [UIView animateKeyframesWithDuration:duration delay:0 options:UIViewKeyframeAnimationOptionCalculationModeCubic animations:^{
//            [UIView addKeyframeWithRelativeStartTime:0 relativeDuration:1 animations:^{
//                imageFade.center = endView.center;
//            }];
//
//            [UIView addKeyframeWithRelativeStartTime:0 relativeDuration:0.8 animations:^{
//                imageFade.transform = CGAffineTransformIdentity;
//            }];
//
//            [UIView addKeyframeWithRelativeStartTime:0.7 relativeDuration:0.3 animations:^{
//                imageFade.layer.borderWidth = 4;
//                imageFade.layer.borderColor = _mainColor.CGColor;
//                imageFade.layer.masksToBounds = YES;
//                imageFade.clipsToBounds = YES;
//            }];
//        } completion:^(BOOL finished) {
//
//        }];
        
        
        
        [UIView animateWithDuration:0.2 delay:0.3 options:UIViewAnimationOptionCurveEaseOut animations:^{
            imageFade.transform = CGAffineTransformIdentity;

        } completion:^(BOOL finished) {
            imageFade.layer.borderWidth = 4;
            imageFade.layer.borderColor = _mainColor.CGColor;
            imageFade.layer.masksToBounds = YES;
            imageFade.clipsToBounds = YES;
        }];
        

        [UIView animateWithDuration:duration delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            [imageFade setBounds:endView.frame];
            [self.interactiveTransitionPresent finishInteractiveTransition];
            [self setEnableGesture:NO];
        } completion:^(BOOL finished) {

        }];

        [UIView animateWithDuration:duration delay:0.0 usingSpringWithDamping:0.9 initialSpringVelocity:fabs(gesture.velocity) options:UIViewAnimationOptionCurveEaseOut animations:^{
            imageFade.center = endView.center;
            
        } completion:^(BOOL finished) {
            [self setEnableGesture:YES];
            _interactionInProgress = NO;
            self.vcPresent.isProcessingTransition = NO;
            [self.scrPageView.pinchGestureRecognizer setEnabled:YES];
        }];
        
       // [CATransaction commit];
        
    } else {
        
        UIView *currentView = self.pinchGesture.view;
        _interactionInProgress = NO;
        [self.scrPageView.pinchGestureRecognizer setEnabled:NO];
        [self.interactiveTransitionPresent cancelInteractiveTransition];
        
        [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            [self setEnableGesture:NO];
            currentView.transform = CGAffineTransformIdentity;
        } completion:^(BOOL finished) {
            [self setEnableGesture:YES];
            [self.scrPageView.pinchGestureRecognizer setEnabled:YES];
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

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale  {
    if (scrollView == _scrPageView) {
        [scrollView.pinchGestureRecognizer setEnabled:YES];
    }
}

@end
