#ifndef __tipos__
#define __tipos__

enum tipos_dados{
    TIPO_INTEGER, TIPO_BOOLEAN, TIPO_UNDEFINED, TIPO_ADDR
};

enum tipos_categoria {
    VARIAVEL_SIMPLES, PARAMETRO_FORMAL, PROCEDIMENTO, FUNCAO
};

enum tipos_relacao {
    RELACAO_IGUAL, RELACAO_DIFERENTE, RELACAO_MENOR, RELACAO_MENOR_IGUAL, RELACAO_MAIOR_IGUAL, RELACAO_MAIOR
};

enum tipos_operacao {
    OPERACAO_MAIS, OPERACAO_MENOS, OPERACAO_MULT, OPERACAO_DIV, OPERACAO_AND, OPERACAO_OR
};

enum tipo_variavel_funcao {
    POR_VALOR, POR_REFERENCIA
};

#endif 