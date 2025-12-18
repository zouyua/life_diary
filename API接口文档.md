# 小哈书 API 接口文档

> 本文档整理了小哈书项目所有模块的接口地址、请求参数和响应参数，供 App 开发使用。

## 目录

- [1. 认证模块 (Auth)](#1-认证模块-auth)
- [2. 用户模块 (User)](#2-用户模块-user)
- [3. 用户关系模块 (User-Relation)](#3-用户关系模块-user-relation)
- [4. 笔记模块 (Note)](#4-笔记模块-note)
- [5. 评论模块 (Comment)](#5-评论模块-comment)
- [6. 搜索模块 (Search)](#6-搜索模块-search)
- [7. 文件上传模块 (OSS)](#7-文件上传模块-oss)
- [8. 计数模块 (Count)](#8-计数模块-count)

---

## 通用响应格式

所有接口统一返回格式：

```json
{
  "success": true,
  "code": "0",
  "message": "操作成功",
  "data": {}
}
```

分页响应格式：

```json
{
  "success": true,
  "code": "0",
  "message": "操作成功",
  "data": [],
  "total": 100,
  "pageNo": 1,
  "pageSize": 10
}
```

---

## 1. 认证模块 (Auth)

### 1.1 发送短信验证码

- **接口地址**: `POST /verification/code/send`
- **接口描述**: 发送短信验证码

**请求参数**:

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| phone | String | 是 | 手机号 |

**请求示例**:
```json
{
  "phone": "13800138000"
}
```

**响应示例**:
```json
{
  "success": true,
  "code": "0",
  "message": "验证码发送成功"
}
```

---

### 1.2 用户登录/注册

- **接口地址**: `POST /login`
- **接口描述**: 用户登录（支持密码或验证码两种方式），新用户自动注册

**请求参数**:

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| phone | String | 是 | 手机号 |
| code | String | 否 | 验证码（验证码登录时必填） |
| password | String | 否 | 密码（密码登录时必填） |
| type | Integer | 是 | 登录类型（1: 验证码登录, 2: 密码登录） |

**请求示例**:
```json
{
  "phone": "13800138000",
  "code": "123456",
  "type": 1
}
```

**响应参数**:

| 参数名 | 类型 | 说明 |
|--------|------|------|
| data | String | Token 令牌 |

**响应示例**:
```json
{
  "success": true,
  "code": "0",
  "message": "登录成功",
  "data": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

---

### 1.3 账号登出

- **接口地址**: `POST /logout`
- **接口描述**: 账号登出

**请求参数**: 无（需要携带 Token）

**响应示例**:
```json
{
  "success": true,
  "code": "0",
  "message": "登出成功"
}
```

---

### 1.4 修改密码

- **接口地址**: `POST /password/update`
- **接口描述**: 修改密码

**请求参数**:

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| newPassword | String | 是 | 新密码 |

**请求示例**:
```json
{
  "newPassword": "newPassword123"
}
```

---

## 2. 用户模块 (User)

### 2.1 修改用户信息

- **接口地址**: `POST /user/update`
- **接口描述**: 修改用户信息
- **Content-Type**: `multipart/form-data`

**请求参数**:

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| userId | Long | 是 | 用户 ID |
| avatar | File | 否 | 头像文件 |
| nickname | String | 否 | 昵称 |
| xiaohashuId | String | 否 | 小哈书 ID |
| sex | Integer | 否 | 性别（0: 女, 1: 男） |
| birthday | String | 否 | 生日（格式: yyyy-MM-dd） |
| introduction | String | 否 | 个人介绍 |
| backgroundImg | File | 否 | 背景图文件 |

---

### 2.2 获取用户主页信息

- **接口地址**: `POST /user/profile`
- **接口描述**: 获取用户主页信息

**请求参数**:

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| userId | Long | 否 | 用户 ID（不传则查询当前登录用户） |

**请求示例**:
```json
{
  "userId": 10001
}
```

**响应参数**:

| 参数名 | 类型 | 说明 |
|--------|------|------|
| userId | Long | 用户 ID |
| avatar | String | 头像 URL |
| nickname | String | 昵称 |
| xiaohashuId | String | 小哈书 ID |
| sex | Integer | 性别 |
| age | Integer | 年龄 |
| introduction | String | 个人介绍 |
| followingTotal | String | 关注数 |
| fansTotal | String | 粉丝数 |
| likeAndCollectTotal | String | 获赞与收藏总数 |
| noteTotal | String | 笔记数 |
| likeTotal | String | 获赞数 |
| collectTotal | String | 获收藏数 |

**响应示例**:
```json
{
  "success": true,
  "code": "0",
  "data": {
    "userId": 10001,
    "avatar": "https://xxx.com/avatar.jpg",
    "nickname": "小哈",
    "xiaohashuId": "xiaoha123",
    "sex": 1,
    "age": 25,
    "introduction": "这是个人介绍",
    "followingTotal": "100",
    "fansTotal": "1000",
    "likeAndCollectTotal": "5000",
    "noteTotal": "50",
    "likeTotal": "3000",
    "collectTotal": "2000"
  }
}
```

---

## 3. 用户关系模块 (User-Relation)

### 3.1 关注用户

- **接口地址**: `POST /relation/follow`
- **接口描述**: 关注用户

**请求参数**:

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| followUserId | Long | 是 | 被关注用户 ID |

**请求示例**:
```json
{
  "followUserId": 10002
}
```

---

### 3.2 取消关注

- **接口地址**: `POST /relation/unfollow`
- **接口描述**: 取消关注用户

**请求参数**:

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| unfollowUserId | Long | 是 | 被取关用户 ID |

**请求示例**:
```json
{
  "unfollowUserId": 10002
}
```

---

### 3.3 查询关注列表

- **接口地址**: `POST /relation/following/list`
- **接口描述**: 查询用户关注列表（分页）

**请求参数**:

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| userId | Long | 是 | 查询用户 ID |
| pageNo | Integer | 是 | 页码（默认 1） |

**请求示例**:
```json
{
  "userId": 10001,
  "pageNo": 1
}
```

**响应参数**:

| 参数名 | 类型 | 说明 |
|--------|------|------|
| userId | Long | 用户 ID |
| avatar | String | 头像 |
| nickname | String | 昵称 |
| introduction | String | 个人介绍 |

---

### 3.4 查询粉丝列表

- **接口地址**: `POST /relation/fans/list`
- **接口描述**: 查询用户粉丝列表（分页）

**请求参数**:

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| userId | Long | 是 | 查询用户 ID |
| pageNo | Integer | 是 | 页码（默认 1） |

**响应参数**:

| 参数名 | 类型 | 说明 |
|--------|------|------|
| userId | Long | 用户 ID |
| avatar | String | 头像 |
| nickname | String | 昵称 |
| fansTotal | Long | 粉丝总数 |
| noteTotal | Long | 笔记总数 |

---

## 4. 笔记模块 (Note)

### 4.1 发布笔记

- **接口地址**: `POST /note/publish`
- **接口描述**: 发布笔记

**请求参数**:

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| type | Integer | 是 | 笔记类型（0: 图文, 1: 视频） |
| imgUris | List<String> | 否 | 图片链接列表（图文笔记必填） |
| videoUri | String | 否 | 视频链接（视频笔记必填） |
| title | String | 否 | 标题 |
| content | String | 否 | 内容 |
| topicId | Long | 否 | 话题 ID |

**请求示例**:
```json
{
  "type": 0,
  "imgUris": ["https://xxx.com/img1.jpg", "https://xxx.com/img2.jpg"],
  "title": "今日分享",
  "content": "这是笔记内容...",
  "topicId": 1001
}
```

---

### 4.2 获取笔记详情

- **接口地址**: `POST /note/detail`
- **接口描述**: 获取笔记详情

**请求参数**:

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| id | Long | 是 | 笔记 ID |

**响应参数**:

| 参数名 | 类型 | 说明 |
|--------|------|------|
| id | Long | 笔记 ID |
| type | Integer | 笔记类型 |
| title | String | 标题 |
| content | String | 内容 |
| imgUris | List<String> | 图片链接列表 |
| topicId | Long | 话题 ID |
| topicName | String | 话题名称 |
| creatorId | Long | 发布者 ID |
| creatorName | String | 发布者昵称 |
| avatar | String | 发布者头像 |
| videoUri | String | 视频链接 |
| updateTime | String | 编辑时间 |
| visible | Integer | 可见状态 |

---

### 4.3 修改笔记

- **接口地址**: `POST /note/update`
- **接口描述**: 修改笔记

**请求参数**:

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| id | Long | 是 | 笔记 ID |
| type | Integer | 是 | 笔记类型 |
| imgUris | List<String> | 否 | 图片链接列表 |
| videoUri | String | 否 | 视频链接 |
| title | String | 否 | 标题 |
| content | String | 否 | 内容 |
| topicId | Long | 否 | 话题 ID |

---

### 4.4 删除笔记

- **接口地址**: `POST /note/delete`
- **接口描述**: 删除笔记

**请求参数**:

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| id | Long | 是 | 笔记 ID |

---

### 4.5 设置笔记仅自己可见

- **接口地址**: `POST /note/visible/onlyme`
- **接口描述**: 设置笔记仅对自己可见

**请求参数**:

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| id | Long | 是 | 笔记 ID |

---

### 4.6 置顶/取消置顶笔记

- **接口地址**: `POST /note/top`
- **接口描述**: 置顶或取消置顶笔记

**请求参数**:

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| id | Long | 是 | 笔记 ID |
| isTop | Boolean | 是 | 是否置顶（true: 置顶, false: 取消置顶） |

---

### 4.7 点赞笔记

- **接口地址**: `POST /note/like`
- **接口描述**: 点赞笔记

**请求参数**:

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| id | Long | 是 | 笔记 ID |

---

### 4.8 取消点赞笔记

- **接口地址**: `POST /note/unlike`
- **接口描述**: 取消点赞笔记

**请求参数**:

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| id | Long | 是 | 笔记 ID |

---

### 4.9 收藏笔记

- **接口地址**: `POST /note/collect`
- **接口描述**: 收藏笔记

**请求参数**:

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| id | Long | 是 | 笔记 ID |

---

### 4.10 取消收藏笔记

- **接口地址**: `POST /note/uncollect`
- **接口描述**: 取消收藏笔记

**请求参数**:

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| id | Long | 是 | 笔记 ID |

---

### 4.11 获取点赞收藏状态

- **接口地址**: `POST /note/isLikedAndCollectedData`
- **接口描述**: 获取当前用户对笔记的点赞、收藏状态

**请求参数**:

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| noteId | Long | 是 | 笔记 ID |

**响应参数**:

| 参数名 | 类型 | 说明 |
|--------|------|------|
| noteId | Long | 笔记 ID |
| isLiked | Boolean | 是否已点赞 |
| isCollected | Boolean | 是否已收藏 |

---

### 4.12 获取用户已发布笔记列表

- **接口地址**: `POST /note/published/list`
- **接口描述**: 获取用户主页已发布笔记列表（游标分页）

**请求参数**:

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| userId | Long | 是 | 用户 ID |
| cursor | Long | 否 | 游标（笔记 ID，用于分页） |

**响应参数**:

| 参数名 | 类型 | 说明 |
|--------|------|------|
| notes | List | 笔记列表 |
| nextCursor | Long | 下一页游标 |

**笔记列表项 (NoteItemRspVO)**:

| 参数名 | 类型 | 说明 |
|--------|------|------|
| noteId | Long | 笔记 ID |
| type | Integer | 笔记类型（0: 图文, 1: 视频） |
| cover | String | 封面图 |
| videoUri | String | 视频链接 |
| title | String | 标题 |
| creatorId | Long | 发布者 ID |
| nickname | String | 发布者昵称 |
| avatar | String | 发布者头像 |
| likeTotal | String | 点赞数 |
| isLiked | Boolean | 当前用户是否已点赞 |

---

## 5. 评论模块 (Comment)

### 5.1 发布评论

- **接口地址**: `POST /comment/publish`
- **接口描述**: 发布评论

**请求参数**:

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| noteId | Long | 是 | 笔记 ID |
| content | String | 否 | 评论内容 |
| imageUrl | String | 否 | 评论图片链接 |
| replyCommentId | Long | 否 | 回复的评论 ID（回复评论时必填） |

**请求示例**:
```json
{
  "noteId": 10001,
  "content": "这是一条评论"
}
```

---

### 5.2 评论分页查询

- **接口地址**: `POST /comment/list`
- **接口描述**: 查询笔记一级评论列表（分页）

**请求参数**:

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| noteId | Long | 是 | 笔记 ID |
| pageNo | Integer | 是 | 页码（默认 1） |

**响应参数**:

| 参数名 | 类型 | 说明 |
|--------|------|------|
| commentId | Long | 评论 ID |
| userId | Long | 发布者用户 ID |
| avatar | String | 头像 |
| nickname | String | 昵称 |
| content | String | 评论内容 |
| imageUrl | String | 评论图片 |
| createTime | String | 发布时间 |
| likeTotal | Long | 点赞数 |
| heat | Double | 热度值 |
| childCommentTotal | Long | 二级评论总数 |
| firstReplyComment | Object | 最早回复的评论 |

---

### 5.3 二级评论分页查询

- **接口地址**: `POST /comment/child/list`
- **接口描述**: 查询二级评论列表（分页）

**请求参数**:

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| parentCommentId | Long | 是 | 父评论 ID |
| pageNo | Integer | 是 | 页码（默认 1） |

**响应参数**:

| 参数名 | 类型 | 说明 |
|--------|------|------|
| commentId | Long | 评论 ID |
| userId | Long | 发布者用户 ID |
| avatar | String | 头像 |
| nickname | String | 昵称 |
| content | String | 评论内容 |
| imageUrl | String | 评论图片 |
| createTime | String | 发布时间 |
| likeTotal | Long | 点赞数 |
| replyUserName | String | 回复的用户昵称 |
| replyUserId | Long | 回复的用户 ID |

---

### 5.4 评论点赞

- **接口地址**: `POST /comment/like`
- **接口描述**: 点赞评论

**请求参数**:

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| commentId | Long | 是 | 评论 ID |

---

### 5.5 取消评论点赞

- **接口地址**: `POST /comment/unlike`
- **接口描述**: 取消点赞评论

**请求参数**:

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| commentId | Long | 是 | 评论 ID |

---

### 5.6 删除评论

- **接口地址**: `POST /comment/delete`
- **接口描述**: 删除评论

**请求参数**:

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| commentId | Long | 是 | 评论 ID |

---

## 6. 搜索模块 (Search)

### 6.1 搜索用户

- **接口地址**: `POST /search/user`
- **接口描述**: 搜索用户（分页）

**请求参数**:

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| keyword | String | 是 | 搜索关键词 |
| pageNo | Integer | 否 | 页码（默认 1） |

**响应参数**:

| 参数名 | 类型 | 说明 |
|--------|------|------|
| userId | Long | 用户 ID |
| nickname | String | 昵称 |
| avatar | String | 头像 |
| xiaohashuId | String | 小哈书 ID |
| noteTotal | Integer | 笔记发布总数 |
| fansTotal | String | 粉丝总数 |
| highlightNickname | String | 昵称（关键词高亮） |

---

### 6.2 搜索笔记

- **接口地址**: `POST /search/note`
- **接口描述**: 搜索笔记（分页）

**请求参数**:

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| keyword | String | 是 | 搜索关键词 |
| pageNo | Integer | 否 | 页码（默认 1） |
| type | Integer | 否 | 笔记类型（null: 综合, 0: 图文, 1: 视频） |
| sort | Integer | 否 | 排序（null: 不限, 0: 最新, 1: 最多点赞, 2: 最多评论, 3: 最多收藏） |
| publishTimeRange | Integer | 否 | 发布时间范围（null: 不限, 0: 一天内, 1: 一周内, 2: 半年内） |

**响应参数**:

| 参数名 | 类型 | 说明 |
|--------|------|------|
| noteId | Long | 笔记 ID |
| cover | String | 封面 |
| title | String | 标题 |
| highlightTitle | String | 标题（关键词高亮） |
| avatar | String | 发布者头像 |
| nickname | String | 发布者昵称 |
| updateTime | String | 最后编辑时间 |
| likeTotal | String | 点赞数 |
| commentTotal | String | 评论数 |
| collectTotal | String | 收藏数 |

---

## 7. 文件上传模块 (OSS)

### 7.1 上传文件

- **接口地址**: `POST /file/upload`
- **接口描述**: 上传文件
- **Content-Type**: `multipart/form-data`

**请求参数**:

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| file | File | 是 | 文件 |

**响应参数**:

| 参数名 | 类型 | 说明 |
|--------|------|------|
| data | String | 文件访问 URL |

**响应示例**:
```json
{
  "success": true,
  "code": "0",
  "data": "https://xxx.com/files/xxx.jpg"
}
```

---

## 8. 计数模块 (Count)

### 8.1 获取用户计数数据

- **接口地址**: `POST /count/user/data`
- **接口描述**: 获取用户计数数据（关注数、粉丝数等）

**请求参数**:

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| userId | Long | 是 | 用户 ID |

---

### 8.2 批量获取笔记计数数据

- **接口地址**: `POST /count/notes/data`
- **接口描述**: 批量获取笔记计数数据（点赞数、收藏数等）

**请求参数**:

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| noteIds | List<Long> | 是 | 笔记 ID 列表 |

---

## 附录

### 请求头说明

需要登录的接口需要在请求头中携带 Token：

```
Authorization: Bearer {token}
```

### 错误码说明

| 错误码 | 说明 |
|--------|------|
| 0 | 成功 |
| 10000 | 参数校验失败 |
| 10001 | 用户未登录 |
| 10002 | Token 已过期 |
| 20001 | 业务异常 |

---

> 文档更新时间: 2025-12-17
