import { useState, useEffect, useRef } from 'react';
import { Send, Paperclip, Phone, MoreVertical, LogOut } from 'lucide-react'; // 🌟 LogOut 아이콘 추가
import axios from 'axios';
import { db, auth } from '../../api/firebaseConfig';
import { signInWithCustomToken, signOut } from 'firebase/auth'; // 🌟 signOut 추가
import {
  collection,
  query,
  orderBy,
  onSnapshot,
  addDoc,
  serverTimestamp,
  doc,
  updateDoc,
} from 'firebase/firestore';

export default function ChatPage() {
  // ✅ 환경에 따른 API 주소 동적 설정
  const API_BASE_URL =
    window.location.hostname === 'localhost' ? 'http://localhost:8080' : 'http://10.0.2.2:8080';

  const [rooms, setRooms] = useState([]); // 채팅방 목록
  const [currentRoom, setCurrentRoom] = useState(null); // 선택된 방
  const [messages, setMessages] = useState([]); // 메시지 내역
  const [inputText, setInputText] = useState('');
  const [currentUser, setCurrentUser] = useState(null); // 현재 로그인 유저 정보
  const scrollRef = useRef();
  const fileInputRef = useRef();

  // 🖼️ 이미지 URL 처리 함수 (상대 경로 대응)
  const getImageUrl = (url) => {
    if (!url) return '';
    return url.startsWith('http') ? url : `${API_BASE_URL}${url}`;
  };

  // 1. 초기 로드: 로그인 유저 정보 및 채팅방 목록 가져오기
  useEffect(() => {
    const initChat = async () => {
      try {
        const token = localStorage.getItem('ACCESS_TOKEN');
        const config = { headers: { Authorization: `Bearer ${token}` } };

        // 백엔드에서 내 정보와 방 목록 가져오기
        const [userRes, roomsRes] = await Promise.all([
          axios.get(`${API_BASE_URL}/api/member/me`, config),
          axios.get(`${API_BASE_URL}/chat/rooms`, config),
        ]);

        setCurrentUser(userRes.data);
        setRooms(roomsRes.data);

        // 파이어베이스 커스텀 토큰 인증
        const tokenRes = await axios.get(`${API_BASE_URL}/chat/firebase-token`, config);
        await signInWithCustomToken(auth, tokenRes.data.token);
      } catch (err) {
        console.error('초기화 에러:', err);
      }
    };
    initChat();
  }, [API_BASE_URL]);

  // 2. 채팅방 선택 시: 메시지 구독 및 읽음 처리
  useEffect(() => {
    // 🌟 [중요]: 실시간 감지를 위해 의존성 배열에 currentUser가 필요하므로 가드 추가
    if (!currentRoom || !currentUser) return;

    const token = localStorage.getItem('ACCESS_TOKEN');
    const config = { headers: { Authorization: `Bearer ${token}` } };

    // Firestore 실시간 구독
    const q = query(
      collection(db, 'chatRooms', String(currentRoom.chatRoomId), 'messages'),
      orderBy('createdAt', 'asc'),
    );

    const unsubscribe = onSnapshot(q, (snapshot) => {
      const msgs = snapshot.docs.map((documentDoc) => {
        const data = documentDoc.data();
        const msgId = documentDoc.id;

        // 🌟 [실시간 읽음 트리거]: 내가 방을 열어놓고 대기 중일 때 상대방(앱)이 보낸 새 메시지가 포착되면 즉시 읽음 처리
        // 1. 내가 보낸 게 아니고 (senderId != 내 ID)
        // 2. 파이어베이스 상태가 안 읽음(isRead가 false이거나 isReadYn이 'N')인 경우
        if (
          String(data.senderId) !== String(currentUser.id) &&
          (data.isRead === false || data.isReadYn === 'N')
        ) {
          // A. Firestore의 해당 메시지 문서를 즉시 읽음 상태로 실시간 업데이트 (앱 화면의 숫자 1 즉시 지우기)
          const docRef = doc(db, 'chatRooms', String(currentRoom.chatRoomId), 'messages', msgId);
          updateDoc(docRef, {
            isRead: true,
            isReadYn: 'Y',
          }).catch((err) => console.error('Firestore 실시간 읽음 처리 실패:', err));

          // B. 백엔드 MySQL 데이터베이스 데이터도 실시간 동기화 벌크 작동
          axios
            .patch(`${API_BASE_URL}/chat/room/${currentRoom.chatRoomId}/read`, {}, config)
            .catch(() => {});
        }

        return {
          id: msgId,
          ...data,
          message: data.message || data.content || '', // 웹-앱 데이터 키 호환 안전망
        };
      });

      setMessages(msgs);

      // 메시지 수신 후 하단 스크롤
      setTimeout(() => {
        if (scrollRef.current) {
          scrollRef.current.scrollTop = scrollRef.current.scrollHeight;
        }
      }, 100);
    });

    return () => unsubscribe();
  }, [currentRoom, currentUser, API_BASE_URL]);

  // 3. 텍스트 메시지 전송
  const handleSend = async () => {
    if (!inputText.trim() || !currentRoom || !currentUser) return;

    const messageData = {
      chatRoomId: currentRoom.chatRoomId,
      senderId: String(currentUser.id),
      senderNick: currentUser.userNick || currentUser.userId,
      content: inputText,
      chatType: 'TEXT',
      createDate: new Date().toISOString(),
      isRead: false,
    };

    try {
      await addDoc(collection(db, 'chatRooms', String(currentRoom.chatRoomId), 'messages'), {
        ...messageData,
        createdAt: serverTimestamp(),
      });
      setInputText('');
    } catch (err) {
      console.error('전송 실패:', err);
    }
  };

  // 4. 이미지 업로드 및 전송
  const handleImageUpload = async (e) => {
    const file = e.target.files[0];
    if (!file || !currentRoom) return;

    const token = localStorage.getItem('ACCESS_TOKEN');
    const formData = new FormData();
    formData.append('file', file);

    try {
      const res = await axios.post(`${API_BASE_URL}/chat/upload`, formData, {
        headers: {
          'Content-Type': 'multipart/form-data',
          Authorization: `Bearer ${token}`,
        },
      });

      if (res.data.url) {
        const messageData = {
          chatRoomId: currentRoom.chatRoomId,
          senderId: String(currentUser.id),
          senderNick: currentUser.userNick || currentUser.userId,
          content: '[사진]',
          chatType: 'IMAGE',
          fileUrl: res.data.url, // 백엔드에서 준 상대 경로 저장
          createDate: new Date().toISOString(),
          isRead: false,
        };
        await addDoc(collection(db, 'chatRooms', String(currentRoom.chatRoomId), 'messages'), {
          ...messageData,
          createdAt: serverTimestamp(),
        });
      }
    } catch (err) {
      alert('이미지 업로드 실패');
    }
  };

  // 🌟 5. 신규 추가: 안전한 세션 로그아웃 및 웹 채팅 패널 즉시 파괴 함수
  const handleLogout = async () => {
    const isConfirm = window.confirm('로그아웃 하시겠습니까?');
    if (!isConfirm) return;

    try {
      await signOut(auth); // 파이어베이스 토큰 파괴

      // 브라우저 내 세션 파편 제거
      localStorage.removeItem('ACCESS_TOKEN');
      localStorage.removeItem('USER_INFO');

      // [핵심 조치]: 모든 렌더링 요소를 완전히 비워 우측 채팅 패널을 즉시 대기 상태로 강제 전환
      setCurrentRoom(null);
      setMessages([]);
      setRooms([]);
      setCurrentUser(null);

      alert('안전하게 로그아웃되었습니다.');
      window.location.href = '/login'; // 로그인 페이지로 리다이렉션
    } catch (err) {
      console.error('로그아웃 처리 중 오류:', err);
    }
  };

  return (
    <div className="flex h-screen bg-gray-100">
      {/* 1. 좌측 사이드바 (채팅방 목록) */}
      <div className="w-1/3 min-w-[320px] bg-white border-r border-gray-200 flex flex-col shadow-sm">
        {/* 🌟 헤더 우측 영역에 로그아웃 트리거 단추 연결 확장 */}
        <div className="p-5 border-b bg-white font-bold text-xl text-purple-700 flex justify-between items-center">
          <span>채팅 목록</span>
          <button
            onClick={handleLogout}
            className="flex items-center gap-1 text-xs text-red-500 font-medium bg-red-50 hover:bg-red-100 px-2.5 py-1.5 rounded-lg transition-colors border border-red-200 cursor-pointer"
          >
            <LogOut size={13} />
            로그아웃
          </button>
        </div>
        <div className="overflow-y-auto flex-1">
          {rooms.map((room) => (
            <div
              key={room.chatRoomId}
              onClick={() => setCurrentRoom(room)}
              className={`flex items-center p-4 hover:bg-gray-50 cursor-pointer border-b transition-colors ${
                currentRoom?.chatRoomId === room.chatRoomId ? 'bg-purple-50' : ''
              }`}
            >
              <div className="w-12 h-12 bg-purple-600 rounded-full flex items-center justify-center text-white font-bold shrink-0 shadow-sm">
                {room.warehouseName?.substring(0, 1) || 'W'}
              </div>
              <div className="ml-4 flex-1 min-w-0">
                <div className="flex justify-between items-center">
                  <span className="font-semibold text-gray-800 truncate">{room.warehouseName}</span>
                  <span className="text-[10px] text-gray-400 shrink-0">
                    {room.updateDate?.split('T')[0]}
                  </span>
                </div>
                <div className="text-sm text-gray-500 truncate">{room.userid}님과의 대화</div>
              </div>
            </div>
          ))}
          {rooms.length === 0 && (
            <div className="p-10 text-center text-gray-400">참여 중인 채팅방이 없습니다.</div>
          )}
        </div>
      </div>

      {/* 2. 우측 메인 채팅창 */}
      <div className="flex-1 flex flex-col bg-[#F3F4F6]">
        {currentRoom ? (
          <>
            {/* 상단 헤더 */}
            <div className="p-4 bg-white border-b border-gray-200 flex justify-between items-center shadow-sm">
              <div className="flex items-center">
                <div className="w-10 h-10 bg-purple-100 text-purple-600 rounded-full flex items-center justify-center font-bold">
                  {currentRoom.warehouseName?.substring(0, 1)}
                </div>
                <div className="ml-3">
                  <div className="font-bold text-gray-800">{currentRoom.warehouseName}</div>
                  <div className="text-xs text-green-500">온라인</div>
                </div>
              </div>
              <div className="flex gap-3 text-gray-400">
                <Phone size={20} className="cursor-pointer hover:text-purple-600" />
                <MoreVertical size={20} className="cursor-pointer hover:text-purple-600" />
              </div>
            </div>

            {/* 대화 내역 */}
            <div ref={scrollRef} className="flex-1 overflow-y-auto p-6 space-y-6">
              {messages.map((msg) => {
                const isMine = String(msg.senderId) === String(currentUser?.id);
                return (
                  <div key={msg.id} className={`flex ${isMine ? 'justify-end' : 'justify-start'}`}>
                    <div
                      className={`max-w-[70%] ${isMine ? 'items-end' : 'items-start'} flex flex-col`}
                    >
                      {!isMine && (
                        <div className="text-xs ml-1 mb-1 text-gray-500 font-medium">
                          {msg.senderNick}
                        </div>
                      )}

                      <div
                        className={`px-4 py-2 rounded-2xl shadow-sm ${
                          isMine ? 'rounded-tr-none' : 'bg-white text-gray-800 rounded-tl-none'
                        }`}
                        style={{
                          backgroundColor: isMine ? '#6f42c1' : '#ffffff', // 내 메시지는 보라색, 상대는 흰색
                          color: isMine ? '#ffffff' : '#1f2937', // 내 메시지는 흰글자, 상대는 어두운 회색
                        }}
                      >
                        {msg.chatType === 'IMAGE' ? (
                          <img
                            src={getImageUrl(msg.fileUrl)}
                            alt="전송 이미지"
                            className="rounded-lg max-w-full cursor-pointer hover:opacity-90"
                            style={{ maxHeight: '300px' }}
                            onClick={() => window.open(getImageUrl(msg.fileUrl))}
                          />
                        ) : (
                          <div className="text-sm leading-relaxed" style={{ color: 'inherit' }}>
                            {msg.content || msg.message}
                          </div>
                        )}
                      </div>

                      <div
                        className={`text-[9px] mt-1 text-gray-400 flex items-center gap-1 ${isMine ? 'flex-row-reverse' : ''}`}
                      >
                        {isMine &&
                          (msg.isRead === false ||
                            msg.isReadYn === 'N' ||
                            (msg.isRead === undefined && msg.isReadYn !== 'Y')) && (
                            <span className="text-warning font-bold" style={{ marginRight: '4px' }}>
                              1
                            </span>
                          )}
                        <span>
                          {msg.createDate
                            ? new Date(msg.createDate).toLocaleTimeString([], {
                                hour: '2-digit',
                                minute: '2-digit',
                              })
                            : ''}
                        </span>
                      </div>
                    </div>
                  </div>
                );
              })}
            </div>

            {/* 하단 입력창 */}
            <div className="p-4 bg-white border-t border-gray-200">
              <div className="flex items-center gap-3 bg-gray-50 px-4 py-2 rounded-full border border-gray-200">
                <button
                  onClick={() => fileInputRef.current.click()}
                  className="text-gray-400 hover:text-purple-600 transition-colors"
                >
                  <Paperclip size={20} />
                </button>
                <input
                  type="file"
                  ref={fileInputRef}
                  className="hidden" // 부트스트랩 d-none 규격을 크로스 호환용 피드백 처리
                  style={{ display: 'none' }}
                  accept="image/*"
                  onChange={handleImageUpload}
                />
                <input
                  type="text"
                  className="flex-1 bg-transparent border-none focus:outline-none text-sm py-1"
                  placeholder="메시지를 입력하세요..."
                  value={inputText}
                  onChange={(e) => setInputText(e.target.value)}
                  onKeyDown={(e) => e.key === 'Enter' && handleSend()}
                />
                <button
                  onClick={handleSend}
                  disabled={!inputText.trim()}
                  className={`${inputText.trim() ? 'text-purple-600' : 'text-gray-300'} transition-colors`}
                >
                  <Send size={20} />
                </button>
              </div>
            </div>
          </>
        ) : (
          <div className="flex-1 flex flex-col items-center justify-center text-gray-400">
            <div className="w-20 h-20 bg-gray-200 rounded-full flex items-center justify-center mb-4">
              <Send size={32} className="text-gray-300" />
            </div>
            <p className="text-lg font-medium">채팅방을 선택하여 대화를 시작해보세요.</p>
          </div>
        )}
      </div>
    </div>
  );
}

