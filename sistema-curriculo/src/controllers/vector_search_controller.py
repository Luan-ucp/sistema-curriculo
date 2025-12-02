from google import genai
from google.genai import types
from pymongo import MongoClient
import streamlit as streamlit

api_key = streamlit.secrets["GOOGLE_API_KEY"]
mongo_url = streamlit.secrets["MONGO_URI"]
db_name = streamlit.secrets["MONGO_DB_NAME"]
collec = streamlit.secrets["MONGO_COLLECTION_NAME"]

client_gemini = genai.Client(api_key=api_key)

mongo_client = MongoClient(mongo_url)
db = mongo_client[db_name]
col = db[collec]


def gerarEmbeddings(lista_textos):
    emb = client_gemini.models.embed_content(
        model="gemini-embedding-001",
        contents=lista_textos,
        config=types.EmbedContentConfig(output_dimensionality=512)
    )
    return emb.embeddings


def buscar_vetorial(query_texto: str):
    # gerar embedding da consulta
    embedding_result = gerarEmbeddings([query_texto])

    # compatibilidade: pode vir com .values ou como lista
    vec = embedding_result[0]
    query_vector = vec.values if hasattr(vec, "values") else vec

    # pipeline de busca vetorial
    pipeline = [
        {
            "$vectorSearch": {
                "index": "default",
                "path": "embedding",
                "queryVector": query_vector,
                "numCandidates": 100,
                "limit": 3
            }
        },
        {
            "$project": {
                "score": { "$meta": "vectorSearchScore" },
                "vaga": "$$ROOT"
            }
        }
    ]

    resultados = list(col.aggregate(pipeline))
    
    resultados = limpar_embeddings(resultados)

    return resultados


def limpar_embeddings(resultados):
    for item in resultados:
        if "vaga" in item and "embedding" in item["vaga"]:
            del item["vaga"]["embedding"]
    return resultados