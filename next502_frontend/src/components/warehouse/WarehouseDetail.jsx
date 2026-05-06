import React, { useState, useEffect } from 'react';
import axios from 'axios';
import { useParams } from 'react-router-dom';
import { Container, Row, Col, Badge, Card, Button, ProgressBar, Spinner } from 'react-bootstrap';
import { fetchWarehouseDetail } from '../../service/ApiService';
import { MapPin, Box, Maximize, Info, Phone, Clock, ShieldCheck } from 'lucide-react';
import Header from '../layout/Header.jsx';
import Footer from '../layout/Footer.jsx';
import FloatingChatBar from '../chat/FloatingChatBar';


const API_BASE_URL = 'http://localhost:8080';

const WarehouseDetail = () => {
  const { id } = useParams();
  const [warehouse, setWarehouse] = useState(null);
  const [loading, setLoading] = useState(true);

  const [isChatOpen, setIsChatOpen] = useState(false);
  const [selectedChatRoom, setSelectedChatRoom] = useState(null);

  useEffect(() => {
    const loadDetail = async () => {
      try {
        const token = localStorage.getItem('ACCESS_TOKEN');
        const data = await fetchWarehouseDetail(id, token);
        setWarehouse(data);
      } catch (error) {
        console.error('데이터 로딩 실패:', error);
      } finally {
        setLoading(false);
      }
    };
    loadDetail();
  }, [id]);

  const handleChatConnect = async () => {
    try {
      const token = localStorage.getItem('ACCESS_TOKEN');

      // 1. 백엔드(Spring Boot)에 채팅방 생성/조회 요청
      const response = await axios.post(
        `${API_BASE_URL}/chat/room/${id}`,
        {},
        {
          headers: { Authorization: `Bearer ${token}` },
        },
      );

      // 2. 받은 방 정보(chatRoomId 등) 저장
      setSelectedChatRoom(response.data);

      // 3. 플로팅 채팅바 열기
      setIsChatOpen(true);
    } catch (error) {
      console.error('채팅방 연결 실패:', error);
      alert('로그인이 필요하거나 채팅방을 열 수 없습니다.');
    }
  };

  // 이미지 URL 변환 헬퍼 함수
  const getImageUrl = (url) => {
    if (!url) return 'https://via.placeholder.com/800x500?text=No+Image';
    if (url.startsWith('http')) return url; // 더미 데이터 (Unsplash 등 절대 경로)
    return `${API_BASE_URL}${url.startsWith('/') ? '' : '/'}${url}`; // 로컬 업로드 파일 (8080 포트 매핑)
  };

  if (loading)
    return (
      <div className="d-flex justify-content-center align-items-center" style={{ height: '100vh' }}>
        <Spinner animation="border" variant="primary" />
      </div>
    );

  if (!warehouse) return <div className="text-center p-5">창고 정보를 찾을 수 없습니다.</div>;

  const usageRate = warehouse.usageRate || 0;

  return (
    <div className="bg-light" style={{ minHeight: '100vh' }}>
      <Header />

      <Container className="pt-5 mt-5 pb-5">
        {/* 상단 타이틀 섹션 */}
        <div className="mb-4 bg-white p-4 rounded-4 shadow-sm border-0">
          <div className="d-flex align-items-center gap-2 mb-2">
            <Badge bg="primary" className="px-3 py-2">
              규모 {warehouse.sizeRank}
            </Badge>
            <Badge bg="info" className="text-white px-3 py-2">
              {warehouse.storageType}
            </Badge>
          </div>
          <h1 className="display-5 fw-bold text-dark">{warehouse.name}</h1>
          <p className="text-secondary fs-5 mb-0">
            <MapPin size={20} className="me-2 text-danger" /> {warehouse.address}
          </p>
        </div>

        <Row className="g-4">
          {/* 왼쪽: 메인 컨텐츠 (이미지 및 상세설명) */}
          <Col lg={8}>
            <Card className="border-0 shadow-sm rounded-4 overflow-hidden mb-4">
              <Card.Img
                variant="top"
                src={getImageUrl(warehouse.repImageUrl)}
                style={{ height: '450px', objectFit: 'cover' }}
              />
              <Card.Body className="p-4">
                <h3 className="fw-bold mb-4 border-bottom pb-2">
                  <Info className="me-2 text-primary" /> 창고 상세 소개
                </h3>
                <p className="text-muted fs-5 leading-relaxed" style={{ whiteSpace: 'pre-wrap' }}>
                  {warehouse.description || '등록된 상세 정보가 없습니다.'}
                </p>
              </Card.Body>
            </Card>
          </Col>

          {/* 오른쪽: 사이드바 (요약 정보 및 액션 버튼) */}
          <Col lg={4}>
            <div className="sticky-top" style={{ top: '120px' }}>
              <Card className="border-0 shadow-sm rounded-4 p-4 mb-4 bg-white">
                <h4 className="fw-bold mb-4">창고 제원 요약</h4>

                <div className="d-flex justify-content-between mb-3 border-bottom pb-2">
                  <span className="text-secondary">
                    <Maximize size={18} className="me-2" /> 총 면적
                  </span>
                  <span className="fw-bold">{warehouse.totalArea}㎡</span>
                </div>

                <div className="d-flex justify-content-between mb-3 border-bottom pb-2">
                  <span className="text-secondary">
                    <Box size={18} className="me-2" /> 보관 유형
                  </span>
                  <span className="fw-bold">{warehouse.storageType}</span>
                </div>

                <div className="d-flex justify-content-between mb-4 border-bottom pb-2">
                  <span className="text-secondary">
                    <ShieldCheck size={18} className="me-2" /> 운영 구조
                  </span>
                  <span className="fw-bold text-truncate" style={{ maxWidth: '150px' }}>
                    {warehouse.operationStructure}
                  </span>
                </div>

                {/* 사용률 섹션 */}
                <div className="mb-4">
                  <div className="d-flex justify-content-between mb-1 small fw-bold">
                    <span>현재 창고 사용률</span>
                    <span className="text-primary">{usageRate}%</span>
                  </div>
                  <ProgressBar
                    now={usageRate}
                    variant={usageRate > 80 ? 'danger' : 'primary'}
                    style={{ height: '10px' }}
                    animated
                  />
                </div>

                <Button
                  variant="primary"
                  size="lg"
                  className="w-100 fw-bold py-3 rounded-3 shadow-sm mb-3"
                  onClick={handleChatConnect}
                >
                  <Phone className="me-2" size={20} /> 채팅으로 문의하기
                </Button>
              </Card>

              {/* 편의시설 카드 */}
              <Card className="border-0 shadow-sm rounded-4 p-4 bg-dark text-white">
                <h5 className="fw-bold mb-3">
                  <Clock size={18} className="me-2 text-warning" /> 편의시설
                </h5>
                <div className="d-flex flex-wrap gap-2">
                  {warehouse.amenities
                    ? warehouse.amenities.split(',').map((tag, idx) => (
                        <Badge key={idx} bg="secondary" className="fw-normal px-2 py-1">
                          {tag.trim()}
                        </Badge>
                      ))
                    : '정보 없음'}
                </div>
              </Card>
            </div>
          </Col>
        </Row>
      </Container>
      <FloatingChatBar
        isOpen={isChatOpen}
        setIsOpen={setIsChatOpen}
        warehouseName={warehouse.name}
        initialRoom={selectedChatRoom}
      />
      <Footer />
    </div>
  );
};

export default WarehouseDetail;
