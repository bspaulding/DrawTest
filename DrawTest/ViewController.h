//
//  ViewController.h
//  DrawTest
//
//  Created by Bradley Spaulding on 11/24/14.
//  Copyright (c) 2014 Motingo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController {
  BOOL touchesMoved;
  CGPoint lastPoint;
  CGFloat brush;
  CGFloat red;
  CGFloat green;
  CGFloat blue;
  CGFloat opacity;
  UIWindow *_secondWindow;
  UIImageView *externalImageView;
}

@end

