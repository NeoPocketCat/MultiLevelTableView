//
//  MainViewController.m
//  FineNativeBIModule
//
//  Created by neo on 2017/11/26.
//  Copyright © 2017 neo. All rights reserved.
//

#import "MainViewController.h"
#import "TreeTableDemoViewController.h"
#import "TreeMapGridDemoViewController.h"
#import "TreeLayerDemoViewController.h"

static NSArray *demoList;

static NSDictionary *demoViewClassDict;

@interface MainViewController () <UITableViewDelegate, UITableViewDataSource>

@end

@implementation MainViewController

+ (void)load {
    [super load];
    demoList =
            @[
                    @"TreeTableView",
                    @"TreeMap",
                    @"TreeLayer-CollectionView"
            ];

    demoViewClassDict =
            @{
                    @"TreeTableView": [TreeTableDemoViewController class],
                    @"TreeMap": [TreeMapGridDemoViewController class],
                    @"TreeLayer-CollectionView": [TreeLayerDemoViewController class],

            };
}


- (void)viewDidLoad {
    [super viewDidLoad];
    UITableView *tableDemoTableView = [[UITableView alloc] initWithFrame:self.view.bounds];
    tableDemoTableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    tableDemoTableView.delegate = self;
    tableDemoTableView.dataSource = self;
    [self.view addSubview:tableDemoTableView];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return demoList.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 40;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] init];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    cell.textLabel.text = demoList[indexPath.row];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UIViewController *demoViewController = [demoViewClassDict[demoList[indexPath.row]] new];
    [self.navigationController pushViewController:demoViewController animated:YES];
}


@end
