package bitc.next502.next502_backend.domain.repository;

import bitc.next502.next502_backend.domain.entity.ProductEntity;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;

public interface ProductRepository extends JpaRepository<ProductEntity, Long> {


    @Query("SELECT p FROM ProductEntity as p " +
            "WHERE (:addr IS NULL OR p.address LIKE %:addr%) " +
            "AND (:op IS NULL OR p.operationType LIKE %:op%) " +
            "AND (:wh IS NULL OR p.warehouseType LIKE %:wh%) " +
            "AND (:name IS NULL OR p.productName LIKE %:name%)")
    List<ProductEntity> searchProducts(
            @Param("addr") String addr,
            @Param("op") String op,
            @Param("wh") String wh,
            @Param("name") String name
    );

    List<ProductEntity> findByMember_UserId(String userId);
}
