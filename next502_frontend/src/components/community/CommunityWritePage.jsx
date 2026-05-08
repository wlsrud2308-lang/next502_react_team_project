import React, { useState } from 'react';
import { useNavigate, useParams } from 'react-router-dom';
import axios from 'axios';
import { Container, Form, Button } from 'react-bootstrap';
import Header from '../layout/Header';
import Footer from '../layout/Footer';

function CommunityWritePage() {
  const { category } = useParams();
  const navigate = useNavigate();
  const [title, setTitle] = useState('');
  const [content, setContent] = useState('');

  const handleSubmit = async (e) => {
    e.preventDefault();

    // 로컬 스토리지에서 토큰 가져오기 (인증 필요)
    const token = localStorage.getItem('ACCESS_TOKEN');

    try {
      await axios.post(
        'http://localhost:8080/board/',
        {
          title: title,
          content: content,
          category: category.toUpperCase(), // 서버가 대문자를 원하므로 변환
        },
        {
          headers: {
            Authorization: `Bearer ${token}`, // JWT 토큰 전달
          },
        },
      );

      alert('게시글이 등록되었습니다.');
      navigate(`/community/${category}`);
    } catch (error) {
      console.error('등록 실패:', error);
      alert('글 등록에 실패했습니다. 로그인을 확인해주세요.');
    }
  };

  return (
    <div className="wrapper">
      <Header />
      <Container style={{ marginTop: '150px', marginBottom: '100px' }}>
        <h2 className="fw-bold mb-4">{category === 'qna' ? '묻고 답하기' : '게시글'} 작성</h2>
        <Form onSubmit={handleSubmit}>
          <Form.Group className="mb-3">
            <Form.Label className="fw-bold">제목</Form.Label>
            <Form.Control
              type="text"
              placeholder="제목을 입력하세요"
              value={title}
              onChange={(e) => setTitle(e.target.value)}
              required
            />
          </Form.Group>
          <Form.Group className="mb-4">
            <Form.Label className="fw-bold">내용</Form.Label>
            <Form.Control
              as="textarea"
              rows={15}
              placeholder="내용을 입력하세요"
              value={content}
              onChange={(e) => setContent(e.target.value)}
              required
            />
          </Form.Group>
          <div className="d-flex justify-content-end gap-2">
            <Button variant="secondary" onClick={() => navigate(-1)}>
              취소
            </Button>
            <Button variant="primary" type="submit" className="px-4">
              등록
            </Button>
          </div>
        </Form>
      </Container>
      <Footer />
    </div>
  );
}

export default CommunityWritePage;
