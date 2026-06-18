# Phân tích yêu cầu — vai Provider

- **Cặp đàm phán:** Pair 03 — Core Business → Access Gate
- **Product:** Smart Campus Operations Platform
- **Provider service:** Access Gate
- **Consumer service:** Core Business
- **Người viết:** Hoàng Văn Xanh — thực hiện cá nhân, mô phỏng vai trò tương ứng
- **Ngày:** 18/06/2026

---

## 1. Resource chính

| Resource | Mô tả | Thuộc tính bắt buộc | Thuộc tính tùy chọn |
|---|---|---|---|
| AccessLog | Bản ghi một lần quẹt thẻ hoặc quét pass tại cổng. | `id`, `gateId`, `direction`, `decision`, `occurredAt`, `identity` | `operatorNote`, `correlationId` |
| GateStatus | Trạng thái vận hành hiện thời của cổng. | `gateId`, `status`, `doorState`, `lastSeenAt`, `firmwareVersion` | `currentSessionId` |
| Card | Thông tin định danh và trạng thái thẻ ra/vào. | `cardId`, `holderId`, `holderName`, `status`, `issuedAt` | `expiresAt`, `lastUsedAt` |

`AccessLog.identity` dùng `oneOf` để biểu diễn hai loại định danh: thẻ chính thức (`CARD`) và pass tạm (`TEMPORARY_PASS`). Provider phân biệt hai kiểu bằng trường `identityType`.

---

## 2. Action/API dự kiến

| Method | Path | Mục đích | Consumer gọi khi nào? |
|---|---|---|---|
| GET | `/health` | Health check service. | Gateway hoặc monitor kiểm tra service. |
| GET | `/access/logs/recent` | Lấy log gần đây, hỗ trợ lọc và cursor pagination. | Core audit, đồng bộ log, kiểm tra sự cố. |
| GET | `/access/logs/{logId}` | Lấy đầy đủ một log cụ thể. | Cần xác minh lần quẹt thẻ cụ thể. |
| GET | `/gates/{gateId}/status` | Kiểm tra cổng online/offline/lỗi/bảo trì. | Xử lý sự cố hoặc đối soát trạng thái cổng. |
| GET | `/cards/{cardId}` | Tra trạng thái và chủ thẻ. | Kiểm tra thẻ khi audit log. |

---

## 3. Error case

| Status | Tình huống | Response body dự kiến |
|---|---|---|
| 400 | `gateId`, `cardId`, UUID hoặc query parameter không đúng định dạng. | `Problem` với `errors[]`. |
| 401 | Thiếu, hết hạn hoặc sai Bearer token. | `Problem` với `type` unauthorized. |
| 403 | Token đúng nhưng không có scope `access-gate.read`. | `Problem` với `type` forbidden. |
| 404 | Không tìm thấy log, gate hoặc card. | `Problem` với URI resource đã truy vấn. |
| 422 | Khoảng `from`/`to` không hợp lệ hoặc điều kiện nghiệp vụ sai. | `Problem` với mã `INVALID_TIME_RANGE`. |
| 500 | Access Gate hoặc downstream storage lỗi. | `Problem` chung, không lộ chi tiết nội bộ. |

---

## 4. Giả định bổ sung

1. Access Gate giữ dữ liệu log online trong 90 ngày; dữ liệu cũ hơn cần kênh báo cáo riêng.
2. Log xuất hiện ở endpoint `/access/logs/recent` chậm tối đa 5 giây sau khi thao tác thực tế xảy ra.
3. Consumer sử dụng Bearer token với scope `access-gate.read`; `X-Correlation-Id` là tùy chọn nhưng được khuyến nghị để truy vết.
4. Các endpoint là read-only nên không áp dụng idempotency key; retry GET an toàn khi timeout.

---

## 5. Câu hỏi cho Consumer

1. Core Business cần đồng bộ log theo lịch bao lâu một lần và cần giữ lại lịch sử ở Core trong bao lâu?
2. Khi cổng offline, Core cần cảnh báo ngay hay chỉ hiển thị trong dashboard?
3. Core có cần lọc log theo khoảng thời gian dài hơn 90 ngày không?

---

## 6. Rủi ro tích hợp

| Rủi ro | Tác động | Đề xuất xử lý |
|---|---|---|
| Core hiểu khác nhau về `ALLOW`/`DENY` hoặc `ENTRY`/`EXIT`. | Audit sai kết quả. | Chốt enum trong `openapi.yaml`. |
| Core gửi `cardId` sai format. | Provider trả 400, mất thời gian debug. | Dùng pattern và ví dụ chung. |
| Log chưa xuất hiện ngay do eventual consistency. | Core tưởng mất dữ liệu. | Quy ước độ trễ tối đa 5 giây và hỗ trợ retry. |
| Token thiếu scope. | 403 tại môi trường tích hợp. | Chốt scope `access-gate.read` trong tài liệu. |
| Không có correlation id. | Khó truy vết liên service. | Core gửi `X-Correlation-Id` cho mọi request audit. |
