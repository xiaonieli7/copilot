import React, { useState } from "react";
import { message } from "antd";

interface CreateSkillModalProps {
  open: boolean;
  onClose: () => void;
  onCreate: (payload: {
    skillName: string;
    scope: "user" | "project";
    description?: string;
    content: string;
  }) => Promise<void>;
}

export default function CreateSkillModal({
  open,
  onClose,
  onCreate,
}: CreateSkillModalProps) {
  const [skillName, setSkillName] = useState("");
  const [scope, setScope] = useState<"user" | "project">("user");
  const [description, setDescription] = useState("");
  const [content, setContent] = useState("# 技能名称\n\n## 描述\n\n## 使用方法\n");
  const [submitting, setSubmitting] = useState(false);

  if (!open) return null;

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    if (!skillName) {
      message.error("请输入技能 ID");
      return;
    }

    setSubmitting(true);
    try {
      // 官方 Skills 规范：SKILL.md 顶部需要 YAML frontmatter
      const frontmatter = `---
name: ${skillName}
description: ${description || "AI 技能包"}
---

`;
      const finalContent = frontmatter + content;

      await onCreate({
        skillName,
        scope,
        description,
        content: finalContent,
      });
      
      message.success("技能创建成功");
      
      // Reset form
      setSkillName("");
      setScope("user");
      setDescription("");
      setContent("# 技能名称\n\n## 描述\n\n## 使用方法\n");
    } catch (err: any) {
      console.error(err);
      message.error(err.message || "创建失败，请检查名称是否重复或符合规范");
    } finally {
      setSubmitting(false);
    }
  }

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/50">
      <div className="bg-white dark:bg-[#18181a] w-full max-w-2xl rounded-xl shadow-2xl flex flex-col max-h-[90vh]">
        <div className="px-6 py-4 border-b border-gray-200 dark:border-[#333333] flex items-center justify-between">
          <h3 className="text-lg font-bold">创建新技能</h3>
          <button
            onClick={onClose}
            className="text-gray-400 hover:text-gray-600 dark:hover:text-gray-200"
          >
            <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
            </svg>
          </button>
        </div>

        <form onSubmit={handleSubmit} className="flex flex-col flex-1 overflow-hidden">
          <div className="flex-1 p-6 overflow-y-auto space-y-4">
            <div>
              <label className="block text-sm font-medium mb-1">技能 ID (唯一标识)</label>
              <input
                type="text"
                required
                placeholder="例如: code-helper (仅限小写字母、数字、连字符)"
                className="w-full px-3 py-2 rounded-lg border border-gray-200 dark:border-[#333333] bg-transparent outline-none focus:ring-2 focus:ring-black dark:focus:ring-white/20"
                value={skillName}
                onChange={(e) => setSkillName(e.target.value.toLowerCase().replace(/[^a-z0-9-]/g, ""))}
              />
            </div>

            <div>
              <label className="block text-sm font-medium mb-1">存储范围</label>
              <div className="flex gap-4">
                <label className="flex items-center gap-2 cursor-pointer">
                  <input
                    type="radio"
                    checked={scope === "user"}
                    onChange={() => setScope("user")}
                    className="w-4 h-4 text-black focus:ring-black"
                  />
                  <span className="text-sm">用户级 (~/.copilot/skills)</span>
                </label>
                <label className="flex items-center gap-2 cursor-pointer">
                  <input
                    type="radio"
                    checked={scope === "project"}
                    onChange={() => setScope("project")}
                    className="w-4 h-4 text-black focus:ring-black"
                  />
                  <span className="text-sm">项目级 (./skills)</span>
                </label>
              </div>
            </div>

            <div>
              <label className="block text-sm font-medium mb-1">简短描述</label>
              <input
                type="text"
                placeholder="简要说明此技能的用途"
                className="w-full px-3 py-2 rounded-lg border border-gray-200 dark:border-[#333333] bg-transparent outline-none focus:ring-2 focus:ring-black dark:focus:ring-white/20"
                value={description}
                onChange={(e) => setDescription(e.target.value)}
              />
            </div>

            <div className="flex flex-col h-64">
              <label className="block text-sm font-medium mb-1">SKILL.md 内容</label>
              <textarea
                required
                className="flex-1 w-full px-3 py-2 rounded-lg border border-gray-200 dark:border-[#333333] bg-transparent outline-none focus:ring-2 focus:ring-black dark:focus:ring-white/20 resize-none font-mono text-sm"
                value={content}
                onChange={(e) => setContent(e.target.value)}
              />
            </div>
          </div>

          <div className="px-6 py-4 border-t border-gray-200 dark:border-[#333333] flex justify-end gap-3">
            <button
              type="button"
              onClick={onClose}
              className="px-4 py-2 rounded-lg text-sm font-medium hover:bg-gray-100 dark:hover:bg-[#2a2a2a]"
            >
              取消
            </button>
            <button
              type="submit"
              disabled={submitting || !skillName}
              className="px-4 py-2 rounded-lg text-sm font-medium bg-black text-white dark:bg-white dark:text-black hover:opacity-90 disabled:opacity-50"
            >
              {submitting ? "创建中..." : "立即创建"}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}
