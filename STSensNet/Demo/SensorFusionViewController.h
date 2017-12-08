//
//  SensorFusionViewController.h
//  STSensNet
//
//  Created by Lorenzo Invidia on 04/12/2017.
//  Copyright © 2017 STCentralLab. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GenericRemoteNodeData.h"
#import <BlueSTSDK/BlueSTSDKNode.h>
#import <SceneKit/SceneKit.h>
#import <GLKit/GLKit.h>
#import <BlueSTSDK_Gui/MBProgressHUD.h>
#import <BlueSTSDK/BlueSTSDKFeatureMemsSensorFusionCompact.h>


@interface SensorFusionViewController : UIViewController

/*
 *  The active central node
 */
@property (retain, nonatomic) BlueSTSDKNode *activeNode;

/*
 *  The active remote node id
 */
@property uint16_t * nodeId;

/*
 *  The active remote node
 */
@property (retain, nonatomic) GenericRemoteNodeData * mRemoteNode;


@property (weak, nonatomic) IBOutlet UILabel *featureLabel;
@property (strong, nonatomic) NSString * featureLabelText;

@property (weak, nonatomic) IBOutlet SCNView *sceneView;

@end
