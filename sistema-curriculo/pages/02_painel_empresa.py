import streamlit as st
import pandas as pd # Opcional, ajuda a mostrar a tabela de candidatos bonita
from src.controllers.habilidade_controller import buscar_habilidades
from src.controllers.vaga_controller import (
    criar_vaga, 
    buscar_vagas_por_empresa, 
    atualizar_vaga, 
    excluir_vaga
)
from src.controllers.user_controller import buscar_candidatos_por_ids
from src.utils.formatter import formatar_real

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

    opcoes_habilidades = buscar_habilidades()
    
    # Se a lista vier vazia (banco vazio), colocamos um fallback para não quebrar visualmente
    if not opcoes_habilidades:
        st.warning("Nenhuma habilidade cadastrada no banco de dados. Contate o administrador.")
        opcoes_habilidades = []

    with st.form("form_criar_vaga"):
        titulo = st.text_input("Título da Vaga")
        descricao = st.text_area("Descrição")
        col1, col2 = st.columns(2)
        tipo_contrato = st.selectbox("Tipo de Contrato", ["CLT", "PJ", "Estágio", "Outro"])
        cidade = col1.text_input("Cidade")
        estado = col2.selectbox("Estado", ["AC", "AL", "AP", "AM", "BA", "CE", "DF", "ES", "GO", "MA", "MT", "MS", "MG", 
                                            "PA", "PB", "PR", "PE", "PI", "RJ", "RN", "RS", "RO", "RR", "SC", "SP", "SE", "TO"])
        salario = st.number_input(
            "Salário (Use ponto para centavos)", 
            min_value=0.0, 
            step=100.0, 
            format="%.2f"
        )
        st.caption(f"Valor formatado: **{formatar_real(salario)}**")
        habs = st.multiselect(
            "Habilidades Requeridas", 
            options=opcoes_habilidades,
            placeholder="Selecione uma ou mais habilidades..."
        )
        
        btn_criar = st.form_submit_button("Publicar")
        
        if btn_criar:
            # Monta o JSON igual ao seu exemplo
            dados = {
                "empregador": {"razao_social": st.session_state["razao_social"]},
                "localizacao": {"cidade": cidade, "estado": estado},
                "titulo": titulo,
                "descricao": descricao,
                "tipo_contrato": tipo_contrato, # Padrão ou adicione campo
                "salario": salario,
                "habilidades": habs,
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

    opcoes_habilidades = buscar_habilidades()
    
    # Se a lista vier vazia (banco vazio), colocamos um fallback para não quebrar visualmente
    if not opcoes_habilidades:
        st.warning("Nenhuma habilidade cadastrada no banco de dados. Contate o administrador.")
        opcoes_habilidades = []
    
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
            
            with st.form(key=f"edit_{vaga['_id']}"):
                novo_titulo = st.text_input("Título", value=vaga['titulo'])
                nova_desc = st.text_area("Descrição", value=vaga['descricao'])
                
                # --- CORREÇÃO DO SELECTBOX ---
                lista_contratos = ["CLT", "PJ", "Estágio", "Outro"]
                
                # Descobre qual o índice (posição) do valor salvo no banco
                try:
                    index_atual = lista_contratos.index(vaga.get('tipo_contrato', "CLT"))
                except ValueError:
                    index_atual = 0 # Se der erro, marca o primeiro como padrão
                
                tipo_contrato = st.selectbox(
                    "Tipo de Contrato", 
                    options=lista_contratos, 
                    index=index_atual # Usa index, não value!
                )

                # --- MÁSCARA NO INPUT ---
                novo_salario = st.number_input(
                    "Salário (use ponto para centavos)", 
                    value=float(vaga['salario']),
                    min_value=0.0, 
                    step=100.0,   
                    format="%.2f"
                )
                # Mostra o valor formatado bonitinho abaixo
                st.caption(f"Valor formatado: **{formatar_real(novo_salario)}**")
                
                # --- CORREÇÃO DO MULTISELECT ---
                # O parâmetro correto aqui é 'default', não 'value'
                habs = st.multiselect(
                     "Habilidades Requeridas",
                     options=opcoes_habilidades, # Lista completa do banco (que vem do controller)
                     default=vaga['habilidades'], # Itens que já vêm marcados
                     placeholder="Selecione uma ou mais habilidades..."
                 )
                
                col_save, col_del = st.columns([1, 1])
                btn_salvar = col_save.form_submit_button("💾 Salvar Alterações")
                
                if btn_salvar:
                    update_data = {
                        "titulo": novo_titulo,
                        "descricao": nova_desc,
                        "salario": novo_salario,
                        "tipo_contrato": tipo_contrato,
                        "habilidades": habs,
                    }
                    atualizar_vaga(vaga['_id'], update_data)
                    st.success("Atualizado!")
                    st.rerun()