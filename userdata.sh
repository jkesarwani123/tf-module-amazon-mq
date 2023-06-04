cd /opt
git clone https://github.com/jkesarwani123/Sample-Project.git
cd Sample-Project
bash rabbitmq.sh ${rabbitmq_appuser_password} &>>/opt/roboshop.log
