package bitc.next502.next502_backend.service;

import bitc.next502.next502_backend.domain.entity.MemberEntity;
import bitc.next502.next502_backend.domain.entity.ProductEntity;
import bitc.next502.next502_backend.domain.entity.WishlistEntity;
import bitc.next502.next502_backend.domain.repository.WishlistRepository;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.Optional;

@Service
@RequiredArgsConstructor
public class WishlistService {

    private final WishlistRepository wishlistRepository;

    @Transactional
    public String toggleWish(MemberEntity member, ProductEntity product) {
        Optional<WishlistEntity> wish = wishlistRepository.findWish(member, product);

        if (wish.isPresent()) {
            wishlistRepository.delete(wish.get());
            return "찜 취소 완료";
        } else {
            WishlistEntity newWish = WishlistEntity.builder()
                    .member(member)
                    .product(product)
                    .build();
            wishlistRepository.save(newWish);
            return "찜 등록 완료";
        }
    }
}