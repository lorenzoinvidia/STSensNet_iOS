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

#include <limits.h>
#include <float.h>
#include "STSensNetGenericRemoteFeature.h"

#import <BlueSTSDK/BlueSTSDKFeature_pro.h>
#import <BlueSTSDK/BlueSTSDKFeatureField.h>
#import <BlueSTSDK/NSData+NumberConversion.h>

///// type id used for undesteand what value read next

#define TYPE_ID_UNKWOWN 0x00
#define TYPE_ID_PRESSURE 0x01
#define TYPE_ID_HUMIDITY 0x02
#define TYPE_ID_TEMPERATURE 0x03
#define TYPE_ID_LED_STATUS 0x04
#define TYPE_ID_PROXIMITY 0x05
#define TYPE_ID_MOTION_DETECTION 0x06
#define TYPE_ID_MIC_LEVEL 0x07
#define TYPE_ID_LUMINOSITY 0x08
#define TYPE_ID_ACCELERATION 0x09
#define TYPE_ID_GYROSCOPE 0x0A
#define TYPE_ID_MAGNETOMETER 0x0B
#define TYPE_ID_STATUS 0x0C
#define TYPE_ID_SENSORFUSION 0x0D



#define FEATURE_NAME @"Generic Remote"

#define REMOTE_NODE_ID_INDEX 0
#define REMOTE_NODE_ID_NAME @"Node Id"
#define REMOTE_NODE_ID_UNIT nil
#define REMOTE_NODE_ID_DATA_MAX ((float)(1<<16)-1)
#define REMOTE_NODE_ID_DATA_MIN  0

#define PRESSURE_INDEX 1
#define PRESSURE_DATA_NAME @"Pressure"
#define PRESSURE_UNIT @"mBar"
#define PRESSURE_DATA_MAX 2000
#define PRESSURE_DATA_MIN 0

#define TEMPERATURE_INDEX 2
#define TEMPERATURE_DATA_NAME @"Temperature"
#define TEMPERATURE_UNIT @"\u2103"
#define TEMPERATURE_DATA_MAX 100
#define TEMPERATURE_DATA_MIN 0

#define HUMIDITY_INDEX 3
#define HUMIDITY_DATA_NAME @"Humidity"
#define HUMIDITY_UNIT @"%"
#define HUMIDITY_DATA_MAX 100
#define HUMIDITY_DATA_MIN 0

#define LED_INDEX 4
#define LED_NAME @"LED"
#define LED_UNIT nil
#define LED_DATA_NAME @"Status"
#define LED_DATA_MAX 1
#define LED_DATA_MIN 0

#define PROXIMITY_INDEX 5
#define PROXIMITY_DATA_NAME @"Proximity"
#define PROXIMITY_UNIT  @"mm"
#define PROXIMITY_DATA_MAX  254
#define PROXIMITY_DATA_MIN 0
#define PROXIMITY_OUT_OF_RANGE_VALUE 255

#define MOTION_DETECTION_INDEX 6
#define MOTION_DETECTION_DATA_NAME @"Last Moviment"
#define MOTION_DETECTION_UNIT  @"s"
#define MOTION_DETECTION_DATA_MAX DBL_MAX
#define MOTION_DETECTION_DATA_MIN -1

#define MIC_LEVEL_INDEX 7
#define MIC_LEVEL_DATA_NAME @"Mic Level"
#define MIC_LEVEL_UNIT  @"db"
#define MIC_LEVEL_DATA_MAX 255
#define MIC_LEVEL_DATA_MIN 0

#define LUX_INDEX 8
#define LUX_DATA_NAME @"Lux"
#define LUX_UNIT  @"Lux"
#define LUX_DATA_MAX (1<<16)
#define LUX_DATA_MIN 0

#define ACCELERATION_X_INDEX 9
#define ACCELERATION_Y_INDEX 10
#define ACCELERATION_Z_INDEX 11
#define ACCELERATION_X_DATA_NAME @"Xa"
#define ACCELERATION_Y_DATA_NAME @"Ya"
#define ACCELERATION_Z_DATA_NAME @"Za"
#define ACCELERATION_UNIT @"mg"
#define ACCELERATION_DATA_MAX 2000
#define ACCELERATION_DATA_MIN -ACCELERATION_DATA_MAX

#define GYROSCOPE_X_INDEX 12
#define GYROSCOPE_Y_INDEX 13
#define GYROSCOPE_Z_INDEX 14
#define GYROSCOPE_X_DATA_NAME @"Xg"
#define GYROSCOPE_Y_DATA_NAME @"Yg"
#define GYROSCOPE_Z_DATA_NAME @"Zg"
#define GYROSCOPE_UNIT @"dps"
#define GYROSCOPE_DATA_MAX ((float)(1<<15)/50.0f)
#define GYROSCOPE_DATA_MIN (-GYROSCOPE_DATA_MAX)

#define MAGNETOMETER_X_INDEX 15
#define MAGNETOMETER_Y_INDEX 16
#define MAGNETOMETER_Z_INDEX 17
#define MAGNETOMETER_X_DATA_NAME @"Xm"
#define MAGNETOMETER_Y_DATA_NAME @"Ym"
#define MAGNETOMETER_Z_DATA_NAME @"Zm"
#define MAGNETOMETER_UNIT @"mGa"
#define MAGNETOMETER_DATA_MAX 2000
#define MAGNETOMETER_DATA_MIN -MAGNETOMETER_DATA_MAX

#define STATUS_INDEX 18
#define STATUS_DATA_NAME @"Status"
#define STATUS_UNIT nil
#define STATUS_DATA_MAX 1
#define STATUS_DATA_MIN 0

#define SENSOR_FUSION_QI_INDEX 19
#define SENSOR_FUSION_QJ_INDEX 20
#define SENSOR_FUSION_QK_INDEX 21
#define SENSOR_FUSION_QI_DATA_NAME @"qi"
#define SENSOR_FUSION_QJ_DATA_NAME @"qj"
#define SENSOR_FUSION_QK_DATA_NAME @"qk"
#define SENSOR_FUSION_UNIT nil
#define SENSOR_FUSION_DATA_MAX 1.0f
#define SENSOR_FUSION_DATA_MIN -SENSOR_FUSION_DATA_MAX

/**
 * @memberof STSensNetGenericRemoteFeature
 *  array with the description of field exported by the feature
 */
static NSArray<BlueSTSDKFeatureField*> *sFieldDesc;

@implementation STSensNetGenericRemoteFeature

+(void)initialize{
    if(self == [STSensNetGenericRemoteFeature class]){
        
                        // 0
        sFieldDesc = @[[BlueSTSDKFeatureField  createWithName:REMOTE_NODE_ID_NAME
                                                         unit:REMOTE_NODE_ID_UNIT
                                                         type:BlueSTSDKFeatureFieldTypeUInt16
                                                          min:@REMOTE_NODE_ID_DATA_MIN
                                                          max:@REMOTE_NODE_ID_DATA_MAX],
                       // 1
                       [BlueSTSDKFeatureField  createWithName:PRESSURE_DATA_NAME
                                                         unit:PRESSURE_UNIT
                                                         type:BlueSTSDKFeatureFieldTypeFloat
                                                          min:@PRESSURE_DATA_MIN
                                                          max:@PRESSURE_DATA_MAX],
                       // 2
                       [BlueSTSDKFeatureField  createWithName:TEMPERATURE_DATA_NAME
                                                         unit:TEMPERATURE_UNIT
                                                         type:BlueSTSDKFeatureFieldTypeFloat
                                                          min:@TEMPERATURE_DATA_MIN
                                                          max:@TEMPERATURE_DATA_MAX],
                       // 3
                       [BlueSTSDKFeatureField  createWithName:HUMIDITY_DATA_NAME
                                                         unit:HUMIDITY_UNIT
                                                         type:BlueSTSDKFeatureFieldTypeFloat
                                                          min:@HUMIDITY_DATA_MIN
                                                          max:@HUMIDITY_DATA_MAX],
                       // 4
                       [BlueSTSDKFeatureField  createWithName:LED_DATA_NAME
                                                         unit:LED_UNIT
                                                         type:BlueSTSDKFeatureFieldTypeUInt8
                                                          min:@LED_DATA_MIN
                                                          max:@LED_DATA_MAX],
                       // 5
                       [BlueSTSDKFeatureField  createWithName:PROXIMITY_DATA_NAME
                                                         unit:PROXIMITY_UNIT
                                                         type:BlueSTSDKFeatureFieldTypeUInt16
                                                          min:@PROXIMITY_DATA_MIN
                                                          max:@PROXIMITY_DATA_MAX],
                       // 6
                       [BlueSTSDKFeatureField  createWithName:MOTION_DETECTION_DATA_NAME
                                                         unit:MOTION_DETECTION_UNIT
                                                         type:BlueSTSDKFeatureFieldTypeDouble
                                                          min:@MOTION_DETECTION_DATA_MIN
                                                          max:@MOTION_DETECTION_DATA_MAX],
                       // 7
                       [BlueSTSDKFeatureField  createWithName:MIC_LEVEL_DATA_NAME
                                                         unit:MIC_LEVEL_UNIT
                                                         type:BlueSTSDKFeatureFieldTypeInt16
                                                          min:@MIC_LEVEL_DATA_MIN
                                                          max:@MIC_LEVEL_DATA_MAX],
                       // 8
                       [BlueSTSDKFeatureField  createWithName:LUX_DATA_NAME
                                                         unit:LUX_UNIT
                                                         type:BlueSTSDKFeatureFieldTypeUInt16
                                                          min:@LUX_DATA_MIN
                                                          max:@LUX_DATA_MAX],

                       // 9
                       // Acceleration
                       [BlueSTSDKFeatureField  createWithName:ACCELERATION_X_DATA_NAME
                                                         unit:ACCELERATION_UNIT
                                                         type:BlueSTSDKFeatureFieldTypeInt16
                                                          min:@ACCELERATION_DATA_MIN
                                                          max:@ACCELERATION_DATA_MAX],
                       // 10
                       [BlueSTSDKFeatureField  createWithName:ACCELERATION_Y_DATA_NAME
                                                         unit:ACCELERATION_UNIT
                                                         type:BlueSTSDKFeatureFieldTypeInt16
                                                          min:@ACCELERATION_DATA_MIN
                                                          max:@ACCELERATION_DATA_MAX],
                       // 11
                       [BlueSTSDKFeatureField  createWithName:ACCELERATION_Z_DATA_NAME
                                                         unit:ACCELERATION_UNIT
                                                         type:BlueSTSDKFeatureFieldTypeInt16
                                                          min:@ACCELERATION_DATA_MIN
                                                          max:@ACCELERATION_DATA_MAX],
                       // 12
                       // Gyroscope
                       [BlueSTSDKFeatureField  createWithName:GYROSCOPE_X_DATA_NAME
                                                         unit:GYROSCOPE_UNIT
                                                         type:BlueSTSDKFeatureFieldTypeFloat
                                                          min:@GYROSCOPE_DATA_MIN
                                                          max:@GYROSCOPE_DATA_MAX],
                       // 13
                       [BlueSTSDKFeatureField  createWithName:GYROSCOPE_Y_DATA_NAME
                                                         unit:GYROSCOPE_UNIT
                                                         type:BlueSTSDKFeatureFieldTypeFloat
                                                          min:@GYROSCOPE_DATA_MIN
                                                          max:@GYROSCOPE_DATA_MAX],
                       // 14
                       [BlueSTSDKFeatureField  createWithName:GYROSCOPE_Z_DATA_NAME
                                                         unit:GYROSCOPE_UNIT
                                                         type:BlueSTSDKFeatureFieldTypeFloat
                                                          min:@GYROSCOPE_DATA_MIN
                                                          max:@GYROSCOPE_DATA_MAX],
                       // 15
                       // Magnetometer
                       [BlueSTSDKFeatureField  createWithName:MAGNETOMETER_X_DATA_NAME
                                                         unit:MAGNETOMETER_UNIT
                                                         type:BlueSTSDKFeatureFieldTypeInt16
                                                          min:@MAGNETOMETER_DATA_MIN
                                                          max:@MAGNETOMETER_DATA_MAX],
                       // 16
                       [BlueSTSDKFeatureField  createWithName:MAGNETOMETER_Y_DATA_NAME
                                                         unit:MAGNETOMETER_UNIT
                                                         type:BlueSTSDKFeatureFieldTypeInt16
                                                          min:@MAGNETOMETER_DATA_MIN
                                                          max:@MAGNETOMETER_DATA_MAX],
                       // 17
                       [BlueSTSDKFeatureField  createWithName:MAGNETOMETER_Z_DATA_NAME
                                                         unit:MAGNETOMETER_UNIT
                                                         type:BlueSTSDKFeatureFieldTypeInt16
                                                          min:@MAGNETOMETER_DATA_MIN
                                                          max:@MAGNETOMETER_DATA_MAX],
                       // 18
                       // Status
                       [BlueSTSDKFeatureField  createWithName:STATUS_DATA_NAME
                                                         unit:STATUS_UNIT
                                                         type:BlueSTSDKFeatureFieldTypeInt16
                                                          min:@STATUS_DATA_MIN
                                                          max:@STATUS_DATA_MAX],
                       // 19
                       // Sensor Fusion
                       [BlueSTSDKFeatureField  createWithName:SENSOR_FUSION_QI_DATA_NAME
                                                         unit:SENSOR_FUSION_UNIT
                                                         type:BlueSTSDKFeatureFieldTypeFloat
                                                          min:@SENSOR_FUSION_DATA_MIN
                                                          max:@SENSOR_FUSION_DATA_MAX],
                       // 20
                       [BlueSTSDKFeatureField  createWithName:SENSOR_FUSION_QJ_DATA_NAME
                                                         unit:SENSOR_FUSION_UNIT
                                                         type:BlueSTSDKFeatureFieldTypeFloat
                                                          min:@SENSOR_FUSION_DATA_MIN
                                                          max:@SENSOR_FUSION_DATA_MAX],
                       // 21
                       [BlueSTSDKFeatureField  createWithName:SENSOR_FUSION_QK_DATA_NAME
                                                         unit:SENSOR_FUSION_UNIT
                                                         type:BlueSTSDKFeatureFieldTypeFloat
                                                          min:@SENSOR_FUSION_DATA_MIN
                                                          max:@SENSOR_FUSION_DATA_MAX]

                       ];
    }//if
}//initialize


-(instancetype) initWhitNode:(BlueSTSDKNode *)node{
    self = [super initWhitNode:node name:FEATURE_NAME];
    return self;
}

-(NSArray*) getFieldsDesc{
    return sFieldDesc;
}




/**
 *  extract data
 *
 *  @param timestamp data time stamp
 *  @param rawData   array of byte send by the node
 *  @param offset    offset where we have to start reading the data
 *
 *  @throw exception if there are no 3 bytes available in the rawdata array
 *  @return humidity + number of read bytes (2)
 */
-(BlueSTSDKExtractResult*) extractData:(uint64_t)timestamp data:(NSData*)rawData dataOffset:(uint32_t)offset{
    
    
    if (rawData.length-offset < 3) //2 (node Id)+1 (type id)
        @throw [NSException
                exceptionWithName:@"Invalid Generic Remote data"
                reason:@"There are no 3 bytes available to read"
                userInfo:nil];
    
    float pressure=NAN;
    float temperature=NAN;
    float humidity=NAN;
    int8_t ledStatus=-1;
    int proximity=-1;
    double movimentDetection=-1;
    int16_t micLevel=-1;
    int luxValue=-1;
    int accelerationX=-2001;
    int accelerationY=-2001;
    int accelerationZ=-2001;
    float gyroscopeX=NAN;
    float gyroscopeY=NAN;
    float gyroscopeZ=NAN;
    int magnetometerX=-2001;
    int magnetometerY=-2001;
    int magnetometerZ=-2001;
    int status=0;
    float sFusionQI=NAN;
    float sFusionQJ=NAN;
    float sFusionQK=NAN;
    
    
    
    uint32_t readData = offset;
    
    int nodeID = [rawData extractLeUInt16FromOffset:readData];
    
    readData+=2;
    
    BOOL validDataId =true;
    while (validDataId && readData<rawData.length){
        switch ([rawData extractUInt8FromOffset:readData]){
            case TYPE_ID_PRESSURE:
                pressure= [rawData extractLeInt32FromOffset:readData+1]/100.0f;
                readData+=4;
                break;
            case TYPE_ID_TEMPERATURE:
                temperature = [rawData extractLeInt16FromOffset:readData+1]/10.0f;
                readData+=2;
                break;
            case TYPE_ID_HUMIDITY:
                humidity = [rawData extractLeInt16FromOffset:readData+1]/10.0f;
                readData+=2;
                break;
            case TYPE_ID_LED_STATUS:
                ledStatus= [rawData extractInt8FromOffset:readData+1];
                readData++;
                break;
            case TYPE_ID_PROXIMITY:
                proximity = [rawData extractLeUInt16FromOffset:readData+1];
                readData+=2;
                break;
            case TYPE_ID_MOTION_DETECTION:
                movimentDetection = [NSDate timeIntervalSinceReferenceDate];
                break;
            case TYPE_ID_MIC_LEVEL:
                micLevel= [rawData extractInt8FromOffset:readData+1];
                readData++;
                break;
            case TYPE_ID_LUMINOSITY:
                luxValue= [rawData extractLeUInt16FromOffset:readData+1];
                readData+=2;
                break;
                
            case TYPE_ID_ACCELERATION:
                NSLog(@"TYPE_ID_ACCELERATION");//DEBUG
                accelerationX = [rawData extractLeInt16FromOffset:readData+1];
                readData+=2;
                accelerationY = [rawData extractLeInt16FromOffset:readData+1];
                readData+=2;
                accelerationZ = [rawData extractLeInt16FromOffset:readData+1];
                readData+=2;
                break;
                
            case TYPE_ID_GYROSCOPE:
                NSLog(@"TYPE_ID_GYROSCOPE");//DEBUG
                gyroscopeX = [rawData extractLeInt16FromOffset:(readData+1)]/10.0f;
                readData+=2;
                gyroscopeY = [rawData extractLeInt16FromOffset:(readData+1)]/10.0f;
                readData+=2;
                gyroscopeZ = [rawData extractLeInt16FromOffset:(readData+1)]/10.0f;
                readData+=2;
                break;
                
            case TYPE_ID_MAGNETOMETER:
                NSLog(@"TYPE_ID_MAGNETOMETER");//DEBUG
                magnetometerX = [rawData extractLeInt16FromOffset:readData+1];
                readData+=2;
                magnetometerY = [rawData extractLeInt16FromOffset:readData+1];
                readData+=2;
                magnetometerZ = [rawData extractLeInt16FromOffset:readData+1];
                readData+=2;
                break;
                
            case TYPE_ID_STATUS:
                NSLog(@"TYPE_ID_STATUS");//DEBUG
                status=1;
                readData+=1;
                break;
                
            case TYPE_ID_SENSORFUSION:
                NSLog(@"TYPE_ID_SENSORFUSION");//DEBUG
                sFusionQI = [rawData extractLeInt16FromOffset:(readData+1)]/10000.0f;
                readData+=2;
                sFusionQJ = [rawData extractLeInt16FromOffset:(readData+1)]/10000.0f;
                readData+=2;
                sFusionQK = [rawData extractLeInt16FromOffset:(readData+1)]/10000.0f;
                readData+=2;
                break;
                
            default://else
                NSLog(@"UNKWNON DATA");//DEBUG
                validDataId=false;
                break;
        }
        readData++; //+1 for the typeid
    }
    
    
    NSArray *data = @[@(nodeID),@(pressure),@(temperature),
                      @(humidity),@(ledStatus),@(proximity),
                      @(movimentDetection),@(micLevel),@(luxValue),
                      @(accelerationX),@(accelerationY), @(accelerationZ),
                      @(gyroscopeX),@(gyroscopeY),@(gyroscopeZ),
                      @(magnetometerX),@(magnetometerY),@(magnetometerZ),
                      @(status),
                      @(sFusionQI),@(sFusionQJ),@(sFusionQK)];
    
    
    BlueSTSDKFeatureSample *sample =
    [BlueSTSDKFeatureSample sampleWithTimestamp:timestamp data:data ];
    return [BlueSTSDKExtractResult resutlWithSample:sample nReadData:readData-offset];
    
}


/*---------------------------------------------------------------------------------*/

+(uint16_t)getNodeId:(BlueSTSDKFeatureSample *)sample{
    if(sample.data.count<REMOTE_NODE_ID_INDEX)
        return -1;
    return[[sample.data objectAtIndex:REMOTE_NODE_ID_INDEX] floatValue];
}

+(float)getTemperature:(BlueSTSDKFeatureSample *)sample{
    if(sample.data.count<TEMPERATURE_INDEX)
        return NAN;
    return[[sample.data objectAtIndex:TEMPERATURE_INDEX] floatValue];
}

+(NSString*)getTemperatureUnit{
    return TEMPERATURE_UNIT;
}

+(float)getHumidity:(BlueSTSDKFeatureSample *)sample{
    if(sample.data.count<HUMIDITY_INDEX)
        return NAN;
    return[[sample.data objectAtIndex:HUMIDITY_INDEX] floatValue];
}

+(NSString*)getHumidityUnit{
    return HUMIDITY_UNIT;
}

+(float)getPressure:(BlueSTSDKFeatureSample *)sample{
    if(sample.data.count<PRESSURE_INDEX)
        return NAN;
    return[[sample.data objectAtIndex:PRESSURE_INDEX] floatValue];
}

+(NSString*)getPressureUnit{
    return PRESSURE_UNIT;
}

+(int32_t)getProximity:(BlueSTSDKFeatureSample *)sample{
    if(sample.data.count<PROXIMITY_INDEX)
        return -1;
    return [[sample.data objectAtIndex:PROXIMITY_INDEX] intValue];
}

+(NSString*)getProximityUnit{
    return PROXIMITY_UNIT;
}

+(uint16_t)getProximityMaxValue{
    return PROXIMITY_DATA_MAX;
}

+(uint16_t)getProximityOutOfRangeValue{
    return PROXIMITY_OUT_OF_RANGE_VALUE;
}

+(NSString*)getMicLevelUnit{
    return MIC_LEVEL_UNIT;
}

+(NSString*)getLuminosityUnit{
    return LUX_UNIT;
}

+(uint16_t)getMicLevelMaxValue{
    return MIC_LEVEL_DATA_MAX;
}

+(int8_t)getLedStatus:(BlueSTSDKFeatureSample *)sample{
    if(sample.data.count<LED_INDEX)
        return NAN;
    return[[sample.data objectAtIndex:LED_INDEX] floatValue];
}

+(NSTimeInterval)getLastMovimentDetected:(BlueSTSDKFeatureSample *)sample{
    if(sample.data.count<MOTION_DETECTION_INDEX)
        return -1;
    return [[sample.data objectAtIndex:MOTION_DETECTION_INDEX] doubleValue];
}


+(int16_t)getMicLevel:(BlueSTSDKFeatureSample *)sample{
    if(sample.data.count<MIC_LEVEL_INDEX)
        return -1;
    return[[sample.data objectAtIndex:MIC_LEVEL_INDEX] shortValue];
}

+(int)getLuminosity:(BlueSTSDKFeatureSample *)sample{
    if(sample.data.count<LUX_INDEX)
        return -1;
    return[[sample.data objectAtIndex:LUX_INDEX] intValue];
}


/*---------------------------------------------------------------------------------*/

+(float)getAccX:(BlueSTSDKFeatureSample *)sample{
    if (sample.data.count<ACCELERATION_X_INDEX)
        return NAN;
    return [[sample.data objectAtIndex:ACCELERATION_X_INDEX] floatValue];
}


+(float)getAccY:(BlueSTSDKFeatureSample *)sample{
    if (sample.data.count<ACCELERATION_Y_INDEX)
        return NAN;
    return [[sample.data objectAtIndex:ACCELERATION_Y_INDEX] floatValue];
}


+(float)getAccZ:(BlueSTSDKFeatureSample *)sample{
    if (sample.data.count<ACCELERATION_Z_INDEX)
        return NAN;
    return [[sample.data objectAtIndex:ACCELERATION_Z_INDEX] floatValue];
}

+(NSString*)getAccelerationUnit{
    return ACCELERATION_UNIT;
}

/*---------------------------------------------------------------------------------*/

+(float)getMagX:(BlueSTSDKFeatureSample *)sample{
    if (sample.data.count<MAGNETOMETER_X_INDEX)
        return NAN;
    return [[sample.data objectAtIndex:MAGNETOMETER_X_INDEX] floatValue];
}

+(float)getMagY:(BlueSTSDKFeatureSample *)sample{
    if (sample.data.count<MAGNETOMETER_Y_INDEX)
        return NAN;
    return [[sample.data objectAtIndex:MAGNETOMETER_Y_INDEX] floatValue];
}

+(float)getMagZ:(BlueSTSDKFeatureSample *)sample{
    if (sample.data.count<MAGNETOMETER_Z_INDEX)
        return NAN;
    return [[sample.data objectAtIndex:MAGNETOMETER_Z_INDEX] floatValue];
}

+(NSString*)getMagnetometerlUnit{
    return MAGNETOMETER_UNIT;
}

/*---------------------------------------------------------------------------------*/

+(float)getGyroX:(BlueSTSDKFeatureSample *)sample{
    if (sample.data.count<GYROSCOPE_X_INDEX)
        return NAN;
    return [[sample.data objectAtIndex:GYROSCOPE_X_INDEX] floatValue];
}

+(float)getGyroY:(BlueSTSDKFeatureSample *)sample{
    if (sample.data.count<GYROSCOPE_Y_INDEX)
        return NAN;
    return [[sample.data objectAtIndex:GYROSCOPE_Y_INDEX] floatValue];
}

+(float)getGyroZ:(BlueSTSDKFeatureSample *)sample{
    if (sample.data.count<GYROSCOPE_Z_INDEX)
        return NAN;
    return [[sample.data objectAtIndex:GYROSCOPE_Z_INDEX] floatValue];
}

+(NSString*)getGyroscopeUnit{
    return GYROSCOPE_UNIT;
}

/*---------------------------------------------------------------------------------*/

+(float)getStatus:(BlueSTSDKFeatureSample *)sample{
    if (sample.data.count<STATUS_INDEX) {
        return -1;
    }
    return [[sample.data objectAtIndex:STATUS_INDEX] intValue];
}

/*---------------------------------------------------------------------------------*/

+(float)getQi:(BlueSTSDKFeatureSample*)sample{
//    NSLog(@"getQi -- ROW 665");//DEBUG
    if(sample.data.count<SENSOR_FUSION_QI_INDEX)
        return NAN;
    return[[sample.data objectAtIndex:SENSOR_FUSION_QI_INDEX] floatValue];
}


+(float)getQj:(BlueSTSDKFeatureSample*)sample{
    if(sample.data.count<SENSOR_FUSION_QJ_INDEX)
        return NAN;
    return[[sample.data objectAtIndex:SENSOR_FUSION_QJ_INDEX] floatValue];
}


+(float)getQk:(BlueSTSDKFeatureSample*)sample{
    if(sample.data.count<SENSOR_FUSION_QK_INDEX)
        return NAN;
    return[[sample.data objectAtIndex:SENSOR_FUSION_QK_INDEX] floatValue];
}

+(NSString*)getSensorFusionUnit{
    return SENSOR_FUSION_UNIT;
}


/*---------------------------------------------------------------------------------*/

-(void)sendEnableCommand:(uint8_t)commandId nodeId:(uint16_t)nodeId enable:(bool)enable{
    
//    NSLog(@"sendEnableCommand ");//DEBUG
    NSMutableData *msg = [NSMutableData data];
    nodeId = CFSwapInt16HostToBig(nodeId);
    uint8_t newStatus = enable ? 0x1 : 0x0;
    [msg appendBytes:&nodeId length:sizeof(nodeId)];
    [msg appendBytes:&commandId length:sizeof(commandId)];
    [msg appendBytes:&newStatus length:sizeof(newStatus)];
    [self writeData:msg];
}

/*---------------------------------------------------------------------------------*/

-(void)setSwitchStatus:(uint16_t)nodeId newState:(bool)state{
    [self sendEnableCommand:TYPE_ID_LED_STATUS nodeId:nodeId enable:state];
}

-(void)enableProximityForNode:(uint16_t)nodeId enabled:(bool)state{
    [self sendEnableCommand:TYPE_ID_PROXIMITY nodeId:nodeId enable:state];
}

-(void)enableMicLevelForNode:(uint16_t)nodeId enabled:(bool)state{
    [self sendEnableCommand:TYPE_ID_MIC_LEVEL nodeId:nodeId enable:state];
}

/*---------------------------------------------------------------------------------*/
// Added

-(void)enableSensorFusionForNode:(uint16_t)nodeId enabled:(bool)state{
    NSLog(@"enableSensorFusionForNode: %@ withState: %s", [NSString stringWithFormat:@"0x%0.4X",nodeId], state ? "true" : "false");//DEBUG
    
    [self sendEnableCommand:TYPE_ID_SENSORFUSION nodeId:nodeId enable:state];
}

-(void)enableAccelerationForNode:(uint16_t)nodeId enabled:(bool)state{
     NSLog(@"enableAccelerationForNode: %@ withState: %s", [NSString stringWithFormat:@"0x%0.4X",nodeId], state ? "true" : "false");//DEBUG
    
    [self sendEnableCommand:TYPE_ID_ACCELERATION nodeId:nodeId enable:state];
}

-(void)enableGyroscopeForNode:(uint16_t)nodeId enabled:(bool)state{
    NSLog(@"enableGyroscopeForNode: %@ withState: %s", [NSString stringWithFormat:@"0x%0.4X",nodeId], state ? "true" : "false");//DEBUG
    
    [self sendEnableCommand:TYPE_ID_GYROSCOPE nodeId:nodeId enable:state];
}

-(void)enableMagnetometerForNode:(uint16_t)nodeId enabled:(bool)state{
    NSLog(@"enableMagnetometerForNode: %@ withState: %s", [NSString stringWithFormat:@"0x%0.4X",nodeId], state ? "true" : "false");//DEBUG
    
    [self sendEnableCommand:TYPE_ID_MAGNETOMETER nodeId:nodeId enable:state];
}

/*---------------------------------------------------------------------------------*/

@end
