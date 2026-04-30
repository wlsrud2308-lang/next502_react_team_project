import React, { useState } from 'react';
import { apiSignup, uploadBusinessLicense } from '../../service/ApiService';

function SignupModal({ isOpen, onClose, onSwitchToLogin }) {
  const [formData, setFormData] = useState({
    userId: '',
    userPw: '',
    name: '',
    userNick: '',
    tel: '',
    birthDate: '',
    role: 'ROLE_MEMBER',
    businessName: '',
    businessNumber: '',
  });
  const [isOCRProcessing, setIsOCRProcessing] = useState(false);

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
      setFormData({
        ...formData,
        businessName: data.businessName || '',
        businessNumber: data.businessNumber || '',
      });
    } catch (err) {
      alert('인식 실패: ' + err);
    } finally {
      setIsOCRProcessing(false);
    }
  };

  const handleSignup = async (e) => {
    e.preventDefault();
    try {
      await apiSignup(formData);
      alert('회원가입 완료!');
      onSwitchToLogin();
    } catch (err) {
      alert(err);
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
        {/* 헤더 */}
        <div className="px-5 py-4 bg-white border-bottom d-flex justify-content-between align-items-center">
          <div>
            <h3 className="fw-bold mb-0">회원가입</h3>
            <p className="text-muted small mb-0">인적 사항을 먼저 입력해 주세요.</p>
          </div>
          <button onClick={onClose} className="btn-close"></button>
        </div>

        {/* 본문 영역 */}
        <div className="p-5 pt-4" style={{ overflowY: 'auto', maxHeight: 'calc(90vh - 100px)' }}>
          <form onSubmit={handleSignup}>
            {/* 1. 공통 인적 사항 섹션 */}
            <div className="row g-3 mb-5">
              <div className="col-md-6">
                <label className="form-label small fw-bold text-secondary">아이디</label>
                <input
                  type="text"
                  name="userId"
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
                  className="form-control py-2 bg-light border-0 shadow-sm"
                  onChange={handleChange}
                  required
                />
              </div>
              <div className="col-md-6">
                <label className="form-label small fw-bold text-secondary">이름</label>
                <input
                  type="text"
                  name="name"
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
                  className="form-control py-2 bg-light border-0 shadow-sm"
                  placeholder="01012345678"
                  onChange={handleChange}
                  required
                />
              </div>
              <div className="col-md-6">
                <label className="form-label small fw-bold text-secondary">
                  생년월일 (8자리)
                </label>
                <input
                  type="text"
                  name="birthDate"
                  className="form-control py-2 bg-light border-0 shadow-sm"
                  placeholder="19900101"
                  onChange={handleChange}
                  required
                />
              </div>
            </div>

            <hr className="my-4 opacity-10" />

            {/* 2. 가입 유형 선택  */}
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

            {/* 3. 임대인 선택 시에만 나타나는 OCR 섹션 */}
            {formData.role === 'ROLE_PROVIDER' && (
              <div
                className="mb-4 p-4 rounded-4 border-0 shadow-sm animate__animated animate__fadeIn"
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
                      />
                      {isOCRProcessing && (
                        <div className="text-primary small mt-2 spinner-border spinner-border-sm"></div>
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
                </div>
              </div>
            )}

            {/* 4. 회원가입 완료 버튼 */}
            <button
              type="submit"
              className="btn btn-primary w-100 py-3 fw-bold rounded-3 border-0 mt-2 shadow-lg"
              style={{ background: 'linear-gradient(45deg, #4e73df, #224abe)' }}
            >
              회원가입 완료
            </button>
          </form>
        </div>
      </div>
    </div>
  );
}

export default SignupModal;
