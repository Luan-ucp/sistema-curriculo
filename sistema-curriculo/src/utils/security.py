import hashlib

def gerar_hash(senha_string):
    """
    Recebe uma senha normal (ex: '123456') e retorna o hash SHA-256 dela.
    """
    # 1. O hashlib precisa receber bytes, então usamos .encode()
    senha_bytes = senha_string.encode('utf-8')
    
    # 2. Geramos o hash SHA-256 (padrão de mercado seguro e comum)
    hash_objeto = hashlib.sha256(senha_bytes)
    
    # 3. Transformamos de volta em string hexadecimal (aquela sopa de letras)
    return hash_objeto.hexdigest()