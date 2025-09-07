import React, { useState, useEffect } from 'react';
import { Button } from './ui/button';
import { Input } from './ui/input';
import { Badge } from './ui/badge';
import { ArrowLeft, Send, Smile, Heart, MessageCircle, User, Phone, Video, MoreVertical, Image, Gift, Zap } from 'lucide-react';
import { Chat, ChatMessage, User as UserType, Screen } from '../App';
import { ImageWithFallback } from './figma/ImageWithFallback';

interface ChatScreenProps {
  onNavigate: (screen: Screen) => void;
  selectedChat: Chat | null;
  onOpenChat: (chat: Chat) => void;
  onStartVideoCall?: (user: UserType) => void;
}

// Mock data for chats
const mockChats: Chat[] = [
  {
    id: '1',
    user: {
      id: '1',
      name: 'Linh',
      age: 25,
      photos: ['https://images.unsplash.com/photo-1503164585513-5c4f19209317?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHx5b3VuZyUyMGFzaWFuJTIwd29tYW4lMjBwb3J0cmFpdHxlbnwxfHx8fDE3NTcwOTcxNzh8MA&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral'],
      bio: '',
      interests: []
    },
    lastMessage: 'Chào bạn! Mình rất vui khi được kết đôi với bạn 😊',
    timestamp: new Date(Date.now() - 30 * 60 * 1000), // 30 minutes ago
    messages: [
      {
        id: '1',
        senderId: '1',
        message: 'Chào bạn! 👋',
        timestamp: new Date(Date.now() - 2 * 60 * 60 * 1000)
      },
      {
        id: '2',
        senderId: 'me',
        message: 'Chào Linh! Rất vui được làm quen 😊',
        timestamp: new Date(Date.now() - 90 * 60 * 1000)
      },
      {
        id: '3',
        senderId: '1',
        message: 'Mình rất vui khi được kết đôi với bạn 😊',
        timestamp: new Date(Date.now() - 30 * 60 * 1000)
      }
    ]
  },
  {
    id: '2',
    user: {
      id: '2',
      name: 'Minh',
      age: 28,
      photos: ['https://images.unsplash.com/photo-1585923491671-0ced430efe9c?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxoYW5kc29tZSUyMGFzaWFuJTIwbWFuJTIwcG9ydHJhaXR8ZW58MXx8fHwxNzU3MTYwOTMzfDA&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral'],
      bio: '',
      interests: []
    },
    lastMessage: 'Cuối tuần này bạn có rảnh không?',
    timestamp: new Date(Date.now() - 2 * 60 * 60 * 1000), // 2 hours ago
    messages: [
      {
        id: '4',
        senderId: '2',
        message: 'Hi! Tôi thấy bạn cũng thích công nghệ',
        timestamp: new Date(Date.now() - 4 * 60 * 60 * 1000)
      },
      {
        id: '5',
        senderId: 'me',
        message: 'Đúng rồi! Bạn làm trong lĩnh vực gì?',
        timestamp: new Date(Date.now() - 3 * 60 * 60 * 1000)
      },
      {
        id: '6',
        senderId: '2',
        message: 'Cuối tuần này bạn có rảnh không?',
        timestamp: new Date(Date.now() - 2 * 60 * 60 * 1000)
      }
    ]
  },
  {
    id: '3',
    user: {
      id: '3',
      name: 'Hương',
      age: 24,
      photos: ['https://images.unsplash.com/photo-1699454207790-3a95751ace90?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxhdHRyYWN0aXZlJTIwd29tYW4lMjBzZWxmaWV8ZW58MXx8fHwxNzU3MTYwOTMzfDA&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral'],
      bio: '',
      interests: []
    },
    lastMessage: 'Mình vừa vẽ xong một bức tranh mới!',
    timestamp: new Date(Date.now() - 24 * 60 * 60 * 1000), // 1 day ago
    messages: [
      {
        id: '7',
        senderId: '3',
        message: 'Mình vừa vẽ xong một bức tranh mới!',
        timestamp: new Date(Date.now() - 24 * 60 * 60 * 1000)
      }
    ]
  }
];

export function ChatScreen({ onNavigate, selectedChat, onOpenChat, onStartVideoCall }: ChatScreenProps) {
  const [newMessage, setNewMessage] = useState('');
  const [chats, setChats] = useState(mockChats);
  const [isTyping, setIsTyping] = useState(false);
  const [showOnlineStatus, setShowOnlineStatus] = useState(true);

  const formatTime = (date: Date) => {
    const now = new Date();
    const diffInHours = Math.floor((now.getTime() - date.getTime()) / (1000 * 60 * 60));
    
    if (diffInHours < 1) {
      const diffInMinutes = Math.floor((now.getTime() - date.getTime()) / (1000 * 60));
      return `${diffInMinutes} phút`;
    } else if (diffInHours < 24) {
      return `${diffInHours} giờ`;
    } else {
      const diffInDays = Math.floor(diffInHours / 24);
      return `${diffInDays} ngày`;
    }
  };

  useEffect(() => {
    // Simulate typing indicator
    if (selectedChat && Math.random() < 0.3) {
      const timer = setTimeout(() => {
        setIsTyping(true);
        setTimeout(() => {
          setIsTyping(false);
          // Simulate receiving a message
          if (Math.random() < 0.5) {
            const responses = [
              'Haha thật thú vị! 😄',
              'Mình cũng nghĩ vậy',
              'Bạn có kế hoạch gì cuối tuần không?',
              'Cảm ơn bạn đã chia sẻ!',
              'Nghe hay quá! ✨'
            ];
            
            const randomResponse = responses[Math.floor(Math.random() * responses.length)];
            const autoMessage: ChatMessage = {
              id: Date.now().toString(),
              senderId: selectedChat.user.id,
              message: randomResponse,
              timestamp: new Date(),
              isRead: false
            };
            
            setChats(prev => prev.map(chat => 
              chat.id === selectedChat.id 
                ? { 
                    ...chat, 
                    messages: [...chat.messages, autoMessage],
                    lastMessage: randomResponse,
                    timestamp: new Date(),
                    unreadCount: (chat.unreadCount || 0) + 1
                  }
                : chat
            ));
          }
        }, 2000);
      }, 5000);
      
      return () => clearTimeout(timer);
    }
  }, [selectedChat]);

  const handleSendMessage = () => {
    if (!newMessage.trim() || !selectedChat) return;

    const message: ChatMessage = {
      id: Date.now().toString(),
      senderId: 'me',
      message: newMessage,
      timestamp: new Date(),
      isRead: true,
      type: 'text'
    };

    // Update the selected chat with new message
    const updatedChats = chats.map(chat => {
      if (chat.id === selectedChat.id) {
        return {
          ...chat,
          messages: [...chat.messages, message],
          lastMessage: newMessage,
          timestamp: new Date(),
          unreadCount: 0
        };
      }
      return chat;
    });

    setChats(updatedChats);
    setNewMessage('');
  };

  // Chat Detail View
  if (selectedChat) {
    const chat = chats.find(c => c.id === selectedChat.id) || selectedChat;
    
    return (
      <div className="min-h-screen flex flex-col bg-white">
        {/* Header */}
        <div className="flex items-center gap-3 p-4 border-b bg-card">
          <Button variant="ghost" size="sm" onClick={() => onNavigate('chat')}>
            <ArrowLeft className="h-5 w-5" />
          </Button>
          <div className="relative">
            <ImageWithFallback
              src={chat.user.photos[0]}
              alt={chat.user.name}
              className="w-10 h-10 rounded-full object-cover"
            />
            {chat.user.isOnline && (
              <div className="absolute -bottom-1 -right-1 w-3 h-3 bg-green-500 border-2 border-white rounded-full" />
            )}
          </div>
          <div className="flex-1">
            <h2 className="text-lg">{chat.user.name}</h2>
            {isTyping ? (
              <div className="flex items-center gap-2 text-sm text-muted-foreground">
                <div className="flex gap-1">
                  <div className="w-1 h-1 bg-gray-400 rounded-full animate-bounce" style={{ animationDelay: '0ms' }} />
                  <div className="w-1 h-1 bg-gray-400 rounded-full animate-bounce" style={{ animationDelay: '150ms' }} />
                  <div className="w-1 h-1 bg-gray-400 rounded-full animate-bounce" style={{ animationDelay: '300ms' }} />
                </div>
                <span>đang nhập...</span>
              </div>
            ) : (
              <p className="text-sm text-muted-foreground">
                {chat.user.isOnline ? 'Đang hoạt động' : `Hoạt động ${formatTime(chat.user.lastSeen || new Date())} trước`}
              </p>
            )}
          </div>
          
          {/* Action buttons */}
          <div className="flex items-center gap-2">
            <Button variant="ghost" size="sm" onClick={() => onStartVideoCall?.(chat.user)}>
              <Video className="h-5 w-5" />
            </Button>
            <Button variant="ghost" size="sm" onClick={() => onStartVideoCall?.(chat.user)}>
              <Phone className="h-5 w-5" />
            </Button>
            <Button variant="ghost" size="sm">
              <MoreVertical className="h-5 w-5" />
            </Button>
          </div>
        </div>

        {/* Messages */}
        <div className="flex-1 p-4 space-y-4 overflow-y-auto">
          {chat.messages.map((message, index) => (
            <div
              key={message.id}
              className={`flex ${message.senderId === 'me' ? 'justify-end' : 'justify-start'}`}
            >
              <div className={`max-w-xs ${message.senderId === 'me' ? 'order-2' : 'order-1'}`}>
                <div
                  className={`px-4 py-2 rounded-2xl ${
                    message.senderId === 'me'
                      ? 'bg-pink-500 text-white rounded-br-md'
                      : 'bg-muted text-foreground rounded-bl-md'
                  }`}
                >
                  <p>{message.message}</p>
                </div>
                
                {/* Message status and time */}
                <div className={`flex items-center gap-1 mt-1 ${
                  message.senderId === 'me' ? 'justify-end' : 'justify-start'
                }`}>
                  <span className="text-xs text-muted-foreground">
                    {message.timestamp.toLocaleTimeString('vi-VN', { 
                      hour: '2-digit', 
                      minute: '2-digit' 
                    })}
                  </span>
                  {message.senderId === 'me' && (
                    <div className="flex">
                      <div className="w-3 h-3 text-muted-foreground">
                        {message.isRead ? (
                          <svg viewBox="0 0 16 15" className="w-full h-full fill-current">
                            <path d="M15.01 3.316l-.478-.372a.365.365 0 0 0-.51.063L8.666 9.879a.32.32 0 0 1-.484.033l-.358-.325a.319.319 0 0 0-.484.032l-.378.483a.418.418 0 0 0 .036.541l1.32 1.266c.143.14.361.125.484-.033l6.272-8.048a.366.366 0 0 0-.064-.512zm-4.1 0l-.478-.372a.365.365 0 0 0-.51.063L4.566 9.879a.32.32 0 0 1-.484.033L1.891 7.769a.319.319 0 0 0-.484.032l-.378.483a.418.418 0 0 0 .036.541l3.61 3.465c.143.14.361.125.484-.033l6.272-8.048a.365.365 0 0 0-.064-.512z"/>
                          </svg>
                        ) : (
                          <svg viewBox="0 0 12 9" className="w-full h-full fill-current">
                            <path d="M11.1 2.7L10.6 2.3c-.1-.1-.3-.1-.4 0L4.6 7.8c-.1.1-.3.1-.4 0L1.4 5.3c-.1-.1-.3-.1-.4 0l-.4.4c-.1.1-.1.3 0 .4l3.6 3.5c.1.1.3.1.4 0l6.3-6.1c.1-.1.1-.3 0-.4z"/>
                          </svg>
                        )}
                      </div>
                    </div>
                  )}
                </div>
              </div>
            </div>
          ))}
          
          {/* Typing indicator */}
          {isTyping && (
            <div className="flex justify-start">
              <div className="max-w-xs">
                <div className="bg-muted text-foreground px-4 py-2 rounded-2xl rounded-bl-md">
                  <div className="flex gap-2">
                    <div className="w-2 h-2 bg-gray-400 rounded-full animate-bounce" style={{ animationDelay: '0ms' }} />
                    <div className="w-2 h-2 bg-gray-400 rounded-full animate-bounce" style={{ animationDelay: '150ms' }} />
                    <div className="w-2 h-2 bg-gray-400 rounded-full animate-bounce" style={{ animationDelay: '300ms' }} />
                  </div>
                </div>
              </div>
            </div>
          )}
        </div>

        {/* Message Input */}
        <div className="p-4 border-t bg-card">
          {/* Quick actions */}
          <div className="flex gap-2 mb-3">
            <Button variant="outline" size="sm" className="rounded-full">
              <Image className="h-4 w-4 mr-1" />
              Ảnh
            </Button>
            <Button variant="outline" size="sm" className="rounded-full">
              <Gift className="h-4 w-4 mr-1" />
              GIF
            </Button>
            <Button variant="outline" size="sm" className="rounded-full">
              <Heart className="h-4 w-4 mr-1" />
              Sticker
            </Button>
          </div>
          
          <div className="flex items-center gap-3">
            <div className="flex-1 relative">
              <Input
                value={newMessage}
                onChange={(e) => setNewMessage(e.target.value)}
                placeholder="Nhập tin nhắn..."
                className="pr-12"
                onKeyPress={(e) => e.key === 'Enter' && handleSendMessage()}
              />
              <Button
                variant="ghost"
                size="sm"
                className="absolute right-2 top-1/2 transform -translate-y-1/2 p-1"
              >
                <Smile className="h-5 w-5 text-muted-foreground" />
              </Button>
            </div>
            <Button
              onClick={handleSendMessage}
              disabled={!newMessage.trim()}
              className="bg-pink-500 hover:bg-pink-600 w-10 h-10 rounded-full p-0"
            >
              <Send className="h-5 w-5" />
            </Button>
          </div>
        </div>
      </div>
    );
  }

  // Chat List View
  return (
    <div className="min-h-screen bg-background">
      {/* Header */}
      <div className="bg-card border-b p-4">
        <h1 className="text-xl">Tin nhắn</h1>
      </div>

      {/* Chat List */}
      <div className="divide-y divide-border">
        {chats.map((chat) => (
          <div
            key={chat.id}
            onClick={() => onOpenChat(chat)}
            className="bg-card p-4 hover:bg-muted/50 cursor-pointer transition-colors"
          >
            <div className="flex items-center gap-3">
              <div className="relative">
                <ImageWithFallback
                  src={chat.user.photos[0]}
                  alt={chat.user.name}
                  className="w-12 h-12 rounded-full object-cover"
                />
                {chat.user.isOnline && (
                  <div className="absolute -bottom-1 -right-1 w-4 h-4 bg-green-500 border-2 border-white rounded-full" />
                )}
              </div>
              <div className="flex-1 min-w-0">
                <div className="flex items-center justify-between mb-1">
                  <div className="flex items-center gap-2">
                    <h3 className="truncate">{chat.user.name}</h3>
                    {chat.user.verified && (
                      <div className="w-3 h-3 bg-blue-500 rounded-full flex items-center justify-center">
                        <svg className="w-2 h-2 text-white" fill="currentColor" viewBox="0 0 20 20">
                          <path fillRule="evenodd" d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z" clipRule="evenodd" />
                        </svg>
                      </div>
                    )}
                  </div>
                  <div className="flex items-center gap-2">
                    <span className="text-xs text-muted-foreground">{formatTime(chat.timestamp)}</span>
                    {chat.unreadCount && chat.unreadCount > 0 && (
                      <Badge className="bg-pink-500 text-white h-5 min-w-5 text-xs rounded-full flex items-center justify-center px-1">
                        {chat.unreadCount > 9 ? '9+' : chat.unreadCount}
                      </Badge>
                    )}
                  </div>
                </div>
                <div className="flex items-center justify-between">
                  <p className="text-sm text-muted-foreground truncate flex-1 mr-2">
                    {chat.isTyping ? (
                      <span className="text-green-600 italic">đang nhập...</span>
                    ) : (
                      chat.lastMessage
                    )}
                  </p>
                </div>
              </div>
            </div>
          </div>
        ))}
      </div>

      {/* Empty State */}
      {chats.length === 0 && (
        <div className="flex flex-col items-center justify-center py-16">
          <MessageCircle className="h-16 w-16 text-gray-300 mb-4" />
          <h3 className="text-lg text-gray-900 mb-2">Chưa có tin nhắn nào</h3>
          <p className="text-gray-600 text-center">
            Khi bạn kết đôi với ai đó, tin nhắn sẽ xuất hiện ở đây
          </p>
        </div>
      )}

      {/* Bottom Navigation */}
      <div className="border-t bg-card p-4 mt-8">
        <div className="flex justify-around">
          <Button variant="ghost" size="sm" className="flex flex-col items-center gap-1" onClick={() => onNavigate('discovery')}>
            <Heart className="h-5 w-5" />
            <span className="text-xs">Khám phá</span>
          </Button>
          <Button variant="ghost" size="sm" className="flex flex-col items-center gap-1" onClick={() => onNavigate('matches')}>
            <Zap className="h-5 w-5" />
            <span className="text-xs">Kết đôi</span>
          </Button>
          <Button variant="ghost" size="sm" className="flex flex-col items-center gap-1">
            <MessageCircle className="h-5 w-5 text-pink-500" />
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