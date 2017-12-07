//
//  SensorFusionViewController.m
//  STSensNet
//
//  Created by Lorenzo Invidia on 04/12/2017.
//  Copyright © 2017 STCentralLab. All rights reserved.
//

#import "SensorFusionViewController.h"

#define SCENE_MODEL_FILE @"art.scnassets/cubeModel.dae"
#define SCENE_MODEL_NAME @"Cube"
#define CUBE_DEFAULT_SCALE 1.5f

@interface SensorFusionViewController ()
//<BlueSTSDKFeatureDelegate>
@end

@implementation SensorFusionViewController


BlueSTSDKFeatureMemsSensorFusion *mSensorFusionFeature;
GLKQuaternion mQuatReset;
SCNScene *mScene;
SCNNode *mObjectNode;


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.featureLabel.text = self.featureLabelText;
    mQuatReset = GLKQuaternionIdentity;
}

///**
// *  retrive and enable the feature needed
// */
//- (void) viewDidAppear:(BOOL)animated {
//    [super viewDidAppear:animated];
//    [self enableSensorFusionNotification];
//}
//
//
///**
// *  get the last data received by the node
// *
// *  @param nodeId nodeId to search
// *
// *  @return data associated to that node
// */
//-(GenericRemoteNodeData*) getNodeData:(uint16_t)nodeId{
//    GenericRemoteNodeData *rData;
//    @synchronized (self.mRemoteNodes) {
//        for(unsigned long i=0;i<self.mRemoteNodes.count;i++){
//            GenericRemoteNodeData *data = [self.mRemoteNodes objectAtIndex:i];
//            if(data.nodeId==nodeId){
//                rData = data;
//            }
//        }
//        return rData;
//    }
//}
//
//
//
//- (void)sceneViewSetup{
//    mScene = [SCNScene sceneNamed:SCENE_MODEL_FILE];
//    mObjectNode = [mScene.rootNode childNodeWithName:SCENE_MODEL_NAME recursively:YES];
//    mObjectNode.scale = SCNVector3Make(CUBE_DEFAULT_SCALE, CUBE_DEFAULT_SCALE, CUBE_DEFAULT_SCALE);
//
//    [self.sceneView prepareObjects:@[mObjectNode] withCompletionHandler:nil];
//    self.sceneView.scene = mScene;
//}
//
//- (void) enableSensorFusionNotification {
//    mSensorFusionFeature = (BlueSTSDKFeatureMemsSensorFusion *)
//    [self.activeNode getFeatureOfType:BlueSTSDKFeatureMemsSensorFusionCompact.class];
//    if(mSensorFusionFeature==nil)
//        mSensorFusionFeature = (BlueSTSDKFeatureMemsSensorFusion*)
//        [self.activeNode getFeatureOfType:BlueSTSDKFeatureMemsSensorFusion.class];
//    if(mSensorFusionFeature!=nil){
//        [mSensorFusionFeature addFeatureDelegate:self];
//        [self.activeNode enableNotification:mSensorFusionFeature];
//    }else{
//        //[self.view makeToast:@"Sensor Fusion NotFound"];
//    }
//}
//
//
//
//- (void) disableSensorFusionNotification {
//    if(mSensorFusionFeature!=nil){
//        [self.activeNode disableNotification:mSensorFusionFeature];
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

@end
