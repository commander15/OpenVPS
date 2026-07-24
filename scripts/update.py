from utils.command import run_command, CalledProcessError
from utils.docker import run_docker_pull

GIT_BRANCH = "main"

def update(exitOnError: bool = False):
    # Git Fetch
    run_command('git', ['fetch', f'origin/{GIT_BRANCH}'], printOutput=True, exitOnError=exitOnError)

    # Git Reset
    run_command('git', ['reset', '--hard', f'origin/{GIT_BRANCH}' ], printOutput=True, exitOnError=exitOnError)

    # Docker pull
    run_docker_pull(exitOnError=exitOnError)

if __name__ == "__main__":
    update(exitOnError=True)