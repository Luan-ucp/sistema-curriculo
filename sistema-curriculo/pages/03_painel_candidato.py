# pages/03_painel_candidato.py
import streamlit as st
import time

# Imports dos controllers
from src.controllers.candidato_controller import buscar_perfil_candidato, atualizar_curriculo, excluir_curriculo_completo
from src.controllers.vaga_controller import listar_todas_vagas, candidatar_vaga
from src.controllers.habilidade_controller import buscar_habilidades
from src.utils.formatter import formatar_real

# --- 1. SEGURANÇA E SETUP ---
if "logado" not in st.session_state or not st.session_state["logado"]:
    st.warning("Faça login.")
    st.stop()

if st.session_state["perfil"] != "CANDIDATO":
    st.error("Página exclusiva para candidatos.")
    st.stop()

# Busca dados do usuário logado
dados_usuario = buscar_perfil_candidato(st.session_state["email"])

# Garante estrutura mínima para não quebrar
candidato_info = dados_usuario.get("candidato", {
    "curriculo": {"habilidades": [], "idiomas": []},
    "resumo": ""
})

st.title(f"Portal do Candidato: {st.session_state['usuario_nome']}")

# --- 2. CRIAÇÃO DAS ABAS ---
# Inverti a ordem: Currículo primeiro, Vagas depois.
tab_curriculo, tab_vagas = st.tabs(["📄 Meu Currículo", "🔍 Buscar Vagas"])

# ==========================================
# ABA 1: MEU CURRÍCULO (AGORA É A PRIMEIRA)
# ==========================================
with tab_curriculo:
    st.header("Editar Dados Profissionais")
    
    # Lista fixa de opções
    lista_habilidades_sistema = buscar_habilidades()

    with st.form("form_curriculo"):
        resumo = st.text_area("Resumo Profissional", value=candidato_info.get("resumo", ""))
        
        # Recupera o que já está salvo no banco
        habs_no_banco = candidato_info.get("curriculo", {}).get("habilidades", [])
        
        # Filtra para evitar erro de 'Option not found'
        defaults_seguros = [h for h in habs_no_banco if h in lista_habilidades_sistema]
        
        habilidades = st.multiselect(
            "Suas Habilidades Técnicas",
            options=lista_habilidades_sistema,
            default=defaults_seguros
        )
        
        lista_idiomas = candidato_info.get("curriculo", {}).get("idiomas", [])
        val_idiomas = ",".join(lista_idiomas) if lista_idiomas else ""
        idiomas = st.text_input("Idiomas (separados por vírgula)", value=val_idiomas)
        
        # Botão de Salvar dentro do Form
        if st.form_submit_button("💾 Salvar Currículo", use_container_width=True):
            novo_candidato = {
                "experiencia": "Atualizado pelo form", 
                "formacao": "Atualizado pelo form",
                "resumo": resumo,
                "contatos": [],
                "curriculo": {
                    "formacoes": [],
                    "experiencias": [],
                    "habilidades": habilidades,
                    "idiomas": [i.strip() for i in idiomas.split(",") if i.strip()]
                }
            }
            atualizar_curriculo(st.session_state["email"], novo_candidato)
            st.success("Currículo atualizado com sucesso!")
            time.sleep(1)
            st.rerun()

    # --- ZONA DE PERIGO (Fora do Form) ---
    st.divider()
    st.subheader("Zona de Perigo")

    if "confirmar_delete" not in st.session_state:
        st.session_state["confirmar_delete"] = False

    if st.button("🗑️ Excluir Currículo e Cancelar Inscrições"):
        st.session_state["confirmar_delete"] = True

    if st.session_state["confirmar_delete"]:
        st.error("⚠️ **ATENÇÃO:** Ao excluir seu currículo, você será automaticamente **desligado de todas as vagas** nas quais se candidatou.")
        
        col_sim, col_nao = st.columns(2)
        
        if col_sim.button("Sim, tenho certeza", type="primary", use_container_width=True):
            excluir_curriculo_completo(st.session_state["email"])
            st.session_state["confirmar_delete"] = False
            st.toast("Excluído com sucesso!", icon="🗑️")
            time.sleep(1.5)
            st.rerun()

        if col_nao.button("Cancelar", use_container_width=True):
            st.session_state["confirmar_delete"] = False
            st.rerun()


# ==========================================
# ABA 2: VAGAS DISPONÍVEIS
# ==========================================
with tab_vagas:
    col_header, col_sort = st.columns([2, 1])
    col_header.write("### Vagas Disponíveis")
    
    ordem = col_sort.radio(
        "Ordenar por:",
        ["Mais Recentes", "Maior Compatibilidade 🟢", "Menor Compatibilidade 🔴"],
        horizontal=True,
        label_visibility="collapsed"
    )
    
    todas_vagas = listar_todas_vagas()
    minhas_skills = set(candidato_info.get("curriculo", {}).get("habilidades", []))

    # --- Lógica de Match e Ordenação ---
    vagas_processadas = []
    for vaga in todas_vagas:
        skills_vaga = set(vaga.get("habilidades", []))
        match_percent = 0
        match_items = set()
        
        if skills_vaga:
            match_items = minhas_skills.intersection(skills_vaga)
            match_percent = int((len(match_items) / len(skills_vaga)) * 100)
        
        vaga["_match_percent"] = match_percent
        vaga["_match_items"] = match_items
        vagas_processadas.append(vaga)

    if ordem == "Maior Compatibilidade 🟢":
        vagas_processadas.sort(key=lambda x: x["_match_percent"], reverse=True)
    elif ordem == "Menor Compatibilidade 🔴":
        vagas_processadas.sort(key=lambda x: x["_match_percent"], reverse=False)
    else:
        vagas_processadas.sort(key=lambda x: x["_id"], reverse=True)

    # --- Exibição ---
    if not minhas_skills:
        st.info("💡 Dica: Preencha a aba 'Meu Currículo' para ver quais vagas combinam com você!")

    count = 0
    for vaga in vagas_processadas:
        count += 1
        with st.container(border=True):
            col_info, col_match = st.columns([3, 1])
            
            with col_info:
                st.subheader(vaga['titulo'])
                st.caption(f"{vaga['empregador']['razao_social']} | {vaga['localizacao']['cidade']}-{vaga['localizacao']['estado']}")
                st.write(vaga['descricao'])
                st.markdown(f"**Salário:** {formatar_real(vaga['salario'])}")
                
                inscritos_str = [str(uid) for uid in vaga.get("candidatos_inscritos", [])]
                usuario_id_str = str(dados_usuario["_id"])
                
                if usuario_id_str in inscritos_str:
                    st.success("✅ Já candidatado")
                else:
                    # Key única para evitar conflito de botões
                    if st.button("Quero me candidatar", key=f"btn_{vaga['_id']}_{count}"):
                        sucesso, msg = candidatar_vaga(vaga['_id'], dados_usuario["_id"])
                        if sucesso:
                            st.toast(msg, icon="🎉")
                            time.sleep(1)
                            st.rerun()
                        else:
                            st.error(msg)

            with col_match:
                percentual = vaga["_match_percent"]
                match_items = vaga["_match_items"]
                
                if percentual == 100:
                    st.metric("Match", f"{percentual}%", "Perfeito!", delta_color="normal")
                elif percentual >= 50:
                    st.metric("Match", f"{percentual}%", "Bom", delta_color="normal")
                else:
                    st.metric("Match", f"{percentual}%", "Baixo", delta_color="inverse")
                
                if match_items:
                    st.caption(f"Match: {', '.join(match_items)}")