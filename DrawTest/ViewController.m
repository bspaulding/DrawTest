//
//  ViewController.m
//  DrawTest
//
//  Created by Bradley Spaulding on 11/24/14.
//  Copyright (c) 2014 Motingo. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
  @property (weak, nonatomic) IBOutlet UILabel *currentWordLabel;
  @property (weak, nonatomic) IBOutlet UIImageView *imageView;
@end

@implementation ViewController

@synthesize pocketsphinxController;
@synthesize openEarsEventsObserver;

- (void)viewDidLoad {
  [super viewDidLoad];
  red = 0;
  green = 0;
  blue = 0;
  brush = 10.0;
  opacity = 1.0;
  
  NSString *filename = @"words.txt";
  NSString *path = [[NSBundle mainBundle] pathForResource:[filename stringByDeletingPathExtension] ofType:[filename pathExtension]];
  NSString *text = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:NULL];
  self.words = [text componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
  
  NSURL *dingSoundURL  = [[NSBundle mainBundle] URLForResource:@"ding" withExtension:@"wav"];
  audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:dingSoundURL error:nil];
  
  maskedCurrentWordLabel = [[UILabel alloc] init];
  maskedCurrentWordLabel.textAlignment = NSTextAlignmentCenter;
  maskedCurrentWordLabel.font = [UIFont boldSystemFontOfSize:24.0];
  
  UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(correctAnswerProvided)];
  [self.currentWordLabel addGestureRecognizer:tapGesture];
  
  [self setupScreenConnectionNotificationHandlers];
  [self checkForExistingScreenAndInitializeIfPresent];
  
  [self setupLanguageModel];
  
  [self newRound];
}

- (IBAction)clearButtonPressed:(id)sender {
  [self clearDrawing];
}

- (void)clearDrawing {
  self.imageView.image = nil;
  externalImageView.image = nil;
}

- (void)correctAnswerProvided {
  [audioPlayer play];
  [self.currentWordLabel setText:@"Correct!"];
  [self performSelector:@selector(newRound) withObject:nil afterDelay:1.0];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)newRound {
  NSUInteger randomIndex = arc4random() % [self.words count];
  currentWord = self.words[randomIndex];
  [self.currentWordLabel setText: currentWord];
  NSMutableString *maskedString = [@"" mutableCopy];
  for (int i = 0; i < currentWord.length; i++) {
    [maskedString appendString:@"_ "];
  }
  [maskedCurrentWordLabel setText:maskedString];
  [self clearDrawing];
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
    
    externalImageView = [[UIImageView alloc] initWithFrame:CGRectMake(screenBounds.size.width/2 - self.imageView.frame.size.width/2, screenBounds.size.height/2 - self.imageView.frame.size.height/2, self.imageView.frame.size.width, self.imageView.frame.size.width)];
    externalImageView.image = self.imageView.image;
    [externalImageView.layer setBorderColor:[[UIColor grayColor] CGColor]];
    [externalImageView.layer setBorderWidth:1.0];
    [whiteField addSubview:externalImageView];

    maskedCurrentWordLabel.frame = CGRectMake(0,20,screenBounds.size.width,24);
    [whiteField addSubview:maskedCurrentWordLabel];
    
    // Go ahead and show the window.
    _secondWindow.hidden = NO;
  }
}

- (void)setupLanguageModel {
  NSString *name = @"EnglishLanguageModel";
  
  LanguageModelGenerator *lmGenerator = [[LanguageModelGenerator alloc] init];
  NSError *err = [lmGenerator generateLanguageModelFromArray:self.words withFilesNamed:name forAcousticModelAtPath:[AcousticModel pathToModel:@"AcousticModelEnglish"]];
  NSDictionary *languageGeneratorResults = nil;
  
  NSString *lmPath = nil;
  NSString *dicPath = nil;
  
  if([err code] == noErr) {
    languageGeneratorResults = [err userInfo];
    
    lmPath = [languageGeneratorResults objectForKey:@"LMPath"];
    dicPath = [languageGeneratorResults objectForKey:@"DictionaryPath"];
    [self.openEarsEventsObserver setDelegate:self];
    [self.pocketsphinxController startListeningWithLanguageModelAtPath:lmPath dictionaryAtPath:dicPath acousticModelAtPath:[AcousticModel pathToModel:@"AcousticModelEnglish"] languageModelIsJSGF:NO];
  } else {
    NSLog(@"Error: %@",[err localizedDescription]);
  }
}

- (PocketsphinxController *)pocketsphinxController {
  if (pocketsphinxController == nil) {
    pocketsphinxController = [[PocketsphinxController alloc] init];
  }
  return pocketsphinxController;
}

- (OpenEarsEventsObserver *)openEarsEventsObserver {
  if (openEarsEventsObserver == nil) {
    openEarsEventsObserver = [[OpenEarsEventsObserver alloc] init];
  }
  return openEarsEventsObserver;
}

#pragma mark OpenEarsObserver Protocol


- (void) pocketsphinxDidReceiveHypothesis:(NSString *)hypothesis recognitionScore:(NSString *)recognitionScore utteranceID:(NSString *)utteranceID {
  NSLog(@"The received hypothesis is %@ with a score of %@ and an ID of %@", hypothesis, recognitionScore, utteranceID);
  if ([hypothesis.lowercaseString isEqualToString:currentWord.lowercaseString]) {
    [self correctAnswerProvided];
  }
}

- (void) pocketsphinxDidStartCalibration {
  NSLog(@"Pocketsphinx calibration has started.");
}

- (void) pocketsphinxDidCompleteCalibration {
  NSLog(@"Pocketsphinx calibration is complete.");
}

- (void) pocketsphinxDidStartListening {
  NSLog(@"Pocketsphinx is now listening.");
}

- (void) pocketsphinxDidDetectSpeech {
  NSLog(@"Pocketsphinx has detected speech.");
}

- (void) pocketsphinxDidDetectFinishedSpeech {
  NSLog(@"Pocketsphinx has detected a period of silence, concluding an utterance.");
}

- (void) pocketsphinxDidStopListening {
  NSLog(@"Pocketsphinx has stopped listening.");
}

- (void) pocketsphinxDidSuspendRecognition {
  NSLog(@"Pocketsphinx has suspended recognition.");
}

- (void) pocketsphinxDidResumeRecognition {
  NSLog(@"Pocketsphinx has resumed recognition.");
}

- (void) pocketsphinxDidChangeLanguageModelToFile:(NSString *)newLanguageModelPathAsString andDictionary:(NSString *)newDictionaryPathAsString {
  NSLog(@"Pocketsphinx is now using the following language model: \n%@ and the following dictionary: %@",newLanguageModelPathAsString,newDictionaryPathAsString);
}

- (void) pocketSphinxContinuousSetupDidFail { // This can let you know that something went wrong with the recognition loop startup. Turn on OPENEARSLOGGING to learn why.
  NSLog(@"Setting up the continuous recognition loop has failed for some reason, please turn on OpenEarsLogging to learn more.");
}

- (void) testRecognitionCompleted {
  NSLog(@"A test file that was submitted for recognition is now complete.");
}

@end
