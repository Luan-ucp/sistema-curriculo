CREATE DATABASE banco_de_vaga;
USE banco_de_vaga;

CREATE USER 'admin'@'localhost' IDENTIFIED BY '123@mudar';
GRANT ALL PRIVILEGES ON banco_de_vaga.* TO 'admin'@'localhost' WITH GRANT OPTION;
FLUSH PRIVILEGES;

CREATE USER 'viewer'@'localhost' IDENTIFIED BY '123@mudar';
GRANT SELECT ON banco_de_vaga.* TO 'viewer'@'localhost';
FLUSH PRIVILEGES;

START transaction;
savepoint sp1;

CREATE TABLE Usuario (
    id_usuario INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(100) NOT NULL,
    email VARCHAR(150) UNIQUE NOT NULL,
    senha_hash VARCHAR(255) NOT NULL,
    perfil ENUM('ADMIN', 'EMPREGADOR', 'CANDIDATO') NOT NULL
);

CREATE TABLE AuditoriaLogin (
    id_log INT PRIMARY KEY AUTO_INCREMENT,
    id_usuario INT, 
    data_hora DATETIME NOT NULL,
    ip VARCHAR(50),
    sucesso BOOLEAN NOT NULL,
    FOREIGN KEY (id_usuario) REFERENCES Usuario(id_usuario)
);

CREATE TABLE Localizacao (
    id_local INT PRIMARY KEY AUTO_INCREMENT,
    cidade VARCHAR(100) NOT NULL,
    estado VARCHAR(50) NOT NULL
);

CREATE TABLE Empregador (
    id_empregador INT PRIMARY KEY AUTO_INCREMENT,
    id_usuario INT default NULL,
    razao_social VARCHAR(150) NOT NULL,
    FOREIGN KEY (id_usuario) REFERENCES Usuario(id_usuario)
);

CREATE TABLE Vaga (
    id_vaga INT PRIMARY KEY AUTO_INCREMENT,
    id_empregador INT NOT NULL,
    id_local INT NOT NULL,
    titulo VARCHAR(150) NOT NULL,
    descricao TEXT,
    tipo_contrato VARCHAR(50),
    salario DECIMAL(10,2),
    FOREIGN KEY (id_empregador) REFERENCES Empregador(id_empregador),
    FOREIGN KEY (id_local) REFERENCES Localizacao(id_local)
);

CREATE TABLE Candidato (
    id_candidato INT PRIMARY KEY AUTO_INCREMENT,
    id_usuario INT default NULL,
    nome VARCHAR(100) NOT NULL,
    email VARCHAR(150) NOT NULL,
    telefone VARCHAR(20),
    experiencia TEXT,
    formacao TEXT,
    resumo TEXT,
    FOREIGN KEY (id_usuario) REFERENCES Usuario(id_usuario)
);

CREATE TABLE Candidatura (
    id_candidatura INT PRIMARY KEY AUTO_INCREMENT,
    id_candidato INT NOT NULL,
    id_vaga INT NOT NULL,
    data_candidatura DATETIME NOT NULL,
    status ENUM('ENVIADA', 'EM_ANALISE', 'ENTREVISTA', 'APROVADA', 'REJEITADA') NOT NULL,
    FOREIGN KEY (id_candidato) REFERENCES Candidato(id_candidato),
    FOREIGN KEY (id_vaga) REFERENCES Vaga(id_vaga)
);

CREATE TABLE Mensagem (
    id_msg INT PRIMARY KEY AUTO_INCREMENT,
    id_candidatura INT NOT NULL,
    id_remetente INT NOT NULL,
    data_hora DATETIME NOT NULL,
    conteudo TEXT NOT NULL,
    FOREIGN KEY (id_candidatura) REFERENCES Candidatura(id_candidatura),
    FOREIGN KEY (id_remetente) REFERENCES Usuario(id_usuario)
);

CREATE TABLE Curriculo (
    id_curriculo INT PRIMARY KEY AUTO_INCREMENT,
    id_candidato INT NOT NULL,
    FOREIGN KEY (id_candidato) REFERENCES Candidato(id_candidato)
);

#ADAPTAR
#CREATE TABLE Formacao (
#    id_form INT PRIMARY KEY AUTO_INCREMENT,
#    id_curriculo INT NOT NULL,
#    curso VARCHAR(150) NOT NULL,
#    instituicao VARCHAR(150),
#    nivel VARCHAR(50),
#    ano_conclusao INT,
#    FOREIGN KEY (id_curriculo) REFERENCES Curriculo(id_curriculo)
#);

#ADAPTAR
#CREATE TABLE Experiencia (
#   id_exp INT PRIMARY KEY AUTO_INCREMENT,
#    id_curriculo INT NOT NULL,
#    cargo VARCHAR(100) NOT NULL,
#    empresa VARCHAR(150),
#    inicio DATE NOT NULL,
#    fim DATE,
#    descricao TEXT,
#    FOREIGN KEY (id_curriculo) REFERENCES Curriculo(id_curriculo)
#);

CREATE TABLE Habilidade (
    id_hab INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(100) UNIQUE NOT NULL
);

CREATE TABLE Idioma (
    id_idioma INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(100) NOT NULL
);

CREATE TABLE Curriculo_Habilidade (
    id_curriculo INT,
    id_hab INT,
    PRIMARY KEY (id_curriculo, id_hab),
    FOREIGN KEY (id_curriculo) REFERENCES Curriculo(id_curriculo),
    FOREIGN KEY (id_hab) REFERENCES Habilidade(id_hab)
);

CREATE TABLE Curriculo_Idioma (
    id_curriculo INT,
    id_idioma INT,
    PRIMARY KEY (id_curriculo, id_idioma),
    FOREIGN KEY (id_curriculo) REFERENCES Curriculo(id_curriculo),
    FOREIGN KEY (id_idioma) REFERENCES Idioma(id_idioma)
);

CREATE TABLE Vaga_Habilidade (
    id_vaga INT,
    id_hab INT,
    PRIMARY KEY (id_vaga, id_hab),
    FOREIGN KEY (id_vaga) REFERENCES Vaga(id_vaga),
    FOREIGN KEY (id_hab) REFERENCES Habilidade(id_hab)
);

CREATE TABLE Vaga_Idioma (
    id_vaga INT,
    id_idioma INT,
    PRIMARY KEY (id_vaga, id_idioma),
    FOREIGN KEY (id_vaga) REFERENCES Vaga(id_vaga),
    FOREIGN KEY (id_idioma) REFERENCES Idioma(id_idioma)
);
CREATE TABLE Contato (
    id_contato INT PRIMARY KEY AUTO_INCREMENT,
    tipo VARCHAR(50) NOT NULL,
    valor VARCHAR(255) NOT NULL
);

CREATE TABLE Candidato_Contato (
    id_candidato INT,
    id_contato INT,
    PRIMARY KEY (id_candidato, id_contato),
    FOREIGN KEY (id_candidato) REFERENCES Candidato(id_candidato),
    FOREIGN KEY (id_contato) REFERENCES Contato(id_contato)
);

-- Empresa
INSERT INTO Empregador (razao_social) VALUES
('Cavalcanti'), ('Campos S.A.'), ('Ramos - ME'), ('da Paz Ramos S/A'),
('Azevedo'), ('Ramos Araújo - EI'), ('Peixoto'), ('Nogueira'),
('Porto - ME'), ('Duarte Silveira Ltda.'),
('Costela Ltda.'), ('IBM Brasil'), ('TOTVS'), ('Amazon Brasil'),
('Itaú Unibanco'), ('Microsoft Brasil'),
('Globo.com'), ('Google Brasil'), ('Petrobras'), ('Ferreira'), ('Mercado Livre'),
('Vale'), ('Embraer'), ('Gomes'), ('Campos Costa - EI'),
('Lopes S/A'), ('Whirlpool'),('Unesp'), ('PagSeguro'), ('Nubank');

-- Localização
INSERT INTO Localizacao (cidade, estado) VALUES
('Fortaleza', 'CE'), ('Florianópolis', 'SC'), ('Recife', 'PE'), ('Curitiba', 'PR'),
('Salvador', 'BA'), ('Brasília', 'DF'), ('Rio de Janeiro', 'RJ'), ('Porto Alegre', 'RS'),
('São Paulo', 'SP'), ('Belo Horizonte', 'MG'), ('Rio Claro', 'SP');

-- Habilidade
INSERT INTO Habilidade (nome) VALUES
('AWS'), ('Azure'), ('C#'), ('CI/CD'), ('CSS'), ('Django'), ('Docker'),
('Flask'), ('GCP'), ('Git'), ('Google Cloud'), ('Hadoop'), ('HTML'), ('Java'),
('JavaScript'), ('Kanban'), ('Kubernetes'), ('Linux'), ('MongoDB'), ('Node.js'),
('NoSQL'), ('PostgreSQL'), ('Power BI'), ('Python'), ('PyTorch'), ('React'),
('Scrum'), ('Spark'), ('SQL'), ('Tableau'), ('TensorFlow'), ('MySQL'), ('Vue.js'), ('Angular'), ('Redis');

-- Idioma
INSERT INTO Idioma (nome) VALUES
('Inglês'), ('Português'), ('Alemão'), ('Espanhol'), ('Francês');

-- Vaga
INSERT INTO Vaga (titulo, descricao, id_local, tipo_contrato, salario, id_empregador) VALUES
('Desenvolvedor Frontend','Conduzir projetos de ciência de dados, desde a coleta e limpeza até a modelagem e visualização.',11,'CLT',9020 ,27),
('Scrum Master','Implementar e monitorar práticas de segurança da informação, mitigando riscos cibernéticos.',9,'Estágio',3431 ,28),
('Administrador de Banco de Dados','Implementar e monitorar práticas de segurança da informação, mitigando riscos cibernéticos.',2,'CLT',10362 ,1),
('Cientista de Dados','Prestar suporte técnico a usuários, solucionando problemas de hardware e software.',3,'Estágio',14653 ,2),
('Desenvolvedor Fullstack','Projetar e treinar modelos de machine learning para resolver problemas complexos de negócio.',2,'Temporário',5740 ,3),
('Especialista em Redes','Prestar suporte técnico a usuários, solucionando problemas de hardware e software.',4,'PJ',7875 ,4),
('Infra TI','Desenvolver soluções em nuvem utilizando AWS, Azure ou GCP, garantindo escalabilidade e confiabilidade.',5,'Temporário',11742 ,5),
('Desenvolvedor Fullstack','Administrar e otimizar bancos de dados relacionais e não relacionais, garantindo disponibilidade.',6,'Estágio',12515 ,6),
('Desenvolvedor Backend','Coordenar equipes de desenvolvimento, assegurando a entrega de projetos no prazo e orçamento.',7,'Estágio',6835 ,7),
('Arquiteto de Soluções','Administrar e otimizar bancos de dados relacionais e não relacionais, garantindo disponibilidade.',2,'PJ',3493 ,8),
('Especialista em Cloud Computing','Coordenar equipes de desenvolvimento, assegurando a entrega de projetos no prazo e orçamento.',2,'Temporário',10707 ,9),
('Cientista de Dados','Implementar e monitorar práticas de segurança da informação, mitigando riscos cibernéticos.',1,'Temporário',4106 ,10),
('Cientista de Dados','Desenvolver soluções em nuvem utilizando AWS, Azure ou GCP, garantindo escalabilidade e confiabilidade.',4,'Temporário',8034 ,11),
('Engenheiro DevOps','Responsável por desenvolver e manter aplicações escaláveis, garantindo alta performance e segurança.',8,'Estágio',11255 ,12),
('Designer de UX/UI','Projetar e treinar modelos de machine learning para resolver problemas complexos de negócio.',2,'PJ',8110 ,12),
('Arquiteto de Soluções','Administrar e otimizar bancos de dados relacionais e não relacionais, garantindo disponibilidade.',3,'Temporário',10633 ,13),
('Analista de Sistemas','Administrar e otimizar bancos de dados relacionais e não relacionais, garantindo disponibilidade.',5,'Estágio',9535 ,12),
('Product Owner','Administrar e otimizar bancos de dados relacionais e não relacionais, garantindo disponibilidade.',5,'PJ',8160 ,12),
('Engenheiro DevOps','Desenvolver soluções em nuvem utilizando AWS, Azure ou GCP, garantindo escalabilidade e confiabilidade.',11,'CLT',7634 ,27),
('Designer de UX/UI','Atuar na análise, modelagem e otimização de processos de dados, criando pipelines eficientes.',1,'Temporário',4757 ,13),
('Administrador de Banco de Dados','Atuar na análise, modelagem e otimização de processos de dados, criando pipelines eficientes.',8,'Temporário',3599 ,12),
('Especialista em Redes','Desenvolver soluções em nuvem utilizando AWS, Azure ou GCP, garantindo escalabilidade e confiabilidade.',1,'Estágio',8036 ,13),
('Engenheiro de Machine Learning','Coordenar equipes de desenvolvimento, assegurando a entrega de projetos no prazo e orçamento.',2,'PJ',11317 ,13),
('Desenvolvedor Backend','Administrar e otimizar bancos de dados relacionais e não relacionais, garantindo disponibilidade.',1,'Estágio',11004 ,14),
('Engenheiro DevOps','Desenvolver interfaces intuitivas e responsivas, focadas na melhor experiência do usuário.',4,'CLT',4181 ,12),
('Especialista em Cloud Computing','Prestar suporte técnico a usuários, solucionando problemas de hardware e software.',9,'Estágio',3145 ,12),
('Analista de BI','Desenvolver interfaces intuitivas e responsivas, focadas na melhor experiência do usuário.',2,'Temporário',12205 ,12),
('Analista de Qualidade de Software','Administrar e otimizar bancos de dados relacionais e não relacionais, garantindo disponibilidade.',3,'Estágio',6988 ,12),
('Arquiteto de Soluções','Implementar e monitorar práticas de segurança da informação, mitigando riscos cibernéticos.',2,'PJ',12254 ,15),
('Infra TI','Projetar e treinar modelos de machine learning para resolver problemas complexos de negócio.',10,'Temporário',9240 ,16),
('Engenheiro DevOps','Implementar e monitorar práticas de segurança da informação, mitigando riscos cibernéticos.',2,'Estágio',14940 ,17),
('Arquiteto de Soluções','Atuar na análise, modelagem e otimização de processos de dados, criando pipelines eficientes.',3,'Temporário',12733 ,18),
('Arquiteto de Soluções','Desenvolver interfaces intuitivas e responsivas, focadas na melhor experiência do usuário.',8,'CLT',9882 ,19),
('Desenvolvedor Fullstack','Administrar e otimizar bancos de dados relacionais e não relacionais, garantindo disponibilidade.',7,'Temporário',8892 ,20),
('Administrador de Banco de Dados','Implementar e monitorar práticas de segurança da informação, mitigando riscos cibernéticos.',9,'Temporário',7605 ,12),
('Desenvolvedor Backend','Responsável por desenvolver e manter aplicações escaláveis, garantindo alta performance e segurança.',10,'PJ',3396 ,13),
('Especialista em Redes','Responsável por desenvolver e manter aplicações escaláveis, garantindo alta performance e segurança.',3,'Estágio',7866 ,19),
('Especialista em Redes','Implementar e monitorar práticas de segurança da informação, mitigando riscos cibernéticos.',9,'Temporário',4913 ,12),
('Analista de Suporte Técnico','Administrar e otimizar bancos de dados relacionais e não relacionais, garantindo disponibilidade.',8,'Temporário',9016 ,16),
('Analista de BI','Coordenar equipes de desenvolvimento, assegurando a entrega de projetos no prazo e orçamento.',10,'Estágio',4122 ,13),
('Desenvolvedor Backend','Projetar e treinar modelos de machine learning para resolver problemas complexos de negócio.',7,'CLT',11319 ,14),
('Analista de BI','Conduzir projetos de ciência de dados, desde a coleta e limpeza até a modelagem e visualização.',5,'Temporário',14391 ,21),
('Cientista de Dados','Implementar e monitorar práticas de segurança da informação, mitigando riscos cibernéticos.',2,'PJ',14156 ,19),
('Engenheiro de Dados','Projetar e treinar modelos de machine learning para resolver problemas complexos de negócio.',5,'CLT',9396 ,17),
('Engenheiro de Machine Learning','Implementar e monitorar práticas de segurança da informação, mitigando riscos cibernéticos.',5,'CLT',11192 ,17),
('Analista de BI','Desenvolver soluções em nuvem utilizando AWS, Azure ou GCP, garantindo escalabilidade e confiabilidade.',9,'Estágio',13471 ,22),
('Especialista em Redes','Desenvolver soluções em nuvem utilizando AWS, Azure ou GCP, garantindo escalabilidade e confiabilidade.',7,'Estágio',11234 ,23),
('Analista de Suporte Técnico','Implementar e monitorar práticas de segurança da informação, mitigando riscos cibernéticos.',7,'PJ',12804 ,24),
('Engenheiro DevOps','Prestar suporte técnico a usuários, solucionando problemas de hardware e software.',7,'PJ',4872 ,25),
('Analista de Segurança da Informação','Implementar e monitorar práticas de segurança da informação, mitigando riscos cibernéticos.',2,'Temporário',10136 ,26);


-- Vaga-Habilidade
INSERT INTO Vaga_Habilidade (id_vaga, id_hab) VALUES
(1,1), (1,24), (1,27), (2,26), (2,27), (2,4), (2,21), (2,14), (3,21), (3,15),
(3,27),(3,13),(3,16),(3,30),(4,30),(4,15),(4,23),(5,26),(5,13),(5,29),(5,24),(5,23),(5,10),(6,24),(6,28),(6,29),(6,23),
(7,7),(7,2),(7,9),(8,18),(8,4),(8,1),(8,29),(8,7),(8,27),(9,28),(9,13),(9,30),(9,12),(9,20),(9,9),(10,10),(10,2),(10,27),
(11,27),(11,15),(11,12),(11,9),(12,15),(12,12),(12,20),(12,23),(13,4),(13,1),(13,21),(13,16),(13,29),(13,18),(14,7),(14,17),
(14,18),(15,26),(15,1),(15,4),(15,14),(15,29),(16,30),(16,24),(16,29),(16,27),(17,29),(17,21),(17,13),(17,24),(17,9),(17,23),
(18,5),(18,7),(18,28),(18,26),(18,24),(18,1),(19,28),(19,12),(19,9),(19,10),(20,23),(20,28),(20,15),(20,21),(20,14),(20,2),
(21,1),(21,26),(21,28),(22,27),(22,12),(22,2),(23,7),(23,26),(23,24),(23,30),(24,17),(24,12),(24,13),(25,28),(25,2),(25,13),
(25,30),(25,16),(26,10),(26,23),(26,17),(26,29),(27,5),(27,21),(27,13),(27,18),(27,20),(28,20),(28,24),(28,14),(29,7),(29,1),
(29,15),(29,9),(30,4),(30,12),(30,14),(30,20),(30,2),(30,17),(31,15),(31,21),(31,5),(32,17),(32,14),(32,2),(32,28),(33,12),
(33,23),(33,26),(34,15),(34,1),(34,20),(34,17),(35,18),(35,20),(35,16),(35,29),(35,14),(36,28),(36,7),(36,29),(36,4),(36,17),
(36,27),(37,26),(37,30),(37,2),(37,27),(38,13),(38,20),(38,27),(39,7),(39,1),(39,5),(39,23),(39,17),(40,28),(40,4),(40,14),(40,20),
(40,9),(40,2),(41,20),(41,16),(41,17),(41,30),(41,29),(41,23),(42,14),(42,1),(42,13),(42,15),(42,29),(43,27),(43,12),(43,26),(43,2),
(43,18),(43,30),(44,27),(44,14),(44,24),(44,26),(44,18),(44,20),(45,24),(45,27),(45,13),(46,29),(46,26),(46,1),(47,18),(47,30),
(47,7),(47,1),(48,9),(48,26),(48,1),(49,21),(49,7),(49,18),(49,24),(49,14),(49,12),(50,28),(50,18),(50,20),(50,10);

-- Candidato
INSERT INTO candidato (nome, email, telefone, formacao, experiencia, resumo) VALUES
('Henrique Ferreira Santos','henrique.ferreira.santos@exemplo.com','+55 11 91896-2569','Bacharelado em Sistemas de Informação','5 anos como analista de dados','Profissional com 5 anos como analista de dados, aplicando tecnologias como React, PostgreSQL, MongoDB em projetos realizados em empresas como IBM Brasil. Possui certificações como Certified Kubernetes Administrator, Microsoft Certified: Azure Fundamentals, destacando-se pela capacidade de entregar soluções inovadoras e eficientes alinhadas às necessidades do negócio.'),
('Paula Moreira Pereira','paula.moreira.pereira@exemplo.com','+55 11 91288-1625','Engenharia da Computação','3 anos como cientista de dados','Profissional com 3 anos como cientista de dados, aplicando tecnologias como Kubernetes, TensorFlow, CSS em projetos realizados em empresas como TOTVS, IBM Brasil. Possui certificações como Certified Information Systems Security Professional (CISSP), Oracle Certified Professional, Java SE, destacando-se pela capacidade de entregar soluções inovadoras e eficientes alinhadas às necessidades do negócio.'),
('Sofia Teixeira da Silva','sofia.teixeira.da.silva@exemplo.com','+55 11 91693-7084','Engenharia de Software','2 anos como engenheiro de software','Profissional com 2 anos como engenheiro de software, aplicando tecnologias como NoSQL, JavaScript, SQL em projetos realizados em empresas como IBM Brasil, Petrobras. Possui certificações como AWS Certified Solutions Architect, Scrum Master Certified, destacando-se pela capacidade de entregar soluções inovadoras e eficientes alinhadas às necessidades do negócio.'),
('Carla Mendes Ferreira','carla.mendes.ferreira@yahoo.com','+55 11 96357-3867','Bacharelado em Ciência da Computação','3 anos como cientista de dados','Profissional com 3 anos como cientista de dados, aplicando tecnologias como Azure, Node.js, Spark em projetos realizados em empresas como IBM Brasil. Possui certificações como Certified Information Systems Security Professional (CISSP), destacando-se pela capacidade de entregar soluções inovadoras e eficientes alinhadas às necessidades do negócio.'),
('Tiago Barros Ferreira','tiago.barros.ferreira@exemplo.com','+55 11 94864-1445','Bacharelado em Sistemas de Informação','2 anos como engenheiro de software','Profissional com 2 anos como engenheiro de software, aplicando tecnologias como React, Redis, Angular em projetos realizados em empresas como Microsoft Brasil, IBM Brasil. Possui certificações como Google Cloud Professional Data Engineer, destacando-se pela capacidade de entregar soluções inovadoras e eficientes alinhadas às necessidades do negócio.'),
('Eduarda Rocha Santos','eduarda.rocha.santos@yahoo.com','+55 11 97942-6822','Engenharia de Software','4 anos como administrador de banco de dados','Profissional com 4 anos como administrador de banco de dados, aplicando tecnologias como Docker, Google Cloud, MySQL em projetos realizados em empresas como Petrobras, Mercado Livre. Possui certificações como Certified Information Systems Security Professional (CISSP), destacando-se pela capacidade de entregar soluções inovadoras e eficientes alinhadas às necessidades do negócio.'),
('Eduarda Rocha Pereira','eduarda.rocha.pereira@exemplo.com','+55 11 98160-2097','Engenharia de Software','2 anos como engenheiro de software','Profissional com 2 anos como engenheiro de software, aplicando tecnologias como Spark, Kubernetes, PostgreSQL em projetos realizados em empresas como Itaú Unibanco, Google Brasil. Possui certificações como Oracle Certified Professional, Java SE, Scrum Master Certified, destacando-se pela capacidade de entregar soluções inovadoras e eficientes alinhadas às necessidades do negócio.'),
('Tiago Barros Santos','tiago.barros.santos@exemplo.com','+55 11 91848-4102','Engenharia da Computação','3 anos como desenvolvedor backend','Profissional com 3 anos como desenvolvedor backend, aplicando tecnologias como SQL, Spark, JavaScript em projetos realizados em empresas como Globo.com, Petrobras. Possui certificações como Scrum Master Certified, Certified Information Systems Security Professional (CISSP), Certified Kubernetes Administrator, destacando-se pela capacidade de entregar soluções inovadoras e eficientes alinhadas às necessidades do negócio.'),
('Eduarda Rocha Ferreira','eduarda.rocha.ferreira@exemplo.com','+55 11 97842-7648','Bacharelado em Sistemas de Informação','5 anos como engenheiro de dados','Profissional com 5 anos como engenheiro de dados, aplicando tecnologias como Kubernetes, Hadoop, PostgreSQL em projetos realizados em empresas como TOTVS. Possui certificações como AWS Certified Solutions Architect, Oracle Certified Professional, Java SE, destacando-se pela capacidade de entregar soluções inovadoras e eficientes alinhadas às necessidades do negócio.'),
('Sofia Teixeira da Silva','sofia.teixeira.da.silva@outlook.com','+55 11 97703-9635','Tecnólogo em Análise e Desenvolvimento de Sistemas','4 anos como administrador de banco de dados','Profissional com 4 anos como administrador de banco de dados, aplicando tecnologias como Node.js, Java, Hadoop em projetos realizados em empresas como Petrobras. Possui certificações como Certified Kubernetes Administrator, Scrum Master Certified, destacando-se pela capacidade de entregar soluções inovadoras e eficientes alinhadas às necessidades do negócio.'),
('Ricardo Nunes Melo','ricardo.nunes.melo@exemplo.com','+55 11 96484-8086','Engenharia de Software','4 anos como administrador de banco de dados','Profissional com 4 anos como administrador de banco de dados, aplicando tecnologias como SQL, MySQL, Hadoop em projetos realizados em empresas como Google Brasil. Possui certificações como Google Cloud Professional Data Engineer, destacando-se pela capacidade de entregar soluções inovadoras e eficientes alinhadas às necessidades do negócio.'),
('Natália Andrade Santos','natália.andrade.santos@exemplo.com','+55 11 92550-5003','Engenharia de Software','2 anos como engenheiro de software','Profissional com 2 anos como engenheiro de software, aplicando tecnologias como Hadoop, MongoDB, AWS em projetos realizados em empresas como Microsoft Brasil, Vale. Possui certificações como AWS Certified Solutions Architect, Scrum Master Certified, Certified Kubernetes Administrator, destacando-se pela capacidade de entregar soluções inovadoras e eficientes alinhadas às necessidades do negócio.'),
('Karen Martins Ferreira','karen.martins.ferreira@exemplo.com','+55 11 97067-1473','Tecnólogo em Análise e Desenvolvimento de Sistemas','2 anos como especialista em segurança da informação','Profissional com 2 anos como especialista em segurança da informação, aplicando tecnologias como Google Cloud, PyTorch, JavaScript em projetos realizados em empresas como Vale. Possui certificações como Google Cloud Professional Data Engineer, Certified Kubernetes Administrator, destacando-se pela capacidade de entregar soluções inovadoras e eficientes alinhadas às necessidades do negócio.'),
('João Pereira da Silva','joão.pereira.da.silva@exemplo.com','+55 11 96463-5381','Engenharia de Software','3 anos como desenvolvedor backend','Profissional com 3 anos como desenvolvedor backend, aplicando tecnologias como NoSQL, React, SQL em projetos realizados em empresas como TOTVS, Google Brasil. Possui certificações como AWS Certified Solutions Architect, Certified Kubernetes Administrator, destacando-se pela capacidade de entregar soluções inovadoras e eficientes alinhadas às necessidades do negócio.'),
('Carla Mendes da Silva','carla.mendes.da.silva@exemplo.com','+55 11 91933-4621','Tecnólogo em Análise e Desenvolvimento de Sistemas','5 anos como engenheiro de dados','Profissional com 5 anos como engenheiro de dados, aplicando tecnologias como Google Cloud, Kubernetes, JavaScript em projetos realizados em empresas como TOTVS. Possui certificações como Certified Kubernetes Administrator, Oracle Certified Professional, Java SE, destacando-se pela capacidade de entregar soluções inovadoras e eficientes alinhadas às necessidades do negócio.'),
('João Pereira Santos','joão.pereira.santos@exemplo.com','+55 11 94578-8734','Bacharelado em Ciência da Computação','5 anos como analista de dados','Profissional com 5 anos como analista de dados, aplicando tecnologias como React, Kubernetes, Node.js em projetos realizados em empresas como Google Brasil, TOTVS. Possui certificações como AWS Certified Solutions Architect, destacando-se pela capacidade de entregar soluções inovadoras e eficientes alinhadas às necessidades do negócio.'),
('Henrique Ferreira Ferreira','henrique.ferreira.ferreira@exemplo.com','+55 11 98200-2508','Tecnólogo em Análise e Desenvolvimento de Sistemas','2 anos como engenheiro de software','Profissional com 2 anos como engenheiro de software, aplicando tecnologias como MongoDB, Docker, React em projetos realizados em empresas como Embraer, IBM Brasil. Possui certificações como Certified Kubernetes Administrator, AWS Certified Solutions Architect, destacando-se pela capacidade de entregar soluções inovadoras e eficientes alinhadas às necessidades do negócio.'),
('Sofia Teixeira Melo','sofia.teixeira.melo@exemplo.com','+55 11 98778-8642','Bacharelado em Sistemas de Informação','5 anos como analista de dados','Profissional com 5 anos como analista de dados, aplicando tecnologias como Java, Node.js, React em projetos realizados em empresas como Petrobras, IBM Brasil. Possui certificações como Scrum Master Certified, destacando-se pela capacidade de entregar soluções inovadoras e eficientes alinhadas às necessidades do negócio.'),
('Sofia Teixeira da Silva','sofia.teixeira.da.silva@gmail.com','+55 11 97206-2768','Engenharia de Software','3 anos como desenvolvedor backend','Profissional com 3 anos como desenvolvedor backend, aplicando tecnologias como JavaScript, Angular, Redis em projetos realizados em empresas como TOTVS, Mercado Livre. Possui certificações como Certified Kubernetes Administrator, AWS Certified Solutions Architect, destacando-se pela capacidade de entregar soluções inovadoras e eficientes alinhadas às necessidades do negócio.'),
('Lucas Ribeiro Pereira','lucas.ribeiro.pereira@exemplo.com','+55 11 91732-3024','Engenharia da Computação','5 anos como analista de dados','Profissional com 5 anos como analista de dados, aplicando tecnologias como Docker, MongoDB, Azure em projetos realizados em empresas como Petrobras, PagSeguro. Possui certificações como Scrum Master Certified, Google Cloud Professional Data Engineer, Certified Kubernetes Administrator, destacando-se pela capacidade de entregar soluções inovadoras e eficientes alinhadas às necessidades do negócio.'),
('Paula Moreira Pereira','paula.moreira.pereira@gmail.com','+55 11 99211-5498','Engenharia da Computação','4 anos como administrador de banco de dados','Profissional com 4 anos como administrador de banco de dados, aplicando tecnologias como React, Java, SQL em projetos realizados em empresas como TOTVS, IBM Brasil. Possui certificações como Certified Kubernetes Administrator, destacando-se pela capacidade de entregar soluções inovadoras e eficientes alinhadas às necessidades do negócio.'),
('Natália Andrade Ferreira','natália.andrade.ferreira@exemplo.com','+55 11 96397-7659','Engenharia da Computação','6 anos como desenvolvedor full stack','Profissional com 6 anos como desenvolvedor full stack, aplicando tecnologias como TensorFlow, Azure, Google Cloud em projetos realizados em empresas como Itaú Unibanco. Possui certificações como Google Cloud Professional Data Engineer, Certified Information Systems Security Professional (CISSP), destacando-se pela capacidade de entregar soluções inovadoras e eficientes alinhadas às necessidades do negócio.'),
('Henrique Ferreira Pereira','henrique.ferreira.pereira@exemplo.com','+55 11 96237-9686','Bacharelado em Ciência da Computação','3 anos como cientista de dados','Profissional com 3 anos como cientista de dados, aplicando tecnologias como MongoDB, Angular, Google Cloud em projetos realizados em empresas como Amazon Brasil, Petrobras. Possui certificações como AWS Certified Solutions Architect, destacando-se pela capacidade de entregar soluções inovadoras e eficientes alinhadas às necessidades do negócio.'),
('Diego Oliveira Pereira','diego.oliveira.pereira@exemplo.com','+55 11 98660-9779','Bacharelado em Sistemas de Informação','6 anos como desenvolvedor full stack','Profissional com 6 anos como desenvolvedor full stack, aplicando tecnologias como Node.js, SQL, MongoDB em projetos realizados em empresas como Itaú Unibanco. Possui certificações como Scrum Master Certified, AWS Certified Solutions Architect, destacando-se pela capacidade de entregar soluções inovadoras e eficientes alinhadas às necessidades do negócio.'),
('Isabela Costa Ferreira','isabela.costa.ferreira@exemplo.com','+55 11 97351-3959','Engenharia da Computação','3 anos como desenvolvedor backend','Profissional com 3 anos como desenvolvedor backend, aplicando tecnologias como C#, Spark, HTML em projetos realizados em empresas como Vale. Possui certificações como Scrum Master Certified, Certified Information Systems Security Professional (CISSP), Oracle Certified Professional, Java SE, destacando-se pela capacidade de entregar soluções inovadoras e eficientes alinhadas às necessidades do negócio.'),
('Henrique Ferreira Ferreira','henrique.ferreira.ferreira@outlook.com','+55 11 93764-1372','Bacharelado em Sistemas de Informação','3 anos como desenvolvedor backend','Profissional com 3 anos como desenvolvedor backend, aplicando tecnologias como Node.js, AWS, Java em projetos realizados em empresas como Globo.com, Itaú Unibanco. Possui certificações como Microsoft Certified: Azure Fundamentals, Oracle Certified Professional, Java SE, Certified Information Systems Security Professional (CISSP), destacando-se pela capacidade de entregar soluções inovadoras e eficientes alinhadas às necessidades do negócio.'),
('Sofia Teixeira Pereira','sofia.teixeira.pereira@exemplo.com','+55 11 93239-6571','Engenharia de Software','3 anos como desenvolvedor backend','Profissional com 3 anos como desenvolvedor backend, aplicando tecnologias como Redis, JavaScript, PyTorch em projetos realizados em empresas como Itaú Unibanco. Possui certificações como Google Cloud Professional Data Engineer, destacando-se pela capacidade de entregar soluções inovadoras e eficientes alinhadas às necessidades do negócio.'),
('Bruno Lima Pereira','bruno.lima.pereira@exemplo.com','+55 11 94895-6230','Engenharia de Software','5 anos como analista de dados','Profissional com 5 anos como analista de dados, aplicando tecnologias como Azure, Python, PyTorch em projetos realizados em empresas como IBM Brasil, Itaú Unibanco. Possui certificações como Microsoft Certified: Azure Fundamentals, destacando-se pela capacidade de entregar soluções inovadoras e eficientes alinhadas às necessidades do negócio.'),
('Henrique Ferreira Melo','henrique.ferreira.melo@exemplo.com','+55 11 91956-9574','Bacharelado em Ciência da Computação','5 anos como engenheiro de dados','Profissional com 5 anos como engenheiro de dados, aplicando tecnologias como Kubernetes, PyTorch, C# em projetos realizados em empresas como Nubank, Embraer. Possui certificações como Certified Information Systems Security Professional (CISSP), Google Cloud Professional Data Engineer, Scrum Master Certified, destacando-se pela capacidade de entregar soluções inovadoras e eficientes alinhadas às necessidades do negócio.'),
('Tiago Barros Melo','tiago.barros.melo@exemplo.com','+55 11 98356-3547','Bacharelado em Ciência da Computação','3 anos como desenvolvedor backend','Profissional com 3 anos como desenvolvedor backend, aplicando tecnologias como C#, MongoDB, CSS em projetos realizados em empresas como TOTVS, Google Brasil. Possui certificações como AWS Certified Solutions Architect, destacando-se pela capacidade de entregar soluções inovadoras e eficientes alinhadas às necessidades do negócio.'),
('Diego Oliveira Melo','diego.oliveira.melo@exemplo.com','+55 11 93195-4098','Engenharia da Computação','2 anos como especialista em segurança da informação','Profissional com 2 anos como especialista em segurança da informação, aplicando tecnologias como TensorFlow, NoSQL, Spark em projetos realizados em empresas como Google Brasil, Amazon Brasil. Possui certificações como Certified Kubernetes Administrator, destacando-se pela capacidade de entregar soluções inovadoras e eficientes alinhadas às necessidades do negócio.'),
('Ana Souza da Silva','ana.souza.da.silva@exemplo.com','+55 11 94560-3746','Tecnólogo em Análise e Desenvolvimento de Sistemas','3 anos como cientista de dados','Profissional com 3 anos como cientista de dados, aplicando tecnologias como TensorFlow, React, Azure em projetos realizados em empresas como Nubank, Mercado Livre. Possui certificações como AWS Certified Solutions Architect, destacando-se pela capacidade de entregar soluções inovadoras e eficientes alinhadas às necessidades do negócio.'),
('Natália Andrade da Silva','natália.andrade.da.silva@exemplo.com','+55 11 97249-4169','Engenharia da Computação','5 anos como engenheiro de dados','Profissional com 5 anos como engenheiro de dados, aplicando tecnologias como Redis, PostgreSQL, AWS em projetos realizados em empresas como Itaú Unibanco, Petrobras. Possui certificações como Google Cloud Professional Data Engineer, destacando-se pela capacidade de entregar soluções inovadoras e eficientes alinhadas às necessidades do negócio.'),
('Eduarda Rocha Pereira','eduarda.rocha.pereira@gmail.com','+55 11 93031-8540','Tecnólogo em Análise e Desenvolvimento de Sistemas','6 anos como desenvolvedor full stack','Profissional com 6 anos como desenvolvedor full stack, aplicando tecnologias como Kubernetes, HTML, CSS em projetos realizados em empresas como Itaú Unibanco, IBM Brasil. Possui certificações como AWS Certified Solutions Architect, Google Cloud Professional Data Engineer, Certified Kubernetes Administrator, destacando-se pela capacidade de entregar soluções inovadoras e eficientes alinhadas às necessidades do negócio.'),
('Paula Moreira da Silva','paula.moreira.da.silva@exemplo.com','+55 11 94386-9714','Tecnólogo em Análise e Desenvolvimento de Sistemas','5 anos como engenheiro de dados','Profissional com 5 anos como engenheiro de dados, aplicando tecnologias como MongoDB, Google Cloud, NoSQL em projetos realizados em empresas como PagSeguro. Possui certificações como Oracle Certified Professional, Java SE, AWS Certified Solutions Architect, destacando-se pela capacidade de entregar soluções inovadoras e eficientes alinhadas às necessidades do negócio.'),
('João Pereira Melo','joão.pereira.melo@exemplo.com','+55 11 93776-7327','Engenharia da Computação','2 anos como engenheiro de software','Profissional com 2 anos como engenheiro de software, aplicando tecnologias como Angular, HTML, Redis em projetos realizados em empresas como Embraer, Amazon Brasil. Possui certificações como Certified Information Systems Security Professional (CISSP), destacando-se pela capacidade de entregar soluções inovadoras e eficientes alinhadas às necessidades do negócio.'),
('Henrique Ferreira Melo','henrique.ferreira.melo@outlook.com','+55 11 96049-9944','Tecnólogo em Análise e Desenvolvimento de Sistemas','6 anos como desenvolvedor full stack','Profissional com 6 anos como desenvolvedor full stack, aplicando tecnologias como PostgreSQL, JavaScript, TensorFlow em projetos realizados em empresas como IBM Brasil, Amazon Brasil. Possui certificações como Certified Information Systems Security Professional (CISSP), Scrum Master Certified, destacando-se pela capacidade de entregar soluções inovadoras e eficientes alinhadas às necessidades do negócio.'),
('Vanessa Lima Santos','vanessa.lima.santos@exemplo.com','+55 11 95849-1176','Tecnólogo em Análise e Desenvolvimento de Sistemas','2 anos como especialista em segurança da informação','Profissional com 2 anos como especialista em segurança da informação, aplicando tecnologias como CSS, HTML, React em projetos realizados em empresas como Amazon Brasil, Nubank. Possui certificações como Certified Kubernetes Administrator, destacando-se pela capacidade de entregar soluções inovadoras e eficientes alinhadas às necessidades do negócio.'),
('Karen Martins Melo','karen.martins.melo@exemplo.com','+55 11 93234-4805','Engenharia de Software','3 anos como desenvolvedor backend','Profissional com 3 anos como desenvolvedor backend, aplicando tecnologias como Java, SQL, NoSQL em projetos realizados em empresas como Embraer, Amazon Brasil. Possui certificações como Microsoft Certified: Azure Fundamentals, Certified Kubernetes Administrator, destacando-se pela capacidade de entregar soluções inovadoras e eficientes alinhadas às necessidades do negócio.'),
('Otávio Carvalho da Silva','otávio.carvalho.da.silva@exemplo.com','+55 11 98045-5074','Bacharelado em Sistemas de Informação','3 anos como cientista de dados','Profissional com 3 anos como cientista de dados, aplicando tecnologias como Redis, HTML, Python em projetos realizados em empresas como Petrobras, Globo.com. Possui certificações como Microsoft Certified: Azure Fundamentals, Certified Information Systems Security Professional (CISSP), destacando-se pela capacidade de entregar soluções inovadoras e eficientes alinhadas às necessidades do negócio.'),
('Lucas Ribeiro Pereira','lucas.ribeiro.pereira@yahoo.com','+55 11 95240-3875','Bacharelado em Sistemas de Informação','2 anos como engenheiro de software','Profissional com 2 anos como engenheiro de software, aplicando tecnologias como JavaScript, Java, CSS em projetos realizados em empresas como TOTVS, PagSeguro. Possui certificações como Google Cloud Professional Data Engineer, Scrum Master Certified, destacando-se pela capacidade de entregar soluções inovadoras e eficientes alinhadas às necessidades do negócio.'),
('Carla Mendes Melo','carla.mendes.melo@exemplo.com','+55 11 94826-7912','Engenharia de Software','5 anos como engenheiro de dados','Profissional com 5 anos como engenheiro de dados, aplicando tecnologias como SQL, Java, TensorFlow em projetos realizados em empresas como Petrobras. Possui certificações como AWS Certified Solutions Architect, Oracle Certified Professional, Java SE, Google Cloud Professional Data Engineer, destacando-se pela capacidade de entregar soluções inovadoras e eficientes alinhadas às necessidades do negócio.'),
('Felipe Alves da Silva','felipe.alves.da.silva@exemplo.com','+55 11 91244-5835','Bacharelado em Ciência da Computação','6 anos como desenvolvedor full stack','Profissional com 6 anos como desenvolvedor full stack, aplicando tecnologias como AWS, Hadoop, PyTorch em projetos realizados em empresas como Amazon Brasil, Google Brasil. Possui certificações como Microsoft Certified: Azure Fundamentals, AWS Certified Solutions Architect, Google Cloud Professional Data Engineer, destacando-se pela capacidade de entregar soluções inovadoras e eficientes alinhadas às necessidades do negócio.'),
('Ricardo Nunes Melo','ricardo.nunes.melo@yahoo.com','+55 11 92259-1968','Engenharia da Computação','2 anos como especialista em segurança da informação','Profissional com 2 anos como especialista em segurança da informação, aplicando tecnologias como MongoDB, NoSQL, CSS em projetos realizados em empresas como TOTVS. Possui certificações como Certified Kubernetes Administrator, AWS Certified Solutions Architect, Google Cloud Professional Data Engineer, destacando-se pela capacidade de entregar soluções inovadoras e eficientes alinhadas às necessidades do negócio.'),
('Karen Martins da Silva','karen.martins.da.silva@exemplo.com','+55 11 94862-9191','Engenharia de Software','3 anos como cientista de dados','Profissional com 3 anos como cientista de dados, aplicando tecnologias como Redis, NoSQL, SQL em projetos realizados em empresas como Google Brasil. Possui certificações como Certified Kubernetes Administrator, Microsoft Certified: Azure Fundamentals, AWS Certified Solutions Architect, destacando-se pela capacidade de entregar soluções inovadoras e eficientes alinhadas às necessidades do negócio.'),
('Ana Souza Melo','ana.souza.melo@exemplo.com','+55 11 94335-3009','Bacharelado em Ciência da Computação','2 anos como especialista em segurança da informação','Profissional com 2 anos como especialista em segurança da informação, aplicando tecnologias como Node.js, MySQL, Angular em projetos realizados em empresas como Embraer, PagSeguro. Possui certificações como Microsoft Certified: Azure Fundamentals, destacando-se pela capacidade de entregar soluções inovadoras e eficientes alinhadas às necessidades do negócio.'),
('Ricardo Nunes da Silva','ricardo.nunes.da.silva@exemplo.com','+55 11 97368-7688','Bacharelado em Sistemas de Informação','3 anos como desenvolvedor backend','Profissional com 3 anos como desenvolvedor backend, aplicando tecnologias como Kubernetes, CSS, Docker em projetos realizados em empresas como IBM Brasil. Possui certificações como Certified Kubernetes Administrator, Google Cloud Professional Data Engineer, Certified Information Systems Security Professional (CISSP), destacando-se pela capacidade de entregar soluções inovadoras e eficientes alinhadas às necessidades do negócio.'),
('Paula Moreira Santos','paula.moreira.santos@exemplo.com','+55 11 94818-5920','Engenharia de Software','6 anos como desenvolvedor full stack','Profissional com 6 anos como desenvolvedor full stack, aplicando tecnologias como Kubernetes, MongoDB, Java em projetos realizados em empresas como Amazon Brasil, Globo.com. Possui certificações como Google Cloud Professional Data Engineer, Oracle Certified Professional, Java SE, Certified Kubernetes Administrator, destacando-se pela capacidade de entregar soluções inovadoras e eficientes alinhadas às necessidades do negócio.'),
('Lucas Ribeiro da Silva','lucas.ribeiro.da.silva@exemplo.com','+55 11 93145-9025','Bacharelado em Sistemas de Informação','5 anos como analista de dados','Profissional com 5 anos como analista de dados, aplicando tecnologias como Python, Google Cloud, Vue.js em projetos realizados em empresas como IBM Brasil, Vale. Possui certificações como AWS Certified Solutions Architect, Google Cloud Professional Data Engineer, destacando-se pela capacidade de entregar soluções inovadoras e eficientes alinhadas às necessidades do negócio.'),
('Henrique Ferreira Santos','henrique.ferreira.santos@gmail.com','+55 11 97800-3596','Tecnólogo em Análise e Desenvolvimento de Sistemas','4 anos como administrador de banco de dados','Profissional com 4 anos como administrador de banco de dados, aplicando tecnologias como Redis, NoSQL, Google Cloud em projetos realizados em empresas como TOTVS, Embraer. Possui certificações como Google Cloud Professional Data Engineer, Certified Kubernetes Administrator, Certified Information Systems Security Professional (CISSP), destacando-se pela capacidade de entregar soluções inovadoras e eficientes alinhadas às necessidades do negócio.'),
('Tiago Barros Pereira','tiago.barros.pereira@exemplo.com','+55 11 99154-8917','Tecnólogo em Análise e Desenvolvimento de Sistemas','4 anos como administrador de banco de dados','Profissional com 4 anos como administrador de banco de dados, aplicando tecnologias como PostgreSQL, HTML, Node.js em projetos realizados em empresas como Vale. Possui certificações como Certified Information Systems Security Professional (CISSP), destacando-se pela capacidade de entregar soluções inovadoras e eficientes alinhadas às necessidades do negócio.'),
('Mariana Gomes Melo','mariana.gomes.melo@exemplo.com','+55 11 93011-6948','Bacharelado em Ciência da Computação','5 anos como analista de dados','Profissional com 5 anos como analista de dados, aplicando tecnologias como JavaScript, AWS, C# em projetos realizados em empresas como PagSeguro, Google Brasil. Possui certificações como Microsoft Certified: Azure Fundamentals, Google Cloud Professional Data Engineer, Oracle Certified Professional, Java SE, destacando-se pela capacidade de entregar soluções inovadoras e eficientes alinhadas às necessidades do negócio.'),
('Vanessa Lima Pereira','vanessa.lima.pereira@exemplo.com','+55 11 98888-9417','Engenharia da Computação','3 anos como cientista de dados','Profissional com 3 anos como cientista de dados, aplicando tecnologias como Hadoop, C#, Spark em projetos realizados em empresas como PagSeguro, Globo.com. Possui certificações como Certified Information Systems Security Professional (CISSP), Oracle Certified Professional, Java SE, destacando-se pela capacidade de entregar soluções inovadoras e eficientes alinhadas às necessidades do negócio.'),
('Ana Souza Santos','ana.souza.santos@exemplo.com','+55 11 98422-8597','Bacharelado em Ciência da Computação','4 anos como administrador de banco de dados','Profissional com 4 anos como administrador de banco de dados, aplicando tecnologias como Redis, C#, Angular em projetos realizados em empresas como IBM Brasil, Nubank. Possui certificações como Oracle Certified Professional, Java SE, AWS Certified Solutions Architect, destacando-se pela capacidade de entregar soluções inovadoras e eficientes alinhadas às necessidades do negócio.'),
('Henrique Ferreira da Silva','henrique.ferreira.da.silva@exemplo.com','+55 11 96502-6235','Tecnólogo em Análise e Desenvolvimento de Sistemas','2 anos como engenheiro de software','Profissional com 2 anos como engenheiro de software, aplicando tecnologias como PyTorch, SQL, Google Cloud em projetos realizados em empresas como Embraer. Possui certificações como Google Cloud Professional Data Engineer, Microsoft Certified: Azure Fundamentals, Oracle Certified Professional, Java SE, destacando-se pela capacidade de entregar soluções inovadoras e eficientes alinhadas às necessidades do negócio.'),
('Felipe Alves da Silva','felipe.alves.da.silva@globo.com','+55 11 94434-3295','Engenharia da Computação','4 anos como administrador de banco de dados','Profissional com 4 anos como administrador de banco de dados, aplicando tecnologias como Node.js, MongoDB, JavaScript em projetos realizados em empresas como Amazon Brasil, Petrobras. Possui certificações como Oracle Certified Professional, Java SE, AWS Certified Solutions Architect, Scrum Master Certified, destacando-se pela capacidade de entregar soluções inovadoras e eficientes alinhadas às necessidades do negócio.'),
('João Pereira Ferreira','joão.pereira.ferreira@exemplo.com','+55 11 98239-6282','Tecnólogo em Análise e Desenvolvimento de Sistemas','3 anos como desenvolvedor backend','Profissional com 3 anos como desenvolvedor backend, aplicando tecnologias como PostgreSQL, Redis, Google Cloud em projetos realizados em empresas como Mercado Livre, Vale. Possui certificações como Oracle Certified Professional, Java SE, Certified Kubernetes Administrator, destacando-se pela capacidade de entregar soluções inovadoras e eficientes alinhadas às necessidades do negócio.'),
('Paula Moreira Melo','paula.moreira.melo@exemplo.com','+55 11 91453-7238','Bacharelado em Sistemas de Informação','3 anos como desenvolvedor backend','Profissional com 3 anos como desenvolvedor backend, aplicando tecnologias como Docker, Redis, CSS em projetos realizados em empresas como Petrobras. Possui certificações como Scrum Master Certified, Google Cloud Professional Data Engineer, destacando-se pela capacidade de entregar soluções inovadoras e eficientes alinhadas às necessidades do negócio.'),
('Tiago Barros Pereira','tiago.barros.pereira@outlook.com','+55 11 95855-3381','Bacharelado em Ciência da Computação','3 anos como desenvolvedor backend','Profissional com 3 anos como desenvolvedor backend, aplicando tecnologias como MySQL, AWS, Python em projetos realizados em empresas como Google Brasil. Possui certificações como Google Cloud Professional Data Engineer, Certified Information Systems Security Professional (CISSP), destacando-se pela capacidade de entregar soluções inovadoras e eficientes alinhadas às necessidades do negócio.'),
('Mariana Gomes Pereira','mariana.gomes.pereira@exemplo.com','+55 11 99333-4957','Engenharia de Software','5 anos como engenheiro de dados','Profissional com 5 anos como engenheiro de dados, aplicando tecnologias como AWS, Azure, Spark em projetos realizados em empresas como Microsoft Brasil, Petrobras. Possui certificações como Certified Information Systems Security Professional (CISSP), Oracle Certified Professional, Java SE, destacando-se pela capacidade de entregar soluções inovadoras e eficientes alinhadas às necessidades do negócio.'),
('Paula Moreira Melo','paula.moreira.melo@hotmail.com','+55 11 92244-4117','Engenharia da Computação','6 anos como desenvolvedor full stack','Profissional com 6 anos como desenvolvedor full stack, aplicando tecnologias como Java, MySQL, SQL em projetos realizados em empresas como PagSeguro, Vale. Possui certificações como Oracle Certified Professional, Java SE, Certified Information Systems Security Professional (CISSP), Microsoft Certified: Azure Fundamentals, destacando-se pela capacidade de entregar soluções inovadoras e eficientes alinhadas às necessidades do negócio.'),
('Tiago Barros da Silva','tiago.barros.da.silva@exemplo.com','+55 11 97488-8663','Bacharelado em Ciência da Computação','4 anos como administrador de banco de dados','Profissional com 4 anos como administrador de banco de dados, aplicando tecnologias como Python, MongoDB, NoSQL em projetos realizados em empresas como Globo.com. Possui certificações como Microsoft Certified: Azure Fundamentals, Google Cloud Professional Data Engineer, destacando-se pela capacidade de entregar soluções inovadoras e eficientes alinhadas às necessidades do negócio.'),
('Vanessa Lima Santos','vanessa.lima.santos@outlook.com','+55 11 96478-3872','Engenharia da Computação','5 anos como analista de dados','Profissional com 5 anos como analista de dados, aplicando tecnologias como Kubernetes, NoSQL, TensorFlow em projetos realizados em empresas como Microsoft Brasil. Possui certificações como Microsoft Certified: Azure Fundamentals, Certified Information Systems Security Professional (CISSP), Oracle Certified Professional, Java SE, destacando-se pela capacidade de entregar soluções inovadoras e eficientes alinhadas às necessidades do negócio.'),
('Henrique Ferreira Ferreira','henrique.ferreira.ferreira@gmail.com','+55 11 98717-2684','Engenharia da Computação','5 anos como analista de dados','Profissional com 5 anos como analista de dados, aplicando tecnologias como HTML, Node.js, PostgreSQL em projetos realizados em empresas como Vale. Possui certificações como Microsoft Certified: Azure Fundamentals, Oracle Certified Professional, Java SE, Certified Information Systems Security Professional (CISSP), destacando-se pela capacidade de entregar soluções inovadoras e eficientes alinhadas às necessidades do negócio.'),
('Ricardo Nunes Pereira','ricardo.nunes.pereira@exemplo.com','+55 11 99824-4662','Engenharia da Computação','3 anos como desenvolvedor backend','Profissional com 3 anos como desenvolvedor backend, aplicando tecnologias como PostgreSQL, TensorFlow, Azure em projetos realizados em empresas como Mercado Livre, Petrobras. Possui certificações como Certified Kubernetes Administrator, AWS Certified Solutions Architect, Google Cloud Professional Data Engineer, destacando-se pela capacidade de entregar soluções inovadoras e eficientes alinhadas às necessidades do negócio.'),
('Carla Mendes Ferreira','carla.mendes.ferreira@exemplo.com','+55 11 99869-1274','Tecnólogo em Análise e Desenvolvimento de Sistemas','2 anos como especialista em segurança da informação','Profissional com 2 anos como especialista em segurança da informação, aplicando tecnologias como PyTorch, Vue.js, MongoDB em projetos realizados em empresas como IBM Brasil, Globo.com. Possui certificações como Oracle Certified Professional, Java SE, Certified Information Systems Security Professional (CISSP), Google Cloud Professional Data Engineer, destacando-se pela capacidade de entregar soluções inovadoras e eficientes alinhadas às necessidades do negócio.'),
('João Pereira Ferreira','joão.pereira.ferreira@hotmail.com','+55 11 94260-3799','Tecnólogo em Análise e Desenvolvimento de Sistemas','5 anos como analista de dados','Profissional com 5 anos como analista de dados, aplicando tecnologias como JavaScript, Angular, MongoDB em projetos realizados em empresas como PagSeguro, Itaú Unibanco. Possui certificações como AWS Certified Solutions Architect, Scrum Master Certified, destacando-se pela capacidade de entregar soluções inovadoras e eficientes alinhadas às necessidades do negócio.'),
('João Pereira da Silva','joão.pereira.da.silva@globo.com','+55 11 94470-2459','Engenharia da Computação','2 anos como especialista em segurança da informação','Profissional com 2 anos como especialista em segurança da informação, aplicando tecnologias como Redis, Google Cloud, TensorFlow em projetos realizados em empresas como Globo.com, IBM Brasil. Possui certificações como Google Cloud Professional Data Engineer, Certified Kubernetes Administrator, Scrum Master Certified, destacando-se pela capacidade de entregar soluções inovadoras e eficientes alinhadas às necessidades do negócio.'),
('Mariana Gomes da Silva','mariana.gomes.da.silva@exemplo.com','+55 11 91885-5354','Engenharia da Computação','4 anos como administrador de banco de dados','Profissional com 4 anos como administrador de banco de dados, aplicando tecnologias como CSS, TensorFlow, Kubernetes em projetos realizados em empresas como Petrobras, Vale. Possui certificações como AWS Certified Solutions Architect, Google Cloud Professional Data Engineer, destacando-se pela capacidade de entregar soluções inovadoras e eficientes alinhadas às necessidades do negócio.'),
('Eduarda Rocha da Silva','eduarda.rocha.da.silva@exemplo.com','+55 11 97137-3569','Bacharelado em Ciência da Computação','2 anos como engenheiro de software','Profissional com 2 anos como engenheiro de software, aplicando tecnologias como PyTorch, Azure, AWS em projetos realizados em empresas como Embraer, TOTVS. Possui certificações como AWS Certified Solutions Architect, Oracle Certified Professional, Java SE, destacando-se pela capacidade de entregar soluções inovadoras e eficientes alinhadas às necessidades do negócio.'),
('Ricardo Nunes Ferreira','ricardo.nunes.ferreira@exemplo.com','+55 11 91932-8205','Tecnólogo em Análise e Desenvolvimento de Sistemas','2 anos como especialista em segurança da informação','Profissional com 2 anos como especialista em segurança da informação, aplicando tecnologias como PostgreSQL, MongoDB, AWS em projetos realizados em empresas como Vale, Amazon Brasil. Possui certificações como AWS Certified Solutions Architect, Certified Kubernetes Administrator, Google Cloud Professional Data Engineer, destacando-se pela capacidade de entregar soluções inovadoras e eficientes alinhadas às necessidades do negócio.'),
('Sofia Teixeira Pereira','sofia.teixeira.pereira@gmail.com','+55 11 99289-6288','Bacharelado em Sistemas de Informação','5 anos como analista de dados','Profissional com 5 anos como analista de dados, aplicando tecnologias como AWS, Spark, Python em projetos realizados em empresas como Embraer. Possui certificações como Google Cloud Professional Data Engineer, destacando-se pela capacidade de entregar soluções inovadoras e eficientes alinhadas às necessidades do negócio.'),
('Paula Moreira Pereira','paula.moreira.pereira@yahoo.com','+55 11 98033-7726','Bacharelado em Ciência da Computação','2 anos como engenheiro de software','Profissional com 2 anos como engenheiro de software, aplicando tecnologias como PyTorch, MongoDB, MySQL em projetos realizados em empresas como Itaú Unibanco. Possui certificações como Microsoft Certified: Azure Fundamentals, destacando-se pela capacidade de entregar soluções inovadoras e eficientes alinhadas às necessidades do negócio.'),
('Lucas Ribeiro Santos','lucas.ribeiro.santos@exemplo.com','+55 11 98496-1304','Engenharia da Computação','6 anos como desenvolvedor full stack','Profissional com 6 anos como desenvolvedor full stack, aplicando tecnologias como NoSQL, Google Cloud, Spark em projetos realizados em empresas como Vale, Nubank. Possui certificações como Microsoft Certified: Azure Fundamentals, Google Cloud Professional Data Engineer, destacando-se pela capacidade de entregar soluções inovadoras e eficientes alinhadas às necessidades do negócio.'),
('Carla Mendes da Silva','carla.mendes.da.silva@gmail.com','+55 11 94868-9830','Engenharia de Software','2 anos como especialista em segurança da informação','Profissional com 2 anos como especialista em segurança da informação, aplicando tecnologias como Google Cloud, Redis, MySQL em projetos realizados em empresas como Globo.com, Vale. Possui certificações como Certified Kubernetes Administrator, AWS Certified Solutions Architect, destacando-se pela capacidade de entregar soluções inovadoras e eficientes alinhadas às necessidades do negócio.'),
('Ana Souza Santos','ana.souza.santos@gmail.com','+55 11 99668-7522','Bacharelado em Sistemas de Informação','5 anos como engenheiro de dados','Profissional com 5 anos como engenheiro de dados, aplicando tecnologias como HTML, CSS, Spark em projetos realizados em empresas como Embraer, PagSeguro. Possui certificações como Google Cloud Professional Data Engineer, Oracle Certified Professional, Java SE, destacando-se pela capacidade de entregar soluções inovadoras e eficientes alinhadas às necessidades do negócio.'),
('Ana Souza Pereira','ana.souza.pereira@exemplo.com','+55 11 97599-3377','Bacharelado em Sistemas de Informação','4 anos como administrador de banco de dados','Profissional com 4 anos como administrador de banco de dados, aplicando tecnologias como Hadoop, Docker, Angular em projetos realizados em empresas como Amazon Brasil. Possui certificações como Google Cloud Professional Data Engineer, Scrum Master Certified, Microsoft Certified: Azure Fundamentals, destacando-se pela capacidade de entregar soluções inovadoras e eficientes alinhadas às necessidades do negócio.'),
('Isabela Costa Ferreira','isabela.costa.ferreira@globo.com','+55 11 97440-4624','Tecnólogo em Análise e Desenvolvimento de Sistemas','5 anos como analista de dados','Profissional com 5 anos como analista de dados, aplicando tecnologias como MongoDB, Spark, Redis em projetos realizados em empresas como Microsoft Brasil, Mercado Livre. Possui certificações como Microsoft Certified: Azure Fundamentals, Oracle Certified Professional, Java SE, destacando-se pela capacidade de entregar soluções inovadoras e eficientes alinhadas às necessidades do negócio.'),
('Natália Andrade da Silva','natália.andrade.da.silva@yahoo.com','+55 11 93364-8190','Bacharelado em Sistemas de Informação','3 anos como desenvolvedor backend','Profissional com 3 anos como desenvolvedor backend, aplicando tecnologias como AWS, Node.js, Redis em projetos realizados em empresas como Google Brasil. Possui certificações como Scrum Master Certified, Microsoft Certified: Azure Fundamentals, destacando-se pela capacidade de entregar soluções inovadoras e eficientes alinhadas às necessidades do negócio.'),
('Otávio Carvalho Melo','otávio.carvalho.melo@exemplo.com','+55 11 92428-7368','Bacharelado em Sistemas de Informação','2 anos como engenheiro de software','Profissional com 2 anos como engenheiro de software, aplicando tecnologias como Kubernetes, Hadoop, Azure em projetos realizados em empresas como Google Brasil, Nubank. Possui certificações como Certified Kubernetes Administrator, Microsoft Certified: Azure Fundamentals, destacando-se pela capacidade de entregar soluções inovadoras e eficientes alinhadas às necessidades do negócio.'),
('Vanessa Lima Melo','vanessa.lima.melo@gmail.com','+55 11 94998-4700','Bacharelado em Sistemas de Informação','2 anos como engenheiro de software','Profissional com 2 anos como engenheiro de software, aplicando tecnologias como MongoDB, Node.js, NoSQL em projetos realizados em empresas como Nubank, Amazon Brasil. Possui certificações como Certified Kubernetes Administrator, Scrum Master Certified, AWS Certified Solutions Architect, destacando-se pela capacidade de entregar soluções inovadoras e eficientes alinhadas às necessidades do negócio.'),
('Vanessa Lima Melo','vanessa.lima.melo@exemplo.com','+55 11 92149-4781','Bacharelado em Ciência da Computação','3 anos como cientista de dados','Profissional com 3 anos como cientista de dados, aplicando tecnologias como Java, CSS, C# em projetos realizados em empresas como Itaú Unibanco, PagSeguro. Possui certificações como Certified Kubernetes Administrator, Scrum Master Certified, destacando-se pela capacidade de entregar soluções inovadoras e eficientes alinhadas às necessidades do negócio.'),
('Karen Martins Santos','karen.martins.santos@exemplo.com','+55 11 98660-6243','Engenharia da Computação','2 anos como engenheiro de software','Profissional com 2 anos como engenheiro de software, aplicando tecnologias como HTML, Google Cloud, PostgreSQL em projetos realizados em empresas como IBM Brasil. Possui certificações como Microsoft Certified: Azure Fundamentals, Certified Information Systems Security Professional (CISSP), Certified Kubernetes Administrator, destacando-se pela capacidade de entregar soluções inovadoras e eficientes alinhadas às necessidades do negócio.'),
('Paula Moreira da Silva','paula.moreira.da.silva@globo.com','+55 11 93074-7982','Engenharia da Computação','4 anos como administrador de banco de dados','Profissional com 4 anos como administrador de banco de dados, aplicando tecnologias como NoSQL, Angular, Spark em projetos realizados em empresas como Petrobras. Possui certificações como Oracle Certified Professional, Java SE, destacando-se pela capacidade de entregar soluções inovadoras e eficientes alinhadas às necessidades do negócio.'),
('Henrique Ferreira Santos','henrique.ferreira.santos@hotmail.com','+55 11 92275-6370','Engenharia de Software','2 anos como especialista em segurança da informação','Profissional com 2 anos como especialista em segurança da informação, aplicando tecnologias como PostgreSQL, Google Cloud, Azure em projetos realizados em empresas como Nubank. Possui certificações como Oracle Certified Professional, Java SE, destacando-se pela capacidade de entregar soluções inovadoras e eficientes alinhadas às necessidades do negócio.'),
('Isabela Costa Pereira','isabela.costa.pereira@exemplo.com','+55 11 97689-4004','Engenharia da Computação','2 anos como engenheiro de software','Profissional com 2 anos como engenheiro de software, aplicando tecnologias como Angular, Vue.js, Python em projetos realizados em empresas como Vale. Possui certificações como Google Cloud Professional Data Engineer, destacando-se pela capacidade de entregar soluções inovadoras e eficientes alinhadas às necessidades do negócio.'),
('Eduarda Rocha Santos','eduarda.rocha.santos@exemplo.com','+55 11 98193-5182','Bacharelado em Sistemas de Informação','3 anos como cientista de dados','Profissional com 3 anos como cientista de dados, aplicando tecnologias como Spark, Node.js, SQL em projetos realizados em empresas como Google Brasil. Possui certificações como Microsoft Certified: Azure Fundamentals, Certified Information Systems Security Professional (CISSP), destacando-se pela capacidade de entregar soluções inovadoras e eficientes alinhadas às necessidades do negócio.'),
('Henrique Ferreira Santos','henrique.ferreira.santos@yahoo.com','+55 11 93500-2014','Bacharelado em Sistemas de Informação','2 anos como engenheiro de software','Profissional com 2 anos como engenheiro de software, aplicando tecnologias como Node.js, SQL, React em projetos realizados em empresas como Globo.com, Amazon Brasil. Possui certificações como Certified Information Systems Security Professional (CISSP), destacando-se pela capacidade de entregar soluções inovadoras e eficientes alinhadas às necessidades do negócio.'),
('Vanessa Lima Melo','vanessa.lima.melo@hotmail.com','+55 11 95895-6846','Tecnólogo em Análise e Desenvolvimento de Sistemas','4 anos como administrador de banco de dados','Profissional com 4 anos como administrador de banco de dados, aplicando tecnologias como Kubernetes, Azure, Java em projetos realizados em empresas como Itaú Unibanco, Amazon Brasil. Possui certificações como Scrum Master Certified, Microsoft Certified: Azure Fundamentals, Certified Information Systems Security Professional (CISSP), destacando-se pela capacidade de entregar soluções inovadoras e eficientes alinhadas às necessidades do negócio.'),
('Sofia Teixeira Santos','sofia.teixeira.santos@exemplo.com','+55 11 91064-2664','Bacharelado em Sistemas de Informação','2 anos como engenheiro de software','Profissional com 2 anos como engenheiro de software, aplicando tecnologias como MongoDB, Java, MySQL em projetos realizados em empresas como Nubank. Possui certificações como Certified Information Systems Security Professional (CISSP), destacando-se pela capacidade de entregar soluções inovadoras e eficientes alinhadas às necessidades do negócio.'),
('Paula Moreira Pereira','paula.moreira.pereira@outlook.com','+55 11 97257-8798','Tecnólogo em Análise e Desenvolvimento de Sistemas','2 anos como especialista em segurança da informação','Profissional com 2 anos como especialista em segurança da informação, aplicando tecnologias como Azure, Vue.js, HTML em projetos realizados em empresas como Google Brasil, Vale. Possui certificações como Certified Information Systems Security Professional (CISSP), destacando-se pela capacidade de entregar soluções inovadoras e eficientes alinhadas às necessidades do negócio.'),
('Henrique Ferreira Pereira','henrique.ferreira.pereira@hotmail.com','+55 11 93616-6201','Engenharia da Computação','5 anos como analista de dados','Profissional com 5 anos como analista de dados, aplicando tecnologias como Angular, C#, PostgreSQL em projetos realizados em empresas como Petrobras. Possui certificações como Google Cloud Professional Data Engineer, Scrum Master Certified, Microsoft Certified: Azure Fundamentals, destacando-se pela capacidade de entregar soluções inovadoras e eficientes alinhadas às necessidades do negócio.'),
('Otávio Carvalho Ferreira','otávio.carvalho.ferreira@exemplo.com','+55 11 95389-9831','Engenharia de Software','5 anos como analista de dados','Profissional com 5 anos como analista de dados, aplicando tecnologias como React, Kubernetes, Node.js em projetos realizados em empresas como Globo.com, Nubank. Possui certificações como Google Cloud Professional Data Engineer, Certified Kubernetes Administrator, Oracle Certified Professional, Java SE, destacando-se pela capacidade de entregar soluções inovadoras e eficientes alinhadas às necessidades do negócio.'),
('Gabriela Santos Santos','gabriela.santos.santos@exemplo.com','+55 11 97719-8994','Bacharelado em Sistemas de Informação','5 anos como analista de dados','Profissional com 5 anos como analista de dados, aplicando tecnologias como JavaScript, Python, PostgreSQL em projetos realizados em empresas como Vale, TOTVS. Possui certificações como Microsoft Certified: Azure Fundamentals, Scrum Master Certified, destacando-se pela capacidade de entregar soluções inovadoras e eficientes alinhadas às necessidades do negócio.'),
('João Pereira Ferreira','joão.pereira.ferreira@outlook.com','+55 11 98184-3525','Bacharelado em Sistemas de Informação','3 anos como desenvolvedor backend','Profissional com 3 anos como desenvolvedor backend, aplicando tecnologias como PostgreSQL, JavaScript, MongoDB em projetos realizados em empresas como PagSeguro, Nubank. Possui certificações como Scrum Master Certified, destacando-se pela capacidade de entregar soluções inovadoras e eficientes alinhadas às necessidades do negócio.'),
('Ricardo Nunes Melo','ricardo.nunes.melo@globo.com','+55 11 92686-1635','Tecnólogo em Análise e Desenvolvimento de Sistemas','5 anos como engenheiro de dados','Profissional com 5 anos como engenheiro de dados, aplicando tecnologias como CSS, SQL, React em projetos realizados em empresas como Google Brasil. Possui certificações como Certified Information Systems Security Professional (CISSP), Oracle Certified Professional, Java SE, Certified Kubernetes Administrator, destacando-se pela capacidade de entregar soluções inovadoras e eficientes alinhadas às necessidades do negócio.'),
('Ana Souza da Silva','ana.souza.da.silva@gmail.com','+55 11 94327-1896','Engenharia da Computação','2 anos como especialista em segurança da informação','Profissional com 2 anos como especialista em segurança da informação, aplicando tecnologias como MongoDB, Node.js, PyTorch em projetos realizados em empresas como Globo.com, PagSeguro. Possui certificações como Certified Kubernetes Administrator, destacando-se pela capacidade de entregar soluções inovadoras e eficientes alinhadas às necessidades do negócio.'),
('Eduarda Rocha Santos','eduarda.rocha.santos@hotmail.com','+55 11 99181-7251','Bacharelado em Ciência da Computação','6 anos como desenvolvedor full stack','Profissional com 6 anos como desenvolvedor full stack, aplicando tecnologias como JavaScript, HTML, Node.js em projetos realizados em empresas como Microsoft Brasil, Petrobras. Possui certificações como Google Cloud Professional Data Engineer, Certified Kubernetes Administrator, destacando-se pela capacidade de entregar soluções inovadoras e eficientes alinhadas às necessidades do negócio.'),
('Felipe Alves Melo','felipe.alves.melo@exemplo.com','+55 11 93763-3865','Engenharia da Computação','3 anos como cientista de dados','Profissional com 3 anos como cientista de dados, aplicando tecnologias como SQL, Node.js, Java em projetos realizados em empresas como IBM Brasil, Embraer. Possui certificações como Certified Information Systems Security Professional (CISSP), destacando-se pela capacidade de entregar soluções inovadoras e eficientes alinhadas às necessidades do negócio.'),
('Vanessa Lima Santos','vanessa.lima.santos@ig.com','+55 11 95591-4903','Bacharelado em Sistemas de Informação','2 anos como engenheiro de software','Profissional com 2 anos como engenheiro de software, aplicando tecnologias como CSS, Java, PyTorch em projetos realizados em empresas como TOTVS, Globo.com. Possui certificações como Certified Kubernetes Administrator, Microsoft Certified: Azure Fundamentals, destacando-se pela capacidade de entregar soluções inovadoras e eficientes alinhadas às necessidades do negócio.');

INSERT INTO curriculo (id_candidato) VALUES
(1),(2),(3),(4),(5),(6),(7),(8),(9),(10),
(11),(12),(13),(14),(15),(16),(17),(18),(19),(20),
(21),(22),(23),(24),(25),(26),(27),(28),(29),(30),
(31),(32),(33),(34),(35),(36),(37),(38),(39),(40),
(41),(42),(43),(44),(45),(46),(47),(48),(49),(50),
(51),(52),(53),(54),(55),(56),(57),(58),(59),(60),
(61),(62),(63),(64),(65),(66),(67),(68),(69),(70),
(71),(72),(73),(74),(75),(76),(77),(78),(79),(80),
(81),(82),(83),(84),(85),(86),(87),(88),(89),(90),
(91),(92),(93),(94),(95),(96),(97),(98),(99),(100);

-- CandidatoSkill
INSERT INTO Curriculo_Habilidade (id_curriculo, id_hab) VALUES
(1,26),(1,22),(1,19),(1,2),(1,24),(1,14),(2,17),(2,31),(2,5),(2,2),(2,22),(3,21),(3,15),(3,29),(3,12),(3,11),(3,32),(3,22),(3,31),
(4,2),(4,20),(4,28),(4,33),(4,15),(4,12),(4,34),(4,7),(5,26),(5,35),(5,34),(5,20),(5,14),(5,3),(5,15),(6,7),(6,11),(6,32),(6,26),
(6,19),(6,17),(6,24),(7,28),(7,17),(7,22),(7,29),(7,34),(7,1),(7,33),(7,19),(8,29),(8,28),(8,15),(8,14),(8,7),(8,13),(9,17),(9,12),
(9,22),(9,13),(9,33),(9,24),(9,32),(10,20),(10,14),(10,12),(10,5),(10,25),(10,35),(10,11),(10,32),(11,29),(11,32),(11,12),(11,28),
(11,14),(11,1),(12,12),(12,19),(12,1),(12,15),(12,22),(12,24),(13,11),(13,25),(13,15),(13,19),(13,32),(13,12),(13,31),(13,17),(14,21),
(14,26),(14,29),(14,25),(14,3),(15,11),(15,17),(15,15),(15,26),(15,3),(16,26),(16,17),(16,20),(16,24),(16,22),(16,14),(16,34),(16,33),
(17,19),(17,7),(17,26),(17,15),(17,25),(17,14),(18,14),(18,20),(18,26),(18,13),(18,1),(18,12),(18,28),(19,15),(19,34),(19,35),(19,12),
(19,5),(19,26),(20,7),(20,19),(20,2),(20,28),(20,3),(20,15),(21,26),(21,14),(21,29),(21,20),(21,34),(21,7),(22,31),(22,2),(22,11),(22,15),
(22,24),(22,28),(22,7),(22,19),(23,19),(23,34),(23,11),(23,5),(23,26),(24,20),(24,29),(24,19),(24,34),(24,28),(24,12),(24,17),(24,1),
(25,3),(25,28),(25,13),(25,32),(25,33),(25,26),(26,20),(26,1),(26,14),(26,31),(26,24),(26,17),(27,35),(27,15),(27,25),(27,12),(27,3),
(28,2),(28,24),(28,25),(28,34),(28,21),(29,17),(29,25),(29,3),(29,1),(29,28),(29,21),(29,33),(30,3),(30,19),(30,5),(30,35),(30,32),
(31,31),(31,21),(31,28),(31,34),(31,17),(32,31),(32,26),(32,2),(32,20),(32,5),(32,11),(32,24),(32,33),(33,35),(33,22),(33,1),(33,7),
(33,24),(33,13),(34,17),(34,13),(34,5),(34,21),(34,26),(34,24),(34,35),(34,33),(35,19),(35,11),(35,21),(35,1),(35,29),(35,22),(35,12),
(35,28),(36,34),(36,13),(36,35),(36,7),(36,28),(37,22),(37,15),(37,31),(37,34),(37,20),(37,28),(37,35),(38,5),(38,13),(38,26),(38,14),
(38,12),(39,14),(39,29),(39,21),(39,33),(39,24),(39,22),(39,28),(40,35),(40,13),(40,24),(40,34),(40,19),(41,15),(41,14),(41,5),(41,34),
(41,3),(41,28),(42,29),(42,14),(42,31),(42,28),(42,15),(43,1),(43,12),(43,25),(43,17),(43,20),(43,5),(43,21),(44,19),(44,21),(44,5),(44,17),
(44,26),(45,35),(45,21),(45,29),(45,2),(45,19),(45,33),(46,20),(46,32),(46,34),(46,29),(46,7),(46,1),(46,24),(46,13),(47,17),(47,5),(47,7),
(47,22),(47,13),(48,17),(48,19),(48,14),(48,11),(48,29),(48,32),(48,24),(49,24),(49,11),(49,33),(49,15),(49,32),(49,1),(50,35),(50,21),
(50,11),(50,13),(50,22),(50,28),(51,22),(51,13),(51,20),(51,28),(51,2),(52,15),(52,1),(52,3),(52,7),(52,21),(52,20),(52,2),(53,12),
(53,3),(53,28),(53,33),(53,24),(54,35),(54,3),(54,34),(54,11),(54,19),(54,26),(55,25),(55,29),(55,11),(55,13),(55,14),(55,33),(55,32),
(56,20),(56,19),(56,15),(56,25),(56,26),(57,22),(57,35),(57,11),(57,15),(57,24),(57,3),(57,19),(58,7),(58,35),(58,5),(58,32),(58,15),
(58,24),(58,20),(59,32),(59,1),(59,24),(59,3),(59,33),(59,5),(59,28),(60,1),(60,2),(60,28),(60,11),(60,15),(60,33),(60,14),(61,14),(61,32),
(61,29),(61,31),(61,33),(61,3),(61,13),(62,24),(62,19),(62,21),(62,31),(62,26),(62,15),(63,17),(63,21),(63,31),(63,25),(63,19),(63,34),
(63,2),(63,29),(64,13),(64,20),(64,22),(64,33),(64,17),(64,2),(64,14),(65,22),(65,31),(65,2),(65,19),(65,15),(65,7),(66,25),(66,33),
(66,19),(66,26),(66,24),(66,1),(66,17),(66,11),(67,15),(67,34),(67,19),(67,35),(67,17),(67,29),(67,12),(68,35),(68,11),(68,31),(68,1),
(68,28),(68,13),(69,5),(69,31),(69,17),(69,29),(69,19),(69,35),(69,25),(70,25),(70,2),(70,1),(70,12),(70,11),(70,29),(70,26),(71,22),
(71,19),(71,1),(71,3),(71,11),(72,1),(72,28),(72,24),(72,15),(72,26),(72,22),(72,19),(72,14),(73,25),(73,19),(73,32),(73,31),(73,15),(74,21),
(74,11),(74,28),(74,14),(74,15),(74,34),(74,20),(74,2),(75,11),(75,35),(75,32),(75,24),(75,13),(75,17),(76,13),(76,5),(76,28),(76,35),
(76,22),(76,11),(76,12),(77,12),(77,7),(77,34),(77,13),(77,25),(77,5),(77,24),(77,2),(78,19),(78,28),(78,35),(78,5),(78,32),(78,15),(79,1),
(79,20),(79,35),(79,2),(79,24),(79,22),(80,17),(80,12),(80,2),(80,22),(80,35),(81,19),(81,20),(81,21),(81,31),(81,32),(82,14),(82,5),(82,3),
(82,35),(82,12),(82,26),(82,32),(82,22),(83,13),(83,11),(83,22),(83,5),(83,3),(83,24),(84,21),(84,34),(84,28),(84,12),(84,32),(85,22),
(85,11),(85,2),(85,13),(85,25),(85,15),(85,35),(86,34),(86,33),(86,24),(86,1),(86,32),(87,28),(87,20),(87,29),(87,26),(87,24),(87,11),
(87,15),(88,20),(88,29),(88,26),(88,21),(88,13),(88,7),(89,17),(89,2),(89,14),(89,1),(89,25),(90,19),(90,14),(90,32),(90,3),(90,7),
(90,25),(90,24),(91,2),(91,33),(91,13),(91,1),(91,34),(91,3),(91,35),(91,15),(92,34),(92,3),(92,22),(92,7),(92,33),(92,24),(92,19),(92,15),
(93,26),(93,17),(93,20),(93,11),(93,25),(93,31),(93,5),(94,15),(94,24),(94,22),(94,35),(94,29),(95,22),(95,15),(95,19),(95,20),(95,32),
(95,34),(95,12),(96,5),(96,29),(96,26),(96,35),(96,7),(96,2),(96,24),(96,13),(97,19),(97,20),(97,25),(97,1),(97,33),(97,24),(97,32),
(98,15),(98,13),(98,20),(98,1),(98,29),(98,11),(99,29),(99,20),(99,14),(99,5),(99,28),(99,25),(100,5),(100,14),(100,25),(100,11),(100,32),(100,2);


-- CandidatoIdioma
INSERT INTO Curriculo_Idioma (id_curriculo, id_idioma) VALUES
(1,1),(2,1),(3,2),(3,5),(4,4),(4,3),(5,4),(6,5),(7,3),(7,2),(7,1),(8,2),(9,5),(9,1),(10,3),(11,3),(11,4),(12,5),
(12,2),(12,4),(13,5),(14,5),(14,4),(14,2),(15,2),(15,5),(15,1),(16,3),(16,1),(16,4),(17,3),(18,1),(19,5),(20,3),
(20,2),(21,3),(21,5),(22,2),(22,1),(23,2),(23,1),(23,5),(24,4),(24,2),(25,4),(25,5),(25,3),(26,3),(27,3),(28,2),
(28,5),(28,1),(29,1),(30,3),(31,1),(31,3),(31,5),(32,4),(32,2),(33,5),(33,3),(34,1),(35,3),(36,3),(37,3),(38,3),
(38,2),(38,4),(39,5),(39,3),(39,4),(40,4),(41,2),(41,5),(42,3),(42,2),(43,5),(43,4),(43,3),(44,4),(44,2),(45,4),
(45,2),(46,2),(46,5),(46,3),(47,5),(48,2),(49,4),(49,1),(49,3),(50,2),(50,1),(51,2),(51,3),(52,4),(52,3),(53,1),
(53,2),(53,5),(54,1),(54,5),(55,3),(55,5),(55,4),(56,5),(57,2),(58,5),(59,5),(60,1),(60,5),(61,2),(61,5),(61,3),
(62,2),(63,4),(63,1),(64,4),(65,4),(65,2),(66,3),(66,5),(66,2),(67,4),(67,5),(68,5),(68,1),(69,5),(70,5),(70,2),
(71,5),(71,1),(71,2),(72,3),(72,2),(72,5),(73,1),(73,2),(73,3),(74,1),(75,3),(75,1),(75,4),(76,4),(76,3),(77,5),
(77,2),(77,1),(78,3),(79,3),(80,1),(81,5),(81,2),(82,2),(82,4),(82,3),(83,1),(84,1),(84,3),(85,3),(86,3),(86,5),
(86,2),(87,1),(87,2),(88,3),(89,1),(89,3),(89,5),(90,3),(90,2),(90,5),(91,5),(91,2),(91,1),(92,1),(92,4),(93,3),
(94,5),(95,1),(96,1),(97,3),(98,3),(98,4),(98,2),(99,4),(99,5),(100,4);

#Verificar se será Implementado
-- CandidatoEmpresaPrevia
#INSERT INTO CandidatoEmpresaPrevia (candidato_id, empresa_id) VALUES
#(1,12),(2,13),(2,12),(3,12),(3,19),(3,14),(4,12),(5,16),(5,12),(6,19),(6,21),(6,18),(6,13),(7,15),(7,18),(7,29),
#(7,12),(8,17),(8,19),(8,23),(8,12),(9,13),(10,19),(11,18),(12,16),(12,22),(12,13),(13,22),(14,13),(14,18),(14,29),
#(14,30),(15,13),(16,18),(16,13),(16,29),(16,16),(17,23),(17,12),(17,16),(17,18),(18,19),(18,12),(18,18),(18,16),
#(19,13),(19,21),(19,15),(19,19),(20,19),(20,29),(21,13),(21,12),(22,15),(23,14),(23,19),(24,15),(25,22),(26,17),
#(26,15),(26,21),(27,15),(28,12),(28,15),(28,16),(28,17),(29,30),(29,23),(30,13),(30,18),(30,23),(30,21),(31,18),
#(31,14),(31,19),(31,17),(32,30),(32,21),(33,15),(33,19),(33,12),(33,29),(34,15),(34,12),(34,22),(34,29),(35,29),
#(36,23),(36,14),(36,21),(37,12),(37,14),(37,15),(37,16),(38,14),(38,30),(38,19),(39,23),(39,14),(39,13),(40,19),
#(40,17),(40,30),(40,15),(41,13),(41,29),(41,19),(41,21),(42,19),(43,14),(43,18),(44,13),(45,18),(46,23),(46,29),
#(46,19),(46,30),(47,12),(48,14),(48,17),(48,29),(49,12),(49,22),(50,13),(50,23),(51,22),(52,29),(52,18),(52,12),
#(52,15),(53,29),(53,17),(53,18),(53,30),(54,12),(54,30),(54,19),(54,22),(55,23),(56,14),(56,19),(56,30),(57,21),
#(57,22),(57,29),(58,19),(59,18),(60,16),(60,19),(61,29),(61,22),(61,12),(61,16),(62,17),(63,16),(64,22),(65,21),
#(65,19),(66,12),(66,17),(66,23),(67,29),(67,15),(67,23),(67,19),(68,17),(68,12),(69,19),(69,22),(70,23),(70,13),
#(70,30),(71,22),(71,14),(71,18),(72,23),(73,15),(74,22),(74,30),(75,17),(75,22),(75,13),(76,23),(76,29),(76,30),
#(77,14),(78,16),(78,21),(78,23),(78,14),(79,18),(80,18),(80,30),(80,14),(81,30),(81,14),(81,21),(81,29),(82,15),
#(82,29),(82,13),(82,22),(83,12),(84,19),(85,30),(86,22),(87,18),(88,17),(88,14),(89,15),(89,14),(89,16),(89,21),
#(90,30),(91,18),(91,22),(91,19),(92,19),(93,17),(93,30),(93,16),(94,22),(94,13),(94,19),(95,29),(95,30),(96,18),
#(97,17),(97,29),(97,18),(97,14),(98,16),(98,19),(98,30),(98,23),(99,12),(99,23),(99,19),(100,13),(100,17),(100,15);

rollback to sp1;
commit; 
rollback;



