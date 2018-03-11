//
// Created by neo on 2017/12/11.
// Copyright (c) 2017 neo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@interface TreeLayerGridCell : NSObject

@property(nonatomic, assign) NSUInteger row;
@property(nonatomic, assign) NSUInteger column;

@property(nonatomic, assign) NSUInteger rowSpan;
@property(nonatomic, assign) NSUInteger columnSpan;

@property(nonatomic, assign) CGRect frame;
@property(nonatomic, strong) NSIndexPath *indexPath;

@property(nonatomic, strong) id customData;

- (instancetype)initWithCustomData:(id)customData;

@end