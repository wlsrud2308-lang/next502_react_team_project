import { useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom'; // 1. useNavigate 임포트

function Header() {
  const navigate = useNavigate(); // 2. navigate 함수 선언
  const [activeMenu, setActiveMenu] = useState(null);
  const [isScrolled, setIsScrolled] = useState(false);

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
      items: [{ name: '창고 검색', link: '/search' }], // 링크를 검색 경로로 설정
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
      setIsScrolled(window.scrollY > 50);
    };
    window.addEventListener('scroll', handleScroll);
    return () => window.removeEventListener('scroll', handleScroll);
  }, []);

  return (
    <nav
      className={`fixed-top py-2 ${isScrolled ? 'bg-white shadow-sm' : 'bg-transparent'}`}
      style={{ transition: 'all 0.3s ease', zIndex: 1000 }}
    >
      <div className="container d-flex align-items-center justify-content-between">
        {/* ================= LOGO & DYNAMIC TEXT (홈으로 이동) ================= */}
        <div
          className="navbar-brand m-0 p-0 d-flex align-items-center"
          style={{ cursor: 'pointer' }}
          onClick={() => navigate('/')} // 로고 클릭 시 홈 이동
        >
          <img
            src={isScrolled ? '/logo.png' : '/logo_white.png'}
            alt="창고이음 로고"
            style={{
              width: isScrolled ? '225px' : '120px',
              height: 'auto',
              transition: 'width 0.3s ease',
            }}
          />

          {!isScrolled && (
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
                className={`nav-link fw-bold px-3 py-3 ${isScrolled ? 'text-dark' : 'text-white'}`}
                style={{ cursor: 'pointer' }}
                onClick={() => {
                  // '창고 검색' 메뉴인 경우 바로 이동
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
                      // 내부 경로 이동을 위해 기본 링크 동작 방지 후 navigate 사용
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
            className={`btn btn-sm d-none d-md-block fw-bold px-3 rounded-pill ${
              isScrolled ? 'btn-outline-primary' : 'btn-outline-light'
            }`}
          >
            로그인
          </button>
          <button
            className={`btn btn-sm border-0 d-lg-none ${isScrolled ? 'text-dark' : 'text-white'}`}
          >
            <span className="fs-3">☰</span>
          </button>
        </div>
      </div>
    </nav>
  );
}

export default Header;
