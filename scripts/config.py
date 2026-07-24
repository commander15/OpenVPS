import sys
import shutil
import re

from tzlocal import get_localzone
from pathlib import Path
from dotenv import set_key, dotenv_values

from utils.command import run_command, subCommand, showHelp
from .all import restart as restart_all

def commit_config(exitOnError: bool = False):
    local_tz = get_localzone()
    timezone_name = local_tz.key
    set_key('.env', 'VPS_TIMEZONE', timezone_name, quote_mode='never')


def edit_config(exitOnError: bool = False):
    run_command('nano', [ '.env' ], printOutput=True, exitOnError=exitOnError)
    return commit_config(exitOnError=exitOnError)

def reset_config(keep: list[str] | None = None, exitOnError: bool = False):
    if keep is None:
        keep = []

    env_file = Path(".env")
    example_file = Path(".env.example")
    
    saved_raw_lines = {}
    
    try:
        # 1. Extract raw literal strings using Regex before deletion
        if keep and env_file.exists():
            # Matches lines like: KEY = "value" or KEY=value with variable tokens intact
            kv_pattern = re.compile(r'^\s*([A-Za-z0-9_]+)\s*=\s*(.*)\s*$')
            
            with open(env_file, "r", encoding="utf-8") as f:
                for line in f:
                    match = kv_pattern.match(line.strip())
                    if match:
                        key, raw_value = match.group(1), match.group(2)
                        if key in keep:
                            saved_raw_lines[key] = raw_value

        # 2. Safely remove the old .env file
        if env_file.exists():
            env_file.unlink()
            
        # 3. Copy the template to .env
        shutil.copy(example_file, env_file)
        
        # 4. Inject the raw untouched values back to preserve interpolation
        if saved_raw_lines:
            # print(f"💾 Restoring raw config values for: {', '.join(saved_raw_lines.keys())}")
            for key, raw_value in saved_raw_lines.items():
                # quote_mode="never" ensures set_key doesn't wrap your value in its own quotes
                set_key(str(env_file), key, raw_value, quote_mode="never")
        
    except Exception as e:
        print(f"❌ Failed to reset config: {e}")
        if exitOnError:
            sys.exit(1)
        return False

    return edit_config(exitOnError=exitOnError)

# ============================= MAIN =======================================

if __name__ == "__main__":
   match subCommand():
    case 'edit' | None:
        edit_config(exitOnError=True)

    case 'reset':
        core_config = [ 'VPS_NAME', 'VPS_TIMEZONE', 'VPS_PUBLIC_IP', 'VPS_PRIVATE_IP', 'VPS_DEPLOYMENTS_DIR' ]
        public_config = [ 'HTTP_IP', 'HTTP_PORT', 'HTTPS_PORT', 'DNS_IP', 'DNS_PORT' ]
        admin_config = [ 'ADMIN_NAME', 'ADMIN_PASS' ]
        reset_config(keep=core_config + public_config + admin_config, exitOnError=True)
        restart_all(exitOnError=True)

    case _:
        showHelp('config', exit=True)
