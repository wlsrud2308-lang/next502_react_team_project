package bitc.next502.next502_backend.service;

import bitc.next502.next502_backend.domain.entity.FavoriteEntity;
import bitc.next502.next502_backend.domain.entity.MemberEntity;
import bitc.next502.next502_backend.domain.entity.WarehouseEntity;
import bitc.next502.next502_backend.domain.repository.FavoriteRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Optional;

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
}
