//
//  SensorFusionViewController.m
//  STSensNet
//
//  Created by Lorenzo Invidia on 04/12/2017.
//  Copyright © 2017 STCentralLab. All rights reserved.
//

#import "SensorFusionViewController.h"

@interface SensorFusionViewController ()

@end

@implementation SensorFusionViewController
@synthesize featureLabel, featureLabelText;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.featureLabel.text = featureLabelText;
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
