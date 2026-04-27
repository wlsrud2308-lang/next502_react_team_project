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

    @PostMapping("/{warehouseSeq}")
    public ResponseEntity<String> toggleFavorite(
            @PathVariable Long warehouseSeq,
            @AuthenticationPrincipal MemberEntity member) {

        WarehouseEntity warehouse = warehouseService.getWarehouseDetail(warehouseSeq);
        String result = favoriteService.toggleFavorite(member, warehouse);

        return ResponseEntity.ok(result);
    }
}

