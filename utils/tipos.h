enum tipos_dados{
    INTEGER, BOOLEAN, UNDEFINED
};

enum tipos_categoria {
    VARIAVEL_SIMPLES, PARAMETRO_FORMAL, PROCEDIMENTO, FUNCAO, ROTULOS
};


typedef struct simbolo_s {
    char *nome;
    int categoria;
    int nivel_lexico;
    int tipo;
    int deslocamento;
}simbolo_t;


typedef struct tabela_simbolos_s {
    int topo;
    int tamanho_maximo;
    simbolo_t **simbolos;
} tabela_simbolos_t;