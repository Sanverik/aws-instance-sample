#!/bin/bash

TF_VAR_AWS_ACCESS_KEY=$AWS_ACCESS_KEY TF_VAR_SECRET_ACCESS_KEY=$AWS_SECRET_KEY terraform apply

echo "Apply terraform changes"