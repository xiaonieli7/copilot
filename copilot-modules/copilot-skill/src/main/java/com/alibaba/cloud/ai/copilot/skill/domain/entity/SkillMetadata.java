package com.alibaba.cloud.ai.copilot.skill.domain.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import com.baomidou.mybatisplus.extension.handlers.JacksonTypeHandler;
import lombok.Data;

import java.time.LocalDateTime;
import java.util.List;

/**
 * 技能元数据实体
 *
 * @author better
 * @since 1.0.0
 */
@Data
@TableName(value = "skill_metadata", autoResultMap = true)
public class SkillMetadata {

    /**
     * 主键ID
     */
    @TableId(type = IdType.ASSIGN_ID)
    private Long id;

    /**
     * 技能名称 (唯一标识)
     */
    private String skillName;

    /**
     * 显示名称
     */
    private String displayName;

    /**
     * 技能描述
     */
    private String description;

    /**
     * 范围: user/project
     */
    private String scope;

    /**
     * 是否启用
     */
    private Boolean enabled;

    /**
     * 分类
     */
    private String category;

    /**
     * 版本
     */
    private String version;

    /**
     * 作者
     */
    private String author;

    /**
     * 标签 (JSON 数组)
     */
    @TableField(typeHandler = JacksonTypeHandler.class)
    private List<String> tags;

    /**
     * 依赖的工具 (JSON 数组)
     */
    @TableField(typeHandler = JacksonTypeHandler.class)
    private List<String> dependencies;

    /**
     * 文件路径
     */
    private String filePath;

    /**
     * 用户ID (用户级技能)
     */
    private Long userId;

    /**
     * 创建时间
     */
    private LocalDateTime createdTime;

    /**
     * 更新时间
     */
    private LocalDateTime updatedTime;

}
