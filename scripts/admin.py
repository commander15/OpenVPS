from utils.docker import run_docker_compose_up, run_docker_compose_down, run_docker_compose
from utils.command import subCommand

def up(exitOnError: bool = False):
    run_docker_compose_up([ 'core', 'admin' ], exitOnError=exitOnError)

def down(exitOnError: bool = False):
    run_docker_compose_down([ 'admin' ], exitOnError=exitOnError)


# ============================= MAIN =======================================

if __name__ == "__main__":
    match subCommand():
        case 'up':
            up(exitOnError=True)

        case 'down':
            down(exitOnError=True)

        case _:
            run_docker_compose([ 'admin' ], exitOnError=True)