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

export const apiLogin = async (userId, userPw) => {
  try {
    const res = await api.post(`/auth/login`, { userId, userPw });
    return res.data;
  } catch (err) {
    throw err.response?.data || '아이디 또는 비밀번호가 틀렸습니다.';
  }
};

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

export const fetchWarehouses = async () => {
  try {
    const res = await api.get('/warehouse');
    return res.data;
  } catch (err) {
    throw err.response?.data || '창고 정보를 불러오는데 실패했습니다.';
  }
};

export const fetchWarehouseDetail = async (id) => {
  try {
    const res = await api.get(`/warehouse/${id}`);
    return res.data;
  } catch (err) {
    throw err.response?.data || '창고 상세 정보를 불러오는데 실패했습니다.';
  }
};

export const getMyInfo = async () => {
  try {
    const res = await api.get('/api/member/me');
    return res.data;
  } catch (err) {
    throw err.response?.data || '내 정보를 가져오는데 실패했습니다.';
  }
};

export const updateMemberInfo = async (data) => {
  try {
    const res = await api.put('/api/member/me', data);
    return res.data;
  } catch (err) {
    throw err.response?.data || '정보 수정에 실패했습니다.';
  }
};

export default api;
