//
// Created by neo on 2017/12/1.
// Copyright (c) 2017 neo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class TreeNode;
@class TreeMapGridCollectionView;


@interface TreeMapGridLayout : UICollectionViewLayout

@property(nullable, nonatomic, readonly) TreeMapGridCollectionView *collectionView;

@end