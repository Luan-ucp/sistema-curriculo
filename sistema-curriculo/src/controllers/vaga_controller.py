# src/controllers/vaga_controller.py
from src.database import get_database
from bson.objectid import ObjectId # Necessário para lidar com _id do Mongo

# --- CREATE ---
def criar_vaga(dados_vaga):
    db = get_database()
    # Garante que começa com lista vazia se não tiver
    dados_vaga["candidatos_inscritos"] = [] 
    db["vaga"].insert_one(dados_vaga)
    return True

# --- READ (Buscar Vagas da Empresa) ---
def buscar_vagas_por_empresa(razao_social):
    db = get_database()
    # Busca apenas as vagas onde 'empregador.razao_social' é igual ao logado
    filtro = {"empregador.razao_social": razao_social}
    return list(db["vaga"].find(filtro))

# --- UPDATE (Editar) ---
def atualizar_vaga(id_vaga, novos_dados):
    db = get_database()
    # O MongoDB precisa receber o ID transformado em ObjectId
    filtro = {"_id": ObjectId(id_vaga)}
    
    # $set atualiza apenas os campos passados, mantendo o resto (como candidatos_inscritos)
    operacao = {"$set": novos_dados}
    
    db["vaga"].update_one(filtro, operacao)
    return True

# --- DELETE (Excluir) ---
def excluir_vaga(id_vaga):
    db = get_database()
    db["vaga"].delete_one({"_id": ObjectId(id_vaga)})
    return True

# --- LISTAGEM GERAL ---
def listar_todas_vagas():
    db = get_database()
    # Retorna todas as vagas, pode adicionar filtros aqui depois
    return list(db["vaga"].find())

# --- INSCRIÇÃO ---
def candidatar_vaga(id_vaga, id_candidato):
    db = get_database()
    
    # 1. Verifica se já não está inscrito para evitar duplicidade
    vaga = db["vaga"].find_one({
        "_id": ObjectId(id_vaga), 
        "candidatos_inscritos": ObjectId(id_candidato)
    })
    
    if vaga:
        return False, "Você já se candidatou para esta vaga!"
    
    # 2. Adiciona o ID do candidato na lista
    db["vaga"].update_one(
        {"_id": ObjectId(id_vaga)},
        {"$push": {"candidatos_inscritos": ObjectId(id_candidato)}}
    )
    return True, "Candidatura realizada com sucesso!"