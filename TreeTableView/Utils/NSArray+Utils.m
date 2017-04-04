//
// Created by neo on 2017/3/1.
// Copyright (c) 2017 neo. All rights reserved.
//

#import "NSArray+Utils.h"


@implementation NSArray (Utils)

- (id)if_objectAtIndex:(NSUInteger)index {
    if (index < 0 || index >= [self count]) {
        return nil;
    }
    return self[index];
}

@end
