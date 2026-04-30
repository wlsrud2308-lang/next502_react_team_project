import React, { useState } from 'react';
import { apiFindId } from '../../service/ApiService';

function FindIdModal({ isOpen, onClose }) {
  const [formData, setFormData] = useState({ name: '', tel: '' });
  const [foundId, setFoundId] = useState(null);

  if (!isOpen) return null;

  const handleFindId = async (e) => {
    e.preventDefault();
    try {
      const data = await apiFindId(formData.name, formData.tel);
      setFoundId(data.userId); // 서버에서 받은 아이디 저장
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
        <h4 className="fw-bold mb-4">아이디 찾기</h4>
        {!foundId ? (
          <form onSubmit={handleFindId}>
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
              placeholder="전화번호 (숫자만)"
              onChange={(e) => setFormData({ ...formData, tel: e.target.value })}
              required
            />
            <div className="d-flex gap-2">
              <button type="button" className="btn btn-light flex-fill py-2" onClick={onClose}>
                취소
              </button>
              <button type="submit" className="btn btn-primary flex-fill py-2">
                확인
              </button>
            </div>
          </form>
        ) : (
          <div className="text-center">
            <p className="mb-4">
              찾으시는 아이디는 <br />
              <strong className="fs-5 text-primary">{foundId}</strong> 입니다.
            </p>
            <button className="btn btn-primary w-100 py-2" onClick={onClose}>
              확인
            </button>
          </div>
        )}
      </div>
    </div>
  );
}

export default FindIdModal;
