# 小哈书 API 接口文档

> 更新时间: 2025-12-23
> 基础路径: http://localhost:8000

## 通用说明

### 请求头
| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| Authorization | String | 是(除登录外) | Bearer {token} |
| Content-Type | String | 是 | application/json |

### 通用响应格式
```json
{
  "success": true,
  "message": "操作成功",
  "errorCode": null,
  "data": {}
}
```

### 分页响应格式
```json
{
  "success": true,
  "message": "操作成功",
  "pageNo": 1,
  "pageSize": 10,
  "totalCount": 100,
  "totalPage": 10,
  "data": []
}
```

---

## 一、认证模块 (Auth)

### 1.1 用户登录/注册
- **接口**: `POST /auth/login`
- **描述**: 手机号验证码登录或密码登录，新用户自动注册

**请求参数**:
| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| phone | String | 是 | 手机号 |
| code | String | 否 | 验证码(验证码登录时必填) |
| password | String | 否 | 密码(密码登录时必填) |
| type | Integer | 是 | 登录类型: 1-验证码登录 2-密码登录 |

**响应示例**:
```json
{
  "success": true,
  "data": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9..."
}
```

### 1.2 账号登出
- **接口**: `POST /auth/logout`
- **描述**: 退出登录

### 1.3 修改密码
- **接口**: `POST /auth/password/update`
- **描述**: 修改账号密码

**请求参数**:
| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| phone | String | 是 | 手机号 |
| code | String | 是 | 验证码 |
| newPassword | String | 是 | 新密码 |

### 1.4 发送验证码
- **接口**: `POST /auth/verification/code/send`
- **描述**: 发送短信验证码

**请求参数**:
| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| phone | String | 是 | 手机号 |
| type | Integer | 是 | 类型: 1-登录 2-修改密码 |

---

## 二、用户模块 (User)

### 2.1 修改用户信息
- **接口**: `POST /user/user/update`
- **描述**: 修改用户个人信息
- **Content-Type**: multipart/form-data

**请求参数**:
| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| avatar | File | 否 | 头像文件 |
| nickname | String | 否 | 昵称 |
| xiaohashuId | String | 否 | 小哈书号 |
| sex | Integer | 否 | 性别: 0-女 1-男 |
| birthday | String | 否 | 生日(yyyy-MM-dd) |
| introduction | String | 否 | 个人简介 |
| backgroundImg | File | 否 | 背景图 |

### 2.2 获取用户主页信息
- **接口**: `POST /user/user/profile`
- **描述**: 获取用户主页详细信息

**请求参数**:
| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| userId | Long | 是 | 用户ID |

**响应参数**:
| 参数名 | 类型 | 说明 |
|--------|------|------|
| userId | Long | 用户ID |
| xiaohashuId | String | 小哈书号 |
| nickname | String | 昵称 |
| avatar | String | 头像URL |
| sex | Integer | 性别 |
| birthday | String | 生日 |
| introduction | String | 简介 |
| backgroundImg | String | 背景图 |
| fansTotal | Long | 粉丝数 |
| followingTotal | Long | 关注数 |
| noteTotal | Long | 笔记数 |
| likeTotal | Long | 获赞数 |
| collectTotal | Long | 收藏数 |
| isFollowed | Boolean | 是否已关注 |

---

## 三、用户关系模块 (Relation)

### 3.1 关注用户
- **接口**: `POST /relation/relation/follow`
- **描述**: 关注指定用户

**请求参数**:
| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| followUserId | Long | 是 | 被关注用户ID |

### 3.2 取消关注
- **接口**: `POST /relation/relation/unfollow`
- **描述**: 取消关注指定用户

**请求参数**:
| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| unfollowUserId | Long | 是 | 取消关注的用户ID |

### 3.3 关注列表
- **接口**: `POST /relation/relation/following/list`
- **描述**: 获取用户关注列表

**请求参数**:
| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| userId | Long | 是 | 用户ID |
| pageNo | Integer | 否 | 页码，默认1 |
| pageSize | Integer | 否 | 每页数量，默认10 |

**响应参数**:
| 参数名 | 类型 | 说明 |
|--------|------|------|
| userId | Long | 用户ID |
| nickname | String | 昵称 |
| avatar | String | 头像 |
| introduction | String | 简介 |
| fansTotal | Long | 粉丝数 |

### 3.4 粉丝列表
- **接口**: `POST /relation/relation/fans/list`
- **描述**: 获取用户粉丝列表

**请求参数**:
| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| userId | Long | 是 | 用户ID |
| pageNo | Integer | 否 | 页码 |
| pageSize | Integer | 否 | 每页数量 |

---

## 四、笔记模块 (Note)

### 4.1 发布笔记
- **接口**: `POST /note/note/publish`
- **描述**: 发布图文或视频笔记

**请求参数**:
| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| type | Integer | 是 | 笔记类型: 0-图文 1-视频 |
| title | String | 否 | 标题 |
| content | String | 否 | 正文内容 |
| imgUris | List<String> | 否 | 图片URL列表(图文笔记必填，最多8张) |
| videoUri | String | 否 | 视频URL(视频笔记必填) |
| topicId | Long | 否 | 话题ID |

### 4.2 笔记详情
- **接口**: `POST /note/note/detail`
- **描述**: 获取笔记详情

**请求参数**:
| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| id | Long | 是 | 笔记ID |

**响应参数**:
| 参数名 | 类型 | 说明 |
|--------|------|------|
| id | Long | 笔记ID |
| type | Integer | 笔记类型 |
| title | String | 标题 |
| content | String | 正文 |
| imgUris | List<String> | 图片列表 |
| videoUri | String | 视频URL |
| topicId | Long | 话题ID |
| topicName | String | 话题名称 |
| creatorId | Long | 作者ID |
| creatorName | String | 作者昵称 |
| avatar | String | 作者头像 |
| updateTime | String | 更新时间 |
| visible | Integer | 可见性 |
| isTop | Boolean | 是否置顶 |
| likeTotal | Long | 点赞数 |
| collectTotal | Long | 收藏数 |
| commentTotal | Long | 评论数 |
| isFollowed | Boolean | 是否已关注作者 |

### 4.3 修改笔记
- **接口**: `POST /note/note/update`
- **描述**: 修改笔记内容

**请求参数**:
| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| id | Long | 是 | 笔记ID |
| type | Integer | 是 | 笔记类型 |
| title | String | 否 | 标题 |
| content | String | 否 | 正文 |
| imgUris | List<String> | 否 | 图片列表 |
| videoUri | String | 否 | 视频URL |
| topicId | Long | 否 | 话题ID |

### 4.4 删除笔记
- **接口**: `POST /note/note/delete`
- **描述**: 删除笔记

**请求参数**:
| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| id | Long | 是 | 笔记ID |

### 4.5 设置笔记可见性
- **接口**: `POST /note/note/visible/onlyme`
- **描述**: 切换笔记公开/仅自己可见

**请求参数**:
| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| id | Long | 是 | 笔记ID |

### 4.6 置顶/取消置顶笔记
- **接口**: `POST /note/note/top`
- **描述**: 置顶或取消置顶笔记

**请求参数**:
| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| id | Long | 是 | 笔记ID |
| isTop | Boolean | 是 | true-置顶 false-取消置顶 |

### 4.7 点赞笔记
- **接口**: `POST /note/note/like`
- **描述**: 点赞笔记

**请求参数**:
| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| id | Long | 是 | 笔记ID |

### 4.8 取消点赞笔记
- **接口**: `POST /note/note/unlike`
- **描述**: 取消点赞笔记

**请求参数**:
| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| id | Long | 是 | 笔记ID |

### 4.9 收藏笔记
- **接口**: `POST /note/note/collect`
- **描述**: 收藏笔记

**请求参数**:
| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| id | Long | 是 | 笔记ID |

### 4.10 取消收藏笔记
- **接口**: `POST /note/note/uncollect`
- **描述**: 取消收藏笔记

**请求参数**:
| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| id | Long | 是 | 笔记ID |

### 4.11 获取点赞收藏状态
- **接口**: `POST /note/note/isLikedAndCollectedData`
- **描述**: 获取当前用户对笔记的点赞、收藏状态

**请求参数**:
| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| noteId | Long | 是 | 笔记ID |

**响应参数**:
| 参数名 | 类型 | 说明 |
|--------|------|------|
| isLiked | Boolean | 是否已点赞 |
| isCollected | Boolean | 是否已收藏 |

### 4.12 已发布笔记列表
- **接口**: `POST /note/note/published/list`
- **描述**: 获取用户已发布的笔记列表(游标分页)

**请求参数**:
| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| userId | Long | 是 | 用户ID |
| cursor | Long | 否 | 游标(上一页最后一条笔记ID) |

**响应参数**:
| 参数名 | 类型 | 说明 |
|--------|------|------|
| notes | List | 笔记列表 |
| nextCursor | Long | 下一页游标 |

**笔记列表项**:
| 参数名 | 类型 | 说明 |
|--------|------|------|
| noteId | Long | 笔记ID |
| type | Integer | 笔记类型 |
| title | String | 标题 |
| cover | String | 封面图 |
| videoUri | String | 视频URL |
| creatorId | Long | 作者ID |
| nickname | String | 作者昵称 |
| avatar | String | 作者头像 |
| likeTotal | Long | 点赞数 |
| isLiked | Boolean | 是否已点赞 |
| visible | Integer | 可见性 |
| isTop | Boolean | 是否置顶 |

### 4.13 点赞过的笔记列表
- **接口**: `POST /note/note/liked/list`
- **描述**: 获取用户点赞过的笔记列表(游标分页)

**请求参数**:
| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| userId | Long | 是 | 用户ID |
| cursor | Long | 否 | 游标 |

**响应参数**: 同已发布笔记列表

### 4.14 收藏的笔记列表
- **接口**: `POST /note/note/collected/list`
- **描述**: 获取用户收藏的笔记列表(游标分页)

**请求参数**:
| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| userId | Long | 是 | 用户ID |
| cursor | Long | 否 | 游标 |

**响应参数**: 同已发布笔记列表

### 4.15 发现页笔记列表
- **接口**: `POST /note/note/discover/list`
- **描述**: 发现页笔记分页查询

**请求参数**:
| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| pageNo | Integer | 否 | 页码 |
| pageSize | Integer | 否 | 每页数量 |
| channelId | Long | 否 | 频道ID |

---

## 五、频道/话题模块 (Channel)

### 5.1 获取频道列表
- **接口**: `POST /note/channel/list`
- **描述**: 获取所有频道列表

**响应参数**:
| 参数名 | 类型 | 说明 |
|--------|------|------|
| id | Long | 频道ID |
| name | String | 频道名称 |

### 5.2 获取话题列表
- **接口**: `POST /note/channel/topic/list`
- **描述**: 根据频道ID获取话题列表

**请求参数**:
| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| channelId | Long | 是 | 频道ID |

**响应参数**:
| 参数名 | 类型 | 说明 |
|--------|------|------|
| id | Long | 话题ID |
| name | String | 话题名称 |

---

## 六、评论模块 (Comment)

### 6.1 发布评论
- **接口**: `POST /comment/comment/publish`
- **描述**: 发布评论或回复

**请求参数**:
| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| noteId | Long | 是 | 笔记ID |
| content | String | 否 | 评论内容 |
| imageUrl | String | 否 | 评论图片URL |
| replyCommentId | Long | 否 | 回复的评论ID(回复时必填) |

### 6.2 评论列表
- **接口**: `POST /comment/comment/list`
- **描述**: 获取一级评论分页列表

**请求参数**:
| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| noteId | Long | 是 | 笔记ID |
| pageNo | Integer | 否 | 页码 |
| pageSize | Integer | 否 | 每页数量 |

**响应参数**:
| 参数名 | 类型 | 说明 |
|--------|------|------|
| id | Long | 评论ID |
| userId | Long | 评论者ID |
| nickname | String | 评论者昵称 |
| avatar | String | 评论者头像 |
| content | String | 评论内容 |
| imageUrl | String | 评论图片 |
| likeTotal | Long | 点赞数 |
| isLiked | Boolean | 是否已点赞 |
| createTime | String | 评论时间 |
| childCommentTotal | Integer | 子评论数 |
| childComments | List | 子评论列表(前2条) |

### 6.3 二级评论列表
- **接口**: `POST /comment/comment/child/list`
- **描述**: 获取二级评论分页列表

**请求参数**:
| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| parentCommentId | Long | 是 | 父评论ID |
| pageNo | Integer | 否 | 页码 |
| pageSize | Integer | 否 | 每页数量 |

### 6.4 评论点赞
- **接口**: `POST /comment/comment/like`
- **描述**: 点赞评论

**请求参数**:
| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| commentId | Long | 是 | 评论ID |

### 6.5 取消评论点赞
- **接口**: `POST /comment/comment/unlike`
- **描述**: 取消点赞评论

**请求参数**:
| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| commentId | Long | 是 | 评论ID |

### 6.6 删除评论
- **接口**: `POST /comment/comment/delete`
- **描述**: 删除评论

**请求参数**:
| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| commentId | Long | 是 | 评论ID |

---

## 七、搜索模块 (Search)

### 7.1 搜索笔记
- **接口**: `POST /search/search/note`
- **描述**: 搜索笔记

**请求参数**:
| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| keyword | String | 是 | 搜索关键词 |
| pageNo | Integer | 否 | 页码 |
| pageSize | Integer | 否 | 每页数量 |

**响应参数**:
| 参数名 | 类型 | 说明 |
|--------|------|------|
| noteId | Long | 笔记ID |
| title | String | 标题(高亮) |
| cover | String | 封面图 |
| type | Integer | 笔记类型 |
| nickname | String | 作者昵称 |
| avatar | String | 作者头像 |
| likeTotal | Long | 点赞数 |

### 7.2 搜索用户
- **接口**: `POST /search/search/user`
- **描述**: 搜索用户

**请求参数**:
| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| keyword | String | 是 | 搜索关键词 |
| pageNo | Integer | 否 | 页码 |
| pageSize | Integer | 否 | 每页数量 |

**响应参数**:
| 参数名 | 类型 | 说明 |
|--------|------|------|
| userId | Long | 用户ID |
| nickname | String | 昵称(高亮) |
| avatar | String | 头像 |
| introduction | String | 简介 |
| fansTotal | Long | 粉丝数 |

---

## 八、OSS模块 (文件上传)

### 8.1 上传文件
- **接口**: `POST /oss/file/upload`
- **描述**: 上传文件(图片/视频)
- **Content-Type**: multipart/form-data

**请求参数**:
| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| file | File | 是 | 文件 |

**响应示例**:
```json
{
  "success": true,
  "data": "https://xxx.oss.com/xxx.jpg"
}
```

---

## 九、聊天模块 (Chat)

### 9.1 获取会话列表
- **接口**: `POST /chat/chat/conversation/list`
- **描述**: 获取聊天会话列表

**请求参数**:
| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| cursor | Long | 否 | 游标 |

**响应参数**:
| 参数名 | 类型 | 说明 |
|--------|------|------|
| conversations | List | 会话列表 |
| nextCursor | Long | 下一页游标 |

**会话项**:
| 参数名 | 类型 | 说明 |
|--------|------|------|
| conversationId | Long | 会话ID |
| targetUserId | Long | 对方用户ID |
| targetNickname | String | 对方昵称 |
| targetAvatar | String | 对方头像 |
| lastMessage | String | 最后一条消息 |
| lastMessageTime | String | 最后消息时间 |
| unreadCount | Integer | 未读数 |

### 9.2 删除会话
- **接口**: `POST /chat/chat/conversation/delete`
- **描述**: 删除聊天会话

**请求参数**:
| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| conversationId | Long | 是 | 会话ID |

### 9.3 发送消息
- **接口**: `POST /chat/chat/message/send`
- **描述**: 发送聊天消息

**请求参数**:
| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| receiverId | Long | 是 | 接收者ID |
| content | String | 是 | 消息内容 |
| messageType | Integer | 否 | 消息类型: 0-文本 1-图片 2-系统消息 |

**响应参数**:
| 参数名 | 类型 | 说明 |
|--------|------|------|
| messageId | Long | 消息ID |
| conversationId | Long | 会话ID |
| createTime | String | 发送时间 |

### 9.4 获取消息列表
- **接口**: `POST /chat/chat/message/list`
- **描述**: 获取聊天消息列表

**请求参数**:
| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| conversationId | Long | 是 | 会话ID |
| cursor | Long | 否 | 游标 |

**响应参数**:
| 参数名 | 类型 | 说明 |
|--------|------|------|
| messages | List | 消息列表 |
| nextCursor | Long | 下一页游标 |

**消息项**:
| 参数名 | 类型 | 说明 |
|--------|------|------|
| messageId | Long | 消息ID |
| senderId | Long | 发送者ID |
| content | String | 消息内容 |
| messageType | Integer | 消息类型 |
| createTime | String | 发送时间 |
| isRead | Boolean | 是否已读 |

### 9.5 标记消息已读
- **接口**: `POST /chat/chat/message/read`
- **描述**: 标记消息为已读

**请求参数**:
| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| conversationId | Long | 是 | 会话ID |

### 9.6 删除消息
- **接口**: `POST /chat/chat/message/delete`
- **描述**: 删除消息

**请求参数**:
| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| messageId | Long | 是 | 消息ID |

### 9.7 获取未读消息数量
- **接口**: `POST /chat/chat/message/unread/count`
- **描述**: 获取未读消息总数

**响应参数**:
| 参数名 | 类型 | 说明 |
|--------|------|------|
| unreadCount | Integer | 未读消息数 |

---

## 附录

### 笔记类型
| 值 | 说明 |
|----|------|
| 0 | 图文笔记 |
| 1 | 视频笔记 |

### 可见性
| 值 | 说明 |
|----|------|
| 0 | 公开 |
| 1 | 仅自己可见 |

### 性别
| 值 | 说明 |
|----|------|
| 0 | 女 |
| 1 | 男 |

### 登录类型
| 值 | 说明 |
|----|------|
| 1 | 验证码登录 |
| 2 | 密码登录 |

### 消息类型
| 值 | 说明 |
|----|------|
| 0 | 文本消息 |
| 1 | 图片消息 |
| 2 | 系统消息 |
