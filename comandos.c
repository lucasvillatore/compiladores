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

void adicionaCodigoRelacao(int relacao){
    switch (relacao)
    {
    case 1:
        adicionaCodigoIgual();
        break;
    case 2:
        adicionaCodigoDiferente();
        break;
    case 3:
        adicionaCodigoMenor();
        break;
    case 4:
        adicionaCodigoMenorIgual();
        break;
    case 5:
        adicionaCodigoMaiorIgual();
        break;
    case 6:
        adicionaCodigoMaior();
        break;
    default:
        break;
    }
}

void verificaComparacao(pilha_t *p1, pilha_t *p2, int tipoComparacao){
    int t1 = remove_pilha(p1), t2 = remove_pilha(p2);

    if (t1 != t2)
       imprimeErro("Tipos diferentes na operação");

    if (t1 != tipoComparacao)
       imprimeErro("Tipos invalidos na operação");

   insere_pilha(p1, tipoComparacao);
}

void verificaRelacao(pilha_t *p1, pilha_t *p2, int tipoRelacao){
   int t1 = remove_pilha(p1), t2 = remove_pilha(p2);

   if (t1 != t2)
      imprimeErro("Tipos diferentes na operação");

    if (t1 == 1 && tipoRelacao > 2)
      imprimeErro("Tipos invalidos na operação");

   insere_pilha(p1, TIPO_BOOLEAN);
}