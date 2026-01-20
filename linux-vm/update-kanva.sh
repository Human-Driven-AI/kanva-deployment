#!/bin/bash
docker compose down
docker pull kanvaimages.azurecr.io/efbundle:latest
docker pull kanvaimages.azurecr.io/hub:latest
docker pull kanvaimages.azurecr.io/delphi:latest
docker pull kanvaimages.azurecr.io/pythoness:latest
docker compose up -d
