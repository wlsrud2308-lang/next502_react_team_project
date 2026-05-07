import axios from 'axios';

const api = axios.create({
  baseURL: 'http://localhost:8080',
  headers: {
    'Content-Type': 'application/json',
  },
});

// 요청 인터셉터: 로컬 스토리지에서 토큰을 꺼내 헤더에 주입
api.interceptors.request.use((config) => {
  const token = localStorage.getItem('ACCESS_TOKEN');
  if (token) {
    config.headers.Authorization = `Bearer ${token}`;
  }
  return config;
});

// ==========================================
// 1. 인증 관련 API (Login, Signup, Find)
// ==========================================

// 로그인
export const apiLogin = async (userId, userPw) => {
  try {
    const res = await api.post(`/auth/login`, { userId, userPw });
    return res.data;
  } catch (err) {
    throw err.response?.data || '아이디 또는 비밀번호가 틀렸습니다.';
  }
};

// 카카오 로그인
export const loginWithKakao = async (accessToken, kakaoId, nickname) => {
  try {
    const res = await api.post('/auth/kakao', { accessToken, kakaoId, nickname });
    return res.data;
  } catch (err) {
    throw err.response?.data || '카카오 로그인에 실패했습니다.';
  }
};

// 회원가입
export const apiSignup = async (userData) => {
  try {
    const res = await api.post(`/auth/signup`, userData);
    return res.data;
  } catch (err) {
    if (err.response && err.response.data) {
      if (typeof err.response.data === 'string') throw err.response.data;
      throw err.response.data.message || err.response.data.error || '회원가입 실패';
    }
    throw '서버 통신 실패';
  }
};

// 아이디 찾기
export const apiFindId = async (name, tel) => {
  try {
    const res = await api.post('/auth/find-id', { name, tel });
    return res.data;
  } catch (err) {
    throw err.response?.data || '일치하는 정보가 없습니다.';
  }
};

// 비밀번호 찾기 (사용자 확인)
export const apiFindPw = async (userId, name, tel) => {
  try {
    const res = await api.post('/auth/find-pw', { userId, name, tel });
    return res.data;
  } catch (err) {
    throw err.response?.data || '입력한 정보가 올바르지 않습니다.';
  }
};

// 비밀번호 재설정
export const apiResetPw = async (userId, newUserPw) => {
  try {
    const res = await api.put('/auth/reset-pw', { userId, newUserPw });
    return res.data;
  } catch (err) {
    throw err.response?.data || '비밀번호 재설정에 실패했습니다.';
  }
};

// ==========================================
// 2. 창고 관련 API (Search, Detail, Insert)
// ==========================================

/**
 * 창고 목록 조회 (필터링 지원)
 * @param {string} location - 구 단위 지역 (예: '강서구')
 * @param {string} type - 창고 유형 (예: '보통창고')
 * @param {string} name - 검색 키워드 (창고명)
 */
export const fetchWarehouses = async (location = '', type = '', name = '') => {
  try {
    const res = await api.get('/warehouse/search', {
      params: {
        location: location,
        type: type,
        name: name,
      },
    });
    return res.data;
  } catch (err) {
    throw err.response?.data || '창고 조회 실패';
  }
};

// 창고 상세 조회
export const fetchWarehouseDetail = async (id) => {
  try {
    const res = await api.get(`/warehouse/${id}`);
    return res.data;
  } catch (err) {
    throw err.response?.data || '상세 조회 실패';
  }
};

// 창고 등록
export const insertWarehouse = async (warehouseData, imageFiles) => {
  try {
    const formData = new FormData();
    formData.append(
      'data',
      new Blob([JSON.stringify(warehouseData)], { type: 'application/json' }),
    );
    imageFiles.forEach((file) => {
      formData.append('images', file);
    });

    const res = await api.post('/warehouse/insert', formData, {
      headers: { 'Content-Type': 'multipart/form-data' },
      timeout: 60000,
    });
    return res.data;
  } catch (err) {
    if (err.response?.data) {
      throw typeof err.response.data === 'string'
        ? err.response.data
        : err.response.data.message || '창고 등록 실패';
    }
    throw '서버 통신 실패';
  }
};

// 내가 등록한 창고 목록 조회
export const getMyWarehouseList = async () => {
  try {
    const res = await api.get('/warehouse/my-list');
    return res.data;
  } catch (err) {
    throw err.response?.data || '내 창고 목록 로드 실패';
  }
};

// ==========================================
// 3. 회원 정보 및 기타 (OCR, Favorites)
// ==========================================

// 내 정보 조회
export const getMyInfo = async () => {
  try {
    const res = await api.get('/api/member/me');
    return res.data;
  } catch (err) {
    throw err.response?.data || '내 정보 조회 실패';
  }
};

// 회원 정보 수정
export const updateMemberInfo = async (data) => {
  try {
    const res = await api.put('/api/member/me', data);
    return res.data;
  } catch (err) {
    throw err.response?.data || '수정 실패';
  }
};

// 사업자등록증 OCR
export const uploadBusinessLicense = async (imageFile) => {
  try {
    const formData = new FormData();
    formData.append('file', imageFile);
    const res = await api.post('/ocr/business-license', formData, {
      headers: { 'Content-Type': 'multipart/form-data' },
      timeout: 60000,
    });
    return res.data;
  } catch (err) {
    throw err.response?.data?.message || 'OCR 분석 실패';
  }
};

// 찜 목록 조회
export const getFavoriteList = async () => {
  try {
    const res = await api.get('/favorite/list');
    return res.data;
  } catch (err) {
    throw err.response?.data || '찜 목록 로드 실패';
  }
};

// 찜하기 토글
export const toggleFavorite = async (whId) => {
  try {
    const res = await api.post(`/favorite/${whId}`);
    return res.data;
  } catch (err) {
    throw err.response?.data || '찜하기 처리 실패';
  }
};

export default api;
