# src/utils/formatters.py

def formatar_real(valor):
    """
    Recebe um float (ex: 2500.5) e retorna string formatada (ex: R$ 2.500,50)
    """
    if not valor:
        return "R$ 0,00"
        
    # 1. Formata com vírgula para milhar e ponto para decimal (padrão US)
    # Ex: 10000.50 -> "10,000.50"
    texto = f"{valor:,.2f}"
    
    # 2. Troca vírgula por X (temporário), ponto por vírgula, e X por ponto
    # Resultado: "10.000,50"
    texto_br = texto.replace(",", "X").replace(".", ",").replace("X", ".")
    
    return f"R$ {texto_br}"