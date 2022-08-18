#Login interactively and set a subscription to be the current active subscription
az login
az account set --subscription "az-204"
$RG_NAME='uademo-rg'
$CONTAINER_NAME='uademo-hello-world-cli'

#Demo 0 - Deploy a container from a public registry. dns-name-label needs to be unique within your region.
az container create --resource-group $RG_NAME --name $CONTAINER_NAME --dns-name-label $CONTAINER_NAME --image mcr.microsoft.com/azuredocs/aci-helloworld --ports 80


#Show the container info
az container show --resource-group $RG_NAME --name $CONTAINER_NAME 


#Retrieve the URL, the format is [name].[region].azurecontainer.io
$URL=$(az container show --resource-group $RG_NAME --name $CONTAINER_NAME --query ipAddress.fqdn | wsl tr -d '\"') 
echo "http://$URL"




#Demo 1 - Deploy a container from Azure Container Registry with authentication
#Step 0 - Set some environment variables and create Resource Group for our demo
$ACR_NAME='uademoacr' #<---change this to match your globally unique ACR Name


#Step 1 - Obtain the full registry ID and login server which well use in the security and create sections of the demo
$ACR_REGISTRY_ID=$(az acr show --name $ACR_NAME --query id --output tsv)
$ACR_LOGINSERVER=$(az acr show --name $ACR_NAME --query loginServer --output tsv)

echo "ACR ID: $ACR_REGISTRY_ID"
echo "ACR Login Server: $ACR_LOGINSERVER"


#Step 2 - Create a service principal and get the password and ID, this will allow Azure Container Instances to Pull Images from our Azure Container Registry
$SP_PASSWD=$(az ad sp create-for-rbac --name http://$ACR_NAME-pull --scopes $ACR_REGISTRY_ID --role acrpull --query password --output tsv)

#UPDATE - --name has been deprecated by azure cli and now uses display name. 
$SP_APPID=$(az ad sp list --display-name http://$ACR_NAME-pull --query '[].appId' --output tsv)

echo "Service principal ID: $SP_APPID"
echo "Service principal password: $SP_PASSWD"


#Step 3 - Create the container in ACI, this will pull our image named
#$ACR_LOGINSERVER is uademoacr.azurecontainer.io. this should match *your* login server name
az container create --resource-group $RG_NAME --name uademo-webapp-cli --dns-name-label uademo-webapp-cli --ports 80 --image $ACR_LOGINSERVER/webappimage:v1 --registry-login-server $ACR_LOGINSERVER --registry-username $SP_APPID --registry-password $SP_PASSWD 


#Step 4 - Confirm the container is running and test access to the web application, look in instanceView.state
az container show --resource-group $RG_NAME --name uademo-webapp-cli  


#Get the URL of the container running in ACI...
#This is our hello world app we build in the previous 
$URL=$(az container show --resource-group $RG_NAME --name uademo-webapp-cli --query ipAddress.fqdn | wsl tr -d '\"') 
echo $URL
curl $URL


#Step 5 - Pull the logs from the container
az container logs --resource-group $RG_NAME --name uademo-webapp-cli


#Step 6 - Delete the running container
az container delete  --resource-group $RG_NAME --name uademo-webapp-cli --yes
az container delete  --resource-group $RG_NAME --name $CONTAINER_NAME --yes


#Step 7 - Clean up from our demos, this will delete all of the ACIs and the ACR deployed in this resource group.
#Delete the local container images
az group delete --name $RG_NAME --no-wait --yes 
docker image rm uademoacr.azurecr.io/webappimage:v1
docker image rm webappimage:v1
