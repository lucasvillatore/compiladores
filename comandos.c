#include <stdio.h>
#include <string.h>
#include <stdlib.h>


void adicionaCodigoAMEM(int num_vars)
{
    char num_vars_str[10];
    sprintf(num_vars_str, "AMEM %d", num_vars);
    geraCodigo(NULL, num_vars_str);
}

void adicionaCodigoDMEM(int num_vars)
{
    char num_vars_str[10];
    sprintf(num_vars_str, "DMEM %d", num_vars);
    geraCodigo(NULL, num_vars_str);
}

void adicionaCodigoCarregaValor(simbolo_t *simbolo, char *token)
{
    char codigo[15];
    sprintf(codigo, "CRVL %d, %d", simbolo->nivel_lexico, simbolo->deslocamento);
    geraCodigo(NULL, codigo);
}

void adicionaCodigoCarregaConstante(char *token)
{
    char codigo[] = "CRCT ";
    strcat(codigo, token);
    geraCodigo(NULL, codigo);
}


void adicionaCodigoIgual()
{
    geraCodigo(NULL, "CMIG");
}
void adicionaCodigoDiferente()
{
    geraCodigo(NULL, "CMDG");
}
void adicionaCodigoMenor()
{
    geraCodigo(NULL, "CMME");
}
void adicionaCodigoMenorIgual()
{
    geraCodigo(NULL, "CMEG");
}
void adicionaCodigoMaiorIgual()
{
    geraCodigo(NULL, "CMAG");
}
void adicionaCodigoMaior()
{
    geraCodigo(NULL, "CMMA");
}
void adicionaCodigoMais()
{
    geraCodigo(NULL, "SOMA");
}
void adicionaCodigoMenos()
{
    geraCodigo(NULL, "SUBT");
}
void adicionaCodigoOr()
{
    geraCodigo(NULL, "DISJ");
}

void adicionaCodigoMult()
{
    geraCodigo(NULL, "MULT");
}

void adicionaCodigoDiv()
{
    geraCodigo(NULL, "DIVI");
}

void adicionaCodigoAnd()
{
    geraCodigo(NULL, "CONJ");
}

void adicionaCodigoRelacao(int relacao){
    switch (relacao)
    {
    case RELACAO_IGUAL:
        adicionaCodigoIgual();
        break;
    case RELACAO_DIFERENTE:
        adicionaCodigoDiferente();
        break;
    case RELACAO_MENOR:
        adicionaCodigoMenor();
        break;
    case RELACAO_MENOR_IGUAL:
        adicionaCodigoMenorIgual();
        break;
    case RELACAO_MAIOR_IGUAL:
        adicionaCodigoMaiorIgual();
        break;
    case RELACAO_MAIOR:
        adicionaCodigoMaior();
        break;
    default:
        break;
    }
}

void adicionaCodigoOperacao(int relacao){
    printf("----- relacao = %d ------\n", relacao);
    switch (relacao)
    {
    case OPERACAO_MULT:
        adicionaCodigoMult();
        break;
    case OPERACAO_DIV:
        adicionaCodigoDiv();
        break;
    case OPERACAO_MAIS:
        adicionaCodigoMais();
        break;
    case OPERACAO_MENOS:
        adicionaCodigoMenos();
        break;

    case OPERACAO_AND:
        adicionaCodigoAnd();
        break;
    case OPERACAO_OR:
        adicionaCodigoOr();
        break;
    default:
        break;
    }
}

int operacaoBoleana(int tipoComparacao)
{
    return (tipoComparacao == OPERACAO_AND || tipoComparacao == OPERACAO_OR);
}

void verificaOperacao(pilha_t *p1, pilha_t *p2, int tipoComparacao){
    int t1 = remove_pilha(p1), t2 = remove_pilha(p2);

    if (t1 != t2)
       imprimeErro("Tipos diferentes na operação");

    if ((t1 == TIPO_INTEGER && operacaoBoleana(tipoComparacao)) || 
        (t1 == TIPO_BOOLEAN && !operacaoBoleana(tipoComparacao)))
       imprimeErro("Tipos invalidos na operação");

    insere_pilha(p1, t1);
}

int relacoesInteiras(int tipoRelacao)
{
    return tipoRelacao > 1;
}

void verificaRelacao(pilha_t *p1, pilha_t *p2, int tipoRelacao){
   int t1 = remove_pilha(p1), t2 = remove_pilha(p2);

   if (t1 != t2)
      imprimeErro("Tipos diferentes na relação");

    if (t1 == TIPO_BOOLEAN && relacoesInteiras(tipoRelacao))
      imprimeErro("Tipos invalidos na relação");

   insere_pilha(p1, TIPO_BOOLEAN);
}

void adicionaCodigoNadaSemRotulo()
{
    geraCodigo(NULL, "NADA");
}

void adicionaCodigoNada(int rotulo)
{
    char *rotulo_str = (char *)malloc(sizeof(char) * 10);
    sprintf(rotulo_str, "R%d", rotulo);
    geraCodigo(rotulo_str, "NADA");
}

void adicionaCodigoDesviaSempre(int rotulo)
{
    char *codigo = (char *)malloc(sizeof(char) * 10);
    sprintf(codigo, "DSVS R%d", rotulo);
    geraCodigo(NULL, codigo);
}

void adicionaDesviaSeFalso(int rotulo)
{
    char *codigo = (char *)malloc(sizeof(char) * 10);
    sprintf(codigo, "DSVF R%d", rotulo);
    geraCodigo(NULL, codigo);
}

void adicionaCodigoArmazena(simbolo_t *simbolo)
{
    char *codigo = (char *)malloc(sizeof(char) * 10);
    sprintf(codigo, "ARMZ %d,%d", simbolo->nivel_lexico, simbolo->deslocamento);
    geraCodigo(NULL, codigo);
}