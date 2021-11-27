#include "../compilador.y"

void adicionaCodigoAmem(int num_vars)
{
    char num_vars_str[10];
    sprintf(num_vars_str, "AMEM %d", num_vars);
    geraCodigo(NULL, num_vars_str);
}