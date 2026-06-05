# protobuf-codegen-action

從 Protocol Buffers (`.proto`) 檔案自動生成多語言程式碼的 GitHub Action，支援 Go、Python、TypeScript 等語言，並在 `neo` 模式下自動更新 API 文件。

---

## 功能特色

- 從 `.proto` 檔案自動生成多語言程式碼（Go、Python、TypeScript 等）
- 支援多種編譯引擎（`neo`、`v3`、`v4`、`multi`、`old`）
- 自動下載外部 Proto 依賴（透過 `src/dependent.config`）
- `neo` 模式下使用 [buf](https://buf.build/) 工具鏈，產生乾淨的 `dist/` 輸出
- 自動格式化並更新 `README.md` 為最新 API 文件

---

## 快速開始

在您的儲存庫中建立 `.github/workflows/proto.yml`：

```yaml
name: Proto Compile

on:
  push:
    branches:
      - main

jobs:
  compile:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout Repository
        uses: actions/checkout@v4

      - name: Compile Proto
        uses: lctech-tw/protobuf-codegen-action@v0
        with:
          version: ${{ github.ref_name }}
          compile-mode: neo
```

---

## 輸入參數

| 參數 | 必填 | 預設值 | 說明 |
|------|------|--------|------|
| `version` | ✅ | — | 版本標籤，通常帶入 `${{ github.ref_name }}` |
| `compile-mode` | ✅ | `neo` | 編譯引擎，詳見下方說明 |
| `stable-mode` | ❌ | `true` | `false` 時，格式化文件時移除目錄（TOC） |

### compile-mode 說明

| 值 | 說明 |
|----|------|
| `neo`（預設）| 使用 [buf](https://buf.build/) 工具鏈，輸出至 `dist/`，並自動更新 `README.md` |
| `multi` | 使用 Docker 多語言編譯引擎（舊版） |
| `v3` | 使用 `build-protoc3.sh` 編譯 |
| `v4` | 使用 `build-protoc4.sh` 編譯 |
| `old` | 使用 `build-protoc.sh` 編譯（最舊版） |

---

## 外部 Proto 依賴

若您的 `.proto` 檔案需要引用其他 GitHub 儲存庫的 Proto，請建立 `src/dependent.config`：

```
# 格式：{org}/{repo}
lctech-tw/example-proto
lctech-tw/another-proto
```

Action 執行時會自動從對應儲存庫的 `src/` 目錄拉取 Proto 檔案至本地 `external/` 資料夾。

---

## 儲存庫結構

```plaintext
.
├── action.yml          # GitHub Action 定義
├── compile.sh          # 編譯入口腳本
├── dependent-proto.sh  # 外部 Proto 依賴下載腳本
├── proto/              # 編譯引擎腳本與 buf 設定檔
│   ├── buf.yaml
│   ├── buf.gen.yaml
│   ├── build-neo.sh
│   ├── build-protoc.sh
│   ├── build-protoc2.sh
│   ├── build-protoc3.sh
│   ├── build-protoc4.sh
│   └── md-formatter.sh
└── README.md
```

---

## neo 模式運作流程

```
src/
├── *.proto
├── dependent.config    # 可選，列出外部依賴
└── external/           # 自動下載的外部 proto（由 dependent-proto.sh 產生）

執行後產生：
dist/
├── go/                 # Go 生成程式碼
├── python/             # Python 生成程式碼
└── docs/               # API 文件（更新至 README.md）
```

---

## 常見問題

**Q：Action 失敗時如何除錯？**  
前往儲存庫的 **Actions** 頁籤，選擇失敗的執行記錄並展開各步驟的日誌。

**Q：如何手動觸發此 Action？**  
在工作流程 YAML 加入 `workflow_dispatch`：
```yaml
on:
  push:
    branches: [main]
  workflow_dispatch:
```

**Q：`stable-mode: false` 有什麼效果？**  
`neo` 模式下格式化文件時，會移除自動生成的目錄（Table of Contents）。

---

## 貢獻指南

1. Fork 此儲存庫
2. 建立功能分支：`git checkout -b feature/your-feature`
3. 提交變更：`git commit -am 'Add new feature'`
4. 推送分支：`git push origin feature/your-feature`
5. 開啟 Pull Request
