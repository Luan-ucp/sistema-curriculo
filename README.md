# Laboratório de Banco de Dados  
## Sistema de Currículos (Banco de Vagas)  

Este projeto foi proposto pelo professor **Bruno Elias Penteado** com o objetivo de compreender e aplicar conceitos de **banco de dados relacionais**.  

Além do banco de dados, será desenvolvido um sistema web utilizando a biblioteca [Streamlit](https://streamlit.io/) em **Python**.  
O banco de dados será hospedado na nuvem através do serviço [Aiven](https://console.aiven.io/), utilizando o **MySQL** como Sistema Gerenciador de Banco de Dados (SGBD).  

---

## Conexão ao Banco de Dados  

### Pré-requisitos  
- Instalação do [MySQL Workbench](https://dev.mysql.com/downloads/workbench/);  
- Credenciais de acesso ao banco de dados (fornecidas pelo serviço Aiven).  

---

### Procedimentos para Conexão no MySQL Workbench  

1. Abrir o **MySQL Workbench**;  
2. No painel **MySQL Connections**, clicar em **+** para criar uma nova conexão;  
3. Preencher os campos da janela **Setup New Connection** com os dados fornecidos:  

```text
Hostname: sistema-curriculo-unesp-6605.d.aivencloud.com
Port: 11135
Username: avnadmin
Password: AVNS_e0dQRRILXP-5ImfpVRY
Default Schema: banco_de_vaga
```  

4. Clicar em **Test Connection** para verificar se as credenciais estão corretas;  
5. Em caso de sucesso, salvar a conexão e acessar o banco de dados.  

---
## Estrutura de Pasta

Dentro da pasta *./SQL* há subpastas nomeadas de acordo com a atividade a ser entregue, exemplo: *./SQL/atividade_3*.

Também foi criada uma pasta de *./SQL/migrations* para armazenar os scripts de alterações na estrutura do banco de dados. O nome do arquivo *.sql* do migration deve ser respectivo a atividade, por exemplo: *atividade_3.sql*.


## Tecnologias Utilizadas  

- **MySQL** – Sistema Gerenciador de Banco de Dados Relacional (SGBDR);  
- **Aiven** – Serviço de hospedagem em nuvem para o banco de dados;  
- **Python** – Linguagem de programação utilizada para integração;  
- **Streamlit** – Biblioteca Python para construção de interfaces web.  

---

