import React, { useState, useEffect } from 'react';
import { Button } from './ui/button';
import { Badge } from './ui/badge';
import { X, Heart, Star, MessageCircle, User, Settings, Bell, Zap } from 'lucide-react';
import { User as UserType, Screen } from '../App';
import { useApp } from '../App';
import { ImageWithFallback } from './figma/ImageWithFallback';
import { StoriesList } from './StoriesScreen';
import { motion } from 'motion/react';

interface DiscoveryScreenProps {
  onNavigate: (screen: Screen) => void;
  currentUser: UserType | null;
}

const mockUsers: UserType[] = [
  {
    id: '1',
    name: 'Linh',
    age: 25,
    photos: ['https://images.unsplash.com/photo-1503164585513-5c4f19209317?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHx5b3VuZyUyMGFzaWFuJTIwd29tYW4lMjBwb3J0cmFpdHxlbnwxfHx8fDE3NTcwOTcxNzh8MA&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral'],
    bio: 'Yêu thích du lịch và khám phá những món ăn mới. Thích xem phim và nghe nhạc indie.',
    interests: ['Du lịch', 'Ẩm thực', 'Phim ảnh', 'Âm nhạc'],
    distance: 2
  },
  {
    id: '2',
    name: 'Minh',
    age: 28,
    photos: ['https://images.unsplash.com/photo-1585923491671-0ced430efe9c?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxoYW5kc29tZSUyMGFzaWFuJTIwbWFuJTIwcG9ydHJhaXR8ZW58MXx8fHwxNzU3MTYwOTMzfDA&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral'],
    bio: 'Lập trình viên đam mê công nghệ. Thích chạy bộ và tập gym vào cuối tuần.',
    interests: ['Công nghệ', 'Thể thao', 'Gym', 'Game'],
    distance: 5
  },
  {
    id: '3',
    name: 'Hương',
    age: 24,
    photos: ['https://images.unsplash.com/photo-1699454207790-3a95751ace90?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxhdHRyYWN0aXZlJTIwd29tYW4lMjBzZWxmaWV8ZW58MXx8fHwxNzU3MTYwOTMzfDA&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral'],
    bio: 'Họa sĩ tự do, yêu thích thiên nhiên và động vật. Thích uống cà phê và đọc sách.',
    interests: ['Vẽ', 'Thiên nhiên', 'Cà phê', 'Đọc sách'],
    distance: 3
  },
  {
    id: '4',
    name: 'Tuấn',
    age: 27,
    photos: ['https://images.unsplash.com/photo-1543132220-e7fef0b974e7?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHx5b3VuZyUyMG1hbiUyMGNhc3VhbCUyMHBvcnRyYWl0fGVufDF8fHx8MTc1NzE2MDkzNHww&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral'],
    bio: 'Nhiếp ảnh gia và travel blogger. Luôn sẵn sàng cho những chuyến phiêu lưu mới.',
    interests: ['Nhiếp ảnh', 'Du lịch', 'Viết lách', 'Khám phá'],
    distance: 8
  },
  {
    id: '5',
    name: 'Chi',
    age: 26,
    photos: ['https://images.unsplash.com/photo-1689045246827-3b2a4ac9bfb7?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxiZWF1dGlmdWwlMjBnaXJsJTIwc21pbGluZ3xlbnwxfHx8fDE3NTcxNjA5MzR8MA&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral'],
    bio: 'Giáo viên yoga và yêu thích nấu ăn. Sống chậm và tận hưởng từng khoảnh khắc.',
    interests: ['Yoga', 'Nấu ăn', 'Thiền', 'Sức khỏe'],
    distance: 4
  }
];

export function DiscoveryScreen({ onNavigate, currentUser }: DiscoveryScreenProps) {
  const [currentUserIndex, setCurrentUserIndex] = useState(0);
  const [showDetails, setShowDetails] = useState(false);
  const [users, setUsers] = useState(mockUsers);
  const [dragX, setDragX] = useState(0);
  const [isDragging, setIsDragging] = useState(false);
  const { notifications, addMatch, addNotification } = useApp();

  const currentDisplayUser = users[currentUserIndex];
  const unreadNotifications = notifications.filter(n => !n.isRead).length;

  const handleAction = (action: 'pass' | 'like' | 'superlike') => {
    if (currentDisplayUser) {
      // Simulate match for like/superlike (30% chance)
      if ((action === 'like' || action === 'superlike') && Math.random() < 0.3) {
        addMatch({
          user: currentDisplayUser,
          timestamp: new Date(),
          isNew: true,
          matchType: action
        });
      } else if (action === 'like' || action === 'superlike') {
        // Add notification for like/superlike
        addNotification({
          type: action,
          message: action === 'superlike' ? 'Bạn đã super like ai đó!' : 'Bạn đã like ai đó!',
          timestamp: new Date(),
          isRead: false,
        });
      }
    }

    // Animate card out and show next user
    if (currentUserIndex < users.length - 1) {
      setCurrentUserIndex(currentUserIndex + 1);
    } else {
      // Reset to first user or show "no more users" message
      setCurrentUserIndex(0);
    }
    setShowDetails(false);
    setDragX(0);
  };

  const handleDragEnd = (event: any, info: any) => {
    const threshold = 100;
    setIsDragging(false);
    
    if (Math.abs(info.offset.x) > threshold) {
      if (info.offset.x > 0) {
        handleAction('like');
      } else {
        handleAction('pass');
      }
    } else {
      setDragX(0);
    }
  };

  if (!currentDisplayUser) {
    return (
      <div className="min-h-screen flex flex-col">
        <div className="flex-1 flex items-center justify-center">
          <div className="text-center">
            <h2 className="text-2xl text-gray-900 mb-2">Không còn người dùng nào</h2>
            <p className="text-gray-600">Hãy quay lại sau để khám phá thêm!</p>
          </div>
        </div>
        {/* Bottom Navigation */}
        <div className="border-t bg-white p-4">
          <div className="flex justify-around">
            <Button variant="ghost" size="sm" className="flex flex-col items-center gap-1">
              <Heart className="h-5 w-5 text-pink-500" />
              <span className="text-xs">Khám phá</span>
            </Button>
            <Button variant="ghost" size="sm" className="flex flex-col items-center gap-1" onClick={() => onNavigate('chat')}>
              <MessageCircle className="h-5 w-5" />
              <span className="text-xs">Tin nhắn</span>
            </Button>
            <Button variant="ghost" size="sm" className="flex flex-col items-center gap-1" onClick={() => onNavigate('profile')}>
              <User className="h-5 w-5" />
              <span className="text-xs">Hồ sơ</span>
            </Button>
          </div>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen flex flex-col bg-gray-50">
      {/* Header */}
      <div className="flex items-center justify-between p-4 bg-card border-b">
        <h1 className="text-xl">Matcha</h1>
        <div className="flex items-center gap-2">
          <Button 
            variant="ghost" 
            size="sm" 
            onClick={() => onNavigate('notifications')}
            className="relative"
          >
            <Bell className="h-5 w-5" />
            {unreadNotifications > 0 && (
              <span className="absolute -top-1 -right-1 w-4 h-4 bg-red-500 text-white text-xs rounded-full flex items-center justify-center">
                {unreadNotifications > 9 ? '9+' : unreadNotifications}
              </span>
            )}
          </Button>
          <Button variant="ghost" size="sm" onClick={() => onNavigate('settings')}>
            <Settings className="h-5 w-5" />
          </Button>
        </div>
      </div>

      {/* Stories */}
      <StoriesList onOpenStories={() => onNavigate('stories')} />

      {/* Main Card */}
      <div className="flex-1 p-4">
        <motion.div 
          className="relative h-full max-h-[600px] bg-card rounded-2xl overflow-hidden shadow-lg"
          drag="x"
          dragConstraints={{ left: -200, right: 200 }}
          onDrag={(event, info) => {
            setDragX(info.offset.x);
            setIsDragging(true);
          }}
          onDragEnd={handleDragEnd}
          whileDrag={{ scale: 1.05 }}
          style={{
            rotate: dragX / 10,
          }}
        >
          {/* Drag Indicators */}
          {isDragging && (
            <>
              {dragX > 50 && (
                <div className="absolute top-1/2 left-1/2 transform -translate-x-1/2 -translate-y-1/2 z-10 bg-green-500 text-white px-6 py-3 rounded-full border-4 border-white shadow-lg">
                  <Heart className="h-8 w-8 fill-current" />
                </div>
              )}
              {dragX < -50 && (
                <div className="absolute top-1/2 left-1/2 transform -translate-x-1/2 -translate-y-1/2 z-10 bg-red-500 text-white px-6 py-3 rounded-full border-4 border-white shadow-lg">
                  <X className="h-8 w-8" />
                </div>
              )}
            </>
          )}
          
          {/* Main Image */}
          <div className="relative h-full">
            <ImageWithFallback
              src={currentDisplayUser.photos[0]}
              alt={currentDisplayUser.name}
              className="w-full h-full object-cover"
            />
            
            {/* Gradient Overlay */}
            <div className="absolute inset-0 bg-gradient-to-t from-black/60 via-transparent to-transparent" />
            
            {/* Compatibility Score */}
            {currentDisplayUser.compatibilityScore && (
              <div className="absolute top-4 right-4 bg-white/90 backdrop-blur-sm rounded-full px-3 py-1">
                <span className="text-sm font-medium text-pink-600">
                  {currentDisplayUser.compatibilityScore}% phù hợp
                </span>
              </div>
            )}
            
            {/* Verified Badge */}
            {currentDisplayUser.verified && (
              <div className="absolute top-4 left-4 bg-blue-500 rounded-full p-2">
                <svg className="h-4 w-4 text-white" fill="currentColor" viewBox="0 0 20 20">
                  <path fillRule="evenodd" d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z" clipRule="evenodd" />
                </svg>
              </div>
            )}
            
            {/* Online Status */}
            {currentDisplayUser.isOnline && (
              <div className="absolute top-16 left-4 flex items-center gap-2 bg-green-500 text-white px-2 py-1 rounded-full text-xs">
                <div className="w-2 h-2 bg-white rounded-full animate-pulse" />
                Đang online
              </div>
            )}
            
            {/* User Info Overlay */}
            <div className="absolute bottom-0 left-0 right-0 p-6 text-white">
              <div className="flex items-center justify-between mb-3">
                <div className="flex items-center gap-2">
                  <h2 className="text-2xl">{currentDisplayUser.name}</h2>
                  <span className="text-xl">{currentDisplayUser.age}</span>
                </div>
                {currentDisplayUser.mutualFriends && (
                  <div className="text-sm bg-white/20 px-2 py-1 rounded-full">
                    {currentDisplayUser.mutualFriends} bạn chung
                  </div>
                )}
              </div>
              <div className="flex flex-wrap gap-2 mb-3">
                {currentDisplayUser.interests.slice(0, 3).map((interest) => (
                  <Badge key={interest} variant="secondary" className="bg-white/20 text-white border-white/30">
                    {interest}
                  </Badge>
                ))}
              </div>
              <div className="text-sm opacity-90">
                📍 {currentDisplayUser.distance}km
              </div>
            </div>

            {/* Details Toggle */}
            <div 
              className="absolute inset-0 cursor-pointer"
              onClick={() => setShowDetails(!showDetails)}
            />
            
            {/* Expanded Details */}
            {showDetails && (
              <motion.div 
                initial={{ opacity: 0, y: 20 }}
                animate={{ opacity: 1, y: 0 }}
                className="absolute inset-0 bg-card"
              >
                <div className="p-6 h-full overflow-y-auto">
                  <div className="flex items-center gap-3 mb-4">
                    <ImageWithFallback
                      src={currentDisplayUser.photos[0]}
                      alt={currentDisplayUser.name}
                      className="w-16 h-16 rounded-full object-cover"
                    />
                    <div>
                      <h2 className="text-xl">{currentDisplayUser.name}, {currentDisplayUser.age}</h2>
                      <p className="text-muted-foreground">📍 {currentDisplayUser.distance}km từ bạn</p>
                    </div>
                  </div>
                  
                  <div className="mb-6">
                    <h3 className="mb-3">Giới thiệu</h3>
                    <p className="text-muted-foreground leading-relaxed">{currentDisplayUser.bio}</p>
                  </div>
                  
                  <div>
                    <h3 className="mb-3">Sở thích</h3>
                    <div className="flex flex-wrap gap-2">
                      {currentDisplayUser.interests.map((interest) => (
                        <Badge key={interest} variant="outline">
                          {interest}
                        </Badge>
                      ))}
                    </div>
                  </div>
                </div>
              </motion.div>
            )}
          </div>
        </motion.div>
      </div>

      {/* Action Buttons */}
      <div className="p-6">
        <div className="flex justify-center items-center gap-6">
          <Button
            size="lg"
            variant="outline"
            className="w-14 h-14 rounded-full border-2 border-gray-300 hover:border-red-500 hover:bg-red-50"
            onClick={() => handleAction('pass')}
          >
            <X className="h-6 w-6 text-gray-600 hover:text-red-500" />
          </Button>
          
          <Button
            size="lg"
            className="w-16 h-16 rounded-full bg-blue-500 hover:bg-blue-600 shadow-lg"
            onClick={() => handleAction('superlike')}
          >
            <Star className="h-7 w-7 text-white fill-current" />
          </Button>
          
          <Button
            size="lg"
            className="w-14 h-14 rounded-full bg-green-500 hover:bg-green-600 shadow-lg"
            onClick={() => handleAction('like')}
          >
            <Heart className="h-6 w-6 text-white fill-current" />
          </Button>
        </div>
      </div>

      {/* Bottom Navigation */}
      <div className="border-t bg-card p-4">
        <div className="flex justify-around">
          <Button variant="ghost" size="sm" className="flex flex-col items-center gap-1">
            <Heart className="h-5 w-5 text-pink-500" />
            <span className="text-xs">Khám phá</span>
          </Button>
          <Button variant="ghost" size="sm" className="flex flex-col items-center gap-1" onClick={() => onNavigate('matches')}>
            <Zap className="h-5 w-5" />
            <span className="text-xs">Kết đôi</span>
          </Button>
          <Button variant="ghost" size="sm" className="flex flex-col items-center gap-1" onClick={() => onNavigate('chat')}>
            <MessageCircle className="h-5 w-5" />
            <span className="text-xs">Tin nhắn</span>
          </Button>
          <Button variant="ghost" size="sm" className="flex flex-col items-center gap-1" onClick={() => onNavigate('profile')}>
            <User className="h-5 w-5" />
            <span className="text-xs">Hồ sơ</span>
          </Button>
        </div>
      </div>
    </div>
  );
}