import axios from 'axios';

const api = axios.create({
  baseURL: 'http://localhost:8080',
});

// 1. 로그인 함수 (async/await 스타일로 통일 권장)
export const apiLogin = async (userId, userPw) => {
  try {
    const res = await api.get(`/auth/login`, {
      params: { userId, userPw },
    });
    alert('로그인 성공');
    localStorage.setItem('ACCESS_TOKEN', res.data.accessToken);
    sessionStorage.setItem('REFRESH_TOKEN', res.data.refreshToken);
    window.location.href = '/';
  } catch (err) {
    alert(`로그인 중 오류 발생: \n${err.response?.data || err.message}`);
  }
};

// 2. 창고 검색 함수
export const fetchWarehouses = async (location, size, name, token) => {
  try {
    const response = await api.get('/warehouse/search', {
      params: { location, size, name },
      headers: { Authorization: `Bearer ${token}` },
    });
    return response.data;
  } catch (error) {
    console.error('창고 검색 오류:', error);
    throw error;
  }
};

// ★ 3. 창고 상세 정보 가져오기 (상세 페이지 연동용) ★
export const fetchWarehouseDetail = async (id, token) => {
  try {
    const response = await api.get(`/warehouse/${id}`, {
      headers: { Authorization: `Bearer ${token}` },
    });
    return response.data;
  } catch (error) {
    console.error('상세 정보 호출 오류:', error);
    throw error;
  }
};
