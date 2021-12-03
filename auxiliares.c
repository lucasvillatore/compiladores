#ifndef __auxiliares__
#define __auxiliares__

int operacaoBoleana(int tipoComparacao)
{
    return (tipoComparacao == OPERACAO_AND || tipoComparacao == OPERACAO_OR);
}

int comparaTipoExpressao(int tipo_simbolo, int tipo_expressao)
{
   return ((tipo_simbolo == tipo_expressao) || ((tipo_simbolo - 10) == tipo_expressao) || (tipo_simbolo == (tipo_expressao - 10)));
}

void verificaOperacao(pilha_t *p1, pilha_t *p2, int tipoComparacao){
    int t1 = remove_pilha(p1), t2 = remove_pilha(p2);

    if (!comparaTipoExpressao(t1, t2))
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

int ehVariavelReferencia(int tipoVariavel) {
   return (tipoVariavel > 9);
}

#endif