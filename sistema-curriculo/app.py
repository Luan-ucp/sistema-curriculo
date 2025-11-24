import streamlit as st
from src.controllers.auth_controller import verificar_login
from src.controllers.user_controller import salvar_usuario # Importa a função nova

st.set_page_config(page_title="Sistema de Currículos", page_icon="💼")

# --- INICIALIZAÇÃO DA SESSÃO ---
if "logado" not in st.session_state:
    st.session_state["logado"] = False
if "usuario_nome" not in st.session_state:
    st.session_state["usuario_nome"] = None
if "perfil" not in st.session_state:
    st.session_state["perfil"] = None
if "razao_social" not in st.session_state:
    st.session_state["razao_social"] = None

# --- FUNÇÃO DE LOGIN E CADASTRO ---
def tela_entrada():
    st.title("💼 Sistema de Vagas & Currículos")
    
    # Abas para alternar
    tab_login, tab_cadastro = st.tabs(["🔐 Login", "📝 Criar Conta"])
    
    # ==========================
    # ABA LOGIN
    # ==========================
    with tab_login:
        with st.form(key="login_form"):
            email = st.text_input("E-mail")
            senha = st.text_input("Senha", type="password")
            submit_login = st.form_submit_button("Entrar", use_container_width=True)
            
            if submit_login:
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
            
            # Campo condicional: Só aparece visualmente, mas precisamos tratar no controller
            razao_social = ""
            if tipo_perfil == "EMPREGADOR":
                st.info("Para empregadores, precisamos do nome da empresa.")
                razao_social = st.text_input("Razão Social (Nome da Empresa)")
            
            submit_cad = st.form_submit_button("Cadastrar", use_container_width=True)
            
            if submit_cad:
                # Validação básica
                if not nome or not email_cad or not senha_cad:
                    st.warning("Preencha todos os campos obrigatórios!")
                else:
                    sucesso, mensagem = salvar_usuario(nome, email_cad, senha_cad, tipo_perfil, razao_social)
                    
                    if sucesso:
                        st.success(mensagem)
                        st.balloons() # Um efeito visual legal
                    else:
                        st.error(mensagem)

# --- TELA PRINCIPAL (DASHBOARD) ---
def tela_principal():
    st.sidebar.title(f"Olá, {st.session_state['usuario_nome']}")
    
    if st.sidebar.button("Sair"):
        st.session_state.clear()
        st.rerun()

    # Redirecionamento visual e dicas
    if st.session_state["perfil"] == "EMPREGADOR":
        st.sidebar.success("Perfil: EMPRESA")
        st.title("Painel da Empresa")
        st.info("👈 Utilize o menu lateral para **Gerenciar Vagas**.")
        st.write(f"Empresa logada: **{st.session_state.get('razao_social')}**")
        
    elif st.session_state["perfil"] == "CANDIDATO":
        st.sidebar.info("Perfil: CANDIDATO")
        st.title("Painel do Candidato")
        st.info("👈 Utilize o menu lateral para **Editar Currículo** ou **Buscar Vagas**.")

# --- CONTROLE DE FLUXO ---
if not st.session_state["logado"]:
    tela_entrada()
else:
    tela_principal()