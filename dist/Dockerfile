# Multi-stage build para aplicação estática
FROM nginx:alpine

# Copiar arquivos da aplicação
COPY . /usr/share/nginx/html/

# Copiar configuração do nginx
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Expor porta
EXPOSE 80

# Comando padrão
CMD ["nginx", "-g", "daemon off;"]
