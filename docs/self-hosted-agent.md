# Setup a self-hosted azure devops pipeline agent in linux VM
- Click on Orgnization and select Orgnization setting option.
- Under pipelines, select Agent pools
- Delete the default pool and add new pool. While creating new pool select option for self-hosted.
- Click on the pool name you have created and click on option new agent ( right side top ).
- Select Windows linux or mac and follow instruction given to download agent file.

### Linux self hosted agent installation and configuration.
**Note:** Agent should be configured with a sudo user but without sudo option.
- Download the agent with wget option.
```bash
mkdir myagent && cd myagent
wget https://vstsagentpackage.azureedge.net/agent/4.251.0/vsts-agent-linux-x64-4.251.0.tar.gz
tar -xvf vsts-agent-linux-x64-4.251.0.tar.gz
```
To configure the agent use this one liner command.  
```bash
./config.sh --unattended  --url https://dev.azure.com/krlabado16feb25 --auth pat --token <mypattoken> --pool onprem --agent onpremvm1 --work /home/vijay/agent_work --acceptTeeEula
```

Where :        
1. **https://dev.azure.com/krlabado16feb25** is azure devops orgnization url.     
2. **mypattoken** Your PAT token you have generated with full access.     
3. **onprem**  The agent pool name you have created.       
4. **onpremvm1** The agnet name for the VM you want to give.     
5. **/home/vijay/agent_work**  The home directory location for your user with work dir.     

Once the above is done, configuration is over but now you need to start agent service so run bellow.    
```bash
 sudo ./svc.sh install
 sudo ./svc.sh start
```
You can check the agent service and can restart as well with bellow commands.     
```bash
 sudo ./svc.sh restart
 sudo ./svc.sh status
```
