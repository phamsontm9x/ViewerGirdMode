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
#import "ReadingBreakController.h"

@interface ViewerCollectionView () <UICollectionViewDelegateFlowLayout, UIViewControllerTransitioningDelegate, ViewerTransitionProtocol, UIScrollViewDelegate>

@property (nonatomic) UIButton *btnBackToReading;

@end

@implementation ViewerCollectionView {
}


- (void)viewDidLoad {
    [super viewDidLoad];

    _totalItems = 21;
    
    [self.collectionView registerNib:[UINib nibWithNibName:@"ViewerCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"ViewerCollectionViewCell"];
    [self.collectionView reloadData];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self initBackToReading];
}

- (void)initBackToReading {
    
    [_btnBackToReading removeFromSuperview];
    
    _btnBackToReading = [[UIButton alloc] initWithFrame:CGRectMake((self.collectionView.frame.size.width - 200)/2, self.collectionView.frame.size.height - 70 , 200, 50)];
    [_btnBackToReading addTarget:self action:@selector(didSelectBackToReading:) forControlEvents:UIControlEventTouchUpInside];
    [_btnBackToReading setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [_btnBackToReading setBackgroundColor:[UIColor whiteColor]];
    _btnBackToReading.layer.cornerRadius = 15;
    _btnBackToReading.clipsToBounds = YES;
    _btnBackToReading.layer.borderWidth = 1;
    _btnBackToReading.layer.borderColor = [UIColor blueColor].CGColor;
    [_btnBackToReading setTitle:@"X  Back To Reading" forState:UIControlStateNormal];
    
    [self.view addSubview:_btnBackToReading];
}

- (void)didSelectBackToReading:(UIButton *)btn {
    
    CGFloat width = self.collectionView.frame.size.width / 3 - 20;
    NSInteger index = (_currentIndexPath.row / 3  > 0) ? _currentIndexPath.row / 3 : 0;
    CGFloat height = (width*1.6 + 10) * index;
    
    if (self.collectionView.contentOffset.y <= height && self.collectionView.contentOffset.y + self.collectionView.frame.size.height >= height) {
        if (_delegate && [_delegate respondsToSelector:@selector(viewerCollectionView:DismissViewController:)]) {
            [_delegate viewerCollectionView:self DismissViewController:_currentIndexPath.row];
        }
        return;
    }
    
    [UIView animateWithDuration:0.3 animations:^{
        [self.collectionView scrollToItemAtIndexPath:_currentIndexPath atScrollPosition:UICollectionViewScrollPositionTop animated:NO];
    } completion:^(BOOL finished){
        if (_delegate && [_delegate respondsToSelector:@selector(viewerCollectionView:DismissViewController:)]) {
            [_delegate viewerCollectionView:self DismissViewController:_currentIndexPath.row];
        }
    }];
}

- (void)setIsProcessingTransition:(BOOL)isProcessingTransition {
    _isProcessingTransition = isProcessingTransition;
    [self.collectionView reloadData];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}


#pragma mark <UICollectionViewFlowLayout>

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
    return UIEdgeInsetsMake(5, 10, 5, 10);
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {

    return _totalItems;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ViewerCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ViewerCollectionViewCell" forIndexPath:indexPath];
    
    if (indexPath.row == _totalItems -1) {
        cell.imv.image = [UIImage imageNamed:@"imageGird"];
        cell.lblNumberOfPage.text = [NSString stringWithFormat:@"%ld",indexPath.row];
    } else {
        cell.imv.image = [UIImage imageNamed:[NSString stringWithFormat:@"image%ld.jpg",(long)indexPath.row%10]];
        cell.lblNumberOfPage.text = [NSString stringWithFormat:@"%ld",indexPath.row];
        
        if (indexPath.row == _currentIndexPath.row) {
            if (_isProcessingTransition) {
                if (_isProcessingInteractiveTransition) {
                    cell.imvBg.hidden = NO;
                } else {
                    cell.imvBg.hidden = YES;
                }
                cell.imv.hidden = YES;
            } else {
                cell.imv.layer.borderWidth = 4;
                cell.imv.layer.borderColor = [UIColor colorWithRed:39/255 green:157/255 blue:255/255 alpha:1].CGColor;
                cell.imv.hidden = NO;
                cell.imvBg.hidden = YES;
            }
            
        } else {
            cell.imvBg.hidden = YES;
            cell.imv.layer.borderWidth = 0;
            cell.imv.hidden = NO;
            cell.imv.backgroundColor = [UIColor clearColor];
        }
        cell.imv.layer.masksToBounds = YES;
    }
    
    return cell;
}

- (CGRect)getFrameCellWithIndexPath:(NSIndexPath*)indexPath {

    UICollectionViewLayoutAttributes *attributes = [self.collectionView layoutAttributesForItemAtIndexPath:indexPath];
    
    return attributes.frame;
}


#pragma mark <UICollectionViewDelegate>

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    _currentIndexPath = indexPath;
    if (_delegate && [_delegate respondsToSelector:@selector(viewerCollectionView:DismissViewController:)]) {
        [_delegate viewerCollectionView:self DismissViewController:indexPath.row];
    }
}


#pragma mark - ViewerTransition Protocal

- (UIImageView *)getImageViewPresentWithInteractive {
    ViewerCollectionViewCell *cell = (ViewerCollectionViewCell*)[self.collectionView cellForItemAtIndexPath:_currentIndexPath];
    if (!cell) {
        CGRect frameView = [self getFrameCellWithIndexPath:_currentIndexPath];
        
        CGRect currentFrameClv = CGRectMake(self.collectionView.contentOffset.x, self.collectionView.contentOffset.y, self.collectionView.frame.size.width, self.collectionView.frame.size.height);
        
        if (!CGRectContainsRect(currentFrameClv,frameView)) {
            [self setContentOffsetForCollectionViewWithCellFrame:frameView];
        }
        
        return [[UIImageView alloc] initWithFrame:frameView];
    }
    
    // ContentOffset For CollectionView
    [self setContentOffsetForCollectionViewWithCellFrame:cell.frame];
    
    CGRect frame = [cell convertRect:cell.imv.frame toView: [self.collectionView superview]];
    
    UIImageView *img = [[UIImageView alloc] initWithFrame:frame];
    img.contentMode = UIViewContentModeScaleAspectFit;
    img.image = cell.imv.image;
    
    return img;
}

-(UIImageView *)getImageViewPresent {
    ViewerCollectionViewCell *cell = (ViewerCollectionViewCell*)[self.collectionView cellForItemAtIndexPath:_currentIndexPath];
    if (!cell) {
        CGRect frameView = [self getFrameCellWithIndexPath:_currentIndexPath];
        
        CGRect currentFrameClv = CGRectMake(self.collectionView.contentOffset.x, self.collectionView.contentOffset.y, self.collectionView.frame.size.width, self.collectionView.frame.size.height);
        
        if (!CGRectContainsRect(currentFrameClv,frameView)) {
            frameView = [self getFrameCellInCollectionViewWithOlfFrame:frameView];
        }
        
        return [[UIImageView alloc] initWithFrame:frameView];
    }
    
    // ContentOffset For CollectionView
    [self setContentOffsetForCollectionViewWithCellFrame:cell.frame];
    
    CGRect frame = [cell convertRect:cell.imv.frame toView: [self.collectionView superview]];
    
    UIImageView *img = [[UIImageView alloc] initWithFrame:frame];
    img.contentMode = UIViewContentModeScaleAspectFit;
    img.image = cell.imv.image;
    
    return img;
}

- (void)setContentOffsetForCollectionViewWithCellFrame:(CGRect)frameCell {
    
    CGFloat newContentOffSetY;
    
    if (frameCell.origin.y + frameCell.size.height > self.collectionView.contentOffset.y + self.collectionView.frame.size.height) {
        
        newContentOffSetY = frameCell.origin.y + frameCell.size.height - self.collectionView.frame.size.height;
        self.collectionView.contentOffset =  CGPointMake(self.collectionView.contentOffset.x, newContentOffSetY > 0 ? newContentOffSetY  : 0);
        
    } else if (frameCell.origin.y < self.collectionView.contentOffset.y + 20) {
       
        newContentOffSetY = frameCell.origin.y > 0 ? frameCell.origin.y : 0;
        
        self.collectionView.contentOffset =  CGPointMake(self.collectionView.contentOffset.x, newContentOffSetY-20);
    }
}

- (CGRect)getFrameCellInCollectionViewWithOlfFrame:(CGRect)frameCell {
    CGRect currentFrame = frameCell;
    CGFloat newContentOffSetY;
    
    if (frameCell.origin.y + frameCell.size.height > self.collectionView.contentOffset.y + self.collectionView.frame.size.height) {
        
        newContentOffSetY = frameCell.origin.y + frameCell.size.height - self.collectionView.frame.size.height;
        self.collectionView.contentOffset =  CGPointMake(self.collectionView.contentOffset.x, newContentOffSetY > 0 ? newContentOffSetY  : 0);
        
        currentFrame.origin.y = currentFrame.origin.y - newContentOffSetY;
        
    } else if (frameCell.origin.y < self.collectionView.contentOffset.y) {
        
        newContentOffSetY = frameCell.origin.y > 0 ? frameCell.origin.y : 0;
        currentFrame.origin.y = 20;
        
        self.collectionView.contentOffset =  CGPointMake(self.collectionView.contentOffset.x, newContentOffSetY-20);
    }
    
    // size lable 20.
    currentFrame.size.height -= 20;

    return currentFrame;
}

#pragma mark - UIScrollDelegate

- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView {
    
}


@end
