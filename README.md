# Getting Started Documentation
### Thanks for this opportunity, and I hope my work is satisfactory.

1- Add LiveController.java file to handle HTTP Logic (src/main/java/com/example/demo/LiveController.java)

2- Add application.properties to handle database connections (src/main/resources/application.properties)

3- Edit build.gradle with last changes

4- Add Dockerfile to handle build and run of app ### I don't have gradle locally so I build the app in docker layer first 

5- Add docker-compose file to handle creations and run of App and Database at any server

6- Add Terraform files to create infrastrucure at AWS (VPC,SUBNETS,ASG,LB,EC2,RDS,...)

7- Add ansible files to configure EC2s to can run the app 

8- Add GitHub Workflows to run all past steps:
    - Terraform.yml (manuall) >> to create infra at AWS and store RDS endpoint to Github secrets and store LB DNS to Github variables 
    - app_ci.yml (automatic on push to main)>> to build app docker image and push it 
    - deploy.yml (automatic on push to main and CI succeeded )>> to deploy the last docker image to all EC2 
    
    



