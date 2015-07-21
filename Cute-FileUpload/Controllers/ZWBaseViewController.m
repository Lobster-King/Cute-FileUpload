//
//  ZWBaseViewController.m
//  Cute-FileUpload
//
//  Created by qinzhiwei on 15/7/20.
//  Copyright (c) 2015年 qinzhiwei. All rights reserved.
//

#import "ZWBaseViewController.h"
#import "CuteHttpServer.h"

@interface ZWBaseViewController ()<ZWCuteServerDelegate>

@property (nonatomic, retain)CuteHttpServer *server;

@end

@implementation ZWBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Cute-FileUpload";
    
    [self initUI];
    
    // Do any additional setup after loading the view.
}

- (void)initUI{
    
    UIButton *conButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    conButton.layer.borderColor = [UIColor redColor].CGColor;
    [conButton setTitle:@"Connect" forState:UIControlStateNormal];
    conButton.frame = CGRectMake(0, 0, 200, 40);
    conButton.center = self.view.center;
    [conButton addTarget:self action:@selector(handleConnection) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:conButton];
    
}

- (void)handleConnection{
    
    self.server.delegate = self;
    [self.server serverStart];
    
}

- (CuteHttpServer *)server{
    if (!_server) {
        _server = [[CuteHttpServer alloc]init];
    }
    return _server;
}

#pragma mark-- ZWLightWeightDelegate--

- (void)zwServerStartSuccessfullyIpString:(NSString *)ipString port:(NSString *)port{
    
    NSLog(@"ipString:%@ port:%@",ipString,port);
    
}

- (void)zwServerRecivedNewClient:(CuteHttpClient *)client{
    
}

- (void)zwServerStartFailedWithError:(ZWCuteServerErrorCode)error{
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
