/*
 * Copyright (c) 2017  STMicroelectronics – All rights reserved
 * The STMicroelectronics corporate logo is a trademark of STMicroelectronics
 *
 * Redistribution and use in source and binary forms, with or without modification,
 * are permitted provided that the following conditions are met:
 *
 * - Redistributions of source code must retain the above copyright notice, this list of conditions
 *   and the following disclaimer.
 *
 * - Redistributions in binary form must reproduce the above copyright notice, this list of
 *   conditions and the following disclaimer in the documentation and/or other materials provided
 *   with the distribution.
 *
 * - Neither the name nor trademarks of STMicroelectronics International N.V. nor any other
 *   STMicroelectronics company nor the names of its contributors may be used to endorse or
 *   promote products derived from this software without specific prior written permission.
 *
 * - All of the icons, pictures, logos and other images that are provided with the source code
 *   in a directory whose title begins with st_images may only be used for internal purposes and
 *   shall not be redistributed to any third party or modified in any way.
 *
 * - Any redistributions in binary form shall not include the capability to display any of the
 *   icons, pictures, logos and other images that are provided with the source code in a directory
 *   whose title begins with st_images.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR
 * IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY
 * AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER
 * OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
 * OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY
 * OF SUCH DAMAGE.
 */

#import "SensorFusionViewController.h"

#define SCENE_MODEL_FILE @"art.scnassets/cubeModel.dae"
#define SCENE_MODEL_NAME @"Cube"
#define CUBE_DEFAULT_SCALE 1.5f

@interface SensorFusionViewController ()<BlueSTSDKFeatureDelegate>
@end


@implementation SensorFusionViewController

/**
 *  array of remote node data
 */
NSMutableArray<GenericRemoteNodeData*> *mRemoteNodes;

STSensNetGenericRemoteFeature *mRemoteFeature;
GLKQuaternion mQuatReset;
SCNScene *mScene;
SCNNode *mObjectNode;


- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (self.activeNode) {
        NSLog(@"activeNode is OK !");
    }else {
        NSLog(@"activeNode is nil !");
    }//DEBUG
    
    if (self.nodeId) {
        NSLog(@"nodeId is %@", [NSString stringWithFormat:@"0x%0.4X",self.nodeId]);
    }else {
        NSLog(@"nodeId is nil !");
    }//DEBUG
    

    mRemoteNodes = [NSMutableArray array];
    self.featureLabel.text = self.featureLabelText;
    [self sceneViewSetup];
    mQuatReset = GLKQuaternionIdentity;
}


- (void) viewDidAppear:(BOOL)animated {
//    NSLog(@"viewDidAppear");//DEBUG
    [super viewDidAppear:animated];
    
    mRemoteFeature =(STSensNetGenericRemoteFeature*)
    [self.activeNode getFeatureOfType:STSensNetGenericRemoteFeature.class];
    
    if (mRemoteFeature!=nil){
//        NSLog(@"(mRemoteFeature!=nil");//DEBUG
        
        [mRemoteFeature addFeatureDelegate:self];
        [self.activeNode enableNotification:mRemoteFeature];
        [self sensorFusionNotificationDidChangeForNodeId:self.nodeId newState:true];
        
    }
}


- (void) viewWillDisappear:(BOOL)animated {
//    NSLog(@"viewWillDisappear");//DEBUG
    [super viewWillDisappear:animated];
    
    if(mRemoteFeature!=nil) {
        [self sensorFusionNotificationDidChangeForNodeId:self.nodeId newState:false];
        [mRemoteFeature removeFeatureDelegate:self];
        [self.activeNode disableNotification:mRemoteFeature];
    }
}


- (void)sceneViewSetup{
//    NSLog(@"sceneViewSetup");//DEBUG

    mScene = [SCNScene sceneNamed:SCENE_MODEL_FILE];
    mObjectNode = [mScene.rootNode childNodeWithName:SCENE_MODEL_NAME recursively:YES];
    mObjectNode.scale = SCNVector3Make(CUBE_DEFAULT_SCALE, CUBE_DEFAULT_SCALE, CUBE_DEFAULT_SCALE);
    
    [self.sceneView prepareObjects:@[mObjectNode] withCompletionHandler:nil];
    self.sceneView.scene = mScene;
}


/**
 *  get the last data received by the node, it the node is new we create an empty
 * class
 *
 *  @param nodeId nodeId to search
 *
 *  @return data associated to that node
 */
-(GenericRemoteNodeData*) getNodeData:(uint16_t)nodeId{
    
//    NSLog(@"getNodeData");//DEBUG
    
    @synchronized (mRemoteNodes) {
        for(unsigned long i=0;i<mRemoteNodes.count;i++){
            GenericRemoteNodeData *data = [mRemoteNodes objectAtIndex:i];
            if(data.nodeId==nodeId){
                return data;
            }//if
        }
        //else, it's a new node
        //create a new remote node data
        GenericRemoteNodeData *data =
        [GenericRemoteNodeData initWithNodeId:nodeId];
        
        [mRemoteNodes addObject:data];
        
//        NSLog(@"mRemoteNodes with %lu elements", (unsigned long)mRemoteNodes.count);//DEBUG
        return data;
    }
    
}

#pragma mark - BlueSTSDKFeatureDelegate

/**
 *  update the node data and update the rotation
 *
 *  @param feature feature tha has an update
 *  @param sample  new data sample
 */
- (void)didUpdateFeature:(BlueSTSDKFeature *)feature sample:(BlueSTSDKFeatureSample *)sample{
//    NSLog(@"didUpdateFeature");

    uint16_t nodeId = [STSensNetGenericRemoteFeature getNodeId:sample];
//    NSLog(@"didUF node id: %u", nodeId);
    
    //update the remote data struct
    GenericRemoteNodeData *data = [self getNodeData:nodeId];
    
    data.sFusionQI = [STSensNetGenericRemoteFeature getQi:sample];
    data.sFusionQJ = [STSensNetGenericRemoteFeature getQj:sample];
    data.sFusionQK = [STSensNetGenericRemoteFeature getQk:sample];
    
        GLKQuaternion temp;
        temp.z = -data.sFusionQI;
        temp.y = data.sFusionQJ;
        temp.x = data.sFusionQK;
        temp.w = sqrt(1-((temp.x*temp.x)+(temp.y*temp.y)+(temp.z*temp.z)));
        
        temp = GLKQuaternionMultiply(mQuatReset,temp);
        SCNQuaternion rot;
        rot.x = temp.x;
        rot.y = temp.y;
        rot.z = temp.z;
        rot.w = temp.w;
        dispatch_async(dispatch_get_main_queue(),^{
            mObjectNode.orientation = rot;
        });
}

/**
 * function called when the sensor fusion notification is enabled for a node
 *
 * @param nodeId node where the user enable the notificaiton
 * @param state true if enable the notification, false for disable it
 */
-(void)sensorFusionNotificationDidChangeForNodeId:(uint16_t)nodeId newState:(bool)state{
    [self getNodeData:nodeId].isSensorFusionEnabled=state;
    if(state){
        [mRemoteFeature enableSensorFusionForNode:nodeId enabled:state];
    }else{
        [mRemoteFeature enableSensorFusionForNode:nodeId enabled:false];
    }
}


/**
 * function called when the user press the reset button
 */
- (IBAction)resetPositionAction:(UIButton *)sender {
    BlueSTSDKFeatureSample * data = mRemoteFeature.lastSample;
    mQuatReset.z = -[STSensNetGenericRemoteFeature getQi:data];
    mQuatReset.y = [STSensNetGenericRemoteFeature getQj:data];
    mQuatReset.x = [STSensNetGenericRemoteFeature getQk:data];
    mQuatReset.w = sqrt(1-((mQuatReset.x*mQuatReset.x)+(mQuatReset.y*mQuatReset.y)+(mQuatReset.z*mQuatReset.z)));
    mQuatReset = GLKQuaternionInvert(mQuatReset);
}



@end
