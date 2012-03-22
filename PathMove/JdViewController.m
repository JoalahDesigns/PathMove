//
//  JdViewController.m
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


#import "JdViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "PathDefinitions.h"
#import "JdBezierPath.h"
#import "JdConfiguration.h"
#import "JdSetupViewController.h"

#pragma mark - Local variables

@implementation JdViewController
{
    UIImageView* theImage;          // The image as displayed on the screen
    UIImageView* smallImage;        // The size of the small image is used to animation parameters
    
    UIButton* clear;                // Clear the current image from the screen
    UIButton* run;                  // Run the path movement animation
    UIButton* setup;                // Setup the animation's behaviour
    
    JdGraphicView* graphicView;     // Background view that shows the path
    CGRect canvas;                  // Extents of the background view
    
    JdConfiguration* configuration; // Configuration details passed to the setup view controller
    
    float scaleUpFactor;            // Factor to scale small image up
    float scaleDownFactor;          // Factor to scale large image down
}

#pragma mark - Imitialisation

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

        self.view.backgroundColor = [UIColor colorWithRed:250.0f/255.0f green:250.0f/255.0F blue:195.0f/255.0f alpha:1.0f];
        self.title = @"Display";
        configuration = [[JdConfiguration alloc] init];
        scaleUpFactor = 1.5;
        scaleDownFactor = 0.4;
    
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
}

#pragma mark - Helper functions

-(void)removeImage
{
    if (theImage != nil && [theImage isDescendantOfView:self.view]) {
        [theImage removeFromSuperview];
        theImage = nil;
    }
}

-(void)addImage
{
    if (theImage!=nil && ![theImage isDescendantOfView:self.view]) [self.view addSubview:theImage];
}

#pragma mark - Button Actions

-(void)clearPressed:(UIButton *) byButton
{
    [self removeImage];
}

-(void)setupPressed:(UIButton *) byButton
{
    JdSetupViewController* setupViewController = [[JdSetupViewController alloc] init];
    setupViewController.configuration = configuration;
    [self.navigationController pushViewController:setupViewController animated:YES];
}

-(void)runPressed:(UIButton *) byButton
{
    // Get the start and end locations of the animation
    [graphicView setNeedsDisplay];

    CGPoint start = CGPointMake(CGRectGetMidX(canvas), CGRectGetMidY(canvas));
    
    CGPoint destination = graphicView.destination;
    destination.x += CGRectGetMinX(canvas);
    destination.y += CGRectGetMinY(canvas);
    
    // Ensure that only 1 copy of the image is added to the view
    [self removeImage];
    theImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:configuration.sizeChange==kSizeChangeShrink?@"ghostBig":@"ghost"]];
    
    // The rotation mode inherently rotates the object so that the horizontal axis follows the path tangent
    // So if we want the object to follow the path along its vertical axis, we need to pre rotate the 
    // object by 90 degrees.
    if (configuration.preRotate) {
        theImage.transform = CGAffineTransformMakeRotation(90*M_PI/180.0);
    }
    
    [self addImage];
    
    
    // Calculate the bezier path that the image will follow.
    JdBezierPath* jdPath = [[JdBezierPath alloc] init];
    
    BezierPathEnumType lOut = configuration.leadOut;
    BezierPathEnumType lIn = configuration.leadIn;
    
    
    [jdPath buildSmoothPathFrom:start leadingOut:lOut to:destination leadingIn:lIn forObjectSize:smallImage.image.size];
    
    float duration = 0.0f;
    switch (lOut) {
        case kBezierPathArc: duration+=0.5; break;
        case kBezierPathHook: duration +=0.75; break;
        case kBezierPathOrbit: duration += 1.25; break;
        default: duration += 0.5; break;
    }
    
    switch (lIn) {
        case kBezierPathArc: duration+=0.5; break;
        case kBezierPathHook: duration +=0.75; break;
        case kBezierPathOrbit: duration += 1.25; break;
        default: duration += 0.5; break;
    }
    
    // Set up scaling
    float scaleFactor = configuration.sizeChange==kSizeChangeNone?1.0:configuration.sizeChange==kSizeChangeGrow?scaleUpFactor:scaleDownFactor;
    
    // Set up and execute the animations
    [UIView animateWithDuration:duration 
                     animations:^{
                         // Prepare my own keypath animation for the layer position.
                         // The layer position is the same as the view center.
                         CAKeyframeAnimation *positionAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
                         positionAnimation.path = [jdPath path].CGPath;
                         positionAnimation.rotationMode = configuration.rotate?kCAAnimationRotateAuto:nil;
                         positionAnimation.removedOnCompletion = NO;
                         positionAnimation.duration = duration;
                         
                         // Set up final transformation of the image
                         [CATransaction setCompletionBlock:^{
                             CGAffineTransform finalTransform = [theImage.layer.presentationLayer affineTransform];
                             [theImage.layer removeAnimationForKey:positionAnimation.keyPath];
                             theImage.transform = finalTransform;
                         }];
                         theImage.transform = CGAffineTransformScale(theImage.transform, scaleFactor, scaleFactor);
                         theImage.center = destination;
                         
                         // Copy properties from UIView's animation.
                         CAAnimation *autoAnimation = [theImage.layer animationForKey:positionAnimation.keyPath];
                         positionAnimation.duration = autoAnimation.duration;
                         positionAnimation.fillMode = autoAnimation.fillMode;
                         
                         // Replace UIView's animation with my animation.
                         [theImage.layer addAnimation:positionAnimation forKey:positionAnimation.keyPath];
                     } ];    
}

#pragma mark - View lifecycle

-(void)viewWillAppear:(BOOL)animated
{
    [self removeImage];
    
    // Ensure that the backgound uses the parameters from the setup
    graphicView.quadrant = configuration.quadrant;
    graphicView.leadOut = configuration.leadOut;
    graphicView.leadIn = configuration.leadIn;
    graphicView.annotateBezierPaths = configuration.annotate;
    [graphicView setNeedsDisplay];
}

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
    [super loadView];
    
    // Set up the user buttons
    clear = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [clear setTitle:@"Clear" forState:UIControlStateNormal];
    clear.frame = CGRectMake(10, 360, 60, 40);
    [clear addTarget:self action:@selector(clearPressed:) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:clear];
    
    run = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [run setTitle:@"Run" forState:UIControlStateNormal];
    run.frame = CGRectMake(130, 360, 60, 40);
    [run addTarget:self action:@selector(runPressed:) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:run];
    
    setup = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [setup setTitle:@"Setup" forState:UIControlStateNormal];
    setup.frame = CGRectMake(250, 360, 60, 40);
    [setup addTarget:self action:@selector(setupPressed:) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:setup];

    // Don't have an image displayed on screen yet
    theImage = nil;

    // Load the small image solely for the sake of getting its size
    // The image size is used to help define the bezier path 
    smallImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ghost"]];
    
    // Load the background view that displays the bezier path on screen
    canvas = CGRectMake(10, 10, 300, 300);
    graphicView = [[JdGraphicView alloc] initWithFrame:canvas forQuadrant:configuration.quadrant withLeadOut:configuration.leadOut andLeadIn:configuration.leadIn andObjectSize:smallImage.image.size];
    
    [self.view addSubview:graphicView];
    
 }

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
