import React, { useState, useEffect } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { useAuth } from '../../context/AuthContext';
import { updateWarehouseInfo, fetchWarehouseDetail } from '../../service/ApiService';
import Header from '../layout/Header';
import Footer from '../layout/Footer';
import {
  ClipboardList,
  Ruler,
  CheckCircle2,
  Image as ImageIcon,
  X,
  UploadCloud,
  Info,
} from 'lucide-react';

const STORAGE_TYPES = [
  '보통창고',
  '야적창고',
  '냉동/냉장창고',
  '저장창고',
  '간이창고',
  '위험물창고',
];
const SIZE_RANKS = ['S', 'M', 'L'];
const AMENITY_OPTIONS = ['주차가능', '무인택배함', 'CCTV', '24시간 운영', '화물 엘리베이터'];

const API_BASE_URL = 'http://localhost:8080';

function WarehouseEdit() {
  const { id } = useParams(); // URL에서 창고 ID 파싱
  const navigate = useNavigate();
  const { isLoggedIn, userRole, loading } = useAuth();

  const [formData, setFormData] = useState({
    name: '',
    address: '',
    description: '',
    sizeRank: '',
    totalArea: '',
    storageType: '',
    operationStructure: '',
  });
  const [amenities, setAmenities] = useState([]);
  const [images, setImages] = useState([]);
  const [previews, setPreviews] = useState([]);
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [isDataLoading, setIsDataLoading] = useState(true);

  // 권한 체크
  useEffect(() => {
    if (loading) return;

    if (!isLoggedIn) {
      alert('로그인이 필요합니다.');
      navigate('/login');
      return;
    }
    if (userRole !== 'ROLE_PROVIDER' && userRole !== 'ROLE_ADMIN') {
      alert('창고 수정은 임대인(기업) 회원만 가능합니다.');
      navigate('/');
    }
  }, [isLoggedIn, userRole, loading, navigate]);

  // ★ 기존 데이터 불러오기
  useEffect(() => {
    if (loading || !isLoggedIn) return;

    const loadData = async () => {
      try {
        const data = await fetchWarehouseDetail(id);

        // 텍스트 데이터 채우기
        setFormData({
          name: data.name || '',
          address: data.address || '',
          description: data.description || '',
          sizeRank: data.sizeRank || '',
          totalArea: data.totalArea || '',
          storageType: data.storageType || '',
          operationStructure: data.operationStructure || '',
        });

        // 편의시설 체크 채우기
        if (data.amenities) {
          setAmenities(data.amenities.split(',').map((item) => item.trim()));
        }

        // 기존 이미지 미리보기 셋팅
        if (data.imageUrls && data.imageUrls.length > 0) {
          const existingPreviews = data.imageUrls.map((url) =>
            url.startsWith('http') ? url : `${API_BASE_URL}${url}`,
          );
          setPreviews(existingPreviews);
        } else if (data.repImageUrl) {
          const repUrl = data.repImageUrl.startsWith('http')
            ? data.repImageUrl
            : `${API_BASE_URL}${data.repImageUrl}`;
          setPreviews([repUrl]);
        }
      } catch (err) {
        console.error(err);
        alert('데이터를 불러오지 못했습니다.');
        navigate(-1);
      } finally {
        setIsDataLoading(false);
      }
    };
    loadData();
  }, [id, loading, isLoggedIn, navigate]);

  const handleChange = (e) => {
    setFormData({ ...formData, [e.target.name]: e.target.value });
  };

  const handleAmenityToggle = (item) => {
    setAmenities((prev) =>
      prev.includes(item) ? prev.filter((a) => a !== item) : [...prev, item],
    );
  };

  const handleImageUpload = (e) => {
    const files = Array.from(e.target.files);


    setImages(files);
    const newPreviews = files.map((f) => URL.createObjectURL(f));
    setPreviews(newPreviews);
  };

  const handleRemoveImage = (idx) => {

    setImages((prev) => prev.filter((_, i) => i !== idx));
    setPreviews((prev) => prev.filter((_, i) => i !== idx));
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    if (isSubmitting) return;

    if (!formData.name || !formData.address || !formData.sizeRank || !formData.storageType) {
      alert('필수 항목을 모두 입력해주세요.');
      return;
    }

    setIsSubmitting(true);
    try {
      const payload = {
        name: formData.name,
        address: formData.address,
        description: formData.description,
        sizeRank: formData.sizeRank,
        totalArea: formData.totalArea,
        storageType: formData.storageType,
        operationStructure: formData.operationStructure,
        amenities: amenities.join(','),
      };

      const submitData = new FormData();
      submitData.append('data', new Blob([JSON.stringify(payload)], { type: 'application/json' }));


      if (images.length > 0) {
        images.forEach((img) => submitData.append('images', img));
      }

      await updateWarehouseInfo(id, submitData);
      alert('창고 수정이 완료되었습니다!');
      navigate(`/warehouse/${id}`);
    } catch (err) {
      alert('수정 실패: ' + err);
    } finally {
      setIsSubmitting(false);
    }
  };

  if (loading || isDataLoading)
    return <div className="text-center py-5 mt-5">기존 정보를 불러오는 중입니다...</div>;
  if (!isLoggedIn) return null;
  if (userRole !== 'ROLE_PROVIDER' && userRole !== 'ROLE_ADMIN') return null;

  return (
    <div className="bg-light" style={{ minHeight: '100vh' }}>
      <Header />

      <main style={{ paddingTop: '100px', paddingBottom: '80px' }}>
        <div className="container">
          <div className="row justify-content-center">
            <div className="col-lg-11 col-xl-10">
              <div className="d-flex justify-content-between align-items-end mb-4 border-bottom pb-3">
                <div>
                  <h2 className="fw-bold text-dark mb-1">창고 정보 수정</h2>
                  <p className="text-secondary mb-0 small">
                    기존에 등록한 창고의 정보를 수정합니다.
                  </p>
                </div>
                <div className="text-muted small">
                  <span className="text-danger">*</span> 필수 입력 항목
                </div>
              </div>

              <form onSubmit={handleSubmit}>
                <div className="card border-0 shadow-sm rounded-3 mb-4 bg-white">
                  <div className="card-header bg-white border-bottom-0 pt-4 pb-0 px-4 d-flex align-items-center">
                    <ClipboardList className="text-primary me-2" size={20} />
                    <h5 className="fw-bold mb-0">기본 정보</h5>
                  </div>
                  <div className="card-body p-4">
                    <div className="row g-4 mb-4">
                      <div className="col-md-6">
                        <label className="form-label fw-semibold text-dark small">
                          창고 이름 <span className="text-danger">*</span>
                        </label>
                        <input
                          type="text"
                          name="name"
                          className="form-control bg-light border-1 px-3 py-2"
                          placeholder="예: 부산항 신항 배후단지 창고"
                          value={formData.name}
                          onChange={handleChange}
                          required
                        />
                      </div>

                      <div className="col-md-6">
                        <label className="form-label fw-semibold text-dark small">
                          주소 <span className="text-danger">*</span>
                        </label>
                        <input
                          type="text"
                          name="address"
                          className="form-control bg-light border-1 px-3 py-2"
                          placeholder="예: 부산광역시 강서구 성북동 123"
                          value={formData.address}
                          onChange={handleChange}
                          required
                        />
                      </div>

                      <div className="col-12">
                        <label className="form-label fw-semibold text-dark small">상세 설명</label>
                        <textarea
                          name="description"
                          className="form-control bg-light border-1 px-3 py-2"
                          rows="4"
                          placeholder="창고의 특징, 접근성, 주변 인프라 등 상세한 설명을 입력해주세요."
                          value={formData.description}
                          onChange={handleChange}
                        />
                      </div>
                    </div>
                  </div>
                </div>

                <div className="card border-0 shadow-sm rounded-3 mb-4 bg-white">
                  <div className="card-header bg-white border-bottom-0 pt-4 pb-0 px-4 d-flex align-items-center">
                    <Ruler className="text-success me-2" size={20} />
                    <h5 className="fw-bold mb-0">규격 및 운영 정보</h5>
                  </div>
                  <div className="card-body p-4">
                    <div className="row g-4">
                      <div className="col-md-3 col-sm-6">
                        <label className="form-label fw-semibold text-dark small">
                          규모 <span className="text-danger">*</span>
                        </label>
                        <select
                          name="sizeRank"
                          className="form-select bg-light border-1 px-3 py-2 cursor-pointer"
                          value={formData.sizeRank}
                          onChange={handleChange}
                          required
                        >
                          <option value="" disabled>
                            선택
                          </option>
                          {SIZE_RANKS.map((s) => (
                            <option key={s} value={s}>
                              {s}
                            </option>
                          ))}
                        </select>
                      </div>

                      <div className="col-md-3 col-sm-6">
                        <label className="form-label fw-semibold text-dark small">
                          총 면적 (㎡)
                        </label>
                        <input
                          type="number"
                          name="totalArea"
                          className="form-control bg-light border-1 px-3 py-2"
                          placeholder="0"
                          value={formData.totalArea}
                          onChange={handleChange}
                          min="0"
                          step="0.01"
                        />
                      </div>

                      <div className="col-md-3 col-sm-6">
                        <label className="form-label fw-semibold text-dark small">
                          보관 유형 <span className="text-danger">*</span>
                        </label>
                        <select
                          name="storageType"
                          className="form-select bg-light border-1 px-3 py-2 cursor-pointer"
                          value={formData.storageType}
                          onChange={handleChange}
                          required
                        >
                          <option value="" disabled>
                            유형 선택
                          </option>
                          {STORAGE_TYPES.map((t) => (
                            <option key={t} value={t}>
                              {t}
                            </option>
                          ))}
                        </select>
                      </div>

                      <div className="col-md-3 col-sm-6">
                        <label className="form-label fw-semibold text-dark small">운영 구조</label>
                        <input
                          type="text"
                          name="operationStructure"
                          className="form-control bg-light border-1 px-3 py-2"
                          placeholder="예: 자가운영, 위탁 등"
                          value={formData.operationStructure}
                          onChange={handleChange}
                        />
                      </div>
                    </div>
                  </div>
                </div>

                <div className="row g-4 mb-4">
                  {/* 왼쪽: 편의시설 */}
                  <div className="col-md-5">
                    <div className="card border-0 shadow-sm rounded-3 h-100 bg-white">
                      <div className="card-header bg-white border-bottom-0 pt-4 pb-0 px-4 d-flex align-items-center">
                        <CheckCircle2 className="text-info me-2" size={20} />
                        <h5 className="fw-bold mb-0">편의시설</h5>
                      </div>
                      <div className="card-body p-4">
                        <div className="d-flex flex-wrap gap-2">
                          {AMENITY_OPTIONS.map((item) => {
                            const checked = amenities.includes(item);
                            return (
                              <button
                                type="button"
                                key={item}
                                onClick={() => handleAmenityToggle(item)}
                                className={`btn btn-sm rounded-pill px-3 py-1 fw-medium border ${
                                  checked
                                    ? 'btn-primary text-white border-primary'
                                    : 'bg-white text-secondary border-secondary'
                                }`}
                                style={{ transition: 'all 0.15s ease-in-out' }}
                              >
                                {checked ? '✓ ' : '+ '}
                                {item}
                              </button>
                            );
                          })}
                        </div>
                      </div>
                    </div>
                  </div>

                  {/* 오른쪽: 사진 업로드 */}
                  <div className="col-md-7">
                    <div className="card border-0 shadow-sm rounded-3 h-100 bg-white">
                      <div className="card-header bg-white border-bottom-0 pt-4 pb-0 px-4 d-flex align-items-center">
                        <ImageIcon className="text-warning me-2" size={20} />
                        <h5 className="fw-bold mb-0">창고 사진 (수정)</h5>
                      </div>
                      <div className="card-body p-4">
                        <label
                          htmlFor="warehouse-image-upload"
                          className="d-flex flex-column align-items-center justify-content-center border border-primary border-opacity-25 rounded-3 p-4 text-center bg-light w-100"
                          style={{
                            cursor: 'pointer',
                            borderStyle: 'dashed !important',
                            transition: 'background-color 0.2s',
                          }}
                          onMouseOver={(e) => e.currentTarget.classList.add('bg-white')}
                          onMouseOut={(e) => e.currentTarget.classList.remove('bg-light')}
                        >
                          <UploadCloud size={32} className="text-primary mb-2 opacity-75" />
                          <span className="fw-bold text-dark mb-1">클릭하여 새 사진 업로드</span>
                          <span className="text-muted" style={{ fontSize: '12px' }}>
                            사진을 새로 올리면 기존 사진은 모두 지워지고 새 사진으로 교체됩니다.
                          </span>
                        </label>
                        <input
                          id="warehouse-image-upload"
                          type="file"
                          accept="image/*"
                          multiple
                          onChange={handleImageUpload}
                          className="d-none"
                        />

                        {previews.length > 0 && (
                          <div className="row g-2 mt-3">
                            {previews.map((src, idx) => (
                              <div key={idx} className="col-auto">
                                <div
                                  className="position-relative rounded-2 overflow-hidden border"
                                  style={{ width: '80px', height: '80px' }}
                                >
                                  <img
                                    src={src}
                                    alt={`preview-${idx}`}
                                    className="w-100 h-100"
                                    style={{ objectFit: 'cover' }}
                                  />
                                  {idx === 0 && (
                                    <span
                                      className="position-absolute bottom-0 start-0 w-100 text-center bg-dark bg-opacity-75 text-white"
                                      style={{ fontSize: '10px', padding: '2px 0' }}
                                    >
                                      대표
                                    </span>
                                  )}

                                  {images.length > 0 && (
                                    <button
                                      type="button"
                                      onClick={() => handleRemoveImage(idx)}
                                      className="position-absolute top-0 end-0 m-1 btn btn-danger d-flex align-items-center justify-content-center rounded-circle"
                                      style={{
                                        width: '20px',
                                        height: '20px',
                                        padding: '0',
                                        fontSize: '12px',
                                      }}
                                    >
                                      <X size={12} />
                                    </button>
                                  )}
                                </div>
                              </div>
                            ))}
                          </div>
                        )}
                      </div>
                    </div>
                  </div>
                </div>

                <div className="d-flex justify-content-end gap-3 pt-3">
                  <button
                    type="button"
                    className="btn btn-light px-4 fw-bold text-secondary border"
                    onClick={() => navigate(-1)}
                  >
                    취소
                  </button>
                  <button
                    type="submit"
                    disabled={isSubmitting}
                    className="btn btn-primary px-5 fw-bold shadow-sm"
                  >
                    {isSubmitting ? (
                      <>
                        <span className="spinner-border spinner-border-sm me-2" />
                        저장 중...
                      </>
                    ) : (
                      '수정 완료'
                    )}
                  </button>
                </div>
              </form>
            </div>
          </div>
        </div>
      </main>

      <Footer />
    </div>
  );
}

export default WarehouseEdit;
