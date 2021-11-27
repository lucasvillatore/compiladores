#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "tipos.h"

tabela_simbolos_t *aloca_tabela_simbolos()
{
    tabela_simbolos_t *tabela = (tabela_simbolos_t *)malloc(sizeof(tabela_simbolos_t));

    tabela->topo = -1;
    tabela->tamanho_maximo = 50;
    tabela->simbolos = (simbolo_t **)malloc(sizeof(simbolo_t) * tabela->tamanho_maximo);
}

void push(simbolo_t *simbolo, tabela_simbolos_t *tabela)
{
    tabela->topo++;
    if (tabela->topo == tabela->tamanho_maximo) {
        tabela->tamanho_maximo *= 2;
        tabela->simbolos = (simbolo_t **)realloc(tabela->simbolos, tabela->tamanho_maximo);
    }

    tabela->simbolos[tabela->topo] = simbolo;    
}

simbolo_t *pop(tabela_simbolos_t *tabela)
{
    simbolo_t *simbolo;
    if (tabela->topo == 0) {
        return NULL;
    }

    simbolo = tabela->simbolos[tabela->topo];
    tabela->topo--;

    return simbolo;
}

simbolo_t *cria_simbolo(char *nome, int categoria, int nivel_lexico, int tipo, int deslocamento) 
{
    simbolo_t *simbolo = (simbolo_t *)malloc(sizeof(simbolo_t));
    simbolo->nome = (char *)malloc(sizeof(50) * sizeof(char));
    
    strcpy(simbolo->nome, nome);
    simbolo->categoria = categoria;
    simbolo->nivel_lexico = nivel_lexico;
    simbolo->tipo = tipo;
    simbolo->deslocamento = deslocamento;

    return simbolo;
}

void mostra_quantidade(tabela_simbolos_t *tabela)
{
    printf("%d\n", tabela->topo + 1);
}

int main()
{
    tabela_simbolos_t *tabela = aloca_tabela_simbolos();

    simbolo_t *simbolo = cria_simbolo("teste", 0, 0, 0, 0);
    push(simbolo, tabela);

    mostra_quantidade(tabela);
}