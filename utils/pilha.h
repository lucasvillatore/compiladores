enum tipos_dados{
    TIPO_INTEGER, TIPO_BOOLEAN, TIPO_UNDEFINED
};

enum tipos_categoria {
    VARIAVEL_SIMPLES, PARAMETRO_FORMAL, PROCEDIMENTO
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

void mostra_quantidade(tabela_simbolos_t *tabela);

simbolo_t *busca(tabela_simbolos_t *tabela, char *nome);

simbolo_t *cria_simbolo(char *nome, int categoria, int nivel_lexico, int deslocamento, int tipo);

simbolo_t *pop(tabela_simbolos_t *tabela);

void push(simbolo_t *simbolo, tabela_simbolos_t *tabela);

tabela_simbolos_t *aloca_tabela_simbolos();