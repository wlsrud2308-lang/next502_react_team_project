import bitc.next502.next502_backend.domain.entity.MemberEntity;
import bitc.next502.next502_backend.domain.entity.WarehouseEntity;
import bitc.next502.next502_backend.service.FavoriteService;
import bitc.next502.next502_backend.service.WarehouseService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/favorite")
@RequiredArgsConstructor
public class FavoriteController {

    private final FavoriteService favoriteService;
    private final WarehouseService warehouseService;

    // 경로 변수명을 id 대신 whId로 쓰면 더 명확합니다.
    @PostMapping("/{whId}")
    public ResponseEntity<String> toggleFavorite(
            @PathVariable("whId") Long whId, // 이름을 명시적으로 지정
            @AuthenticationPrincipal MemberEntity member) {

        // 1. 서비스에 whId를 전달해서 엔티티를 가져옵니다.
        WarehouseEntity warehouse = warehouseService.getWarehouseEntity(whId);

        // 2. 찜 토글 로직을 수행합니다.
        String result = favoriteService.toggleFavorite(member, warehouse);

        return ResponseEntity.ok(result);
    }
}

