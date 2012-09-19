# Masyo(魔性)

## Description
Casual TCP Proxy

## Usage

```sh
$ cd /path-to-masyo
$ bundle install --path=vendor/bundles
$ bundle exec ruby bin/masyo -p #{LISTEN_PORT} --target_host #{PROXY_TARGET_HOST} --target_port #{PROXY_TARGET_PORT}
```
