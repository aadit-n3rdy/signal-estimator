#!env bash

function find_login() {
    local github_login="$(curl -s "https://api.github.com/search/users?q=$1" \
        | jq -r '.items[0].login' 2>/dev/null)"

    if [[ "${github_login}" != "" ]] && [[ "${github_login}" != "null" ]]
    then
        echo "${github_login}"
    fi
}

function find_name() {
    local github_name="$(curl -s "https://api.github.com/users/$1" \
        | jq -r .name 2>/dev/null \
        | sed -r -e 's,^\s*,,' -e 's,\s*$,,')"

    if [[ "${github_name}" != "" ]] && [[ "${github_name}" != "null" ]]
    then
        echo "${github_name}"
    fi
}

function find_email() {
    local github_email="$(curl -s "https://api.github.com/users/$1/events/public" \
        | jq -r \
    '((.[].payload.commits | select(. != null))[].author | select(.name == "'$1'")).email' \
    2>/dev/null \
        | sort -u \
        | grep -v users.noreply.github.com \
        | head -1)"

    if [[ "${github_email}" != "" ]] && [[ "${github_email}" != "null" ]]
    then
        echo "${github_email}"
    fi
}

function add_if_new() {
    local file="$1"

    local commit_name="$2"
    local commit_email="$3"

    if grep -qiF "${commit_name}" "${file}" || grep -qiF "${commit_email}" "${file}"
    then
        return
    fi

    local github_login="$(find_login "${commit_email}")"
    if [ -z "${github_login}" ]
    then
        github_login="$(find_login "${commit_name}")"
    fi
    if [[ -z "${github_login}" ]]
    then
        if echo "${commit_email}" | grep -q users.noreply.github.com
        then
            github_login="$(echo "${commit_email}" | sed -re 's,^([0-9]+\+)?([^@]+).*$,\2,')"
        fi
    fi

    local print_name="$(find_name "${github_login}")"
    if [ -z "${print_name}" ]
    then
        print_name="${commit_name}"
    fi
    print_name="$(echo "${print_name}" | sed -re 's/\S+/\u&/g')"

    local print_addr=""
    if echo "${commit_email}" | grep -q users.noreply.github.com
    then
        if [[ ! -z "${github_login}" ]]
        then
            print_addr="$(find_email "${github_login}")"
        fi
    else
        print_addr="${commit_email}"
    fi
    if [[ -z "${print_addr}" && ! -z "${github_login}" ]]
    then
        print_addr="https://github.com/${github_login}"
    fi

    if [ -z "${print_addr}" ]
    then
        echo "adding ${print_name}" 1>&2
        echo "${print_name}"
    else
        echo "adding ${print_name} <${print_addr}>" 1>&2
        echo "${print_name} <${print_addr}>"
    fi
}

function add_contributors() {
    out_file="$1"
    repo_dir="$2"

    git log --encoding=utf-8 --full-history --reverse "--format=format:%at,%an,%ae" \
        | sort -u -t, -k3,3 \
        | sort -t, -k1n \
        | while read line
    do
        name="$(echo "${line}" | cut -d, -f2)"
        email="$(echo "${line}" | cut -d, -f3)"

        add_if_new "${out_file}" "${name}" "${email}" >> "${out_file}"
    done
}

function update_authors() {
    file="AUTHORS"
    temp="$(mktemp)"

    cat "${file}" > "${temp}"

    add_contributors "${temp}" "$(pwd)"

    cat "$temp" > "${file}"
    rm "${temp}"
}

cd "$(dirname "$0")/.."

update_authors "${sphinx}"

echo "done"
