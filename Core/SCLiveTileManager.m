//
//  SCLiveTileManager.m
//  SCLiveTileManager
//
//  Created by Maxim Kolesnik on 19/10/15.
//  Copyright © 2016 Sugar and Candy. All rights reserved.
//

#import "SCLiveTileManager.h"

static const NSTimeInterval MIN_UPDATE_TIME = 3;
static const NSTimeInterval MAX_UPDATE_TIME = 20;
static const NSTimeInterval UPDATE_INTERVAL = 0.1;

@interface SCLiveTileObject : NSObject

@property (nonatomic, assign) BOOL shouldUpdate;
@property (nonatomic, weak) id<SCLiveTileUpdating> cellReference;
@property (nonatomic, assign, getter=isVisible) BOOL visible;
@property (nonatomic, assign) NSTimeInterval timeToNextUpdate;
@property (nonatomic, assign) SCLiveTileAnimationType animationType;

- (void)setRandomTimeToNextUpdate;

@end


@implementation SCLiveTileObject

- (instancetype)init {
    self = [super init];
    if (self) {
        self.timeToNextUpdate = 10;
    }
    return self;
}

- (void)setRandomTimeToNextUpdate {
    NSTimeInterval time = arc4random_uniform(MAX_UPDATE_TIME);
    srand48(arc4random());
    double delta = drand48();
    time = MAX(time, MIN_UPDATE_TIME);
    self.timeToNextUpdate = time + delta;
}

- (void)setAnimationType:(SCLiveTileAnimationType)animationType {
    if (animationType == SCLiveTileAnimationTypeRandom) {
        _animationType = (NSUInteger)(arc4random() % 5);
    } else {
        _animationType = animationType;
    }
}

@end


@interface SCLiveTileManager ()

@property (nonatomic, strong) NSMutableArray<SCLiveTileObject *> *liveTiles;
@property (nonatomic, strong) NSTimer *updateTimer;

@end


@implementation SCLiveTileManager

+ (instancetype)managerWithNumberOfTiles:(NSInteger)numberOfTiles delegate:(id<SCLiveTileManagerDelegate>)delegate {
    NSAssert(delegate, @"SCLiveTileManager should not be initialised without a delegate");
    SCLiveTileManager *manager = [super new];
    if (manager) {
        NSMutableArray *array = [NSMutableArray new];
        for (NSInteger i = 0; i < numberOfTiles; i++) {
            [array addObject:[[SCLiveTileObject alloc] init]];
        }
        manager.liveTiles = [array copy];
        manager.delegate = delegate;
        [manager setRandomUpdateTimesToAllLiveTiles];
    }
    return manager;
}

- (void)setRandomUpdateTimesToAllLiveTiles {
    if (!self.liveTiles) {
        return;
    }
    for (SCLiveTileObject *tile in self.liveTiles) {
        [tile setRandomTimeToNextUpdate];
        if (self.delegate && [self.delegate respondsToSelector:@selector(liveTileManager:cellShouldUpdate:atIndex:)]) {
            tile.shouldUpdate = [self.delegate liveTileManager:self cellShouldUpdate:tile.cellReference atIndex:[self.liveTiles indexOfObject:tile]];
        } else {
            tile.shouldUpdate = NO;
        }
        if (self.delegate && [self.delegate respondsToSelector:@selector(animationTypeForCellAtIndex:)]) {
            tile.animationType = [self.delegate animationTypeForCellAtIndex:[self.liveTiles indexOfObject:tile]];
        } else {
            tile.animationType = SCLiveTileAnimationTypeNone;
        }
    }
}

#pragma mark - LiveTiles Visibility

- (void)setTileVisibleAtIndex:(NSInteger)index withReferenceCell:(id<SCLiveTileUpdating>)cell {
    if (!self.liveTiles) {
        return;
    }
    SCLiveTileObject *tile = [self.liveTiles objectAtIndex:index];
    if (tile) {
        tile.visible = YES;
        tile.cellReference = cell;
    }
}

- (void)setTileNotVisibleAtIndex:(NSInteger)index {
    if (!self.liveTiles) {
        return;
    }
    SCLiveTileObject *tile = [self.liveTiles objectAtIndex:index];
    if (tile) {
        tile.visible = NO;
        tile.cellReference = nil;
    }
}

#pragma mark - Timer

- (void)startUpdating {
    if (self.updateTimer) {
        [self.updateTimer invalidate];
        self.updateTimer = nil;
    }
    self.updateTimer = [NSTimer timerWithTimeInterval:UPDATE_INTERVAL target:self selector:@selector(timerTick) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:self.updateTimer forMode:NSRunLoopCommonModes];
}

- (void)stopUpdating {
    [self.updateTimer invalidate];
    self.updateTimer = nil;
}

- (void)timerTick {
    for (SCLiveTileObject *tile in self.liveTiles) {
        NSUInteger index = [self.liveTiles indexOfObject:tile];
        if (!tile.shouldUpdate) {
            continue;
        }
        tile.timeToNextUpdate -= UPDATE_INTERVAL;
        if (tile.timeToNextUpdate <= 0) {
            //time to next update has elapsed.
            //set new time.
            [tile setRandomTimeToNextUpdate];
            if (self.delegate && [self.delegate respondsToSelector:@selector(managerShouldSkipCellUpdate:atIndex:)]) {
                if ([self.delegate managerShouldSkipCellUpdate:tile.cellReference atIndex:index]) {
                    continue;
                }
            }
            
            // call a delegate to update the data.
            if (self.delegate && [self.delegate respondsToSelector:@selector(updateDataForCellAtIndex:)]) {
                [self.delegate updateDataForCellAtIndex:index];
            }
            if (!tile.isVisible)
                continue;
            
            //perform actual update on cell
            if (self.delegate && [self.delegate respondsToSelector:@selector(updateCell:atIndex:)]) {
                // send willUpdate call to delegate
                if (self.delegate && [self.delegate respondsToSelector:@selector(managerWillUpdateCell:atIndex:)]) {
                    [self.delegate managerWillUpdateCell:tile.cellReference atIndex:index];
                }
                UIView *container = nil;
                if (self.delegate && [self.delegate respondsToSelector:@selector(containerViewForCellUpdate:atIndex:)]) {
                    container = [self.delegate containerViewForCellUpdate:tile.cellReference atIndex:index];
                }
                [tile.cellReference updateLiveCellAnimated:YES
                                                  animationType:tile.animationType
                                                  containerView:container
                                                    updateBlock:^{
                                                        [self.delegate updateCell:tile.cellReference atIndex:index];
                                                    }];
                
                //did update
                if (self.delegate && [self.delegate respondsToSelector:@selector(managerDidUpdateCell:atIndex:)]) {
                    [self.delegate managerDidUpdateCell:tile.cellReference atIndex:index];
                }
            }
        }
    }
}

@end
