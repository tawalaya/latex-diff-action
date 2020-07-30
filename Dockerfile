FROM xucheng/texlive-full:latest

COPY \
  LICENSE \
  README.md \
  entrypoint.sh \
  /root/

RUN apk add git g++ make asciidoc
RUN cd /opt && git clone https://gitlab.com/git-latexdiff/git-latexdiff.git && cd /opt/git-latexdiff && make install

ENTRYPOINT ["/root/entrypoint.sh"]
