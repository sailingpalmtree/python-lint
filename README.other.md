# Description

This repo contains a GitHub action to run code linters and report thheir findings on GitHub.

The currently supported code linters are:
- [flakeheaven](https://github.com/flakeheaven/flakeheaven),
using [reviewdog](https://github.com/reviewdog/reviewdog) to annotate code changes on GitHub.

This action was created from `reviewdog`'s awesome [action template](https://github.com/reviewdog/action-template).

## Current status

For `push` events to the `master` branch:

[![Test flakeheaven with Reviewdog](https://github.com/sailingpalmtree/lint/actions/workflows/test.yml/badge.svg?branch=master&event=push)](https://github.com/sailingpalmtree/lint/actions/workflows/test.yml)
[![Docker Image CI](https://github.com/sailingpalmtree/lint/actions/workflows/dockerimage.yml/badge.svg?branch=master&event=push)](https://github.com/sailingpalmtree/lint/actions/workflows/dockerimage.yml)
[![Test Flakehell with Reviewdog](https://github.com/sailingpalmtree/lint/actions/workflows/test.yml/badge.svg?branch=master&event=push)](https://github.com/sailingpalmtree/lint/actions/workflows/test.yml)
[![reviewdog](https://github.com/sailingpalmtree/lint/actions/workflows/reviewdog.yml/badge.svg?branch=master&event=push)](https://github.com/sailingpalmtree/lint/actions/workflows/reviewdog.yml)
[![release](https://github.com/sailingpalmtree/lint/actions/workflows/release.yml/badge.svg?branch=master&event=push)](https://github.com/sailingpalmtree/lint/actions/workflows/release.yml)

## Usage

```yaml
name: reviewdog-flakehell
on: [pull_request]
jobs:
  flakehell:
    name: runner / flakehell
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: sailingpalmtree/lint@0.2
        with:
          github_token: ${{ secrets.github_token }}
          # Change reviewdog reporter if you need [github-pr-check,github-check,github-pr-review].
          reporter: github-pr-review
          # Change reporter level if you need.
          # GitHub Status Check won't become failure with warning.
          level: warning
```

## Releases

- v0.2 - first fully tested, and actually fully used version
- v0.1 - first draft release

## Testing

There are three ways to test this action:

1. The included test workflows will run some sanity tests.
2. You can test the full flow of the Action with `act`.
3. You can also test the steps the Action will invoke with a locally built `docker` container.

### Use the included test workflows

These are defined in [`test.yaml`](https://github.com/sailingpalmtree/lint/blob/master/.github/workflows/test.yml). One can further configure these, but you can see in mine how I set them up.

### Test the action locally

For this I used the tool [act](https://github.com/nektos/act).

#### Platforms

I saved the platforms I cared about in my `~/.actrc` file:

```text
-P ubuntu-latest=ghcr.io/catthehacker/ubuntu:act-latest
-P ubuntu-20.04=ghcr.io/catthehacker/ubuntu:act-20.04
-P ubuntu-18.04=ghcr.io/catthehacker/ubuntu:act-18.04
```

(note that you could pass these in on the command line too with `-P`)

#### Secrets and environment variables

In order to pass in secrets and other env variables to the action, I saved these in `.env` and `.secret` files.
(Don't forget to add these to `.gitignore` for obvious reasons)
`act` by default will read these files with these names but you can name them differently and pass them in with their flags.
Alternatively, you can pass them in on the `act` command line too.

#### Invocation

I ran `act` with the simple `act push` command. Here, `push` was meant to simulate a GitHub `push` event. You can use any other event, and you can further configure them if you wish.

### With a locally built Docker image

There's an included `Dockerfile.testing` that can be used to build a container identical to the one the Action uses when it's running. The only difference is that `Dockerfile.testing` doesn't invoke the `entrypoint.sh` script - instead it drops you into `bash` upon running the container. This is so that you can then manually inspect the contents of the container and run any commands you like, including the ones the `entrypoint.sh` script has. Naturally, you'll have to set the needed environment variables yourself in this case.

Feel free to modify the `Dockerfile` or the `Dockerfile.testing`, but always make sure they only differ in their entrypoint. In other words, running `diff Dockerfile*` should show only the following:

```bash
diff Dockerfile*
# [some line numbers here]
< COPY entrypoint.sh /entrypoint.sh
<
< ENTRYPOINT ["/entrypoint.sh"]
---
> ENTRYPOINT [ "/bin/bash" ]
```
