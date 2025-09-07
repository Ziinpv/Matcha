import React, { useState } from 'react';
import { Button } from './ui/button';
import { Card, CardContent, CardHeader, CardTitle } from './ui/card';
import { Slider } from './ui/slider';
import { Switch } from './ui/switch';
import { Label } from './ui/label';
import { ArrowLeft, MapPin, Calendar, Bell, Shield, Trash2 } from 'lucide-react';
import { Screen } from '../App';

interface SettingsScreenProps {
  onNavigate: (screen: Screen) => void;
}

export function SettingsScreen({ onNavigate }: SettingsScreenProps) {
  const [distance, setDistance] = useState([20]);
  const [ageRange, setAgeRange] = useState([22, 35]);
  const [notifications, setNotifications] = useState({
    matches: true,
    messages: true,
    likes: false,
    marketing: false
  });

  return (
    <div className="min-h-screen bg-gray-50">
      {/* Header */}
      <div className="bg-white border-b p-4">
        <div className="flex items-center gap-3">
          <Button variant="ghost" size="sm" onClick={() => onNavigate('discovery')}>
            <ArrowLeft className="h-5 w-5" />
          </Button>
          <h1 className="text-xl">Cài đặt</h1>
        </div>
      </div>

      <div className="p-4 space-y-6">
        {/* Discovery Filters */}
        <Card>
          <CardHeader>
            <CardTitle className="flex items-center gap-2">
              <MapPin className="h-5 w-5" />
              Bộ lọc khám phá
            </CardTitle>
          </CardHeader>
          <CardContent className="space-y-6">
            {/* Distance Filter */}
            <div>
              <div className="flex items-center justify-between mb-3">
                <Label>Khoảng cách tối đa</Label>
                <span className="text-sm text-gray-600">{distance[0]}km</span>
              </div>
              <Slider
                value={distance}
                onValueChange={setDistance}
                max={100}
                min={1}
                step={1}
                className="w-full"
              />
              <div className="flex justify-between text-xs text-gray-500 mt-1">
                <span>1km</span>
                <span>100km</span>
              </div>
            </div>

            {/* Age Range Filter */}
            <div>
              <div className="flex items-center justify-between mb-3">
                <Label>Độ tuổi</Label>
                <span className="text-sm text-gray-600">{ageRange[0]} - {ageRange[1]} tuổi</span>
              </div>
              <Slider
                value={ageRange}
                onValueChange={setAgeRange}
                max={65}
                min={18}
                step={1}
                className="w-full"
              />
              <div className="flex justify-between text-xs text-gray-500 mt-1">
                <span>18</span>
                <span>65</span>
              </div>
            </div>
          </CardContent>
        </Card>

        {/* Notifications */}
        <Card>
          <CardHeader>
            <CardTitle className="flex items-center gap-2">
              <Bell className="h-5 w-5" />
              Thông báo
            </CardTitle>
          </CardHeader>
          <CardContent className="space-y-4">
            <div className="flex items-center justify-between">
              <div>
                <Label>Kết đôi mới</Label>
                <p className="text-sm text-gray-600">Nhận thông báo khi có kết đôi</p>
              </div>
              <Switch
                checked={notifications.matches}
                onCheckedChange={(checked) => 
                  setNotifications({...notifications, matches: checked})
                }
              />
            </div>

            <div className="flex items-center justify-between">
              <div>
                <Label>Tin nhắn</Label>
                <p className="text-sm text-gray-600">Nhận thông báo tin nhắn mới</p>
              </div>
              <Switch
                checked={notifications.messages}
                onCheckedChange={(checked) => 
                  setNotifications({...notifications, messages: checked})
                }
              />
            </div>

            <div className="flex items-center justify-between">
              <div>
                <Label>Lượt thích</Label>
                <p className="text-sm text-gray-600">Nhận thông báo khi được thích</p>
              </div>
              <Switch
                checked={notifications.likes}
                onCheckedChange={(checked) => 
                  setNotifications({...notifications, likes: checked})
                }
              />
            </div>

            <div className="flex items-center justify-between">
              <div>
                <Label>Khuyến mãi</Label>
                <p className="text-sm text-gray-600">Nhận email về ưu đãi</p>
              </div>
              <Switch
                checked={notifications.marketing}
                onCheckedChange={(checked) => 
                  setNotifications({...notifications, marketing: checked})
                }
              />
            </div>
          </CardContent>
        </Card>

        {/* Privacy & Safety */}
        <Card>
          <CardHeader>
            <CardTitle className="flex items-center gap-2">
              <Shield className="h-5 w-5" />
              Quyền riêng tư & An toàn
            </CardTitle>
          </CardHeader>
          <CardContent className="space-y-3">
            <Button variant="ghost" className="w-full justify-start">
              Chặn & Báo cáo
            </Button>
            <Button variant="ghost" className="w-full justify-start">
              Kiểm soát hiển thị hồ sơ
            </Button>
            <Button variant="ghost" className="w-full justify-start">
              Dữ liệu cá nhân
            </Button>
            <Button variant="ghost" className="w-full justify-start">
              Điều khoản sử dụng
            </Button>
            <Button variant="ghost" className="w-full justify-start">
              Chính sách bảo mật
            </Button>
          </CardContent>
        </Card>

        {/* Account Management */}
        <Card>
          <CardHeader>
            <CardTitle>Quản lý tài khoản</CardTitle>
          </CardHeader>
          <CardContent className="space-y-3">
            <Button variant="ghost" className="w-full justify-start">
              Thay đổi mật khẩu
            </Button>
            <Button variant="ghost" className="w-full justify-start">
              Kết nối mạng xã hội
            </Button>
            <Button variant="ghost" className="w-full justify-start">
              Tạm ẩn hồ sơ
            </Button>
            <Button 
              variant="ghost" 
              className="w-full justify-start text-red-600 hover:text-red-700 hover:bg-red-50"
            >
              <Trash2 className="h-4 w-4 mr-2" />
              Xóa tài khoản
            </Button>
          </CardContent>
        </Card>

        {/* Support */}
        <Card>
          <CardHeader>
            <CardTitle>Hỗ trợ</CardTitle>
          </CardHeader>
          <CardContent className="space-y-3">
            <Button variant="ghost" className="w-full justify-start">
              Trung tâm trợ giúp
            </Button>
            <Button variant="ghost" className="w-full justify-start">
              Liên hệ hỗ trợ
            </Button>
            <Button variant="ghost" className="w-full justify-start">
              Phản hồi
            </Button>
          </CardContent>
        </Card>

        {/* App Info */}
        <div className="text-center text-sm text-gray-500 py-4">
          <p>Matcha v1.0.0</p>
          <p>© 2025 Matcha Dating App</p>
        </div>
      </div>
    </div>
  );
}