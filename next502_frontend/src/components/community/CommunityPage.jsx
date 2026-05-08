import React, { useState, useEffect } from 'react'; // useEffect 추가
import { useParams, useNavigate } from 'react-router-dom';
import axios from 'axios'; // axios 설치 필요 (npm install axios)
import Header from '../layout/Header';
import Footer from '../layout/Footer';
import { Container, Nav, Table, Form, Button, InputGroup, Card } from 'react-bootstrap';
import { useAuth } from '../../context/AuthContext';


function CommunityPage() {
  const { category } = useParams();
  const navigate = useNavigate();
  const { userRole } = useAuth();
  const [searchKeyword, setSearchKeyword] = useState('');

  // 1. 서버 데이터를 담을 상태 변수
  const [boardList, setBoardList] = useState([]);

  const tabs = [
    { id: 'notice', name: '공지사항' },
    { id: 'faq', name: '자주 하는 질문' },
    { id: 'qna', name: '묻고 답하기' },
    { id: 'news', name: '물류뉴스' },
  ];

  // 2. 백엔드 데이터 불러오기 (axios 이용)
  useEffect(() => {
    const fetchBoards = async () => {
      try {
        // 백엔드 컨트롤러: @GetMapping("/list/{category}") 호출
        const response = await axios.get(`http://localhost:8080/board/list/${category}`);
        setBoardList(response.data);
      } catch (error) {
        console.error('데이터 로드 실패:', error);
      }
    };

    if (category) fetchBoards();
  }, [category]); // 카테고리가 바뀔 때마다 다시 실행

  return (
    <div className="wrapper">
      <Header />

      <Container style={{ marginTop: '150px', marginBottom: '100px' }}>
        <h2 className="fw-bold mb-4">커뮤니티</h2>

        <Nav variant="tabs" className="mb-4 border-bottom-2">
          {tabs.map((tab) => (
            <Nav.Item key={tab.id}>
              <Nav.Link
                active={category === tab.id}
                onClick={() => navigate(`/community/${tab.id}`)}
                className={`px-4 py-3 fw-bold ${category === tab.id ? 'text-dark border-bottom-0' : 'text-secondary'}`}
              >
                {tab.name}
              </Nav.Link>
            </Nav.Item>
          ))}
        </Nav>

        <div className="d-flex justify-content-between align-items-center mb-3">
          <div className="text-secondary small">
            전체 <span className="text-danger fw-bold">{boardList.length}</span>건의 게시물이
            있습니다.
          </div>
          {/* ... 검색창 영역 (동일) ... */}
        </div>

        <Card className="border-0 border-top border-2 border-dark rounded-0 shadow-none">
          <Table hover responsive className="text-center align-middle mb-0">
            <thead className="bg-light">
              <tr style={{ height: '50px' }}>
                <th style={{ width: '10%' }}>번호</th>
                <th style={{ width: '60%' }}>제목</th>
                <th style={{ width: '15%' }}>작성자</th> {/* 첨부파일 대신 작성자 표시 권장 */}
                <th style={{ width: '15%' }}>작성일</th>
              </tr>
            </thead>
            <tbody className="border-top-0">
              {boardList.length > 0 ? (
                boardList.map((item) => (
                  <tr
                    key={item.boardId}
                    style={{ height: '60px', cursor: 'pointer' }}
                    onClick={() => navigate(`/community/${category}/${item.boardId}`)} // 상세 페이지 이동
                  >
                    <td className="text-secondary small">{item.boardId}</td>
                    <td
                      className="text-start px-4 fw-medium text-truncate"
                      style={{ maxWidth: '400px' }}
                    >
                      {item.title}
                    </td>
                    <td className="text-secondary small">
                      {/* MemberEntity가 lazy 로딩이므로 백엔드에서 DTO로 변환해 보내거나 @EntityGraph 권장 */}
                      {item.writer?.userNick || '관리자'}
                    </td>
                    <td className="text-secondary small">
                      {/* BaseTimeEntity의 날짜 포맷 (YYYY-MM-DD) */}
                      {item.createDate?.substring(0, 10)}
                    </td>
                  </tr>
                ))
              ) : (
                <tr>
                  <td colSpan="4" className="py-5 text-secondary">
                    등록된 게시물이 없습니다.
                  </td>
                </tr>
              )}
            </tbody>
          </Table>
        </Card>
        {(category === 'qna' || userRole === 'ROLE_ADMIN') && (
          <div className="d-flex justify-content-end mt-3">
            <Button
              variant="primary"
              onClick={() => navigate(`/community/${category}/write`)}
              style={{ backgroundColor: '#4e73df', border: 'none' }}
            >
              글쓰기
            </Button>
          </div>
        )}
      </Container>
      <Footer />
    </div>
  );
}

export default CommunityPage;
