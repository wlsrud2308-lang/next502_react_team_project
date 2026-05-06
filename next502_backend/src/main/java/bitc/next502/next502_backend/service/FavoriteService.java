package bitc.next502.next502_backend.service;

import bitc.next502.next502_backend.domain.entity.FavoriteEntity;
import bitc.next502.next502_backend.domain.entity.MemberEntity;
import bitc.next502.next502_backend.domain.entity.WarehouseEntity;
import bitc.next502.next502_backend.domain.repository.FavoriteRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class FavoriteService {

    private final FavoriteRepository favoriteRepository;

    @Transactional
    public String toggleFavorite(MemberEntity member, WarehouseEntity warehouse) {
        Optional<FavoriteEntity> favorite = favoriteRepository.findByMemberAndWarehouse(member, warehouse);

        if (favorite.isPresent()) {
            favoriteRepository.delete(favorite.get());
            return "찜 취소";
        } else {
            FavoriteEntity newFavorite = FavoriteEntity.builder()
                    .member(member)
                    .warehouse(warehouse)
                    .build();
            favoriteRepository.save(newFavorite);
            return "찜 등록";
        }
    }


    @Transactional(readOnly = true)
    public List<Map<String, Object>> getFavoriteList(MemberEntity member) {
        List<FavoriteEntity> favorites = favoriteRepository.findByMember(member);

        return favorites.stream()
                .map(favorite -> {
                    WarehouseEntity warehouse = favorite.getWarehouse();
                    Map<String, Object> map = new HashMap<>();

                    // 기본 정보
                    map.put("warehouseId", warehouse.getWarehouseId());
                    map.put("name", warehouse.getName());
                    map.put("address", warehouse.getAddress());

                    map.put("repImageUrl", warehouse.getRepImageUrl());
                    map.put("sizeRank", warehouse.getSizeRank());
                    map.put("totalArea", warehouse.getTotalArea());
                    map.put("description", warehouse.getDescription());

                    return map;
                })
                .collect(Collectors.toList());
    }
}