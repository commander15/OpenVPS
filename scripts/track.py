from utils.command import subCommand, arguments

import psutil

def find_connections_on_ports(target_ports: list[int]):
    port_str = list(map(str, target_ports))
    print(f"🔍 Searching for listening connections on port {", ".join(port_str)} ...")
    
    # 'inet' filters for IPv4 and IPv6 connections
    connections = psutil.net_connections(kind='inet')
    found_any = False

    for conn in connections:
        # Filter for: 
        # 1. Listening status (like ss -l)
        # 2. Match TCP or UDP kinds (like ss -tu)
        # 3. Target local port match
        if conn.status == psutil.CONN_LISTEN and conn.laddr.port in target_ports:
            found_any = True
            transport_type = "TCP" if conn.type == 1 else "UDP" # 1 = SOCK_STREAM, 2 = SOCK_DGRAM
            local_ip = conn.laddr.ip
            pid = conn.pid
            
            # Fetch the process name if a PID exists (like ss -p requires sudo/root access)
            process_name = "Unknown"
            if pid:
                try:
                    process_name = psutil.Process(pid).name()
                except:
                    process_name = "Access Denied / Dead Process"

            print(f"[{transport_type}] {local_ip}:{conn.laddr.port} -> PID: {pid} ({process_name})")

    if not found_any:
        print(f"ℹ️ No active listeners found on port {target_ports}.")

if __name__ == "__main__":
    match subCommand():
        case 'port' | 'ports':
            args = arguments() or []
            if len(args) > 0:
                ports = []
                for p in args:
                    ports.append(int(p))
                find_connections_on_ports(ports)
