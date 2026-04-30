import React, { useState, useRef } from 'react';
import { uploadBusinessLicense } from '../../service/ApiService';

function OcrNameVerifier({ onVerifyComplete, onCancel }) {
  const fileInputRef = useRef(null);
  const [selectedImage, setSelectedImage] = useState(null);
  const [isUploading, setIsUploading] = useState(false);
  const [ocrData, setOcrData] = useState(null);

  const handleFileSelect = async (e) => {
    const file = e.target.files[0];
    if (!file) return;

    const imageUrl = URL.createObjectURL(file);
    setSelectedImage(imageUrl);
    setIsUploading(true);
    setOcrData(null);

    try {
      const data = await uploadBusinessLicense(file);
      setOcrData(data);
    } catch (err) {
      alert(`분석 실패: ${err}`);
      setSelectedImage(null);
    } finally {
      setIsUploading(false);
    }
  };

  const handleConfirm = () => {
    if (ocrData && onVerifyComplete) {
      onVerifyComplete(ocrData);
    }
  };

  return (
    <div className="card border-0 shadow-lg rounded-4">
      <div className="card-header bg-white border-bottom-0 pt-4 d-flex justify-content-between align-items-center">
        <h5 className="fw-bold mb-0">사업자 인증</h5>
        <button type="button" className="btn-close" onClick={onCancel}></button>
      </div>

      <div className="card-body p-4">
        <input
          type="file"
          accept="image/*"
          ref={fileInputRef}
          style={{ display: 'none' }}
          onChange={handleFileSelect}
        />

        <div
          onClick={() => !isUploading && fileInputRef.current.click()}
          className="border border-2 border-dashed rounded-4 d-flex flex-column align-items-center justify-content-center mb-4"
          style={{
            height: '180px',
            cursor: isUploading ? 'default' : 'pointer',
            backgroundColor: '#f8f9fa',
          }}
        >
          {isUploading ? (
            <div className="text-center text-primary">
              <div className="spinner-border spinner-border-sm mb-2"></div>
              <div className="small">이미지 분석 중...</div>
            </div>
          ) : selectedImage ? (
            <img
              src={selectedImage}
              alt="Preview"
              style={{ width: '100%', height: '100%', objectFit: 'contain' }}
            />
          ) : (
            <div className="text-center text-secondary">
              <div className="fs-2 mb-2">+</div>
              <div className="fw-semibold">사업자등록증 파일 선택</div>
            </div>
          )}
        </div>

        {ocrData && (
          <div className="p-3 bg-light rounded-3 mb-4 border shadow-sm">
            <div className="row g-2 small">
              <div className="col-4 text-secondary">상호명</div>
              <div className="col-8 fw-bold">{ocrData.companyName || '인식 불가'}</div>
              <div className="col-4 text-secondary">사업자번호</div>
              <div className="col-8 fw-bold">{ocrData.registerNumber || '인식 불가'}</div>
              <div className="col-4 text-secondary">사업장 주소</div>
              <div className="col-8 fw-bold">{ocrData.businessAddress || '인식 불가'}</div>
            </div>
          </div>
        )}

        <button
          type="button"
          disabled={!ocrData || isUploading}
          onClick={handleConfirm}
          className="btn btn-primary w-100 py-3 fw-bold"
        >
          인증된 정보 사용하기
        </button>
      </div>
    </div>
  );
}

export default OcrNameVerifier;
