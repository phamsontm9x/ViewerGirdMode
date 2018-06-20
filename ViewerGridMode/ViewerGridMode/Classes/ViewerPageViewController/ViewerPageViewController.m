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

@interface ViewerPageViewController () <ViewerCollectionViewDelegate, UIViewControllerTransitioningDelegate, ViewerTransitionProtocol, UIGestureRecognizerDelegate>

// Transition
@property (nonatomic, strong) ViewerCollectionView *vc;
@property (nonatomic, strong) ViewerTransition *transition;

@property (nonatomic) CGPoint center;

@property (nonatomic) CGRect frameCellPresent;

@property (nonatomic) BOOL selectedButton;

@end

@implementation ViewerPageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (!_indexPath) {
        _indexPath = 0;
    }
    
    _imv.image = [UIImage imageNamed:[NSString stringWithFormat:@"image%ld",_indexPath%10]];
//    _imv.backgroundColor = [UIColor blueColor];
    [self initInteractiveTransition];
    [self initTapGesture];
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

- (void)initTapGesture {
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handlerTapGesture:)];
    tapGesture.delegate = self;
    [self.view addGestureRecognizer:tapGesture];
}

- (void)handlerTapGesture:(UITapGestureRecognizer *)gesture {
    _btnShowList.hidden = NO;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        _btnShowList.hidden = YES;
    });
    
}

- (void)initInteractiveTransition {
    _vc = [self.storyboard instantiateViewControllerWithIdentifier:@"ViewerCollectionView"];
    _interactiveTransitionPresent = [[ViewerInteractiveTransitioning alloc] init];
    
    _interactiveTransitionPresent.isPresent = YES;
    _interactiveTransitionPresent.interactionInProgress = NO;
    [_interactiveTransitionPresent attachToViewController:self withView:self.view presentViewController:_vc];
    _vc.transitioningDelegate = self;
    _vc.currentIndexPath = [NSIndexPath indexPathForRow:_indexPath inSection:0];
    _vc.delegate = self;
}


- (IBAction)didSelectGirdMode:(id)sender {

    _vc.currentIndexPath = [NSIndexPath indexPathForRow:_indexPath inSection:0];
    _selectedButton = YES;
    [self presentViewController:_vc animated:YES completion:nil];
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
    [_transition.snapShot setFrame:_defaultView.frame];
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

    self.interactiveTransitionPresent.interactionInProgress = YES;

    return self.interactiveTransitionPresent;
}


#pragma mark - ViewerTransition Protocal

- (UIImageView *)getImageViewPresent:(BOOL)isPresent {
    return _imv;
}



@end
