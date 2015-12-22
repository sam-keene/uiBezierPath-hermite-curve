//
//  GameScene.m
//  GrainOfSandClock
//
//  Created by Sam Keene on 10/17/15.
//  Copyright (c) 2015 Sam Keene. All rights reserved.
//

#import "GameScene.h"
#import "UIBezierPath+Interpolation.h"

@interface GameScene ()
@property (nonatomic, strong) CAShapeLayer *lineShape;
@property (nonatomic, strong) NSMutableArray *circlePoints;
@property (nonatomic, strong) NSMutableArray *circles;
@end

@implementation GameScene
{
    UIBezierPath *path;
}

-(void)didMoveToView:(SKView *)view {
    /* Setup your scene here */
    
    path = [UIBezierPath bezierPath];
    [path setLineWidth:2.0];
    
    self.circles = [NSMutableArray array];
    
    self.backgroundColor = [UIColor blackColor];

    self.circlePoints = [NSMutableArray array];
    
    [self createGrainOfSand];
    
}

- (void)createGrainOfSand
{
    [self.circlePoints removeAllObjects];
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat r = screenRect.size.width *.8 / 2.;
    CGFloat centerX = screenRect.size.width/2.;
    CGFloat centerY = screenRect.size.height/2.;
    
    NSInteger numPoints = 8;
    CGFloat step = (2*M_PI) / numPoints;
    CGFloat angle = step;
    
    for(NSInteger i = 0; i < numPoints; i++){
        CGFloat xPos = r * cos(angle) + [self randomValueBetween:-50 andValue:50];
        CGFloat yPos = r * sin(angle) *1.5 + [self randomValueBetween:-50 andValue:50];
        
        CGPoint point = CGPointMake(centerX + xPos, centerY + yPos);
        NSValue *valuePoint = [NSValue valueWithCGPoint:point];
        [self.circlePoints addObject:valuePoint];
        
        angle += step;
        
    }
    
    // REMOVE CURRENT CIRCLES
    for (SKShapeNode *circle in self.circles) {
        [circle removeFromParent];
    }
    
    [self.circles removeAllObjects];
    
    // ADD NEW CIRCLES
    for (NSValue *valuePoint in self.circlePoints) {
        SKShapeNode *circle = [self circleShape];
        circle.position = [valuePoint CGPointValue];
        [self addChild:circle];
        [self.circles addObject:circle];
    }
    
    [self animateLine];

}

- (void)animateLine
{
    path = [UIBezierPath bezierPath];
    [path setLineWidth:2.0];
    
    self.lineShape = nil;
    
    CGMutablePathRef linePath = nil;
    linePath = CGPathCreateMutable();
    self.lineShape = [CAShapeLayer layer];
    
    self.lineShape.lineWidth = 2.0f;
    self.lineShape.lineCap = kCALineJoinMiter;
    self.lineShape.strokeColor = [[UIColor whiteColor] CGColor];
    self.lineShape.lineWidth = 1;
    self.lineShape.fillColor = [[UIColor clearColor] CGColor];
    
    NSValue *startValue = [self.circlePoints objectAtIndex:0];
    CGPoint startPoint = [startValue CGPointValue];
    CGPathMoveToPoint(linePath, NULL, startPoint.x, startPoint.y);
    
    for (NSInteger i = 0; i<self.circlePoints.count; i++) {
        NSValue *nextValue = [self.circlePoints objectAtIndex:i];
        CGPoint nextPoint = [nextValue CGPointValue];
        NSLog(@"nextPoint x : %f", nextPoint.x);

    }
 
    //path = [UIBezierPath interpolateCGPointsWithCatmullRom:self.circlePoints closed:YES alpha:.5];
    path = [UIBezierPath interpolateCGPointsWithHermite:self.circlePoints closed:YES];
    
    self.lineShape.path =  path.CGPath;
    [self.view.layer addSublayer:self.lineShape];
    
    //Animate path
    CABasicAnimation *pathAnimation2 = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    pathAnimation2.delegate = self;
    pathAnimation2.duration = 2.0f;
    pathAnimation2.fromValue = [NSNumber numberWithFloat:0.0f];
    pathAnimation2.toValue = [NSNumber numberWithFloat:1.0f];
    pathAnimation2.repeatCount = 0;
    [self.lineShape addAnimation:pathAnimation2 forKey:@"strokeEnd"];
    
    CGPathRelease(linePath);

}


-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
}

- (float)randomValueBetween:(float)low andValue:(float)high {
    return (((float) arc4random() / 0xFFFFFFFFu) * (high - low)) + low;
}

- (void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)flag
{
    [self.lineShape removeFromSuperlayer];
    
    [self createGrainOfSand];
}

- (SKShapeNode *)circleShape
{
    CGRect circle = CGRectMake(0, 0, 10.0, 10.0);
    SKShapeNode *shapeNode = [[SKShapeNode alloc] init];
    shapeNode.path = [UIBezierPath bezierPathWithOvalInRect:circle].CGPath;
    shapeNode.fillColor = [SKColor whiteColor];
    shapeNode.lineWidth = 0;
    return shapeNode;
}
@end
