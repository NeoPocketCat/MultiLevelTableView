//
// Created by neo on 2017/11/30.
// Copyright (c) 2017 neo. All rights reserved.
//

#import "TreeMapGridDemoViewController.h"
#import "TreeMapGridView.h"
#import "TreeNode.h"

@interface TreeMapGridDemoViewController () <TreeMapGridViewDataSource, TreeMapGridViewDelegate>

@property(nonatomic, strong) TreeMapGridView *treeMapGridView;
@property(nonatomic, strong) NSArray *treeNodes;
@property(nonatomic, strong) NSDictionary *cellWights;

@end

@implementation TreeMapGridDemoViewController {

}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self prepareData];

    _treeMapGridView = [[TreeMapGridView alloc] initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height - 64)];
    _treeMapGridView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _treeMapGridView.delegate = self;
    _treeMapGridView.dataSource = self;
    [_treeMapGridView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"__cell__"];
    _treeMapGridView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_treeMapGridView];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    CGFloat navigationHeight = self.navigationController.navigationBar.frame.size.height;
    _treeMapGridView.frame = CGRectMake(0, navigationHeight, self.view.frame.size.width, self.view.frame.size.height - navigationHeight);
}


- (void)prepareData {
    NSMutableDictionary *cellWights = [NSMutableDictionary dictionary];
    _cellWights = cellWights;

    NSMutableArray *treeNodes = [NSMutableArray array];
    for (NSUInteger i = 0; i < 2; i++) {
        TreeNode *nodeInLevel0 = [[TreeNode alloc] initWithCustomData:[NSString stringWithFormat:@"(%d,%d)", 0, i]];
        nodeInLevel0.expand = YES;
        cellWights[nodeInLevel0.customData] = @(random());
        NSMutableArray *level1Nodes = [NSMutableArray array];
        for (NSUInteger j = 0; j < 3; j++) {
            TreeNode *nodeInLevel1 = [[TreeNode alloc] initWithCustomData:[NSString stringWithFormat:@"(%d,%d)", 1, j]];
            nodeInLevel1.expand = YES;
            nodeInLevel1.parentNode = nodeInLevel0;
            cellWights[nodeInLevel1.customData] = @(random());
            NSMutableArray *level2Nodes = [NSMutableArray array];
            for (NSUInteger k = 0; k < 2; k++) {
                TreeNode *nodeInLevel2 = [[TreeNode alloc] initWithCustomData:[NSString stringWithFormat:@"(%d,%d)", 2, k]];
                nodeInLevel2.expand = k == 1;
                nodeInLevel2.parentNode = nodeInLevel1;
                cellWights[nodeInLevel2.customData] = @(random());
                if (k != 2) {
                    NSMutableArray *level3Nodes = [NSMutableArray array];
                    for (NSUInteger l = 0; l < 2; l++) {
                        TreeNode *nodeInLevel3 = [[TreeNode alloc] initWithCustomData:[NSString stringWithFormat:@"(%d,%d)", 3, l]];
                        nodeInLevel3.expand = YES;
                        nodeInLevel3.parentNode = nodeInLevel2;
                        cellWights[nodeInLevel3.customData] = @(random());
                        [level3Nodes addObject:nodeInLevel3];
                    }
                    nodeInLevel2.childNodes = level3Nodes;
                }
                [level2Nodes addObject:nodeInLevel2];
                nodeInLevel1.childNodes = level2Nodes;
            }
            [level1Nodes addObject:nodeInLevel1];
        }
        nodeInLevel0.childNodes = level1Nodes;
        [treeNodes addObject:nodeInLevel0];
    }
    _treeNodes = treeNodes;
}

#pragma mark - TreeGridViewDataSource Methods

- (NSArray<TreeNode *> *)gridViewRootCells:(TreeMapGridView *)gridView {
    return _treeNodes;
}

- (UICollectionViewCell *)gridView:(TreeMapGridView *)gridView cellForRowAtTreeNode:(TreeNode *)treeNode {
    UICollectionViewCell *cell = [gridView dequeueReusableCellWithReuseIdentifier:@"__cell__" forTreeNode:treeNode];
    UILabel *label;
    if (cell.subviews.count > 1) {
        label = cell.subviews[1];
    } else {
        label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, cell.contentView.frame.size.width, cell.contentView.frame.size.height)];
        label.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        label.layer.borderWidth = 1;
        [cell.contentView addSubview:label];
    }
    label.text = [NSString stringWithFormat:@"%d, %d", treeNode.level,
                                            treeNode.level == 0 ? [_treeNodes indexOfObject:treeNode] : [treeNode.parentNode.childNodes indexOfObject:treeNode]];
    cell.backgroundColor = [UIColor colorWithRed:((random() % 256) / 255.0f) green:((random() % 256) / 255.0f) blue:((random() % 256) / 255.0f) alpha:1];
    return cell;
}

#pragma mark - TreeGridViewDelegate Methods

- (void)gridView:(TreeMapGridView *)gridView didSelectCell:(TreeNode *)treeNode {

}

- (void)gridViewDidScroll:(TreeMapGridView *)gridView {

}

- (CGFloat)gridView:(TreeMapGridView *)gridView cellWeightForNode:(TreeNode *)treeNode {
    return [_cellWights[treeNode.customData] floatValue];
}

- (CGFloat)gridView:(TreeMapGridView *)gridView heightAtLevel:(NSUInteger)level {
    return 40;
}


@end