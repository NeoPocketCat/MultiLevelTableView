//
// Created by neo on 2017/12/8.
// Copyright (c) 2017 neo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class TreeLayerCollectionView;


@interface TreeLayerLayout : UICollectionViewLayout

@property(nullable, nonatomic, readonly) TreeLayerCollectionView *collectionView;

@property(nonatomic, assign) BOOL fixLeveledRowHeader;

@end