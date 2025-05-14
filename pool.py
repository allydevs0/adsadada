import requests
import os
import subprocess
import time

# ESTE SCRIPT É FEITO PARA SER USADO COM ~~  KEYRUNT  ~~
# ESTA É UMA CÓPIA MODIFICADA DO SCRIPT FEITO POR JEFINHO ~~ https://github.com/lmajowka/btcpythonscripts/blob/main/pool.py ~~
# INSTALE O KEYRUNT ANTES DE EXECUTAR O SCRIPT
# PARA EXECUTAR O MESMO, APENAS COLOQUE O ARQUIVO NA PASTA KEYRUNT

API_URL = "https://bitcoinflix.replit.app/api/block"
POOL_TOKEN = "b74dbd378423853dcac48da304b2e1aa4e115335a7207752478e01552fda1e13"
ADDITIONAL_ADDRESS = ""

def clear_screen():
    os.system("cls" if os.name == "nt" else "clear")

def fetch_block_data():
    headers = {"pool-token": POOL_TOKEN}
    try:
        response = requests.get(API_URL, headers=headers)
        if response.status_code == 200:
            return response.json()
        else:
            print(f"Erro ao buscar dados do bloco: {response.status_code} - {response.text}")
            return None
    except requests.RequestException as e:
        print(f"Erro ao fazer a requisição: {e}")
        return None

def save_addresses_to_file(addresses, additional_address, filename="in.txt"):
    try:
        with open(filename, "w") as file:
            for address in addresses:
                file.write(address + "\n")
            if additional_address:
                file.write(additional_address + "\n")
        print(f"Endereços salvos com sucesso no arquivo '{filename}'.")
    except Exception as e:
        print(f"Erro ao salvar endereços no arquivo: {e}")

def clear_file(filename):
    try:
        with open(filename, "w") as file:
            pass
        print(f"Arquivo '{filename}' limpo com sucesso.")
    except Exception as e:
        print(f"Erro ao limpar o arquivo '{filename}': {e}")

def run_program(start, end):
    keyspace = f"{start}:{end}"
    command = [
        "./keyhunt",
        "m", "address",
        "-t", "16",
        "-e",
        "-q",
        "-n", "1024",
        "-s", "10",
        "-l", "compress",
        "-k", "2048",
        "-f", "in.txt",
        "-r", keyspace,
    ]
    try:
        print(f"Executando o programa com keyspace {keyspace}...")
        subprocess.run(command, check=True)
        print("Programa executado com sucesso.")
    except subprocess.CalledProcessError as e:
        print(f"Erro ao executar o programa: {e}")
    except Exception as e:
        print(f"Erro inesperado: {e}")

def post_private_keys(private_keys):
    headers = {
        "pool-token": POOL_TOKEN,
        "Content-Type": "application/json"
    }
    data = {"privateKeys": private_keys}

    print(f"Enviando o seguinte array de chaves privadas ({len(private_keys)} chaves):")
    print(private_keys)

    try:
        response = requests.post(API_URL, headers=headers, json=data)
        if response.status_code == 200:
            print("Chaves privadas enviadas com sucesso.")
        else:
            print(f"Erro ao enviar chaves privadas: {response.status_code} - {response.text}")
    except requests.RequestException as e:
        print(f"Erro ao fazer a requisição POST: {e}")

def process_out_file(out_file="KEYFOUNDKEYFOUND.txt", in_file="in.txt", additional_address=ADDITIONAL_ADDRESS):
    if not os.path.exists(out_file):
        print(f"Arquivo '{out_file}' não encontrado.")
        return False

    if not os.path.exists(in_file):
        print(f"Arquivo '{in_file}' não encontrado.")
        return False

    private_keys = {}
    addresses = []
    found_additional_address = False

    try:
        with open(in_file, "r") as file:
            addresses = [line.strip() for line in file if line.strip()]

        if additional_address in addresses:
            addresses.remove(additional_address)

        with open(out_file, "r") as file:
            pending_private_key = None
            for line in file:
                if "Private Key:" in line:
                    pending_private_key = line.split("Private Key:")[1].strip()
                elif "Address" in line and pending_private_key:
                    current_address = line.split("Address")[1].strip()
                    private_keys[current_address] = pending_private_key
                    if current_address == additional_address:
                        input("CHAVE DA CARTEIRA ENCONTRADA !!!!!!!")
                        print(f"Chave encontrada: {pending_private_key}")
                        found_additional_address = True
                        return True  # Encerra o processo se encontrou

        if len(private_keys) != len(addresses):
            print(f"Erro: Número de chaves privadas ({len(private_keys)}) não corresponde ao número de endereços ({len(addresses)}).")
            return False

        ordered_private_keys = [private_keys[addr] for addr in addresses if addr in private_keys]

        for i in range(0, len(ordered_private_keys), 10):
            batch = ordered_private_keys[i:i + 10]
            if len(batch) == 10:
                post_private_keys(batch)
            else:
                print(f"Lote com menos de 10 chaves ignorado: {batch}")

    except Exception as e:
        print(f"Erro ao processar os arquivos: {e}")
        return False

    clear_file(out_file)
    return False

# Loop Principal
if __name__ == "__main__":
    while True:
        clear_screen()
        block_data = fetch_block_data()
        if block_data:
            addresses = block_data.get("checkwork_addresses", [])
            if addresses:
                save_addresses_to_file(addresses, ADDITIONAL_ADDRESS)

                range_data = block_data.get("range", {})
                start = range_data.get("start", "").replace("0x", "")
                end = range_data.get("end", "").replace("0x", "")

                if start and end:
                    run_program(start, end)
                    if process_out_file():
                        break
                else:
                    print("Erro: Start ou End não encontrado no range.")
            else:
                print("Nenhum endereço encontrado no bloco.")
        else:
            print("Erro ao buscar dados do bloco.")

        time.sleep(5)
