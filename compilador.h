/* -------------------------------------------------------------------
 *            Arquivo: compilador.h
 * -------------------------------------------------------------------
 *              Autor: Bruno Muller Junior
 *               Data: 08/2007
 *      Atualizado em: [09/08/2020, 19h:01m]
 *
 * -------------------------------------------------------------------
 *
 * Tipos, protótipos e variáveis globais do compilador (via extern)
 *
 * ------------------------------------------------------------------- */

#define TAM_TOKEN 16

typedef enum simbolos {
  simb_program, simb_var, simb_begin, simb_end,
  simb_identificador, simb_numero,
  simb_ponto, simb_virgula, simb_ponto_e_virgula, simb_dois_pontos,
  simb_atribuicao, simb_abre_parenteses, simb_fecha_parenteses,
  
  simb_label, simb_type, simb_array, simb_of, simb_procedure,
  simb_function, simb_goto, simb_if, simb_then, simb_else, simb_while,
  simb_do, simb_mais, simb_menos, simb_multiplicacao,  simb_or, simb_div,
  simb_and, simb_not, simb_abre_colchetes, simb_fecha_colchetes, simb_igual,
  simb_maior, simb_menor, simb_diferente, simb_maior_igual,
  simb_menor_igual, simb_read, simb_write, simb_false, simb_true,
  simb_integer, simb_boolean
} simbolos;



/* -------------------------------------------------------------------
 * variáveis globais
 * ------------------------------------------------------------------- */

extern simbolos simbolo, relacao;
extern char token[TAM_TOKEN];
extern int nivel_lexico;
extern int desloc;
extern int nl;


/* -------------------------------------------------------------------
 * prototipos globais
 * ------------------------------------------------------------------- */

void geraCodigo (char*, char*);
int imprimeErro (char *erro);
int yylex();
void yyerror(const char *s);
