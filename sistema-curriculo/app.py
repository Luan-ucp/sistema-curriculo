import streamlit as st
import time

# Imports dos seus controllers
from src.controllers.auth_controller import verificar_login
from src.controllers.user_controller import salvar_usuario

# Imports de Interface (O arquivo novo que criamos)
from src.utils.ui import configurar_pagina, rodape_personalizado

# 1. Configuração da Página (OBRIGATÓRIO ser a primeira coisa)
configurar_pagina("Bem-vindo", "👋")

# --- INICIALIZAÇÃO DA SESSÃO ---
if "logado" not in st.session_state:
    st.session_state["logado"] = False
if "usuario_nome" not in st.session_state:
    st.session_state["usuario_nome"] = None
if "perfil" not in st.session_state:
    st.session_state["perfil"] = None
if "razao_social" not in st.session_state:
    st.session_state["razao_social"] = None

# --- FUNÇÃO DA TELA DE LOGIN/CADASTRO ---
def tela_entrada():
    # Centralização: Cria 3 colunas, usaremos apenas a do meio (col2)
    # A proporção [1, 2, 1] faz a coluna do meio ser o dobro das laterais
    col1, col2, col3 = st.columns([1, 2, 1])
    
    with col2:
        st.title("💼 JobMatch")
        st.markdown("### Sistema de Vagas & Currículos")
        
        # Abas para alternar
        tab_login, tab_cadastro = st.tabs(["🔐 Login", "📝 Criar Conta"])
        
        # ==========================
        # ABA LOGIN
        # ==========================
        with tab_login:
            with st.form(key="login_form"):
                email = st.text_input("E-mail")
                senha = st.text_input("Senha", type="password")
                submit_login = st.form_submit_button("Entrar", type="primary", use_container_width=True)
                
                if submit_login:
                    if not email or not senha:
                         st.warning("Preencha todos os campos.")
                    else:
                        user_data = verificar_login(email, senha)
                        
                        if user_data:
                            # Salva na sessão
                            st.session_state["logado"] = True
                            st.session_state["usuario_nome"] = user_data["nome"]
                            st.session_state["email"] = user_data["email"]
                            st.session_state["perfil"] = user_data["perfil"]
                            
                            if "empregador" in user_data:
                                st.session_state["razao_social"] = user_data["empregador"]["razao_social"]
                            
                            st.success(f"Bem-vindo, {user_data['nome']}!")
                            time.sleep(1) # Pequena pausa para ver a mensagem
                            st.rerun() # Recarrega para o direcionador pegar
                        else:
                            st.error("E-mail ou senha incorretos.")

        # ==========================
        # ABA CADASTRO
        # ==========================
        with tab_cadastro:
            st.write("Preencha os dados para se registrar.")
            
            with st.form(key="cadastro_form"):
                nome = st.text_input("Nome Completo")
                email_cad = st.text_input("E-mail")
                senha_cad = st.text_input("Crie uma Senha", type="password")
                
                # Escolha do Perfil
                tipo_perfil = st.radio("Eu sou:", ["CANDIDATO", "EMPREGADOR"], horizontal=True)
                
                # Campo condicional (Visualmente)
                razao_social = ""
                if tipo_perfil == "EMPREGADOR":
                    st.info("Para empregadores, precisamos do nome da empresa.")
                    razao_social = st.text_input("Razão Social (Nome da Empresa)")
                
                submit_cad = st.form_submit_button("Cadastrar", use_container_width=True)
                
                if submit_cad:
                    # Pequena validação antes de chamar o controller
                    if not nome or not email_cad or not senha_cad:
                        st.warning("Preencha os campos obrigatórios!")
                    elif tipo_perfil == "EMPREGADOR" and not razao_social:
                         st.warning("Empregadores devem informar a Razão Social.")
                    else:
                        sucesso, mensagem = salvar_usuario(nome, email_cad, senha_cad, tipo_perfil, razao_social)
                        
                        if sucesso:
                            st.balloons()
                            st.success(mensagem)
                        else:
                            st.error(mensagem)

# --- DIRECIONADOR DE FLUXO ---
# Verifica se está logado para redirecionar ou mostrar login
if st.session_state["logado"]:
    if st.session_state["perfil"] == "EMPREGADOR":
        st.switch_page("pages/02_painel_empresa.py")
    elif st.session_state["perfil"] == "CANDIDATO":
        st.switch_page("pages/03_painel_candidato.py")
else:
    # Se não está logado, mostra a tela de entrada
    tela_entrada()

# Adiciona o rodapé no final de tudo
rodape_personalizado()