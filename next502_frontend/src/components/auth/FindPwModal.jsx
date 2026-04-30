import React, { useState } from 'react';
import { apiFindPw, apiResetPw } from '../../service/ApiService';

function FindPwModal({ isOpen, onClose }) {
  const [step, setStep] = useState(1); // 1: 정보입력, 2: 비번재설정
  const [formData, setFormData] = useState({ userId: '', name: '', tel: '', newUserPw: '' });

  if (!isOpen) return null;

  const handleVerify = async (e) => {
    e.preventDefault();
    try {
      await apiFindPw(formData.userId, formData.name, formData.tel);
      setStep(2);
    } catch (err) {
      alert(err);
    }
  };

  const handleReset = async (e) => {
    e.preventDefault();
    try {
      await apiResetPw(formData.userId, formData.newUserPw);
      alert('비밀번호가 재설정되었습니다. 다시 로그인 해주세요.');
      onClose();
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
        zIndex: 3000,
      }}
    >
      <div className="bg-white rounded-4 p-5 shadow-lg" style={{ maxWidth: '450px', width: '90%' }}>
        <h4 className="fw-bold mb-4">비밀번호 찾기</h4>
        {step === 1 ? (
          <form onSubmit={handleVerify}>
            <input
              type="text"
              className="form-control mb-3 py-2"
              placeholder="아이디"
              onChange={(e) => setFormData({ ...formData, userId: e.target.value })}
              required
            />
            <input
              type="text"
              className="form-control mb-3 py-2"
              placeholder="이름"
              onChange={(e) => setFormData({ ...formData, name: e.target.value })}
              required
            />
            <input
              type="text"
              className="form-control mb-4 py-2"
              placeholder="전화번호"
              onChange={(e) => setFormData({ ...formData, tel: e.target.value })}
              required
            />
            <button type="submit" className="btn btn-primary w-100 py-2">
              정보 확인
            </button>
          </form>
        ) : (
          <form onSubmit={handleReset}>
            <p className="small text-muted mb-3">새로운 비밀번호를 설정해 주세요.</p>
            <input
              type="password"
              className="form-control mb-4 py-2"
              placeholder="새 비밀번호 입력"
              onChange={(e) => setFormData({ ...formData, newUserPw: e.target.value })}
              required
            />
            <button type="submit" className="btn btn-success w-100 py-2">
              비밀번호 변경 완료
            </button>
          </form>
        )}
        <button
          className="btn btn-link w-100 mt-3 text-secondary text-decoration-none small"
          onClick={onClose}
        >
          닫기
        </button>
      </div>
    </div>
  );
}

export default FindPwModal;
