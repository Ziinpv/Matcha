import React from 'react';
import { Button } from './ui/button';
import { Badge } from './ui/badge';
import { ArrowLeft, Heart, MessageCircle, Star, Eye, User as UserIcon } from 'lucide-react';
import { Screen } from '../App';
import { useApp } from '../App';
import { ImageWithFallback } from './figma/ImageWithFallback';

interface NotificationScreenProps {
  onNavigate: (screen: Screen) => void;
}

export function NotificationScreen({ onNavigate }: NotificationScreenProps) {
  const { notifications, markNotificationAsRead } = useApp();

  const getNotificationIcon = (type: string) => {
    switch (type) {
      case 'like':
        return <Heart className="h-5 w-5 text-pink-500" />;
      case 'superlike':
        return <Star className="h-5 w-5 text-blue-500 fill-current" />;
      case 'match':
        return <Heart className="h-5 w-5 text-green-500 fill-current" />;
      case 'message':
        return <MessageCircle className="h-5 w-5 text-blue-500" />;
      case 'view':
        return <Eye className="h-5 w-5 text-purple-500" />;
      default:
        return <UserIcon className="h-5 w-5 text-gray-500" />;
    }
  };

  const getNotificationColor = (type: string) => {
    switch (type) {
      case 'like':
        return 'bg-pink-50 border-pink-200';
      case 'superlike':
        return 'bg-blue-50 border-blue-200';
      case 'match':
        return 'bg-green-50 border-green-200';
      case 'message':
        return 'bg-blue-50 border-blue-200';
      case 'view':
        return 'bg-purple-50 border-purple-200';
      default:
        return 'bg-gray-50 border-gray-200';
    }
  };

  const formatTime = (date: Date) => {
    const now = new Date();
    const diffInMinutes = Math.floor((now.getTime() - date.getTime()) / (1000 * 60));
    
    if (diffInMinutes < 1) {
      return 'Vừa mới';
    } else if (diffInMinutes < 60) {
      return `${diffInMinutes} phút trước`;
    } else if (diffInMinutes < 24 * 60) {
      const hours = Math.floor(diffInMinutes / 60);
      return `${hours} giờ trước`;
    } else {
      const days = Math.floor(diffInMinutes / (24 * 60));
      return `${days} ngày trước`;
    }
  };

  const handleNotificationClick = (notification: any) => {
    if (!notification.isRead) {
      markNotificationAsRead(notification.id);
    }
    
    // Navigate based on notification type
    switch (notification.type) {
      case 'message':
        onNavigate('chat');
        break;
      case 'match':
        onNavigate('matches');
        break;
      case 'like':
      case 'superlike':
        onNavigate('matches');
        break;
      default:
        break;
    }
  };

  const unreadCount = notifications.filter(n => !n.isRead).length;

  return (
    <div className="min-h-screen bg-background">
      {/* Header */}
      <div className="bg-card border-b p-4">
        <div className="flex items-center gap-3">
          <Button variant="ghost" size="sm" onClick={() => onNavigate('discovery')}>
            <ArrowLeft className="h-5 w-5" />
          </Button>
          <div className="flex-1">
            <h1 className="text-xl">Thông báo</h1>
            {unreadCount > 0 && (
              <p className="text-sm text-muted-foreground">{unreadCount} thông báo chưa đọc</p>
            )}
          </div>
        </div>
      </div>

      {/* Notifications List */}
      <div className="p-4">
        {notifications.length > 0 ? (
          <div className="space-y-3">
            {notifications.map((notification) => (
              <div
                key={notification.id}
                onClick={() => handleNotificationClick(notification)}
                className={`
                  relative p-4 rounded-xl border cursor-pointer transition-all hover:shadow-sm
                  ${notification.isRead ? 'bg-card' : getNotificationColor(notification.type)}
                  ${!notification.isRead ? 'border-l-4' : ''}
                `}
              >
                <div className="flex items-start gap-3">
                  {/* Notification Icon */}
                  <div className="flex-shrink-0 mt-1">
                    {getNotificationIcon(notification.type)}
                  </div>
                  
                  {/* User Avatar (if applicable) */}
                  {notification.user && (
                    <div className="flex-shrink-0">
                      <ImageWithFallback
                        src={notification.user.photos[0]}
                        alt={notification.user.name}
                        className="w-12 h-12 rounded-full object-cover"
                      />
                    </div>
                  )}
                  
                  {/* Content */}
                  <div className="flex-1 min-w-0">
                    <div className="flex items-start justify-between">
                      <div className="flex-1">
                        <p className={`text-sm ${!notification.isRead ? 'font-medium' : ''}`}>
                          {notification.message}
                        </p>
                        <p className="text-xs text-muted-foreground mt-1">
                          {formatTime(notification.timestamp)}
                        </p>
                      </div>
                      
                      {!notification.isRead && (
                        <div className="w-2 h-2 bg-pink-500 rounded-full flex-shrink-0 ml-2 mt-2" />
                      )}
                    </div>
                  </div>
                </div>
              </div>
            ))}
          </div>
        ) : (
          <div className="text-center py-16">
            <div className="w-16 h-16 bg-gray-100 rounded-full flex items-center justify-center mx-auto mb-4">
              <Heart className="h-8 w-8 text-gray-400" />
            </div>
            <h3 className="text-lg mb-2">Chưa có thông báo</h3>
            <p className="text-muted-foreground mb-4">
              Các thông báo về lượt thích, kết đôi và tin nhắn sẽ xuất hiện ở đây
            </p>
            <Button onClick={() => onNavigate('discovery')}>
              Bắt đầu khám phá
            </Button>
          </div>
        )}
      </div>

      {/* Quick Actions */}
      {notifications.length > 0 && unreadCount > 0 && (
        <div className="p-4 border-t bg-card">
          <Button
            variant="outline"
            onClick={() => {
              notifications.forEach(n => {
                if (!n.isRead) {
                  markNotificationAsRead(n.id);
                }
              });
            }}
            className="w-full"
          >
            Đánh dấu tất cả đã đọc
          </Button>
        </div>
      )}
    </div>
  );
}