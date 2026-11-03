# Sử dụng Java 17 để chạy ứng dụng Spring Boot
FROM eclipse-temurin:17-jre

# Khai báo thư mục làm việc bên trong container
WORKDIR /app

# Sao chép file JAR vào container
COPY target/QLPhongTro-0.0.1-SNAPSHOT.jar app.jar

# Mở cổng 8080
EXPOSE 8080

# Khởi chạy ứng dụng
ENTRYPOINT ["java", "-jar", "app.jar"]