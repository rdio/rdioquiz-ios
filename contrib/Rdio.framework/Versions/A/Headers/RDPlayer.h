/**
 *  @file RDPlayer.h
 *  Rdio Playback Interface
 *  Copyright 2011 Rdio Inc. All rights reserved.
 */

#import <UIKit/UIKit.h>

////////////////////////////////////////////////////////////////////////////////

/**
 * Playback status
 */
typedef enum {
  RDPlayerStateInitializing, /**< Player is not ready yet */
  RDPlayerStatePaused, /**< Playback is paused */
  RDPlayerStatePlaying, /**< Currently playing (or buffering) */
  RDPlayerStateStopped /**< Playback is stopped */
} RDPlayerState;

////////////////////////////////////////////////////////////////////////////////

/**
 * Player delegate
 */
@protocol RDPlayerDelegate

/**
 * Notification that the current user has started playing with Rdio from 
 * another location, and playback here must stop.
 * @return <code>YES</code> if you handle letting the user know, or <code>NO</code> to have the SDK display a dialog.
 */
-(BOOL)rdioIsPlayingElsewhere;

/**
 * Notification that the player has changed states. See <code>RDPlayerState</code>.
 */
-(void)rdioPlayerChangedFromState:(RDPlayerState)oldState toState:(RDPlayerState)newState;
@end

////////////////////////////////////////////////////////////////////////////////

@class AudioStreamer;
@class RDUserEventLog;
@class RDSession;

/**
 * Responsible for playback. Handles playing and enqueueing track sources, 
 * advancing to the next track, logging plays with the server, etc.
 *
 * For now only track keys are supported, but future versions will accept 
 * album and playlist keys or dictionary objects.
 */
@interface RDPlayer : NSObject {
@private
  RDPlayerState state_;
  double position_;
  
  RDSession *session_;
  
  int currentTrackIndex_;
  NSString *currentTrack_;
  AudioStreamer *audioStream_;
  
  NSString *nextTrack_;
  AudioStreamer *nextAudioStream_;
  
  RDUserEventLog *log_;
  
  BOOL sentPlayEvent_;
  BOOL sentTimedPlayEvent_;
  BOOL sendSkipEvent_;
  BOOL sentSkipEvent_;
  
  BOOL checkingPlayingElsewhere_;
  
  NSTimer *pauseTimer_;
  NSString *playerName_;
  
  NSArray *trackKeys_;
  
  id<RDPlayerDelegate> delegate_;
}

/**
 * Starts playing a track key, such as "t1232".
 * Track keys can be found by calling web service API methods.
 * Objects such as Album contain a 'trackKeys' property.
 */
-(void)playSource:(NSString *)sourceKey;

/**
 * Play through a list of track keys, pre-buffering and automatically advancing
 * between songs.
 *
 * Note: full queue support coming soon.
 */
-(void)playSources:(NSArray *)sourceKeys;

/**
 * Advances to the next track in the trackKeys array.
 * This method only works within the array passed to the <code>playSources:</code> method.
 */
-(void)next;

/**
 * Play the previous track in the trackKeys array. 
 * This method only works within a list passed to the <code>playSources:</code> method.
 */
-(void)previous;

/**
 * Continues playing the current track
 */
- (void)play;

/**
 * Toggles paused state.
 */
- (void)togglePause;

/**
 * Stops playback and release resources.
 */
- (void)stop;

/**
 * Seeks to the given position.
 * @param positionInSeconds position to seek to, in seconds
 */
- (void)seekToPosition:(double)positionInSeconds;

/**
 * Current playback state.
 */
@property (nonatomic, readonly) RDPlayerState state;

/**
 * Current position in seconds.
 */
@property (nonatomic, readonly) double position;

/**
 * Duration of the current track, in seconds.
 */
@property (nonatomic, readonly) double duration;

/**
 * The key of the current track.
 */
@property (nonatomic, readonly) NSString *currentTrack;

/**
 * Index in the trackKeys array that is currently playing.
 */
@property (nonatomic, readonly) int currentTrackIndex;

/**
 * List of keys passed to playSources:
 */
@property (nonatomic, readonly) NSArray *trackKeys;

/**
 * Delegate used to receive player state changes.
 */
@property (nonatomic, assign) id<RDPlayerDelegate> delegate;

@end

