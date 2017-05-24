//
//  ViewController.m
//  TagSelectorView
//
//  Created by 樊少华 on 09/03/2017.
//  Copyright © 2017 camoufleur. All rights reserved.
//

#import "ViewController.h"
#import "TagSelectorView.h"
#import <YYKit.h>

@interface ViewController ()

@property (nonatomic, strong) TagSelectorModel *model;
@property (nonatomic, strong) TagSelectorView *tsView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadData];
}

- (void)loadData {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Untitled.plist" ofType:nil];
    NSData *data = [NSData dataWithContentsOfFile:path];
    NSDictionary *dict = [NSDictionary dictionaryWithPlistData:data];
    _model = [TagSelectorModel modelWithDictionary:dict];
}

- (IBAction)showSelectorView:(UIBarButtonItem *)sender {
    if (_tsView) {
        [_tsView showSelectorView];
    } else {
        _tsView = [TagSelectorView showSelectorWithSelectorModel:_model completion:^(NSArray<TagSelectorModel *> *modelArray) {
            NSLog(@"%@--%@", modelArray[0].title, modelArray[1].title);
        }];
    }
}

@end
