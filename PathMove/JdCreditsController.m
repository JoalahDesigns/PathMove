//
//  JdCreditsController.m
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

#import "JdCreditsController.h"

#pragma mark - Implementation
@implementation JdCreditsController

#pragma mark - Instance Methods

// Initialise the class
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"Credits";

    }
    return self;
}

// This App only supports portrait orientation
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


// User wants to see the Joalah Designs LLC website
-(IBAction)displayJoalahDesigns:(id)sender
{
    NSURL *target = [[NSURL alloc] initWithString:@"http://www.JoalahDesigns.com"];
    [[UIApplication sharedApplication] openURL:target];
}

// User wants to see the Joalah Apps website for this App
-(IBAction)displayJoalahAppsPathMove:(id)sender
{
    NSURL *target = [[NSURL alloc] initWithString:@"http://www.JoalahApps.com/PathMove"];
    [[UIApplication sharedApplication] openURL:target];
}


@end
