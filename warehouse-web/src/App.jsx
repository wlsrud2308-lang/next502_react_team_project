import {useEffect, useRef, useState} from "react";
import {db} from "./api/firebaseConfig.js";
import {collection, query, orderBy, onSnapshot, addDoc, serverTimestamp} from  "firebase/firestore";

function App() {

  // 채팅방과 유저 상태 관리
  const [roomId, setRoomId] = useState("");
  const [isJoined, setIsJoined] = useState(false);
  const [userId, setUserId] = useState("ReactUser1");

  // 메시지 관련 상태 관리
  const [messages, setMessages] = useState([]);
  const [newMessages, setNewMessages] = useState("");

  // 새 메시지 수신 시 자동 스크롤을 위한 참조
  const messagesEndRef = useRef(null);

  // 메시지 목록이 업데이트 될 때마다 맨 아래로 자동 스크롤
  useEffect(() => {
    messagesEndRef.current?.scrollIntoView({ behavior: "smooth" });
  }, [messages]);

  // Firestore에서 메시지 실시간 수신 설정
  useEffect(() => {
    if (!isJoined || !roomId) {
      return;
    }

    console.log(`[${roomId}] 방에 연결되었습니다.`);

    // 해당 roomId 컬렉션 내의 'messages' 서브 컬렉션을 시간순 오름차순으로 정렬
    const messagesRef = collection(db, "chatRooms", roomId, "messages");
    const q = query(messagesRef, orderBy("createdAt", "asc"));

    // 실시간 구독 처리 (새 메시지 오면 자동 갱신)
    const unsubscribe = onSnapshot(q, (snapshot) => {
      const fetchedMessages = snapshot.docs.map((doc) => ({
        id: doc.id,
        ...doc.data(),
      }));
      setMessages(fetchedMessages);
    });

    // 컴포넌트 언마운트 또는 의존성 변경 시 구독 해제하여 메모리 누수 방지
    return () => unsubscribe();
  }, [isJoined, roomId]);

  // 메시지 전송 처리
  const handleSendMessages = async (e) => {
    e.preventDefault();
    if (newMessages.trim() === "") return;

    try {
      const messagesRef = collection(db, "chatRooms", roomId, "messages");
      // Firestore에 문서(메시지) 추가
      await addDoc(messagesRef, {
        senderId: userId,
        content: newMessages,
        createdAt: serverTimestamp(), // 서버 시간 기준으로 저장하여 동기화 오류 방지
        isRead: false,
      });
      setNewMessages(""); // 입력창 초기화
    } catch (error) {
      console.error("메시지 전송 실패:", error);
    }
  };

  // 입장 전 화면 렌더링
  if (!isJoined) {
    return (
      <div style={{padding: "50px", textAlign: "center"}}>
        <h2>💬 React 실시간 채팅 테스트</h2>
        <div style={{marginBottom: "20px"}}>
          <label>테스트용 내 ID : </label>
          <input
            value={userId}
            onChange={(e) => setUserId(e.target.value)}
          />
        </div>
        <div>
          <label>채팅방 번호 : </label>
          <input
            placeholder="예: room_100"
            value={roomId}
            onChange={(e) => setRoomId(e.target.value)}
          />
          <button
            onClick={() => roomId ? setIsJoined(true) : alert('방 번호를 입력하세요!')}
            style={{marginLeft: "10px"}}
          >
            입장하기
          </button>
        </div>
      </div>
    )
  }

  // 입장 후 채팅 화면 렌더링
  return (
    <div style={{ maxWidth: "400px", margin: "20px auto", border: "1px solid #ccc", padding: "10px" }}>

      {/* 헤더 */}
      <div style={{ display: "flex", justifyContent: "space-between", borderBottom: "1px solid #eee", paddingBottom: "10px" }}>
        <h3>방 번호: {roomId}</h3>
        <button onClick={() => setIsJoined(false)}>나가기</button>
      </div>

      {/* 메시지 목록 (채팅창) */}
      <div style={{ height: "400px", overflowY: "scroll", padding: "10px", backgroundColor: "#f9f9f9" }}>
        {messages.length === 0 ? (
          <p style={{ textAlign: "center", color: "#888" }}>메시지가 없습니다.</p>
        ) : (
          messages.map((msg) => {
            const isMe = msg.senderId === userId; // 내가 보낸 메시지인지 확인
            return (
              <div
                key={msg.id}
                style={{
                  textAlign: isMe ? "right" : "left",
                  marginBottom: "10px"
                }}
              >
                <div style={{ fontSize: "12px", color: "#666", marginBottom: "2px" }}>
                  {msg.senderId}
                </div>
                <div
                  style={{
                    display: "inline-block",
                    padding: "8px 12px",
                    borderRadius: "15px",
                    backgroundColor: isMe ? "#ffe33a" : "#fff", // 카카오톡 느낌
                    border: isMe ? "none" : "1px solid #ddd",
                    wordBreak: "break-word"
                  }}
                >
                  {msg.content}
                </div>
              </div>
            );
          })
        )}
        {/* 자동 스크롤을 위한 빈 요소 */}
        <div ref={messagesEndRef} />
      </div>

      {/* 메시지 입력창 */}
      <form onSubmit={handleSendMessages} style={{ display: "flex", marginTop: "10px" }}>
        <input
          style={{ flex: 1, padding: "10px" }}
          value={newMessages}
          onChange={(e) => setNewMessages(e.target.value)}
          placeholder="메시지를 입력하세요..."
        />
        <button type="submit" style={{ padding: "10px 20px" }}>전송</button>
      </form>
    </div>
  );
}

export default App
