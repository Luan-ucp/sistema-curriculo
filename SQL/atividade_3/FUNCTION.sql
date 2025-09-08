DELIMITER //

CREATE FUNCTION contar_vagas_por_habilidade(p_habilidade VARCHAR(100))
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE qtd INT;
    SELECT COUNT(DISTINCT v.id_vaga)
    INTO qtd
    FROM Vaga v
    JOIN vaga_habilidade vh ON v.id_vaga = vh.id_vaga
    JOIN Habilidade h ON vh.id_hab = h.id_hab
    WHERE h.nome = p_habilidade;
    RETURN qtd;
END //
DELIMITER ;

SELECT contar_vagas_por_habilidade('Python') AS total_vagas;