import React, { useState, useEffect } from 'react';
import { useNavigate, useLocation } from 'react-router-dom';
import { updateMemberInfo } from '../../service/ApiService';
import Header from '../layout/Header';
import Footer from '../layout/Footer';

function EditProfile() {
  const navigate = useNavigate();
  const location = useLocation();
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [memberInfo, setMemberInfo] = useState(null);

  const [formData, setFormData] = useState({
    userNick: '',
    birthDate: '',
    tel: '',
    userPw: '',
  });

  useEffect(() => {
    // 마이페이지에서 넘겨준 데이터 세팅
    if (location.state?.memberInfo) {
      const info = location.state.memberInfo;
      setMemberInfo(info);
      setFormData({
        userNick: info.userNick || '',
        birthDate: info.birthDate || '',
        tel: info.tel || '',
        userPw: '',
      });
    }
  }, [location.state]);

  const handleChange = (e) => {
    setFormData({ ...formData, [e.target.name]: e.target.value });
  };

  // 생년월일 포맷팅 로직 (YYYYMMDD -> YYYY-MM-DD)[cite: 2]
  const formatBirth = (input) => {
    const digitsOnly = input.replace(/-/g, '');
    if (/^\d{8}$/.test(digitsOnly)) {
      return `${digitsOnly.substring(0, 4)}-${digitsOnly.substring(4, 6)}-${digitsOnly.substring(6, 8)}`;
    }
    return digitsOnly.length === 10 ? digitsOnly : null;
  };

  const handleUpdate = async (e) => {
    e.preventDefault();
    const birthFormatted = formatBirth(formData.birthDate);

    if (!birthFormatted) {
      alert('생년월일 8자리를 확인해주세요.');
      return;
    }

    setIsSubmitting(true);
    try {
      const updateData = {
        userNick: formData.userNick.trim(),
        birthDate: birthFormatted,
        tel: formData.tel.trim(),
      };

      // 비밀번호가 있을 때만 포함[cite: 2]
      if (formData.userPw.trim() !== '') {
        updateData.userPw = formData.userPw;
      }

      await updateMemberInfo(updateData);
      alert('정보가 수정되었습니다.');
      navigate('/api/member/me');
    } catch (err) {
      alert('수정에 실패했습니다.');
    } finally {
      setIsSubmitting(false);
    }
  };

  return (
    <div className="wrapper" style={{ backgroundColor: '#f4f7f6' }}>
      <Header />
      <main style={{ paddingTop: '120px', paddingBottom: '100px' }}>
        <div className="container">
          <div className="row g-4">
            {/* [왼쪽] 웹 전용 사이드바 - 여백을 채워주는 역할 */}
            <div className="col-lg-3 d-none d-lg-block">
              <div
                className="card border-0 shadow-sm rounded-4 p-4 sticky-top"
                style={{ top: '120px' }}
              >
                <div className="text-center mb-4">
                  <div
                    className="bg-primary bg-opacity-10 rounded-circle d-inline-flex align-items-center justify-content-center mb-3"
                    style={{ width: '80px', height: '80px' }}
                  >
                    <span style={{ fontSize: '2.5rem' }}>👤</span>
                  </div>
                  <h5 className="fw-bold mb-1">{memberInfo?.name || '사용자'}</h5>
                  <p className="text-muted small">{memberInfo?.userEmail}</p>
                </div>
                <div className="list-group list-group-flush small fw-bold">
                  <div className="list-group-item border-0 py-3 text-primary bg-primary bg-opacity-10 rounded-3 mb-2">
                    ✅ 회원 정보 수정
                  </div>
                  <div
                    className="list-group-item border-0 py-3 cursor-pointer mb-2"
                    onClick={() => navigate('/favorites')}
                  >
                    ⭐ 관심 창고 목록
                  </div>
                  <div
                    className="list-group-item border-0 py-3 cursor-pointer mb-2"
                    onClick={() => navigate('/api/member/me')}
                  >
                    🏠 마이페이지 홈
                  </div>
                </div>
              </div>
            </div>

            {/* [오른쪽] 메인 컨텐츠 영역 - 실제 수정 폼 */}
            <div className="col-lg-9">
              <div className="card border-0 shadow-sm rounded-4 overflow-hidden">
                <div className="p-5 bg-white border-bottom border-light">
                  <h4 className="fw-bold mb-1 text-dark">계정 설정</h4>
                  <p className="text-secondary small mb-0">
                    회원님의 개인정보를 최신 상태로 유지해 주세요.
                  </p>
                </div>

                <div className="card-body p-5 pt-4">
                  <form onSubmit={handleUpdate}>
                    <div className="row mb-4">
                      <div className="col-md-6 mb-4 mb-md-0">
                        <label className="form-label fw-bold text-secondary small">닉네임</label>
                        <input
                          type="text"
                          name="userNick"
                          className="form-control form-control-lg border-0 bg-light fs-6"
                          value={formData.userNick}
                          onChange={handleChange}
                          required
                        />
                      </div>
                      <div className="col-md-6">
                        <label className="form-label fw-bold text-secondary small">전화번호</label>
                        <input
                          type="text"
                          name="tel"
                          className="form-control form-control-lg border-0 bg-light fs-6"
                          value={formData.tel}
                          onChange={handleChange}
                          required
                        />
                      </div>
                    </div>

                    <div className="row mb-5">
                      <div className="col-md-6 mb-4 mb-md-0">
                        <label className="form-label fw-bold text-secondary small">
                          생년월일 (8자리)
                        </label>
                        <input
                          type="text"
                          name="birthDate"
                          className="form-control form-control-lg border-0 bg-light fs-6"
                          placeholder="예: 19950520"
                          value={formData.birthDate}
                          onChange={handleChange}
                          required
                        />
                      </div>
                      <div className="col-md-6">
                        <label className="form-label fw-bold text-secondary small">
                          새 비밀번호 (선택)
                        </label>
                        <input
                          type="password"
                          name="userPw"
                          className="form-control form-control-lg border-0 bg-light fs-6"
                          placeholder="변경 시에만 입력"
                          value={formData.userPw}
                          onChange={handleChange}
                        />
                      </div>
                    </div>

                    <div className="d-flex justify-content-end gap-3 border-top pt-4">
                      <button
                        type="button"
                        className="btn btn-light px-5 py-3 fw-bold rounded-3"
                        onClick={() => navigate(-1)}
                      >
                        취소
                      </button>
                      <button
                        type="submit"
                        disabled={isSubmitting}
                        className="btn btn-primary px-5 py-3 fw-bold rounded-3 shadow-sm border-0"
                        style={{ background: '#4e73df' }}
                      >
                        {isSubmitting ? '수정 중...' : '변경사항 저장'}
                      </button>
                    </div>
                  </form>
                </div>
              </div>
            </div>
          </div>
        </div>
      </main>
      <Footer />
    </div>
  );
}

export default EditProfile;
