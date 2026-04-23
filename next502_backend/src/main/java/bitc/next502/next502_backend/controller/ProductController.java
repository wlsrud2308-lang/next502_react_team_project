package bitc.next502.next502_backend.controller;

import bitc.next502.next502_backend.domain.dto.ProductDTO;
import bitc.next502.next502_backend.domain.entity.MemberEntity;
import bitc.next502.next502_backend.service.ProductService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/product")
@RequiredArgsConstructor
public class ProductController {

    private final ProductService productService;

    @GetMapping("/search")
    public ResponseEntity<?> search(
            @RequestParam(value = "location", required = false) String location,
            @RequestParam(value = "operation", required = false) String operation,
            @RequestParam(value = "type", required = false) String type,
            @RequestParam(value = "name", required = false) String name) {

        return ResponseEntity.ok(productService.searchProducts(location, operation, type, name));
    }
    @PostMapping("/insert")
    public ResponseEntity<String> insertProduct(
            @RequestBody ProductDTO productDTO,
            @AuthenticationPrincipal MemberEntity member) {

        productService.insertProduct(productDTO, member);
        return ResponseEntity.ok("창고 등록이 완료되었습니다.");
    }
}
