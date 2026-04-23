package bitc.next502.next502_backend.domain.dto;

import lombok.*;

@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ProductDTO {
    private String productName;
    private String address;
    private String contact;
    private String warehouseType;
    private String operationType;
    private String businessName;
    private String businessAddress;
    private String facilities;
    private String totalArea;
}