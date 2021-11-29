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
    mostra_simbolo(simbolo);
    char codigo[15];
    sprintf(codigo, "CRVL %d, %d", simbolo->nivel_lexico, simbolo->deslocamento);
    geraCodigo(NULL, codigo);
}

void adicionaCodigoCarregaConstante(char *token)
{
    char codigo[] = "CRCT ";
    if (strcmp(token, "true") == 0) {
        token = "1";
    }
    if (strcmp(token, "false") == 0) {
        token = "0";
    }
    
    strcat(codigo, token);
    geraCodigo(NULL, codigo);
}