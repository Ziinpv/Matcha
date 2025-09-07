import React, { useState } from 'react';
import { Button } from './ui/button';
import { Badge } from './ui/badge';
import { Card, CardContent } from './ui/card';
import { Switch } from './ui/switch';
import { ArrowLeft, Edit3, Settings, Crown, Star, MessageCircle, User, Heart, Moon, Sun, Shield, Zap } from 'lucide-react';
import { User as UserType, Screen } from '../App';
import { useApp } from '../App';
import { ImageWithFallback } from './figma/ImageWithFallback';

interface ProfileScreenProps {
  onNavigate: (screen: Screen) => void;
  currentUser: UserType | null;
  setCurrentUser: (user: UserType | null) => void;
}

export function ProfileScreen({ onNavigate, currentUser, setCurrentUser }: ProfileScreenProps) {
  const [isEditing, setIsEditing] = useState(false);
  const { isDarkMode, toggleDarkMode } = useApp();

  if (!currentUser) {
    return (
      <div className="min-h-screen flex items-center justify-center">
        <p>Không tìm thấy thông tin người dùng</p>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-background">
      {/* Header */}
      <div className="bg-card border-b p-4">
        <div className="flex items-center justify-between">
          <h1 className="text-xl">Hồ sơ của tôi</h1>
          <Button variant="ghost" size="sm" onClick={() => setIsEditing(!isEditing)}>
            <Edit3 className="h-5 w-5" />
          </Button>
        </div>
      </div>

      <div className="p-4 space-y-6">
        {/* Profile Header */}
        <Card>
          <CardContent className="p-6">
            <div className="flex items-center gap-4 mb-6">
              <div className="relative">
                <ImageWithFallback
                  src={currentUser.photos[0]}
                  alt={currentUser.name}
                  className="w-20 h-20 rounded-full object-cover"
                />
                {isEditing && (
                  <Button size="sm" className="absolute -bottom-2 -right-2 w-8 h-8 rounded-full p-0">
                    <Edit3 className="h-4 w-4" />
                  </Button>
                )}
              </div>
              <div className="flex-1">
                <div className="flex items-center gap-2 mb-1">
                  <h2 className="text-xl">{currentUser.name}</h2>
                  <span className="text-lg text-muted-foreground">{currentUser.age}</span>
                  {currentUser.verified && (
                    <div className="w-5 h-5 bg-blue-500 rounded-full flex items-center justify-center">
                      <svg className="w-3 h-3 text-white" fill="currentColor" viewBox="0 0 20 20">
                        <path fillRule="evenodd" d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z" clipRule="evenodd" />
                      </svg>
                    </div>
                  )}
                </div>
                <div className="flex items-center gap-3 text-sm text-muted-foreground">
                  <span>Thành viên Matcha</span>
                  {currentUser.isOnline && (
                    <>
                      <div className="w-1 h-1 bg-gray-400 rounded-full" />
                      <div className="flex items-center gap-1">
                        <div className="w-2 h-2 bg-green-500 rounded-full" />
                        <span className="text-green-600">Đang online</span>
                      </div>
                    </>
                  )}
                </div>
              </div>
            </div>

            {/* Profile Completeness */}
            <div className="bg-gradient-to-r from-green-50 to-emerald-50 border border-green-200 rounded-lg p-4 mb-4">
              <div className="flex items-center justify-between mb-2">
                <h4 className="text-sm">Hoàn thiện hồ sơ</h4>
                <span className="text-sm text-green-600">75%</span>
              </div>
              <div className="w-full bg-green-100 rounded-full h-2 mb-2">
                <div className="bg-green-500 h-2 rounded-full" style={{width: '75%'}}></div>
              </div>
              <p className="text-xs text-muted-foreground">Thêm 2 ảnh nữa để tăng cơ hội kết đôi!</p>
            </div>

            {/* Premium Upsell */}
            <div className="bg-gradient-to-r from-yellow-50 to-amber-50 border border-yellow-200 rounded-lg p-4">
              <div className="flex items-center gap-3">
                <div className="bg-yellow-500 p-2 rounded-full">
                  <Crown className="h-5 w-5 text-white" />
                </div>
                <div className="flex-1">
                  <h3 className="text-sm">Nâng cấp lên Premium</h3>
                  <p className="text-xs text-muted-foreground">Xem ai đã thích bạn và nhiều tính năng khác</p>
                </div>
                <Button size="sm" className="bg-yellow-500 hover:bg-yellow-600">
                  Nâng cấp
                </Button>
              </div>
            </div>
          </CardContent>
        </Card>

        {/* Photos */}
        <Card>
          <CardContent className="p-6">
            <div className="flex items-center justify-between mb-4">
              <h3>Ảnh của tôi</h3>
              {isEditing && (
                <Button variant="outline" size="sm">
                  Thêm ảnh
                </Button>
              )}
            </div>
            <div className="grid grid-cols-3 gap-3">
              {currentUser.photos.map((photo, index) => (
                <div key={index} className="aspect-square rounded-lg overflow-hidden bg-gray-100">
                  <ImageWithFallback
                    src={photo}
                    alt={`Photo ${index + 1}`}
                    className="w-full h-full object-cover"
                  />
                </div>
              ))}
              {currentUser.photos.length < 5 && isEditing && (
                <div className="aspect-square border-2 border-dashed border-gray-300 rounded-lg flex items-center justify-center">
                  <span className="text-4xl text-gray-300">+</span>
                </div>
              )}
            </div>
          </CardContent>
        </Card>

        {/* Bio */}
        <Card>
          <CardContent className="p-6">
            <div className="flex items-center justify-between mb-4">
              <h3>Giới thiệu</h3>
              {isEditing && (
                <Button variant="outline" size="sm">
                  <Edit3 className="h-4 w-4" />
                </Button>
              )}
            </div>
            <p className="text-gray-700 leading-relaxed">{currentUser.bio}</p>
          </CardContent>
        </Card>

        {/* Interests */}
        <Card>
          <CardContent className="p-6">
            <div className="flex items-center justify-between mb-4">
              <h3>Sở thích</h3>
              {isEditing && (
                <Button variant="outline" size="sm">
                  <Edit3 className="h-4 w-4" />
                </Button>
              )}
            </div>
            <div className="flex flex-wrap gap-2">
              {currentUser.interests.map((interest) => (
                <Badge key={interest} variant="secondary">
                  {interest}
                </Badge>
              ))}
            </div>
          </CardContent>
        </Card>

        {/* Stats */}
        <Card>
          <CardContent className="p-6">
            <h3 className="mb-4">Thống kê của bạn</h3>
            <div className="grid grid-cols-2 gap-4 mb-4">
              <div className="bg-gradient-to-r from-pink-50 to-rose-50 p-4 rounded-lg border">
                <div className="flex items-center gap-3">
                  <div className="bg-pink-500 p-2 rounded-full">
                    <Heart className="h-4 w-4 text-white" />
                  </div>
                  <div>
                    <div className="text-xl text-pink-600">24</div>
                    <div className="text-sm text-muted-foreground">Lượt thích</div>
                  </div>
                </div>
              </div>
              
              <div className="bg-gradient-to-r from-blue-50 to-cyan-50 p-4 rounded-lg border">
                <div className="flex items-center gap-3">
                  <div className="bg-blue-500 p-2 rounded-full">
                    <Zap className="h-4 w-4 text-white" />
                  </div>
                  <div>
                    <div className="text-xl text-blue-600">12</div>
                    <div className="text-sm text-muted-foreground">Kết đôi</div>
                  </div>
                </div>
              </div>
              
              <div className="bg-gradient-to-r from-purple-50 to-indigo-50 p-4 rounded-lg border">
                <div className="flex items-center gap-3">
                  <div className="bg-purple-500 p-2 rounded-full">
                    <Star className="h-4 w-4 text-white fill-current" />
                  </div>
                  <div>
                    <div className="text-xl text-purple-600">8</div>
                    <div className="text-sm text-muted-foreground">Super Likes</div>
                  </div>
                </div>
              </div>
              
              <div className="bg-gradient-to-r from-green-50 to-emerald-50 p-4 rounded-lg border">
                <div className="flex items-center gap-3">
                  <div className="bg-green-500 p-2 rounded-full">
                    <MessageCircle className="h-4 w-4 text-white" />
                  </div>
                  <div>
                    <div className="text-xl text-green-600">156</div>
                    <div className="text-sm text-muted-foreground">Tin nhắn</div>
                  </div>
                </div>
              </div>
            </div>
            
            {/* Weekly stats */}
            <div className="pt-4 border-t">
              <div className="flex items-center justify-between text-sm mb-2">
                <span className="text-muted-foreground">Hoạt động tuần này</span>
                <span className="text-green-600">+15% ↗</span>
              </div>
              <div className="w-full bg-gray-200 rounded-full h-2">
                <div className="bg-gradient-to-r from-pink-500 to-purple-500 h-2 rounded-full" style={{width: '68%'}}></div>
              </div>
            </div>
          </CardContent>
        </Card>

        {/* Achievements */}
        <Card>
          <CardContent className="p-6">
            <h3 className="mb-4">Huy hiệu</h3>
            <div className="grid grid-cols-3 gap-4">
              <div className="text-center p-3 bg-yellow-50 rounded-lg border">
                <div className="w-8 h-8 bg-yellow-500 rounded-full flex items-center justify-center mx-auto mb-2">
                  <Crown className="h-4 w-4 text-white" />
                </div>
                <p className="text-xs">Người mới</p>
              </div>
              
              <div className="text-center p-3 bg-pink-50 rounded-lg border">
                <div className="w-8 h-8 bg-pink-500 rounded-full flex items-center justify-center mx-auto mb-2">
                  <Heart className="h-4 w-4 text-white fill-current" />
                </div>
                <p className="text-xs">Được yêu thích</p>
              </div>
              
              <div className="text-center p-3 bg-blue-50 rounded-lg border opacity-50">
                <div className="w-8 h-8 bg-gray-300 rounded-full flex items-center justify-center mx-auto mb-2">
                  <Star className="h-4 w-4 text-gray-500" />
                </div>
                <p className="text-xs">Siêu sao</p>
              </div>
              
              <div className="text-center p-3 bg-green-50 rounded-lg border opacity-50">
                <div className="w-8 h-8 bg-gray-300 rounded-full flex items-center justify-center mx-auto mb-2">
                  <MessageCircle className="h-4 w-4 text-gray-500" />
                </div>
                <p className="text-xs">Tám chuyện</p>
              </div>
              
              <div className="text-center p-3 bg-purple-50 rounded-lg border opacity-50">
                <div className="w-8 h-8 bg-gray-300 rounded-full flex items-center justify-center mx-auto mb-2">
                  <Zap className="h-4 w-4 text-gray-500" />
                </div>
                <p className="text-xs">Thần tốc</p>
              </div>
              
              <div className="text-center p-3 bg-red-50 rounded-lg border opacity-50">
                <div className="w-8 h-8 bg-gray-300 rounded-full flex items-center justify-center mx-auto mb-2">
                  <Shield className="h-4 w-4 text-gray-500" />
                </div>
                <p className="text-xs">Xác thực</p>
              </div>
            </div>
            <p className="text-sm text-muted-foreground mt-3 text-center">
              Tiếp tục sử dụng để mở khóa thêm nhiều huy hiệu!
            </p>
          </CardContent>
        </Card>

        {/* Quick Settings */}
        <Card>
          <CardContent className="p-6">
            <h3 className="mb-4">Cài đặt nhanh</h3>
            <div className="space-y-4">
              <div className="flex items-center justify-between">
                <div className="flex items-center gap-3">
                  {isDarkMode ? <Moon className="h-5 w-5" /> : <Sun className="h-5 w-5" />}
                  <div>
                    <p>Chế độ tối</p>
                    <p className="text-sm text-muted-foreground">Bảo vệ mắt trong điều kiện ánh sáng yếu</p>
                  </div>
                </div>
                <Switch checked={isDarkMode} onCheckedChange={toggleDarkMode} />
              </div>
              
              <Button variant="ghost" className="w-full justify-start" onClick={() => onNavigate('settings')}>
                <Settings className="h-5 w-5 mr-3" />
                Cài đặt chi tiết
              </Button>
              
              <Button variant="ghost" className="w-full justify-start">
                <Shield className="h-5 w-5 mr-3" />
                An toàn & Bảo mật
              </Button>
              
              <Button variant="ghost" className="w-full justify-start text-red-600 hover:text-red-700 hover:bg-red-50">
                Đăng xuất
              </Button>
            </div>
          </CardContent>
        </Card>
      </div>

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
          <Button variant="ghost" size="sm" className="flex flex-col items-center gap-1" onClick={() => onNavigate('chat')}>
            <MessageCircle className="h-5 w-5" />
            <span className="text-xs">Tin nhắn</span>
          </Button>
          <Button variant="ghost" size="sm" className="flex flex-col items-center gap-1">
            <User className="h-5 w-5 text-pink-500" />
            <span className="text-xs">Hồ sơ</span>
          </Button>
        </div>
      </div>
    </div>
  );
}