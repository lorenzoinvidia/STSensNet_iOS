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

#import "EnviromentalRemoteNodeCell.h"


/**
 *  enum used for store the next led state
 */
typedef NS_ENUM(uint8_t, LED_NEXT_STATE) {
    
    /**
     *  the starting state is unknown
     */
    LED_NEXT_STATE_UNKNOWN,

    LED_NEXT_STATE_ON,
    
    LED_NEXT_STATE_OFF
};

/**
 *  string to use for the temperature
 */
static NSString *sTempUnit;

/**
 *  string to use for the pressure
 */
static NSString *sPressUnit;

/**
 *  string to use for the humidity
 */
static NSString *sHumidityUnit;

/**
 *  string to use for the humidity
 */
static NSString *sLuminosityUnit;

@interface EnviromentalRemoteNodeCell ()

    @property (weak, nonatomic) IBOutlet UILabel *nodeIdLabel;
    @property (weak, nonatomic) IBOutlet UILabel *pressureLabel;
    @property (weak, nonatomic) IBOutlet UILabel *temperatureLabel;
    @property (weak, nonatomic) IBOutlet UILabel *humidityLabel;
    @property (weak, nonatomic) IBOutlet UISwitch *ledStatusSwitch;
    @property (weak, nonatomic) IBOutlet UIImageView *ledImage;
    @property (weak, nonatomic) IBOutlet UILabel *ledLabel;
    @property (weak, nonatomic) IBOutlet UILabel *disconnectedLabel;


@end

@implementation EnviromentalRemoteNodeCell{
    
    LED_NEXT_STATE mNextLedStatus;
    
}

+(void)setPressureUnit:(NSString*)unit{
    sPressUnit=unit;
}

+(void)setLuminosityUnit:(NSString*)unit{
    sLuminosityUnit=unit;
}

+(void)setTemperatureUnit:(NSString*)unit{
    sTempUnit=unit;
}

+(void)setHumidityUnit:(NSString*)unit{
    sHumidityUnit=unit;
}

/**
 *  change the led image, it is change only if the state is equal to the led status
 * that we are waiting, this avoid to update the image with old data
 *
 *  @param newStatus led status
 */
-(void)changeLedStatus:(bool)newStatus{
    if(mNextLedStatus==LED_NEXT_STATE_UNKNOWN ||
       (mNextLedStatus==LED_NEXT_STATE_ON && newStatus) ||
       (mNextLedStatus==LED_NEXT_STATE_OFF && !newStatus)) {
        if (newStatus) {
            _ledImage.image = [UIImage imageNamed:@"led_on_icon"];
            [_ledStatusSwitch setOn:true animated:false];
        } else {
            _ledImage.image = [UIImage imageNamed:@"led_off_icon"];
            [_ledStatusSwitch setOn:false animated:false];
        }//if-else
        _ledStatusSwitch.hidden=false;
        _ledLabel.hidden=true;
    }//if
}


/**
 *  function called when the user change the switch state
 *
 *  @param sender switch that change
 */
- (IBAction)switchChangeStatus:(UISwitch *)sender {
    
    if(sender.isOn){
        mNextLedStatus=LED_NEXT_STATE_ON;
    }else{
        mNextLedStatus=LED_NEXT_STATE_OFF;
    }//if
    
    if(_envDelegate!=nil)
        [_envDelegate ledStatusDidChangeForNodeId:_nodeId newState:sender.isOn];
}

-(void)setLuminosity:(uint16_t)luminosity{
    _ledLabel.hidden=false;
    _ledStatusSwitch.hidden=true;
    _ledLabel.text=[NSString stringWithFormat:@"%d %@",
                    luminosity,sLuminosityUnit];
    _ledImage.image = [UIImage imageNamed:@"led_on_icon"];
}

-(void)setStatusCellColor:(EnviromentalRemoteNodeData*)data {
    
    if (data.status == 1) { //remote node is disconnected
//        NSLog(@"staus: %d --> light gray color", data.status);//DEBUG
        [self setBackgroundColor:[UIColor lightGrayColor]];
        self.disconnectedLabel.hidden = false;
    }
    if (data.status == 0) { //remote node has connected yet
//        NSLog(@"staus: %d --> white color", data.status);//DEBUG
        [self setBackgroundColor:[UIColor whiteColor]];
        self.disconnectedLabel.hidden = true;
    }
}

-(BOOL)updateContent:(EnviromentalRemoteNodeData*)data{
//    NSLog(@"ERNC updateContent");//DEBUG
    
    BOOL nodeChanges=false;
    
     [self setStatusCellColor:data];
    
    if(_nodeId!=data.nodeId){
        mNextLedStatus=LED_NEXT_STATE_UNKNOWN;
        nodeChanges=true;
    }
    _nodeId = data.nodeId;
    _nodeIdLabel.text= [NSString stringWithFormat:@"0x%0.4X",data.nodeId];
    _temperatureLabel.text = [NSString stringWithFormat:@"%.2f %@",
                              data.temperature,sTempUnit];
    _pressureLabel.text = [NSString stringWithFormat:@"%.2f %@",data.pressure,
                           sPressUnit];
    _humidityLabel.text = [NSString stringWithFormat:@"%.2f %@",data.humidity,
                           sHumidityUnit];
    
    if([data hasLuminosity])
        [self setLuminosity:data.luminosity];
    else if([data hasLedStatus])
        [self changeLedStatus: data.ledStatus];
    return nodeChanges;
    
}

@end
