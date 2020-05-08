//
//  MainViewController.m
//  FaceUnityExample
//
//  Created by Elf Sundae on 2020/03/23.
//  Copyright © 2020 https://0x123.com. All rights reserved.
//

#import "MainViewController.h"
#import <FaceUnity/FaceUnity.h>
#import <ESFramework/ESFramework.h>
#import "TestViewController.h"

static NSString *const CellReuseIdentifier = @"CellReuseIdentifier";

@interface MainViewController ()

@property (nonatomic, strong) NSArray *data;

@end

@implementation MainViewController

- (instancetype)initWithStyle:(UITableViewStyle)style
{
    return [super initWithStyle:UITableViewStyleGrouped];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = UIApplication.sharedApplication.appDisplayName;

    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:CellReuseIdentifier];

    self.data = @[
        @[
            @{
                @"title": @"美颜设置",
                @"action": NSStringFromSelector(@selector(openBeautySetting)),
            },
        ],
        @[
            @{
                @"title": @"Test",
                @"action": NSStringFromSelector(@selector(openTestViewController)),
            },
        ],
    ];
}

- (NSDictionary *)dataForIndexPath:(NSIndexPath *)indexPath
{
    return self.data[indexPath.section][indexPath.row];
}

- (void)openBeautySetting
{
    [self.navigationController pushViewController:[FUBeautySettingViewController new] animated:YES];
}

- (void)openTestViewController
{
    [self.navigationController pushViewController:[TestViewController new] animated:YES];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.data.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [(NSArray *)self.data[section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellReuseIdentifier forIndexPath:indexPath];

    cell.textLabel.text = [self dataForIndexPath:indexPath][@"title"];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    SEL sel = NSSelectorFromString([self dataForIndexPath:indexPath][@"action"]);
    ESInvokeSelector(self, sel, NULL);
}

@end
