#!/bin/bash
set -e

if [ -n "${GITHUB_WORKSPACE}" ]; then
      git config --global --add safe.directory "${GITHUB_WORKSPACE}" || exit 1
      git config --global --add safe.directory "${GITHUB_WORKSPACE}/${INPUT_WORKDIR}" || exit 1
      cd "${GITHUB_WORKSPACE}/${INPUT_WORKDIR}" || exit 1
fi

export PY_EXE="${INPUT_PYTHON_VERSION}"
export REVIEWDOG_GITHUB_API_TOKEN="${INPUT_GITHUB_TOKEN}"
TMPFILE=$(mktemp)
export TMPFILE

echo "Running in: ${PWD}"
echo -e "\n============================="
echo "flakeheaven installed plugins:"
${PY_EXE} -m flakeheaven plugins

echo -e "\n============================="
echo "flakeheaven config file (optional):"
ls -la pyproject.toml || :
cat pyproject.toml || :

echo -e "\n============================="
echo "Running flakeheaven, teeing and saving output to tmpfile: ${TMPFILE} (ignore non-zero exit)"
${PY_EXE} -m flakeheaven lint | tee "${TMPFILE}" || :

echo -e "\n============================="
ls -la "${TMPFILE}"
echo -e "\n============================="
echo "Head of ${TMPFILE}:"
head "${TMPFILE}"

echo -e "\n============================="
echo "Running reviewdog with:"
# shellcheck disable=SC2016
echo 'reviewdog -efm="%f:%l:%c: %m" \
      -name="flakeheaven" \
      -reporter="${INPUT_REPORTER:-github-pr-check}" \
      -filter-mode="${INPUT_FILTER_MODE}" \
      -fail-on-error="${INPUT_FAIL_ON_ERROR}" \
      -level="${INPUT_LEVEL}" \
      -tee < "${TMPFILE}"'
echo
echo "Where vars are:"
echo "  INPUT_REPORTER=${INPUT_REPORTER}"
echo "  INPUT_FILTER_MODE=${INPUT_FILTER_MODE}"
echo "  INPUT_FAIL_ON_ERROR=${INPUT_FAIL_ON_ERROR}"
echo "  INPUT_LEVEL=${INPUT_LEVEL}"

echo -e "\n============================="
reviewdog -efm="%f:%l:%c: %m" \
      -name="flakeheaven" \
      -reporter="${INPUT_REPORTER:-github-pr-check}" \
      -filter-mode="${INPUT_FILTER_MODE}" \
      -fail-on-error="${INPUT_FAIL_ON_ERROR}" \
      -level="${INPUT_LEVEL}" \
      -tee <"${TMPFILE}"

echo -e "\n============================="
echo "Done running reviewdog, exiting..."
