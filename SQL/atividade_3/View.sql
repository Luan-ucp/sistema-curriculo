USE banco_de_vaga;
CREATE VIEW VagasHabilidades AS
SELECT 
    v.id_vaga,
    v.titulo,
    v.descricao,
    v.salario,
    GROUP_CONCAT(DISTINCT h.nome) AS habilidades_requeridas
FROM Vaga v
JOIN Vaga_Habilidade vh ON v.id_vaga = vh.id_vaga
JOIN Habilidade h ON vh.id_hab = h.id_hab
GROUP BY v.id_vaga;

SELECT * FROM vagashabilidades;