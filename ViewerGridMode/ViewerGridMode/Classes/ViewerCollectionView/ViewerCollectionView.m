//
//  ViewerCollectionView.m
//  ViewerGridMode
//
//  Created by Son Pham on 6/18/18.
//  Copyright © 2018 Son Pham. All rights reserved.
//

#import "ViewerCollectionView.h"
#import "ViewerCollectionViewCell.h"
#import "ViewerTransition.h"

@interface ViewerCollectionView () <UICollectionViewDelegateFlowLayout, UIViewControllerTransitioningDelegate, ViewerTransitionProtocol>

@end

@implementation ViewerCollectionView

static NSString * const reuseIdentifier = @"Cell";

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.collectionView registerNib:[UINib nibWithNibName:@"ViewerCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"ViewerCollectionViewCell"];
    [self.collectionView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setIsProcessingTransition:(BOOL)isProcessingTransition {
    _isProcessingTransition = isProcessingTransition;
    [self.collectionView reloadData];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
//    [self.collectionView reloadData];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}


#pragma mark <UICollectionViewDataSource>

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat width = self.collectionView.frame.size.width / 3 - 20;
    return CGSizeMake(width, width*1.6);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    return 20.0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 20;
}
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(10, 10, 10, 10);
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {

    return 20;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ViewerCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ViewerCollectionViewCell" forIndexPath:indexPath];
    
    cell.imv.image = [UIImage imageNamed:[NSString stringWithFormat:@"image%ld",(long)indexPath.row%10]];
    if (indexPath.row == _currentIndexPath.row) {
        if (_isProcessingTransition) {
            cell.hidden = YES;
        } else {
            cell.imv.layer.borderWidth = 2;
            cell.imv.layer.borderColor = [UIColor blueColor].CGColor;
            cell.hidden = NO;
        }

    } else {
        cell.imv.layer.borderWidth = 0;
        cell.hidden = NO;
    }
    cell.imv.layer.masksToBounds = YES;
    
    return cell;
}

- (CGRect)getFrameCellWithIndexPath:(NSIndexPath*)indexPath {

    UICollectionViewLayoutAttributes *attributes = [self.collectionView layoutAttributesForItemAtIndexPath:indexPath];
    CGRect cellFrameInSuperview = [self.collectionView convertRect:attributes.frame toView:[self.collectionView superview]];
    
    return cellFrameInSuperview;
}


#pragma mark <UICollectionViewDelegate>

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    _currentIndexPath = indexPath;
    if (_delegate && [_delegate respondsToSelector:@selector(viewerCollectionView:DismissViewController:)]) {
        [_delegate viewerCollectionView:self DismissViewController:indexPath.row];
    }
}


#pragma mark - ViewerTransition Protocal

-(UIImageView *)getImageViewPresent {
    ViewerCollectionViewCell *cell = (ViewerCollectionViewCell*)[self.collectionView cellForItemAtIndexPath:_currentIndexPath];
    if (!cell) {
        CGRect frameCell = [self getFrameCellWithIndexPath:_currentIndexPath];
        CGFloat height = 0;
        
        if (frameCell.origin.y > self.collectionView.frame.size.height + self.collectionView.contentOffset.y) {
            height = (frameCell.origin.y+self.collectionView.frame.size.height > self.collectionView.contentSize.height) ?  self.collectionView.contentSize.height - self.collectionView.frame.size.height : frameCell.origin.y+self.collectionView.frame.size.height ;
        }
        self.collectionView.contentOffset= CGPointMake(0, height);
        frameCell.origin.y = frameCell.origin.y - height - 20;
        return [[UIImageView alloc] initWithFrame:frameCell];
    }
    
//    CGRect frame2 = [self getFrameCellWithIndexPath:_currentIndexPath];
    CGRect frame = [cell convertRect:cell.imv.frame toView: [self.collectionView superview]];
    
    UIImageView *img = [[UIImageView alloc] initWithFrame:frame];
    img.image = cell.imv.image;
    
    return img;

}


@end
