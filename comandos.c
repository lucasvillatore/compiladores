#include <stdio.h>

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