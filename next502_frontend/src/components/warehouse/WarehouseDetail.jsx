import React, { useState, useEffect } from 'react';
import axios from 'axios';
import { useParams } from 'react-router-dom';
import { Container, Row, Col, Badge, Card, Button, Spinner, Carousel } from 'react-bootstrap';
import { fetchWarehouseDetail, toggleFavorite } from '../../service/ApiService';
import { MapPin, Box, Maximize, Info, Phone, Clock, ShieldCheck, Activity } from 'lucide-react';
import Header from '../layout/Header.jsx';
import Footer from '../layout/Footer.jsx';
import FloatingChatBar from '../chat/FloatingChatBar';
import './WarehouseDetail.css';
import WarehouseModel from '../../assets/warehouse-model.png';

const API_BASE_URL = 'http://localhost:8080';

const WarehouseDetail = () => {
  const { id } = useParams();
  const [warehouse, setWarehouse] = useState(null);
  const [loading, setLoading] = useState(true);

  const [isChatOpen, setIsChatOpen] = useState(false);
  const [selectedChatRoom, setSelectedChatRoom] = useState(null);
  const [isFavorite, setIsFavorite] = useState(false);

  useEffect(() => {
    const loadDetail = async () => {
      try {
        const token = localStorage.getItem('ACCESS_TOKEN');
        const data = await fetchWarehouseDetail(id, token);
        setWarehouse(data);
        setIsFavorite(data.isFavorite === true);
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
      const response = await axios.post(
        `${API_BASE_URL}/chat/room/${id}`,
        {},
        { headers: { Authorization: `Bearer ${token}` } },
      );
      setSelectedChatRoom(response.data);
      setIsChatOpen(true);
    } catch (error) {
      console.error('채팅방 연결 실패:', error);
      alert('로그인이 필요하거나 채팅방을 열 수 없습니다.');
    }
  };

  const handleFavoriteToggle = async () => {
    try {
      await toggleFavorite(id);
      setIsFavorite(!isFavorite);
    } catch (error) {
      console.error('찜하기 실패:', error);
      alert('찜하기 처리에 실패했습니다. 로그인 상태를 확인해주세요.');
    }
  };

  const getImageUrl = (url) => {
    if (!url) return 'https://via.placeholder.com/800x500?text=No+Image';
    if (url.startsWith('http')) return url;
    return `${API_BASE_URL}${url.startsWith('/') ? '' : '/'}${url}`;
  };

  if (loading)
    return (
      <div className="d-flex justify-content-center align-items-center" style={{ height: '100vh' }}>
        <Spinner animation="border" variant="primary" />
      </div>
    );

  if (!warehouse) return <div className="text-center p-5">창고 정보를 찾을 수 없습니다.</div>;

  const usageRate = warehouse.usageRate || 0;
  const imageList = warehouse.images || warehouse.imageUrls || [];

  return (
    <div className="bg-light" style={{ minHeight: '100vh' }}>
      <Header />

      <Container className="pt-5 mt-5 pb-5">
        <div className="mb-4 bg-white p-4 rounded-4 fidelity-card border-0">
          <div className="d-flex justify-content-between align-items-start">
            <div>
              <div className="d-flex align-items-center gap-2 mb-2">
                <Badge className="px-3 py-2 fidelity-badge text-white">
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

            <Button
              variant={isFavorite ? 'danger' : 'light'}
              className="rounded-circle d-flex justify-content-center align-items-center shadow-sm border border-2"
              style={{ width: '60px', height: '60px', fontSize: '1.8rem', transition: 'all 0.3s' }}
              onClick={handleFavoriteToggle}
            >
              {isFavorite ? '❤️' : '🤍'}
            </Button>
          </div>
        </div>

        <Row className="g-4">
          <Col lg={8}>
            <Card className="border-0 shadow-sm rounded-4 overflow-hidden mb-4">
              {imageList.length > 0 ? (
                <Carousel interval={null} variant="dark">
                  {imageList.map((imgUrl, index) => (
                    <Carousel.Item key={index}>
                      <img
                        className="d-block w-100"
                        src={getImageUrl(imgUrl)}
                        alt={`창고 이미지 ${index + 1}`}
                        style={{ height: '450px', objectFit: 'cover' }}
                      />
                    </Carousel.Item>
                  ))}
                </Carousel>
              ) : (
                <Card.Img
                  variant="top"
                  src={getImageUrl(warehouse.repImageUrl)}
                  style={{ height: '450px', objectFit: 'cover' }}
                />
              )}
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

          <Col lg={4}>
            <div className="sticky-top" style={{ top: '120px' }}>
              <Card className="border-0 rounded-4 p-4 mb-4 fidelity-card bg-white">
                <h4 className="fw-bold mb-4 border-bottom pb-2">창고 제원 요약</h4>

                <div className="d-flex justify-content-between mb-3 border-bottom pb-2">
                  <span className="text-secondary">
                    <Maximize size={18} className="me-2" /> 총 면적
                  </span>
                  <span className="fw-bold text-dark">{warehouse.totalArea} ㎡</span>
                </div>

                <div className="d-flex justify-content-between mb-3 border-bottom pb-2">
                  <span className="text-secondary">
                    <Box size={18} className="me-2" /> 보관 유형
                  </span>
                  <span className="fw-bold text-dark">{warehouse.storageType}</span>
                </div>

                <div className="d-flex justify-content-between mb-4 border-bottom pb-2">
                  <span className="text-secondary">
                    <ShieldCheck size={18} className="me-2" /> 운영 구조
                  </span>
                  <span className="fw-bold text-dark text-truncate" style={{ maxWidth: '150px' }}>
                    {warehouse.operationStructure}
                  </span>
                </div>

                <div className="mb-4 p-4 rounded-4 fidelity-usage-area bg-light">
                  <div className="d-flex justify-content-between mb-3 fw-bold">
                    <span className="text-secondary d-flex align-items-center">
                      <Activity size={18} className="me-2 text-primary" /> 실시간 가동률
                    </span>
                    <span className="fw-bold text-primary fs-5">{usageRate}%</span>
                  </div>

                  <div className="d-flex align-items-center gap-3">

                    <div
                      className="position-relative fidelity-mask-wrapper"
                      style={{
                        width: '110px',
                        height: '145px',
                        flexShrink: 0,
                      }}
                    >
                      <img
                        src={WarehouseModel}
                        alt="창고 모형"
                        className="w-100 h-100 position-absolute top-0 start-0 fidelity-mask-bg"
                        style={{ objectFit: 'contain' }}
                      />
                      <div className="fidelity-mask-water-container w-100 h-100 position-absolute bottom-0 start-0">
                        <div
                          className="fidelity-water-gauge position-absolute bottom-0 start-0 w-100"
                          style={{
                            height: `${usageRate}%`,
                          }}
                        />
                      </div>
                      <span
                        className="position-absolute top-50 start-50 translate-middle fw-bold fs-6 text-dark"
                        style={{ textShadow: '1px 1px 0 #fff' }}
                      >
                        {usageRate}%
                      </span>
                    </div>


                    <div className="flex-grow-1 text-end">
                      <div className="fs-6 fw-bold text-dark mb-1">현재 사용 중</div>
                      <div className="fs-5 fw-bold text-primary">
                        {warehouse.occupiedArea?.toLocaleString() || 0} ㎡
                      </div>
                      <div className="text-muted small">
                        / 전체 {warehouse.totalArea?.toLocaleString() || 0} ㎡
                      </div>
                    </div>
                  </div>
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

              <Card className="border-0 shadow-sm rounded-4 p-4 bg-dark text-white">
                <h5 className="fw-bold mb-3 d-flex align-items-center">
                  <Clock size={20} className="me-2 text-warning" /> 편의시설 및 서비스
                </h5>
                <div className="d-flex flex-wrap gap-2">
                  {warehouse.amenities
                    ? warehouse.amenities.split(',').map((tag, idx) => (
                        <Badge key={idx} bg="secondary" className="fw-normal px-2 py-1 fs-6">
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