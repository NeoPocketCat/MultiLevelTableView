//
// Created by neo on 2017/12/15.
// Copyright (c) 2017 neo. All rights reserved.
//

#import "TreeLayerCollectionViewLayoutAttributes.h"


@implementation TreeLayerCollectionViewLayoutAttributes {

}

- (NSInteger)zIndex {
    return super.zIndex;
}

- (id)copyWithZone:(nullable NSZone *)zone {
    TreeLayerCollectionViewLayoutAttributes *copy = [super copyWithZone:zone];

    if (copy != nil) {
        copy.maskRect = self.maskRect;
    }

    return copy;
}

- (BOOL)isEqual:(TreeLayerCollectionViewLayoutAttributes *)other {
    return [super isEqual:other] && CGRectEqualToRect(_maskRect, other.maskRect);
}


@end