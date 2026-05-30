import { readFileSync, writeFileSync } from "node:fs";

const outDir = new URL("../figma-export/", import.meta.url);
const referencePath = new URL("spoonie-main-pages-reference.png", outDir);
const editablePath = new URL("spoonie-main-pages-editable.svg", outDir);
const exactPath = new URL("spoonie-main-pages-reference-embedded.svg", outDir);

const phone = (x, title, subtitle, body) => `
  <g id="${title}" transform="translate(${x} 26)">
    <rect x="0" y="0" width="467" height="972" rx="38" fill="url(#phoneFill)" stroke="#FFFFFF" stroke-opacity=".78"/>
    <text x="38" y="36" class="status">9:41</text>
    <g transform="translate(362 24)" fill="#17172E">
      <rect x="0" y="10" width="4" height="10" rx="2"/>
      <rect x="7" y="6" width="4" height="14" rx="2"/>
      <rect x="14" y="2" width="4" height="18" rx="2"/>
      <path d="M28 9c8-7 20-7 28 0l-4 4c-5-4-15-4-20 0z"/>
      <rect x="66" y="5" width="28" height="14" rx="3" fill="none" stroke="#17172E" stroke-width="2"/>
      <rect x="69" y="8" width="20" height="8" rx="2"/>
    </g>
    ${body}
  </g>
`;

const pill = (x, y, text, selected = false, w = 116, rotate = 0) => `
  <g transform="translate(${x} ${y}) rotate(${rotate})">
    <rect width="${w}" height="50" rx="25" fill="${selected ? "#9183F0" : "#FFFFFF"}" opacity="${selected ? "1" : ".82"}"/>
    <text x="${w / 2}" y="31" text-anchor="middle" class="${selected ? "pillSelected" : "pill"}">${text}</text>
    ${selected ? `<circle cx="${w - 24}" cy="25" r="11" fill="#FFFFFF" opacity=".62"/><path d="M${w - 29} 24l4 4 8-9" fill="none" stroke="#fff" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round"/>` : ""}
  </g>
`;

const capy = (x, y, scale = 1, pose = "sit") => `
  <g id="Capybara" transform="translate(${x} ${y}) scale(${scale})">
    <ellipse cx="105" cy="226" rx="118" ry="25" fill="#C6C0F6" opacity=".55"/>
    <ellipse cx="110" cy="135" rx="92" ry="120" fill="url(#fur)"/>
    <ellipse cx="88" cy="72" rx="74" ry="68" fill="url(#furLight)"/>
    <ellipse cx="34" cy="28" rx="13" ry="22" fill="#9B6F4F" transform="rotate(-18 34 28)"/>
    <ellipse cx="132" cy="22" rx="14" ry="24" fill="#9B6F4F" transform="rotate(21 132 22)"/>
    <path d="M58 82c16 18 48 21 69 0" fill="none" stroke="#6B4B3D" stroke-width="4" stroke-linecap="round" opacity=".45"/>
    <ellipse cx="50" cy="67" rx="9" ry="6" fill="#624436"/>
    <ellipse cx="78" cy="66" rx="8" ry="5" fill="#624436" opacity=".72"/>
    <path d="M112 75c12 3 28 1 40-6" fill="none" stroke="#3B2E32" stroke-width="4" stroke-linecap="round"/>
    <ellipse cx="68" cy="177" rx="31" ry="54" fill="#B88763" opacity=".7"/>
    <ellipse cx="151" cy="176" rx="33" ry="55" fill="#B88763" opacity=".62"/>
    <ellipse cx="58" cy="249" rx="26" ry="12" fill="#6F5145"/>
    <ellipse cx="151" cy="249" rx="27" ry="12" fill="#6F5145"/>
    <g transform="translate(102 40) rotate(32)">
      <rect x="0" y="22" width="34" height="235" rx="17" fill="url(#spoonWood)"/>
      <ellipse cx="17" cy="28" rx="54" ry="72" fill="url(#spoonWood)"/>
      <ellipse cx="17" cy="28" rx="38" ry="54" fill="none" stroke="#C28F58" stroke-width="5" opacity=".38"/>
    </g>
    <ellipse cx="92" cy="162" rx="8" ry="14" fill="#5D463E"/>
    <ellipse cx="111" cy="158" rx="8" ry="13" fill="#5D463E"/>
  </g>
`;

const cloud = (x, y, w = 116, h = 52) => `
  <g transform="translate(${x} ${y})" opacity=".58">
    <ellipse cx="${w * 0.25}" cy="${h * 0.55}" rx="${w * 0.24}" ry="${h * 0.33}" fill="#FFFFFF"/>
    <ellipse cx="${w * 0.48}" cy="${h * 0.45}" rx="${w * 0.3}" ry="${h * 0.38}" fill="#FFFFFF"/>
    <ellipse cx="${w * 0.72}" cy="${h * 0.55}" rx="${w * 0.24}" ry="${h * 0.33}" fill="#FFFFFF"/>
  </g>
`;

const vase = (x, y) => `
  <g transform="translate(${x} ${y})">
    <path d="M24 84h45c2 22-9 34-23 34S20 106 24 84z" fill="#FFFFFF" opacity=".92"/>
    <path d="M45 86c0-42 23-64 38-70" fill="none" stroke="#78A87E" stroke-width="5" stroke-linecap="round"/>
    <path d="M80 4c22 8 25 30 1 44-24-13-22-36-1-44z" fill="#F4B8C2"/>
  </g>
`;

const star = (x, y, s = 1) => `
  <path transform="translate(${x} ${y}) scale(${s})" d="M16 0c4 11 7 14 18 18-11 4-14 7-18 18C12 25 9 22-2 18 9 14 12 11 16 0z" fill="#B8AEF7" opacity=".78"/>
`;

const screenOne = phone(31, "状态收集", "", `
    <g transform="translate(34 78)">
      <path d="M0 10c5-18 31-17 35 0 20-2 28 24 8 31H8C-9 38-9 15 0 10z" fill="none" stroke="#AAA2F6" stroke-width="4"/>
      <text x="52" y="27" class="small">天灰蒙蒙的，像罩了层毛玻璃</text>
    </g>
    <circle cx="423" cy="88" r="21" fill="#FFFFFF" opacity=".76"/>
    <text x="423" y="94" text-anchor="middle" class="dots">•••</text>
    ${cloud(78, 174, 112, 48)}
    <circle cx="73" cy="270" r="9" fill="#FFFFFF" opacity=".9"/>
    ${vase(50, 333)}
    ${star(393, 260, .85)}
    <g transform="translate(397 345)" opacity=".9">
      <path d="M2 0h36c-3 23-13 28-18 36C15 28 5 23 2 0zM2 74h36c-3-23-13-28-18-36C15 46 5 51 2 74z" fill="#FFFFFF"/>
    </g>
    <ellipse cx="344" cy="235" rx="94" ry="72" fill="#DCD8FA" opacity=".52"/>
    ${capy(145, 175, .93)}
    <text x="234" y="505" text-anchor="middle" class="headline">今天像什么样子？</text>
    <text x="234" y="550" text-anchor="middle" class="subcopy">选几个词，看看今天的你</text>
    ${pill(31, 585, "躺了一天", true, 150, 2)}
    ${pill(199, 596, "没洗头", false, 103)}
    ${pill(325, 585, "胸口闷", true, 126, -2)}
    ${pill(30, 666, "不想回消息", true, 162, 2)}
    ${pill(204, 683, "觉得委屈", false, 126)}
    ${pill(350, 735, "害怕明天", false, 120)}
    ${pill(96, 764, "随便吧", false, 102)}
    ${pill(238, 815, "正在发呆", false, 122)}
    <rect x="32" y="860" width="403" height="63" rx="31.5" fill="url(#primary)"/>
    <text x="234" y="900" text-anchor="middle" class="buttonText">生成今日声明</text>
`);

const screenTwo = phone(535, "今日声明", "", `
    <circle cx="43" cy="88" r="21" fill="#FFFFFF" opacity=".76"/>
    <path d="M47 77l-11 11 11 11" fill="none" stroke="#282746" stroke-width="4" stroke-linecap="round" stroke-linejoin="round"/>
    <circle cx="423" cy="88" r="21" fill="#FFFFFF" opacity=".76"/>
    <text x="423" y="94" text-anchor="middle" class="dots">•••</text>
    <text x="234" y="128" text-anchor="middle" class="headline">今日声明</text>
    <text x="234" y="172" text-anchor="middle" class="subcopy">已为你生成</text>
    ${cloud(73, 260, 130, 64)}
    ${vase(100, 320)}
    ${star(70, 188, .75)}
    ${star(408, 428, .55)}
    <ellipse cx="228" cy="315" rx="94" ry="76" fill="#DCD8FA" opacity=".52"/>
    ${capy(185, 198, .74)}
    <g transform="translate(20 390)">
      <rect width="427" height="366" rx="28" fill="#FFFFFF" opacity=".74"/>
      <text x="28" y="43" class="label">今天的你:</text>
      ${pill(28, 86, "躺了一天", false, 105)}
      <circle cx="157" cy="111" r="3" fill="#B4AAF6"/>
      ${pill(180, 86, "胸口闷", false, 105)}
      <circle cx="305" cy="111" r="3" fill="#B4AAF6"/>
      ${pill(326, 86, "不想回消息", false, 95)}
      <rect x="18" y="166" width="391" height="158" rx="25" fill="#FFFFFF" opacity=".92"/>
      <text x="42" y="220" class="statement">今天已经很沉了。</text>
      <text x="42" y="264" class="statement">躺了一天、胸口闷、不想回消息，</text>
      <text x="42" y="308" class="statement">这些不是你在偷懒，</text>
      <text x="42" y="352" class="statement">而是身体和心里都在把门关小一点。</text>
    </g>
    <rect x="28" y="805" width="411" height="63" rx="31.5" fill="url(#primary)"/>
    <text x="226" y="845" text-anchor="middle" class="buttonText">今天先这样</text>
    <path d="M331 821c-17 3-25 13-26 27 13 1 25-6 28-23 9 2 15 0 20-5-8-1-15 0-22 1z" fill="#DDD9FF"/>
    <text x="234" y="910" text-anchor="middle" class="linkText">换一种说法</text>
`);

const record = (y, date, day, weather, tags, copy, art) => `
  <g transform="translate(15 ${y})">
    <rect width="437" height="154" rx="22" fill="#FFFFFF" opacity=".78"/>
    <text x="23" y="37" class="recordDate">${date}</text>
    <text x="106" y="37" class="recordMeta">${day}</text>
    <text x="303" y="37" class="recordMeta">${weather}</text>
    ${tags.map((t, i) => pill(21 + i * 104, 59, t, false, i === 1 ? 104 : 90)).join("")}
    <text x="24" y="116" class="recordCopy">${copy[0]}</text>
    <text x="24" y="142" class="recordCopy">${copy[1]}</text>
    ${art}
  </g>
`;

const screenThree = phone(1038, "日子抽屉", "", `
    <text x="35" y="125" class="headline">日子抽屉</text>
    <text x="35" y="171" class="subcopy">每个日子，都是你认真的证据</text>
    <circle cx="420" cy="105" r="23" fill="#FFFFFF" opacity=".78"/>
    <path d="M410 99h20M410 108h20M410 117h20" stroke="#282746" stroke-width="3" stroke-linecap="round"/>
    ${vase(47, 260)}
    <g transform="translate(160 245)">
      <path d="M20 8h155v120H20z" fill="#EDEAFF"/>
      <path d="M20 8l42-26h155L175 8z" fill="#F9F8FF"/>
      <path d="M175 8l42-26v120l-42 26z" fill="#D9D3F5"/>
      <circle cx="74" cy="82" r="10" fill="#A69AF0"/>
      <path d="M80 25h72M80 45h72M80 65h58" stroke="#D6CEE8" stroke-width="4" stroke-linecap="round"/>
    </g>
    ${capy(296, 190, .62)}
    ${record(344, "4月16日", "星期三", "天灰蒙蒙的", ["躺了一天", "不想回消息", "胸口闷"], ["雨把世界调成了低音量，今天", "少一点力气，不是你的错。"], `<g transform="translate(314 76)" opacity=".7"><path d="M32 0c9 34-8 58-32 71 33-4 55-22 65-54" fill="none" stroke="#B4AAF6" stroke-width="6"/><circle cx="72" cy="63" r="20" fill="#DCD8FA"/></g>`)}
    ${record(523, "4月12日", "星期五", "深夜", ["正在发呆", "害怕明天"], ["你只是飘了一会儿，", "不用马上落地。"], `<g transform="translate(305 16)"><rect x="50" y="0" width="82" height="110" rx="10" fill="#7F78E5" opacity=".72"/><path d="M18 70h88v42H18z" fill="#C5BDF8"/><circle cx="30" cy="76" r="13" fill="#FFE7A3"/></g>`)}
    ${record(703, "4月8日", "星期一", "小雨", ["没洗头", "无故流泪", "随便吧"], ["有时候，眼泪是身体里太多委屈，", "找不到出口。没关系的。"], `<g transform="translate(308 54)" opacity=".78"><path d="M16 53c54-62 116-46 140 0-28-12-53-12-79 0-24-13-43-12-61 0z" fill="#B3ABF4"/><path d="M83 53v76c0 22-24 22-24 3" fill="none" stroke="#8E83E9" stroke-width="8" stroke-linecap="round"/></g>`)}
`);

const editableSvg = `<?xml version="1.0" encoding="UTF-8"?>
<svg width="1536" height="1024" viewBox="0 0 1536 1024" fill="none" xmlns="http://www.w3.org/2000/svg">
  <defs>
    <linearGradient id="canvasBg" x1="0" y1="0" x2="1536" y2="1024" gradientUnits="userSpaceOnUse">
      <stop stop-color="#F1EFFF"/>
      <stop offset=".55" stop-color="#E8E4FA"/>
      <stop offset="1" stop-color="#FFF2EA"/>
    </linearGradient>
    <linearGradient id="phoneFill" x1="233" y1="0" x2="233" y2="972" gradientUnits="userSpaceOnUse">
      <stop stop-color="#FAF9FF"/>
      <stop offset=".45" stop-color="#EFECFF"/>
      <stop offset="1" stop-color="#FFF8F1"/>
    </linearGradient>
    <linearGradient id="primary" x1="0" y1="0" x2="411" y2="63" gradientUnits="userSpaceOnUse">
      <stop stop-color="#8E83F0"/>
      <stop offset="1" stop-color="#7262E8"/>
    </linearGradient>
    <linearGradient id="fur" x1="88" y1="30" x2="130" y2="258" gradientUnits="userSpaceOnUse">
      <stop stop-color="#D8A875"/>
      <stop offset="1" stop-color="#A87854"/>
    </linearGradient>
    <linearGradient id="furLight" x1="88" y1="4" x2="88" y2="140" gradientUnits="userSpaceOnUse">
      <stop stop-color="#DAB17E"/>
      <stop offset="1" stop-color="#B4825E"/>
    </linearGradient>
    <linearGradient id="spoonWood" x1="17" y1="-42" x2="17" y2="257" gradientUnits="userSpaceOnUse">
      <stop stop-color="#E2B574"/>
      <stop offset="1" stop-color="#C58A50"/>
    </linearGradient>
    <filter id="softShadow" x="-20%" y="-20%" width="140%" height="140%">
      <feDropShadow dx="0" dy="20" stdDeviation="28" flood-color="#7770C8" flood-opacity=".16"/>
    </filter>
    <style>
      text { font-family: -apple-system, BlinkMacSystemFont, "PingFang SC", "Microsoft YaHei", sans-serif; fill: #25243F; }
      .status { font-size: 16px; font-weight: 600; }
      .small { font-size: 16px; font-weight: 520; fill: #575573; }
      .dots { font-size: 20px; font-weight: 800; letter-spacing: 2px; }
      .headline { font-size: 38px; font-weight: 800; }
      .subcopy { font-size: 18px; fill: #696682; }
      .pill { font-size: 17px; font-weight: 650; fill: #353356; }
      .pillSelected { font-size: 17px; font-weight: 700; fill: #FFFFFF; }
      .buttonText { font-size: 21px; font-weight: 800; fill: #FFFFFF; }
      .linkText { font-size: 17px; font-weight: 600; fill: #6A61C9; }
      .label { font-size: 18px; font-weight: 650; fill: #56536E; }
      .statement { font-size: 24px; font-weight: 700; fill: #25243F; }
      .recordDate { font-size: 19px; font-weight: 800; }
      .recordMeta { font-size: 15px; fill: #66637E; }
      .recordCopy { font-size: 16px; fill: #45425E; }
    </style>
  </defs>
  <rect width="1536" height="1024" fill="url(#canvasBg)"/>
  <g filter="url(#softShadow)">
    ${screenOne}
    ${screenTwo}
    ${screenThree}
  </g>
</svg>`;

const referenceBase64 = readFileSync(referencePath).toString("base64");
const exactSvg = `<?xml version="1.0" encoding="UTF-8"?>
<svg width="1536" height="1024" viewBox="0 0 1536 1024" fill="none" xmlns="http://www.w3.org/2000/svg">
  <image width="1536" height="1024" href="data:image/png;base64,${referenceBase64}"/>
</svg>`;

writeFileSync(editablePath, editableSvg);
writeFileSync(exactPath, exactSvg);

console.log(`Wrote ${editablePath.pathname}`);
console.log(`Wrote ${exactPath.pathname}`);
