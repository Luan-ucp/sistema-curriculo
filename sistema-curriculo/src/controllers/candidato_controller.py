from src.database import get_database
from bson.objectid import ObjectId

def buscar_perfil_candidato(email):
    db = get_database()
    return db["usuario"].find_one({"email": email})

def atualizar_curriculo(email, dados_candidato):
    """
    Recebe o dicionário completo do objeto 'candidato' e salva no banco.
    """
    db = get_database()
    
    # Atualiza apenas o campo 'candidato' dentro do documento do usuário
    db["usuario"].update_one(
        {"email": email},
        {"$set": {"candidato": dados_candidato}}
    )
    return True

# --- AQUI ESTAVA FALTANDO A NOVA FUNÇÃO ---
def excluir_curriculo_completo(email):
    """
    1. Remove o ID do candidato de TODAS as vagas (candidatos_inscritos).
    2. Limpa os dados do currículo do usuário.
    """
    db = get_database()
    
    # 1. Pega o ID do usuário para saber quem remover das vagas
    usuario = db["usuario"].find_one({"email": email})
    if not usuario:
        return False
    
    usuario_id = usuario["_id"]
    
    # 2. VAI NAS VAGAS: Remove este ID da lista de inscritos em TODAS as vagas
    # O comando $pull remove um item específico de uma lista (array)
    db["vaga"].update_many(
        {}, # Filtro vazio = aplica em todas as vagas do banco
        {"$pull": {"candidatos_inscritos": usuario_id}}
    )
    
    # 3. VAI NO USUÁRIO: Reseta o currículo para vazio
    candidato_zerado = {
        "experiencia": "Não informado",
        "formacao": "Não informado",
        "resumo": "",
        "contatos": [],
        "curriculo": {
            "formacoes": [],
            "experiencias": [],
            "habilidades": [],
            "idiomas": []
        }
    }
    
    db["usuario"].update_one(
        {"email": email},
        {"$set": {"candidato": candidato_zerado}}
    )
    
    return True