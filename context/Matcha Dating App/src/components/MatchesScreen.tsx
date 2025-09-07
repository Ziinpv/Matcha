import React, { useState } from 'react';
import { Button } from './ui/button';
import { Badge } from './ui/badge';
import { Tabs, TabsContent, TabsList, TabsTrigger } from './ui/tabs';
import { Heart, MessageCircle, User, Zap, Clock, Star } from 'lucide-react';
import { Match, Chat, Screen } from '../App';
import { useApp } from '../App';
import { ImageWithFallback } from './figma/ImageWithFallback';

interface MatchesScreenProps {
  onNavigate: (screen: Screen) => void;
  onOpenChat: (chat: Chat) => void;
}

// Mock matches data
const mockMatches: Match[] = [
  {
    id: '1',
    user: {
      id: '1',
      name: 'Linh',
      age: 25,
      photos: ['https://images.unsplash.com/photo-1503164585513-5c4f19209317?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHx5b3VuZyUyMGFzaWFuJTIwd29tYW4lMjBwb3J0cmFpdHxlbnwxfHx8fDE3NTcwOTcxNzh8MA&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral'],
      bio: 'Yêu thích du lịch và khám phá những món ăn mới.',
      interests: ['Du lịch', 'Ẩm thực'],
      verified: true,
      compatibilityScore: 92,
      isOnline: true
    },
    timestamp: new Date(Date.now() - 30 * 60 * 1000),
    isNew: true,
    matchType: 'superlike'
  },
  {
    id: '2',
    user: {
      id: '2',
      name: 'Minh',
      age: 28,
      photos: ['https://images.unsplash.com/photo-1585923491671-0ced430efe9c?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxoYW5kc29tZSUyMGFzaWFuJTIwbWFuJTIwcG9ydHJhaXR8ZW58MXx8fHwxNzU3MTYwOTMzfDA&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral'],
      bio: 'Lập trình viên đam mê công nghệ.',
      interests: ['Công nghệ', 'Thể thao'],
      verified: false,
      compatibilityScore: 87,
      isOnline: false,
      lastSeen: new Date(Date.now() - 2 * 60 * 60 * 1000)
    },
    timestamp: new Date(Date.now() - 2 * 60 * 60 * 1000),
    isNew: true,
    matchType: 'like'
  },
  {
    id: '3',
    user: {
      id: '3',
      name: 'Hương',
      age: 24,
      photos: ['https://images.unsplash.com/photo-1699454207790-3a95751ace90?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxhdHRyYWN0aXZlJTIwd29tYW4lMjBzZWxmaWV8ZW58MXx8fHwxNzU3MTYwOTMzfDA&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral'],
      bio: 'Họa sĩ tự do, yêu thích thiên nhiên.',
      interests: ['Vẽ', 'Thiên nhiên'],
      verified: true,
      compatibilityScore: 94,
      isOnline: false,
      lastSeen: new Date(Date.now() - 24 * 60 * 60 * 1000)
    },
    timestamp: new Date(Date.now() - 24 * 60 * 60 * 1000),
    isNew: false,
    matchType: 'like'
  },
  {
    id: '4',
    user: {
      id: '4',
      name: 'Tuấn',
      age: 27,
      photos: ['https://images.unsplash.com/photo-1543132220-e7fef0b974e7?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHx5b3VuZyUyMG1hbiUyMGNhc3VhbCUyMHBvcnRyYWl0fGVufDF8fHx8MTc1NzE2MDkzNHww&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral'],
      bio: 'Nhiếp ảnh gia và travel blogger.',
      interests: ['Nhiếp ảnh', 'Du lịch'],
      verified: false,
      compatibilityScore: 89,
      isOnline: true
    },
    timestamp: new Date(Date.now() - 3 * 24 * 60 * 60 * 1000),
    isNew: false,
    matchType: 'superlike'
  }
];

export function MatchesScreen({ onNavigate, onOpenChat }: MatchesScreenProps) {
  const [selectedTab, setSelectedTab] = useState('new');
  const [matches] = useState(mockMatches);

  const newMatches = matches.filter(match => match.isNew);
  const allMatches = matches;

  const formatTime = (date: Date) => {
    const now = new Date();
    const diffInHours = Math.floor((now.getTime() - date.getTime()) / (1000 * 60 * 60));
    
    if (diffInHours < 1) {
      return 'Vừa mới';
    } else if (diffInHours < 24) {
      return `${diffInHours} giờ trước`;
    } else {
      const diffInDays = Math.floor(diffInHours / 24);
      return `${diffInDays} ngày trước`;
    }
  };

  const handleStartChat = (match: Match) => {
    const chat: Chat = {
      id: match.id,
      user: match.user,
      lastMessage: '',
      timestamp: new Date(),
      messages: [],
      unreadCount: 0
    };
    onOpenChat(chat);
  };

  const MatchCard = ({ match }: { match: Match }) => (
    <div className="bg-card border rounded-2xl overflow-hidden shadow-sm hover:shadow-md transition-shadow">
      <div className="relative">
        <ImageWithFallback
          src={match.user.photos[0]}
          alt={match.user.name}
          className="w-full h-48 object-cover"
        />
        
        {/* Match type indicator */}
        {match.matchType === 'superlike' && (
          <div className="absolute top-3 left-3 bg-blue-500 rounded-full p-2">
            <Star className="h-4 w-4 text-white fill-current" />
          </div>
        )}
        
        {/* Online status */}
        {match.user.isOnline && (
          <div className="absolute top-3 right-3 w-3 h-3 bg-green-500 rounded-full border-2 border-white" />
        )}
        
        {/* New match badge */}
        {match.isNew && (
          <div className="absolute bottom-3 left-3">
            <Badge className="bg-pink-500 text-white">Mới</Badge>
          </div>
        )}
        
        {/* Verified badge */}
        {match.user.verified && (
          <div className="absolute bottom-3 right-3 bg-blue-500 rounded-full p-1">
            <svg className="h-3 w-3 text-white" fill="currentColor" viewBox="0 0 20 20">
              <path fillRule="evenodd" d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z" clipRule="evenodd" />
            </svg>
          </div>
        )}
      </div>
      
      <div className="p-4">
        <div className="flex items-center justify-between mb-2">
          <div>
            <h3 className="text-lg">{match.user.name}, {match.user.age}</h3>
            <p className="text-sm text-muted-foreground">{formatTime(match.timestamp)}</p>
          </div>
          {match.user.compatibilityScore && (
            <div className="text-right">
              <div className="text-sm text-pink-500">{match.user.compatibilityScore}%</div>
              <div className="text-xs text-muted-foreground">Phù hợp</div>
            </div>
          )}
        </div>
        
        <p className="text-sm text-muted-foreground mb-3 line-clamp-2">
          {match.user.bio}
        </p>
        
        <div className="flex items-center justify-between">
          <div className="flex flex-wrap gap-1">
            {match.user.interests.slice(0, 2).map((interest) => (
              <Badge key={interest} variant="secondary" className="text-xs">
                {interest}
              </Badge>
            ))}
          </div>
          
          <Button
            size="sm"
            onClick={() => handleStartChat(match)}
            className="bg-pink-500 hover:bg-pink-600"
          >
            <MessageCircle className="h-4 w-4 mr-1" />
            Chat
          </Button>
        </div>
      </div>
    </div>
  );

  return (
    <div className="min-h-screen bg-background">
      {/* Header */}
      <div className="bg-card border-b p-4">
        <div className="flex items-center justify-between">
          <h1 className="text-xl">Kết đôi</h1>
          <div className="flex items-center gap-2">
            <Badge variant="secondary" className="bg-pink-100 text-pink-700">
              {newMatches.length} mới
            </Badge>
          </div>
        </div>
      </div>

      {/* Tabs */}
      <div className="p-4">
        <Tabs value={selectedTab} onValueChange={setSelectedTab} className="w-full">
          <TabsList className="grid w-full grid-cols-2">
            <TabsTrigger value="new" className="flex items-center gap-2">
              <Zap className="h-4 w-4" />
              Mới ({newMatches.length})
            </TabsTrigger>
            <TabsTrigger value="all" className="flex items-center gap-2">
              <Clock className="h-4 w-4" />
              Tất cả ({allMatches.length})
            </TabsTrigger>
          </TabsList>
          
          <TabsContent value="new" className="mt-6">
            {newMatches.length > 0 ? (
              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                {newMatches.map((match) => (
                  <MatchCard key={match.id} match={match} />
                ))}
              </div>
            ) : (
              <div className="text-center py-16">
                <Heart className="h-16 w-16 text-muted-foreground mx-auto mb-4" />
                <h3 className="text-lg mb-2">Chưa có kết đôi mới</h3>
                <p className="text-muted-foreground mb-4">
                  Tiếp tục khám phá để tìm thêm người phù hợp!
                </p>
                <Button onClick={() => onNavigate('discovery')}>
                  Bắt đầu khám phá
                </Button>
              </div>
            )}
          </TabsContent>
          
          <TabsContent value="all" className="mt-6">
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              {allMatches.map((match) => (
                <MatchCard key={match.id} match={match} />
              ))}
            </div>
          </TabsContent>
        </Tabs>
      </div>

      {/* Bottom Navigation */}
      <div className="border-t bg-card p-4 mt-8">
        <div className="flex justify-around">
          <Button variant="ghost" size="sm" className="flex flex-col items-center gap-1" onClick={() => onNavigate('discovery')}>
            <Heart className="h-5 w-5" />
            <span className="text-xs">Khám phá</span>
          </Button>
          <Button variant="ghost" size="sm" className="flex flex-col items-center gap-1">
            <Zap className="h-5 w-5 text-pink-500" />
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