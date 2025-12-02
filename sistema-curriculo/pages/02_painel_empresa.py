import streamlit as st
import pandas as pd # Opcional, ajuda a mostrar a tabela de candidatos bonita
from src.controllers.habilidade_controller import buscar_habilidades
from src.controllers.vaga_controller import (
    criar_vaga, 
    buscar_vagas_por_empresa, 
    atualizar_vaga, 
    excluir_vaga,
    buscar_dados_mapa
)
from src.controllers.user_controller import buscar_candidatos_por_ids
from src.utils.formatter import formatar_real
from src.utils.ui import configurar_pagina, rodape_personalizado
from src.controllers.municipio_controller import buscar_lista_estados, buscar_cidades_por_estado, buscar_dados_municipio
from src.utils.formatter import formatar_real
from src.utils.ui import configurar_pagina, rodape_personalizado

configurar_pagina("Painel da Empresa", "🏢")

with st.sidebar:
    st.image("https://cdn-icons-png.flaticon.com/512/2922/2922510.png", width=50) # Opcional: Logo
    st.write(f"Olá, **{st.session_state.get('usuario_nome', 'Visitante')}**")
    st.caption(f"Empresa: {st.session_state.get('razao_social', '')}")
    st.divider()
    
    if st.button("🚪 Sair do Sistema", use_container_width=True): # Botão full width fica mais bonito
        st.session_state.clear()
        st.switch_page("app.py")

# --- BLOQUEIO DE SEGURANÇA (Mantenha seu código original) ---
    if "logado" not in st.session_state or st.session_state["perfil"] == "CANDIDATO":
        st.warning("Acesso restrito a Empresas.")
        st.stop()

st.title(f"Painel Corporativo")
st.markdown("Gerencie suas vagas e visualize candidatos qualificados.")
st.divider()

st.title(f"Painel: {st.session_state['razao_social']}")

# Criação das Abas
aba1, aba2 = st.tabs(["➕ Cadastrar Nova Vaga", "📋 Gerenciar Minhas Vagas"])

# ==========================================
# ABA 1: CADASTRAR
# ==========================================
with aba1:
    opcoes_habilidades = buscar_habilidades()
    if not opcoes_habilidades:
        opcoes_habilidades = []

    # --- Lógica de Estados e Cidades ---
    lista_estados = buscar_lista_estados()
    
    # Criamos um container para o formulário
    with st.container(border=True):
        st.subheader("Nova Vaga")
      
        titulo = st.text_input("Título da Vaga")
        descricao = st.text_area("Descrição da Vaga")
        
        col_uf, col_cidade = st.columns(2)
        
        # 1. Seleção de Estado
        estado_selecionado = col_uf.selectbox("Estado (UF)", options=lista_estados, index=None, placeholder="Selecione o Estado")
        
        # 2. Seleção de Cidade (Depende do Estado)
        opcoes_cidades = []
        if estado_selecionado:
            opcoes_cidades = buscar_cidades_por_estado(estado_selecionado)
            
        cidade_selecionada = col_cidade.selectbox("Cidade", options=opcoes_cidades, placeholder="Selecione a Cidade", disabled=not estado_selecionado)

        col_contrato, col_salario = st.columns(2)
        tipo_contrato = col_contrato.selectbox("Tipo de Contrato", ["CLT", "PJ", "Estágio", "Outro"])
        
        salario = col_salario.number_input(
            "Salário (Use ponto para centavos)", 
            min_value=0.0, step=100.0, format="%.2f"
        )
        st.caption(f"Valor: {formatar_real(salario)}")

        habs = st.multiselect(
            "Habilidades Requeridas", 
            options=opcoes_habilidades,
            placeholder="Selecione..."
        )
        
        st.write("")
        if st.button("🚀 Publicar Vaga", type="primary", use_container_width=True):
            # Validações
            if not titulo or not descricao or not estado_selecionado or not cidade_selecionada:
                st.warning("Preencha todos os campos obrigatórios (Título, Descrição e Localização).")
            else:
                # 3. Busca Latitude e Longitude no banco de Municípios
                dados_geo = buscar_dados_municipio(cidade_selecionada, estado_selecionado)
                
                if not dados_geo:
                    st.error("Erro ao buscar coordenadas da cidade. Tente outra.")
                else:
                    # Monta o JSON completo com a nova estrutura
                    dados = {
                        "empregador": {"razao_social": st.session_state["razao_social"]},
                        "localizacao": {
                            "cidade": cidade_selecionada, 
                            "estado": estado_selecionado
                        },
                        # Aqui salvamos o objeto cidade completo para o mapa funcionar
                        "cidade": {
                            "nome": cidade_selecionada,
                            "uf": estado_selecionado,
                            "latitude": dados_geo.get("latitude"),
                            "longitude": dados_geo.get("longitude")
                        },
                        "titulo": titulo,
                        "descricao": descricao,
                        "tipo_contrato": tipo_contrato,
                        "salario": salario,
                        "habilidades": habs,
                        "idiomas": ["Português"],
                        "candidatos_inscritos": []
                    }
                    
                    criar_vaga(dados)
                    st.success("Vaga publicada com sucesso!")
                    import time
                    time.sleep(1.5)
                    st.rerun()

# ==========================================
# ABA 2: GERENCIAR (VER, EDITAR, DELETAR, CANDIDATOS)
# ==========================================
# ==========================================
# ABA 2: GERENCIAR (CORRIGIDO E COMPLETADO)
# ==========================================
with aba2:
    st.write("Aqui estão suas vagas ativas.")
    
    # --- 1. MAPA DE VAGAS DA EMPRESA ---
    st.info("🗺️ Distribuição das suas vagas:")
    dados_mapa = buscar_dados_mapa(st.session_state["razao_social"])
    
    if dados_mapa:
        # Prepara dados para o st.map (precisa de colunas 'lat' e 'lon')
        df_mapa = pd.DataFrame([{
            "lat": d["cidade"]["latitude"],
            "lon": d["cidade"]["longitude"]
        } for d in dados_mapa])
        
        st.map(df_mapa, size=20, color="#FF4B4B") # Vermelho
    else:
        st.caption("Cadastre vagas com localização para ver o mapa.")
    st.divider()

    # --- 2. PREPARAÇÃO DE DADOS AUXILIARES ---
    opcoes_habilidades = buscar_habilidades()
    if not opcoes_habilidades:
        opcoes_habilidades = []
        
    lista_estados = buscar_lista_estados() # Busca UFs para os selects

    # --- 3. LISTAGEM DE VAGAS ---
    minhas_vagas = buscar_vagas_por_empresa(st.session_state["razao_social"])
    
    if not minhas_vagas:
        st.info("Nenhuma vaga cadastrada.")
    
    for vaga in minhas_vagas:
        # Tenta pegar cidade/uf antiga ou nova estrutura
        cidade_atual = vaga.get('localizacao', {}).get('cidade', 'N/A')
        uf_atual = vaga.get('localizacao', {}).get('estado', 'N/A')

        titulo_expander = f"📢 {vaga['titulo']} - {cidade_atual}/{uf_atual}"
        
        with st.expander(titulo_expander):
            
            # ---------------------------
            # A) ÁREA DE CANDIDATOS
            # ---------------------------
            st.write("#### 👥 Candidatos Inscritos")
            lista_ids = vaga.get("candidatos_inscritos", [])
            
            if not lista_ids:
                st.info("Nenhum candidato se inscreveu nesta vaga ainda.")
            else:
                candidatos = buscar_candidatos_por_ids(lista_ids)
                skills_vaga = set(vaga.get("habilidades", []))

                for cand in candidatos:
                    info_cand = cand.get("candidato", {})
                    curr_cand = info_cand.get("curriculo", {})
                    skills_cand = set(curr_cand.get("habilidades", []))
                    
                    # Match
                    match_percent = 0
                    if skills_vaga:
                        match_items = skills_vaga.intersection(skills_cand)
                        match_percent = int((len(match_items) / len(skills_vaga)) * 100)
                    
                    icon_match = "🟢" if match_percent >= 80 else "🟡" if match_percent >= 50 else "🔴"

                    with st.popover(f"{icon_match} {match_percent}% | {cand['nome']}"):
                        st.write(f"**Email:** {cand['email']}")
                        st.write(f"**Resumo:** {info_cand.get('resumo', '')}")
                        st.write(f"**Habilidades:** {', '.join(skills_cand)}")
                        idiomas = curr_cand.get("idiomas", [])
                        if idiomas: st.write(f"**Idiomas:** {', '.join(idiomas)}")

            st.divider()
            
            # ---------------------------
            # B) ÁREA DE EDIÇÃO (DINÂMICA)
            # ---------------------------
            st.write("#### ✏️ Editar Vaga")
            
            
            col_titulo, col_dummy = st.columns([2, 1])
            novo_titulo = col_titulo.text_input("Título", value=vaga['titulo'], key=f"tit_{vaga['_id']}")
            
            # --- Lógica de UF/Cidade ---
            col_uf, col_cidade = st.columns(2)
            
            # 1. Recupera índice do estado atual
            try:
                idx_uf = lista_estados.index(uf_atual)
            except ValueError:
                idx_uf = 0
            
            # 2. Selectbox de Estado (Reativo)
            novo_estado = col_uf.selectbox(
                "Estado", 
                options=lista_estados, 
                index=idx_uf, 
                key=f"uf_{vaga['_id']}"
            )
            
            # 3. Carrega cidades baseadas no Estado selecionado acima
            cidades_edit = buscar_cidades_por_estado(novo_estado)
            
            # 4. Recupera índice da cidade atual (se existir na nova lista)
            try:
                idx_cidade = cidades_edit.index(cidade_atual)
            except ValueError:
                idx_cidade = 0
                
            nova_cidade = col_cidade.selectbox(
                "Cidade", 
                options=cidades_edit, 
                index=idx_cidade, 
                key=f"cid_{vaga['_id']}"
            )
            # ---------------------------

            nova_desc = st.text_area("Descrição", value=vaga['descricao'], key=f"desc_{vaga['_id']}")
            
            col_e3, col_e4 = st.columns(2)
            
            lista_contratos = ["CLT", "PJ", "Estágio", "Outro"]
            try:
                idx_cont = lista_contratos.index(vaga.get('tipo_contrato', "CLT"))
            except: idx_cont = 0
            
            novo_tipo = col_e3.selectbox("Contrato", lista_contratos, index=idx_cont, key=f"tipo_{vaga['_id']}")
            
            novo_salario = col_e4.number_input(
                "Salário", 
                value=float(vaga['salario']), 
                step=100.0,
                format="%.2f", 
                key=f"sal_{vaga['_id']}"
            )

            novas_habs = st.multiselect(
                "Habilidades", 
                options=opcoes_habilidades, 
                default=vaga['habilidades'], 
                key=f"hab_{vaga['_id']}"
            )
            
            if st.button("💾 Salvar Alterações", key=f"btn_save_{vaga['_id']}"):
                # Busca Geo Localização
                dados_geo_edit = buscar_dados_municipio(nova_cidade, novo_estado)
                
                update_data = {
                    "titulo": novo_titulo,
                    "descricao": nova_desc,
                    "salario": novo_salario,
                    "tipo_contrato": novo_tipo,
                    "habilidades": novas_habs,
                    "localizacao": {"cidade": nova_cidade, "estado": novo_estado},
                    "cidade": {
                        "nome": nova_cidade,
                        "uf": novo_estado,
                        "latitude": dados_geo_edit["latitude"] if dados_geo_edit else 0,
                        "longitude": dados_geo_edit["longitude"] if dados_geo_edit else 0
                    }
                }
                atualizar_vaga(vaga['_id'], update_data)
                st.success("Vaga atualizada com sucesso!")
                import time
                time.sleep(1)
                st.rerun()

            # ---------------------------
            # C) LÓGICA DE EXCLUSÃO
            # ---------------------------
            st.divider()
            
            col_trash, col_aviso = st.columns([1, 3])
            
            # Chave única para controle de estado
            chave_confirmar = f"confirmar_exclusao_{vaga['_id']}"
            
            if chave_confirmar not in st.session_state:
                st.session_state[chave_confirmar] = False

            # Botão inicial
            if col_trash.button("🗑️ Excluir", key=f"btn_trash_{vaga['_id']}", type="primary"):
                st.session_state[chave_confirmar] = True

            # Alerta de confirmação
            if st.session_state[chave_confirmar]:
                st.warning("⚠️ Tem certeza? Essa ação excluirá a vaga e removerá todos os candidatos associados.")
                
                col_sim, col_nao = st.columns(2)
                
                if col_sim.button("✅ Sim, excluir", key=f"sim_{vaga['_id']}"):
                    excluir_vaga(vaga['_id'])
                    st.toast("Vaga excluída com sucesso!", icon="🗑️")
                    
                    # Limpa estado e recarrega
                    del st.session_state[chave_confirmar]
                    import time
                    time.sleep(1)
                    st.rerun()
                
                if col_nao.button("❌ Cancelar", key=f"nao_{vaga['_id']}"):
                    st.session_state[chave_confirmar] = False
                    st.rerun()

rodape_personalizado()