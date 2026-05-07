import React, { useEffect, useRef } from 'react';

const NaverMapContainer = ({ warehouses, onMarkerClick }) => {
  const mapElement = useRef(null);
  const mapRef = useRef(null);
  const markersRef = useRef([]);
  const currentDataRef = useRef([]);

  useEffect(() => {
    if (!window.naver || !window.naver.maps) return;
    if (!mapRef.current && mapElement.current) {
      mapRef.current = new window.naver.maps.Map(mapElement.current, {
        center: new window.naver.maps.LatLng(35.1795543, 129.0756416),
        zoom: 12,
        // 지도 컨트롤 설정 (깔끔하게)
        logoControl: false,
        mapDataControl: false,
      });
    }
  }, []);

  useEffect(() => {
    if (!mapRef.current || !window.naver || !window.naver.maps) return;

    // 1. 기존 마커 및 정보창 제거
    markersRef.current.forEach((marker) => marker.setMap(null));
    markersRef.current = [];
    currentDataRef.current = warehouses;

    if (!warehouses || warehouses.length === 0) return;

    const bounds = new window.naver.maps.LatLngBounds();
    let processedCount = 0;

    warehouses.forEach((item) => {
      window.naver.maps.Service.geocode({ query: item.address }, (status, response) => {
        if (currentDataRef.current !== warehouses) return;
        processedCount++;

        if (status === window.naver.maps.Service.Status.OK && response.v2.addresses[0]) {
          const result = response.v2.addresses[0];
          const coord = new window.naver.maps.LatLng(result.y, result.x);

          // 2. 심플한 기본 마커 생성
          const marker = new window.naver.maps.Marker({
            position: coord,
            map: mapRef.current,
            title: item.name, // 마우스 올리면 브라우저 기본 툴팁으로 이름 뜸
            animation: window.naver.maps.Animation.DROP,
            // 아이콘을 더 깔끔한 핀으로 변경 (옵션)
            icon: {
              content: `
                <div style="cursor:pointer;">
                    <div style="width:24px; height:24px; background:#0d6efd; border:2px solid #fff; border-radius:50% 50% 50% 0; transform:rotate(-45deg); box-shadow:0 2px 5px rgba(0,0,0,0.3);"></div>
                </div>`,
              anchor: new window.naver.maps.Point(12, 24),
            },
          });

          // 3. 상세 정보창(InfoWindow) 설정
          const infoWindow = new window.naver.maps.InfoWindow({
            content: `
              <div style="padding:12px; min-width:180px; border-radius:8px; font-family: sans-serif;">
                <div style="font-weight:bold; font-size:14px; margin-bottom:4px; color:#333;">${item.name}</div>
                <div style="font-size:12px; color:#666; margin-bottom:8px;">${item.address}</div>
                <div style="display:flex; gap:4px; margin-bottom:8px;">
                    <span style="background:#e7f1ff; color:#0d6efd; padding:2px 6px; border-radius:4px; font-size:10px;">${item.storageType}</span>
                    <span style="background:#f8f9fa; color:#666; padding:2px 6px; border-radius:4px; font-size:10px;">규모 ${item.sizeRank}</span>
                </div>
                <button id="info-btn-${item.warehouseId}" style="width:100%; border:none; background:#0d6efd; color:white; padding:6px; border-radius:4px; font-size:12px; cursor:pointer;">
                    상세보기
                </button>
              </div>`,
            backgroundColor: '#fff',
            borderWidth: 0,
            disableAnchor: false,
            pixelOffset: new window.naver.maps.Size(0, -10),
          });

          // [이벤트 1] 마우스 올리면(mouseover) 정보창 열기
          window.naver.maps.Event.addListener(marker, 'mouseover', () => {
            infoWindow.open(mapRef.current, marker);

            // 버튼 클릭 이벤트 바인딩 (setTimeout으로 렌더링 대기)
            setTimeout(() => {
              const btn = document.getElementById(`info-btn-${item.warehouseId}`);
              if (btn && onMarkerClick) {
                btn.onclick = () => onMarkerClick(item.warehouseId);
              }
            }, 100);
          });

          // [이벤트 2] 마우스 나가면(mouseout) 정보창 닫기 (원치 않으면 삭제 가능)
          // window.naver.maps.Event.addListener(marker, 'mouseout', () => {
          //   infoWindow.close();
          // });

          // [이벤트 3] 클릭 시 상세 페이지로 바로 이동
          window.naver.maps.Event.addListener(marker, 'click', () => {
            if (onMarkerClick) onMarkerClick(item.warehouseId);
          });

          bounds.extend(coord);
          markersRef.current.push(marker);
        }

        if (processedCount === warehouses.length && !bounds.isEmpty()) {
          mapRef.current.panToBounds(bounds);
        }
      });
    });
  }, [warehouses, onMarkerClick]);

  return <div ref={mapElement} style={{ width: '100%', height: '100%' }} className="rounded-4" />;
};

export default NaverMapContainer;
