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

# src/controllers/user_controller.py
from src.database import get_database
from src.utils.security import gerar_hash # Certifique-se que essa função existe no utils

def salvar_usuario(nome, email, senha, perfil, razao_social=None):
    db = get_database()
    collection = db["usuario"] # Usando singular conforme seu padrão
    
    # 1. Verifica se o e-mail já existe
    if collection.find_one({"email": email}):
        return False, "E-mail já cadastrado no sistema."
    
    # 2. Cria a estrutura base
    novo_usuario = {
        "nome": nome,
        "email": email,
        "senha_hash": gerar_hash(senha), # IMPORTANTE: Criptografar!
        "perfil": perfil,
        "logins": []
    }
    
    # 3. Adiciona campos específicos baseados no perfil
    if perfil == "EMPREGADOR":
        if not razao_social:
            return False, "Razão Social é obrigatória para empresas."
        
        novo_usuario["empregador"] = {
            "razao_social": razao_social
        }
        
    elif perfil == "CANDIDATO":
        # Inicializa a estrutura vazia para evitar erros no Portal do Candidato
        novo_usuario["candidato"] = {
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
        
    # 4. Salva no banco
    collection.insert_one(novo_usuario)
    return True, "Cadastro realizado com sucesso! Faça login agora."

# src/controllers/user_controller.py
from src.database import get_database
from bson.objectid import ObjectId

def buscar_candidatos_por_ids(lista_ids):
    """
    Recebe uma lista de IDs e retorna os dados completos dos candidatos.
    """
    db = get_database()
    
    # 1. Converte strings para ObjectId
    lista_obj_ids = []
    for item in lista_ids:
        if isinstance(item, str):
            lista_obj_ids.append(ObjectId(item))
        else:
            lista_obj_ids.append(item)
            
    usuarios = list(db["usuario"].find(
        {"_id": {"$in": lista_obj_ids}},
        {
            "nome": 1, 
            "email": 1, 
            "candidato": 1
        }
    ))
    return usuarios