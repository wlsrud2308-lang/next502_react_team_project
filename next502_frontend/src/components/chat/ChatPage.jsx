import { useState, useEffect, useRef } from 'react';
import { Send, Paperclip, Phone, MoreVertical } from 'lucide-react';
import axios from 'axios';
import { db, auth } from '../firebase'; // 설정 파일 import
import { signInWithCustomToken } from 'firebase/auth';
import {
  collection,
  query,
  orderBy,
  onSnapshot,
  addDoc,
  serverTimestamp,
} from 'firebase/firestore';

export default function ChatPage() {
  const [rooms, setRooms] = useState([]); // 채팅방 목록
  const [currentRoom, setCurrentRoom] = useState(null); // 선택된 방
  const [messages, setMessages] = useState([]); // 메시지 내역
  const [inputText, setInputText] = useState('');
  const [currentUser, setCurrentUser] = useState(null); // 현재 로그인 유저 정보
  const scrollRef = useRef();

  // 1. 초기 로드: 로그인 유저 정보 및 채팅방 목록 가져오기
  useEffect(() => {
    const initChat = async () => {
      try {
        // 백엔드에서 내 정보와 방 목록 가져오기
        const [userRes, roomsRes] = await Promise.all([
          axios.get('/api/member/me'), // 유저 정보 API (가정)
          axios.get('/chat/rooms'),
        ]);
        setCurrentUser(userRes.data);
        setRooms(roomsRes.data);

        // 파이어베이스 커스텀 토큰 인증
        const tokenRes = await axios.get('/chat/firebase-token');
        await signInWithCustomToken(auth, tokenRes.data.token);
      } catch (err) {
        console.error('초기화 에러:', err);
      }
    };
    initChat();
  }, []);

  // 2. 채팅방 선택 시: 메시지 구독 및 읽음 처리
  useEffect(() => {
    if (!currentRoom) return;

    // Firestore 실시간 구독
    const q = query(
      collection(db, 'chatRooms', String(currentRoom.chatRoomId), 'messages'), // 'chats' -> 'chatRooms'
      orderBy('createdAt', 'asc'),
    );

    const unsubscribe = onSnapshot(q, (snapshot) => {
      const msgs = snapshot.docs.map((doc) => ({ id: doc.id, ...doc.data() }));
      setMessages(msgs);
      scrollToBottom();
    });

    // 백엔드 읽음 처리 API 호출
    axios.patch(`/chat/room/${currentRoom.chatRoomId}/read`);

    return () => unsubscribe();
  }, [currentRoom]);

  // 3. 메시지 전송
  const handleSend = async () => {
    if (!inputText.trim() || !currentRoom) return;

    const messageData = {
      chatRoomId: currentRoom.chatRoomId,
      senderId: String(currentUser.id), // String으로 통일
      senderNick: currentUser.userNick,
      content: inputText, // 'message' -> 'content' 로 변경
      chatType: 'TEXT',
      createDate: new Date().toISOString(),
      createdAt: serverTimestamp(),
      isRead: false, // 'isReadYn' -> 'isRead' (boolean)로 변경
    };

    try {
      await addDoc(
        collection(db, 'chatRooms', String(currentRoom.chatRoomId), 'messages'),
        messageData,
      );
      setInputText('');
    } catch (err) {
      console.error('전송 실패:', err);
    }
  };

  const scrollToBottom = () => {
    if (scrollRef.current) {
      scrollRef.current.scrollTop = scrollRef.current.scrollHeight;
    }
  };

  return (
    <div className="flex h-screen bg-gray-100">
      {/* 1. 좌측 사이드바 (채팅방 목록) */}
      <div className="w-1/3 min-w-[320px] bg-white border-r border-gray-200 flex flex-col">
        <div className="p-4 border-b bg-gray-50 font-bold text-lg">채팅 목록</div>
        <div className="overflow-y-auto flex-1">
          {rooms.map((room) => (
            <div
              key={room.chatRoomId}
              onClick={() => setCurrentRoom(room)}
              className={`flex items-center p-4 hover:bg-gray-50 cursor-pointer border-b ${currentRoom?.chatRoomId === room.chatRoomId ? 'bg-purple-50' : ''}`}
            >
              <div className="w-12 h-12 bg-purple-600 rounded-full flex items-center justify-center text-white font-bold">
                {room.warehouseName.substring(0, 1)}
              </div>
              <div className="ml-4 flex-1">
                <div className="flex justify-between items-center">
                  <span className="font-semibold text-gray-800">{room.warehouseName}</span>
                  <span className="text-[10px] text-gray-500">
                    {room.updateDate?.split('T')[0]}
                  </span>
                </div>
                <div className="text-sm text-gray-500 truncate">{room.userid}님과의 대화</div>
              </div>
            </div>
          ))}
        </div>
      </div>

      {/* 2. 우측 메인 채팅창 */}
      <div className="flex-1 flex flex-col bg-[#F3F4F6]">
        {currentRoom ? (
          <>
            {/* 상단 헤더 */}
            <div className="p-4 bg-white border-b border-gray-200 flex justify-between items-center">
              <div className="flex items-center">
                <div className="w-10 h-10 bg-purple-600 rounded-full flex items-center justify-center text-white font-bold">
                  W
                </div>
                <div className="ml-3">
                  <div className="font-bold text-gray-800">{currentRoom.warehouseName}</div>
                  <div className="text-xs text-green-500">대화 중</div>
                </div>
              </div>
            </div>

            {/* 대화 내역 */}
            <div ref={scrollRef} className="flex-1 overflow-y-auto p-6 space-y-4">
              {messages.map((msg) => (
                <div
                  key={msg.id}
                  className={`flex ${String(msg.senderId) === String(currentUser?.id) ? 'justify-end' : 'justify-start'}`}
                >
                  <div
                    className={`max-w-[60%] rounded-2xl px-4 py-2 ${
                      String(msg.senderId) === String(currentUser?.id)
                        ? 'bg-purple-600 text-white rounded-br-none'
                        : 'bg-white text-gray-800 rounded-bl-none shadow-sm'
                    }`}
                  >
                    <div className="text-[10px] mb-1 opacity-70">{msg.senderNick}</div>
                    {/* 👈 msg.message를 msg.content로 변경해야 글자가 보입니다. */}
                    <div>{msg.content || msg.message}</div>
                    <div className="text-[10px] mt-1 text-right opacity-70">
                      {msg.createDate
                        ? new Date(msg.createDate).toLocaleTimeString([], {
                            hour: '2-digit',
                            minute: '2-digit',
                          })
                        : ''}
                    </div>
                  </div>
                </div>
              ))}
            </div>

            {/* 하단 입력창 */}
            <div className="p-4 bg-white border-t border-gray-200">
              <div className="flex items-center gap-4">
                <input
                  type="text"
                  className="flex-1 border border-gray-300 rounded-full px-4 py-2 focus:outline-none focus:border-purple-600"
                  placeholder="메시지를 입력하세요..."
                  value={inputText}
                  onChange={(e) => setInputText(e.target.value)}
                  onKeyPress={(e) => e.key === 'Enter' && handleSend()}
                />
                <button
                  onClick={handleSend}
                  className="bg-purple-600 text-white p-2 rounded-full hover:bg-purple-700"
                >
                  <Send size={18} />
                </button>
              </div>
            </div>
          </>
        ) : (
          <div className="flex-1 flex items-center justify-center text-gray-400">
            채팅방을 선택해주세요.
          </div>
        )}
      </div>
    </div>
  );
}
