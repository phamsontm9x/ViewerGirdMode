    //
//  PageCollectionViewController.m
//  ViewerGridMode
//
//  Created by Son Pham on 7/2/18.
//  Copyright © 2018 ThanhSon. All rights reserved.
//

#import "PageCollectionViewController.h"
#import "PageCollectionViewCell.h"
#import "ViewerController.h"
#import "ViewerInteractiveTransitioning.h"



@interface PageCollectionViewController () <UICollectionViewDelegateFlowLayout, UIScrollViewDelegate, UIViewControllerTransitioningDelegate, ViewerCollectionViewDelegate, PageCollectionViewCellDelegate>

// Transition
@property (nonatomic, strong) ViewerTransition *transition;
@property (nonatomic, strong) ViewerInteractiveTransitioning *interactiveTransitionPresent;

@property (nonatomic, strong) ViewerCollectionView<ViewerTransitionProtocol> *vcPresent;
@property (nonatomic) NSInteger totalItems;

@property (nonatomic) BOOL selectedButton;

@end


@implementation PageCollectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _totalItems = 20;
    [self.collectionView registerNib:[UINib nibWithNibName:@"PageCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"PageCollectionViewCell"];
    [self initInteractiveTransition];
    [self.collectionView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)didTapOnGirdMode {
    _selectedButton = YES;
    
    self.vcPresent.currentIndexPath = [NSIndexPath indexPathForRow:[self cellViewForImageTransition].indexPage inSection:0];
    
    if (![self.presentedViewController isBeingDismissed]) {
        [self presentViewController:self.vcPresent animated:YES completion:nil];
    }
}

- (void)setEstimatedSizeIfNeeded {
    UICollectionViewFlowLayout *flowLayout = (UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
    CGFloat estimatedWidth = 30.f;
    if (flowLayout.estimatedItemSize.width != estimatedWidth) {
        [flowLayout setEstimatedItemSize:CGSizeMake(estimatedWidth, 100)];
        [flowLayout invalidateLayout];
    }
}


#pragma mark <UICollectionViewFlowLayout>

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGRect frame = self.collectionView.bounds;
    return CGSizeMake(frame.size.width, frame.size.height -20);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(0, 8, 0, 8);
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _totalItems;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PageCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"PageCollectionViewCell" forIndexPath:indexPath];
    cell.delegate = self;
    cell.indexPage = indexPath.row;
    cell.imv.image = [UIImage imageNamed:[NSString stringWithFormat:@"image%ld",(long)indexPath.row%10]];
    
    return cell;
}


#pragma mark - Init Interactive

- (void)initInteractiveTransition {
    self.vcPresent = [self.storyboard instantiateViewControllerWithIdentifier:@"ViewerCollectionView"];
    _interactiveTransitionPresent = [[ViewerInteractiveTransitioning alloc] init];
    self.vcPresent.transitioningDelegate = self;
    self.vcPresent.delegate = self;
}


#pragma mark - UIViewControllerTransitioningDelegate

- (nullable id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(ViewerCollectionView *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    
    presented.isProcessingTransition = YES;
    
    _transition = [[ViewerTransition alloc] init];
    if (_selectedButton) {
        _transition.enabledInteractive = NO;
        _selectedButton = NO;
    }
    _transition.transitionMode = ViewerTransitionModeCollection;
    _transition.isPresent = YES;
    _transition.snapShot = [self imageViewForImageTransition];
    _transition.frameSnapShot = [self imageViewForImageTransition].frame;
    NSIndexPath *cellIndex = [NSIndexPath indexPathForRow:[self cellViewForImageTransition].indexPage inSection:0];
    _transition.toViewDefault = [self getFrameCellWithIndexPath:cellIndex];
    
    return _transition;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(ViewerCollectionView *)dismissed {
    
    dismissed.isProcessingTransition = YES;
    
    _transition = [[ViewerTransition alloc] init];
    _transition.isPresent = NO;
    NSIndexPath *cellIndex = [NSIndexPath indexPathForRow:[self cellViewForImageTransition].indexPage inSection:0];
    _transition.toViewDefault = [self getFrameCellWithIndexPath:cellIndex];
    _transition.transitionMode = ViewerTransitionModeCollection;
    _transition.enabledInteractive = YES;
    
    return _transition;
}

- (nullable id <UIViewControllerInteractiveTransitioning>)interactionControllerForPresentation:(id <UIViewControllerAnimatedTransitioning>)animator {
    
    return self.interactiveTransitionPresent;
}

#pragma mark - UIViewControllerTransitioningDelegate

- (void)viewerCollectionView:(ViewerCollectionView *)vc DismissViewController:(NSInteger)index {
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredVertically animated:NO];
    [vc dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - PageCollectionViewCellDelegate

- (void)pageCollectionViewCell:(PageCollectionViewCell *)cell dismissViewController:(NSInteger)index {
    self.vcPresent.isProcessingTransition = YES;
    self.vcPresent.currentIndexPath = [NSIndexPath indexPathForRow:index inSection:0];
    [self presentViewController:self.vcPresent animated:YES completion:^{
    
    }];
}

- (void)pageCollectionViewCell:(PageCollectionViewCell *)cell finishInteractiveTransition:(BOOL)finished {
    if (finished) {
        
        UIImageView *endView = [self.vcPresent getImageViewPresentWithInteractive];
        CGRect frame = endView.frame;
        [endView setFrame:frame];
        
        CGRect defaultFrame = [self.collectionView convertRect:cell.pinchGesture.view.frame toView:[self.collectionView superview]];
        
        UIImageView *imageBegin = [[UIImageView alloc] initWithFrame:defaultFrame];
        imageBegin.image = cell.imv.image;
        imageBegin.contentMode = UIViewContentModeScaleAspectFit;
        [self.view addSubview:imageBegin];
        [self.view bringSubviewToFront:imageBegin];
        [cell.pinchGesture.view setHidden:YES];
        
        
        
        [UIView animateWithDuration:0.5 delay:0.0 usingSpringWithDamping:0.8 initialSpringVelocity:1 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            [cell setEnableGesture:NO];
            cell.pinchGesture.view.transform = CGAffineTransformIdentity;
            imageBegin.frame = endView.frame;
        } completion:^(BOOL finished) {
            [cell setEnableGesture:YES];
            [imageBegin removeFromSuperview];
            [cell.pinchGesture.view setHidden:NO];
            self.vcPresent.isProcessingTransition = NO;
        }];
        
        [self.interactiveTransitionPresent finishInteractiveTransition];
    } else {
        [self.interactiveTransitionPresent cancelInteractiveTransition];
    }
}

- (void)pageCollectionViewCell:(PageCollectionViewCell *)cell updateInteractiveTransition:(CGFloat)vaule {
    [self.interactiveTransitionPresent updateInteractiveTransition:vaule];
}

#pragma mark - ImageForTransition

- (CGRect)getFrameCellWithIndexPath:(NSIndexPath*)indexPath {
    
    UICollectionViewLayoutAttributes *attributes = [self.collectionView layoutAttributesForItemAtIndexPath:indexPath];
    CGRect cellFrameInSuperview = attributes.frame;
    cellFrameInSuperview.origin.y = 20;
    return cellFrameInSuperview;
}

- (PageCollectionViewCell *)cellViewForImageTransition {
    PageCollectionViewCell *resultCell = self.collectionView.visibleCells.firstObject;
    CGFloat minCenterY = self.collectionView.frame.size.height;
    for (PageCollectionViewCell *cell in self.collectionView.visibleCells) {
        
        if (fabs(cell.frame.origin.y + cell.frame.size.height/2 - self.collectionView.contentOffset.y - self.collectionView.center.y) <= minCenterY) {
            resultCell  = cell;
            minCenterY = fabs(cell.frame.origin.y + cell.frame.size.height/2 - self.collectionView.contentOffset.y - self.collectionView.center.y);
        }
    }
    
    return resultCell;
}

- (UIImageView *)imageViewForImageTransition {
    PageCollectionViewCell *resultCell = [self cellViewForImageTransition];
    UIImageView *img = [[UIImageView alloc] initWithFrame:resultCell.imv.frame];
    img.image = resultCell.imv.image;
    
    return img;
}

#pragma mark - SnapShot

-(UIImageView *)snapshotImageViewFromView:(UIView *)view {
    UIImage * snapshot = [self dt_takeSnapshotWihtView:view];
    UIImageView * imageView = [[UIImageView alloc] initWithImage:snapshot];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.clipsToBounds = YES;
    return imageView;
}


-(UIImage *)dt_takeSnapshotWihtView:(UIView*)view {
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, YES, [UIScreen mainScreen].scale);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    [view.layer renderInContext:ctx];
    UIImage *snapshot = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return snapshot;
}


@end
