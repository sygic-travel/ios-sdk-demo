//
//  VR360VideoController.m
//  Travel
//
//  Created by Marek Stana on 12/8/16.
//  Copyright © 2016 Tripomatic. All rights reserved.
//

#import <SceneKit/SceneKit.h>
#import <CoreMotion/CoreMotion.h>
#import <SpriteKit/SpriteKit.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <TravelKit/TravelKit.h>

#import "TKVR360VideoController.h"

#define kCameraMaxZoom 120
#define kCameraMinZoom 40


@interface TKVR360VideoController  () <SCNSceneRendererDelegate, UIGestureRecognizerDelegate>

@property (nonatomic) SKVideoNode *videoSpriteKitNode;

@property (nonatomic) AVPlayer *videoPlayer;

@property (nonatomic) SCNView *leftSceneView;
@property (nonatomic) SCNView *rightSceneView;

@property (nonatomic) SCNScene *scene;

@property (nonatomic) SCNNode *videoNode;
@property (nonatomic) SCNNode *cameraNode;
@property (nonatomic) SCNNode *cameraRollNode;
@property (nonatomic) SCNNode *cameraPitchNode;
@property (nonatomic) SCNNode *cameraYawNode;

@property UITapGestureRecognizer *tapRecognizer;
@property UITapGestureRecognizer *doubleTapRecognizer;
@property UIPanGestureRecognizer *panRecognizer;
@property UIPinchGestureRecognizer *pinchRecognizer;
@property CMMotionManager *motionManager;

@property CGFloat currentAngleX;
@property CGFloat currentAngleY;

@property CGFloat oldX;
@property CGFloat oldY;
@property CGFloat memoryWarning;


@property (atomic, assign) BOOL landscapeLeftRightInvertor, playingVideo, cardboardViewOn, cameraZoomed;

@property (nonatomic) TKMedium *medium;

@property (nonatomic, strong) UIView *controlView;
@property (nonatomic, strong) UIView *cardboardOverlayView;
@property (nonatomic, strong) UIActivityIndicatorView *backgroundSpiner;

@property (nonatomic, strong) UIButton *closeButton;
@property (nonatomic, strong) UIButton *cardboardButton;

@end

@implementation VR360VideoController


- (instancetype)initWithMedium:(TKMedium *)medium
{
	self = [super init];
	if (self) {
		_medium = medium;
	}
	return self;
}

#pragma mark - View Life Cycle

-(void)viewDidLoad
{
	[super viewDidLoad];

	_memoryWarning = 0;

	_leftSceneView = [[SCNView alloc] initWithFrame:self.view.bounds];
	_leftSceneView.backgroundColor = [UIColor clearColor];
	_leftSceneView.hidden = YES;
	[self.view addSubview:_leftSceneView];

	_rightSceneView = [[SCNView alloc] initWithFrame:self.view.bounds];
	_rightSceneView.backgroundColor = [UIColor clearColor];
	[self.view addSubview:_rightSceneView];

	self.view.backgroundColor = [UIColor blackColor];

	_playingVideo = YES;
	_cardboardViewOn = NO;
	_cameraZoomed = NO;

	_leftSceneView.delegate = self;
	_rightSceneView.delegate = _leftSceneView.delegate;

	SCNCamera *camera = [[SCNCamera alloc] init];

	camera.xFov = 70;
	camera.yFov = 70;
	camera.zFar = 50;

	SCNNode *leftCameraNode = [[SCNNode alloc] init];
	leftCameraNode.camera = camera;

	_scene = [[SCNScene alloc] init];

	_cameraNode = [[SCNNode alloc] init];
	_cameraRollNode = [[SCNNode alloc] init];
	_cameraPitchNode = [[SCNNode alloc] init];
	_cameraYawNode = [[SCNNode alloc] init];

	[_cameraNode addChildNode:leftCameraNode];
	[_cameraRollNode addChildNode:_cameraNode];
	[_cameraPitchNode addChildNode:_cameraRollNode];
	[_cameraYawNode addChildNode:_cameraPitchNode];

	_leftSceneView.scene = _scene;
	_rightSceneView.scene = _scene;

	leftCameraNode.position = SCNVector3Make(0.0, 0.5, 0.5);

	NSArray *cameraNodeAngles = [self getCamerasNodeAngle];
	_cameraNode.position = SCNVector3Make(0.0, 0.5, 0.5);
	_cameraNode.eulerAngles = SCNVector3Make([[cameraNodeAngles objectAtIndex:0] floatValue], [[cameraNodeAngles objectAtIndex:1] floatValue], [[cameraNodeAngles objectAtIndex:2] floatValue]);

	[_scene.rootNode addChildNode:_cameraYawNode];

	_leftSceneView.pointOfView = leftCameraNode;
	_rightSceneView.pointOfView = leftCameraNode;

	_motionManager = [[CMMotionManager alloc] init];
	_motionManager.deviceMotionUpdateInterval = 1.0/60;
	[_motionManager startDeviceMotionUpdatesUsingReferenceFrame:CMAttitudeReferenceFrameXArbitraryZVertical];


	// UIGesture recognizers

	_tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureOnView)];
	_doubleTapRecognizer.numberOfTapsRequired = 1;
	_tapRecognizer.delegate = self;
	[self.view addGestureRecognizer:_tapRecognizer];

	_doubleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapGestureOnView)];
	_doubleTapRecognizer.numberOfTapsRequired = 2;
	_doubleTapRecognizer.delegate = self;
	[self.view addGestureRecognizer:_doubleTapRecognizer];

	_panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGesture:)];
	_panRecognizer.delegate = self;
	[self.view addGestureRecognizer:_panRecognizer];

	//Initialize position variable (for the panGesture)
	_currentAngleX = 0;
	_currentAngleY = 0;

	_oldX = 0;
	_oldY = 0;

	UIImageView *imageOverlay = [[UIImageView alloc] initWithFrame:self.view.frame];
	imageOverlay.image = [UIImage imageNamed:@"360-cardboard-overlay"];
	imageOverlay.contentMode = UIViewContentModeScaleAspectFill;
	_cardboardOverlayView = [[UIView alloc] initWithFrame:self.view.frame];
	[_cardboardOverlayView addSubview:imageOverlay];
	[self.view addSubview:_cardboardOverlayView];
	_cardboardOverlayView.hidden = !_cardboardViewOn;

	_controlView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 60)];
	_controlView.tag = 100;
	_controlView.backgroundColor = [UIColor clearColor];

	_closeButton = [[UIButton alloc] initWithFrame:CGRectMake(10, 10, 50, 50)];
	[_closeButton setImage:[UIImage imageNamed:@"icon-close-white"] forState:UIControlStateNormal];
	[_closeButton addTarget:self action:@selector(dismissVC) forControlEvents:UIControlEventTouchUpInside];
	[_controlView addSubview:_closeButton];

	_cardboardButton = [[UIButton alloc] initWithFrame:CGRectMake(_controlView.size.width-50-10, 10, 50, 50)];
	[_cardboardButton setImage:[UIImage imageNamed:@"360-cardboard-icon"] forState:UIControlStateNormal];
	[_cardboardButton addTarget:self action:@selector(displayIfNeededCardboardView) forControlEvents:UIControlEventTouchUpInside];
	if (!isIPad()) {
		[_controlView addSubview:_cardboardButton];
	}

	[self.view addSubview:_controlView];

	_backgroundSpiner = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
	[_backgroundSpiner startAnimating];
	_backgroundSpiner.center = self.view.center;
	_backgroundSpiner.hidesWhenStopped = YES;
	[self.view addSubview:_backgroundSpiner];
	[_backgroundSpiner startAnimating];

	[self play];
}

- (void) viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
	[_videoPlayer.currentItem removeObserver:self forKeyPath:@"playbackBufferEmpty"];
}

-(NSArray *)getCamerasNodeAngle
{
	double camerasNodeAngle1 = 0.0;
	double camerasNodeAngle2 = 0.0;

	UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
	_landscapeLeftRightInvertor = NO;
	if (orientation == UIInterfaceOrientationPortrait){
		camerasNodeAngle1 = -M_PI_2;
	} else if (orientation == UIInterfaceOrientationPortraitUpsideDown) {
		camerasNodeAngle1 = M_PI_2;
	} else if (orientation == UIInterfaceOrientationLandscapeRight) {
		camerasNodeAngle1 = -M_PI;
		camerasNodeAngle2 = 0;
		_landscapeLeftRightInvertor = YES;
	} else if (orientation == UIInterfaceOrientationLandscapeLeft) {
		camerasNodeAngle1 = 0;
		camerasNodeAngle2 = 0;
	}

	return [NSArray arrayWithObjects:[NSNumber numberWithFloat: -M_PI_2], [NSNumber numberWithFloat: camerasNodeAngle1], [NSNumber numberWithFloat: camerasNodeAngle2], nil];
}

-(void)play
{
	if (_medium.previewURL) {

		BOOL cellular = [ConnectionManager isCellular];
		CGFloat screenScale = 2;

		VideoType type = (!cellular) ? VideoType1080p : VideoType720p;
		NSString *size = [Medium sizeStringForVideoType:type];

		NSString *urlString = [_medium.previewURL.absoluteString
			stringByReplacingOccurrencesOfString:@MEDIUM_SIZE_PLACEHOLDER_LOCAL withString:size];

		NSURL *url = [NSURL URLWithString:urlString];

		_videoPlayer = [[AVPlayer alloc] initWithURL:url];
		_videoPlayer.volume = 1.0f;
		_videoSpriteKitNode = [SKVideoNode videoNodeWithAVPlayer:_videoPlayer];

		_videoNode = [[SCNNode alloc] init];
		_videoNode.castsShadow = NO;
		SKScene *spriteKitScene1 = [[SKScene alloc] initWithSize:CGSizeMake(1280*screenScale, 1280*screenScale)];
		spriteKitScene1.shouldRasterize = YES;

		_videoNode.geometry = [SCNSphere sphereWithRadius:40];
		spriteKitScene1.scaleMode = SKSceneScaleModeAspectFit;

		_videoSpriteKitNode.position = CGPointMake(spriteKitScene1.size.width/2.0, spriteKitScene1.size.height/2.0);
		_videoSpriteKitNode.size = spriteKitScene1.size;

		[spriteKitScene1 addChild:_videoSpriteKitNode];

		SCNMatrix4 transform = SCNMatrix4MakeRotation((float)M_PI, 0.0, 0.0, 1.0);
		transform = SCNMatrix4Translate(transform, 1.0, 1.0, 0.0);

		_videoNode.geometry.firstMaterial.diffuse.contents = spriteKitScene1;
		_videoNode.geometry.firstMaterial.doubleSided = YES;
		_videoNode.pivot = SCNMatrix4MakeRotation((float) M_2_PI, 0.0, -1.0, 0.0);
		_videoNode.geometry.firstMaterial.diffuse.contentsTransform = transform;
		_videoNode.position = SCNVector3Make(0.0, 0.0, 0.0);

		[_scene.rootNode addChildNode:_videoNode];
		[_videoPlayer.currentItem addObserver:self forKeyPath:@"playbackBufferEmpty" options:NSKeyValueObservingOptionNew context:nil];

		[_videoPlayer play];
		[_videoSpriteKitNode play];
		_rightSceneView.playing = YES;
		_leftSceneView.playing = YES;

		if (cellular)
			[[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"You are connected via Mobile Data", @"Alert title")
				message:NSLocalizedString(@"For the best experience make sure to use a fast internet connection.", @"Alert message")
					delegate:self cancelButtonTitle:NSLocalizedString(@"OK", @"Button title")
						otherButtonTitles:nil] show];

	}
	else [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"There's a problem with the requested content", @"Alert title")
			message:NSLocalizedString(@"This is usually a temporary issue. Please try it again later.", @"Alert message")
				delegate:self cancelButtonTitle:NSLocalizedString(@"OK", @"Button title")
					otherButtonTitles:nil] show];
}



- (void)observeValueForKeyPath:(NSString *)keyPath
					  ofObject:(id)object
						change:(NSDictionary<NSString *,id> *)change
					   context:(void *)context {

	if ([keyPath isEqualToString:@"playbackBufferEmpty"]) {
		BOOL status = [change[NSKeyValueChangeNewKey] boolValue];
		__weak typeof (self) weakSelf = self;
		dispatch_async(dispatch_get_main_queue(), ^{
			if (status)
				[weakSelf.backgroundSpiner startAnimating];
			else
				[weakSelf.backgroundSpiner stopAnimating];
		});
	}
}

#pragma mark - Gesture Recognizers

-(void)tapGestureOnView
{
	CGFloat alpha = 1 -_controlView.alpha;

	[UIView animateWithDuration:0.3f animations:^{
		_controlView.alpha = alpha;
	}];
}


-(void)doubleTapGestureOnView
{
	float newFov = _cameraZoomed ? 70 : 40;

	for (SCNNode *childNode in _cameraNode.childNodes) {
		childNode.camera.xFov = newFov;
		childNode.camera.yFov = newFov;
	}
	_cameraZoomed = !_cameraZoomed;
}

-(int) normalizeCorrecture: (float)correcture
{
	if (correcture >=0) return _landscapeLeftRightInvertor ? -1 : 1;
	else return _landscapeLeftRightInvertor ? 1 : -1;
}

-(BOOL)isLandscape {
	return isIPad();
}

-(void)panGesture:(UIPanGestureRecognizer *)recognizer
{

	CGPoint transtaltion = [recognizer translationInView:recognizer.view];
	float protection = 2.0;

	if ([self isLandscape]) {
		protection = 4.0;
	}

	if (_motionManager && _motionManager.deviceMotion) {
		CMDeviceMotion *motion = _motionManager.deviceMotion;
		if (motion.attitude.pitch > 0.4 || motion.attitude.pitch < -0.4) {
			// portait
			float correcture = [self normalizeCorrecture: motion.attitude.pitch];
			if ([self isLandscape]) {
				if (fabs(transtaltion.y * correcture - _oldX) >= protection) {
					float newAngleX = transtaltion.y * correcture - _oldX - protection;
					_currentAngleX = newAngleX/100 + _currentAngleX;
					_oldX = transtaltion.y * correcture;
				}
			} else {
				if (fabs(transtaltion.x * correcture - _oldX) >= protection) {
					float newAngleX = transtaltion.x * correcture - _oldX - protection;
					_currentAngleX = newAngleX/100 + _currentAngleX;
					_oldX = transtaltion.x * correcture;
				}
			}
		} else {
			// landscape
			float correcture = [self isLandscape] ? [self normalizeCorrecture: motion.attitude.roll] : [self normalizeCorrecture: motion.attitude.yaw];
			if ([self isLandscape]) {
				if (fabs(transtaltion.x * correcture - _oldX) >= protection) {
					float newAngleX = transtaltion.x * correcture - _oldX - protection;
					_currentAngleX = newAngleX/100 + _currentAngleX;
					_oldX = transtaltion.x * correcture;
				}

			} else {
				if (fabs(transtaltion.y * correcture - _oldX) >= protection) {
					float newAngleX = transtaltion.y * correcture - _oldX - protection;
					_currentAngleX = newAngleX/100 + _currentAngleX;
					_oldX = transtaltion.y * correcture;
				}
			}
		}
	}

	if (recognizer.state == UIGestureRecognizerStateEnded) {
		_oldX = 0;
		_oldY = 0;
	}
}

#pragma mark - Render the scene

-(void)renderer:(id<SCNSceneRenderer>)renderer updateAtTime:(NSTimeInterval)time
{
	if (!self) return;
	__weak typeof (self) weakSelf = self;
	dispatch_async(dispatch_get_main_queue(), ^{
		if (_motionManager && _motionManager.deviceMotion) {

			__weak CMAttitude *currentAttitude = _motionManager.deviceMotion.attitude;
			_cameraRollNode.eulerAngles = SCNVector3Make(((float) currentAttitude.roll - _currentAngleY),
														 _cameraRollNode.eulerAngles.y,
														 _cameraRollNode.eulerAngles.z);
			_cameraPitchNode.eulerAngles = SCNVector3Make(_cameraPitchNode.eulerAngles.x,
														  _cameraPitchNode.eulerAngles.y,
														  currentAttitude.pitch);
			_cameraYawNode.eulerAngles = SCNVector3Make(_cameraYawNode.eulerAngles.x,
														(float) currentAttitude.yaw + _currentAngleX,
														_cameraYawNode.eulerAngles.z);
			[weakSelf rotateButtons:_motionManager.deviceMotion];
		}
	});
}

-(void) rotateButtons: (CMDeviceMotion *) motion
{
	if (_cardboardButton.hidden) return;
	CGFloat rotationAngle = 0;

	if (motion.attitude.pitch > 0.4 || motion.attitude.pitch < -0.4) {
		float correcture = [self normalizeCorrecture: motion.attitude.pitch];
		if (correcture <= 0) rotationAngle = M_PI; else rotationAngle = 0;
	} else {
		float correcture = [self isLandscape] ? [self normalizeCorrecture: motion.attitude.roll] : [self normalizeCorrecture: motion.attitude.yaw];
		rotationAngle = correcture * M_PI_2;
	}

	[UIView animateWithDuration:0.3 animations:^{
		_cardboardButton.transform = CGAffineTransformMakeRotation(rotationAngle);
		_closeButton.transform = CGAffineTransformMakeRotation(rotationAngle);
	}];
}

-(void) displayIfNeededCardboardView
{
	// CARDBOARD IS IPHONE ONLY
	_cardboardOverlayView.hidden = _cardboardViewOn;
	if (_cardboardViewOn) {
		_leftSceneView.hidden = YES;
		_rightSceneView.frame = CGRectMake(0, 0, self.view.size.width, self.view.size.height);
		_leftSceneView.frame = CGRectMake(_leftSceneView.frame.origin.x, _leftSceneView.frame.origin.y, _leftSceneView.frame.size.width, self.view.size.height);
	} else {
		_leftSceneView.hidden = NO;
		_rightSceneView.frame = CGRectMake(_rightSceneView.frame.origin.x, 0, self.view.size.width, self.view.size.height/2.0);
		_leftSceneView.frame = CGRectMake(_leftSceneView.frame.origin.x, _rightSceneView.size.height , self.view.size.width, self.view.size.height/2.0);
		_controlView.alpha = 0;
	}
	_cardboardViewOn = !_cardboardViewOn;
}

-(void)dealloc
{

	[self removeNode:_cameraNode];
	[self removeNode:_cameraRollNode];
	[self removeNode:_cameraYawNode];
	[self removeNode:_cameraPitchNode];
	[self removeNode:_videoNode];

	[_videoSpriteKitNode removeAllChildren];
	[_videoSpriteKitNode removeFromParent];

	[_leftSceneView removeFromSuperview];
	_leftSceneView = nil;

	[_rightSceneView removeFromSuperview];
	_rightSceneView = nil;

	[_scene removeAllParticleSystems];
	_scene = nil;

	[_videoNode removeFromParentNode];
	[_videoNode removeAllAudioPlayers];
	[_videoNode removeAllParticleSystems];
	[_videoNode removeAllActions];
	_videoNode = nil;

	[_cameraNode removeFromParentNode];
	[_cameraNode removeAllAudioPlayers];
	[_cameraNode removeAllParticleSystems];
	[_cameraNode removeAllActions];
	_cameraNode = nil;

	[_cameraYawNode removeFromParentNode];
	[_cameraYawNode removeAllAudioPlayers];
	[_cameraYawNode removeAllParticleSystems];
	[_cameraYawNode removeAllActions];
	_cameraYawNode = nil;

	[_cameraRollNode removeFromParentNode];
	[_cameraRollNode removeAllAudioPlayers];
	[_cameraRollNode removeAllParticleSystems];
	[_cameraRollNode removeAllActions];
	_cameraRollNode = nil;

	[_cameraPitchNode removeFromParentNode];
	[_cameraPitchNode removeAllAudioPlayers];
	[_cameraPitchNode removeAllParticleSystems];
	[_cameraPitchNode removeAllActions];
	_cameraPitchNode = nil;

	[_motionManager stopDeviceMotionUpdates];
	_motionManager = nil;

	[_videoPlayer pause];
	[_videoPlayer replaceCurrentItemWithPlayerItem:nil];
	_videoPlayer = nil;

	_panRecognizer.delegate = nil;
	_tapRecognizer.delegate = nil;
	_doubleTapRecognizer.delegate = nil;
}

-(void)removeNode:(SCNNode *)node
{
	for (SCNNode *n in node.childNodes) {
		[self removeNode:n];
	}

	if (node.childNodes.count == 0) {
		[node removeFromParentNode];
	}
}

-(void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];

	[self dismissViewControllerAnimated:YES completion:^{
		[[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"There's a problem with the requested content", @"Alert title")
			message:NSLocalizedString(@"This is usually a temporary issue. Please try it again later.", @"Alert message")
				delegate:self cancelButtonTitle:NSLocalizedString(@"OK", @"Button title")
					otherButtonTitles:nil] show];
	}];
}


-(void)dismissVC
{
	[_leftSceneView stop:self];
	[_rightSceneView stop:self];
	_leftSceneView.delegate = nil;
	_rightSceneView.delegate = nil;
	[self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Autorotate

-(BOOL)shouldAutorotate { return NO; }

-(BOOL)prefersStatusBarHidden { return YES; }

@end
