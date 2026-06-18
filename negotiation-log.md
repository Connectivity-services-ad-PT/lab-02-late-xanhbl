# Biên bản đàm phán hợp đồng API

- **Cặp đàm phán:** Pair 03 — Core Business → Access Gate
- **Product:** Smart Campus Operations Platform
- **Provider:** Access Gate
- **Consumer:** Core Business
- **Phiên:** v1.0
- **Ngày:** 18/06/2026
- **Hình thức thực hiện:** Cá nhân — Hoàng Văn Xanh mô phỏng hai vai trò Provider và Consumer trong phạm vi Pair 03.

---

## Issue #1 — Phạm vi endpoint và cách đặt tên resource

- **Raised by:** Consumer
- **Endpoint:** Toàn bộ API
- **Concern:** Consumer ban đầu đề xuất các path động từ như `/getRecentLogs`; Provider muốn contract theo resource-oriented API.
- **Proposal:** Dùng `/access/logs/recent`, `/access/logs/{logId}`, `/gates/{gateId}/status`, `/cards/{cardId}`.
- **Resolution:** Accepted
- **Rationale:** Path thể hiện resource rõ ràng, dễ mở rộng pagination/filter và phù hợp REST.
- **Impact:** Core cập nhật client theo các path thống nhất; Access Gate map controller theo các resource này.

---

## Issue #2 — Pagination, lọc và retention của access log

- **Raised by:** Consumer
- **Endpoint:** `GET /access/logs/recent`
- **Concern:** Offset pagination có thể gây trùng hoặc mất log khi có dữ liệu mới liên tục; chưa rõ dữ liệu được lưu bao lâu.
- **Proposal:** Dùng cursor pagination, `limit` từ 1 đến 100, hỗ trợ filter `from`, `to`, `gateId`, `cardId`; retention online 90 ngày.
- **Resolution:** Accepted
- **Rationale:** Cursor ổn định hơn offset trong luồng audit; 90 ngày đủ cho vận hành thường ngày.
- **Impact:** Core phải lưu cursor sau khi xử lý thành công; truy vấn cũ hơn 90 ngày chuyển sang kênh báo cáo/archive.

---

## Issue #3 — Chuẩn hóa trạng thái hướng đi và quyết định

- **Raised by:** Provider
- **Endpoint:** `GET /access/logs/recent`, `GET /access/logs/{logId}`
- **Concern:** Hai bên dùng lẫn “in/out”, “entry/exit” và “accepted/rejected”, làm dashboard/audit khó đồng nhất.
- **Proposal:** Chốt `direction` là `ENTRY | EXIT`; `decision` là `ALLOW | DENY`; trạng thái thẻ là `ACTIVE | BLOCKED | EXPIRED | LOST | REVOKED`.
- **Resolution:** Accepted
- **Rationale:** Enum ngắn, đủ nghiệp vụ, có thể kiểm tra bằng schema.
- **Impact:** Core hiển thị label tiếng Việt ở UI nhưng lưu/parse enum chuẩn tiếng Anh; Provider validate cứng enum.

---

## Issue #4 — Ghi chú vận hành và giá trị null

- **Raised by:** Consumer
- **Endpoint:** `GET /access/logs/*`
- **Concern:** Consumer cần biết khác biệt giữa “không có ghi chú” và một chuỗi rỗng.
- **Proposal:** `operatorNote` luôn có trong response; schema dùng `oneOf` gồm chuỗi từ 1 đến 300 ký tự hoặc `type: 'null'`, dùng `null` khi không có ghi chú và không dùng chuỗi rỗng.
- **Resolution:** Accepted
- **Rationale:** Rõ nghĩa với OpenAPI 3.1, tránh suy đoán từ field bị thiếu.
- **Impact:** Provider luôn serialize `operatorNote`; Core xử lý `null` bằng nhãn “Không có ghi chú”.

---

## Issue #5 — Xác thực, phân quyền và correlation id

- **Raised by:** Provider
- **Endpoint:** Tất cả endpoint trừ `/health`
- **Concern:** Audit access log là dữ liệu nội bộ; cần phân biệt caller và truy vết request qua nhiều service.
- **Proposal:** Dùng Bearer JWT/service token, yêu cầu scope `access-gate.read`; Core gửi header tùy chọn `X-Correlation-Id` dạng UUID.
- **Resolution:** Accepted
- **Rationale:** Scope hạn chế quyền đọc; correlation id giúp nối log Core và Access Gate khi điều tra sự cố.
- **Impact:** Core cấu hình service account/scope và sinh UUID; Provider ghi nhận correlation id nếu có.

---

## Issue #6 — Freshness dữ liệu, timeout và retry

- **Raised by:** Consumer
- **Endpoint:** `GET /access/logs/recent`, `GET /gates/{gateId}/status`
- **Concern:** Log có thể xuất hiện chậm sau lần quẹt; timeout kéo dài sẽ ảnh hưởng dashboard.
- **Proposal:** Log xuất hiện trong tối đa 5 giây; Core đặt timeout 2 giây cho truy vấn trạng thái cổng và 5 giây cho log; chỉ retry GET tối đa 2 lần theo exponential backoff khi gặp 500/timeout.
- **Resolution:** Modified
- **Rationale:** Provider không cam kết SLA mạng tuyệt đối, nhưng chốt freshness vận hành và quy tắc retry an toàn cho endpoint read-only.
- **Impact:** Core hiển thị trạng thái “dữ liệu đang đồng bộ” khi cần; Provider giám sát độ trễ ingest log.

---

# Chốt hợp đồng v1.0

- **Provider sign-off:** Hoàng Văn Xanh — Access Gate (Provider, thực hiện cá nhân)
- **Consumer sign-off:** Hoàng Văn Xanh — Core Business (Consumer mô phỏng, thực hiện cá nhân)
- **Witness (GV/TA):** Chưa yêu cầu
- **Date:** 18/06/2026

---

## Ghi chú warning nếu Spectral còn cảnh báo

| Warning | Lý do chấp nhận tạm thời | Kế hoạch sửa |
|---|---|---|
| Không có warning dự kiến | Contract đã khai báo `operationId`, `summary`, `tags` ở mọi operation. | Chạy `npm run lint:report`; nếu có warning thực tế thì bổ sung tại đây. |
