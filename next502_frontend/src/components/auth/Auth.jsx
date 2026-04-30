import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { useAuth } from '../../context/AuthContext';
import { apiSignup } from '../../service/ApiService';
import Header from '../layout/Header';
import Footer from '../layout/Footer';
import OcrNameVerifier from './OcrNameVerifier';

function Auth() {
  const navigate = useNavigate();
  const { loginSuccess } = useAuth();

  const [userRole, setUserRole] = useState('BUYER');
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [showOcrModal, setShowOcrModal] = useState(false);

  const [formData, setFormData] = useState({
    id: '',
    pw: '',
    pwConfirm: '',
    name: '',
    nick: '',
    birth: '',
    phone: '',
    email: '',
  });

  const [ocrData, setOcrData] = useState({
    isVerified: false,
    businessName: '',
    businessNumber: '',
    businessAddress: '',
  });

  const handleChange = (e) => {
    setFormData({ ...formData, [e.target.name]: e.target.value });
  };

  const handleRoleChange = (role) => {
    setUserRole(role);
    if (role === 'BUYER') {
      setOcrData({ isVerified: false, businessName: '', businessNumber: '', businessAddress: '' });
    }
  };

  const handleOcrComplete = (data) => {
    setOcrData({
      isVerified: true,
      businessName: data.companyName,
      businessNumber: data.registerNumber,
      businessAddress: data.businessAddress,
    });
    if (data.representativeName) {
      setFormData((prev) => ({ ...prev, name: data.representativeName }));
    }
    setShowOcrModal(false);
  };

  const formatBirth = (input) => {
    const digitsOnly = input.replace(/-/g, '');
    if (/^\d{8}$/.test(digitsOnly)) {
      return `${digitsOnly.substring(0, 4)}-${digitsOnly.substring(4, 6)}-${digitsOnly.substring(6, 8)}`;
    }
    if (/^\d{4}-\d{2}-\d{2}$/.test(input)) return input;
    return null;
  };

  const handleSignup = async (e) => {
    e.preventDefault();
    if (isSubmitting) return;

    if (!formData.id) return alert('아이디를 입력하세요.');
    if (!formData.pw) return alert('비밀번호를 입력하세요.');
    if (formData.pw !== formData.pwConfirm) return alert('비밀번호가 일치하지 않습니다.');
    if (!formData.name) return alert('이름을 입력하세요.');
    if (!formData.nick) return alert('닉네임을 입력하세요.');
    if (!formData.birth) return alert('생년월일을 입력하세요.');

    const birthFormatted = formatBirth(formData.birth);
    if (!birthFormatted) return alert('생년월일을 8자리 숫자 또는 YYYY-MM-DD로 입력하세요.');

    if (!formData.phone) return alert('전화번호를 입력하세요.');
    if (userRole === 'PROVIDER' && !ocrData.isVerified)
      return alert('임대인 가입을 위해 사업자 인증이 필요합니다.');

    setIsSubmitting(true);

    try {
      const backendRole = userRole === 'PROVIDER' ? 'ROLE_PROVIDER' : 'ROLE_MEMBER';
      const payload = {
        userId: formData.id,
        userPw: formData.pw,
        userEmail: formData.email,
        userNick: formData.nick,
        name: formData.name,
        birthDate: birthFormatted,
        tel: formData.phone,
        role: backendRole,
        businessName: ocrData.businessName || null,
        businessNumber: ocrData.businessNumber || null,
        businessAddress: ocrData.businessAddress || null,
      };

      const res = await apiSignup(payload);
      loginSuccess(res.accessToken, res.role, res.id);
      alert('회원가입이 완료되었습니다!');
      navigate('/');
    } catch (err) {
      const errorMessage = typeof err === 'string' ? err.replace(/\n/g, ' ') : err;
      alert(errorMessage);
    } finally {
      setIsSubmitting(false);
    }
  };

  return (
    <div className="wrapper">
      <Header />
      <main
        className="bg-light"
        style={{ minHeight: '100vh', paddingTop: '120px', paddingBottom: '100px' }}
      >
        <div className="container">
          <div className="row justify-content-center">
            <div className="col-md-8 col-lg-6">
              <div className="text-center mb-4">
                <h3 className="fw-bold text-dark">회원가입</h3>
              </div>
              <div className="card border-0 shadow-sm rounded-4 overflow-hidden">
                <div className="card-body p-4 p-md-5">
                  <form onSubmit={handleSignup}>
                    <div className="mb-3">
                      <label className="form-label small fw-bold text-secondary">아이디</label>
                      <input
                        type="text"
                        name="id"
                        className="form-control bg-light border-0 py-2"
                        value={formData.id}
                        onChange={handleChange}
                        placeholder="아이디를 입력하세요"
                      />
                    </div>
                    <div className="mb-3">
                      <label className="form-label small fw-bold text-secondary">비밀번호</label>
                      <input
                        type="password"
                        name="pw"
                        className="form-control bg-light border-0 py-2"
                        value={formData.pw}
                        onChange={handleChange}
                        placeholder="비밀번호를 입력하세요"
                      />
                    </div>
                    <div className="mb-3">
                      <label className="form-label small fw-bold text-secondary">
                        비밀번호 확인
                      </label>
                      <input
                        type="password"
                        name="pwConfirm"
                        className="form-control bg-light border-0 py-2"
                        value={formData.pwConfirm}
                        onChange={handleChange}
                        placeholder="비밀번호를 다시 한번 입력하세요"
                      />
                    </div>
                    <div className="mb-3">
                      <label className="form-label small fw-bold text-secondary">이름 (실명)</label>
                      <input
                        type="text"
                        name="name"
                        className="form-control bg-light border-0 py-2"
                        value={formData.name}
                        onChange={handleChange}
                        placeholder="실명을 입력해주세요"
                      />
                    </div>
                    <div className="mb-3">
                      <label className="form-label small fw-bold text-secondary">닉네임</label>
                      <input
                        type="text"
                        name="nick"
                        className="form-control bg-light border-0 py-2"
                        value={formData.nick}
                        onChange={handleChange}
                        placeholder="앱에서 사용할 닉네임을 입력하세요"
                      />
                    </div>
                    <div className="mb-3">
                      <label className="form-label small fw-bold text-secondary">생년월일</label>
                      <input
                        type="text"
                        name="birth"
                        className="form-control bg-light border-0 py-2"
                        value={formData.birth}
                        onChange={handleChange}
                        placeholder="YYYYMMDD 또는 YYYY-MM-DD"
                      />
                    </div>
                    <div className="mb-3">
                      <label className="form-label small fw-bold text-secondary">전화번호</label>
                      <input
                        type="text"
                        name="phone"
                        className="form-control bg-light border-0 py-2"
                        value={formData.phone}
                        onChange={handleChange}
                        placeholder="'-' 없이 숫자만 입력"
                      />
                    </div>
                    <div className="mb-4">
                      <label className="form-label small fw-bold text-secondary">이메일</label>
                      <input
                        type="email"
                        name="email"
                        className="form-control bg-light border-0 py-2"
                        value={formData.email}
                        onChange={handleChange}
                        placeholder="example@email.com"
                      />
                    </div>
                    <hr className="my-4" />
                    <div className="mb-4">
                      <label className="form-label fw-bold d-block mb-3">
                        임대인으로 가입하시겠습니까?
                      </label>
                      <div className="d-flex gap-2">
                        <button
                          type="button"
                          onClick={() => handleRoleChange('PROVIDER')}
                          className={`btn flex-grow-1 py-2 ${userRole === 'PROVIDER' ? 'btn-primary' : 'btn-outline-secondary'}`}
                        >
                          예
                        </button>
                        <button
                          type="button"
                          onClick={() => handleRoleChange('BUYER')}
                          className={`btn flex-grow-1 py-2 ${userRole === 'BUYER' ? 'btn-primary' : 'btn-outline-secondary'}`}
                        >
                          아니오
                        </button>
                      </div>
                    </div>
                    {userRole === 'PROVIDER' && (
                      <div
                        className={`p-3 rounded-3 mb-4 border ${ocrData.isVerified ? 'border-primary bg-primary bg-opacity-10' : 'bg-light'}`}
                      >
                        <div className="d-flex justify-content-between align-items-center mb-2">
                          <span className="fw-bold small">사업자 등록증 인증</span>
                          {ocrData.isVerified && (
                            <span className="text-primary fw-bold small">인증 완료</span>
                          )}
                        </div>
                        {ocrData.isVerified && (
                          <div className="small text-secondary mb-3">
                            <div>상호: {ocrData.businessName}</div>
                            <div>번호: {ocrData.businessNumber}</div>
                          </div>
                        )}
                        <button
                          type="button"
                          onClick={() => setShowOcrModal(true)}
                          className={`btn w-100 py-2 ${ocrData.isVerified ? 'btn-secondary' : 'btn-primary'}`}
                        >
                          {ocrData.isVerified ? '다시 인증하기' : '사업자등록증 촬영/업로드'}
                        </button>
                      </div>
                    )}
                    <button
                      type="submit"
                      disabled={isSubmitting}
                      className="btn btn-primary w-100 py-3 fw-bold rounded-3 mt-2"
                    >
                      {isSubmitting ? '처리 중...' : '가입하기'}
                    </button>
                  </form>
                </div>
              </div>
            </div>
          </div>
        </div>
      </main>
      <Footer />
      {showOcrModal && (
        <div className="modal d-block" style={{ backgroundColor: 'rgba(0,0,0,0.5)', zIndex: 1050 }}>
          <div className="modal-dialog modal-dialog-centered">
            <div className="modal-content border-0 bg-transparent shadow-none">
              <OcrNameVerifier
                onVerifyComplete={handleOcrComplete}
                onCancel={() => setShowOcrModal(false)}
              />
            </div>
          </div>
        </div>
      )}
    </div>
  );
}

export default Auth;
