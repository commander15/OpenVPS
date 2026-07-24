from utils.command import run_command, subCommand, arguments, CompletedProcess

from dotenv import set_key

def use_address(usage: str):
    result = run_command('tailscale', [ 'ip' ], printOutput=False, exitOnError=True)
    if not isinstance(result, CompletedProcess):
        return
    
    # Retrieve the clean, stripped text from the standard output stream
    ips = (result.stdout or bytes()).strip().splitlines()
    if not ips:
        return
    
    ip = str(ips[0]).removeprefix('b\'').removesuffix('\'')
    match usage:
        case 'public':
            print("🌐 Setting up public network interface...")
            set_key('.env', 'VPS_PUBLIC_IP', ip, quote_mode='never')
            
        case 'private':
            print("🔒 Setting up private network interface...")
            set_key('.env', 'VPS_PRIVATE_IP', ip, quote_mode='never')

    print("IP set to:", ip)



# ============================= MAIN =======================================

if __name__ == "__main__":
    if subCommand() == 'set':
        args = arguments()
        if args:
            use_address(usage=args[0])
        else:
            use_address('public')
            use_address('private')
