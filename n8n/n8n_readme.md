# n8n 구글 클라우드 호스팅

## GCP VM 인스턴스 설치

1. https://console.cloud.google.com/ (구글 클라우드 콘솔) 에 접속해서 프로젝트를 하나 생성.
2. `Create VM` 버튼 클릭 : Compute Enging API -> 사용 (활성화)
3. New VM instance (Preetire) 생성

````text
    Name : freetier
    Region : 프리티어 인스턴스를 지원해주는 지역 선택 us-west1 (Oregon)
    Machine Type : e2-micro (2 vCpu, 1 core, 1 GB Memory)
    
    방화벽 : 모든 Http Allow
    Disk :
        - Operating System : Ubuntu
        - Disk Type : Standard
        - Size : 30 GB
     
````

---


## docker 설치

브라우저를 통해 ssh 콘솔 접속

1. 기본 tool 설치

```shell
# root 패스워드 변경
sudo passwd root

# vi, net-tool 설치 
sudo apt update
sudo apt install vim net-tools
```

2. docker 설치

```bash
# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc
```
`중간에 Abort 문제가 발생하는 경우` 한 줄씩 입력해보세요. 시스템이 Y/n 를 묻는다면 Y를 입력.

```bash
# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
```

`위 내용은 전체 실행`

```shell
sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

## n8n 설치

### docker-compose.yml 생성

```yaml
version: "3.8"

services:
  n8n:
    image: n8nio/n8n:latest
    container_name: n8n
    ports:
      - "${N8N_PORT}:${N8N_PORT}"
    environment:
      - WEBHOOK_URL=https://a59972d57213.ngrok-free.app
      - N8N_SECURE_COOKIE=false
      - N8N_PORT=${N8N_PORT}
      - N8N_HOST=${N8N_HOST}
      - N8N_PROTOCOL=${N8N_PROTOCOL}
      - N8N_BASE_URL=${N8N_BASE_URL}
      - N8N_ENFORCE_SETTINGS_FILE_PERMISSIONS=true
    env_file:
      - .env
    volumes:
      - ./n8n_data:/home/node/.n8n
    restart: always
```

### .env 생성

```yaml
# n8n Secure key
N8N_ENCRYPTION_KEY=qvW7g/9ZtA&f#X1!DLkp@73hYud$Xq0r
N8N_USER_MANAGEMENT_JWT_SECRET=anotherSuperSecretKey

# External connection Config
N8N_PORT=5678
N8N_HOST=localhost
N8N_PROTOCOL=http
N8N_BASE_URL=http://localhost:5678
```

`root`로 실행시 권한 오류가 발생할 있으므로 미리 폴더에 대한 권한을 변경한다.

n8n 공식 Docker 이미지는 보안상 root가 아닌 node(UID 1000) 계정으로 실행됩

```shell
sudo mkdir n8n_data
sudo chown -R 1000:1000 ./n8n_data
```

### Container 실행

```shell
docker compose up -d

# check
docker ps 

docker logs -f Container-ID
```
### GCP 방화벽 허용
Google Cloud Console > VPC네트워크 > 방화벽 

`IP : 0.0.0.0, PORT : 5678` 허용

접속

http://ip:5678

최초 로그인 / 비번정보 `반드시 기억해야함!!!!!!`

---

## ngrok 을 이용한 HTTPS 연동

### ngrok 설치

['https://ngrok.com/docs/getting-started/cloud-endpoints-quickstart/' 참조](https://ngrok.com/docs/getting-started/cloud-endpoints-quickstart/)

1. ngrok install
```shell
curl -sSL https://ngrok-agent.s3.amazonaws.com/ngrok.asc \
  | sudo tee /etc/apt/trusted.gpg.d/ngrok.asc >/dev/null \
  && echo "deb https://ngrok-agent.s3.amazonaws.com buster main" \
  | sudo tee /etc/apt/sources.list.d/ngrok.list \
  && sudo apt update \
  && sudo apt install ngrok
```
2. 설치 확인
```shell
ngrok help
```
3. Connect your account
```shell
ngrok config add-authtoken $YOUR_TOKEN
```
4. backgroud 실행(ngrok.sh)
```shell
nohup ngrok http 5678 > ngrok.log 2>&1 &
```

nohup으로 ngrok을 백그라운드에서 실행하면 터널 정보(특히 https URL)가 터미널에 바로 표시되지 않기 때문에, ngrok이 생성한 URL을 따로 확인하는 방법이 필요.

ngrok은 기본적으로 로컬 API 서버를 **http://127.0.0.1:4040**에서 실행합니다. 이를 통해 현재 열려 있는 터널 정보를 확인

5. ngrok_url.sh
```shell
curl http://127.0.0.1:4040/api/tunnels
```
실행결과

{"tunnels":[{"name":"command_line","ID":"9b7c272fbaedb14cbcff0bb3f0c226c1","uri":"/api/tunnels/command_line",`"public_url":"https://7e4589482a20.ngrok-free.app"`,"proto":"https","config":{"addr":"http://localhost:5678","inspect":true},"metrics":{"conns":{"count":0,"gauge":0,"rate1":0,"rate5":0,"rate15":0,"p50":0,"p90":0,"p95":0,"p99":0},"http":{"count":0,"rate1":0,"rate5":0,"rate15":0,"p50":0,"p90":0,"p95":0,"p99":0}}}],"uri":"/api/tunnels"}

접속

https://7e4589482a20.ngrok-free.app




