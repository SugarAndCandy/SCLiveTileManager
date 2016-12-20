//
//  SCLiveTileManager.h
//  SCLiveTileManager
//
//  Created by Maxim Kolesnik on 19/10/15.
//  Copyright © 2016 Sugar and Candy. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^SCLiveTileUpdateBlock)(void);

typedef NS_ENUM(NSUInteger, SCLiveTileAnimationType) {
    SCLiveTileAnimationTypeFlipVertical = 0,
    SCLiveTileAnimationTypeFlipHorizontal = 1,
    SCLiveTileAnimationTypeSlideFromRight = 2,
    SCLiveTileAnimationTypeSlideFromLeft = 3,
    SCLiveTileAnimationTypeSlideFromBottom = 4,
    SCLiveTileAnimationTypeCrossDissolve = 5,
    SCLiveTileAnimationTypeRandom = 99,
    SCLiveTileAnimationTypeNone = 999,
};

@class SCLiveTileManager;


@protocol SCLiveTileUpdating <NSObject>

@required

- (void)updateLiveCellAnimated:(BOOL)animated
                      animationType:(SCLiveTileAnimationType)type
                      containerView:(UIView *)container
                        updateBlock:(SCLiveTileUpdateBlock)updateBlock;
- (void)updateLiveCellWithoutAnimationWithBlock:(SCLiveTileUpdateBlock)updateBlock;

@end


@protocol SCLiveTileManagerDelegate <NSObject>

@optional

- (void)updateCell:(id<SCLiveTileUpdating>)cell
           atIndex:(NSUInteger)index;
- (SCLiveTileAnimationType)animationTypeForCellAtIndex:(NSUInteger)index;
- (BOOL)liveTileManager:(SCLiveTileManager *)manager
       cellShouldUpdate:(id<SCLiveTileUpdating>)cell
                atIndex:(NSUInteger)index;
- (void)managerWillUpdateCell:(id<SCLiveTileUpdating>)cell
                      atIndex:(NSUInteger)index;
- (void)managerDidUpdateCell:(id<SCLiveTileUpdating>)cell
                     atIndex:(NSUInteger)index;
- (BOOL)managerShouldSkipCellUpdate:(id<SCLiveTileUpdating>)cell
                            atIndex:(NSUInteger)index;
- (void)updateDataForCellAtIndex:(NSUInteger)index;
- (UIView *)containerViewForCellUpdate:(id<SCLiveTileUpdating>)cell
                               atIndex:(NSUInteger)index;

@end


@interface SCLiveTileManager : NSObject

@property (nonatomic, weak) id<SCLiveTileManagerDelegate> delegate;

+ (instancetype)managerWithNumberOfTiles:(NSInteger)numberOfTiles delegate:(id<SCLiveTileManagerDelegate>)delegate;
- (void)startUpdating;
- (void)stopUpdating;
- (void)setTileVisibleAtIndex:(NSInteger)index withReferenceCell:(id<SCLiveTileUpdating>)cell;
- (void)setTileNotVisibleAtIndex:(NSInteger)index;

@end
