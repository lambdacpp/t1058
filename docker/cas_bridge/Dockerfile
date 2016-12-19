FROM aweiker/alpine-elixir

MAINTAINER heyuan <heyuan@cdu.edu.cn>

RUN apk update
RUN apk add git
RUN rm -rf /var/cache/apk/*


RUN git clone -b another_cas_server  https://github.com/lambdacpp/t1058.git  /t1058

WORKDIR /t1058

RUN mix local.hex --force 
RUN mix local.rebar --force 

RUN mix deps.get
RUN mix compile

CMD ["mix", "run", "--no-halt"]

