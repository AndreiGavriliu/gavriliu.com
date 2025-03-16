FROM hugomods/hugo

# Copy the public folder to Apache's web root
COPY . /src

RUN hugo mod get && hugo mod tidy

# Expose the HTTP port
EXPOSE 1313

CMD ["server", "-D"]

# # Stage 2: Serve with Nginx
# FROM nginx:latest

# # Copy built Hugo site from the builder stage to Nginx's web root
# COPY /public /usr/share/nginx/html

# # Expose HTTP port
# EXPOSE 80

# # Start Nginx
# CMD ["nginx", "-g", "daemon off;"]