"use strict";

const cloudbase = require("@cloudbase/node-sdk");

const ZHIPU_ENDPOINT = "https://open.bigmodel.cn/api/paas/v4/chat/completions";
const DEFAULT_CONFIG = {
  model: "glm-4.7-flash",
  temperature: 0.82,
  maxTokens: 360,
  style: "friend_companion",
  targetLength: "90-140",
  enableMultimodal: false,
  enableShareVersion: false
};

exports.main = async (event) => {
  const payload = normalizePayload(event);
  const cloud = createCloudBaseApp();
  const remoteConfig = await loadGenerationConfig(cloud);
  const config = {
    ...DEFAULT_CONFIG,
    ...remoteConfig,
    model: process.env.ZHIPU_MODEL || remoteConfig.model || payload.model || DEFAULT_CONFIG.model,
    temperature: Number(process.env.ZHIPU_TEMPERATURE || remoteConfig.temperature || payload.temperature || DEFAULT_CONFIG.temperature),
    maxTokens: Number(process.env.ZHIPU_MAX_TOKENS || remoteConfig.maxTokens || payload.maxTokens || DEFAULT_CONFIG.maxTokens)
  };
  const apiKey = process.env.ZHIPU_API_KEY;
  if (!apiKey) {
    throw new Error("Missing ZHIPU_API_KEY in CloudBase environment variables.");
  }

  const response = await fetch(ZHIPU_ENDPOINT, {
    method: "POST",
    headers: {
      "Authorization": `Bearer ${apiKey}`,
      "Content-Type": "application/json"
    },
    body: JSON.stringify({
      model: config.model,
      temperature: config.temperature,
      max_tokens: config.maxTokens,
      messages: [
        { role: "system", content: systemPrompt(config) },
        { role: "user", content: userPrompt(payload) }
      ]
    })
  });

  if (!response.ok) {
    const message = await response.text();
    throw new Error(`Zhipu request failed: ${response.status} ${message}`);
  }

  const result = await response.json();
  const statement = result?.choices?.[0]?.message?.content?.trim();
  if (!statement) {
    throw new Error("Zhipu returned an empty declaration.");
  }

  const sanitized = sanitizeStatement(statement);
  const recordId = await saveDeclarationRecord(cloud, event, payload, sanitized, config);

  return {
    statement: sanitized,
    recordId,
    model: config.model,
    style: config.style,
    targetLength: config.targetLength
  };
};

function normalizePayload(event) {
  if (typeof event === "string") {
    return JSON.parse(event);
  }
  if (event?.body) {
    return typeof event.body === "string" ? JSON.parse(event.body) : event.body;
  }
  return event || {};
}

function createCloudBaseApp() {
  try {
    return cloudbase.init({
      env: process.env.TCB_ENV || cloudbase.SYMBOL_CURRENT_ENV
    });
  } catch (error) {
    console.warn("CloudBase init failed, continue without database:", error.message);
    return null;
  }
}

async function loadGenerationConfig(cloud) {
  if (!cloud) return {};
  try {
    const result = await cloud
      .database()
      .collection("spoonie_remote_config")
      .doc("declaration_generation")
      .get();
    const data = Array.isArray(result.data) ? result.data[0] : result.data;
    return data || {};
  } catch (error) {
    console.warn("Use default declaration config:", error.message);
    return {};
  }
}

async function saveDeclarationRecord(cloud, event, payload, statement, config) {
  if (!cloud) return null;
  try {
    const record = {
      userId: resolveUserId(event),
      clientRecordId: payload.clientRecordId || null,
      dateISO: payload.dateISO || new Date().toISOString(),
      tags: Array.isArray(payload.tags) ? payload.tags : [],
      weatherNarrative: payload.weatherNarrative || "",
      weatherShort: payload.weatherShort || "",
      primaryState: payload.primaryState || "",
      supplementalNoteHint: payload.supplementalNoteHint || "",
      supplementalImageCount: Number(payload.supplementalImageCount || 0),
      supplementalImageRefs: Array.isArray(payload.supplementalImageRefs) ? payload.supplementalImageRefs : [],
      statement,
      model: config.model,
      style: config.style,
      targetLength: config.targetLength,
      modelVersion: config.modelVersion || config.model,
      createdAt: new Date()
    };
    const result = await cloud.database().collection("spoonie_daily_declarations").add(record);
    return result.id || result._id || null;
  } catch (error) {
    console.warn("Save declaration record failed:", error.message);
    return null;
  }
}

function resolveUserId(event) {
  return (
    event?.userId ||
    event?.userInfo?.uid ||
    event?.userInfo?.openId ||
    event?.userInfo?.openid ||
    event?.requestContext?.authorizer?.uid ||
    "anonymous"
  );
}

function systemPrompt(config) {
  return [
    "你是「勺子星人」App 的今日声明生成器。",
    "你的语气像一个懂用户的朋友：温柔、具体、轻一点，不像心理咨询师，也不鸡汤。",
    `输出中文，${config.targetLength || DEFAULT_CONFIG.targetLength}字，分成3个自然段。`,
    "结构：第一段承认情绪；第二段把状态词、天气和补充内容转成生活化共鸣；第三段给轻量允许感。",
    "禁止诊断疾病，禁止说教，禁止承诺明天一定会好。",
    "用户补充内容是隐私上下文，只可轻影响语气和场景，不要逐字复述具体隐私。"
  ].join("\n");
}

function userPrompt(payload) {
  const tags = Array.isArray(payload.tags) ? payload.tags.join("、") : "";
  const weather = payload.weatherShort || payload.weatherNarrative || "无天气";
  const extra = payload.supplementalNoteHint || "";
  const imageCount = Number(payload.supplementalImageCount || 0);

  return [
    `状态词：${tags || "没有明确状态词"}`,
    `天气：${weather}`,
    `日期：${payload.dateISO || "未提供"}`,
    `主要IP状态：${payload.primaryState || "unknown"}`,
    `用户补充上下文摘要：${extra || "无"}`,
    `用户补充图片数量：${imageCount}`,
    "请生成今日声明。不要使用标题、编号或引号。"
  ].join("\n");
}

function sanitizeStatement(text) {
  return text
    .replace(/^今日声明[:：]\s*/u, "")
    .replace(/\n{3,}/g, "\n\n")
    .trim();
}
