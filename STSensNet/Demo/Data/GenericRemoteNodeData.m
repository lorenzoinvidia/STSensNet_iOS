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

#import "GenericRemoteNodeData.h"

@implementation GenericRemoteNodeData



+(instancetype)initWithNodeId:(uint16_t)nodeId{
    GenericRemoteNodeData *data = [[GenericRemoteNodeData alloc] init];
    data.nodeId=nodeId;
    return data;
}

-(instancetype)init{
    self = [super init];
    _proximity=-1;
    _lastMotionEvent=-1;
    _micLevel=-1;
    _accelerationX=-2001;
    _accelerationY=-2001;
    _accelerationZ=-2001;
    _gyroscopeX=NAN;
    _gyroscopeY=NAN;
    _gyroscopeZ=NAN;
    _magnetometerX=-2001;
    _magnetometerY=-2001;
    _magnetometerZ=-2001;
    _sFusionQI=NAN;
    _sFusionQJ=NAN;
    _sFusionQK=NAN;
    
    return self;
}


-(BOOL) hasProximity{
    return _proximity>=0;
}


-(void)setProximity:(int32_t)proximity{
    if(proximity<0)
        return;
    _proximity=proximity;
}

-(void)setLastMotionEvent:(NSTimeInterval)lastEvent{
    if(lastEvent<0)
        return;
    _lastMotionEvent=lastEvent;
}

-(void)setMicLevel:(int16_t)micLevel{
    if(micLevel<0)
        return;
    _micLevel=micLevel;
}

//Added

//Accelerometer
-(void)setAccelerationX:(int)accelerationX{
    if(accelerationX>=-2000 && accelerationX<=2000)
        _accelerationX=accelerationX;
}

-(void)setAccelerationY:(int)accelerationY{
    if(accelerationY>=-2000 && accelerationY<=2000)
        _accelerationY=accelerationY;
}

-(void)setAccelerationZ:(int)accelerationZ{
    if(accelerationZ>=-2000 && accelerationZ<=2000)
        _accelerationZ=accelerationZ;
}

// Gyroscope
-(void)setGyroscopeX:(float)gyroscopeX{
    if(gyroscopeX != NAN)
        _gyroscopeX=gyroscopeX;
}

-(void)setGyroscopeY:(float)gyroscopeY{
    if(gyroscopeY != NAN)
        _gyroscopeY=gyroscopeY;
}

-(void)setGyroscopeZ:(float)gyroscopeZ{
    if(_gyroscopeZ != NAN)
        _gyroscopeZ=gyroscopeZ;
}

// Magnetometer
-(void)setMagnetometerX:(int)magnetometerX{
    if(magnetometerX>=-2000 && magnetometerX<=2000)
        _magnetometerX=magnetometerX;
}

-(void)setMagnetometerY:(int)magnetometerY{
    if(magnetometerY>=-2000 && magnetometerY<=2000)
        _magnetometerY=magnetometerY;
}

-(void)setMagnetometerZ:(int)magnetometerZ{
    if(magnetometerZ>=-2000 && magnetometerZ<=2000)
        _magnetometerZ=magnetometerZ;
}


// SFusion
-(void)setSFusionQI:(float)sFusionQI{
    if(sFusionQI != NAN)
        _sFusionQI=sFusionQI;
}

-(void)setSFusionQJ:(float)sFusionQJ{
    if(sFusionQJ != NAN)
        _sFusionQJ=sFusionQJ;
}

-(void)setSFusionQK:(float)sFusionQK{
    if(sFusionQK != NAN)
        _sFusionQK=sFusionQK;
}


@end
