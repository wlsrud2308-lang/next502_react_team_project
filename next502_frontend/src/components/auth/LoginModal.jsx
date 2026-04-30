import React, { useState } from 'react';
import { useAuth } from '../../context/AuthContext';
import { apiLogin, loginWithKakao } from '../../service/ApiService';

function LoginModal({ isOpen, onClose, onSwitchToSignup }) {
  const [userId, setUserId] = useState('');
  const [userPw, setUserPw] = useState('');
  const { loginSuccess } = useAuth();

  if (!isOpen) return null;

  // 일반 로그인 처리
  const handleLogin = async (e) => {
    e.preventDefault();
    try {
      const data = await apiLogin(userId, userPw);
      loginSuccess(data.token || data.accessToken, data.role, data.userId || data.id);
      onClose();
    } catch (err) {
      alert(err);
    }
  };

  // ★ 3단계: 카카오 로그인
  const handleKakaoLogin = () => {
    if (!window.Kakao) {
      alert('카카오 SDK가 아직 불러와지지 않았습니다. 잠시 후 다시 시도해주세요.');
      return;
    }
    const Kakao = window.Kakao;

    // 1. 카카오 인증 서비스 호출
    Kakao.Auth.login({
      success: function (authObj) {
        console.log('카카오 인증 성공:', authObj);

        // 2. 사용자 정보 요청
        Kakao.API.request({
          url: '/v2/user/me',
          success: async function (res) {
            console.log('사용자 정보 요청 성공:', res);

            const kakaoAccount = res.kakao_account;
            const nickname = kakaoAccount?.profile?.nickname || '카카오유저';
            const email = kakaoAccount?.email || ''; //[cite: 1]

            try {

              const response = await loginWithKakao(
                authObj.access_token, // 카카오 발급 토큰
                res.id, // 카카오 고유 식별자
                nickname, // 닉네임
              );


              loginSuccess(response.accessToken, response.role, response.id);

              alert(`${nickname}님, 환영합니다!`);
              onClose();
            } catch (err) {
              console.error('백엔드 연동 실패:', err);
              alert('서버 로그인 처리 중 오류가 발생했습니다.');
            }
          },
          fail: function (error) {
            console.error('사용자 정보 요청 실패:', error);
          },
        });
      },
      fail: function (err) {
        console.error('카카오 인증 실패:', err);
      },
    });
  };

  return (
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
              className="form-control bg-light border-0 py-3 mb-4"
              placeholder="비밀번호"
              value={userPw}
              onChange={(e) => setUserPw(e.target.value)}
              required
            />
            <button
              className="btn btn-primary w-100 py-3 fw-bold rounded-3 border-0 mb-3"
              style={{ background: '#4e73df' }}
            >
              로그인
            </button>
          </form>

          {/* 카카오 로그인 버튼 */}
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
  );
}

export default LoginModal;
