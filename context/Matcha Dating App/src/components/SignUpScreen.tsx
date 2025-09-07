import React, { useState } from 'react';
import { Button } from './ui/button';
import { Input } from './ui/input';
import { Label } from './ui/label';
import { Textarea } from './ui/textarea';
import { Badge } from './ui/badge';
import { ArrowLeft, ArrowRight, Plus, X } from 'lucide-react';
import { User } from '../App';
import { ImageWithFallback } from './figma/ImageWithFallback';

interface SignUpScreenProps {
  onSignUpComplete: (user: User) => void;
  onBackToLogin: () => void;
}

const interests = [
  'Du lịch', 'Phim ảnh', 'Âm nhạc', 'Thể thao', 'Nấu ăn', 'Đọc sách',
  'Nhiếp ảnh', 'Vẽ', 'Khiêu vũ', 'Yoga', 'Gym', 'Game',
  'Cà phê', 'Bia', 'Rượu vang', 'Thú cưng', 'Thiên nhiên', 'Công nghệ'
];

export function SignUpScreen({ onSignUpComplete, onBackToLogin }: SignUpScreenProps) {
  const [step, setStep] = useState(1);
  const [formData, setFormData] = useState({
    name: '',
    age: '',
    photos: [] as string[],
    bio: '',
    selectedInterests: [] as string[]
  });

  const handleNext = () => {
    if (step < 5) {
      setStep(step + 1);
    } else {
      // Hoàn thành đăng ký
      const user: User = {
        id: Date.now().toString(),
        name: formData.name,
        age: parseInt(formData.age),
        photos: formData.photos.length > 0 ? formData.photos : ['https://images.unsplash.com/photo-1503164585513-5c4f19209317?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHx5b3VuZyUyMGFzaWFuJTIwd29tYW4lMjBwb3J0cmFpdHxlbnwxfHx8fDE3NTcwOTcxNzh8MA&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral'],
        bio: formData.bio,
        interests: formData.selectedInterests
      };
      onSignUpComplete(user);
    }
  };

  const handleBack = () => {
    if (step > 1) {
      setStep(step - 1);
    } else {
      onBackToLogin();
    }
  };

  const addPhoto = () => {
    const photoUrls = [
      'https://images.unsplash.com/photo-1503164585513-5c4f19209317?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHx5b3VuZyUyMGFzaWFuJTIwd29tYW4lMjBwb3J0cmFpdHxlbnwxfHx8fDE3NTcwOTcxNzh8MA&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral',
      'https://images.unsplash.com/photo-1699454207790-3a95751ace90?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxhdHRyYWN0aXZlJTIwd29tYW4lMjBzZWxmaWV8ZW58MXx8fHwxNzU3MTYwOTMzfDA&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral',
      'https://images.unsplash.com/photo-1689045246827-3b2a4ac9bfb7?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxiZWF1dGlmdWwlMjBnaXJsJTIwc21pbGluZ3xlbnwxfHx8fDE3NTcxNjA5MzR8MA&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral'
    ];
    
    if (formData.photos.length < 5) {
      const newPhoto = photoUrls[formData.photos.length % photoUrls.length];
      setFormData({
        ...formData,
        photos: [...formData.photos, newPhoto]
      });
    }
  };

  const removePhoto = (index: number) => {
    setFormData({
      ...formData,
      photos: formData.photos.filter((_, i) => i !== index)
    });
  };

  const toggleInterest = (interest: string) => {
    const newInterests = formData.selectedInterests.includes(interest)
      ? formData.selectedInterests.filter(i => i !== interest)
      : [...formData.selectedInterests, interest];
    
    setFormData({
      ...formData,
      selectedInterests: newInterests
    });
  };

  const canProceed = () => {
    switch (step) {
      case 1: return formData.name.trim() !== '';
      case 2: return formData.age !== '' && parseInt(formData.age) >= 18;
      case 3: return true; // Photos are optional
      case 4: return formData.bio.trim() !== '';
      case 5: return formData.selectedInterests.length > 0;
      default: return false;
    }
  };

  return (
    <div className="min-h-screen flex flex-col">
      {/* Header */}
      <div className="flex items-center justify-between p-4 border-b">
        <Button variant="ghost" size="sm" onClick={handleBack}>
          <ArrowLeft className="h-5 w-5" />
        </Button>
        <div className="flex space-x-2">
          {[1, 2, 3, 4, 5].map((i) => (
            <div
              key={i}
              className={`w-2 h-2 rounded-full ${
                i <= step ? 'bg-pink-500' : 'bg-gray-200'
              }`}
            />
          ))}
        </div>
        <div className="w-10" />
      </div>

      {/* Content */}
      <div className="flex-1 flex flex-col justify-center px-6 py-8">
        <div className="mx-auto w-full max-w-sm">
          {/* Bước 1: Tên */}
          {step === 1 && (
            <div className="text-center">
              <h2 className="text-2xl mb-8">Bạn tên là gì?</h2>
              <div className="space-y-4">
                <Input
                  value={formData.name}
                  onChange={(e) => setFormData({ ...formData, name: e.target.value })}
                  placeholder="Nhập tên của bạn"
                  className="text-center text-lg"
                />
              </div>
            </div>
          )}

          {/* Bước 2: Tuổi */}
          {step === 2 && (
            <div className="text-center">
              <h2 className="text-2xl mb-8">Bạn bao nhiêu tuổi?</h2>
              <div className="space-y-4">
                <Input
                  type="number"
                  min="18"
                  max="100"
                  value={formData.age}
                  onChange={(e) => setFormData({ ...formData, age: e.target.value })}
                  placeholder="Nhập tuổi của bạn"
                  className="text-center text-lg"
                />
              </div>
            </div>
          )}

          {/* Bước 3: Ảnh */}
          {step === 3 && (
            <div className="text-center">
              <h2 className="text-2xl mb-8">Hãy tải lên những bức ảnh đẹp nhất của bạn.</h2>
              <div className="grid grid-cols-2 gap-4 mb-6">
                {formData.photos.map((photo, index) => (
                  <div key={index} className="relative aspect-square rounded-lg overflow-hidden bg-gray-100">
                    <ImageWithFallback
                      src={photo}
                      alt={`Photo ${index + 1}`}
                      className="w-full h-full object-cover"
                    />
                    <button
                      onClick={() => removePhoto(index)}
                      className="absolute top-2 right-2 bg-white rounded-full p-1 shadow-md"
                    >
                      <X className="h-4 w-4 text-gray-600" />
                    </button>
                  </div>
                ))}
                {formData.photos.length < 5 && (
                  <button
                    onClick={addPhoto}
                    className="aspect-square border-2 border-dashed border-gray-300 rounded-lg flex items-center justify-center hover:border-pink-500 transition-colors"
                  >
                    <Plus className="h-8 w-8 text-gray-400" />
                  </button>
                )}
              </div>
              <p className="text-sm text-gray-600">Thêm tối đa 5 ảnh</p>
            </div>
          )}

          {/* Bước 4: Mô tả */}
          {step === 4 && (
            <div className="text-center">
              <h2 className="text-2xl mb-8">Hãy giới thiệu về bản thân.</h2>
              <div className="space-y-4">
                <Textarea
                  value={formData.bio}
                  onChange={(e) => setFormData({ ...formData, bio: e.target.value })}
                  placeholder="Chia sẻ điều gì đó thú vị về bạn..."
                  className="min-h-32 resize-none"
                  maxLength={500}
                />
                <p className="text-sm text-gray-500">{formData.bio.length}/500</p>
              </div>
            </div>
          )}

          {/* Bước 5: Sở thích */}
          {step === 5 && (
            <div className="text-center">
              <h2 className="text-2xl mb-8">Sở thích của bạn là gì?</h2>
              <div className="grid grid-cols-2 gap-3 mb-6">
                {interests.map((interest) => (
                  <Badge
                    key={interest}
                    variant={formData.selectedInterests.includes(interest) ? "default" : "outline"}
                    className={`cursor-pointer p-3 justify-center ${
                      formData.selectedInterests.includes(interest)
                        ? 'bg-pink-500 hover:bg-pink-600'
                        : 'hover:bg-pink-50'
                    }`}
                    onClick={() => toggleInterest(interest)}
                  >
                    {interest}
                  </Badge>
                ))}
              </div>
              <p className="text-sm text-gray-600">Chọn ít nhất 1 sở thích</p>
            </div>
          )}
        </div>
      </div>

      {/* Footer */}
      <div className="p-6">
        <Button
          onClick={handleNext}
          disabled={!canProceed()}
          className="w-full bg-gradient-to-r from-pink-500 to-rose-500 hover:from-pink-600 hover:to-rose-600 disabled:opacity-50"
        >
          {step === 5 ? 'Hoàn thành' : 'Tiếp theo'}
          <ArrowRight className="ml-2 h-4 w-4" />
        </Button>
      </div>
    </div>
  );
}