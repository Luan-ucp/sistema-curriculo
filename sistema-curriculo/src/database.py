import streamlit as st
from pymongo import MongoClient
import certifi # Opcional: Ajuda se der erro de SSL/Certificado


@st.cache_resource
def get_database():
    
    # Verifica se as secrets existem antes de tentar conectar
    if "mongo" not in st.secrets:
        st.error("Erro: Secrets do MongoDB não encontrados no arquivo .streamlit/secrets.toml")
        return None

    try:
        # Pega os dados do arquivo secrets.toml
        uri = st.secrets["mongo"]["uri"]
        db_name = st.secrets["mongo"]["db_name"]
        
        # Cria a conexão
        # tlsCAFile=certifi.where() é útil se você usar Windows e der erro de certificado
        client = MongoClient(uri, tlsCAFile=certifi.where())
        
        # Verifica se a conexão está ativa (ping)
        client.admin.command('ping')
        
        # Retorna o objeto do banco de dados específico
        return client[db_name]

    except Exception as e:
        st.error(f"Erro ao conectar ao MongoDB: {e}")
        return None