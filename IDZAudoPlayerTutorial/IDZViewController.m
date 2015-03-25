//
//  IDZViewController.m
//  IDZAudoPlayerTutorial
//
//  Created by idz on 10/1/12.
//  Copyright (c) 2012 iosdeveloperzone.com. All rights reserved.
//

#import "IDZViewController.h"


#define IDZTrace() NSLog(@"%s", __PRETTY_FUNCTION__)

@interface IDZViewController ()

@property (nonatomic, strong) AVAudioPlayer* player;
@property (nonatomic, strong) NSTimer* timer;

- (void)updateDisplay;
- (void)updateSliderLabels;

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player 
                       successfully:(BOOL)flag;
- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player 
                                 error:(NSError *)error;

@end

@implementation IDZViewController
@synthesize currentTimeLabel = mCurrentTimeLabel;
@synthesize deviceCurrentTimeLabel = mDeviceCurrentTimeLabel;
@synthesize durationLabel = mDurationLabel;
@synthesize numberOfChannelsLabel = mNumberOfChannels;
@synthesize playingLabel = mPlayingLabel;
@synthesize elapsedTimeLabel = mElapsedTimeLabel;
@synthesize remainingTimeLabel = mRemainingTimeLabel;
@synthesize currentTimeSlider = mCurrentTimeSlider;
@synthesize playButton = mPlayingButton;
@synthesize pauseButton = mPauseButton;
@synthesize stopButton = mStopButton;
@synthesize player = mPlayer;
@synthesize timer = mTimer;


#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.  
    NSURL* url = [[NSBundle mainBundle] URLForResource:@"Rondo_Alla_Turka_Short" withExtension:@"aiff"];
    NSAssert(url, @"URL is valid."); 
    NSError* error = nil;
    self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
    if(!self.player)
    {
        NSLog(@"Error creating player: %@", error);
    }
    self.player.delegate = self;
    [self.player prepareToPlay];
    // Fill in the labels that do not change
    self.durationLabel.text = [NSString stringWithFormat:@"%.02fs",self.player.duration];
    self.numberOfChannelsLabel.text = [NSString stringWithFormat:@"%d", self.player.numberOfChannels];
    self.currentTimeSlider.minimumValue = 0.0f;
    self.currentTimeSlider.maximumValue = self.player.duration;
    [self updateDisplay];
}

- (void)viewDidUnload
{
    [self setPauseButton:nil];
    [self setPlayButton:nil];
    [self setStopButton:nil];
    [self setCurrentTimeLabel:nil];
    [self setDeviceCurrentTimeLabel:nil];
    [self setDurationLabel:nil];
    [self setNumberOfChannelsLabel:nil];
    [self setPlayingLabel:nil];
    [self setElapsedTimeLabel:nil];
    [self setRemainingTimeLabel:nil];
    [self setCurrentTimeSlider:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

#pragma mark - Actions

- (IBAction)play:(id)sender {
    IDZTrace();
    [self.player play];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(timerFired:) userInfo:nil repeats:YES];
                  
}

- (IBAction)pause:(id)sender {
    IDZTrace();
    [self.player pause];
    [self stopTimer];
    [self updateDisplay];
}

- (IBAction)stop:(id)sender {
    IDZTrace();
    [self.player stop];
    [self stopTimer];
    self.player.currentTime = 0;
    [self.player prepareToPlay];
    [self updateDisplay];
}

- (IBAction)currentTimeSliderValueChanged:(id)sender
{
    if(self.timer)
        [self stopTimer];
    [self updateSliderLabels];
}

- (IBAction)currentTimeSliderTouchUpInside:(id)sender
{
    [self.player stop];
    self.player.currentTime = self.currentTimeSlider.value;
    [self.player prepareToPlay];
    [self play:self];
}

#pragma mark - Display Update
- (void)updateDisplay
{
    NSTimeInterval currentTime = self.player.currentTime;
    NSString* currentTimeString = [NSString stringWithFormat:@"%.02f", currentTime];
    
    self.currentTimeSlider.value = currentTime;
    [self updateSliderLabels];
    
    self.currentTimeLabel.text = currentTimeString;
    self.playingLabel.text = self.player.playing ? @"YES" : @"NO";
    self.deviceCurrentTimeLabel.text = [NSString stringWithFormat:@"%.02f", self.player.deviceCurrentTime];
}

- (void)updateSliderLabels
{
    NSTimeInterval currentTime = self.currentTimeSlider.value;
    NSString* currentTimeString = [NSString stringWithFormat:@"%.02f", currentTime];
    
    self.elapsedTimeLabel.text =  currentTimeString;
    self.remainingTimeLabel.text = [NSString stringWithFormat:@"%.02f", self.player.duration - currentTime];
}

#pragma mark - Timer
- (void)timerFired:(NSTimer*)timer
{
    [self updateDisplay];
}

- (void)stopTimer
{
    [self.timer invalidate];
    self.timer = nil;
    [self updateDisplay];
}

#pragma mark - AVAudioPlayerDelegate
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    NSLog(@"%s successfully=%@", __PRETTY_FUNCTION__, flag ? @"YES"  : @"NO");
    [self stopTimer];
    [self updateDisplay];
}

- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error
{
    NSLog(@"%s error=%@", __PRETTY_FUNCTION__, error);
    [self stopTimer];
    [self updateDisplay];
}

@end
