# Closing quiz — Mentimeter

10 questions covering the whole deck, for the closing quiz slot mentioned in
the curriculum doc. Mentimeter doesn't have a plain-text bulk import for
quizzes on the free plan — create each as a **Quiz Competition** slide and
copy these in manually. Suggested: 20–30s per question, points based on
speed.

---

**1. You run `docker run python:3.12` with no other flags. It exits almost
immediately. Why?**
- A) The image is corrupted
- B) ✅ Python starts a REPL, gets no TTY/stdin without `-it`, hits EOF and exits — a container only lives as long as its main process
- C) `python:3.12` has no default command
- D) Docker Hub rate-limited the pull

**2. What's the actual difference between `ENTRYPOINT` and `CMD`?**
- A) They do the same thing, it's just style
- B) `CMD` always runs, `ENTRYPOINT` is ignored if you pass arguments
- C) ✅ `ENTRYPOINT` is a fixed prefix that always runs; `CMD` alone is a default command that `docker run <image> <args>` overrides
- D) `ENTRYPOINT` only works with shell form

**3. Your Dockerfile has `EXPOSE 8000`. You run the container with no other
flags. Can another machine reach it on port 8000?**
- A) Yes, `EXPOSE` opens the port automatically
- B) ✅ No — `EXPOSE` is documentation only; only `-p` (or `-P`) actually publishes a port
- C) Only if the image is `FROM scratch`
- D) Only on Linux hosts

**4. A Dockerfile does `COPY . .` then `RUN pip install -r requirements.txt`.
Every commit — even a one-line code change — triggers a full reinstall. What
fixes it?**
- A) Add `--no-cache-dir` to pip
- B) Switch to a slim base image
- C) ✅ Copy and install `requirements.txt` *before* copying the rest of the source, so that layer only invalidates when dependencies change
- D) Run `docker build --no-cache` every time

**5. You `RUN apt-get install -y build-essential` in one layer and
`RUN apt-get remove -y build-essential` three layers later. What happens to
the image size?**
- A) It shrinks — the package is gone
- B) ✅ It doesn't shrink — layers only add, the delete just hides the file; the bytes stay in the earlier layer and still ship with the image
- C) It shrinks, but only for `apt` packages, not `pip` ones
- D) It depends on the base image

**6. Your Python/ML image is huge, so you switch the base from
`python:3.12` to `python:3.12-alpine` to save space. What's the catch?**
- A) There is none, Alpine is always smaller and safer
- B) Alpine doesn't support Python at all
- C) ✅ Alpine uses musl, not glibc — many scientific/ML wheels (PyTorch included) ship no musl wheel, so pip compiles from source: slower builds, and the image can end up *bigger*
- D) Alpine images can't run as non-root

**7. What does a Kubernetes `Service` actually give you?**
- A) A place to store secrets
- B) ✅ A stable name and load balancer in front of a set of pods, so callers don't need to track individual pod IPs
- C) Automatic horizontal scaling
- D) Encrypted traffic between pods

**8. Which of these is one of the four DORA metrics used to measure whether
DevOps is "actually working"?**
- A) Test coverage percentage
- B) Number of open pull requests
- C) ✅ Lead time for change (commit to production)
- D) Lines of code per engineer

**9. What branching model does the deck say most Dataroots projects use?**
- A) GitFlow, with long-lived `develop` and `release` branches
- B) ✅ Trunk-based development — one `main` branch, short-lived feature branches merged within a day or two
- C) One branch per environment (dev/staging/prod)
- D) Fork-and-pull-request only, no shared repo

**10. In a proper CI/CD pipeline, how should the same application move from
dev to production?**
- A) Rebuild the image separately for each environment, using the same source code
- B) ✅ Build the artifact once, then retag/promote that exact same image between environments — never rebuild
- C) Deploy directly from a developer's laptop once tests pass locally
- D) Copy the compiled files over SSH to each server
