import React, { useState, useEffect } from 'react';
import { Button } from './ui/button';
import { ArrowLeft, Play, Pause, X, Heart, MessageCircle, Plus } from 'lucide-react';
import { Screen, Story, User as UserType } from '../App';
import { ImageWithFallback } from './figma/ImageWithFallback';

interface StoriesScreenProps {
  onNavigate: (screen: Screen) => void;
}

// Mock stories data
const mockStories: (Story & { user: UserType })[] = [
  {
    id: '1',
    userId: '1',
    user: {
      id: '1',
      name: 'Linh',
      age: 25,
      photos: ['https://images.unsplash.com/photo-1503164585513-5c4f19209317?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHx5b3VuZyUyMGFzaWFuJTIwd29tYW4lMjBwb3J0cmFpdHxlbnwxfHx8fDE3NTcwOTcxNzh8MA&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral'],
      bio: '',
      interests: []
    },
    imageUrl: 'https://images.unsplash.com/photo-1501594907352-04cda38ebc29?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHx0cmF2ZWwlMjBiZWFjaHxlbnwxfHx8fDE3NTcxNjA5MzR8MA&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral',
    timestamp: new Date(Date.now() - 2 * 60 * 60 * 1000),
    isViewed: false
  },
  {
    id: '2',
    userId: '2',
    user: {
      id: '2',
      name: 'Minh',
      age: 28,
      photos: ['https://images.unsplash.com/photo-1585923491671-0ced430efe9c?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxoYW5kc29tZSUyMGFzaWFuJTIwbWFuJTIwcG9ydHJhaXR8ZW58MXx8fHwxNzU3MTYwOTMzfDA&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral'],
      bio: '',
      interests: []
    },
    imageUrl: 'https://images.unsplash.com/photo-1498050108023-c5249f4df085?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxjb2RpbmclMjBsYXB0b3B8ZW58MXx8fHwxNzU3MTYwOTM0fDA&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral',
    timestamp: new Date(Date.now() - 4 * 60 * 60 * 1000),
    isViewed: false
  },
  {
    id: '3',
    userId: '3',
    user: {
      id: '3',
      name: 'Hương',
      age: 24,
      photos: ['https://images.unsplash.com/photo-1699454207790-3a95751ace90?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxhdHRyYWN0aXZlJTIwd29tYW4lMjBzZWxmaWV8ZW58MXx8fHwxNzU3MTYwOTMzfDA&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral'],
      bio: '',
      interests: []
    },
    imageUrl: 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxhcnQlMjBwYWludGluZ3xlbnwxfHx8fDE3NTcxNjA5MzR8MA&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral',
    timestamp: new Date(Date.now() - 6 * 60 * 60 * 1000),
    isViewed: true
  }
];

export function StoriesScreen({ onNavigate }: StoriesScreenProps) {
  const [currentStoryIndex, setCurrentStoryIndex] = useState(0);
  const [progress, setProgress] = useState(0);
  const [isPaused, setIsPaused] = useState(false);
  const [stories] = useState(mockStories);

  const currentStory = stories[currentStoryIndex];
  const STORY_DURATION = 5000; // 5 seconds per story

  useEffect(() => {
    if (!isPaused && currentStory) {
      const interval = setInterval(() => {
        setProgress(prev => {
          const newProgress = prev + (100 / (STORY_DURATION / 100));
          if (newProgress >= 100) {
            // Move to next story
            if (currentStoryIndex < stories.length - 1) {
              setCurrentStoryIndex(currentStoryIndex + 1);
              return 0;
            } else {
              // End of stories, go back to discovery
              onNavigate('discovery');
              return 100;
            }
          }
          return newProgress;
        });
      }, 100);

      return () => clearInterval(interval);
    }
  }, [currentStoryIndex, isPaused, stories.length, onNavigate, currentStory]);

  const goToNextStory = () => {
    if (currentStoryIndex < stories.length - 1) {
      setCurrentStoryIndex(currentStoryIndex + 1);
      setProgress(0);
    } else {
      onNavigate('discovery');
    }
  };

  const goToPrevStory = () => {
    if (currentStoryIndex > 0) {
      setCurrentStoryIndex(currentStoryIndex - 1);
      setProgress(0);
    }
  };

  const formatTime = (date: Date) => {
    const now = new Date();
    const diffInHours = Math.floor((now.getTime() - date.getTime()) / (1000 * 60 * 60));
    
    if (diffInHours < 1) {
      return 'Vừa mới';
    } else if (diffInHours < 24) {
      return `${diffInHours}h`;
    } else {
      const diffInDays = Math.floor(diffInHours / 24);
      return `${diffInDays}d`;
    }
  };

  if (!currentStory) {
    return (
      <div className="min-h-screen bg-black flex items-center justify-center">
        <p className="text-white">Không có story nào</p>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-black relative">
      {/* Story Background */}
      <div className="absolute inset-0">
        <ImageWithFallback
          src={currentStory.imageUrl}
          alt="Story"
          className="w-full h-full object-cover"
        />
        <div className="absolute inset-0 bg-black/20" />
      </div>

      {/* Progress bars */}
      <div className="absolute top-4 left-4 right-4 z-20">
        <div className="flex gap-1">
          {stories.map((_, index) => (
            <div key={index} className="flex-1 h-1 bg-white/30 rounded-full overflow-hidden">
              <div
                className="h-full bg-white transition-all duration-100 ease-linear"
                style={{
                  width: index < currentStoryIndex ? '100%' : 
                         index === currentStoryIndex ? `${progress}%` : '0%'
                }}
              />
            </div>
          ))}
        </div>
      </div>

      {/* Top bar */}
      <div className="absolute top-12 left-4 right-4 z-20">
        <div className="flex items-center justify-between text-white">
          <div className="flex items-center gap-3">
            <ImageWithFallback
              src={currentStory.user.photos[0]}
              alt={currentStory.user.name}
              className="w-8 h-8 rounded-full object-cover border-2 border-white"
            />
            <div>
              <p className="text-sm font-medium">{currentStory.user.name}</p>
              <p className="text-xs text-white/70">{formatTime(currentStory.timestamp)}</p>
            </div>
          </div>
          
          <div className="flex items-center gap-3">
            <Button
              variant="ghost"
              size="sm"
              onClick={() => setIsPaused(!isPaused)}
              className="text-white hover:bg-white/20"
            >
              {isPaused ? <Play className="h-4 w-4" /> : <Pause className="h-4 w-4" />}
            </Button>
            <Button
              variant="ghost"
              size="sm"
              onClick={() => onNavigate('discovery')}
              className="text-white hover:bg-white/20"
            >
              <X className="h-4 w-4" />
            </Button>
          </div>
        </div>
      </div>

      {/* Navigation areas */}
      <div className="absolute inset-0 flex">
        {/* Left tap area - previous story */}
        <div 
          className="flex-1 cursor-pointer"
          onClick={goToPrevStory}
        />
        {/* Right tap area - next story */}
        <div 
          className="flex-1 cursor-pointer"
          onClick={goToNextStory}
        />
      </div>

      {/* Story interactions */}
      <div className="absolute bottom-20 left-4 right-4 z-20">
        <div className="flex items-center gap-4 text-white">
          <Button
            variant="ghost"
            size="sm"
            className="text-white hover:bg-white/20"
          >
            <Heart className="h-5 w-5 mr-2" />
            Thích
          </Button>
          <Button
            variant="ghost"
            size="sm"
            className="text-white hover:bg-white/20"
            onClick={() => onNavigate('chat')}
          >
            <MessageCircle className="h-5 w-5 mr-2" />
            Nhắn tin
          </Button>
        </div>
      </div>

      {/* Story indicators */}
      <div className="absolute bottom-8 left-1/2 transform -translate-x-1/2 z-20">
        <div className="flex items-center gap-2 text-white text-sm">
          <span>{currentStoryIndex + 1}</span>
          <span>/</span>
          <span>{stories.length}</span>
        </div>
      </div>

      {/* Long press instruction */}
      <div className="absolute bottom-4 left-4 right-4 z-20">
        <p className="text-center text-white/50 text-xs">
          Chạm và giữ để tạm dừng • Chạm trái/phải để chuyển story
        </p>
      </div>
    </div>
  );
}

// Stories List Component (for discovery screen)
export function StoriesList({ onOpenStories }: { onOpenStories: () => void }) {
  const [stories] = useState(mockStories);
  
  // Group stories by user
  const userStories = stories.reduce((acc, story) => {
    if (!acc[story.userId]) {
      acc[story.userId] = {
        user: story.user,
        stories: [],
        hasUnviewed: false
      };
    }
    acc[story.userId].stories.push(story);
    if (!story.isViewed) {
      acc[story.userId].hasUnviewed = true;
    }
    return acc;
  }, {} as Record<string, { user: UserType, stories: Story[], hasUnviewed: boolean }>);

  return (
    <div className="p-4">
      <div className="flex items-center gap-3 mb-4">
        <h3 className="text-lg">Stories</h3>
      </div>
      
      <div className="flex gap-4 overflow-x-auto pb-2">
        {/* Add your story */}
        <div className="flex-shrink-0 text-center">
          <div className="w-16 h-16 border-2 border-dashed border-gray-300 rounded-full flex items-center justify-center mb-2 cursor-pointer hover:border-pink-500 transition-colors">
            <Plus className="h-6 w-6 text-gray-400" />
          </div>
          <p className="text-xs text-gray-600">Thêm story</p>
        </div>
        
        {/* User stories */}
        {Object.values(userStories).map((userStory) => (
          <div key={userStory.user.id} className="flex-shrink-0 text-center cursor-pointer" onClick={onOpenStories}>
            <div className={`w-16 h-16 rounded-full p-0.5 mb-2 ${
              userStory.hasUnviewed ? 'bg-gradient-to-r from-pink-500 to-purple-500' : 'bg-gray-300'
            }`}>
              <ImageWithFallback
                src={userStory.user.photos[0]}
                alt={userStory.user.name}
                className="w-full h-full rounded-full object-cover border-2 border-white"
              />
            </div>
            <p className="text-xs text-gray-900 truncate w-16">{userStory.user.name}</p>
          </div>
        ))}
      </div>
    </div>
  );
}