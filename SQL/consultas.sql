SHOW DATABASES;
USE banco_de_vaga;
SHOW TABLES;

/* Quais são as vagas disponíveis?*/
select * from Vaga;SELECT 
    v.id_vaga,
    v.titulo,
    v.descricao,
    v.tipo_contrato,
    v.salario,
    l.cidade,
    l.estado,
    e.razao_social AS empregador
FROM Vaga v
JOIN Localizacao l ON v.id_local = l.id_local
JOIN Empregador e ON v.id_empregador = e.id_empregador;

/* Quais são as tecnologias mais procuradas em cada estado? */
SELECT
    h.nome AS habilidade,
    l.estado,
    COUNT(v.id_vaga) AS total_vagas
FROM
    Vaga v
JOIN
    Vaga_Habilidade vh ON v.id_vaga = vh.id_vaga
JOIN
    Habilidade h ON vh.id_hab = h.id_hab
JOIN
    Localizacao l ON v.id_local = l.id_local
GROUP BY
    h.nome, l.estado
ORDER BY
    l.estado, total_vagas DESC;
/*Quantos graus separam X e Y?*/

/*Quais são os contatos de 1º e 2º níveis de X?*/

/*Quais são os salários médios de cada profissão*/    
SELECT 
    v.titulo AS vaga,
    AVG(v.salario) AS salario_medio
FROM
    Vaga v
GROUP BY
    v.titulo;

/*Qual empresa paga mais em média?*/
SELECT 
    e.razao_social AS empresa,
    AVG(v.salario) AS salario_medio
FROM
    Vaga v
JOIN
    Empregador e ON v.id_empregador = e.id_empregador
GROUP BY
    e.razao_social
ORDER BY
    salario_medio DESC
LIMIT 1;

/*Quais são as empresas com mais vagas abertas?*/
SELECT 
    e.razao_social AS empresa,
    COUNT(v.id_vaga) AS total_vagas
FROM
    Vaga v
JOIN
    Empregador e ON v.id_empregador = e.id_empregador
GROUP BY
    e.razao_social
ORDER BY
    total_vagas DESC
LIMIT 1;    


/*Melhor Match para vaga */
SELECT can.id_candidato, can.nome, can.email, COUNT(DISTINCT vh.id_hab) AS habilidades_correspondentes
FROM Vaga v
JOIN vaga_habilidade vh ON v.id_vaga = vh.id_vaga
JOIN curriculo_habilidade ch ON vh.id_hab = ch.id_hab
JOIN curriculo c ON ch.id_curriculo = c.id_curriculo
JOIN candidato can ON c.id_candidato = can.id_candidato
WHERE v.id_vaga = 1
GROUP BY can.id_candidato
ORDER BY COUNT(DISTINCT vh.id_hab) DESC