import { useEffect, useState } from 'react';
import { useNavigate, useLocation } from 'react-router-dom';

function Header() {
  const navigate = useNavigate();
  const location = useLocation();

  const [activeMenu, setActiveMenu] = useState(null);
  const [isScrolled, setIsScrolled] = useState(false);

  const isMainPage = location.pathname === '/';

  // --- 메뉴 데이터 수정 (link 연결) ---
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
        // '창고 이용' 클릭 시 /warehouse/list로 이동하도록 설정
        { name: '창고 이용', link: '/warehouse/list' },
        { name: '창고 등록', link: '/warehouse/insert' }, // 나중에 등록 페이지 만들면 연결
      ],
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
      setIsScrolled(window.scrollY > 50);
    };
    window.addEventListener('scroll', handleScroll);
    return () => window.removeEventListener('scroll', handleScroll);
  }, []);

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
        {/* LOGO */}
        <div
          className="navbar-brand m-0 p-0 d-flex align-items-center"
          style={{ cursor: 'pointer' }}
          onClick={() => navigate('/')}
        >
          <img
            src={logoImg}
            alt="창고이음 로고"
            style={{
              width: isWhiteStyle ? '200px' : '150px', // 로고 크기 조정
              height: 'auto',
              transition: 'all 0.3s ease',
            }}
          />
        </div>

        {/* PC MENU */}
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
                  // 대메뉴 자체 클릭 시 이동 로직 (선택 사항)
                  if (menu.title === '창고 검색') navigate('/search');
                  if (menu.title === '창고 등록·이용') navigate('/warehouse/list');
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
                  <button // a태그 대신 button이나 navigate 활용 권장
                    key={i}
                    className="dropdown-item py-2 px-3 small border-0 bg-transparent"
                    onClick={() => {
                      if (item.link !== '#') {
                        navigate(item.link);
                        setActiveMenu(null); // 메뉴 닫기
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

        {/* RIGHT SIDE UTILS */}
        <div className="d-flex align-items-center gap-2">
          <button
            className={`btn btn-sm d-none d-md-block fw-bold px-3 rounded-pill ${btnClass}`}
            onClick={() => navigate('/login')}
          >
            로그인
          </button>
          <button className={`btn btn-sm border-0 d-lg-none ${textColor}`}>
            <span className="fs-3">☰</span>
          </button>
        </div>
      </div>
    </nav>
  );
}

export default Header;
