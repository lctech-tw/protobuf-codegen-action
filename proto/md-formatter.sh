#!/bin/bash

# 從 .md 檔案中移除 Markdown 目錄（TOC）、修正錨點屬性，並加入 VitePress 前言區塊

# 解析命令列參數
REMOVE_TOC=false
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --remove-toc) REMOVE_TOC=true ;;
        *) echo "未知參數: $1"; exit 1 ;;
    esac
    shift
done

# 預先取得專案名稱，避免在每個檔案迴圈中重複呼叫 git
PROJECT_NAME=$(basename "$(git rev-parse --show-toplevel)")

process_file() {
    local file=$1
    echo "處理: $file"

    # 一次掃描取得前兩個 <a> 標籤的行號，避免重複讀取檔案
    local a_lines
    mapfile -t a_lines < <(grep -n '<a' "$file" | head -n 2 | cut -d: -f1)
    local first_a_line="${a_lines[0]}"
    local second_a_line="${a_lines[1]}"

    if [ -z "$first_a_line" ] || [ -z "$second_a_line" ]; then
        echo "  警告: 未找到兩個 <a> 標籤，略過此檔案"
        return 1
    fi

    # 條件性刪除兩個 <a> 標籤之間的 TOC 區塊
    if [ "$REMOVE_TOC" = true ]; then
        sed -i "${first_a_line},${second_a_line}d" "$file"
        echo "  已移除 TOC"
    fi

    # 合併多個替換操作為單次 sed，減少磁碟 I/O
    sed -i \
        -e '/<a href="#top">Top<\/a>/d' \
        -e "s/# Protocol Documentation/# ${PROJECT_NAME}/g" \
        -e 's/<a name=/<a id=/g' \
        "$file"

    # 在檔案開頭插入 VitePress 前言區塊與版本標籤
    # 使用 printf + cat 取代兩次 sed，避免多行插入的相容性問題
    printf -- '---\noutline: deep\n---\n\n# v%s\n' "${TAG_VERSION}" \
        | cat - "$file" > "${file}.tmp" && mv "${file}.tmp" "$file"

    echo "  完成: $file"
}

# 批次處理目前目錄下README.md檔案
find . -type f -name "README.md" | while IFS= read -r file; do
    process_file "$file"
done

echo "✅ 所有 Markdown 檔案處理完成！"
