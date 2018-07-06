//
//  PageCollectionViewCell.m
//  ViewerGridMode
//
//  Created by Son Pham on 7/2/18.
//  Copyright © 2018 ThanhSon. All rights reserved.
//

#import "PageCollectionViewCell.h"

#define MAXIMUM_SCALE    3.0
#define MINIMUM_SCALE    1.0

@interface PageCollectionViewCell () <UIGestureRecognizerDelegate, UIScrollViewDelegate>

@property (nonatomic) UIPanGestureRecognizer *panGesture;
@property (nonatomic) UIRotationGestureRecognizer *rotationGesture;

@property (nonatomic) BOOL interactionInProgress;

@end


@implementation PageCollectionViewCell {
    CGFloat currentScale;
    CGFloat oldSizeY;
    CGAffineTransform transformDefault;
    CGAffineTransform transformZoom;
    CGAffineTransform transformRotate;
    CGAffineTransform transformMove;
    
    BOOL _shouldCompleteTransition;
    
}

- (void)awakeFromNib {
    [super awakeFromNib];

    [self configScrollView];
    [self configGesture];
}


#pragma mark - UIScrollView

- (void)configScrollView {
    _scrPageView.delegate = self;
    _scrPageView.contentSize = self.imv.frame.size;
    _scrPageView.scrollEnabled = YES;
    _scrPageView.maximumZoomScale = 3.0;
    _scrPageView.minimumZoomScale = 1;
}

- (UIView*)viewForZoomingInScrollView:(UIScrollView *)aScrollView {
    return self.imv;
}


#pragma mark - ConfigGesture

- (void)configGesture {
    
    [self.imv setUserInteractionEnabled:YES];
    
    // remove gestures
    [self removeGestureRecognizer:_panGesture];
    [self removeGestureRecognizer:_pinchGesture];
    [self removeGestureRecognizer:_rotationGesture];
    
    
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
    
    [self addGestureRecognizer:self.pinchGesture];
    [self addGestureRecognizer:self.panGesture];
    [self addGestureRecognizer:self.rotationGesture];
    
}

- (void)setEnableGesture:(BOOL)enableGesture {
    [self.pinchGesture setEnabled:enableGesture];
    [self.panGesture setEnabled:enableGesture];
    [self.rotationGesture setEnabled:enableGesture];
}


#pragma mark - Handler Gesture

- (void)handlePinch:(UIPinchGestureRecognizer*)gestureRecognizer {
    
    switch (gestureRecognizer.state) {
        case UIGestureRecognizerStateBegan: {
            NSLog(@"%f",gestureRecognizer.velocity);
            if (gestureRecognizer.scale < 1 && gestureRecognizer.velocity < 0) {
                if (!_interactionInProgress ) {
                    if (_delegate && [_delegate respondsToSelector:@selector(pageCollectionViewCell:dismissViewController:)]) {
                        [_delegate pageCollectionViewCell:self dismissViewController:self.indexPage];
                    }
                    _interactionInProgress = YES;
                }

            }
        }
            break;
            
        case UIGestureRecognizerStateChanged: {
            
            if (gestureRecognizer.scale < 3 && gestureRecognizer.scale > 0.4) {
                
//                UIView *pinchView = gestureRecognizer.view;
//                CGRect bounds = pinchView.bounds;
//                CGPoint pinchCenter = [gestureRecognizer locationInView:pinchView];
//                pinchCenter.x -= CGRectGetMidX(bounds);
//                pinchCenter.y -= CGRectGetMidY(bounds);
//                [gestureRecognizer view].transdform = CGAffineTransformScale([gestureRecognizer view].transform, pinchCenter.x, pinchCenter.y);
                
                [gestureRecognizer view].transform = CGAffineTransformScale(CGAffineTransformIdentity, gestureRecognizer.scale, gestureRecognizer.scale);
//
//                CGSize sizeZoom = self.frame.size;
//                sizeZoom.height = self.frame.size.height * gestureRecognizer.scale;
//
//                [_scrPageView setContentSize:gestureRecognizer.view.frame.size];
//                if (_delegate && [_delegate respondsToSelector:@selector(pageCollectionViewCell:isZoomingWithSize:)]) {
//                    [_delegate pageCollectionViewCell:self isZoomingWithSize:sizeZoom];
//                }
//                NSLog(@"%f",gestureRecognizer.scale);
//                gestureRecognizer.scale = 1;
//
                
                if (_interactionInProgress == YES) {
                    if (_interactionInProgress && gestureRecognizer.scale < 1) {
                        CGFloat fraction = fabs((1 - gestureRecognizer.scale) / 0.4);
                        fraction = fminf(fmaxf(fraction, 0.0), 0.7);
                        _shouldCompleteTransition = (fraction > 0.5);
                        if (fraction >= 1.0)
                            fraction = 0.99;
                        
                        if (_delegate && [_delegate respondsToSelector:@selector(pageCollectionViewCell:updateInteractiveTransition:)]) {
                            [_delegate pageCollectionViewCell:self updateInteractiveTransition:fraction];
                        }

                    }
                }
            } else {
                if (gestureRecognizer.scale <= 0.4) {
                    [self setEnableGesture:NO];
                }
            }
        }
            break;
            
        case UIGestureRecognizerStateFailed:
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateEnded: {
            NSLog(@"______");
//           gestureRecognizer.view.transform = CGAffineTransformIdentity;
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

- (void)animationEndGestureWithGesture:(UIPinchGestureRecognizer *)gesture {
    
    if (_shouldCompleteTransition) {
        _shouldCompleteTransition = NO;
        _interactionInProgress = NO;
        if (_delegate && [_delegate respondsToSelector:@selector(pageCollectionViewCell: andGesture:finishInteractiveTransition:)]) {
            [_delegate pageCollectionViewCell:self andGesture:gesture finishInteractiveTransition:YES];
        }
        
    } else {
        
        if (_delegate && [_delegate respondsToSelector:@selector(pageCollectionViewCell: andGesture:finishInteractiveTransition:)]) {
            [_delegate pageCollectionViewCell:self andGesture:gesture finishInteractiveTransition:NO];
        }
        
        UIView *currentView = self.pinchGesture.view;
        _interactionInProgress = NO;
        
        [UIView animateWithDuration:1 delay:0.0 usingSpringWithDamping:0.9 initialSpringVelocity:gesture.velocity options:UIViewAnimationOptionCurveEaseInOut animations:^{
            [self setEnableGesture:NO];
            currentView.transform = CGAffineTransformIdentity;
        } completion:^(BOOL finished) {
            [self setEnableGesture:YES];
            //[self.view removeGestureRecognizer:_panGestureVC];
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


#pragma mark - UIScrollViewDelegate

- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view {
    NSLog(@"%f",scrollView.pinchGestureRecognizer.velocity);
//    oldSizeY = self.imv.frame.size.width;
     oldSizeY = self.frame.size.height;
    if ((scrollView.pinchGestureRecognizer.velocity < 0 && scrollView.pinchGestureRecognizer.scale <= 1.0 ) && scrollView.zoomScale == 1 && scrollView == _scrPageView) {
        [scrollView.pinchGestureRecognizer setEnabled:NO];
    }
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {

    NSLog(@"%f",oldSizeY);
    CGSize sizeZoom = self.frame.size;
    sizeZoom.height = oldSizeY * scrollView.pinchGestureRecognizer.scale;

    if (sizeZoom.height < 1500 || sizeZoom.height > 100) {
        if (_delegate && [_delegate respondsToSelector:@selector(pageCollectionViewCell:isZoomingWithSize:)]) {
            [_delegate pageCollectionViewCell:self isZoomingWithSize:sizeZoom];
        }
    } else {
        [scrollView.pinchGestureRecognizer setEnabled:NO];
    }
    


}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale  {
    if (scrollView == _scrPageView) {
        [scrollView.pinchGestureRecognizer setEnabled:YES];
    }
}

- (UICollectionViewLayoutAttributes *)preferredLayoutAttributesFittingAttributes:(UICollectionViewLayoutAttributes *)layoutAttributes {
//    _scrPageView.pinchGestureRecognizer.scale = 1;
    return layoutAttributes;
}

@end
