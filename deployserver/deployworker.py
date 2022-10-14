import subprocess

print("Deployment started")


print("Unzipping Image...")

with open("./logs/unzip.log", "w") as output:
    subprocess.call(
        "docker load -i job.tar",
        shell=True,
        stdout=output,
        stderr=output,
    )
print("Image unzip complete")
print("running container")

with open("./logs/run.log", "w") as output:
    subprocess.Popen(
        "docker run --name job -d -p 5000:5000 job",
        shell=True,
        stdout=output,
        stderr=output,
    )
print("Application deployed successfully!")
