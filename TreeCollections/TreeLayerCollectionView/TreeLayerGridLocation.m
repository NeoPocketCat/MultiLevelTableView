//
// Created by neo on 2017/12/29.
// Copyright (c) 2017 neo. All rights reserved.
//

#import "TreeLayerGridLocation.h"


@implementation TreeLayerGridLocation {

}

+ (instancetype)locationWithRow:(NSUInteger)row andColumn:(NSUInteger)column {
    return [[TreeLayerGridLocation alloc] initWithRow:row andColumn:column];
}

- (instancetype)initWithRow:(NSUInteger)row andColumn:(NSUInteger)column {
    self = [super init];
    if (self) {
        _rowIndex = row;
        _columnIndex = column;
    }

    return self;
}

@end