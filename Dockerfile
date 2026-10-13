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
