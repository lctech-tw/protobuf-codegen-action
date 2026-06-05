#!/bin/bash
set -e

# 初始化顏色變數
RED='\033[0;31m'
NC='\033[0m'

# 取得 GITHUB_REPOSITORY，若未設定則從 git remote 解析
if [ -z "$GITHUB_REPOSITORY" ]; then
    echo -e "@ ${RED}GITHUB_REPOSITORY${NC} 未設定，嘗試從 git remote 解析..."
    GITHUB_REPOSITORY=$(git config --get remote.origin.url | sed -E 's|git@github.com:||;s|https://github.com/||;s|\.git$||')
fi
echo -e "@ GITHUB_REPOSITORY = ${RED}$GITHUB_REPOSITORY${NC}"

# 根據 COMPILE_MODE 決定使用的腳本檔案
# 預設（空值）-> Neo 模式
# Multi       -> 多檔編譯
# v3 / v4 / old -> 舊版模式
case "${COMPILE_MODE,,}" in
    multi|muliti) SCRIPT_FILE="build-protoc2.sh" ;;
    v3)           SCRIPT_FILE="build-protoc3.sh" ;;
    v4)           SCRIPT_FILE="build-protoc4.sh" ;;
    old)          SCRIPT_FILE="build-protoc.sh"  ;;
    *)            SCRIPT_FILE=""                  ;;
esac

# 若存在 go.mod 則重新產生（確保 module 路徑正確）
if [ -f go.mod ]; then
    printf "module github.com/%s\ngo 1.22\n" "$GITHUB_REPOSITORY" > go.mod
fi

if [ -n "$SCRIPT_FILE" ]; then
    # ── 舊版模式 ──────────────────────────────────────────────
    echo -e "@ ENGINE = ${RED}Default${NC} | COMPILE_MODE=${COMPILE_MODE} SCRIPT_FILE=${RED}$SCRIPT_FILE${NC}"

    # 下載編譯腳本
    curl -sLJO "https://raw.githubusercontent.com/lctech-tw/protobuf-codegen-action/main/proto/$SCRIPT_FILE"
    curl -sLJO "https://raw.githubusercontent.com/lctech-tw/protobuf-codegen-action/main/proto/build-protoc-node.sh"

    # 非本機開發環境時進行 GCP / Docker 認證
    if [ "$(whoami)" != "lctech-zeki" ]; then
        gcloud auth activate-service-account docker-puller@lc-shared-res.iam.gserviceaccount.com --key-file=.github/auth/puller.json
        gcloud auth configure-docker -q
        docker login -u _json_key --password-stdin https://asia.gcr.io < ./.github/auth/puller.json
    fi

    # 同時拉取兩個映像檔以節省時間，等待完成後再執行
    docker pull asia.gcr.io/lc-shared-res/proto-compiler:node &
    docker pull asia.gcr.io/lc-shared-res/proto-compiler:latest
    wait

    # 透過 Docker 執行編譯
    docker run --rm -v "$(pwd)":/workdir asia.gcr.io/lc-shared-res/proto-compiler:latest ./"$SCRIPT_FILE" build "github.com/$GITHUB_REPOSITORY"
    docker run --rm -v "$(pwd)":/workdir asia.gcr.io/lc-shared-res/proto-compiler:node ./build-protoc-node.sh build

    # 清除下載的腳本
    rm -f ./build-protoc*
else
    # ── Neo 模式 ───────────────────────────────────────────────
    echo -e "@ ENGINE = ${RED}Neo 模式${NC}"

    # 清除舊的 dist，並備份 src 以便結束後還原
    rm -rf dist
    cp -R src tmp_src
    cd ./src || exit

    # 若不存在 buf 設定檔則從遠端下載
    [ ! -f buf.yaml ]     && curl -sLJO "https://raw.githubusercontent.com/lctech-tw/protobuf-codegen-action/main/proto/buf.yaml"
    [ ! -f buf.gen.yaml ] && curl -sLJO "https://raw.githubusercontent.com/lctech-tw/protobuf-codegen-action/main/proto/buf.gen.yaml"

    mkdir dist

    # 若有外部 proto 檔案則複製進來
    [ -d "../external" ] && rsync -a ../external/ ./

    # 使用 buf 更新依賴並產生程式碼
    docker run --volume "$(pwd):/workspace" --workdir /workspace bufbuild/buf dep update
    docker run --volume "$(pwd):/workspace" --workdir /workspace bufbuild/buf generate

    # 將產出移至根目錄並清除暫存設定
    mv dist ../dist && rm -f buf.yaml buf.gen.yaml buf.lock

    # 修正 Golang 輸出路徑（buf 會依 module 路徑建立巢狀目錄）
    sudo mv "../dist/go/github.com/$GITHUB_REPOSITORY/dist/go/"* ../dist/go/
    sudo mv "../dist/go/github.com/$GITHUB_REPOSITORY/"* ../dist/go/

    # 將產出的文件移至 README.md
    sudo mv ../dist/docs/docs.md ../README.md

    # 清除多餘的巢狀目錄
    sudo rm -rf "../dist/go/github.com"

    # 還原原始 src
    cd .. && rm -rf src && mv tmp_src src
fi

echo "@ Done 🎉🎉🎉"
