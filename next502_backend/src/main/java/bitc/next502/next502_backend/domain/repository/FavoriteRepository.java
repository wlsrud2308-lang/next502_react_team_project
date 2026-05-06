package bitc.next502.next502_backend.domain.repository;

import bitc.next502.next502_backend.domain.entity.FavoriteEntity;
import bitc.next502.next502_backend.domain.entity.MemberEntity;
import bitc.next502.next502_backend.domain.entity.WarehouseEntity;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface FavoriteRepository extends JpaRepository<FavoriteEntity, Long> {

    Optional<FavoriteEntity> findByMemberAndWarehouse(MemberEntity member, WarehouseEntity warehouse);


    List<FavoriteEntity> findByMember(MemberEntity member);

    
}