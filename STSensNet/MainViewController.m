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

#include <BlueSTSDK/BlueSTSDKManager.h>
#include <BlueSTSDK_Gui/BlueSTSDKMainViewController.h>

#include "MainViewController.h"
#include "Demo/GenericRemoteNodeTableViewController.h"
#include "Demo/Feature/STSensNetGenericRemoteFeature.h"
#include "Demo/Feature/STSensNetCommandFeature.h"

#define DID_RUN_BEFORE @"STSensNet.didRunBefore"
#define FIRST_RUN_ALERT_TITLE @"Warning"
#define FIRST_RUN_ALERT_TEXT @"This app is compatible with FP-NET-BLESTAR1 v1.2 or above package, please update the Nucleo firmware."
#define FIRST_RUN_ALERT_NEW_FW @"Go to web site"
#define FIRST_RUN_ALERT_NEW_URL @"http://www.st.com/content/st_com/en/products/embedded-software/mcus-embedded-software/stm32-embedded-software/stm32-ode-function-pack-sw/fp-net-blestar1.html"
#define FIRST_RUN_ALLER_NOT_SHOW @"Don't show again"

@interface MainViewController ()<BlueSTSDKAboutViewControllerDelegate,
    BlueSTSDKNodeListViewControllerDelegate>

@end

@implementation MainViewController


-(void) dismisInfoDialog{
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:DID_RUN_BEFORE];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(BOOL) showInfoDialog{
    return ![[NSUserDefaults standardUserDefaults] boolForKey:DID_RUN_BEFORE];
}

-(void) showInforDialog{
    
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:FIRST_RUN_ALERT_TITLE
                                                                       message:FIRST_RUN_ALERT_TEXT
                                                                preferredStyle:UIAlertControllerStyleAlert];
    
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK"
                                                                style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {}];
    
        UIAlertAction* dontShowAction = [UIAlertAction actionWithTitle:FIRST_RUN_ALLER_NOT_SHOW
                                                            style:UIAlertActionStyleDestructive
                                                          handler:^(UIAlertAction * action) {
                                                              [self dismisInfoDialog];
                                                          }];
    
        UIAlertAction* openUrlAction =[UIAlertAction actionWithTitle: FIRST_RUN_ALERT_NEW_FW
                                                               style: UIAlertActionStyleDefault
                                                             handler: ^(UIAlertAction * action) {
                                                                 UIApplication *app = [UIApplication sharedApplication];
                                                                        NSURL *url = [NSURL URLWithString:FIRST_RUN_ALERT_NEW_URL];
                                                                        [app openURL:url];
                                                             }//handler
                                       ];
        
        
        [alert addAction:openUrlAction];
        [alert addAction:defaultAction];
        [alert addAction:dontShowAction];
        [self presentViewController:alert animated:YES completion:nil];
}

/**
 *  laod the BlueSTSDKMainView and set the delegate for it
 */
-(void)viewDidLoad{
    [super viewDidLoad];
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"BlueSTSDKMainView"
                                                         bundle:[NSBundle bundleForClass:BlueSTSDKMainViewController.class]];
    
    BlueSTSDKMainViewController *mainView = (BlueSTSDKMainViewController*) [storyBoard instantiateInitialViewController];
    mainView.delegateMain=nil;
    mainView.delegateAbout=self;
    mainView.delegateNodeList=self;
    
    // add the feature to the Nucleo device
    uint8_t deviceId = 0x81;
    // the feature will be mapped in the characteristic
    // 0x10000000-0001-11e1-ac36-0002a5d5c51b
    NSDictionary * temp = @{
                            @0x00080000: [STSensNetGenericRemoteFeature class],
                            @0x00040000: [STSensNetCommandFeature class]
                            };
    
    BlueSTSDKManager *manager = [BlueSTSDKManager sharedInstance];
    [manager addFeatureForNode:deviceId features:temp];
    
    [self pushViewController:mainView animated:TRUE];
    
}

-(void)viewDidAppear:(BOOL)animated{
    if([self showInfoDialog])
       [self showInforDialog];
}

#pragma mark - BlueSTSDKAboutViewControllerDelegate

- (NSString*) htmlFile{
    NSBundle *bundle = [NSBundle mainBundle];
    return [bundle pathForResource:@"text" ofType:@"html"];
}

- (UIImage*) headImage{
    return [UIImage imageNamed:@"press_contact.jpg"];
}

#pragma mark - BlueSTSDKNodeListViewControllerDelegate

/**
 *  filter the node for show only the ones with remote features
 *
 *  @param node node to filter
 *
 *  @return true if it is a nucleo of type 0x81
 */
-(bool) displayNode:(BlueSTSDKNode*)node{
    return true;
    //return (node.type == BlueSTSDKNodeTypeNucleo) && (node.typeId == 0x81);
}


/**
 *  when the user select a node show the main view form the DemoView storyboard
 *
 *  @param node node selected
 *
 *  @return controller with the demo to show
 */
-(UIViewController*) demoViewControllerWithNode:(BlueSTSDKNode*)node
                                    menuManager:(id<BlueSTSDKViewControllerMenuDelegate>)menuManager;{
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"DemoView" bundle:nil];
    
    GenericRemoteNodeTableViewController *mainView =
        (GenericRemoteNodeTableViewController*) [storyBoard instantiateInitialViewController];
    
    mainView.node=node;
    mainView.menuDelegate = menuManager;
    
    return mainView;
}



@end
