import requests
import os
import subprocess
import time

# ESTE ESCRIPT É FEITO PARA SER USADO COM ~~  KEYRUNT  ~~
# ESTA E UMA COPIA MODIFICADA DO SCRIPT FEITO POR JEFINHO ~~   https://github.com/lmajowka/btcpythonscripts/blob/main/pool.py   ~~
# INSTALE O KEYRUNT ANTES DE EXECUTAR O SCRIPT
# PARA EXECUTAR O MESMO APENAS COLOQUE O ARQUIVO NA PASTA KEYRUNT

API_URL = "https://bitcoinflix.replit.app/api/block"
POOL_TOKEN = "aacb1deccad7f3b10b764ee1193e5cad8597b5b9e7c9c9028f4d70964bf4a33c"
ADDITIONAL_ADDRESS = "COLE O ENDEREÇO DA CARTEIRA PROCURADA ~~ https://privatekeys.pw/puzzles/bitcoin-puzzle-tx  ~~"

def clear_screen():
    """Limpa a tela do terminal."""
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
            file.write(additional_address + "\n")  # Adicionando o endereço adicional
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
            print(f"Chaves privadas enviadas com sucesso.")
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
        # Lendo os endereços do arquivo in.txt
        with open(in_file, "r") as file:
            addresses = [line.strip() for line in file if line.strip()]
        
        # Removendo o endereço adicional para evitar inconsistência
        if additional_address in addresses:
            addresses.remove(additional_address)

        # Lendo os endereços e chaves privadas do arquivo out.txt

        with open(out_file, "r") as file:
            pending_private_key = None  # Armazena a chave privada temporariamente
            private_keys = {}  # Dicionário para armazenar chave pública -> chave privada

            for line in file:
                if "Private Key:" in line:  # Primeiro, encontramos a chave privada
                    pending_private_key = line.split("Private Key:")[1].strip()
                elif "Address" in line and pending_private_key:  # Depois, encontramos a chave pública
                    current_address = line.split("Address")[1].strip()
                    private_keys[current_address] = pending_private_key  # Associamos a chave pública à chave privada
                    pending_private_key = None  # Resetamos a variável após o uso

                    # Verificando se a chave pertence ao endereço adicional
                    if current_address == additional_address:
                        input("CHAVE DA CARTEIRA ENCONTRADA !!!!!!!")
                        found_additional_address = True

        # Se a chave privada do endereço adicional foi encontrada
        if found_additional_address:
            print("Chave privada do endereço adicional encontrada! Parando o programa.")
            print(f"Chave encontrada: {private_keys.get(additional_address)}")
            return True

        # Verificando se a quantidade de chaves privadas corresponde à quantidade de endereços
        if len(private_keys) != len(addresses):
            print(f"Erro: Número de chaves privadas ({len(private_keys)}) não corresponde ao número de endereços ({len(addresses)}).")
            clear_file(out_file)
            return False

        # Ordenando as chaves privadas na mesma ordem dos endereços em in.txt
        ordered_private_keys = [private_keys[addr] for addr in addresses if addr in private_keys]

        # Enviar as chaves em lotes de 10
        for i in range(0, len(ordered_private_keys), 10): 
            batch = ordered_private_keys[i:i + 10]
            if len(batch) == 10:
                batch = [f"0x00000000000000000000000000000000000000000000000{key}" for key in batch]
                post_private_keys(batch)
            else:
                print(f"Lote com menos de 10 chaves ignorado: {batch}")

    except Exception as e:
        print(f"Erro ao processar os arquivos: {e}")

    # Limpar o arquivo out.txt
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
                
                # Extraindo start e end do range
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

        
        # Aguardar 2 segundos antes de reiniciar o loop
        time.sleep(5)

