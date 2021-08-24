# Create a resource group with tags to be used for the other resources
New-AzResourceGroup -Name 'rg-sftp-dp' -Location 'West US' -Tag @{Environment='stage'; Organization='NSO&CF'; Dept='IT'; Project='MODS'; 'Technical-Contact'='[tech contant here]'; 'Project-Owner'='[business contact here]'}
# Initial deployment to get the majority of the data engineering platform build up
New-AzResourceGroupDeployment -Name 'sftp-deployment' -ResourceGroupName 'rg-sftp-dp' -TemplateFile 'main.bicep'
