FROM hugomods/hugo

# Copy the public folder to Apache's web root
COPY . /src

RUN grep baseurl /src/hugo.toml

RUN hugo mod get && hugo mod tidy

RUN grep baseurl /src/hugo.toml

# Expose the HTTP port
EXPOSE 1313

CMD ["server", "--bind", "0.0.0.0", "--config", "/src/hugo.toml", "--baseURL", "https://hugo.gavriliu.com/", "--disableFastRender"]