FROM hugomods/hugo

# Copy the public folder to Apache's web root
COPY . /src

RUN hugo mod get && hugo mod tidy

# Expose the HTTP port
EXPOSE 1313

ENTRYPOINT ["hugo", "server"]
CMD ["--buildDrafts", "--baseURL", "https://hugo.gavriliu.com/"]