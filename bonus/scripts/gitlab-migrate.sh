#!/bin/bash

# Variables
PORT=8080
DOMAIN="jihagukdejeok.ai"
GITHUB_REPO="git@github.com:Alixmixx/deploy_amuller_42.git"
GITLAB_DOMAIN="http://${DOMAIN}:${PORT}"
GITLAB_PROJECT_NAME="gitlab_playground"
ARGOCD_APP_NAME="playground"
GITLAB_USERNAME="root"
GITLAB_PASSWORD="$(kubectl get secret gitlab-gitlab-initial-root-password -n gitlab -ojsonpath='{.data.password}' | base64 --decode)"
GITLAB_PERSONAL_ACCESS_TOKEN=$(tr -dc 'a-zA-Z' < /dev/urandom | head -c 26)
GITLAB_TOOLBOX="$(kubectl get pods -n gitlab | grep gitlab-toolbox | awk '{print $1}')"
NEW_GITLAB_REPO_URL="${GITLAB_DOMAIN}/${GITLAB_USERNAME}/${GITLAB_PROJECT_NAME}.git"

echo -e "GitLab credentials:\nUsername: ${GITLAB_USERNAME}\nPassword: ${GITLAB_PASSWORD}"
echo ${GITLAB_PASSWORD} > gitlabpass

kubectl --namespace gitlab exec -it ${GITLAB_TOOLBOX} -- /srv/gitlab/bin/rails runner "token = User.find_by_username('${GITLAB_USERNAME}').personal_access_tokens.create(scopes: ['api', 'read_repository', 'write_repository'], name: 'Jihagukdejeok token', expires_at: 125.days.from_now); token.set_token('${GITLAB_PERSONAL_ACCESS_TOKEN}'); token.save!"

# Clone the GitHub repository
git clone ${GITHUB_REPO} ${GITLAB_PROJECT_NAME}
cd ${GITLAB_PROJECT_NAME}
git remote rename origin old-origin
git remote add origin http://${GITLAB_USERNAME}:${GITLAB_PERSONAL_ACCESS_TOKEN}@${DOMAIN}:${PORT}/${GITLAB_USERNAME}/${GITLAB_PROJECT_NAME}.git
git push --set-upstream origin --all 
git push --set-upstream origin --tags

curl --request PUT --header "PRIVATE-TOKEN: ${GITLAB_PERSONAL_ACCESS_TOKEN}" \
        --url "${GITLAB_DOMAIN}/api/v4/projects/${GITLAB_USERNAME}%2F${GITLAB_PROJECT_NAME}" \
        --data "visibility=public"

# Update the Argo CD application to point to the new GitLab repository

argocd proj add-source ${ARGOCD_APP_NAME} http://gitlab-webservice-default.gitlab.svc:8181/${GITLAB_USERNAME}/${GITLAB_PROJECT_NAME}.git
argocd app set ${ARGOCD_APP_NAME} --repo http://gitlab-webservice-default.gitlab.svc:8181/${GITLAB_USERNAME}/${GITLAB_PROJECT_NAME}.git
argocd app sync ${ARGOCD_APP_NAME}

echo "Repository transitioned and Argo CD application updated successfully."