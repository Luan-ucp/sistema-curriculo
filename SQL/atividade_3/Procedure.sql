DELIMITER //

USE banco_de_vaga //

CREATE PROCEDURE `MelhorCurriculoVaga`(IN id_vaga INT)
BEGIN
    SELECT 
        can.id_candidato, 
        can.nome, 
        can.email, 
        COUNT(DISTINCT vh.id_hab) AS habilidades_correspondentes
    FROM Vaga v
    JOIN Vaga_Habilidade vh ON v.id_vaga = vh.id_vaga
    JOIN Curriculo_Habilidade ch ON vh.id_hab = ch.id_hab
    JOIN Curriculo cur ON ch.id_curriculo = cur.id_curriculo
    JOIN Candidato can ON cur.id_candidato = can.id_candidato
    WHERE v.id_vaga = id_vaga
    GROUP BY can.id_candidato, can.nome, can.email
    ORDER BY habilidades_correspondentes DESC;
END //

DELIMITER ;

CALL MelhorCurriculoVaga(1);
