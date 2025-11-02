# English Reader Backend

基于 Dart Shelf 的轻量后端，提供与前端页面相匹配的 REST API。

## 启动

1. 进入目录：`cd backend`
2. 安装依赖：`dart pub get`
3. 启动服务：`dart run bin/server.dart`

默认端口：`8080`，健康检查：`http://localhost:8080/health`

## API 概览

- `POST /auth/register` { email, password, name }
- `POST /auth/login` { email, password } → { token }
- `GET /profile/me` 需要 `Authorization: Bearer <token>`
- `GET /books?query=...`
- `GET /books/:id`
- `GET /notes?bookId=...`
- `POST /notes` { bookId, content }
- `PUT /notes/:id` { content }
- `DELETE /notes/:id`

讨论区（Discussions）：
- `GET /discussions?query=...&sort=likes|recent`
- `GET /discussions/:id`
- `GET /discussions/:id/replies`
- `POST /discussions` { title, content, author }
- `POST /discussions/:id/replies` { content, author }
- `POST /discussions/:id/like` { like: true|false }

数据存储在 `backend/data/` 下的 JSON 文件中，便于开发与演示（包含 `discussions.json`）。
