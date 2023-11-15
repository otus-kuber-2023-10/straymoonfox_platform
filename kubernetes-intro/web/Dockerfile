FROM rockylinux/rockylinux:8
RUN dnf -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm
RUN dnf -y install epel-release 
RUN dnf -y install nginx
RUN  mkdir /app/
RUN chown -R nginx:nginx /app
RUN chmod -R 755 /app
ADD homework.html app/homework.html
ADD nginx.conf /etc/nginx/nginx.conf
RUN usermod -u 1001 nginx && groupmod -g 1001 nginx
EXPOSE 8000
CMD ["nginx", "-g", "daemon off;"]