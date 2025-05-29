#!/bin/bash
set -e

# CouchDBの起動を待つ
until $(curl -s --head http://localhost:5984/_up 2>/dev/null | grep "200 OK"); do
  echo "Waiting for CouchDB to start..."
  sleep 5
done

echo "CouchDB is up."

# 作成したいデータベース名（環境変数から取得）
DATABASE_NAME="${COUCHDB_APP_DB}"

# 作成したいユーザー情報（環境変数から取得）
USERNAME="${COUCHDB_APP_USER}"
PASSWORD="${COUCHDB_APP_PASSWORD}"

# スーパーユーザーの認証情報（環境変数から取得）
ADMIN_USER="${COUCHDB_USER}"
ADMIN_PASSWORD="${COUCHDB_PASSWORD}"

# 作成するユーザー名とパスワード、データベース名が環境変数で設定されていない場合は終了
if [ -z "${COUCHDB_USER}" ] || [ -z "${COUCHDB_PASSWORD}" ] || [ -z "${COUCHDB_APP_USER}" ] || [ -z "${COUCHDB_APP_PASSWORD}" ] || [ -z "${COUCHDB_APP_DB}" ]; then
  echo "環境変数 COUCHDB_USER, COUCHDB_PASSWORD, COUCHDB_APP_USER, COUCHDB_APP_PASSWORD, COUCHDB_APP_DB のいずれかが設定されていません。処理を中断します。"
  exit 0
fi

# データベースが存在するか確認し、存在しなければ作成
if ! curl -X GET "http://localhost:5984/${DATABASE_NAME}" -u "${ADMIN_USER}:${ADMIN_PASSWORD}" 2>/dev/null | grep "200 OK"; then
  echo "Database '${DATABASE_NAME}' does not exist. Creating..."
  curl -X PUT "http://localhost:5984/${DATABASE_NAME}" -u "${ADMIN_USER}:${ADMIN_PASSWORD}"
  echo "Database '${DATABASE_NAME}' created."
else
  echo "Database '${DATABASE_NAME}' already exists."
fi

# ユーザーが存在するか確認し、存在しなければ作成
USER_ID="org.couchdb.user:${USERNAME}"
if ! curl -X GET "http://localhost:5984/_users/${USER_ID}" -u "${ADMIN_USER}:${ADMIN_PASSWORD}" 2>/dev/null | grep "200 OK"; then
  echo "User '${USERNAME}' does not exist. Creating..."
  curl -X PUT \
    -H "Content-Type: application/json" \
    -u "${ADMIN_USER}:${ADMIN_PASSWORD}" \
    "http://localhost:5984/_users/${USER_ID}" \
    -d "{
      \"name\": \"${USERNAME}\",
      \"password\": \"${PASSWORD}\",
      \"roles\": [],
      \"type\": \"user\"
    }"
  echo "User '${USERNAME}' created."

  # 作成したユーザーにデータベースへの read/write 権限を付与
  curl -X GET "http://localhost:5984/${DATABASE_NAME}/_security" -u "${ADMIN_USER}:${ADMIN_PASSWORD}" -H "Content-Type: application/json" -o security.json
  if jq -e ".members.names += [\"${USERNAME}\"]" security.json > updated_security.json; then
    mv updated_security.json security.json
    curl -X PUT "http://localhost:5984/${DATABASE_NAME}/_security" -u "${ADMIN_USER}:${ADMIN_PASSWORD}" -H "Content-Type: application/json" -d "@security.json"
    echo "User '${USERNAME}' granted read/write access to '${DATABASE_NAME}'."
  else
    echo "Failed to grant read/write access to '${USERNAME}' on '${DATABASE_NAME}'."
  fi
  rm security.json # クリーンアップ
fi
