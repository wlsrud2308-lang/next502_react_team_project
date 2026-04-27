import axios from 'axios';


const apiLogin = (userId, userPw) => {
  axios
    .get(`http://localhost:8080/auth/login`, {
      params: {
        userId: userId,
        userPw: userPw,
      },
    })
    .then((res) => {
      alert('로그인');
      localStorage.setItem('ACCESS_TOKEN', res.data.accessToken);
      sessionStorage.setItem('REFRESH_TOKEN', res.data.refreshToken);
      window.location.href = '/';
    })
    .catch((err) => {
      alert(`로그인 중 오류가 발생했습니다. \n${err}`);
    });
};


export { apiLogin };