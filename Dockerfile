FROM hugomods/hugo

# Copy the public folder to Apache's web root
COPY ./ /src

RUN hugo mod get && hugo mod tidy

# Expose the HTTP port
EXPOSE 1313

CMD ["hugo", "server", "--bind", "0.0.0.0", "--baseURL", "http://hugo.gavriliu.com/", "--disableFastRender"]