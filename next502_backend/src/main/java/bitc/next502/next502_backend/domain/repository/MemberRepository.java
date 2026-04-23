package bitc.next502.next502_backend.domain.repository;

import bitc.next502.next502_backend.domain.entity.MemberEntity;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface MemberRepository extends JpaRepository<MemberEntity, Long> {

  Optional<MemberEntity> findByUserId(String userId);

  boolean existsByUserId(String userId);

  boolean existsByUserEmail(String userEmail);
}
