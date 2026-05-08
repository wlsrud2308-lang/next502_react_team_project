import React, { useState, useEffect } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import axios from 'axios';
import { useAuth } from '../../context/AuthContext'; // 1. useAuth 추가
import Header from '../layout/Header';
import Footer from '../layout/Footer';
import { Container, Spinner, Button, Form } from 'react-bootstrap';

function CommunityDetailPage() {
  const { category, boardId } = useParams();
  const navigate = useNavigate();
  const { userRole } = useAuth(); // 2. 관리자 권한 확인용
  const [board, setBoard] = useState(null);
  const [loading, setLoading] = useState(true);
  const [replyText, setReplyText] = useState(''); // 답변 입력 상태

  useEffect(() => {
    const fetchDetail = async () => {
      try {
        setLoading(true);
        if (!boardId) return;
        const response = await axios.get(`http://localhost:8080/board/${boardId}`);
        setBoard(response.data);
        if (response.data.reply) setReplyText(response.data.reply); // 기존 답변 있으면 세팅
      } catch (error) {
        console.error('데이터 로드 실패:', error);
      } finally {
        setLoading(false);
      }
    };
    fetchDetail();
  }, [boardId]);

  // 답변 등록 함수 (관리자 전용)
  const handleReplySubmit = async () => {
    if (!replyText.trim()) return alert('답변 내용을 입력해주세요.');
    try {
      const token = localStorage.getItem('ACCESS_TOKEN');
      // 백엔드에 답변 업데이트 요청 (URL은 본인의 컨트롤러 설정에 맞게 수정)
      await axios.put(
        `http://localhost:8080/board/${boardId}/reply`,
        { reply: replyText },
        {
          headers: { Authorization: `Bearer ${token}` },
        },
      );
      alert('답변이 등록되었습니다.');
      window.location.reload(); // 새로고침하여 반영
    } catch (error) {
      alert('답변 등록 실패: ' + error.message);
    }
  };

  if (loading)
    return (
      <div className="d-flex justify-content-center align-items-center" style={{ height: '100vh' }}>
        <Spinner animation="border" />
      </div>
    );

  if (!board)
    return (
      <Container className="mt-5 text-center">
        <h3>게시글을 찾을 수 없습니다.</h3>
        <Button onClick={() => navigate(-1)}>뒤로가기</Button>
      </Container>
    );

  return (
    <div className="wrapper">
      <Header />
      <Container style={{ marginTop: '150px', marginBottom: '100px' }}>
        <div className="border-bottom border-2 border-dark pb-3 mb-4">
          <h3 className="fw-bold mb-3">{board?.title}</h3>
          <div className="d-flex text-secondary small">
            <span className="me-4">작성자: {board?.writer?.userNick || '관리자'}</span>
            <span>등록일: {board.createDate?.substring(0, 10)}</span>
          </div>
        </div>

        {/* 질문 본문 */}
        <div
          className="py-5 mb-5 border-bottom"
          style={{ minHeight: '300px', whiteSpace: 'pre-wrap' }}
        >
          {board?.content}
        </div>

        {category === 'qna' && (
          <>
            {board?.reply ? (
              /* 답변이 있을 때: 모든 유저에게 노출 */
              <div
                className="p-4 mb-5 rounded-3"
                style={{ backgroundColor: '#f8f9fa', borderLeft: '5px solid #4e73df' }}
              >
                <h6 className="fw-bold text-primary mb-3">💬 관리자 답변</h6>
                <div style={{ whiteSpace: 'pre-wrap' }}>{board.reply}</div>
              </div>
            ) : (
              /* 답변이 없을 때: 관리자에게만 작성창 노출 */
              userRole === 'ROLE_ADMIN' && (
                <div className="p-4 mb-5 border rounded-3 bg-light">
                  <h6 className="fw-bold mb-3">답변 작성 (관리자 전용)</h6>
                  <Form.Control
                    as="textarea"
                    rows={3}
                    className="mb-2"
                    placeholder="답변을 입력하세요..."
                    value={replyText}
                    onChange={(e) => setReplyText(e.target.value)}
                  />
                  <Button variant="primary" size="sm" onClick={handleReplySubmit}>
                    답변 등록
                  </Button>
                </div>
              )
            )}
          </>
        )}

        <Button variant="dark" onClick={() => navigate(`/community/${category}`)}>
          목록
        </Button>
      </Container>
      <Footer />
    </div>
  );
}

export default CommunityDetailPage;
