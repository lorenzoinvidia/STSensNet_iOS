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

#include <float.h>
#include <libkern/OSAtomic.h>
#import "PlotFeatureViewController.h"


#define Y_AXIS_BORDER 0.1f
#define Y_NAME @"Time (ms)"
#define MS_TO_TIMESTAMP_SCALE 10
#define MAX_PLOT_UPDATE_DIFF_MS 500

#define ACC_LABEL @"Accelerometer"
#define GYRO_LABEL @"Gyroscope"
#define MAG_LABEL @"Magnetometer"

#define DEFAULT_TIME_STAMP_RANGE (10*1000) //10ms

#define ACCELERATION_X_INDEX 9
#define ACCELERATION_Y_INDEX 10
#define ACCELERATION_Z_INDEX 11
#define GYROSCOPE_X_INDEX 12
#define GYROSCOPE_Y_INDEX 13
#define GYROSCOPE_Z_INDEX 14
#define MAGNETOMETER_X_INDEX 15
#define MAGNETOMETER_Y_INDEX 16
#define MAGNETOMETER_Z_INDEX 17




@interface PlotFeatureViewController ()<BlueSTSDKFeatureDelegate, CPTPlotDataSource>
@end

@implementation PlotFeatureViewController {
    
    //queue where we schedule a task each MAX_PLOT_UPDATE_DIFF_MS, if the data aren't update
    // the task will insert again the last value
    dispatch_queue_t mForcePlotUpdateQueue;
    
    //queue used for serialize the access to the ploted data, we move the computation
    //outside the main queue
    dispatch_queue_t mSerializePlotUpdateQueue;
    
    //time of the last update of the data
    double mLastDataUpdate;
   
    //time of the last graph plotting, we fix the plot update time to 30fps
    double mLastPlotUpdate;
    
    unsigned int SELECTED_FEATURE_INDEX;
    
    
    //number of fake data insert from the last fresh data, this index is used for compute
    // the fake data timestamp
    uint32_t mNForcedUpdate; //check this <----------------------

    
    int64_t mFirstTimeStamp;
    int64_t mLastTimeStamp;
    
    // range of timestamp to plot
    uint32_t mTimestampRange;
    NSNumber *mTimestampRangeDecimal;
    
    bool mAutomaticRange; // true if we have to automaticaly update the y
    CPTXYGraph *mGraph; //graph where plot the feature
    
    NSMutableArray * mPlotDataY; //data plotted Y
    NSMutableArray * mPlotDataX; //data plotted X
    NSMutableArray * tempY;

}


NSMutableArray<GenericRemoteNodeData*> * mRemNodes; //array of remote node data
STSensNetGenericRemoteFeature * mRemFeature; //feature object


//color used for plot the data lines
static NSArray *sLineColor;
static NSNumber *sZero;



+ (void)initialize{
    if(self == [PlotFeatureViewController class]){
        sLineColor = @[ [CPTColor greenColor],
                        [CPTColor blueColor],
                        [CPTColor redColor],
                        [CPTColor yellowColor],
                        [CPTColor purpleColor],
                        [CPTColor purpleColor],
                        ];
        sZero =[NSDecimalNumber zero];
    }//if
}//initialize


+(bool)getBoundaryForFeature:(BlueSTSDKFeature*)f min:(float*)min max:(float*)max{
    if ([f isKindOfClass:[STSensNetGenericRemoteFeature class]]) {
        return true;
    }
    return false;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (self.plotView) {
        NSLog(@"plotView is OK !");
    }else {
        NSLog(@"plotView is nil !");
    }//DEBUG
    
    
    //initialize
    mRemNodes = [NSMutableArray array];
    self.featureLabel.text = self.featureLabelText;
    mTimestampRange = DEFAULT_TIME_STAMP_RANGE;
    
    
    mForcePlotUpdateQueue = dispatch_queue_create("ForcePlotUpdateQueue", DISPATCH_QUEUE_SERIAL);
    mSerializePlotUpdateQueue = dispatch_queue_create("SerializePlotUpdateQueue", DISPATCH_QUEUE_SERIAL);
    mLastPlotUpdate = -1;
    mNForcedUpdate = 0;
}


- (void)viewWillAppear:(BOOL)animated {
    NSLog(@"viewWillAppear");//DEBUG
    [super viewWillAppear:animated];
    
    //initialize the plot
    [self initPlotView]; //if there are problems put this line in viewDidAppear <-----------------
}


- (void)viewDidAppear:(BOOL)animated {
    NSLog(@"viewDidAppear");//DEBUG
    [super viewDidAppear:animated];
    
    mRemFeature =(STSensNetGenericRemoteFeature*)
    [self.activeNode getFeatureOfType:STSensNetGenericRemoteFeature.class];
    
    if(mRemFeature!=nil){
        NSLog(@"mRemFeature!=nil");//DEBUG
        
        // startPlotFeature methods
        mTimestampRangeDecimal = @(-(int32_t) mTimestampRange);
        mFirstTimeStamp=-1;
        
        //update the graph for plot the new feature
        [self setUpPlotViewForFeature:mRemFeature];
        
        [mRemFeature addFeatureDelegate:self];
        [self.activeNode enableNotification:mRemFeature];
        
        //select for feature
        if ([self.featureLabelText isEqualToString:ACC_LABEL]) {
            NSLog(@"%@", ACC_LABEL);
            [self accelerationNotificationDidChangeForNodeId:self.nodeId newState:true];
        }
 
        if ([self.featureLabelText isEqualToString:GYRO_LABEL]) {
                NSLog(@"%@", GYRO_LABEL);
            [self gyroscopeNotificationDidChangeForNodeId:self.nodeId newState:true];
        }
        
        if ([self.featureLabelText isEqualToString:MAG_LABEL]) {
            NSLog(@"%@", MAG_LABEL);
            [self magnetometerNotificationDidChangeForNodeId:self.nodeId newState:true];
        }
        
    }
}



- (void)viewWillDisappear:(BOOL)animated{
    NSLog(@"viewWillDisappear");//DEBUG
    [super viewWillDisappear:animated];
    
    if (mRemFeature != nil) {
    
        //disable all notification
        [self accelerationNotificationDidChangeForNodeId:self.nodeId newState:false];
        [self gyroscopeNotificationDidChangeForNodeId:self.nodeId newState:false];
        [self magnetometerNotificationDidChangeForNodeId:self.nodeId newState:false];
        [mRemFeature removeFeatureDelegate:self];
        [self.activeNode disableNotification:mRemFeature];

    }
    mRemFeature = nil;
}



/**
 *  get the last data received by the node, it the node is new we create an empty
 *  class
 *
 *  @param nodeId nodeId to search
 *
 *  @return data associated to that node
 */
-(GenericRemoteNodeData*) getNodeData:(uint16_t)nodeId{
    
    NSLog(@"getNodeData");//DEBUG
    
    @synchronized (mRemNodes) {
        for(unsigned long i=0;i<mRemNodes.count;i++){
            GenericRemoteNodeData *data = [mRemNodes objectAtIndex:i];
            if(data.nodeId==nodeId){
                return data;
            }//if
        }
        //else, it's a new node
        //create a new remote node data
        GenericRemoteNodeData *data =
        [GenericRemoteNodeData initWithNodeId:nodeId];
        
        [mRemNodes addObject:data];
        
        //NSLog(@"mRemNodes with %lu elements", (unsigned long)mRemNodes.count);//DEBUG
        return data;
    }
    
}



/**
 *  get a custom sample data from the selected feature
 *
 *  @param nodeId nodeId to search
 *
 *  @return sample data associated
 */
- (NSArray *)getCustomData:(uint16_t)nodeId{
    int tempX = 0;
    int tempY = 0;
    int tempZ = 0;
    NSArray<NSNumber *> * tempData = [[NSArray alloc] init];
    
    if ([self.featureLabelText isEqualToString:ACC_LABEL]) {
        tempX = [self getNodeData:nodeId].accelerationX;
        tempY = [self getNodeData:nodeId].accelerationY;
        tempZ = [self getNodeData:nodeId].accelerationZ;
    }
    
    if ([self.featureLabelText isEqualToString:GYRO_LABEL]) {
        tempX = [self getNodeData:nodeId].gyroscopeX;
        tempY = [self getNodeData:nodeId].gyroscopeY;
        tempZ = [self getNodeData:nodeId].gyroscopeZ;
    }
    if ([self.featureLabelText isEqualToString:MAG_LABEL]) {
        tempX = [self getNodeData:nodeId].magnetometerX;
        tempY = [self getNodeData:nodeId].magnetometerY;
        tempZ = [self getNodeData:nodeId].magnetometerZ;
    }
    
    tempData = @[@(tempX), @(tempY), @(tempZ)];
    
    return tempData;
}



- (void)initPlotView {
//    NSLog(@"initPlotView");//DEBUG
    
    self.plotView.allowPinchScaling = false;
    self.plotView.collapsesLayers = true;
    
    // Grid line styles
    CPTMutableLineStyle *majorGridLineStyle = [CPTMutableLineStyle lineStyle];
    majorGridLineStyle.lineWidth = 0.5;
    majorGridLineStyle.lineColor = [[CPTColor blackColor] colorWithAlphaComponent:0.5];
    
    CPTMutableLineStyle *minorGridLineStyle = [CPTMutableLineStyle lineStyle];
    minorGridLineStyle.lineWidth = 0.25;
    minorGridLineStyle.lineColor = [[CPTColor blackColor] colorWithAlphaComponent:0.1];
    
    
    CPTMutableTextStyle *textStyle = [CPTMutableTextStyle textStyle];
    [textStyle setFontSize:8.0f];
    
    //create the graph
    mGraph =[[CPTXYGraph alloc] initWithFrame: self.plotView.bounds];
    
    [mGraph applyTheme:[CPTTheme themeNamed:kCPTPlainWhiteTheme]];
    self.plotView.hostedGraph = mGraph;
    
    //padding of the graph inside the graph view
    mGraph.plotAreaFrame.paddingLeft = 48; //space for the axis value
    mGraph.plotAreaFrame.paddingTop = 8;
    mGraph.plotAreaFrame.paddingRight = 16;
    // more space for the x axis name and the leggend
    mGraph.plotAreaFrame.paddingBottom = 48;
    
    // Axes
    // Y axis
    //show only the major grid, and a title,show only the integer part
    //for other stuff, use the default
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *)mGraph.axisSet;
    //Y axis, show only the majout
    CPTXYAxis *y          = axisSet.yAxis;
    y.labelingPolicy              = CPTAxisLabelingPolicyAutomatic;
    y.majorGridLineStyle          = majorGridLineStyle;
    y.title= Y_NAME;
    NSNumberFormatter *labelFormatter = [[NSNumberFormatter alloc] init];
    labelFormatter.numberStyle = NSNumberFormatterRoundCeiling;
    labelFormatter.positiveFormat = @"0";
    y.labelFormatter           = labelFormatter;
    y.labelRotation = CPTFloat(-M_PI_2);
    y.titleRotation = CPTFloat(-M_PI_2);
    y.labelTextStyle =textStyle;
    
    // X axis
    //show the grid in both the case, no title
    CPTXYAxis *x = axisSet.xAxis;
    x.labelingPolicy              = CPTAxisLabelingPolicyAutomatic;
    x.majorGridLineStyle          = majorGridLineStyle;
    x.minorGridLineStyle          = minorGridLineStyle;
    //always show the y axis
    x.axisConstraints             = [CPTConstraints constraintWithLowerOffset:0.0];
    x.labelTextStyle = textStyle;
    x.labelRotation = CPTFloat(-M_PI_2);
}



- (void)setUpPlotViewForFeature:(BlueSTSDKFeature*)feature {
//    NSLog(@"setUpPlotViewForFeature");//DEBUG
    
    NSUInteger arrCapacity = (NSUInteger) mTimestampRange;
    
    //before add new plot, remove the old one
    NSArray *oldPlots = [mGraph allPlots];
    for(CPTPlot *plot in oldPlots){
        [mGraph removePlot:plot];
    }
    
    //reset the plot data
    mPlotDataY = [NSMutableArray arrayWithCapacity:arrCapacity];
    mPlotDataX = [NSMutableArray arrayWithCapacity:arrCapacity];
    tempY = [NSMutableArray arrayWithCapacity:arrCapacity];
    
    //create a plot for each data exported by the feature
    NSArray *dataDesc = [feature getFieldsDesc];
    
    
    /*
     * Select the field by the index of array
     */
    
    //select for feature
    if ([self.featureLabelText isEqualToString:ACC_LABEL]) {
        SELECTED_FEATURE_INDEX = ACCELERATION_X_INDEX;
    }
    if ([self.featureLabelText isEqualToString:GYRO_LABEL]) {
        SELECTED_FEATURE_INDEX = GYROSCOPE_X_INDEX;
    }
    if ([self.featureLabelText isEqualToString:MAG_LABEL]) {
        SELECTED_FEATURE_INDEX = MAGNETOMETER_X_INDEX;
    }

    BlueSTSDKFeatureField *field = dataDesc[SELECTED_FEATURE_INDEX];
//    NSLog(@"SELECTED_FEATURE_INDEX: %d", SELECTED_FEATURE_INDEX);//DEBUG
    
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)mGraph.defaultPlotSpace;
    
    plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:@0.0
                                                    length:mTimestampRangeDecimal];
    
    float min = field.min.floatValue;
    float max = field.max.floatValue;
    
    if ([PlotFeatureViewController getBoundaryForFeature:feature min:&min max:&max]) {
        plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:@(min)
                                                        length:@(max - min)];
        if(max-min > 100){
            NSNumberFormatter *labelFormatter = [[NSNumberFormatter alloc] init];
            labelFormatter.numberStyle = NSNumberFormatterRoundCeiling;
            labelFormatter.positiveFormat = @"0";
            ((CPTXYAxisSet *)mGraph.axisSet).xAxis.labelFormatter = labelFormatter;
        }else{
            NSNumberFormatter *labelFormatter = [[NSNumberFormatter alloc] init];
            labelFormatter.numberStyle = NSNumberFormatterRoundCeiling;
            labelFormatter.positiveFormat = @"0.0";
            ((CPTXYAxisSet *)mGraph.axisSet).xAxis.labelFormatter = labelFormatter;
        }
        mAutomaticRange =false;
    }else {
        mAutomaticRange =true;
    }//if-else

    
    //fix the x axis on the bottom of the plot
    ((CPTXYAxisSet*)mGraph.axisSet).yAxis.axisConstraints = [CPTConstraints constraintWithLowerOffset:0];
    uint32_t identifier = 0;
    
    for (int i=SELECTED_FEATURE_INDEX; i<(SELECTED_FEATURE_INDEX+3); i++) {
        BlueSTSDKFeatureField *field = [dataDesc objectAtIndex:i];
        
        // Create the plot
        CPTScatterPlot *dataSourceLinePlot = [[CPTScatterPlot alloc] init];
        dataSourceLinePlot.identifier     = @(identifier);
        dataSourceLinePlot.cachePrecision = CPTPlotCachePrecisionDouble;
        
        CPTMutableLineStyle *lineStyle = [dataSourceLinePlot.dataLineStyle mutableCopy];
        lineStyle.lineWidth              = 1.0;
        lineStyle.lineColor              = sLineColor[identifier % sLineColor.count];
        dataSourceLinePlot.dataLineStyle = lineStyle;
        dataSourceLinePlot.title = field.name;
        dataSourceLinePlot.dataSource = self;
        dataSourceLinePlot.showLabels=false;
        
        [mGraph addPlot: dataSourceLinePlot];
        identifier++;
    }//for

    
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *)mGraph.axisSet;
    if(dataDesc.count!=1){
        // Add legend
        mGraph.legend                 = [CPTLegend legendWithGraph:mGraph];
        mGraph.legend.hidden=false;
        mGraph.legend.fill            = [CPTFill fillWithColor:[CPTColor clearColor]];
        mGraph.legend.cornerRadius    = 5.0;
        mGraph.legend.numberOfRows    = 1;
        mGraph.legendAnchor           = CPTRectAnchorBottom;
        mGraph.legendDisplacement     = CGPointMake( 0.0, 16 * CPTFloat(1.25) );
        axisSet.xAxis.title=@"";
    }else{
        BlueSTSDKFeatureField *field = ((BlueSTSDKFeatureField*) dataDesc[SELECTED_FEATURE_INDEX]);
        if([field hasUnit])
            axisSet.xAxis.title = [NSString stringWithFormat:@"%@ (%@)",field.name,field.unit ];
        else
            axisSet.xAxis.title = [NSString stringWithFormat:@"%@",field.name ];
        mGraph.legend.hidden=true;
    }//dataDesc
    
    //[plotSpace scaleToFitPlots:plots];
}




#pragma mark - CPTPlotDataSource methods

-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot {
//    NSLog(@"numberOfRecordsForPlot %lu", mPlotDataY.count);//DEBUG
    
    return mPlotDataY.count;
}

-(NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index {
//    NSLog(@"NumberForPlot: Index:%lu andField: %lu",index, fieldEnum);//DEBUG
    
    NSArray *datas;
    switch (fieldEnum){
        case CPTScatterPlotFieldY:
            return mPlotDataX[index];
        case CPTScatterPlotFieldX:
            datas = mPlotDataY[index];
            NSNumber *idx = (NSNumber*)plot.identifier;
            return datas[[idx unsignedIntValue]];
    }
    return sZero;
}


/**
 * find the max and min value that we will plot in the graph
 */
-(void) extractMaxMinFromData:(NSArray*)data min:(float*)outMin max:(float*)outMax{
//    NSLog(@"extractMaxMinFromData");//DEBUG
    
    float min = FLT_MAX;
    float max = FLT_MIN;
    
    for (NSArray *arr in data){
        for(NSNumber *n in arr){
            float temp = n.floatValue;
            if(temp<min)
                min=temp;
            else if (temp>max)
                max = temp;
        }//for n
    }//for arr
    
    *outMin=min;
    *outMax=max;
}



-(void)insertPlotItem:(bool)forceUpdate{
//    NSLog(@"insertPlotItem");//DEBUG

    static bool isPlotting = false;
    if (mRemFeature == nil)
        return;
    if (isPlotting)
        return;
    isPlotting = true;


    BlueSTSDKFeatureSample * sample = mRemFeature.lastSample;
    
    
    NSString * dataString = nil;
    if(forceUpdate) //generate the string only if we have to render it
        dataString= [mRemFeature description];

    dispatch_async(mSerializePlotUpdateQueue,^{

        double currentTime = CACurrentMediaTime();
        double diffLastDataUpdate = currentTime-mLastDataUpdate;
        if(mFirstTimeStamp<0){
            mFirstTimeStamp=sample.timestamp;
            mLastTimeStamp=0;
        }

        if(sample.timestamp<mLastTimeStamp){ // the data are old, avoid to plot it
            isPlotting=false;
            return;
        }

        mLastTimeStamp=sample.timestamp;

        uint64_t xValue = sample.timestamp;

        if(forceUpdate){
            mLastDataUpdate=currentTime;
            mNForcedUpdate=0;


        }else{
            // NSLog(@"Force update: %f < %f\n",diffLastDataUpdate,MAX_PLOT_UPDATE_DIFF_MS*0.001);

            //the last update is recent -> we can skip this one
            if(diffLastDataUpdate< MAX_PLOT_UPDATE_DIFF_MS*0.001){
                isPlotting=false;
                return;
            }else{
                //increase the timestamp for duplicate the last received data
                xValue += (++mNForcedUpdate)*(MAX_PLOT_UPDATE_DIFF_MS/MS_TO_TIMESTAMP_SCALE);
            }//if-else
        }//if

        //convert from timestamp to time
        xValue =(uint32_t)(xValue-mFirstTimeStamp)*MS_TO_TIMESTAMP_SCALE;

        //the system clock is faster than the board one, so we run too much -> remove the sample that are in the future
        if(((NSNumber*)mPlotDataX.lastObject).unsignedIntValue > xValue){

            uint32_t nRemove =0;
            while (mPlotDataX.count>0 && ((NSNumber*)mPlotDataX.lastObject).unsignedIntValue > xValue) {
                [mPlotDataX removeLastObject];
                [mPlotDataY removeLastObject];
                nRemove++;
            }//while


        }//if
        
        [mPlotDataY addObject:[self getCustomData:self.nodeId]];
//        [mPlotDataY addObject:sample.data];
        
        NSNumber *lastXValue = @(xValue);

        [mPlotDataX addObject:lastXValue];

        unsigned int nRemove=0;
        // NSLog(@"Oldest: %@ newer:%@",((NSNumber*)mPlotDataX.firstObject),((NSNumber*)mPlotDataX.lastObject));
        //        const uint32_t lastTs =(((NSNumber*)mPlotDataX.lastObject).unsignedIntValue);
        while(( xValue-
               (((NSNumber*) mPlotDataX[nRemove]).unsignedIntValue))
              > mTimestampRange ){

            nRemove++;
        }//while

        if(nRemove!=0){
            [mPlotDataX removeObjectsInRange:NSMakeRange(0, nRemove)];
            [mPlotDataY removeObjectsInRange:NSMakeRange(0, nRemove)];
        }

        float minY=0,maxY=0;

        if(mAutomaticRange){
            //update the y range
            [self extractMaxMinFromData:mPlotDataY min:&minY max:&maxY];
            float delta = maxY-minY;
            minY = minY - (delta)*Y_AXIS_BORDER;
            maxY = maxY + delta*Y_AXIS_BORDER;
        }//if automaticRange

        //   if(currentTime-mLastPlotUpdate>0.016) // refresh at 60fps
        // if(currentTime-mLastPlotUpdate>0.1) // refresh at 30fps
        dispatch_sync(dispatch_get_main_queue(), ^{
            if(mRemFeature==nil){ //plot stop
                isPlotting=false;
                return;
            }//if

            mLastPlotUpdate = currentTime;
            CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)mGraph.defaultPlotSpace;

            plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:lastXValue
                                                            length:mTimestampRangeDecimal];

            if(mAutomaticRange){
                plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:@(minY)
                                                                length:@(maxY - minY)];

            }//if automaticRange

            [mGraph reloadData];

        });

        isPlotting=false;
        dispatch_time_t nextUpdate = dispatch_time(DISPATCH_TIME_NOW, MAX_PLOT_UPDATE_DIFF_MS*1000000L);
        dispatch_after(nextUpdate,mForcePlotUpdateQueue, ^{
            [self insertPlotItem:false];
        });

    });

}


/**
 * function called when the acceleration notification is enabled for a node
 *
 * @param nodeId node where the user enable the notificaiton
 * @param state true if enable the notification, false for disable it
 */
- (void)accelerationNotificationDidChangeForNodeId:(uint16_t)nodeId newState:(bool)state {
    [self getNodeData:nodeId].isAccelerationEnabled = state;
    if (state) {
        [mRemFeature enableAccelerationForNode:nodeId enabled:state];
    } else {
        [mRemFeature enableAccelerationForNode:nodeId enabled:false];
    }
}

/**
 * function called when the gyroscope notification is enabled for a node
 *
 * @param nodeId node where the user enable the notificaiton
 * @param state true if enable the notification, false for disable it
 */
- (void)gyroscopeNotificationDidChangeForNodeId:(uint16_t)nodeId newState:(bool)state {
    [self getNodeData:nodeId].isGyroscopeEnabled = state;
    if (state) {
        [mRemFeature enableGyroscopeForNode:nodeId enabled:state];
    } else {
        [mRemFeature enableGyroscopeForNode:nodeId enabled:false];
    }
}

/**
 * function called when the magnetometer notification is enabled for a node
 *
 * @param nodeId node where the user enable the notificaiton
 * @param state true if enable the notification, false for disable it
 */
- (void)magnetometerNotificationDidChangeForNodeId:(uint16_t)nodeId newState:(bool)state {
    [self getNodeData:nodeId].isMagnetometerEnabled = state;
    if (state) {
        [mRemFeature enableMagnetometerForNode:nodeId enabled:state];
    } else {
        [mRemFeature enableMagnetometerForNode:nodeId enabled:false];
    }
}



#pragma mark - BlueSTSDKFeatureDelegate methods

- (void)didUpdateFeature:(BlueSTSDKFeature *)feature sample:(BlueSTSDKFeatureSample *)sample{
//    NSLog(@"didUpdateFeature");//DEBUG
    
    uint16_t nodeId = [STSensNetGenericRemoteFeature getNodeId:sample];
    
    //update the remote data struct
    GenericRemoteNodeData *data = [self getNodeData:nodeId];
    
    if ([self.featureLabelText isEqualToString:ACC_LABEL]) {
        data.accelerationX = [STSensNetGenericRemoteFeature getAccX:sample];
        data.accelerationY = [STSensNetGenericRemoteFeature getAccY:sample];
        data.accelerationZ = [STSensNetGenericRemoteFeature getAccZ:sample];
    }
    if ([self.featureLabelText isEqualToString:GYRO_LABEL]) {
        data.gyroscopeX = [STSensNetGenericRemoteFeature getGyroX:sample];
        data.gyroscopeY = [STSensNetGenericRemoteFeature getGyroY:sample];
        data.gyroscopeZ = [STSensNetGenericRemoteFeature getGyroZ:sample];
    }
    if ([self.featureLabelText isEqualToString:MAG_LABEL]) {
        data.magnetometerX = [STSensNetGenericRemoteFeature getMagX:sample];
        data.magnetometerY = [STSensNetGenericRemoteFeature getMagY:sample];
        data.magnetometerZ = [STSensNetGenericRemoteFeature getMagZ:sample];
    }
    

    [self insertPlotItem:true];

}



@end
