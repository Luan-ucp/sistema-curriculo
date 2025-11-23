import streamlit as st
from src.controllers.auth_controller import verificar_login

st.set_page_config(page_title="Sistema de Currículos")

# --- 1. PADRONIZAÇÃO DA SESSÃO ---
# Usando os mesmos nomes que salvamos no login
if "logado" not in st.session_state:
    st.session_state["logado"] = False
if "usuario_nome" not in st.session_state: # Ajustado
    st.session_state["usuario_nome"] = None
if "perfil" not in st.session_state:       # Ajustado
    st.session_state["perfil"] = None
if "razao_social" not in st.session_state: # Importante inicializar
    st.session_state["razao_social"] = None

def tela_login():
    st.title("🔐 Login")
    
    with st.form(key="login_form"):
        email = st.text_input("E-mail")
        senha = st.text_input("Senha", type="password")
        submit = st.form_submit_button("Entrar")
        
        if submit:
            user_data = verificar_login(email, senha)
            
            if user_data:
                st.session_state["logado"] = True
                st.session_state["usuario_nome"] = user_data["nome"]
                st.session_state["email"] = user_data["email"]
                st.session_state["perfil"] = user_data["perfil"]
                
                if "empregador" in user_data:
                    st.session_state["razao_social"] = user_data["empregador"]["razao_social"]
                
                st.rerun()
            else:
                st.error("E-mail ou senha incorretos.")

def tela_principal():
    # Menu lateral com Logout
    st.sidebar.write(f"Olá, **{st.session_state['usuario_nome']}**")
    
    # --- 2. BOTÃO DE LOGOUT ---
    if st.sidebar.button("Sair"):
        st.session_state.clear() # Limpa toda a memória da sessão
        st.rerun()               # Recarrega a página (vai voltar pro login)

    # Conteúdo principal
    if st.session_state["perfil"] == "EMPREGADOR":
        st.sidebar.success("Perfil: EMPRESA")
        st.write("### Painel da Empresa")
        st.info("Utilize o menu lateral para cadastrar novas vagas.")
        st.write(f"Empresa Logada: **{st.session_state.get('razao_social', 'N/A')}**")
        
    elif st.session_state["perfil"] == "CANDIDATO":
        st.sidebar.info("Perfil: CANDIDATO")
        st.write("### Painel do Candidato")
        st.write("Busque vagas no menu lateral.")

# Controle de Fluxo
if not st.session_state["logado"]:
    tela_login()
else:
    tela_principal()