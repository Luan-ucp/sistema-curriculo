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
    id_usuario INT NOT NULL,
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
    id_usuario INT NOT NULL,
    razao_social VARCHAR(150) NOT NULL,
    cnpj VARCHAR(20) UNIQUE NOT NULL,
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
    id_usuario INT NOT NULL,
    nome VARCHAR(100) NOT NULL,
    email VARCHAR(150) NOT NULL,
    telefone VARCHAR(20),
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
    resumo TEXT,
    FOREIGN KEY (id_candidato) REFERENCES Candidato(id_candidato)
);

CREATE TABLE Formacao (
    id_form INT PRIMARY KEY AUTO_INCREMENT,
    id_curriculo INT NOT NULL,
    curso VARCHAR(150) NOT NULL,
    instituicao VARCHAR(150),
    nivel VARCHAR(50),
    ano_conclusao INT,
    FOREIGN KEY (id_curriculo) REFERENCES Curriculo(id_curriculo)
);

CREATE TABLE Experiencia (
    id_exp INT PRIMARY KEY AUTO_INCREMENT,
    id_curriculo INT NOT NULL,
    cargo VARCHAR(100) NOT NULL,
    empresa VARCHAR(150),
    inicio DATE NOT NULL,
    fim DATE,
    descricao TEXT,
    FOREIGN KEY (id_curriculo) REFERENCES Curriculo(id_curriculo)
);

CREATE TABLE Habilidade (
    id_hab INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(100) UNIQUE NOT NULL
);

CREATE TABLE Idioma (
    id_idioma INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(100) NOT NULL,
    nivel_padrao VARCHAR(50)
);

CREATE TABLE Curriculo_Habilidade (
    id_curriculo INT,
    id_hab INT,
    nivel_opcional VARCHAR(50),
    PRIMARY KEY (id_curriculo, id_hab),
    FOREIGN KEY (id_curriculo) REFERENCES Curriculo(id_curriculo),
    FOREIGN KEY (id_hab) REFERENCES Habilidade(id_hab)
);

CREATE TABLE Curriculo_Idioma (
    id_curriculo INT,
    id_idioma INT,
    nivel VARCHAR(50),
    PRIMARY KEY (id_curriculo, id_idioma),
    FOREIGN KEY (id_curriculo) REFERENCES Curriculo(id_curriculo),
    FOREIGN KEY (id_idioma) REFERENCES Idioma(id_idioma)
);

CREATE TABLE Vaga_Habilidade (
    id_vaga INT,
    id_hab INT,
    obrigatoria BOOLEAN NOT NULL,
    PRIMARY KEY (id_vaga, id_hab),
    FOREIGN KEY (id_vaga) REFERENCES Vaga(id_vaga),
    FOREIGN KEY (id_hab) REFERENCES Habilidade(id_hab)
);

CREATE TABLE Vaga_Idioma (
    id_vaga INT,
    id_idioma INT,
    nivel_minimo VARCHAR(50),
    PRIMARY KEY (id_vaga, id_idioma),
    FOREIGN KEY (id_vaga) REFERENCES Vaga(id_vaga),
    FOREIGN KEY (id_idioma) REFERENCES Idioma(id_idioma)
);

rollback to sp1;
commit; 
rollback;
