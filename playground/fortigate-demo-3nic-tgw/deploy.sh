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