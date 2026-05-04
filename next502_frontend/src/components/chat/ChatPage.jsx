import { useState, useEffect } from 'react';
import { Send, Paperclip, Phone, MoreVertical } from 'lucide-react'; // 아이콘

export default function ChatPage() {
  const [messages, setMessages] = useState([
    { id: 1, text: '안녕하세요! 창고 문의드립니다.', isMe: false, time: '14:20' },
    { id: 2, text: '네, 안녕하세요. 어떤 창고가 필요하신가요?', isMe: true, time: '14:21' },
    { id: 3, text: '보내주신 사진 봤는데 맘에 드네요.', isMe: false, time: '14:22' },
  ]);
  const [inputText, setInputText] = useState('');

  const handleSend = () => {
    if (!inputText.trim()) return;
    setMessages([...messages, { id: Date.now(), text: inputText, isMe: true, time: '14:25' }]);
    setInputText('');
  };

  return (
    <div className="flex h-screen bg-gray-100">
      {/* 1. 좌측 사이드바 (채팅방 목록) */}
      <div className="w-1/3 min-w-[320px] bg-white border-r border-gray-200 flex flex-col">
        <div className="p-4 border-bottom bg-gray-50 font-bold text-lg">채팅 목록</div>
        <div className="overflow-y-auto flex-1">
          {/* 채팅방 리스트 아이템 (반복문으로 렌더링 가능) */}
          <div className="flex items-center p-4 hover:bg-gray-50 cursor-pointer border-b border-gray-100">
            <div className="w-12 h-12 bg-purple-600 rounded-full flex items-center justify-center text-white font-bold">
              W
            </div>
            <div className="ml-4 flex-1">
              <div className="flex justify-between items-center">
                <span className="font-semibold text-gray-800">부산 1호 창고</span>
                <span className="text-xs text-gray-500">14:22</span>
              </div>
              <div className="text-sm text-gray-500 truncate">
                보내주신 사진 봤는데 맘에 드네요.
              </div>
            </div>
          </div>
        </div>
      </div>

      {/* 2. 우측 메인 채팅창 */}
      <div className="flex-1 flex flex-col bg-[#F3F4F6]">
        {/* 상단 헤더 */}
        <div className="p-4 bg-white border-b border-gray-200 flex justify-between items-center">
          <div className="flex items-center">
            <div className="w-10 h-10 bg-purple-600 rounded-full flex items-center justify-center text-white font-bold">
              W
            </div>
            <div className="ml-3">
              <div className="font-bold text-gray-800">부산 1호 창고</div>
              <div className="text-xs text-green-500">대화 가능</div>
            </div>
          </div>
          <div className="flex gap-4 text-gray-600">
            {/* 보이스톡 버튼과 더보기 버튼 */}
            <button className="hover:text-purple-600">
              <Phone size={20} />
            </button>
            <button className="hover:text-purple-600">
              <MoreVertical size={20} />
            </button>
          </div>
        </div>

        {/* 대화 내역 영역 */}
        <div className="flex-1 overflow-y-auto p-6 space-y-4">
          {messages.map((msg) => (
            <div key={msg.id} className={`flex ${msg.isMe ? 'justify-end' : 'justify-start'}`}>
              <div
                className={`max-w-[60%] rounded-2xl px-4 py-2 ${
                  msg.isMe
                    ? 'bg-purple-600 text-white rounded-br-none'
                    : 'bg-white text-gray-800 rounded-bl-none shadow-sm'
                }`}
              >
                <div>{msg.text}</div>
                <div
                  className={`text-xs mt-1 ${msg.isMe ? 'text-purple-200' : 'text-gray-400'} text-right`}
                >
                  {msg.time}
                </div>
              </div>
            </div>
          ))}
        </div>

        {/* 하단 입력창 */}
        <div className="p-4 bg-white border-t border-gray-200">
          <div className="flex items-center gap-4">
            <button className="text-gray-500 hover:text-purple-600">
              <Paperclip size={22} />
            </button>
            <input
              type="text"
              className="flex-1 border border-gray-300 rounded-full px-4 py-2 focus:outline-none focus:border-purple-600"
              placeholder="메시지를 입력하세요..."
              value={inputText}
              onChange={(e) => setInputText(e.target.value)}
              onKeyPress={(e) => e.key === 'Enter' && handleSend()}
            />
            <button
              className="bg-purple-600 text-white p-2 rounded-full hover:bg-purple-700 transition-colors"
              onClick={handleSend}
            >
              <Send size={18} />
            </button>
          </div>
        </div>
      </div>
    </div>
  );
}
