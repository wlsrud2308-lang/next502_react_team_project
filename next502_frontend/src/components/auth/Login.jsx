//  File: Login.jsx
//  User: it
//  Date: 2026-04-23
//  Time: 오후 12:40
//  Desc : 창고이음 스타일의 모던 로그인 페이지 (Header/Footer 포함 통합 버전)

import React from 'react';
import Header from '../layout/Header';
import Footer from '../layout/Footer';

function Login() {
  const navyColor = '#1a2c4e';

  return (
    <div className="wrapper">
      <Header />

      <main
        className="bg-light"
        style={{ minHeight: '100vh', paddingTop: '150px', paddingBottom: '100px' }}
      >
        <div className="container">
          <div className="row justify-content-center">
            <div className="col-md-6 col-lg-5">
              {/* 상단 타이틀 섹션 */}
              <div className="text-center mb-5">
                <div className="d-inline-flex align-items-center mb-3">
                  <div
                    className="bg-primary text-white p-1 rounded me-2"
                    style={{
                      width: '40px',
                      height: '40px',
                      textAlign: 'center',
                      lineHeight: '32px',
                    }}
                  >
                    <i className="bi bi-box-seam fs-4"></i>
                  </div>
                  <span className="fw-bold fs-2 text-dark tracking-tight">
                    창고<span className="text-primary">이음</span>
                  </span>
                </div>
                <h3 className="fw-bold text-dark">로그인</h3>
                <p className="text-secondary">
                  부산광역시 창고정보연계시스템에 오신 것을 환영합니다.
                </p>
              </div>

              {/* 로그인 카드 컨테이너 */}
              <div className="card border-0 shadow-lg rounded-4 overflow-hidden">
                <div className="card-body p-5">
                  <form onSubmit={(e) => e.preventDefault()}>
                    {/* 아이디 입력 */}
                    <div className="mb-4">
                      <label className="form-label small fw-bold text-secondary">아이디</label>
                      <div className="input-group border rounded-3 p-1 bg-white">
                        <span className="input-group-text bg-transparent border-0 text-primary">
                          <i className="bi bi-person"></i>
                        </span>
                        <input
                          type="text"
                          className="form-control border-0 shadow-none"
                          placeholder="아이디를 입력하세요"
                        />
                      </div>
                    </div>

                    {/* 비밀번호 입력 */}
                    <div className="mb-4">
                      <label className="form-label small fw-bold text-secondary">비밀번호</label>
                      <div className="input-group border rounded-3 p-1 bg-white">
                        <span className="input-group-text bg-transparent border-0 text-primary">
                          <i className="bi bi-lock"></i>
                        </span>
                        <input
                          type="password"
                          className="form-control border-0 shadow-none"
                          placeholder="비밀번호를 입력하세요"
                        />
                      </div>
                    </div>

                    {/* 옵션 설정 영역 */}
                    <div className="d-flex justify-content-between align-items-center mb-4 small">
                      <div className="form-check">
                        <input
                          className="form-check-input shadow-none"
                          type="checkbox"
                          id="rememberMe"
                        />
                        <label
                          className="form-check-label text-secondary"
                          htmlFor="rememberMe"
                          style={{ cursor: 'pointer' }}
                        >
                          로그인 상태 유지
                        </label>
                      </div>
                      <div className="auth-links">
                        <a
                          href="#!"
                          className="text-decoration-none text-secondary me-2 hover-primary"
                        >
                          아이디 찾기
                        </a>
                        <span className="text-muted opacity-50">|</span>
                        <a
                          href="#!"
                          className="text-decoration-none text-secondary ms-2 hover-primary"
                        >
                          비밀번호 찾기
                        </a>
                      </div>
                    </div>

                    {/* 로그인 실행 버튼 */}
                    <button
                      className="btn btn-primary w-100 py-3 fw-bold rounded-3 shadow-sm mb-4 login-submit-btn"
                      style={{ backgroundColor: '#007bff', border: 'none' }}
                    >
                      로그인
                    </button>

                    {/* 구분선 디자인 */}
                    <div className="position-relative text-center mb-4">
                      <hr className="text-muted opacity-25" />
                      <span className="position-absolute top-50 start-50 translate-middle bg-white px-3 text-muted small">
                        SNS 계정으로 로그인
                      </span>
                    </div>

                    {/* 간편 로그인 영역 */}
                    <div className="d-grid gap-2 mb-5">
                      <button className="btn btn-outline-dark py-2 rounded-3 d-flex align-items-center justify-content-center fw-medium border-secondary-subtle hover-bg-light">
                        <i className="bi bi-chat-fill text-warning me-2"></i> 카카오톡으로 시작하기
                      </button>
                    </div>

                    {/* 회원가입 유도 */}
                    <div className="text-center pt-3 border-top">
                      <p className="text-secondary small mb-0">
                        아직 창고이음 회원이 아니신가요?
                        <a
                          href="#!"
                          className="text-primary fw-bold ms-2 text-decoration-none border-bottom border-primary pb-1"
                        >
                          회원가입
                        </a>
                      </p>
                    </div>
                  </form>
                </div>
              </div>

              {/* 하단 안내 배너 */}
              <div className="text-center mt-4 p-3 bg-white border rounded-4 shadow-sm opacity-90">
                <p className="small text-muted mb-0">
                  <i className="bi bi-info-circle-fill me-2 text-primary"></i>
                  기업 회원 전환 문의는 <strong>1588-XXXX</strong> (내선 1번)
                </p>
              </div>
            </div>
          </div>
        </div>
      </main>

      <Footer />

      {/* 인라인 스타일링 */}
      <style
        dangerouslySetInnerHTML={{
          __html: `
        .tracking-tight { letter-spacing: -0.05rem; }
        .login-submit-btn:hover { 
          background-color: ${navyColor} !important; 
          transform: translateY(-2px); 
          box-shadow: 0 5px 15px rgba(0,123,255,0.3) !important;
        }
        .input-group:focus-within { 
          border-color: #007bff !important; 
          box-shadow: 0 0 0 0.25rem rgba(0,123,255,0.1); 
        }
        .hover-primary:hover { color: #007bff !important; }
        .hover-bg-light:hover { background-color: #f8f9fa; }
        .form-check-input:checked { background-color: #007bff; border-color: #007bff; }
      `,
        }}
      />
    </div>
  );
}

export default Login;
