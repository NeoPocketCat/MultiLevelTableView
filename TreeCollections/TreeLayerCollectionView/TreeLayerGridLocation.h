//
// Created by neo on 2017/12/29.
// Copyright (c) 2017 neo. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface TreeLayerGridLocation : NSObject

@property(nonatomic, assign) NSUInteger rowIndex;
@property(nonatomic, assign) NSUInteger columnIndex;

+ (instancetype)locationWithRow:(NSUInteger)row andColumn:(NSUInteger)column;

- (instancetype)initWithRow:(NSUInteger)row andColumn:(NSUInteger)column;

@end