#!/bin/bash

# 환경 변수 설정
export WORK="/root/birds-sui-bot"
export NVM_DIR="$HOME/.nvm"

# 색상 정의
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # 색상 초기화

echo -e "${GREEN}birds-sui-bot을 설치합니다.${NC}"
echo -e "${GREEN}스크립트작성자: https://t.me/kjkresearch${NC}"
echo -e "${GREEN}출처: https://github.com/Widiskel/birds-sui-bot${NC}"

echo -e "${GREEN}설치 옵션을 선택하세요:${NC}"
echo -e "${YELLOW}1. birds-sui-bot 새로 설치${NC}"
echo -e "${YELLOW}2. 재실행하기${NC}"
read -p "선택: " choice

case $choice in
  1)
    echo -e "${GREEN}birds-sui-bot을 새로 설치합니다.${NC}"

    # 사전 필수 패키지 설치
    echo -e "${YELLOW}시스템 업데이트 및 필수 패키지 설치 중...${NC}"
    sudo apt update
    sudo apt install -y git

    echo -e "${YELLOW}작업 공간 준비 중...${NC}"
    if [ -d "$WORK" ]; then
        echo -e "${YELLOW}기존 작업 공간 삭제 중...${NC}"
        rm -rf "$WORK"
    fi

    # GitHub에서 코드 복사
    echo -e "${YELLOW}GitHub에서 코드 복사 중...${NC}"
    git clone https://github.com/Bachtran301/birds-sui-bot
    cd "$WORK"

    # Node.js LTS 버전 설치 및 사용
    echo -e "${YELLOW}Node.js LTS 버전을 설치하고 설정 중...${NC}"
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # nvm을 로드합니다
    nvm install --lts
    nvm use --lts
    npm install

    echo -e "${YELLOW}Web텔레그렘에 접속후 F12를 누르시고 게임을 실행하세요${NC}"
    read -p "애플리케이션-세션저장소-birds-sui과 관련된 URL클릭 후 나오는 UserID나 QueryID를 적어두세요 (엔터) : "
    echo -e "${GREEN}다계정의 query_id를 입력할 경우 줄바꿈으로 구분하세요.${NC}"
    echo -e "${GREEN}입력을 마치려면 엔터를 두 번 누르세요.${NC}"
    echo -e "${YELLOW}Userid를 입력하세요(user= 또는 query_id= 포함해서 입력):${NC}"
    
    # 쿼리 파일 생성 및 초기화
    {
        while IFS= read -r line; do
            [[ -z "$line" ]] && break
            echo "$line"
        done
    } > "$WORK/data.txt"
    
    # 프록시파일 생성
    echo -e "${YELLOW}프록시 정보를 입력하세요. 입력형식: http://user:pass@ip:port${NC}"
    echo -e "${YELLOW}여러 개의 프록시는 줄바꿈으로 구분하세요.${NC}"
    echo -e "${YELLOW}입력을 마치려면 엔터를 두 번 누르세요.${NC}"

    {
        echo "export const proxyList = ["  # 파일 시작
        while IFS= read -r line; do
            [[ -z "$line" ]] && break
            # 입력된 프록시 정보를 그대로 사용
            echo "  \"$line\","
        done
        echo "];"  # 배열 끝
    } > "$WORK/config/proxiy_list.js"

    # SUI 지갑의 프라이빗키 입력 받기
    read -p "SUI 지갑의 프라이빗키를 입력하세요. 여러계정의 경우 쉼표로 구분하세요: " sui_private_key

    # 쿼리 파일에서 쿼리 읽기
    mapfile -t queries < "$WORK/data.txt"

    # config.js 파일 생성
    {
        echo "export class Config {"
        echo "static TELEGRAM_APP_ID = undefined;"
        echo "static TELEGRAM_APP_HASH = undefined;"
        echo "static USEONCHAINTX = true;" 
        echo "static USERWALLET = ["

        # 프라이빗키를 쉼표로 분리하여 배열에 추가
        IFS=',' read -ra keys <<< "$sui_private_key"
        for i in "${!keys[@]}"; do
            echo "    ["
            echo "        \"${keys[i]}\","
            echo "        \"${queries[i]}\","
            echo "    ]${i:+,}"  # 마지막 요소가 아닐 경우 쉼표 추가
        done

        echo "];"
        echo "}"  # Config 클래스 끝
    } > "$WORK/config/config.js"

    # 봇 구동
    node birds-sui-bot.js

    fi
    ;;
    
  2)
    echo -e "${GREEN}birds-sui-bot을 재실행합니다.${NC}"
    
    # nvm을 로드합니다
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # nvm을 로드합니다
    cd "$WORK"

    # 사용자에게 프록시 사용 여부를 물어봅니다.
    read -p "프록시를 사용하셨었습니까? (y/n): " use_proxy
    if [[ "$use_proxy" == "y" || "$use_proxy" == "Y" ]]; then
        node birds-sui-bot.js
    else
        node birds-sui-bot.js
    fi
    ;;

  *)
    echo -e "${RED}잘못된 선택입니다. 다시 시도하세요.${NC}"
    ;;
esac