//
//  ViewController.h
//  DrawTest
//
//  Created by Bradley Spaulding on 11/24/14.
//  Copyright (c) 2014 Motingo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <OpenEars/LanguageModelGenerator.h>
#import <OpenEars/PocketsphinxController.h>
#import <OpenEars/AcousticModel.h>
#import <OpenEars/OpenEarsEventsObserver.h>
#import <AVFoundation/AVFoundation.h>

@interface ViewController : UIViewController <OpenEarsEventsObserverDelegate> {
  BOOL touchesMoved;
  CGPoint lastPoint;
  CGFloat brush;
  CGFloat red;
  CGFloat green;
  CGFloat blue;
  CGFloat opacity;
  UIWindow *_secondWindow;
  UIImageView *externalImageView;
  UILabel *maskedCurrentWordLabel;
  NSString *currentWord;
  PocketsphinxController *pocketsphinxController;
  OpenEarsEventsObserver *openEarsEventsObserver;
  AVAudioPlayer *audioPlayer;
}

@property (strong, nonatomic) PocketsphinxController *pocketsphinxController;
@property (strong, nonatomic) OpenEarsEventsObserver *openEarsEventsObserver;
@property (strong, nonatomic) NSArray *words;

- (void)clearDrawing;
@end

