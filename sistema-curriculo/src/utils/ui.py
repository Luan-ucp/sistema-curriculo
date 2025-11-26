import streamlit as st

def configurar_pagina(titulo_pagina, icone_pagina="💼"):
    """
    Configurações iniciais da página e injeção de CSS personalizado.
    """
    st.set_page_config(
        page_title=f"JobMatch | {titulo_pagina}",
        page_icon=icone_pagina,
        layout="wide",
        initial_sidebar_state="expanded"
    )
    
    # CSS Customizado
    st.markdown("""
        <style>
        /* 1. Importando fonte moderna (Inter) */
        @import url('https://fonts.googleapis.com/css2?family=Inter:wght@400;600;700&display=swap');
        
        html, body, [class*="css"]  {
            font-family: 'Inter', sans-serif;
        }

        /* 2. Estilizando Botões para ficarem redondos e modernos */
        .stButton > button {
            border-radius: 8px;
            font-weight: 600;
            border: none;
            transition: all 0.3s ease;
        }
        
        /* 3. Estilizando Cards (Containers com borda) */
        [data-testid="stForm"], [data-testid="stExpander"] {
            background-color: #ffffff;
            border-radius: 12px;
            box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);
            border: 1px solid #e5e7eb;
            padding: 1rem;
        }

        /* 4. Ajuste do Rodapé Fixo */
        footer {visibility: hidden;} /* Esconde o rodapé padrão do Streamlit */
        
        .footer {
            position: fixed;
            left: 0;
            bottom: 0;
            width: 100%;
            background-color: #F3F4F6;
            color: #6B7280;
            text-align: center;
            padding: 10px;
            font-size: 14px;
            border-top: 1px solid #E5E7EB;
            z-index: 1000;
        }
        
        /* Adiciona espaço no final da página para o conteúdo não ficar atrás do rodapé */
        .block-container {
            padding-bottom: 80px;
        }
        </style>
    """, unsafe_allow_html=True)

def rodape_personalizado():
    """
    Renderiza o rodapé fixo.
    """
    st.markdown("""
        <div class="footer">
            <p>Desenvolvido por <b>Luan Araújo & Moisés Dearo</b> | © 2025 JobMatch System</p>
        </div>
    """, unsafe_allow_html=True)