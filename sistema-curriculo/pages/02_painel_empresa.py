import streamlit as st
import pandas as pd # Opcional, ajuda a mostrar a tabela de candidatos bonita
from src.controllers.vaga_controller import (
    criar_vaga, 
    buscar_vagas_por_empresa, 
    atualizar_vaga, 
    excluir_vaga
)
from src.controllers.user_controller import buscar_candidatos_por_ids

# --- BLOQUEIO DE SEGURANÇA ---
if "logado" not in st.session_state or st.session_state["perfil"] != "EMPREGADOR":
    st.warning("Acesso restrito a Empresas.")
    st.stop()

st.title(f"Painel: {st.session_state['razao_social']}")

# Criação das Abas
aba1, aba2 = st.tabs(["➕ Cadastrar Nova Vaga", "📋 Gerenciar Minhas Vagas"])

# ==========================================
# ABA 1: CADASTRAR
# ==========================================
with aba1:
    with st.form("form_criar_vaga"):
        titulo = st.text_input("Título da Vaga")
        descricao = st.text_area("Descrição")
        col1, col2 = st.columns(2)
        cidade = col1.text_input("Cidade")
        estado = col2.selectbox("Estado", ["PE", "SP", "RJ", "MG"])
        salario = st.number_input("Salário", min_value=0.0, step=100.0)
        habs = st.text_input("Habilidades (separe por vírgula)") # Simplifiquei para text_input
        
        btn_criar = st.form_submit_button("Publicar")
        
        if btn_criar:
            # Monta o JSON igual ao seu exemplo
            dados = {
                "empregador": {"razao_social": st.session_state["razao_social"]},
                "localizacao": {"cidade": cidade, "estado": estado},
                "titulo": titulo,
                "descricao": descricao,
                "tipo_contrato": "CLT", # Padrão ou adicione campo
                "salario": salario,
                "habilidades": [h.strip() for h in habs.split(",") if h], # Transforma em lista
                "idiomas": ["Português"],
                "candidatos_inscritos": [] # Começa vazio
            }
            criar_vaga(dados)
            st.success("Vaga Criada!")
            st.rerun()

# ==========================================
# ABA 2: GERENCIAR (VER, EDITAR, DELETAR, CANDIDATOS)
# ==========================================
with aba2:
    st.write("Aqui estão suas vagas ativas.")
    
    # 1. Busca as vagas do banco
    minhas_vagas = buscar_vagas_por_empresa(st.session_state["razao_social"])
    
    if not minhas_vagas:
        st.info("Nenhuma vaga cadastrada.")
    
    for vaga in minhas_vagas:
        # Mostra um resumo no título do expander
        titulo_expander = f"📢 {vaga['titulo']} - {vaga['localizacao']['cidade']}/{vaga['localizacao']['estado']}"
        
        with st.expander(titulo_expander):
            # --- ÁREA DE CANDIDATOS ---
            st.write("#### 👥 Candidatos Inscritos")
            lista_ids = vaga.get("candidatos_inscritos", [])
            
            if not lista_ids:
                st.write("_Nenhum candidato inscrito ainda._")
            else:
                # Busca os dados reais dos usuários
                candidatos = buscar_candidatos_por_ids(lista_ids)
                
                # Mostra numa tabelinha simples
                dados_tabela = []
                for c in candidatos:
                    dados_tabela.append({
                        "Nome": c["nome"],
                        "Email": c["email"],
                        # "Link Currículo": "Ver PDF" (Ideia futura)
                    })
                st.dataframe(dados_tabela, use_container_width=True)

            st.divider()
            
            # --- ÁREA DE EDIÇÃO ---
            st.write("#### ✏️ Editar Vaga")
            # Dica: Usamos key=str(vaga['_id']) para o Streamlit saber que cada form é único
            with st.form(key=f"edit_{vaga['_id']}"):
                novo_titulo = st.text_input("Título", value=vaga['titulo'])
                nova_desc = st.text_area("Descrição", value=vaga['descricao'])
                novo_salario = st.number_input("Salário", value=float(vaga['salario']))
                
                col_save, col_del = st.columns([1, 1])
                btn_salvar = col_save.form_submit_button("💾 Salvar Alterações")
                
                if btn_salvar:
                    # Monta o objeto de atualização
                    update_data = {
                        "titulo": novo_titulo,
                        "descricao": nova_desc,
                        "salario": novo_salario
                    }
                    atualizar_vaga(vaga['_id'], update_data)
                    st.success("Atualizado!")
                    st.rerun()

            # --- BOTÃO DELETAR (Fora do form para evitar conflito) ---
            if st.button("🗑️ Excluir Vaga", key=f"del_{vaga['_id']}"):
                excluir_vaga(vaga['_id'])
                st.warning("Vaga excluída.")
                st.rerun()