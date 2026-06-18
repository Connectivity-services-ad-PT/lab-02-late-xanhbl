# Gói hoàn thiện Pair 03 — Access Gate

Gói này thay thế các file khung trong repository Lab 02 bằng nội dung cho **Pair 03: Core Business → Access Gate**.

## Cách áp dụng

1. Tải ZIP và giải nén trực tiếp vào thư mục clone repository `lab-02-late-xanhbl`.
2. Cho phép ghi đè các file có cùng đường dẫn.
3. Mở PowerShell tại thư mục repository và chạy:

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
npm run install:cli
npm run lint
npm run lint:report
npm run mock
```

4. Mở **PowerShell thứ hai**, rồi chạy:

```powershell
.\scripts\test_mock_with_curl.ps1
```

5. Chụp 5 phần kết quả của script, mỗi ảnh phải thấy lệnh `curl`, status code và response body. Lưu vào:
   `evidence/buoi-02/mock-screenshots/`

6. Sau khi chạy lint, file `evidence/buoi-02/spectral-report.txt` sẽ được thay bằng báo cáo thật.

## Trước khi nộp

- Thay `[Đại diện Core Business điền tên]` bằng tên thành viên phía Consumer.
- Chạy lại `npm run lint`; chỉ nộp khi không có dòng `error`.
- Kiểm tra `git status`.
- Commit và push:

```powershell
git add openapi.yaml negotiation-log.md VERSIONING.md docs scripts evidence
git commit -m "chore(contract): pair-03 access-gate v1.0 signed-off"
git push
```
