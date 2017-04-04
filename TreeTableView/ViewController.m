//
//  ViewController.m
//  TreeTableView
//
//  Created by neo on 2017/4/4.
//  Copyright © 2017 neo. All rights reserved.
//

#import "ViewController.h"
#import "TestView.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    TestView *testView = [[TestView alloc] initWithFrame:self.view.frame];
    [self.view addSubview:testView];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
