import React, { useState, useEffect } from 'react';
import { useAuth } from '../../context/AuthContext';
import { apiSignup, uploadBusinessLicense } from '../../service/ApiService';

function SignupModal({ isOpen, onClose, onSwitchToLogin }) {
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

  // 모달 열릴 때마다 폼 초기화
  useEffect(() => {
    if (isOpen) {
      setFormData({
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
      setIsOCRProcessing(false);
      setIsSubmitting(false);
    }
  }, [isOpen]);

  if (!isOpen) return null;

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

      alert('회원가입 완료! 자동 로그인 되었습니다.');
      onClose();
    } catch (err) {
      alert(err);
    } finally {
      setIsSubmitting(false);
    }
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
        className="bg-white rounded-4 shadow-lg overflow-hidden"
        style={{ maxWidth: '750px', width: '95%', maxHeight: '90vh' }}
      >
        <div className="px-5 py-4 bg-white border-bottom d-flex justify-content-between align-items-center">
          <div>
            <h3 className="fw-bold mb-0">회원가입</h3>
            <p className="text-muted small mb-0">인적 사항을 먼저 입력해 주세요.</p>
          </div>
          <button onClick={onClose} className="btn-close"></button>
        </div>

        <div className="p-5 pt-4" style={{ overflowY: 'auto', maxHeight: 'calc(90vh - 100px)' }}>
          <form onSubmit={handleSignup}>
            <div className="row g-3 mb-5">
              <div className="col-md-6">
                <label className="form-label small fw-bold text-secondary">아이디</label>
                <input
                  type="text"
                  name="userId"
                  value={formData.userId}
                  className="form-control py-2 bg-light border-0 shadow-sm"
                  onChange={handleChange}
                  required
                />
              </div>
              <div className="col-md-6">
                <label className="form-label small fw-bold text-secondary">비밀번호</label>
                <input
                  type="password"
                  name="userPw"
                  value={formData.userPw}
                  className="form-control py-2 bg-light border-0 shadow-sm"
                  onChange={handleChange}
                  required
                />
              </div>
              <div className="col-md-6">
                <label className="form-label small fw-bold text-secondary">비밀번호 확인</label>
                <input
                  type="password"
                  name="userPwConfirm"
                  value={formData.userPwConfirm}
                  className="form-control py-2 bg-light border-0 shadow-sm"
                  onChange={handleChange}
                  required
                />
              </div>
              <div className="col-md-6">
                <label className="form-label small fw-bold text-secondary">이메일</label>
                <input
                  type="email"
                  name="userEmail"
                  value={formData.userEmail}
                  className="form-control py-2 bg-light border-0 shadow-sm"
                  placeholder="example@email.com"
                  onChange={handleChange}
                />
              </div>
              <div className="col-md-6">
                <label className="form-label small fw-bold text-secondary">이름</label>
                <input
                  type="text"
                  name="name"
                  value={formData.name}
                  className="form-control py-2 bg-light border-0 shadow-sm"
                  onChange={handleChange}
                  required
                />
              </div>
              <div className="col-md-6">
                <label className="form-label small fw-bold text-secondary">닉네임</label>
                <input
                  type="text"
                  name="userNick"
                  value={formData.userNick}
                  className="form-control py-2 bg-light border-0 shadow-sm"
                  onChange={handleChange}
                  required
                />
              </div>
              <div className="col-md-6">
                <label className="form-label small fw-bold text-secondary">전화번호</label>
                <input
                  type="text"
                  name="tel"
                  value={formData.tel}
                  className="form-control py-2 bg-light border-0 shadow-sm"
                  placeholder="01012345678"
                  onChange={handleChange}
                  required
                />
              </div>
              <div className="col-md-6">
                <label className="form-label small fw-bold text-secondary">생년월일 (8자리)</label>
                <input
                  type="text"
                  name="birthDate"
                  value={formData.birthDate}
                  className="form-control py-2 bg-light border-0 shadow-sm"
                  placeholder="19900101"
                  onChange={handleChange}
                  required
                />
              </div>
            </div>

            <hr className="my-4 opacity-10" />

            <div className="mb-4">
              <label className="form-label small fw-bold text-dark mb-3">
                가입 유형을 선택해 주세요
              </label>
              <div className="d-flex gap-3">
                <div className="flex-fill">
                  <input
                    type="radio"
                    className="btn-check"
                    name="role"
                    id="modal_m"
                    value="ROLE_MEMBER"
                    checked={formData.role === 'ROLE_MEMBER'}
                    onChange={handleChange}
                  />
                  <label
                    className="btn btn-outline-primary w-100 py-3 rounded-3 fw-bold shadow-sm"
                    htmlFor="modal_m"
                  >
                    일반 회원
                  </label>
                </div>
                <div className="flex-fill">
                  <input
                    type="radio"
                    className="btn-check"
                    name="role"
                    id="modal_p"
                    value="ROLE_PROVIDER"
                    checked={formData.role === 'ROLE_PROVIDER'}
                    onChange={handleChange}
                  />
                  <label
                    className="btn btn-outline-primary w-100 py-3 rounded-3 fw-bold shadow-sm"
                    htmlFor="modal_p"
                  >
                    임대인(기업)
                  </label>
                </div>
              </div>
            </div>

            {formData.role === 'ROLE_PROVIDER' && (
              <div
                className="mb-4 p-4 rounded-4 border-0 shadow-sm"
                style={{ backgroundColor: '#f0f4ff' }}
              >
                <div className="d-flex align-items-center mb-3">
                  <span className="fs-4 me-2">🏢</span>
                  <h6 className="fw-bold mb-0 text-primary">사업자 인증 정보</h6>
                </div>
                <div className="row g-3">
                  <div className="col-12">
                    <div className="bg-white p-3 rounded-3 border">
                      <label className="form-label small text-muted">
                        사업자 등록증 업로드 (자동 인식)
                      </label>
                      <input
                        type="file"
                        className="form-control form-control-sm border-0"
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
                  </div>
                  <div className="col-md-6">
                    <input
                      type="text"
                      name="businessName"
                      className="form-control py-2 border-0 shadow-sm"
                      placeholder="상호명"
                      value={formData.businessName}
                      onChange={handleChange}
                    />
                  </div>
                  <div className="col-md-6">
                    <input
                      type="text"
                      name="businessNumber"
                      className="form-control py-2 border-0 shadow-sm"
                      placeholder="사업자 번호"
                      value={formData.businessNumber}
                      onChange={handleChange}
                    />
                  </div>
                  <div className="col-12">
                    <input
                      type="text"
                      name="businessAddress"
                      className="form-control py-2 border-0 shadow-sm"
                      placeholder="사업장 주소"
                      value={formData.businessAddress}
                      onChange={handleChange}
                    />
                  </div>
                </div>
              </div>
            )}

            <button
              type="submit"
              disabled={isSubmitting}
              className="btn btn-primary w-100 py-3 fw-bold rounded-3 border-0 mt-2 shadow-lg"
              style={{ background: 'linear-gradient(45deg, #4e73df, #224abe)' }}
            >
              {isSubmitting ? '가입 처리 중...' : '회원가입 완료'}
            </button>
          </form>
        </div>
      </div>
    </div>
  );
}

export default SignupModal;
