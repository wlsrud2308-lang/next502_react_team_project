import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { apiSignup } from '../../service/ApiService';

function Auth() {
  const navigate = useNavigate();
  const [formData, setFormData] = useState({
    userId: '',
    userPw: '',
    name: '',
    userNick: '',
    tel: '',
    birthDate: '',
    role: 'ROLE_MEMBER',
  });

  const handleChange = (e) => {
    setFormData({ ...formData, [e.target.name]: e.target.value });
  };

  const handleSignup = async (e) => {
    e.preventDefault();
    try {
      await apiSignup(formData);
      alert('회원가입이 완료되었습니다!');
      navigate('/login');
    } catch (err) {
      alert(err);
    }
  };

  return (
    <div className="bg-light min-vh-100 d-flex align-items-center py-5">
      <div className="container">
        <div className="row justify-content-center">
          <div className="col-lg-8">
            <div className="card border-0 shadow-lg rounded-4 overflow-hidden">
              <div className="row g-0">
                {/* 상단 헤더 */}
                <div className="p-5 bg-white border-bottom w-100 text-center">
                  <h2 className="fw-bold text-dark">회원가입</h2>
                  <p className="text-muted">창고이음의 가족이 되어 더 많은 혜택을 누리세요.</p>
                </div>

                <div className="card-body p-5">
                  <form onSubmit={handleSignup}>
                    <div className="row g-4">
                      {/* 1열 배치로 넓게 활용 */}
                      <div className="col-md-6">
                        <label className="form-label small fw-bold">아이디</label>
                        <input
                          type="text"
                          name="userId"
                          className="form-control form-control-lg bg-light border-0 fs-6"
                          placeholder="아이디 입력"
                          onChange={handleChange}
                          required
                        />
                      </div>
                      <div className="col-md-6">
                        <label className="form-label small fw-bold">비밀번호</label>
                        <input
                          type="password"
                          name="userPw"
                          className="form-control form-control-lg bg-light border-0 fs-6"
                          placeholder="비밀번호 입력"
                          onChange={handleChange}
                          required
                        />
                      </div>

                      <div className="col-md-6">
                        <label className="form-label small fw-bold">이름</label>
                        <input
                          type="text"
                          name="name"
                          className="form-control form-control-lg bg-light border-0 fs-6"
                          placeholder="실명 입력"
                          onChange={handleChange}
                          required
                        />
                      </div>
                      <div className="col-md-6">
                        <label className="form-label small fw-bold">닉네임</label>
                        <input
                          type="text"
                          name="userNick"
                          className="form-control form-control-lg bg-light border-0 fs-6"
                          placeholder="활동할 이름 입력"
                          onChange={handleChange}
                          required
                        />
                      </div>

                      <div className="col-md-6">
                        <label className="form-label small fw-bold">전화번호</label>
                        <input
                          type="text"
                          name="tel"
                          className="form-control form-control-lg bg-light border-0 fs-6"
                          placeholder="010-0000-0000"
                          onChange={handleChange}
                          required
                        />
                      </div>
                      <div className="col-md-6">
                        <label className="form-label small fw-bold">생년월일 (8자리)</label>
                        <input
                          type="text"
                          name="birthDate"
                          className="form-control form-control-lg bg-light border-0 fs-6"
                          placeholder="YYYYMMDD"
                          onChange={handleChange}
                          required
                        />
                      </div>

                      <div className="col-12">
                        <label className="form-label small fw-bold">가입 유형</label>
                        <div className="d-flex gap-3 mt-1">
                          <div className="flex-fill">
                            <input
                              type="radio"
                              className="btn-check"
                              name="role"
                              id="member"
                              value="ROLE_MEMBER"
                              checked={formData.role === 'ROLE_MEMBER'}
                              onChange={handleChange}
                            />
                            <label
                              className="btn btn-outline-primary w-100 py-3 border-2 rounded-3"
                              htmlFor="member"
                            >
                              개인 회원
                            </label>
                          </div>
                          <div className="flex-fill">
                            <input
                              type="radio"
                              className="btn-check"
                              name="role"
                              id="provider"
                              value="ROLE_PROVIDER"
                              checked={formData.role === 'ROLE_PROVIDER'}
                              onChange={handleChange}
                            />
                            <label
                              className="btn btn-outline-primary w-100 py-3 border-2 rounded-3"
                              htmlFor="provider"
                            >
                              기업/임대인
                            </label>
                          </div>
                        </div>
                      </div>
                    </div>

                    <div className="mt-5">
                      <button
                        type="submit"
                        className="btn btn-primary w-100 py-3 fw-bold rounded-3 shadow-lg border-0 fs-5"
                        style={{ background: 'linear-gradient(45deg, #4e73df, #224abe)' }}
                      >
                        회원가입 완료
                      </button>
                    </div>
                  </form>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}

export default Auth;
