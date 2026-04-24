package bitc.next502.next502_backend.controller;

import bitc.next502.next502_backend.domain.entity.MemberEntity;
import bitc.next502.next502_backend.domain.entity.WarehouseEntity;
import bitc.next502.next502_backend.service.ProductService;
import bitc.next502.next502_backend.service.WishlistService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/wish")
@RequiredArgsConstructor
public class WishlistController {

    private final WishlistService wishlistService;
    private final ProductService productService;

    // 찜 토글 (등록/취소)
    @PostMapping("/{productId}")
    public ResponseEntity<String> toggleWish(
            @PathVariable Long productId,
            @AuthenticationPrincipal MemberEntity member) {

        WarehouseEntity product = productService.getProductDetail(productId);

        String result = wishlistService.toggleWish(member, product);

        return ResponseEntity.ok(result);
    }
}
