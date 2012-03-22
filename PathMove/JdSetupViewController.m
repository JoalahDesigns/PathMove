//
//  JdSetupViewCOntroller.m
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


#import "JdSetupViewController.h"

#pragma mark - Local method declarations
@interface JdSetupViewController() 
-(BezierPathEnumType)makePathEnum:(int)selection;
-(int)makeIntFromPathEnum:(BezierPathEnumType)path;
-(DestinationQuadrant)makeDestinationEnum:(int)selection;
-(int)makeIntFromDestinationEnum:(DestinationQuadrant)destination;
-(SizeChangeEnum)makeSizeEnum:(int)selection;
-(int)makeIntFromSizeEnum:(SizeChangeEnum)sizeChange;
@end

@implementation JdSetupViewController

#pragma mark - Synthesize
@synthesize configuration;
@synthesize segQuadrant;
@synthesize segLeadIn;
@synthesize segLeadOut;
@synthesize swRotate;
@synthesize swAnnotate;
@synthesize segSize;
@synthesize swPreRotate;

#pragma mark - Initialisation
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"Setup";
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Preload the controls with the current user configuration
    if (configuration != nil) {
        segQuadrant.selectedSegmentIndex = [self makeIntFromDestinationEnum:configuration.quadrant];
        segLeadOut.selectedSegmentIndex = [self makeIntFromPathEnum:configuration.leadOut];
        segLeadIn.selectedSegmentIndex = [self makeIntFromPathEnum:configuration.leadIn];
        swRotate.on = configuration.rotate;
        swAnnotate.on = configuration.annotate;
        segSize.selectedSegmentIndex = [self makeIntFromSizeEnum:configuration.sizeChange];
        swPreRotate.on = configuration.preRotate;
    } else {
        segQuadrant.selectedSegmentIndex = 0;
        segLeadOut.selectedSegmentIndex = 0;
        segLeadIn.selectedSegmentIndex = 0;
        swRotate.on = NO;
        swAnnotate.on = NO;
        segSize.selectedSegmentIndex = 0;
        swPreRotate.on = NO;
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Convert values between ints and enums

// Note that you could cast directly between enum and int,
// But that assumes a non-sparse enum and/or an enum that starts at 0
// These functions shield us from those assumptions

-(BezierPathEnumType)makePathEnum:(int)selection
{
    switch (selection) {
        case 0: return kBezierPathArc; break;
        case 1: return kBezierPathHook; break;
        case 2: return kBezierPathOrbit; break;
        default: return kBezierPathArc; break;
    }
}

-(int)makeIntFromPathEnum:(BezierPathEnumType)path
{
    switch (path) {
        case kBezierPathArc: return 0; break;
        case kBezierPathHook: return 1; break;
        case kBezierPathOrbit: return 2; break;
        default: return 0; break;
    }
    
}

-(DestinationQuadrant)makeDestinationEnum:(int)selection
{
    switch (selection) {
        case 0: return kFirstQuadrant; break;
        case 1: return kSecondQuadrant; break;
        case 2: return kThirdQuadrant; break;
        case 3: return kFouthQuadrant; break;
        default: return kFirstQuadrant; break;
    }
}

-(int)makeIntFromDestinationEnum:(DestinationQuadrant)destination
{
    switch (destination) {
        case kFirstQuadrant: return 0; break;
        case kSecondQuadrant: return 1; break;
        case kThirdQuadrant: return 2; break;
        case kFouthQuadrant: return 3; break;
        default: return 0; break;
    }
}

-(SizeChangeEnum)makeSizeEnum:(int)selection
{
    switch (selection) {
        case 0: return kSizeChangeNone; break;
        case 1: return kSizeChangeGrow; break;
        case 2: return kSizeChangeShrink; break;
        default: return kSizeChangeNone; break;
    }
}

-(int)makeIntFromSizeEnum:(SizeChangeEnum)sizeChange
{
    switch (sizeChange) {
        case kSizeChangeNone: return 0; break;
        case kSizeChangeGrow: return 1; break;
        case kSizeChangeShrink: return 2; break;
        default: return 0; break;
    }
}


#pragma mark - Responses to user controls

-(IBAction)quadrantChanged:(id)sender
{
    configuration.quadrant = [self makeDestinationEnum:((UISegmentedControl*)(sender)).selectedSegmentIndex];
}

-(IBAction)leadOutChanged:(id)sender
{
    configuration.leadOut = [self makePathEnum:((UISegmentedControl*)(sender)).selectedSegmentIndex];
}


-(IBAction)leadInChanged:(id)sender
{
    configuration.leadIn = [self makePathEnum:((UISegmentedControl*)(sender)).selectedSegmentIndex];
}


-(IBAction)rotateChanged:(id)sender
{
    configuration.rotate =((UISwitch*)sender).on;
}


-(IBAction)annotateChanged:(id)sender
{
    configuration.annotate =((UISwitch*)sender).on;
}


-(IBAction)sizeChanged:(id)sender
{
    configuration.sizeChange = [self makeSizeEnum:((UISegmentedControl*)(sender)).selectedSegmentIndex];
}

-(IBAction)preRotateChanged:(id)sender
{
    configuration.preRotate = ((UISwitch*)sender).on;
}

@end
