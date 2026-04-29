import { useEffect, useState } from 'react';
import { useNavigate, useLocation } from 'react-router-dom';

function Header() {
  const navigate = useNavigate();
  const location = useLocation(); // 현재 경로 파악을 위한 훅

  const [activeMenu, setActiveMenu] = useState(null);
  const [isScrolled, setIsScrolled] = useState(false);

  // 현재 페이지가 메인 페이지('/')인지 확인하는 변수
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
      items: [{ name: '창고 이용', link: '#' }],
    },
    {
      title: '창고 검색',
      items: [{ name: '창고 검색', link: '/search' }],
    },
    {
      title: '커뮤니티',
      items: [
        { name: '공지사항', link: '#' },
        { name: '자주 하는 질문', link: '#' },
        { name: '묻고 답하기', link: '#' },
        { name: '물류뉴스', link: '#' },
      ],
    },
  ];

  useEffect(() => {
    const handleScroll = () => {
      // 스크롤 50px 이상 여부 체크
      setIsScrolled(window.scrollY > 50);
    };

    window.addEventListener('scroll', handleScroll);
    return () => window.removeEventListener('scroll', handleScroll);
  }, []);

  // --- 스타일 분기 조건 ---
  // 메인이 아니거나, 메인이면서 스크롤된 경우 => '흰색 배경 스타일' 적용
  const isWhiteStyle = !isMainPage || isScrolled;

  const navClass = isWhiteStyle ? 'bg-white shadow-sm' : 'bg-transparent';
  const textColor = isWhiteStyle ? 'text-dark' : 'text-white';
  const logoImg = isWhiteStyle ? '/logo.png' : '/logo_white.png';
  const btnClass = isWhiteStyle ? 'btn-outline-primary' : 'btn-outline-light';

  return (
    <nav
      className={`fixed-top py-2 ${navClass}`}
      style={{ transition: 'all 0.3s ease', zIndex: 1000 }}
    >
      <div className="container d-flex align-items-center justify-content-between">
        {/* ================= LOGO & DYNAMIC TEXT ================= */}
        <div
          className="navbar-brand m-0 p-0 d-flex align-items-center"
          style={{ cursor: 'pointer' }}
          onClick={() => navigate('/')}
        >
          <img
            src={logoImg}
            alt="창고이음 로고"
            style={{
              width: isWhiteStyle ? '225px' : '120px',
              height: 'auto',
              transition: 'all 0.3s ease',
            }}
          />

          {/* 메인 페이지이면서 스크롤되지 않았을 때만 브랜드 텍스트 노출 (선택 사항) */}
          {!isWhiteStyle && (
            <div className="ms-2 d-flex flex-column" style={{ lineHeight: '1.1' }}>
              <span className="fw-bold fs-5 text-white">창고이음</span>
            </div>
          )}
        </div>

        {/* ================= PC MENU ================= */}
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
                }}
              >
                {menu.title}
              </span>

              {/* 2차 메뉴 드롭다운 */}
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
                  <a
                    key={i}
                    href={item.link}
                    className="dropdown-item py-2 px-3 small"
                    onClick={(e) => {
                      if (item.link.startsWith('/')) {
                        e.preventDefault();
                        navigate(item.link);
                      }
                    }}
                  >
                    {item.name}
                  </a>
                ))}
              </div>
            </li>
          ))}
        </ul>

        {/* ================= RIGHT SIDE UTILS ================= */}
        <div className="d-flex align-items-center gap-2">
          <button
            className={`btn btn-sm d-none d-md-block fw-bold px-3 rounded-pill ${btnClass}`}
          >
            로그인
          </button>
          <button
            className={`btn btn-sm border-0 d-lg-none ${textColor}`}
          >
            <span className="fs-3">☰</span>
          </button>
        </div>
      </div>
    </nav>
  );
}

export default Header;