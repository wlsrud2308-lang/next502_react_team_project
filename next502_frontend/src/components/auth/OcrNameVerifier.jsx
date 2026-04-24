import React, { useState } from 'react';

const OcrVerifyPage = () => {
  const [name, setName] = useState('');
  const [isLoading, setIsLoading] = useState(false);

  const handleFileChange = async (e) => {
    const file = e.target.files[0];
    if (!file) return;

    const formData = new FormData();
    formData.append('file', file);

    setIsLoading(true); // 로딩 상태 시작

    try {
      // 스프링 부트 서버 주소 (CORS 설정 확인 필요)
      const response = await fetch('http://localhost:8080/ocr/verify-name', {
        method: 'POST',
        body: formData,
      });

      if (!response.ok) throw new Error('서버 통신 에러');

      const data = await response.json();
      setName(data.extractedName);

      if (data.extractedName !== '미인식') {
        alert(`${data.extractedName} 님 인증에 성공했습니다!`);
      } else {
        alert('이름을 인식할 수 없습니다. 다른 사진으로 시도해주세요.');
      }
    } catch (error) {
      console.error('인식 중 에러 발생:', error);
      alert('서버와 통신할 수 없습니다. 백엔드 실행 상태를 확인하세요.');
    } finally {
      setIsLoading(false); // 로딩 상태 종료
    }
  };

  return (
    <div style={{ padding: '20px', textAlign: 'center' }}>
      <h2>신분증/명함 이름 인증</h2>
      <p>인증을 위해 사진을 업로드해주세요.</p>

      <input type="file" onChange={handleFileChange} accept="image/*" disabled={isLoading} />

      <div style={{ marginTop: '20px', fontSize: '1.2rem' }}>
        {isLoading ? (
          <p>텍스트 분석 중...</p>
        ) : (
          <p>
            인식된 이름: <strong>{name || '파일을 선택하세요'}</strong>
          </p>
        )}
      </div>
    </div>
  );
};

export default OcrVerifyPage;
