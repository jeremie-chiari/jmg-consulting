FROM nginx:alpine
COPY *.html /usr/share/nginx/html/
COPY *.pdf /usr/share/nginx/html/
COPY ["Images Site", "/usr/share/nginx/html/Images Site/"]
COPY nginx.conf /etc/nginx/conf.d/default.conf
EXPOSE 80
