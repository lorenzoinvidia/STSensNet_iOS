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

#import "EnviromentalRemoteNodeData.h"



/**
 * Class that contains enviromental data and other datas form a remote node
 */
@interface GenericRemoteNodeData : EnviromentalRemoteNodeData

+(instancetype)initWithNodeId:(uint16_t) nodeId;


/**
 * proximity value: -1 -> unknown >=0 valid value
 */
@property (readwrite,nonatomic, assign) int32_t proximity;
/**
 * true if the prximity notification are enabled
 */
@property (readwrite, assign) BOOL isProximityEnabled;

/**
 * micLevel value: -1 -> unknown >=0 valid value
 */
@property (readwrite,nonatomic, assign) int16_t micLevel;

/**
 * true if the micLevel notificaiton are enabled
 */
@property (readwrite, assign) BOOL isMicLevelEnabled;

/**
 * lastMoviemnt value: -1 -> unknown >=0 valid value
 */
@property (readwrite,nonatomic, assign) NSTimeInterval lastMotionEvent;


/**
 * tell if the node has send some proximity value
 * @return true if the node has send some valid proximity values
 */
-(BOOL) hasProximity;


/**
 * acceleration
 */
@property (readwrite,nonatomic, assign) int accelerationX;
@property (readwrite,nonatomic, assign) int accelerationY;
@property (readwrite,nonatomic, assign) int accelerationZ;

/**
 * true if the acceleration notification are enabled
 */
@property (readwrite, assign) BOOL isAccelerationEnabled;


/**
 * gyroscope
 */
@property (readwrite,nonatomic, assign) float gyroscopeX;
@property (readwrite,nonatomic, assign) float gyroscopeY;
@property (readwrite,nonatomic, assign) float gyroscopeZ;

/**
 * true if the gyroscope notification are enabled
 */
@property (readwrite, assign) BOOL isGyroscopeEnabled;


/**
 * magnetometer
 */
@property (readwrite,nonatomic, assign) int magnetometerX;
@property (readwrite,nonatomic, assign) int magnetometerY;
@property (readwrite,nonatomic, assign) int magnetometerZ;

/**
 * true if the magnetometer notification are enabled
 */
@property (readwrite, assign) BOOL isMagnetometerEnabled;


/**
 * sensor fusion
 */
@property (readwrite,nonatomic, assign) float sFusionQI;
@property (readwrite,nonatomic, assign) float sFusionQJ;
@property (readwrite,nonatomic, assign) float sFusionQK;

/**
 * true if the sensor fusion notification are enabled
 */
@property (readwrite, assign) BOOL isSensorFusionEnabled;


/**
 * status
 */


@end
