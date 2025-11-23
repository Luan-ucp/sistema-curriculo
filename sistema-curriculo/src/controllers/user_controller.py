# src/controllers/user_controller.py
from src.database import get_database
from src.utils.security import gerar_hash
from bson.objectid import ObjectId

def salvar_usuario(nome, email, senha, perfil, razao_social=None):
    """
    Salva um usuário seguindo a estrutura exata do JSON do MongoDB.
    """
    db = get_database()
    collection = db["usuario"]
    
    # Verifica duplicidade de email
    if collection.find_one({"email": email}):
        return False, "Email já cadastrado."
    
    # Estrutura base do documento
    novo_usuario = {
        "nome": nome,
        "email": email,
        "senha_hash": gerar_hash(senha), # Gera o hash aqui
        "perfil": perfil, # 'EMPREGADOR' ou 'CANDIDATO'
        "logins": [] # Começa com lista vazia
    }
    
    # Regra específica para Empregador
    if perfil == "EMPREGADOR":
        if not razao_social:
            return False, "Razão Social é obrigatória para empregadores."
            
        novo_usuario["empregador"] = {
            "razao_social": razao_social
        }
    
    # Salva no banco
    collection.insert_one(novo_usuario)
    return True, "Usuário cadastrado com sucesso!"

def buscar_candidatos_por_ids(lista_ids):
    """
    Recebe uma lista de IDs (strings ou ObjectIds) e retorna os dados dos usuários.
    """
    db = get_database()
    
    # Converte tudo para ObjectId caso esteja como string no banco
    lista_obj_ids = [ObjectId(id_user) for id_user in lista_ids]
    
    # O operador $in busca qualquer documento cujo _id esteja na lista
    usuarios = list(db["usuario"].find(
        {"_id": {"$in": lista_obj_ids}},
        {"senha_hash": 0, "logins": 0} # Projeção: Esconde senha e logs por segurança
    ))
    return usuarios