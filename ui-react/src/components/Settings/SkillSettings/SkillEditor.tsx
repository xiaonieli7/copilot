import React, { useEffect, useMemo, useState } from "react";
import { message } from "antd";
import type { SkillDTO } from "@/api/skill";

export default function SkillEditor(props: {
  skill: SkillDTO | null;
  loading: boolean;
  onSave: (content: string) => Promise<void>;
}) {
  const { skill, loading, onSave } = props;

  const initialContent = useMemo(() => skill?.content ?? "", [skill]);
  const [content, setContent] = useState(initialContent);
  const [saving, setSaving] = useState(false);

  useEffect(() => {
    setContent(initialContent);
  }, [initialContent]);

  const dirty = content !== initialContent;

  async function handleSave() {
    if (!skill) return;
    setSaving(true);
    try {
      await onSave(content);
      message.success("保存成功");
    } catch (err: any) {
      message.error(err?.message || "保存失败");
      throw err;
    } finally {
      setSaving(false);
    }
  }

  return (
    <div className="flex flex-col h-full">
      <div className="px-3 py-2 border-b border-gray-200 dark:border-[#333333] flex items-center justify-between">
        <div className="min-w-0">
          <div className="text-[13px] font-bold truncate">
            {skill?.skillName || "未选择技能"}
          </div>
          {skill?.description ? (
            <div className="text-[12px] text-gray-500 dark:text-gray-400 line-clamp-1 mt-0.5">
              {skill.description}
            </div>
          ) : null}
        </div>

        <div className="flex items-center gap-2">
          {dirty ? (
            <div className="text-[12px] text-orange-600 dark:text-orange-400">未保存</div>
          ) : (
            <div className="text-[12px] text-gray-400">已保存</div>
          )}
          <button
            className="px-3 py-1.5 rounded-lg text-[13px] bg-black text-white hover:opacity-90 disabled:opacity-50"
            onClick={() => void handleSave()}
            disabled={!skill || loading || saving || !dirty}
          >
            {saving ? "保存中..." : "保存"}
          </button>
        </div>
      </div>

      <div className="flex-1 overflow-y-auto">
        {loading ? (
          <div className="p-3 text-[13px] text-gray-500">加载中...</div>
        ) : !skill ? (
          <div className="p-3 text-[13px] text-gray-500">请选择一个技能进行编辑</div>
        ) : (
          <div className="p-3 h-full">
            <textarea
              className="w-full h-full min-h-[480px] resize-none rounded-lg border border-gray-200 dark:border-[#333333] bg-white dark:bg-[#18181a] p-3 text-[13px] outline-none"
              value={content}
              onChange={(e) => setContent(e.target.value)}
              placeholder="请输入 SKILL.md 内容"
            />
          </div>
        )}
      </div>
    </div>
  );
}
