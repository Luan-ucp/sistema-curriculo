# 💼 JobMatch System

> Plataforma SaaS de conexão entre talentos e oportunidades, desenvolvida com Python, Streamlit e MongoDB.

![Streamlit](https://img.shields.io/badge/Streamlit-FF4B4B?style=for-the-badge&logo=Streamlit&logoColor=white)
![Python](https://img.shields.io/badge/Python-3.10+-3776AB?style=for-the-badge&logo=python&logoColor=white)
![MongoDB](https://img.shields.io/badge/MongoDB-47A248?style=for-the-badge&logo=mongodb&logoColor=white)

## 📄 Sobre o Projeto

O **JobMatch** é um sistema de recrutamento completo que conecta candidatos a vagas de emprego utilizando um algoritmo de compatibilidade (*smart match*). O sistema possui dois portais distintos com controle de acesso rigoroso:

* **Portal do Recrutador:** Gestão completa de vagas, triagem de candidatos e dashboard.
* **Portal do Candidato:** Criação de currículo digital, busca de vagas e candidatura simplificada.

## 🚀 Funcionalidades Principais

| Módulo | Funcionalidades |
| :--- | :--- |
| **Autenticação** | Login seguro, Cadastro com hash de senha (SHA-256) e Sessão persistente. |
| **Vagas** | CRUD completo de vagas, visualização de inscritos e métricas de adesão. |
| **Match** | Algoritmo que calcula a % de compatibilidade entre as habilidades da vaga e do candidato. |
| **Interface** | Layout moderno (UI/UX) com temas personalizados e design responsivo. |

## 📂 Estrutura do Projeto

A arquitetura segue o padrão MVC (Model-View-Controller) adaptado para Streamlit:

```text
sistema-curriculo/
├── .streamlit/
│   ├── config.toml          # Configuração visual (Cores, Fontes)
│   └── secrets.toml         # Credenciais do Banco (Não comitar!)
├── pages/
│   ├── 02_painel_empresa.py     # View: Área da Empresa
│   └── 03_painel_candidato.py   # View: Área do Candidato
├── src/
│   ├── controllers/         # Regras de Negócio e Lógica
│   │   ├── auth_controller.py
│   │   ├── vaga_controller.py
│   │   └── ...
│   ├── database/
│   │   └── connection.py    # Conexão Singleton com MongoDB
│   ├── utils/
│   │   ├── ui.py            # Componentes visuais e CSS injetado
│   │   ├── security.py      # Criptografia
│   │   └── formatter.py     # Formatação de dados
│   └── __init__.py
├── app.py                   # Entry Point (Login/Landing Page)
├── requirements.txt         # Dependências do projeto
└── README.md                # Documentação
```

## 🛠️ Instalação e Configuração

### 1. Pré-requisitos
* Python 3.8 ou superior
* Conta no MongoDB Atlas (ou MongoDB local instalado)

### 2. Instalação das Dependências

Clone o repositório e instale as bibliotecas listadas no `requirements.txt`:

```bash
pip install -r requirements.txt
```
Nota: O arquivo requirements.txt deve conter:

```text
streamlit
pymongo==4.15.4
```

### 3. Configuração de Variáveis de Ambiente (Secrets)
Para segurança, as credenciais do banco não ficam no código. Crie um arquivo chamado secrets.toml dentro da pasta .streamlit/:

Arquivo: .streamlit/secrets.toml

```init, TOML
# Exemplo de configuração para MongoDB Atlas
[mongo]
uri = "mongodb+srv://<usuario>:<senha>@cluster0.mongodb.net/?retryWrites=true&w=majority"
db_name = "jobmatch_db"

# Ou para MongoDB Local
# uri = "mongodb://localhost:27017"
```

### 4. Executando o Projeto

Na raiz do projeto, execute:
 ```bash
streamlit run app.py
 ```

 O sistema estará disponível em: http://localhost:8501

 # 🔒 Segurança
 * **Senhas:** Nenhuma senha é salva em texto plano. Utilizamos SHA-256 (via hashlib) antes da persistência.

* **Sessão:** Controle de estado via st.session_state impede acesso direto às páginas internas sem login (st.stop() se não autenticado).

* **Isolamento:** Usuários do tipo "Candidato" não conseguem acessar rotas de "Empresa" e vice-versa.

# 💻 Link de Acesso à aplicação web

https://job-m4tch.streamlit.app/

# 👤 Autores

Desenvolvido por Luan Araújo & Moisés Dearo.

© 2025 JobMatch System.