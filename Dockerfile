FROM nginx:latest

# Copy built Hugo site from the builder stage to Nginx's web root
COPY /public /usr/share/nginx/html

# Expose HTTP port
EXPOSE 80

# Start Nginx
CMD ["nginx", "-g", "daemon off;"]