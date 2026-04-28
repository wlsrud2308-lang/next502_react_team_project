import axios from 'axios';

// 1. 로그인 함수 (앞에 export를 바로 붙여주세요)
export const apiLogin = (userId, userPw) => {
  axios
    .get(`http://localhost:8080/auth/login`, {
      params: { userId, userPw },
    })
    .then((res) => {
      alert('로그인 성공');
      localStorage.setItem('ACCESS_TOKEN', res.data.accessToken);
      sessionStorage.setItem('REFRESH_TOKEN', res.data.refreshToken);
      window.location.href = '/';
    })
    .catch((err) => {
      alert(`로그인 중 오류 발생: \n${err}`);
    });
};

const api = axios.create({
  baseURL: 'http://localhost:8080',
});

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
