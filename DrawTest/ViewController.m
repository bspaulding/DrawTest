//
//  ViewController.m
//  DrawTest
//
//  Created by Bradley Spaulding on 11/24/14.
//  Copyright (c) 2014 Motingo. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
  @property (weak, nonatomic) IBOutlet UIImageView *imageView;
@end

@implementation ViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  red = 0;
  green = 0;
  blue = 0;
  brush = 10.0;
  opacity = 1.0;
  [self setupScreenConnectionNotificationHandlers];
  [self checkForExistingScreenAndInitializeIfPresent];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
  touchesMoved = NO;
  UITouch *touch = [touches anyObject];
  lastPoint = [touch locationInView:self.view];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
  touchesMoved = YES;
  UITouch *touch = [touches anyObject];
  CGPoint currentPoint = [touch locationInView:self.imageView];
  
  UIGraphicsBeginImageContext(self.view.frame.size);
  
  [self.imageView.image drawInRect:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
  [externalImageView.image drawInRect:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];

  CGContextRef context = UIGraphicsGetCurrentContext();
  CGContextMoveToPoint(context, lastPoint.x, lastPoint.y);
  CGContextAddLineToPoint(context, currentPoint.x, currentPoint.y);
  CGContextSetLineCap(context, kCGLineCapRound);
  CGContextSetLineWidth(context, brush);
  CGContextSetRGBStrokeColor(context, red, green, blue, 1.0);
  CGContextSetBlendMode(context, kCGBlendModeNormal);
  CGContextStrokePath(context);
  
  self.imageView.image = UIGraphicsGetImageFromCurrentImageContext();
  externalImageView.image = UIGraphicsGetImageFromCurrentImageContext();
  
  UIGraphicsEndImageContext();
  
  lastPoint = currentPoint;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
  if (touchesMoved) {
    return;
  }
  
  UIGraphicsBeginImageContext(self.view.frame.size);
  
  [self.imageView.image drawInRect:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
  [externalImageView.image drawInRect:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
  
  CGContextRef context = UIGraphicsGetCurrentContext();
  CGContextSetLineCap(context, kCGLineCapRound);
  CGContextSetLineWidth(context, brush);
  CGContextSetRGBStrokeColor(context, red, green, blue, opacity);
  CGContextMoveToPoint(context, lastPoint.x, lastPoint.y);
  CGContextAddLineToPoint(context, lastPoint.x, lastPoint.y);
  CGContextStrokePath(context);
  CGContextFlush(context);
  
  self.imageView.image = UIGraphicsGetImageFromCurrentImageContext();
  externalImageView.image = self.imageView.image;
  
  UIGraphicsEndImageContext();
}

- (void)setupScreenConnectionNotificationHandlers {
  NSNotificationCenter* center = [NSNotificationCenter defaultCenter];
  
  [center addObserver:self selector:@selector(handleScreenConnectNotification:)
                 name:UIScreenDidConnectNotification object:nil];
  [center addObserver:self selector:@selector(handleScreenDisconnectNotification:)
                 name:UIScreenDidDisconnectNotification object:nil];
}

- (void)handleScreenConnectNotification:(NSNotification*)aNotification {
  [self checkForExistingScreenAndInitializeIfPresent];
}

- (void)handleScreenDisconnectNotification:(NSNotification*)aNotification {
  if (_secondWindow) {
    // Hide and then delete the window.
    _secondWindow.hidden = YES;
    // [_secondWindow release];
    _secondWindow = nil;
  }
}

- (void)checkForExistingScreenAndInitializeIfPresent {
  NSLog(@"checkForExistingScreenAndInitializeIfPresent");
  if ([[UIScreen screens] count] > 1) {
    // Associate the window with the second screen.
    // The main screen is always at index 0.
    UIScreen*    secondScreen = [[UIScreen screens] objectAtIndex:1];
    CGRect        screenBounds = secondScreen.bounds;
    
    _secondWindow = [[UIWindow alloc] initWithFrame:screenBounds];
    _secondWindow.screen = secondScreen;
    
    // Add a white background to the window
    UIView* whiteField = [[UIView alloc] initWithFrame:screenBounds];
    whiteField.backgroundColor = [UIColor whiteColor];
    
    [_secondWindow addSubview:whiteField];
    // [whiteField release];
    
    externalImageView = [[UIImageView alloc] initWithFrame:screenBounds];
    externalImageView.image = self.imageView.image;
    [whiteField addSubview:externalImageView];
    
    // Go ahead and show the window.
    _secondWindow.hidden = NO;
  }
}

@end
