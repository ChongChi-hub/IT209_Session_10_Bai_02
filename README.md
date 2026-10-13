# Báo cáo Thực hành DevOps - Session 10: Bài 2
## Đóng gói Ứng dụng Web Backend bằng Single-stage Dockerfile

- **Học viên:** Đào Trọng Trí
- **Mã sinh viên:** PTIT062
- **Lớp:** DevOps / Cloud Native Engineering
- **Bài tập:** Đóng gói ứng dụng REST API Node.js/Express thành Docker Image phục vụ môi trường thử nghiệm

---

## 1. Mục tiêu và Yêu cầu
- Xây dựng một ứng dụng Web API đơn giản bằng Node.js và Express framework.
- Soạn thảo tệp `Dockerfile` chuẩn Single-stage đầy đủ các chỉ thị tiêu chuẩn: `FROM`, `WORKDIR`, `COPY`, `RUN`, `EXPOSE`, `ENV`, `CMD`.
- Sử dụng Base Image tối ưu: `node:18-alpine`.
- Build image với tag `hw-backend:v1` và khởi chạy container `app-single-stage` ánh xạ cổng `8080:3000`.
- Kiểm tra tính sẵn sàng của container và kiểm chứng phản hồi JSON mã HTTP `200 OK`.

---

## 2. Cấu trúc thư mục dự án
```text
SS10_HW02_DaoTrongTri_PTIT062/
├── Dockerfile          # Single-stage Dockerfile đóng gói ứng dụng
├── .dockerignore       # Loại trừ node_modules và các file thừa khi build
├── package.json        # Định nghĩa dự án và dependencies Express
├── server.js           # Mã nguồn REST API Node.js
└── README.md           # Tài liệu hướng dẫn & báo cáo kết quả thực nghiệm
```

---

## 3. Chi tiết Cấu hình Dockerfile

```dockerfile
# Sử dụng Base Image Node.js 18 phiên bản Alpine siêu nhẹ
FROM node:18-alpine

# Thiết lập thư mục làm việc bên trong container
WORKDIR /app

# Thiết lập biến môi trường PORT mặc định
ENV PORT=3000

# Sao chép file định nghĩa phụ thuộc package.json
COPY package*.json ./

# Cài đặt các thư viện dependencies cần thiết
RUN npm install --production

# Sao chép toàn bộ mã nguồn ứng dụng vào thư mục làm việc
COPY . .

# Khai báo cổng ứng dụng lắng nghe bên trong container
EXPOSE 3000

# Chỉ thị thực thi khởi chạy ứng dụng theo dạng exec form
CMD ["node", "server.js"]
```

### Giải thích các chỉ thị cốt lõi:
1. `FROM node:18-alpine`: Sử dụng hệ điều hành Alpine Linux có cài sẵn Node.js 18, dung lượng base image chỉ khoảng ~45MB (nhỏ hơn rất nhiều so với image tiêu chuẩn node:18 > 1GB).
2. `WORKDIR /app`: Đặt thư mục làm việc mặc định cho tất cả các lệnh tiếp theo, tránh cài đặt lung tung ở thư mục gốc `/`.
3. `ENV PORT=3000`: Định nghĩa biến môi trường `PORT`, cho phép ứng dụng đọc qua `process.env.PORT`.
4. `COPY package*.json ./` & `RUN npm install`: Tận dụng Layer Caching của Docker, chỉ cài lại thư viện khi có thay đổi trong `package.json`.
5. `COPY . .`: Sao chép phần mã nguồn còn lại (nhờ có `.dockerignore` nên thư mục `node_modules` cục bộ sẽ không bị copy đè lên).
6. `EXPOSE 3000`: Khai báo siêu dữ liệu chỉ định container sẽ phục vụ cổng 3000.
7. `CMD ["node", "server.js"]`: Khởi chạy ứng dụng bằng Exec Form (PID 1 là tiến trình `node`, giúp container nhận và xử lý tín hiệu POSIX như `SIGTERM`, `SIGINT` đúng cách khi dừng).

---

## 4. Các bước Triển khai và Kiểm tra Thực tế

### Bước 1: Build Docker Image
```bash
docker build -t hw-backend:v1 .
```

### Bước 2: Khởi chạy Container
```bash
docker run -d --name app-single-stage -p 8080:3000 hw-backend:v1
```

### Bước 3: Kiểm tra trạng thái Container
```bash
docker ps
```

### Bước 4: Kiểm tra Log khởi động của Ứng dụng
```bash
docker logs app-single-stage
```

### Bước 5: Kiểm tra kết nối API qua cURL
```bash
curl -i http://localhost:8080/
```

---

## 5. Nhật ký Lệnh Thực thi từ Terminal Thực tế

### 5.1. Log Build Image (`docker build -t hw-backend:v1 .`)
```text
#0 building with "default" instance using docker driver
#1 [internal] load build definition from Dockerfile
#1 transferring dockerfile: 708B done
#2 [internal] load metadata for docker.io/library/node:18-alpine
#3 [internal] load .dockerignore
#3 transferring context: 93B done
#4 [internal] load build context
#4 transferring context: 2.56kB done
#5 [1/5] FROM docker.io/library/node:18-alpine
#6 [2/5] WORKDIR /app
#7 [3/5] COPY package*.json ./
#8 [4/5] RUN npm install --production
added 68 packages, and audited 69 packages in 10s
found 0 vulnerabilities
#9 [5/5] COPY . .
#10 exporting to image
#10 naming to docker.io/library/hw-backend:v1 done
```

### 5.2. Log khởi chạy & kiểm tra Container (`docker ps`, `docker logs`)
```text
$ docker run -d --name app-single-stage -p 8080:3000 hw-backend:v1
3f982b2a920d01641cf9ae15ddfbf06b58958def24058861b6d5afa64fc75c61

$ docker ps
CONTAINER ID   IMAGE           COMMAND                  CREATED         STATUS        PORTS                                         NAMES
3f982b2a920d   hw-backend:v1   "docker-entrypoint.s…"   2 seconds ago   Up 1 second   0.0.0.0:8080->3000/tcp, [::]:8080->3000/tcp   app-single-stage

$ docker logs app-single-stage
Server listening on port 3000
```

### 5.3. Log kiểm tra phản hồi API (`curl -i http://localhost:8080/`)
```text
$ curl -i http://localhost:8080/
HTTP/1.1 200 OK
X-Powered-By: Express
Content-Type: application/json; charset=utf-8
Content-Length: 64
ETag: W/"40-upZb7Fps+hszzRU9BoKtiCsmGCQ"
Date: Tue, 13 Oct 2026 16:56:42 GMT
Connection: keep-alive
Keep-Alive: timeout=5

{"status":"success","message":"Hello from Docker Single-stage!"}
```

---

## 6. Hướng dẫn Chụp ảnh Minh chứng (Evidence Collection)

> **Hướng dẫn cho sinh viên:**
> 1. Mở Terminal và kết nối SSH vào máy chủ Linux:
>    ```bash
>    ssh devopsg5@103.72.57.148
>    ```
> 2. Di chuyển vào thư mục bài tập và kiểm tra container:
>    ```bash
>    docker ps | grep app-single-stage
>    curl -i http://localhost:8080/
>    ```
> 3. Chụp ảnh màn hình hiển thị cả lệnh `docker ps` (trạng thái Up) và kết quả `curl` trả về mã `HTTP/1.1 200 OK` cùng nội dung JSON.
> 4. Dán ảnh chụp vào vị trí placeholder bên dưới.

### Minh chứng ảnh chụp:
`ImgEx: [Dán ảnh chụp màn hình terminal kiểm tra container app-single-stage và curl HTTP 200 OK tại đây]`
