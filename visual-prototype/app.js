const screens = [...document.querySelectorAll(".screen")];
const navItems = [...document.querySelectorAll("[data-nav]")];
const stateWords = [...document.querySelectorAll(".state-word")];
const selectedText = document.querySelector("[data-selected-text]");
const statementText = document.querySelector("[data-statement-text]");
const recordList = document.querySelector("[data-record-list]");
const screenNames = new Set(screens.map((screen) => screen.dataset.screen));

const statements = [
  (words) =>
    `今天已经很沉了。${words.join("、")}，这些不是你在偷懒，而是身体和心里都在把门关小一点。外面灰灰的，你也不用急着把自己解释清楚。`,
  (words) =>
    `如果今天只剩下${words.slice(0, 2).join("、")}，也没关系。你没有失败，只是正在用很小的力气，把自己从噪音里慢慢抱回来。`,
  (words) =>
    `今天的${words.join("、")}都可以先被放下。你不需要马上回应世界，也不用把每一种难受都讲得很清楚。`,
];

let statementIndex = 0;
let currentWords = getSelectedWords();

function switchScreen(name, updateHash = true) {
  screens.forEach((screen) => {
    screen.classList.toggle("is-active", screen.dataset.screen === name);
  });
  navItems.forEach((item) => {
    item.classList.toggle("is-active", item.dataset.nav === name);
  });
  if (updateHash) {
    history.replaceState(null, "", `#${name}`);
  }
}

function getSelectedWords() {
  const words = stateWords
    .filter((word) => word.classList.contains("is-selected"))
    .map((word) => word.textContent.trim());

  return words.length > 0 ? words : ["正在发呆"];
}

function renderStatement(nextIndex = statementIndex) {
  currentWords = getSelectedWords();
  statementIndex = nextIndex % statements.length;
  selectedText.textContent = currentWords.join("、");
  statementText.textContent = statements[statementIndex](currentWords);
  upsertTodayRecord();
}

function upsertTodayRecord() {
  const existing = recordList.querySelector("[data-today-record]");
  const card = existing || document.createElement("article");

  card.className = "record-card";
  card.dataset.todayRecord = "true";
  card.innerHTML = `
    <time>今天</time>
    <div class="record-tags">
      ${currentWords.map((word) => `<span>${word}</span>`).join("")}
    </div>
    <p>${statementText.textContent}</p>
  `;

  if (!existing) {
    recordList.prepend(card);
  }
}

stateWords.forEach((word) => {
  word.addEventListener("click", () => {
    word.classList.toggle("is-selected");
  });
});

navItems.forEach((item) => {
  item.addEventListener("click", () => {
    if (item.dataset.nav === "statement") {
      renderStatement();
    }
    switchScreen(item.dataset.nav);
  });
});

document.querySelector("[data-generate]").addEventListener("click", () => {
  renderStatement(0);
  switchScreen("statement");
});

document.querySelector("[data-regenerate]").addEventListener("click", () => {
  renderStatement(statementIndex + 1);
});

document.querySelector("[data-accept]").addEventListener("click", () => {
  upsertTodayRecord();
  switchScreen("drawer");
});

document.querySelector("[data-back-state]").addEventListener("click", () => {
  switchScreen("state");
});

renderStatement();
const initialScreen = location.hash.slice(1);
if (screenNames.has(initialScreen)) {
  switchScreen(initialScreen, false);
}
