# VERSIONING

## Phiên bản hiện tại

- API contract: **v1.0.0**
- OpenAPI: **3.1.0**
- Pair: **03 — Core Business → Access Gate**

## Quy tắc versioning

Contract dùng Semantic Versioning:

- **MAJOR**: thay đổi breaking, ví dụ xóa path, đổi tên field bắt buộc, đổi nghĩa enum hiện có.
- **MINOR**: thêm endpoint, thêm field optional hoặc thêm capability vẫn tương thích client cũ.
- **PATCH**: sửa mô tả, example, constraint không làm thay đổi behavior đã cam kết.

## Compatibility policy

1. Trong nhánh `v1.x`, Provider không đổi tên hoặc xóa field required.
2. Field mới phải optional hoặc có default an toàn.
3. Enum mới chỉ được thêm khi Consumer có chiến lược xử lý giá trị chưa biết.
4. Breaking change phải phát hành phiên bản URL mới như `/v2/...` hoặc contract mới, đồng thời thông báo Consumer trước khi triển khai.
5. Mọi thay đổi contract phải cập nhật `openapi.yaml`, `negotiation-log.md`, evidence lint/mock và được hai bên sign-off.
