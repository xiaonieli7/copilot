package com.alibaba.cloud.ai.copilot.skill.config;

import lombok.Data;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.stereotype.Component;

/**
 * Skills 功能配置属性
 *
 * @author better
 * @since 1.0.0
 */
@Data
@Component
@ConfigurationProperties(prefix = "app.skill")
public class SkillProperties {

    /**
     * 是否启用技能功能
     */
    private boolean enabled = true;

    /**
     * 用户级技能目录 (默认: ~/.copilot/skills)
     */
    private String userSkillsDirectory = System.getProperty("user.home") + "/.copilot/skills";

    /**
     * 项目级技能目录 (默认: ./skills)
     */
    private String projectSkillsDirectory = "./skills";

    /**
     * 是否启用技能市场
     */
    private boolean marketEnabled = true;

    /**
     * 技能市场 API 地址
     */
    private String marketApiUrl = "";

    /**
     * 是否延迟加载技能 (false 则启动时加载)
     */
    private boolean lazyLoad = false;

}
