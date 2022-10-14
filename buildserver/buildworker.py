from git import Repo
import subprocess
import time

print("clonning repo....")

Repo.clone_from("https://github.com/BurhanuddinMerchant/docker-init.git", "./clone")

print("cloned repo ")


def wait_timeout(proc, seconds, err):
    """Wait for a process to finish, or raise exception after timeout"""
    start = time.time()
    end = start + seconds
    interval = min(seconds / 1000.0, 0.25)

    while True:
        result = proc.poll()
        if result is not None:
            return result
        if time.time() >= end:
            raise RuntimeError(err)
        time.sleep(interval)


print("building container image....")
with open("./logs/build.log", "a") as output:
    p = subprocess.Popen(
        ["sudo docker build -t job ./clone"],
        shell=True,
        stdout=output,
        stderr=output,
    )
    wait_timeout(p, 60, "Build Process Timed Out")

print("container image build successfull")
print("zipping container image....")

with open("./logs/zip.log", "w") as output:
    p = subprocess.Popen(
        "sudo docker save job -o job.tar",
        shell=True,
        stdout=output,
        stderr=output,
    )
    # wait_timeout(p, 60, "Zip Process Timed Out")
print("Zipped container image successfully")
print("Removing container image from system (cleanup)")

with open("./logs/rmi.log", "w") as output:
    p = subprocess.Popen(
        "sudo docker rmi job",
        shell=True,
        stdout=output,
        stderr=output,
    )
    # wait_timeout(p, 120, "Remove Image Process Timed Out")
subprocess.call("rm -rf clone", shell=True)
print("Cleanup complete")

print("Sending built image for deployment....")
subprocess.call("sudo chmod +x job.tar", shell=True)
subprocess.call("cd terraform;sudo terraform init", shell=True)
subprocess.call("cd terraform;sudo terraform apply -auto-approve", shell=True)
print("Successfully sent image for deployment")
