//
//  JdBezierPath.m
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


#import "JdBezierPath.h"

#pragma mark - Local definitions

// Internal definition of the ending quadrant of the bezier path
typedef enum {
    kFirst = 0,
    kSecond,
    kThird,
    kFourth,
    kIdentical  // Path start and finish are the same
    
} BezierFinishQuandrantEnumType;

#pragma mark - Local method definitions
@interface JdBezierPath()
-(void)addArcLeadOutFrom:(CGPoint)start toQuadrant:(BezierFinishQuandrantEnumType)quadrant forRadius:(float)radius andObjectSize:(CGSize)size;
-(void)addArcLeadInTo:(CGPoint)finish inQuadrant:(BezierFinishQuandrantEnumType)quadrant forRadius:(float)radius andObjectSize:(CGSize)size;
-(void)addHookLeadOutFrom:(CGPoint)start toQuadrant:(BezierFinishQuandrantEnumType)quadrant forRadius:(float)radius andObjectSize:(CGSize)size;
-(void)addHookLeadInTo:(CGPoint)finish inQuadrant:(BezierFinishQuandrantEnumType)quadrant forRadius:(float)radius andObjectSize:(CGSize)size;
-(void)addOrbitLeadOutFrom:(CGPoint)start toQuadrant:(BezierFinishQuandrantEnumType)quadrant forRadius:(float)radius andObjectSize:(CGSize)size;
-(void)addOrbitLeadInTo:(CGPoint)finish inQuadrant:(BezierFinishQuandrantEnumType)quadrant forRadius:(float)radius andObjectSize:(CGSize)size;
@end


#pragma mark - Local variables

@implementation JdBezierPath
{
    NSMutableArray* bezierPoints;   // Array of points in the path
}

#pragma mark - (Class) Utilities

// Quadrants are non standard.  They are defined with (0,0) being the top left of the screen
// and X & Y increasing as you go to bottom right of the screen
+(BezierFinishQuandrantEnumType)getQuandrantFrom:(CGPoint)origin to:(CGPoint)point
{
    if (point.x>origin.x && point.y<origin.x) return kFirst;
    
    if (point.x<origin.x && point.y<origin.x) return kSecond;
    
    if (point.x<origin.x && point.y>origin.y) return kThird;
    
    if (point.x>origin.x && point.y>origin.y) return kFourth;
    
    return kIdentical;
}

// Calculate the tangent of a line
+(float)lineTangentFrom:(CGPoint)start to:(CGPoint)finish
{
    float dX = finish.x-start.x;
    float dY = -(finish.y-start.y);
    if (100*fabsf(dX)<fabsf(dY)) return signbit(dY)==0?90.0f:-90.0f;
    return atan2f(dY, dX)*180.0f / M_PI;
}

// Make a control point that is anchored at a point and extends away 
// at a set angle and radius
+(CGPoint)makeControlFor:(CGPoint)point atAngle:(float)angle andRadius:(float)radius
{
    float theta = angle * M_PI / 180.0;
    return CGPointMake(point.x+radius*cos(theta), point.y-radius*sin(theta));
}

#pragma mark - Initialisation
-(id)init
{
    if(!(self = [super init])) return self;
    bezierPoints = [[NSMutableArray alloc] init];
    
    return self;
}

#pragma mark - (Public) path creation
// remove all the points from this path
-(void)clearPath
{
    [bezierPoints removeAllObjects];
}

// Set the starting point of the path
-(void)startFrom:(CGPoint)start departAngle:(float)angle atRadius:(float)radius
{
    [bezierPoints addObject:[[JdBezierPoint alloc] initStart:start withControlOut:[JdBezierPath makeControlFor:start atAngle:angle andRadius:radius]]];
}

// Curve to the next point in the bezier path
-(void)curveTo:(CGPoint)location approachAngle:(float)angle atInRadius:(float)inRadius atOutRadius:(float)outRadius
{
    [bezierPoints addObject:[[JdBezierPoint alloc] initCurve:location  withControlIn:[JdBezierPath makeControlFor:location atAngle:angle+180 andRadius:inRadius] andControlOut:[JdBezierPath makeControlFor:location atAngle:angle andRadius:outRadius]]];
}

// Return the iOS definition of this bezier path
-(UIBezierPath*)path
{
    if ([bezierPoints count]==0) return nil;
    
    // Build the real bezier path
    UIBezierPath* path = [[UIBezierPath alloc] init];
    JdBezierPoint* start = [bezierPoints objectAtIndex:0];
    CGPoint lastControlPointOut = start.controlOut;
    
    [path moveToPoint:start.location];
    
    for(int i=1; i<[bezierPoints count]; i++)
    {
        JdBezierPoint* current = [bezierPoints objectAtIndex:i];
        [path addCurveToPoint:current.location controlPoint1:lastControlPointOut controlPoint2:current.controlIn];
        lastControlPointOut = current.controlOut;
    }
    
    
    return path;
}

// Build a smooth bezier path from the start to finish locations
// using defined lead in and lead out paths,
// linking them with a smooth transition
-(void)buildSmoothPathFrom:(CGPoint) start leadingOut:(BezierPathEnumType)leadOut to:(CGPoint)finish leadingIn:(BezierPathEnumType)leadIn forObjectSize:(CGSize)size
{
    [self clearPath];
    
    BezierFinishQuandrantEnumType quadrant = [JdBezierPath getQuandrantFrom:start to:finish];
    if (quadrant==kIdentical) return;
    
    float ctrlRadius = MAX(size.width, size.height)/2.0f;
    
    switch(leadOut) {
        case kBezierPathArc:
            [self addArcLeadOutFrom:start toQuadrant:quadrant forRadius:ctrlRadius andObjectSize:size];
            break;
            
        case kBezierPathHook:
            [self addHookLeadOutFrom:start toQuadrant:quadrant forRadius:ctrlRadius andObjectSize:size];
            break;
            
        case kBezierPathOrbit:
            [self addOrbitLeadOutFrom:start toQuadrant:quadrant forRadius:ctrlRadius andObjectSize:size];
            break;
            
        default:
            break;
    }
    
    
    switch(leadIn) {
        case kBezierPathArc:
            [self addArcLeadInTo:finish inQuadrant:quadrant forRadius:ctrlRadius andObjectSize:size];
            break;
            
        case kBezierPathHook:
            [self addHookLeadInTo:finish inQuadrant:quadrant forRadius:ctrlRadius andObjectSize:size];
            break;
            
        case kBezierPathOrbit:
            [self addOrbitLeadInTo:finish inQuadrant:quadrant forRadius:ctrlRadius andObjectSize:size];
            break;
            
        default:
            break;
    }
    
}



#pragma mark - (Public) Path decoration

// Stoke out the complete bezier path with a set color and thickness
-(void)strokeWithColor:(UIColor*)strokeColor andThickness:(float)thickness inContext:(CGContextRef) ctx
{
    // Get the reall bezier path
    UIBezierPath* path = [self path];
    if (path==nil) return;
    
    // Now stroke it
    CGContextSetStrokeColorWithColor(ctx, strokeColor.CGColor);
    CGContextSetLineWidth(ctx, thickness);
    [path stroke];
}

// Mark and stroke out the control points in the bezier path with a set color and thickness
-(void)markWithColor:(UIColor*)strokeColor strokeThickness:(float)thickness pointColor:(UIColor*)pColor pointRadius:(float)pRadius inContext:(CGContextRef) ctx
{
    // Build and stroke the controls 
    if ([bezierPoints count]==0) return;
    

    UIBezierPath* path = [[UIBezierPath alloc] init];
    for (JdBezierPoint* point in bezierPoints)
    {
        CGContextSetStrokeColorWithColor(ctx, strokeColor.CGColor);
        CGContextSetFillColorWithColor(ctx, strokeColor.CGColor);
        CGContextSetLineWidth(ctx, thickness);

        [path removeAllPoints];
        [path moveToPoint:point.controlIn];
        [path addLineToPoint:point.location];
        [path addLineToPoint:point.controlOut];
        [path stroke];

        CGContextFillEllipseInRect(ctx, CGRectMake(point.controlIn.x-pRadius/2, point.controlIn.y-pRadius/2, pRadius, pRadius));
        CGContextFillEllipseInRect(ctx, CGRectMake(point.controlOut.x-pRadius/2, point.controlOut.y-pRadius/2, pRadius, pRadius));
        
        
        CGContextSetStrokeColorWithColor(ctx, pColor.CGColor);
        CGContextSetFillColorWithColor(ctx, pColor.CGColor);
        CGContextFillEllipseInRect(ctx, CGRectMake(point.location.x-pRadius/2, point.location.y-pRadius/2, pRadius, pRadius));
        
        
    }

    
    
}

#pragma mark - (Internal) Build Arc Paths

// Lead out with an arc from the starting point
-(void)addArcLeadOutFrom:(CGPoint)start toQuadrant:(BezierFinishQuandrantEnumType)quadrant forRadius:(float)radius andObjectSize:(CGSize)size
{
    switch (quadrant) {
        case kFirst:
            [self startFrom:start departAngle:90.0f atRadius:1.0f*radius];
            [self curveTo:CGPointMake(start.x + size.width, start.y - 1.5*size.height) approachAngle:45.0f atInRadius:2.5f*radius atOutRadius:2.0f*radius];
            break;
            
        case kSecond:
            [self startFrom:start departAngle:90.0f atRadius:1.0f*radius];
            [self curveTo:CGPointMake(start.x - size.width, start.y - 1.5f*size.height) approachAngle:135.0f atInRadius:2.5f*radius atOutRadius:2.0f*radius];
            break;
            
        case kThird:
            [self startFrom:start departAngle:90.0f atRadius:3.5f*radius];
            [self curveTo:CGPointMake(start.x - 1.5*size.width, start.y - 0.5f*size.height) approachAngle:260.0f atInRadius:2.5f*radius atOutRadius:2.0f*radius];
            break;
            
        case kFourth:
            [self startFrom:start departAngle:90.0f atRadius:3.5f*radius];
            [self curveTo:CGPointMake(start.x + 1.5*size.width, start.y - 0.5f*size.height) approachAngle:280.0f atInRadius:2.5f*radius atOutRadius:2.0f*radius];
            break;
            
        default:
            return;
            break;
    }
}

// Lead into the finish point with an arc
-(void)addArcLeadInTo:(CGPoint)finish inQuadrant:(BezierFinishQuandrantEnumType)quadrant forRadius:(float)radius andObjectSize:(CGSize)size
{
    CGPoint entrance;
    switch (quadrant) {
        case kFirst:
            entrance = CGPointMake(finish.x - size.width, finish.y + 1.5*size.height);
            [self curveTo:entrance approachAngle:45.0f atInRadius:2.0f*radius atOutRadius:2.5f*radius];
            [self curveTo:finish approachAngle:90.0f atInRadius:1.0f*radius atOutRadius:0.0f*radius];
            break;
            
        case kSecond:
            entrance = CGPointMake(finish.x + size.width, finish.y + 1.5*size.height);
            [self curveTo:entrance approachAngle:135.0f atInRadius:2.0f*radius atOutRadius:2.5f*radius];
            [self curveTo:finish approachAngle:90.0f atInRadius:1.0f*radius atOutRadius:0.0f*radius];
            break;
            
        case kThird:
            entrance = CGPointMake(finish.x + 1.5*size.width, finish.y + 0.5f*size.height);
            [self curveTo:entrance approachAngle:260.0f atInRadius:2.0f*radius atOutRadius:2.0f*radius];
            [self curveTo:finish approachAngle:90.0f atInRadius:3.5f*radius atOutRadius:0.0f*radius];
            break;
            
        case kFourth:
            entrance = CGPointMake(finish.x - 1.5*size.width, finish.y + 0.5f*size.height);
            [self curveTo:entrance approachAngle:280.0f atInRadius:2.0f*radius atOutRadius:2.0f*radius];
            [self curveTo:finish approachAngle:90.0f atInRadius:3.5f*radius atOutRadius:0.0f*radius];
            break;
            
        default:
            return;
            break;
    }
}


#pragma mark - (Internal) Build Hook Paths

// Lead out from the starting point with a hook
-(void)addHookLeadOutFrom:(CGPoint)start toQuadrant:(BezierFinishQuandrantEnumType)quadrant forRadius:(float)radius andObjectSize:(CGSize)size
{
    switch (quadrant) {
        case kFirst:
            [self startFrom:start departAngle:90.0f atRadius:1.0f*radius];
            [self curveTo:CGPointMake(start.x -1.0f * size.width, start.y - 1.0f *size.height) approachAngle:135.0f atInRadius:1.0f*radius atOutRadius:2.0f*radius];
            [self curveTo:CGPointMake(start.x -0.0f * size.width, start.y - 2.0f *size.height) approachAngle:0.0f atInRadius:1.0f*radius atOutRadius:2.0f*radius];
            break;
            
        case kSecond:
            [self startFrom:start departAngle:90.0f atRadius:1.0f*radius];
            [self curveTo:CGPointMake(start.x +1.0f * size.width, start.y - 1.0f *size.height) approachAngle:45.0f atInRadius:1.0f*radius atOutRadius:2.0f*radius];
            [self curveTo:CGPointMake(start.x -0.0f * size.width, start.y - 2.0f *size.height) approachAngle:180.0f atInRadius:1.0f*radius atOutRadius:2.0f*radius];
            break;
            
        case kThird:
            [self startFrom:start departAngle:90.0f atRadius:1.5f*radius];
            [self curveTo:CGPointMake(start.x + 0.5f * size.width, start.y - 1.5f *size.height) approachAngle:135.0f atInRadius:1.5f*radius atOutRadius:1.0f*radius];
            [self curveTo:CGPointMake(start.x - 0.5f * size.width, start.y - 1.5f *size.height) approachAngle:210.0f atInRadius:1.0f*radius atOutRadius:1.0f*radius];
            [self curveTo:CGPointMake(start.x -1.5f * size.width, start.y + 0.5f *size.height) approachAngle:260.0f atInRadius:2.0f*radius atOutRadius:2.0f*radius];
            break;
            
        case kFourth:
            [self startFrom:start departAngle:90.0f atRadius:1.5f*radius];
            [self curveTo:CGPointMake(start.x - 0.5f * size.width, start.y - 1.5f *size.height) approachAngle: 45.0f atInRadius:1.5f*radius atOutRadius:1.0f*radius];
            [self curveTo:CGPointMake(start.x + 0.5f * size.width, start.y - 1.5f *size.height) approachAngle:-30.0f atInRadius:1.0f*radius atOutRadius:1.0f*radius];
            [self curveTo:CGPointMake(start.x + 1.5f * size.width, start.y + 0.5f *size.height) approachAngle:280.0f atInRadius:2.0f*radius atOutRadius:2.0f*radius];
            break;
            
        default:
            return;
            break;
    }
}

// Lead into the finish point with a hook
-(void)addHookLeadInTo:(CGPoint)finish inQuadrant:(BezierFinishQuandrantEnumType)quadrant forRadius:(float)radius andObjectSize:(CGSize)size
{
    CGPoint entrance;
    switch (quadrant) {
        case kFirst:
            entrance = CGPointMake(finish.x - size.width, finish.y + 1.5*size.height);
            [self curveTo:entrance approachAngle:0.0f atInRadius:1.0f*radius atOutRadius:1.0f*radius];
            [self curveTo:CGPointMake(finish.x +0.5f * size.width, finish.y + 1.0f *size.height) approachAngle:90.0f atInRadius:1.0f*radius atOutRadius:1.0f*radius];
            [self curveTo:finish approachAngle:90.0f atInRadius:1.5f*radius atOutRadius:0.0f*radius];
            break;
            
        case kSecond:
            entrance = CGPointMake(finish.x + size.width, finish.y + 1.5*size.height);
            [self curveTo:entrance approachAngle:180.0f atInRadius:1.0f*radius atOutRadius:1.0f*radius];
            [self curveTo:CGPointMake(finish.x - 0.5f * size.width, finish.y + 1.0f *size.height) approachAngle:90.0f atInRadius:1.0f*radius atOutRadius:1.0f*radius];
            [self curveTo:finish approachAngle:90.0f atInRadius:1.5f*radius atOutRadius:0.0f*radius];
            break;
            
        case kThird:
            entrance = CGPointMake(finish.x + 0.5f * size.width, finish.y + 1.5*size.height);
            [self curveTo:entrance approachAngle:180.0f atInRadius:2.5f*radius atOutRadius:1.0f*radius];
            [self curveTo:CGPointMake(finish.x - 0.5f * size.width, finish.y + 1.0f *size.height) approachAngle:90.0f atInRadius:1.0f*radius atOutRadius:1.0f*radius];
            [self curveTo:finish approachAngle:90.0f atInRadius:1.5f*radius atOutRadius:0.0f*radius];
            break;
            
        case kFourth:
            entrance = CGPointMake(finish.x - 0.5f * size.width, finish.y + 1.5*size.height);
            [self curveTo:entrance approachAngle:00.0f atInRadius:2.5f*radius atOutRadius:1.0f*radius];
            [self curveTo:CGPointMake(finish.x + 0.5f * size.width, finish.y + 1.0f *size.height) approachAngle:90.0f atInRadius:1.0f*radius atOutRadius:1.0f*radius];
            [self curveTo:finish approachAngle:90.0f atInRadius:1.5f*radius atOutRadius:0.0f*radius];
            break;
            
        default:
            return;
            break;
    }
}

#pragma mark - (Internal) Build Orbit Parts

// Lead out from the starting point with an orbit
-(void)addOrbitLeadOutFrom:(CGPoint)start toQuadrant:(BezierFinishQuandrantEnumType)quadrant forRadius:(float)radius andObjectSize:(CGSize)size
{
    switch (quadrant) {
        case kFirst:
            [self startFrom:start departAngle:90.0f atRadius:3.5f*radius];
            [self curveTo:CGPointMake(start.x - 1.5f * size.width, start.y - 0.0f *size.height) approachAngle:270.0f atInRadius:2.0f*radius atOutRadius:1.0f*radius];
            [self curveTo:CGPointMake(start.x - 0.0f * size.width, start.y + 1.5f *size.height) approachAngle:0.0f atInRadius:2.0f*radius atOutRadius:2.0f*radius];
            [self curveTo:CGPointMake(start.x + 1.5f * size.width, start.y + 0.0f *size.height) approachAngle:70.0f atInRadius:1.0f*radius atOutRadius:2.0f*radius];
            break;
            
        case kSecond:
            [self startFrom:start departAngle:90.0f atRadius:3.5f*radius];
            [self curveTo:CGPointMake(start.x + 1.5f * size.width, start.y - 0.0f *size.height) approachAngle:270.0f atInRadius:2.0f*radius atOutRadius:1.0f*radius];
            [self curveTo:CGPointMake(start.x + 0.0f * size.width, start.y + 1.5f *size.height) approachAngle:180.0f atInRadius:2.0f*radius atOutRadius:2.0f*radius];
            [self curveTo:CGPointMake(start.x - 1.5f * size.width, start.y + 0.0f *size.height) approachAngle:110.0f atInRadius:1.0f*radius atOutRadius:2.0f*radius];
            break;
            
        case kThird:
            [self startFrom:start departAngle:90.0f atRadius:3.5f*radius];
            [self curveTo:CGPointMake(start.x - 1.5f * size.width, start.y - 0.0f *size.height) approachAngle:270.0f atInRadius:2.0f*radius atOutRadius:1.0f*radius];
            [self curveTo:CGPointMake(start.x - 0.0f * size.width, start.y + 1.5f *size.height) approachAngle:0.0f atInRadius:2.0f*radius atOutRadius:2.0f*radius];
            [self curveTo:CGPointMake(start.x + 1.5f * size.width, start.y + 0.0f *size.height) approachAngle:90.0f atInRadius:1.0f*radius atOutRadius:7.0f*radius];
            [self curveTo:CGPointMake(start.x - 2.5f * size.width, start.y + 0.0f *size.height) approachAngle:280.0f atInRadius:5.0f*radius atOutRadius:4.0f*radius];
            break;
            
        case kFourth:
            [self startFrom:start departAngle:90.0f atRadius:3.5f*radius];
            [self curveTo:CGPointMake(start.x + 1.5f * size.width, start.y - 0.0f *size.height) approachAngle:270.0f atInRadius:2.0f*radius atOutRadius:1.0f*radius];
            [self curveTo:CGPointMake(start.x + 0.0f * size.width, start.y + 1.5f *size.height) approachAngle:180.0f atInRadius:2.0f*radius atOutRadius:2.0f*radius];
            [self curveTo:CGPointMake(start.x - 1.5f * size.width, start.y + 0.0f *size.height) approachAngle:90.0f atInRadius:1.0f*radius atOutRadius:7.0f*radius];
            [self curveTo:CGPointMake(start.x + 2.5f * size.width, start.y + 0.0f *size.height) approachAngle:260.0f atInRadius:5.0f*radius atOutRadius:4.0f*radius];
            break;
            
        default:
            return;
            break;
    }
}

// Lead into the finish point with an orbit
-(void)addOrbitLeadInTo:(CGPoint)finish inQuadrant:(BezierFinishQuandrantEnumType)quadrant forRadius:(float)radius andObjectSize:(CGSize)size
{
    CGPoint entrance;
    switch (quadrant) {
        case kFirst:
            entrance = CGPointMake(finish.x - 1.75f * size.width, finish.y + 0.5*size.height);
            [self curveTo:entrance approachAngle:80.0f atInRadius:2.0f*radius atOutRadius:6.0f*radius];
            [self curveTo:CGPointMake(finish.x + 1.5f * size.width, finish.y + 0.0f *size.height) approachAngle:260.0f atInRadius:4.0f*radius atOutRadius:3.0f*radius];
            [self curveTo:finish approachAngle:90.0f atInRadius:3.0f*radius atOutRadius:0.0f*radius];
            break;
            
        case kSecond:
            entrance = CGPointMake(finish.x + 1.75f * size.width, finish.y + 0.5*size.height);
            [self curveTo:entrance approachAngle:110.0f atInRadius:2.0f*radius atOutRadius:6.0f*radius];
            [self curveTo:CGPointMake(finish.x - 1.5f * size.width, finish.y + 0.0f *size.height) approachAngle:280.0f atInRadius:4.0f*radius atOutRadius:3.0f*radius];
            [self curveTo:finish approachAngle:90.0f atInRadius:3.0f*radius atOutRadius:0.0f*radius];
            break;
            
        case kThird:
            entrance = CGPointMake(finish.x + 1.0f * size.width, finish.y + 1.75*size.height);
            [self curveTo:entrance approachAngle:200.0f atInRadius:3.5f*radius atOutRadius:3.5f*radius];
            [self curveTo:CGPointMake(finish.x - 1.5f * size.width, finish.y + 0.0f *size.height) approachAngle:70.0f atInRadius:2.0f*radius atOutRadius:4.0f*radius];
            [self curveTo:CGPointMake(finish.x + 1.25f * size.width, finish.y + 0.0f *size.height) approachAngle:280.0f atInRadius:3.0f*radius atOutRadius:3.0f*radius];
            [self curveTo:finish approachAngle:90.0f atInRadius:3.0f*radius atOutRadius:0.0f*radius];
            break;
            
        case kFourth:
            entrance = CGPointMake(finish.x - 1.0f * size.width, finish.y + 1.75*size.height);
            [self curveTo:entrance approachAngle:-20.0f atInRadius:3.5f*radius atOutRadius:3.5f*radius];
            [self curveTo:CGPointMake(finish.x + 1.5f * size.width, finish.y + 0.0f *size.height) approachAngle:110.0f atInRadius:2.0f*radius atOutRadius:4.0f*radius];
            [self curveTo:CGPointMake(finish.x - 1.25f * size.width, finish.y + 0.0f *size.height) approachAngle:260.0f atInRadius:3.0f*radius atOutRadius:3.0f*radius];
            [self curveTo:finish approachAngle:90.0f atInRadius:3.0f*radius atOutRadius:0.0f*radius];
            break;
            
        default:
            return;
            break;
    }
}






@end
