# Exercise 1 · appetizer (10 min · solo)

Get your hands on the CLI. No files needed — just a terminal with Docker running.

## Tasks and example answers

```bash
# 1. Pull an official Python image
docker pull python:3.12

# 2. Run it — what happens, and why does it stop straight away?
docker run python:3.12
```
Python starts an interactive REPL, but `docker run` (without `-it`) gives the
container no TTY and no stdin. The REPL reads EOF immediately, exits, and the
container stops — a container only lives as long as its main process (PID 1).

```bash
# 3. Open an interactive shell and print the environment variables
docker run -it python:3.12 sh
# inside the container:
env
exit
```
Note the variables that are already there (`PATH`, `LANG`, `PYTHON_VERSION`,
`HOSTNAME`, ...) — they come from the image, not from your host shell.

```bash
# 4. Find the image size
docker image ls python:3.12
```
Expect roughly **1 GB**. Write it down — it's the "before" number for the
layers/size block later.
