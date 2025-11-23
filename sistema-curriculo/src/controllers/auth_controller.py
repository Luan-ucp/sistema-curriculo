# src/controllers/auth_controller.py
from datetime import datetime
from src.database import get_database
from src.utils.security import gerar_hash

def verificar_login(email, senha_digitada):
    db = get_database()
    collection = db["usuario"] # Atenção: nome da collection no singular conforme seu exemplo
    
    # 1. Busca pelo email
    user_data = collection.find_one({"email": email})
    
    if user_data:
       
        if user_data["senha_hash"] == gerar_hash(senha_digitada):
            
            # --- NOVIDADE: Atualiza o histórico de logins ---
            novo_registro_login = {
                "data_hora": datetime.now().isoformat(), # Salva data atual
                "ip": "127.0.0.1", # Em localhost é difícil pegar o IP real, usamos padrão
                "sucesso": True
            }
            
            # Comando $push do Mongo adiciona um item na lista 'logins'
            collection.update_one(
                {"_id": user_data["_id"]},
                {"$push": {"logins": novo_registro_login}}
            )
            
            return user_data
            
    return None