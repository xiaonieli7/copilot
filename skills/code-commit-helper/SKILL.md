---
name: code-commit-helper
description: 生成规范的 Git Commit Message，撰写清晰的 PR 描述，并提供高质量代码注释规范。
---

# 技能名称: 代码提交助手 (Code Commit Helper)

## 📝 描述

这个技能帮助你生成规范的 Git Commit 消息、添加高质量的代码注释，以及编写清晰的 Pull Request 描述。它遵循业界最佳实践，确保代码提交历史清晰、易于追溯123。

## 🎯 适用场景

当用户提到以下关键词时，你应该使用此技能：
- "生成 commit message"
- "写 commit"
- "提交代码"
- "添加注释"
- "写注释"
- "生成 PR 描述"
- "Pull Request"
- "代码审查"

## 📋 使用规则

### 1. Commit Message 生成

**格式规范**（遵循 Conventional Commits）:
```
<type>(<scope>): <subject>

<body>

<footer>
```

**Type 类型**:
- `feat`: 新功能
- `fix`: Bug 修复
- `docs`: 文档更新
- `style`: 代码格式调整（不影响功能）
- `refactor`: 重构（不是新功能，也不是修 bug）
- `perf`: 性能优化
- `test`: 测试相关
- `chore`: 构建过程或辅助工具的变动
- `ci`: CI/CD 配置修改

**示例**:
```
feat(user-auth): 添加 JWT 登录认证功能

- 实现了基于 JWT 的用户登录认证
- 添加了 LoginController 和 AuthService
- 集成 Redis 存储 Token，支持过期自动刷新
- 添加了登录失败次数限制（5次/10分钟）

Closes #123

Co-Authored-By: AI Assistant <ai@copilot.com>
```

### 2. 代码注释规范

**注释原则**:
- 使用中文编写注释（除非项目要求英文）
- 解释 "为什么" 而不是 "是什么"
- 简洁明了，避免废话
- 为复杂逻辑添加注释

**Java 示例**:
```java
/**
 * 用户认证服务
 *
 * 提供基于 JWT 的用户登录、注销和 Token 刷新功能
 *
 * @author Alibaba Cloud AI Team
 * @since 1.0.0
 */
@Service
public class AuthService {

    /**
     * 用户登录
     *
     * @param username 用户名
     * @param password 密码
     * @return JWT Token
     * @throws AuthenticationException 认证失败时抛出
     */
    public String login(String username, String password) {
        // 验证用户名和密码
        // ...

        // 生成 JWT Token（有效期 7 天）
        String token = jwtUtil.generateToken(user);

        // 存储到 Redis，用于 Token 刷新和注销
        redisTemplate.opsForValue().set(
            "token:" + user.getId(),
            token,
            7,
            TimeUnit.DAYS
        );

        return token;
    }
}
```

### 3. Pull Request 描述

**PR 描述模板**:
```markdown
## 📌 变更内容

- 添加了 XXX 功能
- 修复了 XXX Bug
- 重构了 XXX 模块

## 🎯 变更原因

解释为什么需要这次变更，背景是什么。

## 🧪 测试计划

- [ ] 单元测试通过
- [ ] 集成测试通过
- [ ] 手动测试场景：
  - 场景1: ...
  - 场景2: ...

## 📊 影响范围

- 影响模块: XXX, YYY
- 是否有破坏性变更: 否
- 是否需要更新文档: 否

## 📸 截图/演示

（可选）添加截图或 GIF 演示

## 🔗 相关 Issue

Closes #123
Relates to #456
```

## 💡 示例对话

**用户**: "帮我生成这次提交的 commit message，我添加了用户登录功能"

**AI 回复**:
```
feat(auth): 添加用户登录功能

- 实现了基于 JWT 的登录认证
- 添加了 LoginController 和 AuthService
- 集成了 Redis 存储 Token
- 添加了登录失败次数限制

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>
```

---

**用户**: "给这个方法添加注释"

**AI 回复**:
```java
/**
 * 刷新 JWT Token
 *
 * 当 Token 即将过期时（剩余有效期 < 1天），自动生成新的 Token
 * 并延长 Redis 中的过期时间
 *
 * @param oldToken 旧的 Token
 * @return 新的 Token，如果不需要刷新则返回原 Token
 */
public String refreshToken(String oldToken) {
    // ...
}
```

## 🛠️ 依赖工具

无（纯文本生成）

## 📚 参考资料

- [Conventional Commits 规范](https://www.conventionalcommits.org/)
- [如何写好 Git Commit Message](https://chris.beams.io/posts/git-commit/)

## ✅ 检查清单

使用此技能生成内容时，确保：
- [ ] Commit message 格式正确
- [ ] 包含必要的上下文信息
- [ ] 注释简洁明了
- [ ] PR 描述完整

---

**版本**: 1.0.0
**作者**: Alibaba Cloud AI Team
**更新时间**: 2026-02-09
