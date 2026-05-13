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
  doc,
  updateDoc,
} from 'firebase/firestore';
import { useAuth } from '../../context/AuthContext';

// ✅ 환경에 따른 API 주소 동적 설정
const API_BASE_URL =
  window.location.hostname === 'localhost' ? 'http://localhost:8080' : 'http://10.0.2.2:8080';

export default function FloatingChatBar({ isOpen, setIsOpen, initialRoom }) {
  const [selectedRoom, setSelectedRoom] = useState(null);
  const [message, setMessage] = useState('');
  const [chatRooms, setChatRooms] = useState([]);
  const [messages, setMessages] = useState([]);

  // ✅ 유저 정보 유실 방지 로직
  const { userData: authUserData } = useAuth();
  const [userData, setUserData] = useState(null);

  const scrollRef = useRef();
  const fileInputRef = useRef();

  // 🖼️ 이미지 URL 처리 함수 (상상 경로 대응)
  const getImageUrl = (url) => {
    if (!url) return '';
    return url.startsWith('http') ? url : `${API_BASE_URL}${url}`;
  };

  // 1. [유저 정보 복구] Context가 비었을 때 로컬스토리지에서 가져옴
  useEffect(() => {
    if (authUserData) {
      setUserData(authUserData);
    } else {
      const savedUser = localStorage.getItem('USER_INFO');
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
      const config = { headers: { Authorization: `Bearer ${token}` } };

      axios
        .get(`${API_BASE_URL}/chat/rooms`, config)
        .then((res) => setChatRooms(Array.isArray(res.data) ? res.data : []))
        .catch((err) => console.error('목록 로드 실패:', err));
    }
  }, [isOpen]);

  // 4. [Firestore] 실시간 메시지 구독 및 읽음 처리
  useEffect(() => {
    // 🌟 실시간 읽음 처리를 위해 userData 조건 가드 추가
    if (!selectedRoom || !userData) return;

    const token = localStorage.getItem('ACCESS_TOKEN');
    const config = { headers: { Authorization: `Bearer ${token}` } };

    // Firestore 메시지 실시간 구독
    const q = query(
      collection(db, 'chatRooms', String(selectedRoom.chatRoomId), 'messages'),
      orderBy('createdAt', 'asc'),
    );

    const unsubscribe = onSnapshot(
      q,
      (snapshot) => {
        const msgs = snapshot.docs.map((documentDoc) => {
          const data = documentDoc.data();
          const msgId = documentDoc.id;

          // 🌟 [실시간 읽음 트리거]: 플로팅 대화창을 열고 대기 중일 때 앱 유저가 새 메시지를 보내면 즉시 읽음 마킹
          // 1. 내가 보낸 게 아니고 (senderId != 내 ID)
          // 2. 파이어베이스 상태가 안 읽음(isRead가 false이거나 isReadYn이 'N')인 경우
          if (
            String(data.senderId) !== String(userData.id) &&
            (data.isRead === false || data.isReadYn === 'N')
          ) {
            // A. Firestore 문서를 실시간 읽음 완료 상태로 즉시 업데이트 (앱 화면의 숫자 1 실시간 삭제 유도)
            const docRef = doc(db, 'chatRooms', String(selectedRoom.chatRoomId), 'messages', msgId);
            updateDoc(docRef, {
              isRead: true,
              isReadYn: 'Y',
            }).catch((err) => console.error('Firestore 실시간 읽음 처리 실패:', err));

            // B. 백엔드 MySQL 데이터베이스 읽음 상태도 실시간 동기화 호출
            axios
              .patch(`${API_BASE_URL}/chat/room/${selectedRoom.chatRoomId}/read`, {}, config)
              .catch(() => {});
          }

          return {
            id: msgId,
            ...data,
            message: data.message || data.content || '', // 웹-앱 데이터 키 호환성 안전망
          };
        });

        setMessages(msgs);

        // 메시지 수신 시 스크롤 하단 이동
        setTimeout(() => {
          if (scrollRef.current) scrollRef.current.scrollTop = scrollRef.current.scrollHeight;
        }, 100);
      },
      (err) => {
        console.error('Firestore 구독 에러:', err);
      },
    );

    return () => unsubscribe();
  }, [selectedRoom, userData]);

  // 5. 메시지 전송 로직
  const saveMessage = async (type, content, fileUrl = null) => {
    if (!userData || !userData.id) {
      alert('유저 정보를 불러올 수 없습니다. 다시 로그인해 주세요.');
      return;
    }
    if (!selectedRoom) return;

    const messageData = {
      chatRoomId: selectedRoom.chatRoomId,
      senderId: String(userData.id),
      senderNick: userData.userNick || userData.userId,
      content: content,
      chatType: type,
      fileUrl: fileUrl,
      createDate: new Date().toISOString(),
      isRead: false,
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
      // 백엔드에서 받은 상대 경로 저장
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
          width: '340px',
          height: '500px',
          zIndex: 1050,
          overflow: 'hidden',
        }}
      >
        {/* 헤더 */}
        <div className="p-3 border-bottom d-flex justify-content-between align-items-center bg-light">
          <div className="d-flex align-items-center gap-2">
            {selectedRoom && (
              <ChevronLeft
                size={20}
                className="cursor-pointer text-secondary"
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

        {/* 본문 (메시지 영역) */}
        <div
          ref={scrollRef}
          className="flex-grow-1 overflow-auto bg-white p-3 d-flex flex-column gap-3"
          style={{ fontSize: '13px' }}
        >
          {!selectedRoom
            ? chatRooms.map((room) => (
                <div
                  key={room.chatRoomId}
                  className="p-3 border-bottom hover-bg-light cursor-pointer rounded-3 transition-all"
                  onClick={() => setSelectedRoom(room)}
                >
                  <div className="fw-bold text-dark">{room.warehouseName}</div>
                  <div className="text-muted small">상대: {room.userid || '관리자'}</div>
                </div>
              ))
            : messages.map((msg) => {
                const isMine = String(msg.senderId) === String(userData?.id);
                return (
                  <div
                    key={msg.id}
                    className={`d-flex flex-column ${isMine ? 'align-items-end' : 'align-items-start'}`}
                  >
                    {msg.chatType === 'IMAGE' ? (
                      <img
                        src={getImageUrl(msg.fileUrl)}
                        alt="chat"
                        className="rounded-3 shadow-sm mb-1"
                        style={{ maxWidth: '75%', cursor: 'pointer' }}
                        onClick={() => window.open(getImageUrl(msg.fileUrl))}
                      />
                    ) : (
                      <div
                        className={`p-2 px-3 rounded-3 shadow-sm ${isMine ? 'rounded-tr-none' : 'rounded-tl-none'}`}
                        style={{
                          backgroundColor: isMine ? '#6f42c1' : '#f1f3f5',
                          color: isMine ? '#ffffff' : '#212529',
                          maxWidth: '85%',
                          wordBreak: 'break-word',
                        }}
                      >
                        {msg.content}
                      </div>
                    )}
                    <div className="text-muted mt-1" style={{ fontSize: '9px' }}>
                      {isMine &&
                        (msg.isRead === false ||
                          msg.isReadYn === 'N' ||
                          (msg.isRead === undefined && msg.isReadYn !== 'Y')) && (
                          <span className="text-warning fw-bold me-1">1</span>
                        )}
                      {msg.createDate &&
                        new Date(msg.createDate).toLocaleTimeString([], {
                          hour: '2-digit',
                          minute: '2-digit',
                        })}
                    </div>
                  </div>
                );
              })}
        </div>

        {/* 하단 입력창 */}
        {selectedRoom && (
          <div className="p-3 border-top bg-white">
            <div className="d-flex align-items-center gap-2">
              <input
                type="file"
                ref={fileInputRef}
                className="d-none"
                accept="image/*"
                onChange={handleImageUpload}
              />
              <Paperclip
                size={20}
                className="text-secondary cursor-pointer hover-opacity"
                onClick={() => fileInputRef.current.click()}
              />
              <Form.Control
                type="text"
                placeholder="메시지 입력..."
                className="rounded-pill bg-light border-0 shadow-none py-2"
                style={{ fontSize: '13px' }}
                value={message}
                onChange={(e) => setMessage(e.target.value)}
                onKeyDown={(e) => e.key === 'Enter' && handleSend()}
              />
              <Send
                size={20}
                className="cursor-pointer"
                style={{ color: message.trim() ? '#6f42c1' : '#ccc', transition: 'color 0.2s' }}
                onClick={handleSend}
              />
            </div>
          </div>
        )}
      </div>

      {/* ─── 플로팅 버튼 ─── */}
      <div
        className="bg-white border shadow-lg rounded-pill py-2 px-3 d-flex align-items-center gap-2"
        style={{
          position: 'fixed',
          bottom: '20px',
          right: '20px',
          zIndex: 1040,
          cursor: 'pointer',
          transition: 'transform 0.2s ease',
        }}
        onClick={() => setIsOpen(!isOpen)}
        onMouseEnter={(e) => (e.currentTarget.style.transform = 'scale(1.05)')}
        onMouseLeave={(e) => (e.currentTarget.style.transform = 'scale(1)')}
      >
        <MessageSquare size={18} style={{ color: '#6f42c1' }} />
        <span className="fw-bold small" style={{ color: '#444' }}>
          {isOpen ? '닫기' : '채팅 상담'}
        </span>
      </div>
    </>
  );
}


