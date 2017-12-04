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

<<<<<<< HEAD
BlueSTSDKFeatureMemsSensorFusion *mSensorFusionFeature;
GLKQuaternion mQuatReset;
SCNScene *mScene;
SCNNode *mObjectNode;


- (void)viewDidLoad {
    [super viewDidLoad];
    self.featureLabel.text = featureLabelText;
    mQuatReset = GLKQuaternionIdentity;
}


//- (void)sceneViewSetup{
//    mScene = [SCNScene sceneNamed:SCENE_MODEL_FILE];
//    mObjectNode = [mScene.rootNode childNodeWithName:SCENE_MODEL_NAME recursively:YES];
//    mObjectNode.scale = SCNVector3Make(CUBE_DEFAULT_SCALE, CUBE_DEFAULT_SCALE, CUBE_DEFAULT_SCALE);
//
//    [self.sceneView prepareObjects:@[mObjectNode] withCompletionHandler:nil];
//    self.sceneView.scene = mScene;
//}


//- (void) enableSensorFusionNotification {
//    mSensorFusionFeature = (BlueSTSDKFeatureMemsSensorFusion *)
//    [self.node getFeatureOfType:BlueSTSDKFeatureMemsSensorFusionCompact.class];
//    if(mSensorFusionFeature==nil)
//        mSensorFusionFeature = (BlueSTSDKFeatureMemsSensorFusion*)
//        [self.node getFeatureOfType:BlueSTSDKFeatureMemsSensorFusion.class];
//    if(mSensorFusionFeature!=nil){
//        [mSensorFusionFeature addFeatureDelegate:self];
//        [self.node enableNotification:mSensorFusionFeature];
//    }else{
//        //[self.view makeToast:@"Sensor Fusion NotFound"];
//    }
//}


//- (void) viewDidAppear:(BOOL)animated {
//    [super viewDidAppear:animated];
//    [self enableSensorFusionNotification];
//}


//- (void) disableSensorFusionNotification {
//    if(mSensorFusionFeature!=nil){
//        [self.node disableNotification:mSensorFusionFeature];
//        [mSensorFusionFeature removeFeatureDelegate:self];
//    }
//}
//
//
//- (void) viewWillDisappear:(BOOL)animated {
//    [super viewWillDisappear:animated];
//    [self disableSensorFusionNotification];
//}
//
//
//// Update Rotation method
//-(void) updateRotation:(BlueSTSDKFeatureSample*)sample{
//    GLKQuaternion temp;
//    temp.z = -[BlueSTSDKFeatureMemsSensorFusionCompact getQi:sample];
//    temp.y = [BlueSTSDKFeatureMemsSensorFusionCompact getQj:sample];
//    temp.x = [BlueSTSDKFeatureMemsSensorFusionCompact getQk:sample];
//    temp.w = [BlueSTSDKFeatureMemsSensorFusionCompact getQs:sample];
//    temp = GLKQuaternionMultiply(mQuatReset,temp);
//    SCNQuaternion rot;
//    rot.x = temp.x;
//    rot.y = temp.y;
//    rot.z = temp.z;
//    rot.w = temp.w;
//    dispatch_async(dispatch_get_main_queue(),^{
//        mObjectNode.orientation = rot;
//    });
//}
//
//
//#pragma mark - BlueSTSDKFeatureDelegate
//- (void)didUpdateFeature:(BlueSTSDKFeature *)feature sample:(BlueSTSDKFeatureSample *)sample{
//    if(feature == mSensorFusionFeature)
//        [self updateRotation:sample];
//}
=======
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
>>>>>>> parent of 0652255... Basic SensorFusion implementation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
