package com.alibaba.cloud.ai.copilot.skill.config;

import com.alibaba.cloud.ai.graph.agent.hook.skills.SkillsAgentHook;
import com.alibaba.cloud.ai.graph.skills.registry.SkillRegistry;
import com.alibaba.cloud.ai.graph.skills.registry.filesystem.FileSystemSkillRegistry;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.boot.context.properties.EnableConfigurationProperties;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import java.io.File;

/**
 * Skills 功能配置类
 *
 * @author better
 * @since 1.0.0
 */
@Slf4j
@Configuration
@EnableConfigurationProperties(SkillProperties.class)
@RequiredArgsConstructor
public class SkillConfig {

    private final SkillProperties skillProperties;

    /**
     * 创建技能注册表 Bean
     * 使用文件系统实现，支持用户级和项目级技能目录
     */
    @Bean
    @ConditionalOnProperty(prefix = "app.skill", name = "enabled", havingValue = "true", matchIfMissing = true)
    public SkillRegistry skillRegistry() {
        log.info("初始化 Skill Registry");
        log.info("用户级技能目录: {}", skillProperties.getUserSkillsDirectory());
        log.info("项目级技能目录: {}", skillProperties.getProjectSkillsDirectory());

        // 确保技能目录存在
        ensureDirectoryExists(skillProperties.getUserSkillsDirectory());
        ensureDirectoryExists(skillProperties.getProjectSkillsDirectory());

        return FileSystemSkillRegistry.builder()
                .userSkillsDirectory(skillProperties.getUserSkillsDirectory())
                .projectSkillsDirectory(skillProperties.getProjectSkillsDirectory())
                .build();
    }

    /**
     * 创建 Skills Agent Hook Bean
     * 用于在 ReactAgent 中自动加载和注入技能
     */
    @Bean
    @ConditionalOnProperty(prefix = "app.skill", name = "enabled", havingValue = "true", matchIfMissing = true)
    public SkillsAgentHook skillsAgentHook(SkillRegistry skillRegistry) {
        log.info("初始化 Skills Agent Hook");
        return SkillsAgentHook.builder()
                .skillRegistry(skillRegistry)
                .autoReload(false)
                .build();
    }

    /**
     * 确保目录存在，如果不存在则创建
     */
    private void ensureDirectoryExists(String directoryPath) {
        File directory = new File(directoryPath);
        if (!directory.exists()) {
            boolean created = directory.mkdirs();
            if (created) {
                log.info("创建技能目录: {}", directoryPath);
            } else {
                log.warn("无法创建技能目录: {}", directoryPath);
            }
        }
    }

}
