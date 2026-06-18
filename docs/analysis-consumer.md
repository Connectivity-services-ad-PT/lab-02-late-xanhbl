# Phân tích yêu cầu — vai Consumer

- **Cặp đàm phán:** Pair 03 — Core Business → Access Gate
- **Product:** Smart Campus Operations Platform
- **Consumer service:** Core Business
- **Provider service:** Access Gate
- **Người viết:** Hoàng Văn Xanh — thực hiện cá nhân, mô phỏng vai trò tương ứng
- **Ngày:** 18/06/2026

---

## 1. Resource Consumer cần nhận/gửi

| Resource | Consumer dùng để làm gì? | Field bắt buộc với Consumer | Field có thể tùy chọn |
|---|---|---|---|
| AccessLog | Audit truy cập, điều tra sự cố, tổng hợp nghiệp vụ. | `id`, `gateId`, `direction`, `decision`, `occurredAt`, `identity` | `operatorNote`, `correlationId` |
| GateStatus | Hiển thị tình trạng cổng và phát hiện gián đoạn. | `gateId`, `status`, `doorState`, `lastSeenAt` | `currentSessionId`, `firmwareVersion` |
| Card | Xác minh trạng thái thẻ và chủ thẻ. | `cardId`, `holderId`, `holderName`, `status` | `expiresAt`, `lastUsedAt` |

Core Business chỉ đọc dữ liệu. Header `X-Correlation-Id` do Core tạo để nối request, log ứng dụng và nghiệp vụ audit.

---

## 2. API Consumer cần gọi

| Method | Path | Lúc nào gọi? | Kỳ vọng response |
|---|---|---|---|
| GET | `/health` | Kiểm tra sức khỏe Access Gate trước hoặc trong monitor. | `200 HealthStatus`. |
| GET | `/access/logs/recent` | Định kỳ đồng bộ/audit log, có thể lọc theo card, gate hoặc thời gian. | `200 AccessLogPage`, sắp xếp giảm theo `occurredAt`. |
| GET | `/access/logs/{logId}` | Người vận hành mở chi tiết một log. | `200 AccessLog` hoặc `404 Problem`. |
| GET | `/gates/{gateId}/status` | Dashboard kiểm tra trạng thái cổng. | `200 GateStatus` hoặc `404 Problem`. |
| GET | `/cards/{cardId}` | Audit thẻ của một lần quẹt. | `200 Card` hoặc `404 Problem`. |

---

## 3. Error case Consumer cần xử lý

| Status | Consumer hiểu là gì? | Consumer sẽ xử lý thế nào? |
|---|---|---|
| 400 | Request sai format, ví dụ `cardId` hoặc UUID sai. | Chặn input, log chi tiết `errors[]`, không retry. |
| 401 | Token không hợp lệ/hết hạn. | Refresh hoặc lấy service token mới, sau đó retry một lần. |
| 403 | Service account không có `access-gate.read`. | Hiển thị lỗi cấu hình và báo quản trị hệ thống. |
| 404 | Log/gate/card không tồn tại hoặc đã hết retention. | Hiển thị “không tìm thấy”, không retry. |
| 422 | Query hợp lệ về cú pháp nhưng sai điều kiện, ví dụ `from > to`. | Sửa bộ lọc ở UI/API caller, không retry. |
| 500 | Provider hoặc storage gặp lỗi. | Circuit breaker/backoff, retry GET tối đa 2 lần. |

---

## 4. Giả định bổ sung

1. Core đồng bộ log theo cursor, không dùng offset để tránh bỏ sót hoặc trùng dữ liệu khi có log mới.
2. Core chấp nhận độ trễ tối đa 5 giây để log mới xuất hiện.
3. Core gửi `X-Correlation-Id` là UUID cho mọi request nghiệp vụ; không gửi thông tin cá nhân nhạy cảm trong header.
4. Core chỉ hiển thị dữ liệu theo quyền người vận hành, không công khai thông tin chủ thẻ.

---

## 5. Câu hỏi cho Provider

1. Khi log bị xóa hoặc quá thời hạn lưu, Provider luôn trả 404 hay có mã khác?
2. `lastSeenAt` của cổng được cập nhật theo chu kỳ nào và khi nào `status` chuyển thành `OFFLINE`?
3. Có trường hợp một `AccessLog` không có `correlationId` không, và Core cần xử lý thế nào?

---

## 6. Rủi ro tích hợp

| Rủi ro | Tác động | Đề xuất xử lý |
|---|---|---|
| Đổi enum trạng thái thẻ/cổng không báo trước. | Core parse lỗi hoặc hiển thị sai. | Versioning Semantic Versioning và chỉ bổ sung backward compatible trong v1.x. |
| Pagination cursor bị dùng lại sai. | Lặp hoặc mất log. | Core lưu cursor cuối cùng sau khi xử lý thành công. |
| Provider chậm/timeout. | Dashboard hoặc audit chậm. | Timeout ngắn, retry GET giới hạn, circuit breaker. |
| Mã lỗi không đồng nhất. | Core không biết xử lý tình huống. | Chỉ dùng `application/problem+json` với schema `Problem`. |
| Response chứa danh tính pass tạm. | Nguy cơ lộ dữ liệu. | Phân quyền scope, masking ở UI Core nếu cần. |
