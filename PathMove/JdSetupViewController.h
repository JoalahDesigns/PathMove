//
//  JdSetupViewCOntroller.h
//  PathMove
//

// Copyright (c) 2012, Joalah Designs LLC
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are met:
// 
//    1. Redistributions of source code must retain the above copyright
//       notice, this list of conditions and the following disclaimer.
// 
//    2. Redistributions in binary form must reproduce the above copyright
//       notice, this list of conditions and the following disclaimer in the
//       documentation and/or other materials provided with the distribution.
// 
//    3. Neither the name of Joalah Designs LLC nor the
//       names of its contributors may be used to endorse or promote products
//       derived from this software without specific prior written permission.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
// ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
// WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
// DISCLAIMED. IN NO EVENT SHALL JOALAH DESIGNS LLC BE LIABLE FOR ANY
// DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
// (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
// LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
// ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
// (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
// SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


#import <UIKit/UIKit.h>
#import "JdConfiguration.h"

// View controller for setting user selections

@interface JdSetupViewController : UIViewController

// User selctions to be passed back to the caller
@property (strong, nonatomic) JdConfiguration* configuration;


@property (strong, nonatomic) IBOutlet UISegmentedControl* segQuadrant;
@property (strong, nonatomic) IBOutlet UISegmentedControl* segLeadOut;
@property (strong, nonatomic) IBOutlet UISegmentedControl* segLeadIn;
@property (strong, nonatomic) IBOutlet UISwitch* swRotate;
@property (strong, nonatomic) IBOutlet UISwitch* swAnnotate;
@property (strong, nonatomic) IBOutlet UISegmentedControl* segSize;
@property (strong, nonatomic) IBOutlet UISwitch* swPreRotate;

-(IBAction)quadrantChanged:(id)sender;
-(IBAction)leadOutChanged:(id)sender;
-(IBAction)leadInChanged:(id)sender;
-(IBAction)rotateChanged:(id)sender;
-(IBAction)annotateChanged:(id)sender;
-(IBAction)sizeChanged:(id)sender;
-(IBAction)preRotateChanged:(id)sender;

@end
