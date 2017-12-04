//
//  SensorFusionViewController.h
//  STSensNet
//
//  Created by Lorenzo Invidia on 04/12/2017.
//  Copyright © 2017 STCentralLab. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SceneKit/SceneKit.h>
#import "GenericRemoteNodeTableViewController.h"

@interface SensorFusionViewController : GenericRemoteNodeTableViewController
@property (weak, nonatomic) IBOutlet UILabel *featureLabel;
@property (strong, nonatomic) NSString * featureLabelText;
@property (weak, nonatomic) IBOutlet SCNView *sceneView;

@end
