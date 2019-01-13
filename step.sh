#!/bin/bash
set -ex

echo " (?) stage_files: $stage_files"
echo " (?) repository_url: $repository_url"
echo " (?) author: $author"
echo " (?) commit_message: $commit_message"
echo " (?) tag: $tag"
echo " (?) tag_message: $tag_message"
echo " (?) add_flags: $add_flags"
echo " (?) commit_flags: $commit_flags"
echo " (?) push_flags: $push_flags"
echo " (?) refspec: $refspec"

if [ -z "${stage_files}" ]; then
    echo " [!] stage_files is an empty string."
    echo " [!] A directory or a file to include in commit are required."
    exit 1
fi
if [ -z "${repository_url}" ]; then
    echo " [!] repository_url is an empty string."
    echo " [!] Remote repository URL is required."
    exit 1
fi
if [ -z "${author}" ]; then
    echo " [!] author is an empty string."
    echo " [!] Commit author credentials are required."
    exit 1
fi
if [ -z "${commit_message}" ]; then
    echo " [!] commit_message is an empty string."
    echo " [!] Commit message is required."
    exit 1
fi


git add ${add_flags} -- ${stage_files}
git commit ${commit_flags} --author "${author}" --message "${commit_message}"

if [ -n "${tag}" ]; then
    echo " (?) Adding tag ${tag} with message ${tag_message}"
    if [ -n "$(git ls-remote --tags "${repository_url}" "${tag})" ]; then 
        echo " (!) Tag already exists. Adding current commit hash as suffix"
        tag="${tag}-$(git rev-parse --short HEAD)"
        echo " (!) New tag: ${tag}"
    fi
    git tag -fa "${tag}" -m "${tag_message}"
    git push "${repository_url}" "refs/tags/${tag}"
    echo " (?) Success, remote tags are:"
    git ls-remote --tags "${repository_url}"
fi

git push ${push_flags} "${repository_url}" ${refspec}
