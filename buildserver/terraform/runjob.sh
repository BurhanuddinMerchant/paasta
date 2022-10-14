sudo docker load -i job.tar
sudo docker run --name job -d -p 80:5000 job