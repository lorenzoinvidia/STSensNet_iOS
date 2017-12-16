# Installing and working with CorePlot

1. Go to the project directory

2. Create a file named "Podfile" like this

  platform :ios, '9.0'
  use_frameworks!

  target 'STSensNet' do
    pod 'CorePlot', '~> 2.2'
    end
  workspace 'STSensNet'

3. Install the dependencies
  $ pod install

4. Make sure to always open the Xcode workspace instead of the project file when building your project:
  $ open STSensNet.xcworkspace

5. Import the dependencies
  #import <CorePlot-CocoaTouch.h>
