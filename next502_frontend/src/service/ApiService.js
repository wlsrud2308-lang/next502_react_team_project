import axios from 'axios';

const api = axios.create({
  baseURL: 'http://localhost:8080',
  headers: {
    'Content-Type': 'application/json',
  },
});

api.interceptors.request.use((config) => {
  const token = localStorage.getItem('ACCESS_TOKEN');
  if (token) {
    config.headers.Authorization = `Bearer ${token}`;
  }
  return config;
});

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
    const res = await api.post('/auth/kakao', {
      accessToken,
      kakaoId,
      nickname,
    });
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
      if (typeof err.response.data === 'string') {
        throw err.response.data;
      }
      throw err.response.data.message || err.response.data.error || '회원가입에 실패했습니다.';
    }
    throw '서버와 통신할 수 없습니다.';
  }
};

// 사업자등록증 OCR
export const uploadBusinessLicense = async (imageFile) => {
  try {
    const formData = new FormData();
    formData.append('file', imageFile);

    const res = await api.post('/ocr/business-license', formData, {
      headers: {
        'Content-Type': 'multipart/form-data',
      },
      timeout: 60000,
    });
    return res.data;
  } catch (err) {
    throw err.response?.data?.message || err.response?.data?.error || 'OCR 분석에 실패했습니다.';
  }
};

// 창고 목록 조회 (컨트롤러 /search 경로에 맞춤)
export const fetchWarehouses = async () => {
  try {
    const res = await api.get('/warehouse/search');
    return res.data;
  } catch (err) {
    throw err.response?.data || '창고 정보를 불러오는데 실패했습니다.';
  }
};

// 창고 상세 조회
export const fetchWarehouseDetail = async (id) => {
  try {
    const res = await api.get(`/warehouse/${id}`);
    return res.data;
  } catch (err) {
    throw err.response?.data || '창고 상세 정보를 불러오는데 실패했습니다.';
  }
};

// 창고 등록
export const apiInsertWarehouse = async (warehouseData) => {
  try {
    const res = await api.post('/warehouse/insert', warehouseData);
    return res.data;
  } catch (err) {
    throw err.response?.data || '창고 등록에 실패했습니다.';
  }
};

// 내 정보 조회
export const getMyInfo = async () => {
  try {
    const res = await api.get('/api/member/me');
    return res.data;
  } catch (err) {
    throw err.response?.data || '내 정보를 가져오는데 실패했습니다.';
  }
};

// 회원 정보 수정
export const updateMemberInfo = async (data) => {
  try {
    const res = await api.put('/api/member/me', data);
    return res.data;
  } catch (err) {
    throw err.response?.data || '정보 수정에 실패했습니다.';
  }
};

export default api;
