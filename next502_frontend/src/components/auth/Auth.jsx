import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { useAuth } from '../../context/AuthContext';
import { apiSignup, uploadBusinessLicense } from '../../service/ApiService';

function Auth() {
  const navigate = useNavigate();
  const { loginSuccess } = useAuth();

  const [formData, setFormData] = useState({
    userId: '',
    userPw: '',
    userPwConfirm: '',
    name: '',
    userNick: '',
    tel: '',
    birthDate: '',
    userEmail: '',
    role: 'ROLE_MEMBER',
    businessName: '',
    businessNumber: '',
    businessAddress: '',
  });
  const [isOCRProcessing, setIsOCRProcessing] = useState(false);
  const [isSubmitting, setIsSubmitting] = useState(false);

  const handleChange = (e) => {
    setFormData({ ...formData, [e.target.name]: e.target.value });
  };

  const handleFileUpload = async (e) => {
    const file = e.target.files[0];
    if (!file) return;
    setIsOCRProcessing(true);
    try {
      const data = await uploadBusinessLicense(file);
      setFormData((prev) => ({
        ...prev,
        businessName: data.companyName || '',
        businessNumber: data.registerNumber || '',
        businessAddress: data.businessAddress || '',
      }));
      alert('사업자등록증 인식 완료. 결과를 확인 후 수정해주세요.');
    } catch (err) {
      alert('인식 실패: ' + err);
    } finally {
      setIsOCRProcessing(false);
    }
  };

  const formatBirth = (input) => {
    const digits = input.replace(/-/g, '');
    if (/^\d{8}$/.test(digits)) {
      return `${digits.slice(0, 4)}-${digits.slice(4, 6)}-${digits.slice(6, 8)}`;
    }
    if (/^\d{4}-\d{2}-\d{2}$/.test(input)) return input;
    return null;
  };

  const handleSignup = async (e) => {
    e.preventDefault();
    if (isSubmitting) return;

    if (formData.userPw !== formData.userPwConfirm) {
      alert('비밀번호가 일치하지 않습니다.');
      return;
    }

    const birthFormatted = formatBirth(formData.birthDate);
    if (!birthFormatted) {
      alert('생년월일을 8자리 숫자 또는 YYYY-MM-DD 로 입력하세요.');
      return;
    }

    if (formData.role === 'ROLE_PROVIDER' && !formData.businessNumber) {
      alert('임대인 가입을 위해 사업자등록증 인증이 필요합니다.');
      return;
    }

    setIsSubmitting(true);
    try {
      const payload = {
        userId: formData.userId,
        userPw: formData.userPw,
        name: formData.name,
        userNick: formData.userNick,
        tel: formData.tel,
        birthDate: birthFormatted,
        userEmail: formData.userEmail,
        role: formData.role,
        businessName: formData.businessName || null,
        businessNumber: formData.businessNumber || null,
        businessAddress: formData.businessAddress || null,
      };

      const data = await apiSignup(payload);

      localStorage.setItem('ACCESS_TOKEN', data.accessToken);
      if (data.refreshToken) localStorage.setItem('REFRESH_TOKEN', data.refreshToken);
      loginSuccess(data.accessToken, data.role, data.id);

      alert('회원가입이 완료되었습니다! 자동 로그인 되었습니다.');
      navigate('/');
    } catch (err) {
      alert(err);
    } finally {
      setIsSubmitting(false);
    }
  };

  return (
    <div className="bg-light min-vh-100 d-flex align-items-center py-5">
      <div className="container">
        <div className="row justify-content-center">
          <div className="col-lg-8">
            <div className="card border-0 shadow-lg rounded-4 overflow-hidden">
              <div className="row g-0">
                <div className="p-5 bg-white border-bottom w-100 text-center">
                  <h2 className="fw-bold text-dark">회원가입</h2>
                  <p className="text-muted">창고이음의 가족이 되어 더 많은 혜택을 누리세요.</p>
                </div>

                <div className="card-body p-5">
                  <form onSubmit={handleSignup}>
                    <div className="row g-4">
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
                        <label className="form-label small fw-bold">비밀번호 확인</label>
                        <input
                          type="password"
                          name="userPwConfirm"
                          className="form-control form-control-lg bg-light border-0 fs-6"
                          placeholder="비밀번호 재입력"
                          onChange={handleChange}
                          required
                        />
                      </div>
                      <div className="col-md-6">
                        <label className="form-label small fw-bold">이메일</label>
                        <input
                          type="email"
                          name="userEmail"
                          className="form-control form-control-lg bg-light border-0 fs-6"
                          placeholder="example@email.com"
                          onChange={handleChange}
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
                          placeholder="01012345678"
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

                      {formData.role === 'ROLE_PROVIDER' && (
                        <div className="col-12">
                          <div
                            className="p-4 rounded-4 shadow-sm"
                            style={{ backgroundColor: '#f0f4ff' }}
                          >
                            <h6 className="fw-bold text-primary mb-3">🏢 사업자 인증</h6>
                            <div className="row g-3">
                              <div className="col-12">
                                <label className="form-label small text-muted">
                                  사업자 등록증 업로드 (자동 인식)
                                </label>
                                <input
                                  type="file"
                                  className="form-control"
                                  onChange={handleFileUpload}
                                  accept="image/*"
                                  disabled={isOCRProcessing}
                                />
                                {isOCRProcessing && (
                                  <div className="text-primary small mt-2">
                                    <span className="spinner-border spinner-border-sm me-2"></span>
                                    이미지 분석 중... (최대 10초)
                                  </div>
                                )}
                              </div>
                              <div className="col-md-6">
                                <input
                                  type="text"
                                  name="businessName"
                                  className="form-control bg-white"
                                  placeholder="상호명"
                                  value={formData.businessName}
                                  onChange={handleChange}
                                />
                              </div>
                              <div className="col-md-6">
                                <input
                                  type="text"
                                  name="businessNumber"
                                  className="form-control bg-white"
                                  placeholder="사업자 번호"
                                  value={formData.businessNumber}
                                  onChange={handleChange}
                                />
                              </div>
                              <div className="col-12">
                                <input
                                  type="text"
                                  name="businessAddress"
                                  className="form-control bg-white"
                                  placeholder="사업장 주소"
                                  value={formData.businessAddress}
                                  onChange={handleChange}
                                />
                              </div>
                            </div>
                          </div>
                        </div>
                      )}
                    </div>

                    <div className="mt-5">
                      <button
                        type="submit"
                        disabled={isSubmitting}
                        className="btn btn-primary w-100 py-3 fw-bold rounded-3 shadow-lg border-0 fs-5"
                        style={{ background: 'linear-gradient(45deg, #4e73df, #224abe)' }}
                      >
                        {isSubmitting ? '가입 처리 중...' : '회원가입 완료'}
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
