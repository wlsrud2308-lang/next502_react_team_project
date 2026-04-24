import React from 'react';
import { useNavigate, useLocation } from 'react-router-dom';

function BoardTest() {
  const navigate = useNavigate();
  const location = useLocation();

  // 이전 페이지(OCR)에서 보낸 이름 데이터를 받아옵니다.
  const userName = location.state?.userName || '손님';

  return (
    <div className="container mt-5 text-center">
      <div className="card shadow p-5">
        <h1 className="text-success mb-4">✅ 게시판 테스트 페이지</h1>
        <p className="fs-4">
          <strong>{userName}</strong>님, OCR 인증에 성공하여 보드 페이지로 이동했습니다.
        </p>
        <div className="mt-4">
          <button className="btn btn-primary me-2" onClick={() => navigate('/')}>
            홈으로 이동
          </button>
          <button className="btn btn-outline-secondary" onClick={() => navigate(-1)}>
            이전으로
          </button>
        </div>
      </div>
    </div>
  );
}

export default BoardTest;
