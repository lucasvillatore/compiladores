#ifndef __pilha__
#define __pilha__

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "tipos.h"

typedef struct pilha_s {
    int topo;
    int tamanho_maximo;
    int *itens;
} pilha_t;

pilha_t *cria_pilha()
{
    pilha_t *p = (pilha_t *)malloc(sizeof(pilha_t));

    p->topo = -1;
    p->tamanho_maximo = 50;
    p->itens = (int *)malloc(sizeof(int) * p->tamanho_maximo);

    return p;
}

void insere_pilha(pilha_t *p, int valor)
{
    p->topo++;
    if (p->topo == p->tamanho_maximo) {
        p->tamanho_maximo *= 2;
        p->itens = (int *)realloc(p->itens, p->tamanho_maximo);
    }

    p->itens[p->topo] = valor;    
}

int remove_pilha(pilha_t *p)
{
    if (p->topo == -1)
        return -1;

    return p->itens[p->topo--];
}

#endif