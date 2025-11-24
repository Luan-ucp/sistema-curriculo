from src.database import get_database
from bson.objectid import ObjectId 

def buscar_habilidades():
    """
    Retorna a lista de habilidades disponíveis no banco de dados.
    """
    db = get_database()
    habilidades = list(db["habilidade"].find({}, {"_id": 0, "habilidade": 1}))  # Projeção para retornar apenas o nome
    return [hab["habilidade"] for hab in habilidades]