//
//  JdGraphicView.m
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



#import "JdGraphicView.h"
#import "JdBezierPath.h"

#pragma mark - Local definitions
@interface JdGraphicView()
@property (readwrite, nonatomic) CGPoint destination;
@end

#pragma mark - Local variables
@implementation JdGraphicView
{
    CGPoint centre;     // Centre point of the view
    CGPoint q1Centre;   // Marker location for 1st quadrant cross
    CGPoint q2Centre;   // Marker location for 2nd quadrant cross
    CGPoint q3Centre;   // Marker location for 3rd quadrant cross
    CGPoint q4Centre;   // Marker location for 4th quadrant cross
}

#pragma mark - Synthesize

@synthesize quadrant;
@synthesize leadIn;
@synthesize leadOut;
@synthesize destination;
@synthesize objectSize;
@synthesize annotateBezierPaths;


#pragma mark - Initialisation

- (id)initWithFrame:(CGRect)frame forQuadrant:(DestinationQuadrant)quad withLeadOut:(BezierPathEnumType)lOut andLeadIn:(BezierPathEnumType)lIn andObjectSize:(CGSize)objSize
{
    self = [super initWithFrame:frame];
    if (self) {
        quadrant = quad;
        leadOut = lOut;
        leadIn = lIn;
        objectSize = objSize;
        self.backgroundColor = [UIColor whiteColor];
        annotateBezierPaths = NO;
    }
    return self;
}

#pragma mark - Drawing functions

// Draw a cross at a set point
-(void)drawCross:(UIBezierPath*) path atPoint:(CGPoint)point withHeight:(float)height andWidth:(float)width
{
   [path removeAllPoints];
    
   [path moveToPoint:CGPointMake(point.x, point.y-height/2)];
   [path addLineToPoint:CGPointMake(point.x, point.y+height/2)];
    
   [path stroke];
    
   [path removeAllPoints];

   [path moveToPoint:CGPointMake(point.x-width/2.0, point.y)];
   [path addLineToPoint:CGPointMake(point.x+width/2.0, point.y)];
    
   [path stroke];
}

// Draw the complete graphics background of the view
-(void)drawNormal:(CGRect)rect
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(ctx, [UIColor blackColor].CGColor);
    CGContextSetLineWidth(ctx, 2);
    
    // Draw the axis
    UIBezierPath *path = [[UIBezierPath alloc] init]; 
    centre = CGPointMake(rect.size.width/2.0, rect.size.height/2.0);
    [self drawCross:path atPoint:centre withHeight:rect.size.height andWidth:rect.size.width];    
    
    // Draw the markers at each quadrant
    CGContextSetStrokeColorWithColor(ctx, [UIColor redColor].CGColor);
    float dX = rect.size.width/6.0;
    float dY = rect.size.height/6.0;
    float sizeX = 16.0;
    float sizeY = 16.0;
    
    q1Centre = CGPointMake(rect.size.width - dX, dY);
    [self drawCross:path atPoint:q1Centre withHeight:sizeY andWidth:sizeX];
    
    q2Centre = CGPointMake(dX, dY);
    [self drawCross:path atPoint:q2Centre withHeight:sizeY andWidth:sizeX];
    
    q3Centre = CGPointMake(dX, rect.size.height - dY);
    [self drawCross:path atPoint:q3Centre withHeight:sizeY andWidth:sizeX];
    
    q4Centre = CGPointMake(rect.size.width - dX, rect.size.height - dY);
    [self drawCross:path atPoint:q4Centre withHeight:sizeY andWidth:sizeX];
    
    // find the destination
    destination = centre;
    switch (quadrant) {
        case kFirstQuadrant: destination = q1Centre; break;
        case kSecondQuadrant: destination = q2Centre; break;
        case kThirdQuadrant: destination = q3Centre; break;
        case kFouthQuadrant: destination = q4Centre; break;
            
        default:
            break;
    }
    
    // Draw a box around the object at the centre and destination
    CGContextSetStrokeColorWithColor(ctx, [UIColor greenColor].CGColor);
    CGRect centreBox = CGRectMake(centre.x-objectSize.width/2.0, centre.y-objectSize.height/2.0, objectSize.width, objectSize.height);
    path = [UIBezierPath bezierPathWithRect:centreBox];
    [path stroke];
    
    CGRect destBox = CGRectMake(destination.x-objectSize.width/2.0, destination.y-objectSize.height/2.0, objectSize.width, objectSize.height);
    path = [UIBezierPath bezierPathWithRect:destBox];
    [path stroke];
    
    // Draw the actual bezier path
    JdBezierPath* jdPath = [[JdBezierPath alloc] init];
    
    [jdPath buildSmoothPathFrom:centre leadingOut:leadOut to:destination leadingIn:leadIn forObjectSize:objectSize];
    [jdPath strokeWithColor:[UIColor blueColor] andThickness:4.0f inContext:ctx];
    
    
    // Annotate the bezier path with the point and control point locations
    if (annotateBezierPaths) {
        [jdPath markWithColor:[UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:0.5] strokeThickness:2.0f pointColor:[UIColor grayColor] pointRadius:3.0 inContext:ctx];
    }
}

// Draw the view with custom graphics
- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    [self drawNormal:rect];
}

@end
