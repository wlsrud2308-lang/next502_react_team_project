import { useEffect, useState } from 'react';
import { useNavigate, useLocation } from 'react-router-dom';
import { useAuth } from '../../context/AuthContext';

import LoginModal from '../auth/LoginModal';
import SignupModal from '../auth/SignupModal';

function Header() {
  const navigate = useNavigate();
  const location = useLocation();
  const { isLoggedIn, logout } = useAuth();

  const [activeMenu, setActiveMenu] = useState(null);
  const [isScrolled, setIsScrolled] = useState(false);

  // 모달 상태 관리 추가
  const [isLoginOpen, setIsLoginOpen] = useState(false);
  const [isSignupOpen, setIsSignupOpen] = useState(false);

  const isMainPage = location.pathname === '/';

  const menuData = [
    {
      title: '창고이음 소개',
      items: [
        { name: '창고이음이란?', link: '#' },
        { name: '창고이음 이용안내', link: '#' },
      ],
    },
    {
      title: '창고 등록·이용',
      items: [
        { name: '창고 이용', link: '/warehouse/list' },
        { name: '창고 등록', link: '/warehouse/insert' },
      ],
    },
    {
      title: '창고 검색',
      items: [{ name: '창고 검색', link: '/search' }],
    },
    {
      title: '커뮤니티',
      items: [
        { name: '공지사항', link: '/community/notice' },
        { name: '자주 하는 질문', link: '/community/faq' },
        { name: '묻고 답하기', link: '/community/qna' },
        { name: '물류뉴스', link: '/community/news' },
      ],
    },
  ];

  useEffect(() => {
    const handleScroll = () => {
      setIsScrolled(window.scrollY > 50);
    };
    window.addEventListener('scroll', handleScroll);
    return () => window.removeEventListener('scroll', handleScroll);
  }, []);

  const handleLogout = () => {
    logout();
    alert('로그아웃 되었습니다.');
    navigate('/');
  };

  const isWhiteStyle = !isMainPage || isScrolled;
  const navClass = isWhiteStyle ? 'bg-white shadow-sm' : 'bg-transparent';
  const textColor = isWhiteStyle ? 'text-dark' : 'text-white';
  const logoImg = isWhiteStyle ? '/logo.png' : '/logo_white.png';
  const btnClass = isWhiteStyle ? 'btn-outline-primary' : 'btn-outline-light';

  return (
    <>
      <nav
        className={`fixed-top py-2 ${navClass}`}
        style={{ transition: 'all 0.3s ease', zIndex: 1000 }}
      >
        <div className="container d-flex align-items-center justify-content-between">
          <div
            className="navbar-brand m-0 p-0 d-flex align-items-center"
            style={{ cursor: 'pointer' }}
            onClick={() => navigate('/')}
          >
            <img
              src={logoImg}
              alt="창고이음 로고"
              style={{
                width: isWhiteStyle ? '200px' : '150px',
                height: 'auto',
                transition: 'all 0.3s ease',
              }}
            />
          </div>

          <ul className="nav d-none d-lg-flex">
            {menuData.map((menu, idx) => (
              <li
                key={idx}
                className="nav-item position-relative mx-2"
                onMouseEnter={() => setActiveMenu(idx)}
                onMouseLeave={() => setActiveMenu(null)}
              >
                <span
                  className={`nav-link fw-bold px-3 py-3 ${textColor}`}
                  style={{ cursor: 'pointer' }}
                  onClick={() => {
                    if (menu.title === '창고 검색') navigate('/search');
                    if (menu.title === '창고 등록·이용') navigate('/warehouse/list');
                  }}
                >
                  {menu.title}
                </span>

                <div
                  className={`dropdown-menu border-0 shadow-lg p-3 rounded-3 ${
                    activeMenu === idx ? 'show d-block' : 'd-none'
                  }`}
                  style={{
                    minWidth: '200px',
                    left: '50%',
                    transform: 'translateX(-50%)',
                    marginTop: '0',
                  }}
                >
                  {menu.items.map((item, i) => (
                    <button
                      key={i}
                      className="dropdown-item py-2 px-3 small border-0 bg-transparent"
                      onClick={() => {
                        if (item.link !== '#') {
                          navigate(item.link);
                          setActiveMenu(null);
                        }
                      }}
                    >
                      {item.name}
                    </button>
                  ))}
                </div>
              </li>
            ))}
          </ul>

          <div className="d-flex align-items-center gap-2">
            {isLoggedIn ? (
              <>
                <button
                  className={`btn btn-sm d-none d-md-block fw-bold px-3 rounded-pill ${btnClass}`}

                  onClick={() => navigate('/mypage')}
                >
                  내 정보
                </button>
                <button
                  className={`btn btn-sm d-none d-md-block fw-bold px-3 rounded-pill ${btnClass}`}
                  onClick={handleLogout}
                >
                  로그아웃
                </button>
              </>
            ) : (
              <>
                {/* 페이지 이동 대신 모달 열기 */}
                <button
                  className={`btn btn-sm d-none d-md-block fw-bold px-3 rounded-pill ${btnClass}`}
                  onClick={() => setIsLoginOpen(true)}
                >
                  로그인
                </button>
                <button
                  className={`btn btn-sm d-none d-md-block fw-bold px-3 rounded-pill ${btnClass} ms-1`}
                  onClick={() => setIsSignupOpen(true)}
                >
                  회원가입
                </button>
              </>
            )}
            <button className={`btn btn-sm border-0 d-lg-none ${textColor}`}>
              <span className="fs-3">☰</span>
            </button>
          </div>
        </div>
      </nav>

      {/* 로그인 모달 */}
      <LoginModal
        isOpen={isLoginOpen}
        onClose={() => setIsLoginOpen(false)}
        onSwitchToSignup={() => {
          setIsLoginOpen(false);
          setIsSignupOpen(true);
        }}
      />

      {/* 회원가입 모달 */}
      <SignupModal
        isOpen={isSignupOpen}
        onClose={() => setIsSignupOpen(false)}
        onSwitchToLogin={() => {
          setIsSignupOpen(false);
          setIsLoginOpen(true);
        }}
      />
    </>
  );
}

export default Header;
