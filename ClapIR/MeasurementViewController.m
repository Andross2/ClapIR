//
//  MeasurementViewController.m
//  ClapIR
//
//  Created by Stephen Tarzia on 3/19/12.
//

#import "MeasurementViewController.h"
#import "PlotView.h"

@interface MeasurementViewController (){
    UILabel* _rt60Label;
    UILabel* _backgroundLabel;
    UIButton* _resetButton;
    PlotView* _plot;
    float* _plotCurve;
}
-(void)reset;
@end

@implementation MeasurementViewController
@synthesize recorder;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    _rt60Label = [[UILabel alloc] initWithFrame:CGRectMake(10, 40, 320-20, 60)];
    _rt60Label.text = @"";
    [self.view addSubview:_rt60Label];

    _backgroundLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 200, 320-20, 60)];
    [self.view addSubview:_backgroundLabel];
    
    _resetButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    _resetButton.frame = CGRectMake( 100, 250, 320-200, 40 );
    [_resetButton setTitle:@"reset" forState:UIControlStateNormal];
    [_resetButton addTarget:self 
                     action:@selector(reset) 
           forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_resetButton];
    
    _plot = [[PlotView alloc] initWithFrame:CGRectMake(10, 300, 320-20, 150)];
    [self.view addSubview:_plot];
    
    // start audio
    recorder = [[ClapRecorder alloc] init];
    recorder.delegate = self;
    [self reset];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - 
-(void) reset{
    _backgroundLabel.text = @"￼Calculating background level...";
    
    [recorder stop];
    [recorder start];
}

#pragma mark - ClapRecorderDelegate methods
-(void)gotMeasurement:(ClapMeasurement *)measurement{
    _rt60Label.text = [NSString stringWithFormat:@"rt60 = %.3f seconds", measurement.reverbTime];
    for( int i=0; i<ClapMeasurement.numFreqs; i++ ){
        NSLog( @"%.0f Hz\t%.3f seconds", ClapMeasurement.specFrequencies[i], 
               measurement.reverbTimeSpectrum[i] );
    }
    // copy vector to plot
    if( _plotCurve ) free( _plotCurve );
    _plotCurve = malloc( sizeof(float) * ClapMeasurement.numFreqs );
    memcpy( _plotCurve, measurement.reverbTimeSpectrum, sizeof(float) * ClapMeasurement.numFreqs );
    
    // update plot
    [_plot setVector:_plotCurve length:ClapMeasurement.numFreqs];
    [_plot setYRange_min:0 max:5];
}

-(void)gotBackgroundLevel:(float)decibels{
    _backgroundLabel.text = [NSString stringWithFormat:@"background level is %.0f dB",decibels];
}
@end
