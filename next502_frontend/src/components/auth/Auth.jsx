import React from 'react';
import Header from '../layout/Header';
import Footer from '../layout/Footer';

function Auth() {
  return (
    <div className="bg-light">
      <Header />
      <main style={{ paddingTop: '130px', paddingBottom: '100px' }}>
        <div className="container">
          <div className="col-lg-8 mx-auto">
            <div className="text-center mb-5">
              <h2 className="fw-bold mb-3">회원가입</h2>
              <p className="text-secondary">창고이음의 정보입력 단계입니다.</p>
            </div>
            <div className="card border-0 shadow-sm rounded-4 p-5 text-start bg-white">
              <h5 className="fw-bold mb-4 pb-2 border-bottom">기본 정보 입력</h5>
              <div className="mb-4 row">
                <label className="col-md-3 col-form-label fw-bold">아이디 *</label>
                <div className="col-md-9">
                  <div className="input-group">
                    <input type="text" className="form-control" />
                    <button className="btn btn-outline-primary">중복확인</button>
                  </div>
                </div>
              </div>
              <div className="mb-4 row">
                <label className="col-md-3 col-form-label fw-bold">비밀번호 *</label>
                <div className="col-md-9">
                  <input type="password" className="form-control" />
                </div>
              </div>
              <div className="mb-4 row">
                <label className="col-md-3 col-form-label fw-bold">담당자명 *</label>
                <div className="col-md-9">
                  <input type="text" className="form-control" />
                </div>
              </div>
              <div className="mb-4 row">
                <label className="col-md-3 col-form-label fw-bold">연락처 *</label>
                <div className="col-md-9">
                  <div className="row g-2">
                    <div className="col-4">
                      <input type="text" className="form-control" />
                    </div>
                    <div className="col-4">
                      <input type="text" className="form-control" />
                    </div>
                    <div className="col-4">
                      <input type="text" className="form-control" />
                    </div>
                  </div>
                </div>
              </div>
              <div className="text-center mt-5 pt-4 border-top">
                <button className="btn btn-outline-secondary btn-lg px-5 me-3 rounded-pill fw-bold">
                  취소
                </button>
                <button className="btn btn-primary btn-lg px-5 rounded-pill fw-bold">
                  가입완료
                </button>
              </div>
            </div>
          </div>
        </div>
      </main>
      <Footer />
    </div>
  );
}
export default Auth;
