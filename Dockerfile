# Etapa de Build
FROM --platform=linux/amd64 golang:1.18-alpine AS builder

WORKDIR /code

ENV CGO_ENABLED 0
ENV GOPATH /go
ENV GOCACHE /go-build

# Copiar dependências
COPY go.mod go.sum ./
RUN go mod download

# Copiar o código-fonte
COPY . .

# Construir o binário
RUN go build -o bin/backend main.go

# Comando para rodar o backend
CMD ["/code/bin/backend"]

# Etapa de Desenvolvimento
FROM builder as dev-envs

# Instalar pacotes para o ambiente de desenvolvimento
RUN apk update && apk add --no-cache git
RUN apk add --no-cache docker-cli docker-compose

# Criar um usuário para o VSCode
RUN addgroup -S docker && adduser -S --shell /bin/bash --ingroup docker vscode

# Comando para rodar a aplicação em modo de desenvolvimento
CMD ["go", "run", "main.go"]

# Etapa de Produção (apenas o binário)
FROM scratch

# Copiar apenas o binário para a imagem final
COPY --from=builder /code/bin/backend /usr/local/bin/backend

# Comando para rodar o binário em produção
CMD ["/usr/local/bin/backend"]

