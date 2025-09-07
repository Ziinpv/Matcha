import React, { useState, createContext, useContext } from 'react';
import { LoginScreen } from './components/LoginScreen';
import { SignUpScreen } from './components/SignUpScreen';
import { DiscoveryScreen } from './components/DiscoveryScreen';
import { ProfileScreen } from './components/ProfileScreen';
import { ChatScreen } from './components/ChatScreen';
import { SettingsScreen } from './components/SettingsScreen';
import { MatchesScreen } from './components/MatchesScreen';
import { NotificationScreen } from './components/NotificationScreen';
import { VideoCallScreen } from './components/VideoCallScreen';
import { StoriesScreen } from './components/StoriesScreen';

export type Screen = 'login' | 'signup' | 'discovery' | 'profile' | 'chat' | 'settings' | 'matches' | 'notifications' | 'videocall' | 'stories';

export interface User {
  id: string;
  name: string;
  age: number;
  photos: string[];
  bio: string;
  interests: string[];
  distance?: number;
  isOnline?: boolean;
  lastSeen?: Date;
  verified?: boolean;
  compatibilityScore?: number;
  mutualFriends?: number;
  isPremium?: boolean;
}

export interface ChatMessage {
  id: string;
  senderId: string;
  message: string;
  timestamp: Date;
  type?: 'text' | 'image' | 'voice' | 'gif';
  isRead?: boolean;
}

export interface Chat {
  id: string;
  user: User;
  lastMessage: string;
  timestamp: Date;
  messages: ChatMessage[];
  isTyping?: boolean;
  unreadCount?: number;
}

export interface Match {
  id: string;
  user: User;
  timestamp: Date;
  isNew: boolean;
  matchType: 'like' | 'superlike';
}

export interface Notification {
  id: string;
  type: 'like' | 'match' | 'message' | 'superlike' | 'view';
  user?: User;
  message: string;
  timestamp: Date;
  isRead: boolean;
}

export interface Story {
  id: string;
  userId: string;
  imageUrl: string;
  timestamp: Date;
  isViewed: boolean;
}

export interface AppContextType {
  isDarkMode: boolean;
  toggleDarkMode: () => void;
  notifications: Notification[];
  addNotification: (notification: Omit<Notification, 'id'>) => void;
  markNotificationAsRead: (id: string) => void;
  matches: Match[];
  addMatch: (match: Omit<Match, 'id'>) => void;
}

const AppContext = createContext<AppContextType | undefined>(undefined);

export const useApp = () => {
  const context = useContext(AppContext);
  if (!context) {
    throw new Error('useApp must be used within AppProvider');
  }
  return context;
};

export default function App() {
  const [currentScreen, setCurrentScreen] = useState<Screen>('login');
  const [isLoggedIn, setIsLoggedIn] = useState(false);
  const [currentUser, setCurrentUser] = useState<User | null>(null);
  const [selectedChat, setSelectedChat] = useState<Chat | null>(null);
  const [isDarkMode, setIsDarkMode] = useState(false);
  const [notifications, setNotifications] = useState<Notification[]>([]);
  const [matches, setMatches] = useState<Match[]>([]);
  const [activeCall, setActiveCall] = useState<User | null>(null);

  const toggleDarkMode = () => {
    setIsDarkMode(!isDarkMode);
    document.documentElement.classList.toggle('dark', !isDarkMode);
  };

  const addNotification = (notification: Omit<Notification, 'id'>) => {
    const newNotification: Notification = {
      ...notification,
      id: Date.now().toString(),
    };
    setNotifications(prev => [newNotification, ...prev]);
  };

  const markNotificationAsRead = (id: string) => {
    setNotifications(prev => 
      prev.map(notif => 
        notif.id === id ? { ...notif, isRead: true } : notif
      )
    );
  };

  const addMatch = (match: Omit<Match, 'id'>) => {
    const newMatch: Match = {
      ...match,
      id: Date.now().toString(),
    };
    setMatches(prev => [newMatch, ...prev]);
    
    // Add notification for new match
    addNotification({
      type: 'match',
      user: match.user,
      message: `Bạn và ${match.user.name} đã kết đôi!`,
      timestamp: new Date(),
      isRead: false,
    });
  };

  const handleLogin = () => {
    // Create a mock user profile for login
    const mockUser: User = {
      id: 'current-user',
      name: 'Bạn',
      age: 25,
      photos: [
        'https://images.unsplash.com/photo-1662695089339-a2c24231a3ac?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHx5b3VuZyUyMHBlcnNvbiUyMHByb2ZpbGUlMjBzZWxmaWV8ZW58MXx8fHwxNzU3MjM1MDY2fDA&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral'
      ],
      bio: 'Chào mừng bạn đến với Matcha! Hãy cập nhật thông tin cá nhân để bắt đầu tìm kiếm những kết nối tuyệt vời.',
      interests: ['Du lịch', 'Âm nhạc', 'Phim ảnh', 'Thể thao'],
      verified: true,
      isPremium: false,
      isOnline: true
    };

    setCurrentUser(mockUser);
    setIsLoggedIn(true);
    setCurrentScreen('discovery');
    
    // Mock some initial notifications and matches
    setTimeout(() => {
      addNotification({
        type: 'like',
        message: 'Có người mới thích bạn!',
        timestamp: new Date(Date.now() - 30 * 60 * 1000),
        isRead: false,
      });
    }, 1000);
  };

  const handleSignUpComplete = (user: User) => {
    setCurrentUser(user);
    setIsLoggedIn(true);
    setCurrentScreen('discovery');
  };

  const navigateTo = (screen: Screen) => {
    setCurrentScreen(screen);
    if (screen !== 'chat') {
      setSelectedChat(null);
    }
    if (screen !== 'videocall') {
      setActiveCall(null);
    }
  };

  const openChat = (chat: Chat) => {
    setSelectedChat(chat);
    setCurrentScreen('chat');
  };

  const startVideoCall = (user: User) => {
    setActiveCall(user);
    setCurrentScreen('videocall');
  };

  const appContextValue: AppContextType = {
    isDarkMode,
    toggleDarkMode,
    notifications,
    addNotification,
    markNotificationAsRead,
    matches,
    addMatch,
  };

  if (!isLoggedIn) {
    return (
      <div className={`min-h-screen bg-gradient-to-br from-pink-50 to-rose-100 ${isDarkMode ? 'dark' : ''}`}>
        {currentScreen === 'login' ? (
          <LoginScreen onLogin={handleLogin} onSwitchToSignUp={() => setCurrentScreen('signup')} />
        ) : (
          <SignUpScreen onSignUpComplete={handleSignUpComplete} onBackToLogin={() => setCurrentScreen('login')} />
        )}
      </div>
    );
  }

  return (
    <AppContext.Provider value={appContextValue}>
      <div className={`min-h-screen bg-background ${isDarkMode ? 'dark' : ''}`}>
        {currentScreen === 'discovery' && (
          <DiscoveryScreen onNavigate={navigateTo} currentUser={currentUser} />
        )}
        {currentScreen === 'matches' && (
          <MatchesScreen onNavigate={navigateTo} onOpenChat={openChat} />
        )}
        {currentScreen === 'profile' && (
          <ProfileScreen onNavigate={navigateTo} currentUser={currentUser} setCurrentUser={setCurrentUser} />
        )}
        {currentScreen === 'chat' && (
          <ChatScreen onNavigate={navigateTo} selectedChat={selectedChat} onOpenChat={openChat} onStartVideoCall={startVideoCall} />
        )}
        {currentScreen === 'notifications' && (
          <NotificationScreen onNavigate={navigateTo} />
        )}
        {currentScreen === 'videocall' && (
          <VideoCallScreen onNavigate={navigateTo} callUser={activeCall} />
        )}
        {currentScreen === 'stories' && (
          <StoriesScreen onNavigate={navigateTo} />
        )}
        {currentScreen === 'settings' && (
          <SettingsScreen onNavigate={navigateTo} />
        )}
      </div>
    </AppContext.Provider>
  );
}