import React, { useState, useEffect } from 'react';
import { Button } from './ui/button';
import { 
  Phone, 
  PhoneOff, 
  Mic, 
  MicOff, 
  Video, 
  VideoOff, 
  MessageCircle,
  Volume2,
  VolumeX,
  Camera,
  Users
} from 'lucide-react';
import { User as UserType, Screen } from '../App';
import { ImageWithFallback } from './figma/ImageWithFallback';

interface VideoCallScreenProps {
  onNavigate: (screen: Screen) => void;
  callUser: UserType | null;
}

export function VideoCallScreen({ onNavigate, callUser }: VideoCallScreenProps) {
  const [callDuration, setCallDuration] = useState(0);
  const [isVideoEnabled, setIsVideoEnabled] = useState(true);
  const [isAudioEnabled, setIsAudioEnabled] = useState(true);
  const [isSpeakerEnabled, setIsSpeakerEnabled] = useState(true);
  const [callStatus, setCallStatus] = useState<'connecting' | 'connected' | 'ended'>('connecting');

  useEffect(() => {
    // Simulate connection process
    const connectTimer = setTimeout(() => {
      setCallStatus('connected');
    }, 3000);

    return () => clearTimeout(connectTimer);
  }, []);

  useEffect(() => {
    let interval: NodeJS.Timeout;
    
    if (callStatus === 'connected') {
      interval = setInterval(() => {
        setCallDuration(prev => prev + 1);
      }, 1000);
    }

    return () => {
      if (interval) clearInterval(interval);
    };
  }, [callStatus]);

  const formatDuration = (seconds: number) => {
    const mins = Math.floor(seconds / 60);
    const secs = seconds % 60;
    return `${mins.toString().padStart(2, '0')}:${secs.toString().padStart(2, '0')}`;
  };

  const handleEndCall = () => {
    setCallStatus('ended');
    setTimeout(() => {
      onNavigate('chat');
    }, 2000);
  };

  if (!callUser) {
    return (
      <div className="min-h-screen bg-gray-900 flex items-center justify-center">
        <p className="text-white">Không có cuộc gọi nào</p>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gray-900 relative overflow-hidden">
      {/* Background - Partner's video */}
      <div className="absolute inset-0">
        {isVideoEnabled ? (
          <div className="w-full h-full bg-gray-800 flex items-center justify-center">
            <ImageWithFallback
              src={callUser.photos[0]}
              alt={callUser.name}
              className="w-full h-full object-cover"
            />
            {/* Video overlay effect */}
            <div className="absolute inset-0 bg-black/20" />
          </div>
        ) : (
          <div className="w-full h-full bg-gray-800 flex items-center justify-center">
            <div className="text-center">
              <div className="w-32 h-32 bg-gray-600 rounded-full flex items-center justify-center mx-auto mb-4">
                <Users className="h-16 w-16 text-gray-400" />
              </div>
              <p className="text-white text-xl">{callUser.name}</p>
              <p className="text-gray-300">Camera đã tắt</p>
            </div>
          </div>
        )}
      </div>

      {/* Top Status Bar */}
      <div className="absolute top-0 left-0 right-0 p-6 bg-gradient-to-b from-black/50 to-transparent">
        <div className="flex items-center justify-between text-white">
          <div className="flex items-center gap-3">
            <div className="w-10 h-10 bg-gray-600 rounded-full flex items-center justify-center">
              <ImageWithFallback
                src={callUser.photos[0]}
                alt={callUser.name}
                className="w-full h-full rounded-full object-cover"
              />
            </div>
            <div>
              <h2 className="text-lg">{callUser.name}</h2>
              {callStatus === 'connecting' && (
                <p className="text-sm text-gray-300">Đang kết nối...</p>
              )}
              {callStatus === 'connected' && (
                <p className="text-sm text-gray-300">{formatDuration(callDuration)}</p>
              )}
              {callStatus === 'ended' && (
                <p className="text-sm text-gray-300">Cuộc gọi đã kết thúc</p>
              )}
            </div>
          </div>
          
          {callStatus === 'connected' && (
            <div className="flex items-center gap-2">
              <div className="w-2 h-2 bg-green-500 rounded-full animate-pulse" />
              <span className="text-sm">HD</span>
            </div>
          )}
        </div>
      </div>

      {/* Self video preview */}
      <div className="absolute top-20 right-4 w-24 h-32 bg-gray-700 rounded-lg overflow-hidden border-2 border-white/20">
        {isVideoEnabled ? (
          <div className="w-full h-full bg-gray-600 flex items-center justify-center">
            <div className="text-white text-xs text-center">
              <Camera className="h-6 w-6 mx-auto mb-1" />
              Bạn
            </div>
          </div>
        ) : (
          <div className="w-full h-full bg-gray-700 flex items-center justify-center">
            <VideoOff className="h-6 w-6 text-gray-400" />
          </div>
        )}
      </div>

      {/* Bottom Controls */}
      <div className="absolute bottom-0 left-0 right-0 p-6 bg-gradient-to-t from-black/50 to-transparent">
        <div className="flex items-center justify-center gap-6">
          {/* Audio Toggle */}
          <Button
            size="lg"
            variant={isAudioEnabled ? "secondary" : "destructive"}
            className="w-14 h-14 rounded-full"
            onClick={() => setIsAudioEnabled(!isAudioEnabled)}
          >
            {isAudioEnabled ? (
              <Mic className="h-6 w-6" />
            ) : (
              <MicOff className="h-6 w-6" />
            )}
          </Button>

          {/* Video Toggle */}
          <Button
            size="lg"
            variant={isVideoEnabled ? "secondary" : "destructive"}
            className="w-14 h-14 rounded-full"
            onClick={() => setIsVideoEnabled(!isVideoEnabled)}
          >
            {isVideoEnabled ? (
              <Video className="h-6 w-6" />
            ) : (
              <VideoOff className="h-6 w-6" />
            )}
          </Button>

          {/* End Call */}
          <Button
            size="lg"
            variant="destructive"
            className="w-16 h-16 rounded-full bg-red-500 hover:bg-red-600"
            onClick={handleEndCall}
          >
            <PhoneOff className="h-7 w-7" />
          </Button>

          {/* Speaker Toggle */}
          <Button
            size="lg"
            variant={isSpeakerEnabled ? "secondary" : "outline"}
            className="w-14 h-14 rounded-full"
            onClick={() => setIsSpeakerEnabled(!isSpeakerEnabled)}
          >
            {isSpeakerEnabled ? (
              <Volume2 className="h-6 w-6" />
            ) : (
              <VolumeX className="h-6 w-6" />
            )}
          </Button>

          {/* Chat */}
          <Button
            size="lg"
            variant="outline"
            className="w-14 h-14 rounded-full"
            onClick={() => onNavigate('chat')}
          >
            <MessageCircle className="h-6 w-6" />
          </Button>
        </div>

        {/* Safety tip */}
        <div className="mt-4 text-center">
          <p className="text-xs text-white/70">
            💡 Tip: Luôn giữ cuộc gọi trong ứng dụng để đảm bảo an toàn
          </p>
        </div>
      </div>

      {/* Connection quality indicator */}
      {callStatus === 'connected' && (
        <div className="absolute top-20 left-4 bg-black/50 rounded-lg px-3 py-2">
          <div className="flex items-center gap-2 text-white text-sm">
            <div className="flex gap-1">
              <div className="w-1 h-3 bg-green-500 rounded" />
              <div className="w-1 h-3 bg-green-500 rounded" />
              <div className="w-1 h-3 bg-green-500 rounded" />
              <div className="w-1 h-3 bg-gray-400 rounded" />
            </div>
            <span className="text-xs">Tốt</span>
          </div>
        </div>
      )}

      {/* Call ended overlay */}
      {callStatus === 'ended' && (
        <div className="absolute inset-0 bg-black/80 flex items-center justify-center">
          <div className="text-center text-white">
            <div className="w-20 h-20 bg-red-500 rounded-full flex items-center justify-center mx-auto mb-4">
              <PhoneOff className="h-10 w-10" />
            </div>
            <h3 className="text-xl mb-2">Cuộc gọi đã kết thúc</h3>
            <p className="text-gray-300 mb-4">Thời gian: {formatDuration(callDuration)}</p>
            <p className="text-sm text-gray-400">Đang trở về tin nhắn...</p>
          </div>
        </div>
      )}
    </div>
  );
}