import React, { useState, useEffect, useRef } from 'react';
import { Form, Button } from 'react-bootstrap';
import { Send, MessageSquare, ChevronLeft, Paperclip } from 'lucide-react';
import axios from 'axios';
import { db } from '../../api/firebaseConfig';
import {
  collection,
  query,
  orderBy,
  onSnapshot,
  addDoc,
  serverTimestamp,
} from 'firebase/firestore';
import { useAuth } from '../../context/AuthContext';

// ✅ 백엔드 주소 고정 (404 방지)
const API_BASE_URL = 'http://localhost:8080';

export default function FloatingChatBar({ isOpen, setIsOpen, warehouseName, initialRoom }) {
  const [selectedRoom, setSelectedRoom] = useState(null);
  const [message, setMessage] = useState('');
  const [chatRooms, setChatRooms] = useState([]);
  const [messages, setMessages] = useState([]);

  // ✅ 유저 정보 유실 방지 로직
  const { userData: authUserData } = useAuth();
  const [userData, setUserData] = useState(null);

  const scrollRef = useRef();
  const fileInputRef = useRef();

  // 1. [유저 정보 복구] Context가 비었을 때 로컬스토리지에서 가져옴
  useEffect(() => {
    if (authUserData) {
      setUserData(authUserData);
    } else {
      const savedUser = localStorage.getItem('USER_INFO'); // 본인의 프로젝트 키 이름 확인 필요
      if (savedUser) setUserData(JSON.parse(savedUser));
    }
  }, [authUserData]);

  // 2. [상세페이지 연동] 넘겨받은 방이 있으면 즉시 대화창 열기
  useEffect(() => {
    if (initialRoom) {
      setSelectedRoom(initialRoom);
    }
  }, [initialRoom]);

  // 3. [MySQL] 채팅방 목록 가져오기
  useEffect(() => {
    if (isOpen) {
      const token = localStorage.getItem('ACCESS_TOKEN');
      axios
        .get(`${API_BASE_URL}/chat/rooms`, {
          headers: { Authorization: `Bearer ${token}` },
        })
        .then((res) => setChatRooms(Array.isArray(res.data) ? res.data : []))
        .catch((err) => console.error('목록 로드 실패:', err));
    }
  }, [isOpen]);

  // 4. [Firestore] 실시간 메시지 구독 및 읽음 처리
  useEffect(() => {
    if (!selectedRoom) return;

    const token = localStorage.getItem('ACCESS_TOKEN');
    // 읽음 처리 알림 (백엔드)
    axios
      .patch(
        `${API_BASE_URL}/chat/room/${selectedRoom.chatRoomId}/read`,
        {},
        {
          headers: { Authorization: `Bearer ${token}` },
        },
      )
      .catch(() => {});

    // 👈 앱과 동일한 'chatRooms' 컬렉션 사용
    const q = query(
      collection(db, 'chatRooms', String(selectedRoom.chatRoomId), 'messages'),
      orderBy('createdAt', 'asc'),
    );

    const unsubscribe = onSnapshot(
      q,
      (snapshot) => {
        const msgs = snapshot.docs.map((doc) => ({
          id: doc.id,
          ...doc.data(),
        }));
        setMessages(msgs);

        setTimeout(() => {
          if (scrollRef.current) scrollRef.current.scrollTop = scrollRef.current.scrollHeight;
        }, 100);
      },
      (err) => {
        console.error('Firestore 구독 에러 (인덱스 생성 링크 확인):', err);
      },
    );

    return () => unsubscribe();
  }, [selectedRoom]);

  // 5. 메시지 전송 로직 (앱 규격 일치)
  const saveMessage = async (type, content, fileUrl = null) => {
    if (!userData || !userData.id) {
      alert('유저 정보를 불러올 수 없습니다. 다시 로그인해 주세요.');
      return;
    }
    if (!selectedRoom) return;

    const messageData = {
      chatRoomId: selectedRoom.chatRoomId,
      senderId: String(userData.id), // String으로 통일
      senderNick: userData.userNick || userData.userId,
      content: content, // message -> content (App 일치)
      chatType: type, // TEXT or IMAGE
      fileUrl: fileUrl,
      createDate: new Date().toISOString(),
      isRead: false, // isReadYn -> isRead (boolean)
    };

    try {
      await addDoc(collection(db, 'chatRooms', String(selectedRoom.chatRoomId), 'messages'), {
        ...messageData,
        createdAt: serverTimestamp(),
      });
    } catch (err) {
      console.error('메시지 전송 실패:', err);
    }
  };

  const handleSend = () => {
    if (!message.trim()) return;
    saveMessage('TEXT', message);
    setMessage('');
  };

  const handleImageUpload = async (e) => {
    const file = e.target.files[0];
    if (!file) return;

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
      if (res.data.url) saveMessage('IMAGE', '[사진]', res.data.url);
    } catch (err) {
      alert('이미지 업로드 실패');
    }
  };

  return (
    <>
      {/* ─── 채팅창 본체 ─── */}
      <div
        className={`bg-white rounded-4 shadow-lg border flex-column ${isOpen ? 'd-flex' : 'd-none'}`}
        style={{
          position: 'fixed',
          bottom: '80px',
          right: '20px',
          width: '330px',
          height: '480px',
          zIndex: 1050,
        }}
      >
        {/* 헤더 */}
        <div className="p-3 border-bottom d-flex justify-content-between align-items-center bg-light rounded-top-4">
          <div className="d-flex align-items-center gap-2">
            {selectedRoom && (
              <ChevronLeft
                size={20}
                className="cursor-pointer"
                onClick={() => setSelectedRoom(null)}
              />
            )}
            <span
              className="fw-bold text-dark text-truncate"
              style={{ maxWidth: '180px', fontSize: '14px' }}
            >
              {selectedRoom ? selectedRoom.warehouseName : '메시지 목록'}
            </span>
          </div>
          <Button
            variant="link"
            className="text-secondary p-0 text-decoration-none"
            onClick={() => setIsOpen(false)}
          >
            ✕
          </Button>
        </div>

        {/* 본문 */}
        <div
          ref={scrollRef}
          className="flex-grow-1 overflow-auto bg-white p-3 d-flex flex-column gap-3"
          style={{ fontSize: '13px' }}
        >
          {!selectedRoom
            ? chatRooms.map((room) => (
                <div
                  key={room.chatRoomId}
                  className="p-2 border-bottom hover-bg-light cursor-pointer"
                  onClick={() => setSelectedRoom(room)}
                >
                  <div className="fw-bold">{room.warehouseName}</div>
                  <div className="text-muted small">상대: {room.userid || '관리자'}</div>
                </div>
              ))
            : messages.map((msg) => (
                <div
                  key={msg.id}
                  className={`d-flex flex-column ${String(msg.senderId) === String(userData?.id) ? 'align-items-end' : 'align-items-start'}`}
                >
                  {msg.chatType === 'IMAGE' ? (
                    <img
                      src={msg.fileUrl}
                      alt="chat"
                      className="rounded-3 shadow-sm mb-1"
                      style={{ maxWidth: '75%', cursor: 'pointer' }}
                      onClick={() => window.open(msg.fileUrl)}
                    />
                  ) : (
                    <div
                      className={`p-2 rounded-3 ${String(msg.senderId) === String(userData?.id) ? 'bg-purple-600 text-white' : 'bg-light text-dark'}`}
                    >
                      {msg.content}
                    </div>
                  )}
                  <div className="text-muted mt-1" style={{ fontSize: '9px' }}>
                    {!msg.isRead && String(msg.senderId) === String(userData?.id) && (
                      <span className="text-warning fw-bold me-1">1</span>
                    )}
                    {msg.createDate &&
                      new Date(msg.createDate).toLocaleTimeString([], {
                        hour: '2-digit',
                        minute: '2-digit',
                      })}
                  </div>
                </div>
              ))}
        </div>

        {/* 하단 입력창 */}
        {selectedRoom && (
          <div className="p-3 border-top">
            <div className="d-flex align-items-center gap-2">
              <input
                type="file"
                ref={fileInputRef}
                className="d-none"
                onChange={handleImageUpload}
                accept="image/*"
              />
              <Paperclip
                size={20}
                className="text-secondary cursor-pointer"
                onClick={() => fileInputRef.current.click()}
              />
              <Form.Control
                type="text"
                placeholder="메시지 입력..."
                className="rounded-pill bg-light border-0 shadow-none"
                style={{ fontSize: '13px' }}
                value={message}
                onChange={(e) => setMessage(e.target.value)}
                onKeyPress={(e) => e.key === 'Enter' && handleSend()}
              />
              <Send size={20} className="text-primary cursor-pointer" onClick={handleSend} />
            </div>
          </div>
        )}
      </div>

      {/* 플로팅 버튼 */}
      <div
        className="bg-white border shadow-sm rounded-pill py-2 px-3 d-flex align-items-center gap-2"
        style={{
          position: 'fixed',
          bottom: '20px',
          right: '20px',
          zIndex: 1040,
          cursor: 'pointer',
        }}
        onClick={() => setIsOpen(!isOpen)}
      >
        <MessageSquare size={18} className="text-purple-600" />
        <span className="fw-bold small">채팅 상담</span>
      </div>
    </>
  );
}


