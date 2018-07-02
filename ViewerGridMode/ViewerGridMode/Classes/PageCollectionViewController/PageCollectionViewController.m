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



@interface PageCollectionViewController () <UICollectionViewDelegateFlowLayout, UIScrollViewDelegate, UIViewControllerTransitioningDelegate, ViewerCollectionViewDelegate>

// Transition
@property (nonatomic, strong) ViewerTransition *transition;

@property (nonatomic, strong) ViewerCollectionView<ViewerTransitionProtocol> *vcPresent;
@property (nonatomic) NSInteger totalItems;

@property (nonatomic) BOOL selectedButton;

@end


@implementation PageCollectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _totalItems = 20;
    [self.collectionView registerNib:[UINib nibWithNibName:@"PageCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"PageCollectionViewCell"];
    
    [self.collectionView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)didTapOnGirdMode {
    _selectedButton = YES;
    
    self.vcPresent = [self.storyboard instantiateViewControllerWithIdentifier:@"ViewerCollectionView"];
    self.vcPresent.delegate = self;
    self.vcPresent.transitioningDelegate = self;
    self.vcPresent.currentIndexPath = [NSIndexPath indexPathForRow:[self cellViewForImageTransition].indexPage inSection:0];
    //self.vcPresent.collectionView.contentOffset = self.contentOffSetClv;
    
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
    CGRect frame = self.collectionView.frame;
    return CGSizeMake(frame.size.width -10, frame.size.height);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    return 0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(0, 0 , 0, 0);
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
    
    cell.indexPage = indexPath.row;
    cell.imv.image = [UIImage imageNamed:[NSString stringWithFormat:@"image%ld",(long)indexPath.row%10]];
    
    return cell;
}

#pragma mark <UICollectionViewDelegate>

/*
// Uncomment this method to specify if the specified item should be highlighted during tracking
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}
*/

/*
// Uncomment this method to specify if the specified item should be selected
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
*/

/*
// Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	return NO;
}

- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	
}
*/


#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    
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
    
    return _transition;
}


#pragma mark - UIViewControllerTransitioningDelegate

- (void)viewerCollectionView:(ViewerCollectionView *)vc DismissViewController:(NSInteger)index {
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredVertically animated:NO];
    [vc dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - ImageForTransition

- (CGRect)getFrameCellWithIndexPath:(NSIndexPath*)indexPath {
    
    UICollectionViewLayoutAttributes *attributes = [self.collectionView layoutAttributesForItemAtIndexPath:indexPath];
    CGRect cellFrameInSuperview = [self.collectionView convertRect:attributes.frame toView:[self.collectionView superview]];
    
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


@end
