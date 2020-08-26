#!/bin/bash
echo "
##############################################################################################################
#
# Fortinet FortiGate 3NIC TGW
#
##############################################################################################################

"

# Stop running when command returns error
set -e

PLAN="terraform.tfplan"

if [ -z "$DEPLOY_PREFIX" ]
then
    # Input prefix
    echo -n "Enter prefix: "
    stty_orig=`stty -g` # save original terminal setting.
    read prefix         # read the prefix
    stty $stty_orig     # restore terminal setting.
    if [ -z "$prefix" ]
    then
        prefix="JBI-DEMO-FGT-AP-LB"
    fi
else
    prefix="$DEPLOY_PREFIX"
fi
export TF_VAR_PREFIX="$prefix"
echo ""
echo "--> Using prefix $prefix for all resources ..."
echo ""
rg_cgf="$prefix-RG"

if [ -z "$DEPLOY_PASSWORD" ]
then
    # Input password
    echo -n "Enter password: "
    stty_orig=`stty -g` # save original terminal setting.
    stty -echo          # turn-off echoing.
    read passwd         # read the password
    stty $stty_orig     # restore terminal setting.
    echo ""
else
    passwd="$DEPLOY_PASSWORD"
    echo ""
    echo "--> Using password found in env variable DEPLOY_PASSWORD ..."
    echo ""
fi
PASSWORD="$passwd"

echo ""
echo "==> Starting Terraform deployment"
echo ""
cd terraform/

echo ""
echo "==> Terraform init"
echo ""
terraform init

echo ""
echo "==> Terraform plan"
echo ""
terraform plan --out "$PLAN"

echo -n "Do you want to continue? Type yes: "
stty_orig=`stty -g` # save original terminal setting.
read continue         # read the location
stty $stty_orig     # restore terminal setting.

if [[ $continue == "yes" ]]
then
    echo ""
    echo "==> Terraform apply"
    echo ""
    terraform apply "$PLAN"
    if [[ $? != 0 ]];
    then
        echo "--> ERROR: Deployment failed ..."
        exit $rc;
    fi
else
    echo "--> ERROR: Deployment cancelled ..."
    exit $rc;
fi