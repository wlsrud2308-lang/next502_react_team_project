import React, { useState, useEffect } from 'react';
import { Form, Button } from 'react-bootstrap';
import { Send, MessageSquare, Heart, Smile, ChevronLeft } from 'lucide-react';
// import { db } from '../../firebase'; // 👈 파이어베이스 이닛 파일 생성 후 주석 해제
// import { collection, query, where, onSnapshot } from 'firebase/firestore';

export default function FloatingChatBar() {
  const [isOpen, setIsOpen] = useState(false);
  const [selectedRoom, setSelectedRoom] = useState(null); // 현재 클릭한 방 (ChatRoomDTO 규격)
  const [message, setMessage] = useState('');

  // ⚠️ 백엔드 ChatRoomDTO 규격에 맞춘 가상 리스트 (추후 Firestore 실시간 데이터로 대체)
  const [chatRooms, setChatRooms] = useState([
    {
      chatRoomId: 101,
      warehouseName: '부산항 신항 배후단지 창고',
      userid: 'buyer_01',
      updateDate: '2026-05-04 14:30',
    },
    {
      chatRoomId: 102,
      warehouseName: '감천항 냉동 물류센터',
      userid: 'provider_02',
      updateDate: '2026-05-04 12:15',
    },
  ]);

  // 💡 [추후 연동할 파이어베이스 실시간 구독 코드 미리 심어두기]
  /*
  useEffect(() => {
    const currentUserId = "현재_로그인한_유저_ID";
    const q = query(
      collection(db, "chatRooms"),
      where("participants", "arrayContains", currentUserId)
    );

    const unsubscribe = onSnapshot(q, (snapshot) => {
      const rooms = snapshot.docs.map(doc => ({
        chatRoomId: doc.id,
        ...doc.data()
      }));
      setChatRooms(rooms);
    });

    return () => unsubscribe();
  }, []);
  */

  const handleSend = () => {
    if (!message.trim()) return;
    console.log(`[${selectedRoom.warehouseName}]에 메시지 전송:`, message);
    setMessage('');
  };

  return (
    <>
      {/* 1. 클릭 시 위로 솟아오르는 인스타그램 스타일 채팅 서랍 */}
      <div
        className={`bg-white rounded-4 shadow-lg border border-light flex-column ${
          isOpen ? 'd-flex' : 'd-none'
        }`}
        style={{
          position: 'fixed',
          bottom: '80px',
          right: '20px',
          width: '330px',
          height: '450px',
          zIndex: 1050,
          transition: 'all 0.2s ease',
        }}
      >
        {/* ─── 헤더 영역 ─── */}
        <div className="p-3 border-bottom d-flex justify-content-between align-items-center bg-light rounded-top-4">
          <div className="d-flex align-items-center gap-2">
            {selectedRoom && (
              <ChevronLeft
                size={20}
                className="cursor-pointer text-secondary"
                style={{ cursor: 'pointer' }}
                onClick={() => setSelectedRoom(null)}
              />
            )}
            <div
              className="bg-dark text-white rounded-circle d-flex align-items-center justify-content-center font-bold"
              style={{ width: '32px', height: '32px', fontSize: '12px' }}
            >
              W
            </div>
            <span
              className="fw-bold text-dark"
              style={{ fontSize: '14px', maxWidth: '180px' }}
              className="text-truncate"
            >
              {selectedRoom ? selectedRoom.warehouseName : '채팅 목록'}
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

        {/* ─── 본문 영역 (목록 vs 대화창 분기) ─── */}
        <div className="flex-grow-1 overflow-auto bg-white" style={{ fontSize: '13px' }}>
          {!selectedRoom ? (
            // 📁 목록 화면 (ChatRoomDTO 기반 렌더링)
            chatRooms.length > 0 ? (
              chatRooms.map((room) => (
                <div
                  key={room.chatRoomId}
                  className="p-3 border-bottom d-flex align-items-center justify-content-between hover-bg-light"
                  style={{ cursor: 'pointer', transition: 'background 0.2s' }}
                  onClick={() => setSelectedRoom(room)}
                  onMouseEnter={(e) => (e.currentTarget.style.backgroundColor = '#f8f9fa')}
                  onMouseLeave={(e) => (e.currentTarget.style.backgroundColor = 'transparent')}
                >
                  <div className="d-flex flex-column" style={{ maxWidth: '70%' }}>
                    <span className="fw-bold text-dark text-truncate">{room.warehouseName}</span>
                    <span className="text-secondary" style={{ fontSize: '11px' }}>
                      상대: {room.userid}
                    </span>
                  </div>
                  <span className="text-muted" style={{ fontSize: '10px' }}>
                    {room.updateDate.substring(11, 16)} {/* 시간만 추출 */}
                  </span>
                </div>
              ))
            ) : (
              <div className="text-center py-5 text-muted">참여 중인 채팅방이 없습니다.</div>
            )
          ) : (
            // 💬 대화 화면
            <div className="p-3">
              <div
                className="bg-light p-2 rounded-3 text-dark d-inline-block"
                style={{ maxWidth: '80%' }}
              >
                안녕하세요! {selectedRoom.warehouseName}에 대해 무엇을 도와드릴까요?
              </div>
            </div>
          )}
        </div>

        {/* ─── 입력창 영역 (대화창이 열렸을 때만 노출) ─── */}
        {selectedRoom && (
          <div className="p-3 border-top">
            <div className="d-flex align-items-center gap-2 bg-light rounded-pill px-3 py-1">
              <Form.Control
                type="text"
                placeholder="메시지 입력..."
                className="border-0 bg-transparent shadow-none p-1"
                style={{ fontSize: '13px' }}
                value={message}
                onChange={(e) => setMessage(e.target.value)}
                onKeyPress={(e) => e.key === 'Enter' && handleSend()}
              />
              <div className="d-flex gap-2 text-secondary align-items-center">
                <Smile size={16} style={{ cursor: 'pointer' }} />
                <Heart size={16} style={{ cursor: 'pointer' }} />
                <Button
                  variant="link"
                  className="text-primary p-0 text-decoration-none fw-bold"
                  style={{ fontSize: '13px' }}
                  onClick={handleSend}
                >
                  전송
                </Button>
              </div>
            </div>
          </div>
        )}
      </div>

      {/* 2. [요청하신 부분] 우측 하단 고정 플로팅 바 (프로필 버블 삭제) */}
      <div
        className="bg-white border shadow-sm rounded-4 py-2 px-3 d-flex justify-content-between align-items-center"
        style={{
          position: 'fixed',
          bottom: '20px',
          right: '20px',
          width: '180px', // 버블이 빠졌으므로 가로 폭을 스마트하게 축소
          zIndex: 1040,
          cursor: 'pointer',
        }}
        onClick={() => setIsOpen(!isOpen)}
      >
        <div className="d-flex align-items-center gap-2">
          <MessageSquare size={18} className="text-dark" />
          <span className="fw-bold text-dark" style={{ fontSize: '14px' }}>
            메시지
          </span>
        </div>

        {/* 안 읽은 총 메시지 수 등 숫자를 배지 형태로 띄워주면 훨씬 깔끔합니다. */}
        <span className="badge bg-danger rounded-pill" style={{ fontSize: '10px' }}>
          2
        </span>
      </div>
    </>
  );
}

