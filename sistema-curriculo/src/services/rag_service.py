import streamlit as streamlit
from google import genai
from ..controllers.vector_search_controller import buscar_vetorial
from google.genai import types
from pymongo import MongoClient

# ==============================
# CONFIGURAÇÕES
# ==============================
api_key = streamlit.secrets["GOOGLE_API_KEY"]
mongo_url = streamlit.secrets["MONGO_URI"]
db_name = streamlit.secrets["MONGO_DB_NAME"]
collec = streamlit.secrets["MONGO_COLLECTION_NAME"]

client_gemini = genai.Client(api_key=api_key)

mongo_client = MongoClient(mongo_url)
db = mongo_client[db_name]
col = db[collec]

# ==============================
# PROMPT ENGINEER (CORAÇÃO DO RAG)
# ==============================

def gerar_prompt_rag(pergunta: str, documentos: list[dict]) -> str:

    contexto = ""
    for i, doc in enumerate(documentos):
        vaga = doc.get("vaga", {})
        titulo = vaga.get("titulo", "N/A")
        empresa = vaga.get("empresa", "N/A")
        descricao = vaga.get("descricao", "N/A")
        cidade = vaga.get("cidade", "N/A")
        estado = vaga.get("estado", "N/A")
        tipo_contratacao = vaga.get("tipo_contratacao", "N/A")
        salario = vaga.get("salario", "N/A")


        contexto += f"Documento {i+1}:\n"
        contexto += f"Título da Vaga: {titulo}\n"
        contexto += f"Empresa: {empresa}\n"
        contexto += f"Descrição: {descricao}\n"
        contexto += f"Cidade: {cidade}\n"
        contexto += f"Estado: {estado}\n"
        contexto += f"Tipo de Contratação: {tipo_contratacao}\n"
        contexto += f"Salário: {salario}\n"
        contexto += "\n---\n\n"

    prompt = f"""
    Você é uma IA especialista em empregos, recrutamento e análise de currículos.

    Você deve responder APENAS com base no contexto abaixo.
    No contexto, há informações extraídas de vagas e descrições de vagas de emprego.

    De todas as informações fornecidas no contexto, responda à pergunta do usuário da melhor forma possível.

    De a resposta em Markdown, utilizando listas, negrito e outros recursos para melhorar a legibilidade.

    ====================
    CONTEXTO:
    {contexto}
    ====================

    Pergunta do usuário:
    {pergunta}

    Regras:
    - Seja amigavel e profissional
    - Responda apenas com base no contexto fornecido
    - Não invente informações
    - Se não souber, informe educadamente
    - Use linguagem profissional e amigavel sempre utilizando "você" para se referir ao usuário
    - Utilize emojis relacionados a empregos e trabalho (💼, 📄, 🔍, 🤝, 📝, etc.) para tornar a resposta mais leve
    - Não cite documentos
    - Não explique que usou RAG

    Resposta:
    """

    return prompt.strip()


# ==============================
# IA GEMINI
# ==============================

def chamar_gemini(prompt: str) -> str:
    response = client_gemini.models.generate_content(
        model="models/gemini-2.0-flash",
        contents=prompt,
        config=types.GenerateContentConfig(
            temperature=0.3,
            max_output_tokens=600
        )
    )

    try:
        return response.text
    except Exception:
        return "Erro ao gerar resposta com IA."


# ==============================
# FUNÇÃO FINAL DE RAG
# ==============================

def consultar_rag(pergunta: str) -> dict:
    documentos = buscar_vetorial(pergunta)

    prompt = gerar_prompt_rag(pergunta, documentos)

    resposta = chamar_gemini(prompt)

    return resposta;
