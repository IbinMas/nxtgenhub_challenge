FROM nginx:alpine
COPY index.html /usr/share/nginx/html/index.html



# docker build -t hellow-wold-nginx:1.1 .