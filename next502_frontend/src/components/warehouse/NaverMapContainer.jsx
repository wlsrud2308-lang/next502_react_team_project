import React from 'react';
import { Container as MapDiv, NaverMap, Marker } from 'react-naver-maps';

const NaverMapContainer = () => {
  return (
    <div style={{ width: '100%', height: '100%' }}>
      <MapDiv
        style={{
          width: '100%',
          height: '100%',
        }}
      >
        <NaverMap defaultCenter={{ lat: 37.5665, lng: 126.978 }} defaultZoom={15}>
          <Marker position={{ lat: 37.5665, lng: 126.978 }} />
        </NaverMap>
      </MapDiv>
    </div>
  );
};

export default NaverMapContainer;
