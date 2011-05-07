/*
 Copyright (c) 2011 Rdio Inc
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 */

#import "Settings.h"


@implementation Settings

-(void)setAccessToken:(NSString *)token
{
  [dictionary_ setValue:token forKey:@"accessToken"];
}

-(NSString *)accessToken
{
  return [dictionary_ objectForKey:@"accessToken"];
}

-(void)setUser:(NSString *)user
{
  [dictionary_ setValue:user forKey:@"user"];
}

-(NSString *)user
{
  return [dictionary_ objectForKey:@"user"];
}

-(void)setUserKey:(NSString *)userKey 
{  
  [dictionary_ setValue:userKey forKey:@"userKey"];
}

-(NSString*)userKey
{
  return [dictionary_ objectForKey:@"userKey"];
}

-(void)setIcon:(NSString *)iconUrl
{
  [dictionary_ setValue:iconUrl forKey:@"icon"];
}

-(NSString*)icon
{
  return [dictionary_ objectForKey:@"icon"];
}

+ (Settings*)settings 
{
  static Settings *settings_;
  
  if (settings_) {
    return settings_;
  }
  
  @synchronized(self) {
    if (!settings_){
      settings_ = [[self alloc] init];
    }
  }
  
  return settings_;
}

- (NSString*)filePath 
{
  if (filePath_ == nil) {
    filePath_ = [[[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] 
                  stringByAppendingPathComponent:@"rdio-quiz.settings"] retain];
  }
  return filePath_;
}

- (id)init 
{
  if (self = [super init]) 
  {
    @try
    {
      dictionary_ = [[NSKeyedUnarchiver unarchiveObjectWithFile:[self filePath]] retain];
    }
    @catch (NSException *exception) 
    {
      NSLog(@"Exception loading settings. %@, %@", exception.name, exception.reason);
    }
    if (dictionary_ == nil) 
    {
      dictionary_ = [[NSMutableDictionary dictionaryWithCapacity:10] retain]; 
    }
  }
  return self;
}

//////////////////////////////////////////////////////////////////////////////////////////////////
- (void)save {
  NSLog(@"About to save settings");
  [NSKeyedArchiver archiveRootObject:dictionary_
                              toFile:[self filePath]];
  NSLog(@"Settings saved.");
}

- (void)reset {
  [(NSMutableDictionary *)dictionary_ removeAllObjects];
}

@end
