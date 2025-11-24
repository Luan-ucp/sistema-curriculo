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

with st.sidebar:
    st.write(f"Logado como: **{st.session_state.get('usuario_nome', 'Usuário')}**")
    
    if st.button("🚪 Sair do Sistema"):
        st.session_state.clear() # Limpa a sessão
        st.switch_page("app.py") # Volta para a tela de login

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
# ... (dentro do with st.expander(titulo_expander): da vaga) ...

            st.divider()
            st.write("#### 👥 Candidatos Inscritos")
            
            lista_ids = vaga.get("candidatos_inscritos", [])
            
            if not lista_ids:
                st.info("Nenhum candidato se inscreveu nesta vaga ainda.")
            else:
                # Busca os dados completos (incluindo currículo)
                candidatos = buscar_candidatos_por_ids(lista_ids)
                
                # Prepara os sets da VAGA para calcular o Match
                skills_vaga = set(vaga.get("habilidades", []))

                for cand in candidatos:
                    # Pega os dados do objeto 'candidato' (pode estar vazio se ele nunca editou)
                    info_cand = cand.get("candidato", {})
                    curr_cand = info_cand.get("curriculo", {})
                    
                    # --- CÁLCULO DO MATCH ---
                    skills_cand = set(curr_cand.get("habilidades", []))
                    match_items = skills_vaga.intersection(skills_cand)
                    match_percent = 0
                    if skills_vaga:
                        match_percent = int((len(match_items) / len(skills_vaga)) * 100)
                    
                    # Define cor/icone do match
                    icon_match = "🔴"
                    if match_percent >= 50: icon_match = "🟡" 
                    if match_percent >= 80: icon_match = "🟢"

                    # --- VISUAL DO CANDIDATO ---
                    # Cria um expander para cada pessoa
                    with st.expander(f"{icon_match} {match_percent}% Match | {cand['nome']}"):
                        
                        col_a, col_b = st.columns([1, 1])
                        
                        with col_a:
                            st.markdown(f"**📧 Email:** {cand['email']}")
                            
                            # Mostra quais habilidades bateram
                            if match_items:
                                st.success(f"**Match:** {', '.join(match_items)}")
                            
                            # Mostra as que faltam (opcional, mas útil para o RH)
                            missing = skills_vaga - skills_cand
                            if missing:
                                st.error(f"**Faltam:** {', '.join(missing)}")
                        
                        with col_b:
                            idiomas = curr_cand.get("idiomas", [])
                            st.markdown(f"**🗣️ Idiomas:** {', '.join(idiomas) if idiomas else 'Não informado'}")
                            
                            # Links de contato (Linkedin, etc)
                            contatos = info_cand.get("contatos", [])
                            if contatos:
                                st.markdown("**🔗 Contatos:**")
                                for c in contatos:
                                    st.write(f"- {c.get('tipo')}: {c.get('valor')}")

                        st.markdown("---")
                        st.markdown("**📝 Resumo Profissional:**")
                        st.write(info_cand.get("resumo", "Sem resumo cadastrado."))
                        
                        st.markdown("**🎓 Formação / Experiência:**")
                        st.write(info_cand.get("experiencia", "Não informado."))
            
            # if not lista_ids:
            #     st.write("_Nenhum candidato inscrito ainda._")
            # else:
            #     # Busca os dados reais dos usuários
            #     candidatos = buscar_candidatos_por_ids(lista_ids)
                
            #     # Mostra numa tabelinha simples
            #     dados_tabela = []
            #     for c in candidatos:
            #         dados_tabela.append({
            #             "Nome": c["nome"],
            #             "Email": c["email"],
            #             # "Link Currículo": "Ver PDF" (Ideia futura)
            #         })
            #     st.dataframe(dados_tabela, use_container_width=True)

            # st.divider()
            
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

            
        # --- FORA DO FORMULÁRIO ---
        st.divider() # Cria uma linha divisória visual
        
        # Colunas para organizar o botão à esquerda
        col_trash, col_aviso = st.columns([1, 3])
        
        # Criamos uma chave única para o estado de confirmação dessa vaga específica
        chave_confirmar = f"confirmar_exclusao_{vaga['_id']}"
        
        if chave_confirmar not in st.session_state:
            st.session_state[chave_confirmar] = False

        # Botão inicial de Excluir
        if col_trash.button("🗑️ Excluir", key=f"btn_trash_{vaga['_id']}", type="primary"):
            st.session_state[chave_confirmar] = True # Ativa o alerta

        # Se ativou o alerta, mostra a confirmação
        if st.session_state[chave_confirmar]:
            st.warning("⚠️ Tem certeza? Essa ação excluirá a vaga e removerá todos os candidatos associados.")
            
            col_sim, col_nao = st.columns(2)
            
            if col_sim.button("✅ Sim, excluir", key=f"sim_{vaga['_id']}"):
                # Chama a função do controller que já existe
                excluir_vaga(vaga['_id'])
                
                st.toast("Vaga excluída com sucesso!", icon="🗑️")
                
                # Limpa o estado e recarrega a página
                del st.session_state[chave_confirmar]
                import time
                time.sleep(1)
                st.rerun()
            
            if col_nao.button("❌ Cancelar", key=f"nao_{vaga['_id']}"):
                st.session_state[chave_confirmar] = False
                st.rerun()