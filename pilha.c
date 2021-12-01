#include <stdio.h>
#include <stdlib.h>
#include <string.h>

enum tipos_dados{
    TIPO_INTEGER, TIPO_BOOLEAN, TIPO_UNDEFINED
};

enum tipos_categoria {
    VARIAVEL_SIMPLES, PARAMETRO_FORMAL, PROCEDIMENTO
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


tabela_simbolos_t *aloca_tabela_simbolos()
{
    tabela_simbolos_t *tabela = (tabela_simbolos_t *)malloc(sizeof(tabela_simbolos_t));

    tabela->topo = -1;
    tabela->tamanho_maximo = 50;
    tabela->simbolos = (simbolo_t **)malloc(sizeof(simbolo_t) * tabela->tamanho_maximo);

    return tabela;
}

void adiciona_simbolo_tabela_simbolos(simbolo_t *simbolo, tabela_simbolos_t *tabela)
{
    tabela->topo++;
    if (tabela->topo == tabela->tamanho_maximo) {
        tabela->tamanho_maximo *= 2;
        tabela->simbolos = (simbolo_t **)realloc(tabela->simbolos, tabela->tamanho_maximo);
    }

    tabela->simbolos[tabela->topo] = simbolo;    
}

simbolo_t *remove_simbolo_tabela_simbolos(tabela_simbolos_t *tabela)
{
    simbolo_t *simbolo;
    if (tabela->topo == 0) {
        return NULL;
    }

    simbolo = tabela->simbolos[tabela->topo];
    tabela->topo--;

    return simbolo;
}

simbolo_t *cria_simbolo(char *nome, int categoria, int nivel_lexico, int deslocamento, int tipo) 
{
    simbolo_t *simbolo = (simbolo_t *)malloc(sizeof(simbolo_t));
    simbolo->nome = (char *)malloc(strlen(nome) * sizeof(char));
    
    strcpy(simbolo->nome, nome);
    simbolo->categoria = categoria;
    simbolo->nivel_lexico = nivel_lexico;
    simbolo->tipo = tipo;
    simbolo->deslocamento = deslocamento;

    return simbolo;
}

simbolo_t *busca_simbolo(tabela_simbolos_t *tabela, char *nome, int nivel_lexico)
{
    if (tabela->topo == -1) {
        return NULL;
    }

    for (int i = tabela->topo; i >= 0; i--) {
        if (!strcmp(nome, tabela->simbolos[i]->nome) && nivel_lexico == tabela->simbolos[i]->nivel_lexico) {
            return tabela->simbolos[i];
        }
    }

    return NULL;
}

simbolo_t *busca_simbolo_sem_nivel_lexico(tabela_simbolos_t *tabela, char *nome)
{
    if (tabela->topo == -1) {
        return NULL;
    }

    for (int i = tabela->topo; i >= 0; i--) {
        if (!strcmp(nome, tabela->simbolos[i]->nome)) {
            return tabela->simbolos[i];
        }
    }

    return NULL;
}

void mostra_quantidade(tabela_simbolos_t *tabela)
{
    printf("%d\n", tabela->topo + 1);
}

void mostra_simbolo(simbolo_t *simbolo)
{
    printf("nome: %s\n", simbolo->nome);
    printf("categoria: %d\n", simbolo->categoria);
    printf("nivel_lexico: %d\n", simbolo->nivel_lexico);
    printf("deslocamento: %d\n", simbolo->deslocamento);
    printf("tipo: %d\n", simbolo->tipo);
}

void mostra_tabela_simbolos(tabela_simbolos_t *tabela)
{
    for (int i = 0; i <= tabela->topo; i++) {
        mostra_simbolo(tabela->simbolos[i]);
    }
}

void atualiza_tipo_variaveis_tabela_simbolos(tabela_simbolos_t *tabela, int tipo_variavel, int num_vars)
{

    for (int i = tabela->topo; i > tabela->topo - num_vars; i--) {
        tabela->simbolos[i]->tipo = tipo_variavel;
    }

}