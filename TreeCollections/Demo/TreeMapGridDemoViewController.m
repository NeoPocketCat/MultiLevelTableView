//
// Created by neo on 2017/11/30.
// Copyright (c) 2017 neo. All rights reserved.
//

#import "TreeMapGridDemoViewController.h"
#import "TreeMapGridView.h"
#import "TreeNode.h"

@interface TreeMapGridDemoViewController () <TreeMapGridViewDataSource, TreeMapGridViewDelegate>

@property(nonatomic, strong) NSArray *treeNodes;

@end

@implementation TreeMapGridDemoViewController {

}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self prepareData];

    TreeMapGridView *treeGridView = [[TreeMapGridView alloc] initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height - 64)];
    treeGridView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    treeGridView.delegate = self;
    treeGridView.dataSource = self;
    [treeGridView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"__cell__"];
    treeGridView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:treeGridView];
}

- (void)prepareData {
    NSMutableArray *treeNodes = [NSMutableArray array];
    for (NSUInteger i = 0; i < 2; i++) {
        TreeNode *nodeInLevel0 = [[TreeNode alloc] init];
        nodeInLevel0.expand = YES;
        NSMutableArray *level1Nodes = [NSMutableArray array];
        for (NSUInteger j = 0; j < 3; j++) {
            TreeNode *nodeInLevel1 = [[TreeNode alloc] init];
            nodeInLevel1.expand = j == 1;
            nodeInLevel1.parentNode = nodeInLevel0;
            if (j != 2) {
                NSMutableArray *level2Nodes = [NSMutableArray array];
                for (NSUInteger k = 0; k < 2; k++) {
                    TreeNode *nodeInLevel2 = [[TreeNode alloc] init];
                    nodeInLevel2.expand = YES;
                    nodeInLevel2.parentNode = nodeInLevel1;
                    [level2Nodes addObject:nodeInLevel2];
                }
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
    return cell;
}

#pragma mark - TreeGridViewDelegate Methods

- (void)gridView:(TreeMapGridView *)gridView didSelectCell:(TreeNode *)treeNode {

}

- (void)gridViewDidScroll:(TreeMapGridView *)gridView {

}

- (CGFloat)gridView:(TreeMapGridView *)gridView cellWeightForNode:(TreeNode *)treeNode {
    return 1;
}

- (CGFloat)gridView:(TreeMapGridView *)gridView heightAtLevel:(NSUInteger)level {
    return 40;
}


@end