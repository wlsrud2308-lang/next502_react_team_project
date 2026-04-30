import React, { useState } from 'react';
import { useAuth } from '../../context/AuthContext';
import { apiLogin } from '../../service/ApiService';
import FindIdModal from './FindIdModal';
import FindPwModal from './FindPwModal';

function LoginModal({ isOpen, onClose, onSwitchToSignup }) {
  const [userId, setUserId] = useState('');
  const [userPw, setUserPw] = useState('');

  // 2. 아이디/비밀번호 찾기 모달의 열림 상태 관리
  const [isFindIdOpen, setIsFindIdOpen] = useState(false);
  const [isFindPwOpen, setIsFindPwOpen] = useState(false);

  const { loginSuccess } = useAuth();

  if (!isOpen) return null;

  const handleLogin = async (e) => {
    e.preventDefault();
    try {
      const data = await apiLogin(userId, userPw);
      loginSuccess(data.token, data.role, data.userId);
      onClose();
    } catch (err) {
      alert(err);
    }
  };

  const handleKakaoLogin = () => {
    alert('카카오 로그인 페이지로 이동합니다.');
  };

  return (
    <>
      <div
        className="modal-backdrop d-flex align-items-center justify-content-center"
        style={{
          position: 'fixed',
          top: 0,
          left: 0,
          width: '100vw',
          height: '100vh',
          backgroundColor: 'rgba(0,0,0,0.7)',
          zIndex: 2000,
        }}
      >
        <div
          className="bg-white rounded-4 overflow-hidden shadow-lg d-flex"
          style={{ maxWidth: '850px', width: '90%', height: '530px' }}
        >
          {/* 왼쪽: 브랜드 섹션 */}
          <div
            className="col-lg-5 d-none d-lg-flex flex-column justify-content-center align-items-center text-white p-5"
            style={{ background: 'linear-gradient(135deg, #4e73df 0%, #224abe 100%)' }}
          >
            <h2 className="fw-bold">창고이음</h2>
            <p className="small text-center opacity-75 mt-2">부산 스마트 창고 연결의 시작</p>
            <div className="fs-1">📦</div>
          </div>

          <div className="col-lg-7 p-5 position-relative d-flex flex-column justify-content-center">
            <button
              onClick={onClose}
              className="btn-close position-absolute top-0 end-0 m-4"
            ></button>
            <h3 className="fw-bold mb-4">로그인</h3>

            <form onSubmit={handleLogin}>
              <input
                type="text"
                className="form-control bg-light border-0 py-3 mb-3"
                placeholder="아이디"
                value={userId}
                onChange={(e) => setUserId(e.target.value)}
                required
              />
              <input
                type="password"
                className="form-control bg-light border-0 py-3 mb-2"
                placeholder="비밀번호"
                value={userPw}
                onChange={(e) => setUserPw(e.target.value)}
                required
              />

              {/* 3. 링크 클릭 시 모달 열기 상태로 변경 */}
              <div className="d-flex justify-content-end gap-3 mb-4 px-1">
                <span
                  className="text-secondary small cursor-pointer"
                  style={{ cursor: 'pointer', fontSize: '0.8rem' }}
                  onClick={() => setIsFindIdOpen(true)}
                >
                  아이디 찾기
                </span>
                <span className="text-secondary-emphasis small">|</span>
                <span
                  className="text-secondary small cursor-pointer"
                  style={{ cursor: 'pointer', fontSize: '0.8rem' }}
                  onClick={() => setIsFindPwOpen(true)}
                >
                  비밀번호 찾기
                </span>
              </div>

              <button
                className="btn btn-primary w-100 py-3 fw-bold rounded-3 border-0 mb-3"
                style={{ background: '#4e73df' }}
              >
                로그인
              </button>
            </form>

            <button
              className="btn w-100 py-3 fw-bold rounded-3 border-0 mb-3 d-flex align-items-center justify-content-center"
              style={{ backgroundColor: '#FEE500', color: '#3c1e1e' }}
              onClick={handleKakaoLogin}
            >
              <span className="me-2">💬</span> 카카오 로그인
            </button>

            <p className="text-center small text-muted mb-0">
              계정이 없으신가요?{' '}
              <span
                className="text-primary fw-bold cursor-pointer"
                style={{ cursor: 'pointer' }}
                onClick={onSwitchToSignup}
              >
                회원가입 하기
              </span>
            </p>
          </div>
        </div>
      </div>


      <FindIdModal isOpen={isFindIdOpen} onClose={() => setIsFindIdOpen(false)} />
      <FindPwModal isOpen={isFindPwOpen} onClose={() => setIsFindPwOpen(false)} />
    </>
  );
}

export default LoginModal;
