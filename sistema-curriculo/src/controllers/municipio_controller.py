# src/controllers/municipio_controller.py
from src.database import get_database
import streamlit as st

@st.cache_data(ttl=3600) # Cache de 1 hora para não consultar o banco toda hora
def buscar_lista_estados():
    """
    Retorna a lista de UFs únicas presentes na collection municipio.
    """
    db = get_database()
    # Distinct pega apenas os valores únicos
    estados = db["municipio"].distinct("uf")
    estados.sort()
    return estados

def buscar_cidades_por_estado(uf):
    """
    Retorna apenas os nomes das cidades de um determinado estado.
    """
    db = get_database()
    # Busca cidades daquele UF e ordena por nome
    cidades = list(db["municipio"].find({"uf": uf}, {"nome": 1, "_id": 0}).sort("nome", 1))
    return [c["nome"] for c in cidades]

def buscar_dados_municipio(cidade, uf):
    """
    Busca os dados completos (latitude, longitude) de uma cidade específica.
    """
    db = get_database()
    return db["municipio"].find_one({
        "nome": cidade,
        "uf": uf
    })