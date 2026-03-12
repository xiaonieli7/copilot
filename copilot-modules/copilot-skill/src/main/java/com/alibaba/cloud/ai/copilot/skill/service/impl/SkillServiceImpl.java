package com.alibaba.cloud.ai.copilot.skill.service.impl;

import com.alibaba.cloud.ai.copilot.skill.config.SkillProperties;
import com.alibaba.cloud.ai.copilot.skill.domain.dto.CreateSkillRequest;
import com.alibaba.cloud.ai.copilot.skill.domain.dto.SkillDTO;
import com.alibaba.cloud.ai.copilot.skill.domain.dto.UpdateSkillRequest;
import com.alibaba.cloud.ai.copilot.skill.domain.entity.SkillMetadata;
import com.alibaba.cloud.ai.copilot.skill.mapper.SkillMetadataMapper;
import com.alibaba.cloud.ai.copilot.skill.service.SkillService;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.io.*;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import java.util.stream.Collectors;
import java.util.zip.ZipEntry;
import java.util.zip.ZipInputStream;
import java.util.zip.ZipOutputStream;

/**
 * 技能管理服务实现
 *
 * @author Alibaba Cloud AI Team
 * @since 1.0.0
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class SkillServiceImpl implements SkillService {

    private final SkillMetadataMapper skillMetadataMapper;
    private final SkillProperties skillProperties;
    private final ObjectMapper objectMapper;

    @Override
    public List<SkillDTO> listSkills(String scope) {
        log.info("查询技能列表, scope: {}", scope);

        LambdaQueryWrapper<SkillMetadata> queryWrapper = new LambdaQueryWrapper<>();

        if ("user".equalsIgnoreCase(scope)) {
            queryWrapper.eq(SkillMetadata::getScope, "user");
        } else if ("project".equalsIgnoreCase(scope)) {
            queryWrapper.eq(SkillMetadata::getScope, "project");
        }
        // "all" 或 null 则不添加 scope 条件

        List<SkillMetadata> metadataList = skillMetadataMapper.selectList(queryWrapper);

        return metadataList.stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    @Override
    public SkillDTO getSkill(String skillName) {
        log.info("获取技能详情: {}", skillName);

        LambdaQueryWrapper<SkillMetadata> queryWrapper = new LambdaQueryWrapper<>();
        queryWrapper.eq(SkillMetadata::getSkillName, skillName);
        SkillMetadata metadata = skillMetadataMapper.selectOne(queryWrapper);

        if (metadata == null) {
            throw new RuntimeException("技能不存在: " + skillName);
        }

        SkillDTO dto = convertToDTO(metadata);

        // 读取 SKILL.md 文件内容
        if (metadata.getFilePath() != null) {
            try {
                Path filePath = Paths.get(metadata.getFilePath());
                if (Files.exists(filePath)) {
                    dto.setContent(Files.readString(filePath));
                }
            } catch (IOException e) {
                log.warn("无法读取技能文件: {}", metadata.getFilePath(), e);
            }
        }

        return dto;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void createSkill(CreateSkillRequest request) {
        log.info("创建技能: {}", request.getSkillName());

        // 检查技能是否已存在
        LambdaQueryWrapper<SkillMetadata> queryWrapper = new LambdaQueryWrapper<>();
        queryWrapper.eq(SkillMetadata::getSkillName, request.getSkillName())
                .eq(SkillMetadata::getScope, request.getScope());

        if (skillMetadataMapper.selectCount(queryWrapper) > 0) {
            throw new RuntimeException("技能已存在: " + request.getSkillName());
        }

        // 确定技能目录
        String baseDir = "user".equalsIgnoreCase(request.getScope())
                ? skillProperties.getUserSkillsDirectory()
                : skillProperties.getProjectSkillsDirectory();

        String skillDir = baseDir + File.separator + request.getSkillName();
        String skillFilePath = skillDir + File.separator + "SKILL.md";

        // 创建技能目录和文件
        try {
            Files.createDirectories(Paths.get(skillDir));
            Files.writeString(Paths.get(skillFilePath), request.getContent());
            log.info("创建技能文件: {}", skillFilePath);
        } catch (IOException e) {
            throw new RuntimeException("无法创建技能文件: " + e.getMessage(), e);
        }

        // 保存元数据到数据库
        SkillMetadata metadata = new SkillMetadata();
        metadata.setSkillName(request.getSkillName());
        metadata.setDisplayName(request.getDisplayName());
        metadata.setDescription(request.getDescription());
        metadata.setScope(request.getScope());
        metadata.setEnabled(true);
        metadata.setCategory(request.getCategory());
        metadata.setVersion(request.getVersion());
        metadata.setTags(request.getTags());
        metadata.setDependencies(request.getDependencies());
        metadata.setFilePath(skillFilePath);
        metadata.setCreatedTime(LocalDateTime.now());
        metadata.setUpdatedTime(LocalDateTime.now());

        skillMetadataMapper.insert(metadata);
        log.info("技能创建成功: {}", request.getSkillName());
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void updateSkill(UpdateSkillRequest request) {
        log.info("更新技能: {}", request.getSkillName());

        LambdaQueryWrapper<SkillMetadata> queryWrapper = new LambdaQueryWrapper<>();
        queryWrapper.eq(SkillMetadata::getSkillName, request.getSkillName());
        SkillMetadata metadata = skillMetadataMapper.selectOne(queryWrapper);

        if (metadata == null) {
            throw new RuntimeException("技能不存在: " + request.getSkillName());
        }

        // 更新文件内容
        if (request.getContent() != null && metadata.getFilePath() != null) {
            try {
                Files.writeString(Paths.get(metadata.getFilePath()), request.getContent());
            } catch (IOException e) {
                throw new RuntimeException("无法更新技能文件: " + e.getMessage(), e);
            }
        }

        // 更新元数据
        if (request.getDisplayName() != null) {
            metadata.setDisplayName(request.getDisplayName());
        }
        if (request.getDescription() != null) {
            metadata.setDescription(request.getDescription());
        }
        if (request.getCategory() != null) {
            metadata.setCategory(request.getCategory());
        }
        if (request.getVersion() != null) {
            metadata.setVersion(request.getVersion());
        }
        if (request.getTags() != null) {
            metadata.setTags(request.getTags());
        }
        if (request.getDependencies() != null) {
            metadata.setDependencies(request.getDependencies());
        }
        metadata.setUpdatedTime(LocalDateTime.now());

        skillMetadataMapper.updateById(metadata);
        log.info("技能更新成功: {}", request.getSkillName());
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void deleteSkill(String skillName, String scope) {
        log.info("删除技能: {}, scope: {}", skillName, scope);

        LambdaQueryWrapper<SkillMetadata> queryWrapper = new LambdaQueryWrapper<>();
        queryWrapper.eq(SkillMetadata::getSkillName, skillName)
                .eq(SkillMetadata::getScope, scope);
        SkillMetadata metadata = skillMetadataMapper.selectOne(queryWrapper);

        if (metadata == null) {
            throw new RuntimeException("技能不存在: " + skillName);
        }

        // 删除文件目录
        if (metadata.getFilePath() != null) {
            try {
                Path skillDir = Paths.get(metadata.getFilePath()).getParent();
                deleteDirectory(skillDir.toFile());
                log.info("删除技能目录: {}", skillDir);
            } catch (Exception e) {
                log.warn("无法删除技能目录", e);
            }
        }

        // 删除数据库记录
        skillMetadataMapper.deleteById(metadata.getId());
        log.info("技能删除成功: {}", skillName);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void toggleSkill(String skillName, boolean enabled) {
        log.info("切换技能状态: {}, enabled: {}", skillName, enabled);

        LambdaQueryWrapper<SkillMetadata> queryWrapper = new LambdaQueryWrapper<>();
        queryWrapper.eq(SkillMetadata::getSkillName, skillName);
        SkillMetadata metadata = skillMetadataMapper.selectOne(queryWrapper);

        if (metadata == null) {
            throw new RuntimeException("技能不存在: " + skillName);
        }

        metadata.setEnabled(enabled);
        metadata.setUpdatedTime(LocalDateTime.now());
        skillMetadataMapper.updateById(metadata);

        log.info("技能状态切换成功: {}", skillName);
    }

    @Override
    public String exportSkill(String skillName) {
        log.info("导出技能: {}", skillName);

        SkillDTO skill = getSkill(skillName);

        try {
            return objectMapper.writeValueAsString(skill);
        } catch (Exception e) {
            throw new RuntimeException("导出技能失败: " + e.getMessage(), e);
        }
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void importSkill(String skillData) {
        log.info("导入技能");

        try {
            SkillDTO skill = objectMapper.readValue(skillData, SkillDTO.class);

            CreateSkillRequest request = new CreateSkillRequest();
            request.setSkillName(skill.getSkillName());
            request.setDisplayName(skill.getDisplayName());
            request.setDescription(skill.getDescription());
            request.setScope(skill.getScope());
            request.setContent(skill.getContent());
            request.setCategory(skill.getCategory());
            request.setVersion(skill.getVersion());
            request.setTags(skill.getTags());
            request.setDependencies(skill.getDependencies());

            createSkill(request);
            log.info("技能导入成功");
        } catch (Exception e) {
            throw new RuntimeException("导入技能失败: " + e.getMessage(), e);
        }
    }

    @Override
    public void exportSkillZip(String skillName, OutputStream outputStream) {
        log.info("导出技能为 ZIP: {}", skillName);

        LambdaQueryWrapper<SkillMetadata> queryWrapper = new LambdaQueryWrapper<>();
        queryWrapper.eq(SkillMetadata::getSkillName, skillName);
        SkillMetadata metadata = skillMetadataMapper.selectOne(queryWrapper);

        if (metadata == null || metadata.getFilePath() == null) {
            throw new RuntimeException("技能不存在或文件路径为空: " + skillName);
        }

        Path skillPath = Paths.get(metadata.getFilePath()).getParent();
        if (!Files.exists(skillPath)) {
            throw new RuntimeException("技能目录不存在: " + skillPath);
        }

        try (ZipOutputStream zos = new ZipOutputStream(outputStream)) {
            Files.walk(skillPath).forEach(path -> {
                if (Files.isDirectory(path)) return;
                ZipEntry zipEntry = new ZipEntry(skillPath.relativize(path).toString());
                try {
                    zos.putNextEntry(zipEntry);
                    Files.copy(path, zos);
                    zos.closeEntry();
                } catch (IOException e) {
                    log.error("压缩文件失败: {}", path, e);
                }
            });
        } catch (IOException e) {
            throw new RuntimeException("导出 ZIP 失败: " + e.getMessage(), e);
        }
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void importSkillZip(InputStream inputStream, String scope) {
        log.info("从 ZIP 导入技能, scope: {}", scope);

        String baseDir = "user".equalsIgnoreCase(scope)
                ? skillProperties.getUserSkillsDirectory()
                : skillProperties.getProjectSkillsDirectory();

        try (ZipInputStream zis = new ZipInputStream(inputStream)) {
            ZipEntry entry;
            String skillName = null;
            Path skillPath = null;

            while ((entry = zis.getNextEntry()) != null) {
                if (entry.isDirectory()) continue;

                // 假设 ZIP 包结构是直接放技能文件的，第一个文件所在的目录名即为技能名
                // 或者我们可以从 SKILL.md 中解析
                String entryName = entry.getName();
                Path targetPath = Paths.get(baseDir, entryName).normalize();

                // Zip Slip 防护：校验目标路径是否仍在 baseDir 目录下
                if (!targetPath.startsWith(Paths.get(baseDir).normalize())) {
                    throw new RuntimeException("非法的 ZIP 条目路径: " + entryName);
                }

                // 记录技能名称 (取第一层目录)
                if (skillName == null) {
                    skillName = Paths.get(entryName).getName(0).toString();
                    skillPath = Paths.get(baseDir, skillName);
                }

                Files.createDirectories(targetPath.getParent());
                Files.copy(zis, targetPath, java.nio.file.StandardCopyOption.REPLACE_EXISTING);
                zis.closeEntry();
            }

            if (skillName != null && skillPath != null) {
                // 扫描导入后的 SKILL.md 并注册到数据库
                registerImportedSkill(skillName, skillPath, scope);
            }

        } catch (IOException e) {
            throw new RuntimeException("导入 ZIP 失败: " + e.getMessage(), e);
        }
    }

    /**
     * 注册导入后的技能到数据库
     */
    private void registerImportedSkill(String skillName, Path skillPath, String scope) {
        Path skillMdPath = skillPath.resolve("SKILL.md");
        if (!Files.exists(skillMdPath)) {
            log.warn("导入的技能目录中缺少 SKILL.md: {}", skillPath);
            return;
        }

        try {
            String content = Files.readString(skillMdPath);
            String description = extractFromFrontmatter(content, "description");
            String realName = extractFromFrontmatter(content, "name");
            if (realName != null) skillName = realName;

            // 检查数据库记录
            LambdaQueryWrapper<SkillMetadata> queryWrapper = new LambdaQueryWrapper<>();
            queryWrapper.eq(SkillMetadata::getSkillName, skillName).eq(SkillMetadata::getScope, scope);
            SkillMetadata metadata = skillMetadataMapper.selectOne(queryWrapper);

            if (metadata == null) {
                metadata = new SkillMetadata();
                metadata.setCreatedTime(LocalDateTime.now());
            }

            metadata.setSkillName(skillName);
            metadata.setDescription(description);
            metadata.setScope(scope);
            metadata.setFilePath(skillMdPath.toString());
            metadata.setEnabled(true);
            metadata.setUpdatedTime(LocalDateTime.now());

            if (metadata.getId() == null) {
                skillMetadataMapper.insert(metadata);
            } else {
                skillMetadataMapper.updateById(metadata);
            }
            log.info("导入技能已注册: {}", skillName);

        } catch (IOException e) {
            log.error("解析导入技能失败: {}", skillName, e);
        }
    }

    private String extractFromFrontmatter(String content, String key) {
        Pattern pattern = Pattern.compile("---[\\s\\S]*?" + key + ":\\s*(.*?)\\s*\\n[\\s\\S]*?---");
        Matcher matcher = pattern.matcher(content);
        if (matcher.find()) {
            return matcher.group(1).trim();
        }
        return null;
    }

    /**
     * 转换为 DTO
     */
    private SkillDTO convertToDTO(SkillMetadata metadata) {
        SkillDTO dto = new SkillDTO();
        dto.setId(metadata.getId());
        dto.setSkillName(metadata.getSkillName());
        dto.setDisplayName(metadata.getDisplayName());
        dto.setDescription(metadata.getDescription());
        dto.setScope(metadata.getScope());
        dto.setEnabled(metadata.getEnabled());
        dto.setCategory(metadata.getCategory());
        dto.setVersion(metadata.getVersion());
        dto.setAuthor(metadata.getAuthor());
        dto.setTags(metadata.getTags());
        dto.setDependencies(metadata.getDependencies());
        dto.setFilePath(metadata.getFilePath());
        return dto;
    }

    /**
     * 递归删除目录
     */
    private void deleteDirectory(File directory) {
        if (directory.isDirectory()) {
            File[] files = directory.listFiles();
            if (files != null) {
                for (File file : files) {
                    deleteDirectory(file);
                }
            }
        }
        directory.delete();
    }

}
