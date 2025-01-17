//
//  EZAudio.m
//  EZAudio
//
//  Created by Syed Haris Ali on 11/21/13.
//  Copyright (c) 2013 Syed Haris Ali. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT FALSET LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND FALSENINFRINGEMENT. IN FALSE EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

#import "EZAudio.h"

@implementation EZAudio

#pragma mark - AudioBufferList Utility
+ (AudioBufferList *)audioBufferListWithNumberOfFrames:(UInt32)frames
                                     numberOfChannels:(UInt32)channels
                                          interleaved:(BOOL)interleaved
{
    AudioBufferList *audioBufferList = (AudioBufferList*)malloc(sizeof(AudioBufferList));
    UInt32 outputBufferSize = 32 * frames; // 32 KB
    audioBufferList->mNumberBuffers = interleaved ? 1 : channels;
    for( int i = 0; i < audioBufferList->mNumberBuffers; i++ )
    {
        audioBufferList->mBuffers[i].mNumberChannels = channels;
        audioBufferList->mBuffers[i].mDataByteSize = channels * outputBufferSize;
        audioBufferList->mBuffers[i].mData = (STMAudioUnitSampleType*)malloc(channels * sizeof(STMAudioUnitSampleType) *outputBufferSize);
    }
    return audioBufferList;
}

+ (void)freeBufferList:(AudioBufferList *)bufferList
{
    if( bufferList )
    {
        if( bufferList->mNumberBuffers )
        {
            for( int i = 0; i < bufferList->mNumberBuffers; i++ )
            {
                if( bufferList->mBuffers[i].mData )
                {
                    free(bufferList->mBuffers[i].mData);
                }
            }
        }
        free(bufferList);
    }
    bufferList = NULL;
}

#pragma mark - AudioStreamBasicDescription Utility
+ (AudioStreamBasicDescription)AIFFFormatWithNumberOfChannels:(UInt32)channels
                                                  sampleRate:(float)sampleRate
{
    AudioStreamBasicDescription asbd;
    memset(&asbd, 0, sizeof(asbd));
    asbd.mFormatID          = kAudioFormatLinearPCM;
    asbd.mFormatFlags       = kAudioFormatFlagIsBigEndian|kAudioFormatFlagIsPacked|kAudioFormatFlagIsSignedInteger;
    asbd.mSampleRate        = sampleRate;
    asbd.mChannelsPerFrame  = channels;
    asbd.mBitsPerChannel    = 32;
    asbd.mBytesPerPacket    = (asbd.mBitsPerChannel / 8) * asbd.mChannelsPerFrame;
    asbd.mFramesPerPacket   = 1;
    asbd.mBytesPerFrame     = (asbd.mBitsPerChannel / 8) * asbd.mChannelsPerFrame;
    return asbd;
}

+ (AudioStreamBasicDescription)iLBCFormatWithSampleRate:(float)sampleRate
{
    AudioStreamBasicDescription asbd;
    memset(&asbd, 0, sizeof(asbd));
    asbd.mFormatID          = kAudioFormatiLBC;
    asbd.mChannelsPerFrame  = 1;
    asbd.mSampleRate        = sampleRate;
    
    // Fill in the rest of the descriptions using the Audio Format API
    UInt32 propSize = sizeof(asbd);
    [EZAudio checkResult:AudioFormatGetProperty(kAudioFormatProperty_FormatInfo,
                                                0,
                                                NULL,
                                                &propSize,
                                                &asbd)
               operation:"Failed to fill out the rest of the m4a AudioStreamBasicDescription"];
    
    return asbd;
}

+ (AudioStreamBasicDescription)M4AFormatWithNumberOfChannels:(UInt32)channels
                                                 sampleRate:(float)sampleRate
{
    AudioStreamBasicDescription asbd;
    memset(&asbd, 0, sizeof(asbd));
    asbd.mFormatID          = kAudioFormatMPEG4AAC;
    asbd.mChannelsPerFrame  = channels;
    asbd.mSampleRate        = sampleRate;
    
    // Fill in the rest of the descriptions using the Audio Format API
    UInt32 propSize = sizeof(asbd);
    [EZAudio checkResult:AudioFormatGetProperty(kAudioFormatProperty_FormatInfo,
                                                0,
                                                NULL,
                                                &propSize,
                                                &asbd)
               operation:"Failed to fill out the rest of the m4a AudioStreamBasicDescription"];
    
    return asbd;
}

+ (AudioStreamBasicDescription)monoFloatFormatWithSampleRate:(float)sampleRate{
    AudioStreamBasicDescription asbd;
    FillOutASBDForLPCM(&asbd, sampleRate, 1, 16, FALSE, FALSE);
    return asbd;
}

+ (AudioStreamBasicDescription)monoCanonicalFormatWithSampleRate:(float)sampleRate
{
    return [self monoFloatFormatWithSampleRate:sampleRate];
}

+ (AudioStreamBasicDescription)stereoCanonicalNonInterleavedFormatWithSampleRate:(float)sampleRate
{
    AudioStreamBasicDescription asbd;
    FillOutASBDForLPCM(&asbd, sampleRate, 2, 16, FALSE, FALSE);
    return asbd;
}

+ (AudioStreamBasicDescription)stereoFloatInterleavedFormatWithSampleRate:(float)sampleRate
{
    return [self stereoCanonicalNonInterleavedFormatWithSampleRate:sampleRate];
}

+ (AudioStreamBasicDescription)stereoFloatNonInterleavedFormatWithSampleRate:(float)sampleRate
{
    return [self stereoCanonicalNonInterleavedFormatWithSampleRate:sampleRate];
}

+ (void)printASBD:(AudioStreamBasicDescription)asbd {
    char formatIDString[5];
    UInt32 formatID = CFSwapInt32HostToBig(asbd.mFormatID);
    bcopy (&formatID, formatIDString, 4);
    formatIDString[4] = '\0';
    NSLog (@"  Sample Rate:         %10.0f",  asbd.mSampleRate);
    NSLog (@"  Format ID:           %10s",    formatIDString);
    NSLog (@"  Format Flags:        %10X",    (unsigned int)asbd.mFormatFlags);
    NSLog (@"  Bytes per Packet:    %10d",    (unsigned int)asbd.mBytesPerPacket);
    NSLog (@"  Frames per Packet:   %10d",    (unsigned int)asbd.mFramesPerPacket);
    NSLog (@"  Bytes per Frame:     %10d",    (unsigned int)asbd.mBytesPerFrame);
    NSLog (@"  Channels per Frame:  %10d",    (unsigned int)asbd.mChannelsPerFrame);
    NSLog (@"  Bits per Channel:    %10d",    (unsigned int)asbd.mBitsPerChannel);
}

#pragma mark - OSStatus Utility
+ (void)checkResult:(OSStatus)result
         operation:(const char *)operation {
	if (result == noErr) return;
	char errorString[20];
	// see if it appears to be a 4-char-code
	*(UInt32 *)(errorString + 1) = CFSwapInt32HostToBig(result);
	if (isprint(errorString[1]) && isprint(errorString[2]) && isprint(errorString[3]) && isprint(errorString[4])) {
		errorString[0] = errorString[5] = '\'';
		errorString[6] = '\0';
	} else
		// no, format it as an integer
		sprintf(errorString, "%d", (int)result);
	fprintf(stderr, "Error: %s (%s)\n", operation, errorString);
	exit(1);
}

+ (float)MAP:(float)value
    leftMin:(float)leftMin
    leftMax:(float)leftMax
   rightMin:(float)rightMin
   rightMax:(float)rightMax {
    float leftSpan    = leftMax  - leftMin;
    float rightSpan   = rightMax - rightMin;
    float valueScaled = ( value  - leftMin ) / leftSpan;
    return rightMin + (valueScaled * rightSpan);
}

+ (float)RMS:(float *)buffer
     length:(int)bufferSize {
    float sum = 0.0;
    for(int i = 0; i < bufferSize; i++)
        sum += buffer[i] * buffer[i];
    return sqrtf( sum / bufferSize );
}

+ (float)SGN:(float)value
{
    return value < 0 ? -1.0f : ( value > 0 ? 1.0f : 0.0f );
}

static UInt32 CalculateLPCMFlags(UInt32 bitsPerChannel,
                                 BOOL isFloat,
                                 BOOL isNonInterleaved) {
    return
    (isFloat ? kAudioFormatFlagIsFloat : kAudioFormatFlagIsSignedInteger) |
    (isFloat ? kAudioFormatFlagIsAlignedHigh : kAudioFormatFlagIsPacked)  |
    (isNonInterleaved ? ((UInt32)kAudioFormatFlagIsNonInterleaved) : 0);
}


void FillOutASBDForLPCM(AudioStreamBasicDescription *ABSD,
                        Float64 sampleRate,
                        UInt32 channelsPerFrame,
                        UInt32 bitsPerChannel,
                        BOOL isFloat,
                        BOOL isNonInterleaved) {
    ABSD->mSampleRate = sampleRate;
    ABSD->mFormatID = kAudioFormatLinearPCM;
    ABSD->mFormatFlags =    CalculateLPCMFlags(bitsPerChannel,
                                               isFloat,
                                               isNonInterleaved);
    ABSD->mBytesPerPacket =
    (isNonInterleaved ? 1 : channelsPerFrame) * (bitsPerChannel/8);
    ABSD->mFramesPerPacket = 1;
    ABSD->mBytesPerFrame =
    (isNonInterleaved ? 1 : channelsPerFrame) * (bitsPerChannel/8);
    ABSD->mChannelsPerFrame = channelsPerFrame;
    ABSD->mBitsPerChannel = bitsPerChannel;
}

@end