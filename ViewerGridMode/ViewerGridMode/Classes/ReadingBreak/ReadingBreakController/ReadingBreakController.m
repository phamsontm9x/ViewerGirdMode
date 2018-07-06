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



@interface ReadingBreakController () <UIViewControllerTransitioningDelegate,ViewerCollectionViewDelegate>

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
    self.vcPresent = [self.storyboard instantiateViewControllerWithIdentifier:@"ViewerCollectionView"];
    self.vcPresent.delegate = self;
    self.vcPresent.transitioningDelegate = self;
    self.vcPresent.currentIndexPath = [NSIndexPath indexPathForRow:self.indexPath inSection:0];
    self.vcPresent.collectionView.contentOffset = self.contentOffSetClv;
    
    if (![self.presentedViewController isBeingDismissed]) {
        [self presentViewController:self.vcPresent animated:YES completion:nil];
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
    
    if ([presented isKindOfClass:[ViewerCollectionView class]]) {
        ViewerTransition *transition = [[ViewerTransition alloc] init];
        transition.isPresent = YES;
        ViewerCollectionView * vc = (ViewerCollectionView *)presented;
        if (vc.currentIndexPath.row == vc.totalItems - 1) {
            transition.transitionMode = ViewerTransitionModeAds;
        } else {
            transition.transitionMode = ViewerTransitionModePage;
        }
        
        transition.snapShot = [self snapshotImageViewFromView:self.imageAds];
        transition.frameSnapShot = self.imageAds.frame;
        transition.enabledInteractive = NO;
        
        return transition;
    }
    
    if ([presented isKindOfClass:[ReadingBreakPageViewController class]]) {
        ReadingBreakTransition *transition = [[ReadingBreakTransition alloc] init];
        transition.isPresent = YES;
        
        return transition;
    }

    return nil;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    
    if ([dismissed isKindOfClass:[ViewerCollectionView class]]) {
        ViewerTransition *transition = [[ViewerTransition alloc] init];
        transition.isPresent = NO;
        transition.toViewDefault = self.defaultView.frame;
        transition.frameSnapShot = self.defaultView.frame;
        
        return transition;
    }
    
    if ([dismissed isKindOfClass:[ReadingBreakPageViewController class]]) {
        ReadingBreakTransition *transition = [[ReadingBreakTransition alloc] init];
        transition.isPresent = NO;
        
        return transition;
    }

    return nil;
}

- (nullable id <UIViewControllerInteractiveTransitioning>)interactionControllerForDismissal:(id <UIViewControllerAnimatedTransitioning>)animator {
    _interactiveTransitionPresent.interactionInProgress = YES;
    
    return _interactiveTransitionPresent;
}


#pragma mark - ViewerCollectionViewDelegate

- (void)viewerCollectionView:(ViewerCollectionView *)vc dismissViewController:(NSInteger)index withModeBackToReading:(BOOL)isBackToReading {
    [self viewerPageViewControllerDelegate:self clv:vc jumpToViewControllerAtIndex:index];
}


#pragma mark - SnapShot

-(UIImageView *)snapshotImageViewFromView:(UIView *)view {
    UIImage * snapshot = [self dt_takeSnapshotWihtView:view];
    UIImageView * imageView = [[UIImageView alloc] initWithImage:snapshot];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.clipsToBounds = YES;
    return imageView;
}


-(UIImage *)dt_takeSnapshotWihtView:(UIView*)view
{
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, YES, [UIScreen mainScreen].scale);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    [view.layer renderInContext:ctx];
    UIImage *snapshot = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return snapshot;
}

@end
