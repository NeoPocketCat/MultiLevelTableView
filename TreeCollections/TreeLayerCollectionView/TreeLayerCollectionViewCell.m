//
// Created by neo on 2017/12/15.
// Copyright (c) 2017 neo. All rights reserved.
//

#import "TreeLayerCollectionViewCell.h"
#import "TreeLayerCollectionViewLayoutAttributes.h"

@interface TreeLayerCollectionViewCell ()

@property(nonatomic, strong) UIView *maskView;

@end


@implementation TreeLayerCollectionViewCell {

}

- (void)applyLayoutAttributes:(UICollectionViewLayoutAttributes *)layoutAttributes {
    [super applyLayoutAttributes:layoutAttributes];
    TreeLayerCollectionViewLayoutAttributes *treeLayoutAttributes = (TreeLayerCollectionViewLayoutAttributes *) layoutAttributes;
    if (!_maskView) {
        _maskView = [[UIView alloc] init];
        _maskView.backgroundColor = [UIColor whiteColor];
        self.contentView.maskView = _maskView;
        self.clipsToBounds = YES;
        self.contentView.layer.masksToBounds = YES;
    }
    _maskView.frame = treeLayoutAttributes.maskRect;
}


@end