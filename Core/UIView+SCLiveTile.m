//
//  UIView+SCLiveTile.m
//  SCLiveTileManager
//
//  Created by Maxim Kolesnik on 19/10/15.
//  Copyright © 2016 Sugar and Candy. All rights reserved.
//

#import "UIView+SCLiveTile.h"

static const CGFloat ANIMATION_DURATION = 0.75f;


@implementation UIView (SCLiveTile)

- (void)updateLiveCellWithoutAnimationWithBlock:(SCLiveTileUpdateBlock)updateBlock {
    [self updateLiveCellAnimated:NO animationType:SCLiveTileAnimationTypeNone containerView:nil updateBlock:updateBlock];
}

- (void)updateLiveCellAnimated:(BOOL)animated animationType:(SCLiveTileAnimationType)animationType containerView:(UIView *)container updateBlock:(void (^)(void))updateBlock {
    if (!animated || animationType == SCLiveTileAnimationTypeNone) {
        updateBlock();
        return;
    }
    if (!container.superview) {
        updateBlock();
        return;
    }
    if (animationType == SCLiveTileAnimationTypeFlipHorizontal || animationType == SCLiveTileAnimationTypeFlipVertical || animationType == SCLiveTileAnimationTypeCrossDissolve) {
        NSInteger animationOption = 0;
        if (animationType == SCLiveTileAnimationTypeFlipHorizontal) {
            animationOption = UIViewAnimationOptionTransitionFlipFromLeft;
        }
        if (animationType == SCLiveTileAnimationTypeFlipVertical) {
            animationOption = UIViewAnimationOptionTransitionFlipFromTop;
        }
        if (animationType == SCLiveTileAnimationTypeCrossDissolve) {
            animationOption = UIViewAnimationOptionTransitionCrossDissolve;
        }
        [UIView transitionWithView:container
                          duration:ANIMATION_DURATION
                           options:UIViewAnimationOptionCurveEaseInOut | animationOption
                        animations:^{
                            updateBlock();
                        }
                        completion:nil];
    }
    if (animationType == SCLiveTileAnimationTypeSlideFromRight || animationType == SCLiveTileAnimationTypeSlideFromBottom || animationType == SCLiveTileAnimationTypeSlideFromLeft) {
        UIView *snapshotBefore = [container snapshotViewAfterScreenUpdates:NO];
        [container.superview insertSubview:snapshotBefore aboveSubview:container];
        updateBlock();
        snapshotBefore.frame = container.frame;
        CGFloat delta = 0;
        if (animationType == SCLiveTileAnimationTypeSlideFromRight) {
            delta = snapshotBefore.bounds.size.width;
            container.transform = CGAffineTransformMakeTranslation(-delta, 0);
        }
        if (animationType == SCLiveTileAnimationTypeSlideFromLeft) {
            delta = snapshotBefore.bounds.size.width;
            container.transform = CGAffineTransformMakeTranslation(+delta, 0);
        }
        if (animationType == SCLiveTileAnimationTypeSlideFromBottom) {
            delta = snapshotBefore.bounds.size.height;
            container.transform = CGAffineTransformMakeTranslation(0, -delta);
        }
        [UIView animateWithDuration:ANIMATION_DURATION delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            if (animationType == SCLiveTileAnimationTypeSlideFromRight) {
                snapshotBefore.transform = CGAffineTransformMakeTranslation(delta, 0);
            }
            if (animationType == SCLiveTileAnimationTypeSlideFromLeft) {
                snapshotBefore.transform = CGAffineTransformMakeTranslation(-delta, 0);
            }
            if (animationType == SCLiveTileAnimationTypeSlideFromBottom) {
                snapshotBefore.transform = CGAffineTransformMakeTranslation(0, delta);
            }
            container.transform = CGAffineTransformIdentity;
        } completion:^(BOOL finished) {
            [snapshotBefore removeFromSuperview];
        }];
    }
}

@end
