FROM ubuntu:latest
RUN apt update -y && apt install -y sudo curl git vim tmux fish language-pack-ko nodejs npm ruby gem ctags python3-pip
RUN curl -LO https://github.com/BurntSushi/ripgrep/releases/download/11.0.2/ripgrep_11.0.2_amd64.deb \
	&& dpkg -i ripgrep*.deb \
	&& rm ripgrep*.deb

RUN gem install coderay

# Set user
ARG user
ARG gid
ARG uid

RUN groupadd -g $gid $user \
  && useradd -u $uid -g $gid -m $user \
  && echo "$user:$user" | chpasswd \
  && usermod -a -G sudo $user \
  && echo "$user ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

# Generate locales
RUN echo "ko_KR.UTF-8 UTF-8" >  /etc/locale.gen \
 && echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen \
 && locale-gen \
 && echo "LANG=en_US.UTF-8" >> /etc/locale.conf

ENV LANG=en_US.UTF-8

# Set timezone
RUN ln -sf /usr/share/zoneinfo/Asia/Seoul /etc/localtime

# Go specifics
ADD https://dl.google.com/go/go1.12.7.linux-amd64.tar.gz /usr/local/go.tar.gz
RUN tar -xf /usr/local/go.tar.gz -C /usr/local && rm /usr/local/go.tar.gz

USER $user
ENV USER $user
ENV HOME /home/$user
ENV GOROOT /usr/local/go
ENV GOPATH /home/$user/go
ENV SHELL fish
ENV PATH $HOME/.local/bin:$GOPATH/bin:$GOROOT/bin:$PATH

RUN curl https://git.io/fisher --create-dirs -sLo $HOME/.config/fish/functions/fisher.fish
RUN curl -fLo $HOME/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
RUN git clone https://github.com/tmux-plugins/tpm $HOME/.tmux/plugins/tpm
RUN git clone --depth 1 https://github.com/junegunn/fzf.git $HOME/.fzf \
	&& $HOME/.fzf/install --all

COPY .vimrc .tmux.conf $HOME/
COPY config.fish fishfile $HOME/.config/fish/
COPY coc-settings.json $HOME/.vim

RUN fish -c "fisher"

RUN vim +PlugInstall +qa || true
RUN vim -c "set filetype=go" +GoInstallBinaries +qa || true
RUN pip3 install --user termtosvg
RUN gem install coderay

WORKDIR $HOME
CMD tmux
