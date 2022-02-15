FROM ansible/centos7-ansible:latest
RUN yum install -y texlive-latex-bin texlive-xetex-bin texmaker
ADD xeCJK.tgz /usr/share/texlive/texmf-dist/tex/xelatex/xecjk/
ADD euenc.tgz /usr/share/texlive/texmf-dist/tex/latex/euenc/
COPY SIMKAI.ttf /usr/share/fonts/dejavu/
RUN texhash
COPY grafana-reporter /
RUN chmod +x /grafana-reporter
EXPOSE 8686
ENTRYPOINT ["/grafana-reporter","-ip","172.22.254.57:30030"]
