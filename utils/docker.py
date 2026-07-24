import sys
import docker

from utils.command import run_command

def get_client():
    return docker.from_env()

def run_docker(args: list[str], exitOnError: bool = False):
    return run_command('docker', args, scrollable=False, printOutput=True, exitOnError=exitOnError)

def run_docker_compose(profiles: list[str], args: list[str] | None = None, exitOnError: bool = False):
    """Executes docker compose under the profile with passed arguments."""
    profileArgs = []
    for profile in profiles:
        profileArgs.append('--profile')
        profileArgs.append(profile)

    if args == None:
        args = sys.argv
        args.pop(0)

    return run_docker(args=[ 'compose' ] + profileArgs + args, exitOnError=exitOnError)

def run_docker_compose_up(profiles: list[str], exitOnError: bool = False):
    args = [ 'up', '--build', '-d' ]
    if 'core' in profiles:
        return run_docker_compose(profiles, args, exitOnError=exitOnError)
    else:
        return run_docker_compose([ 'core' ] + profiles, args, exitOnError=exitOnError)

def run_docker_compose_down(profiles: list[str], exitOnError: bool = False):
    args = [ 'down' ]
    if 'core' in profiles:
        return run_docker_compose(profiles, args, exitOnError=exitOnError)
    else:
        return run_docker_compose([ 'core' ] + profiles, args, exitOnError=exitOnError)

def run_docker_compose_pull(exitOnError: bool = False):
    return run_docker_compose([ '*' ], [ 'pull' ], exitOnError=exitOnError)


# ============================================ MAIN =====================================================

if __name__ == "__main__":
    args = sys.argv;
    if len(args) > 0:
        profiles = [ args.pop(0) ]
    else:
        profiles = [ "*" ]

    if len(args) == 0:
        subCommand = ''
    else:
        subCommand = args.pop(0)

    if subCommand == 'up':
        run_docker_compose_up(profiles, exitOnError=True)
    elif subCommand == 'down':
        run_docker_compose_down(profiles, exitOnError=True)
    elif subCommand == 'pull':
        run_docker_compose_pull(exitOnError=True)
    elif subCommand == 'compose':
        run_docker_compose(profiles, args, exitOnError=True)
    else:
        run_docker(args, exitOnError=True)