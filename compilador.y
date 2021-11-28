
// Testar se funciona corretamente o empilhamento de par�metros
// passados por valor ou por refer�ncia.


%{
#include <stdio.h>
#include <ctype.h>
#include <stdlib.h>
#include <string.h>
#include "compilador.h"
#include "pilha.c"
#include "comandos.c"

tabela_simbolos_t *tabela_simbolos;

int num_vars;
int dmem;
int nivel_lexico;
int deslocamento;
int deslocamento_anterior;
int tipo_variavel;
simbolo_t *novo_simbolo;

%}

%token PROGRAM ABRE_PARENTESES FECHA_PARENTESES
%token VIRGULA PONTO_E_VIRGULA DOIS_PONTOS PONTO
%token T_BEGIN T_END VAR IDENT ATRIBUICAO
%token LABEL TYPE ARRAY OF PROCEDURE FUNCTION
%token GOTO IF THEN ELSE WHILE DO MAIS MENOS
%token MULTIPLICACAO OR AND NOT ABRE_COLCHETES
%token FECHA_COLCHETES IGUAL MENOR MAIOR DIFERENTE
%token MAIOR_IGUAL MENOR_IGUAL READ WRITE FALSE
%token TRUE INTEGER DIV NUMERO BOOLEAN

%%

programa: 
   {
      geraCodigo (NULL, "INPP");
   }
   PROGRAM IDENT
   ABRE_PARENTESES lista_idents FECHA_PARENTESES PONTO_E_VIRGULA
   bloco PONTO 
   {
      mostra_tabela_simbolos(tabela_simbolos);
      adicionaCodigoDMEM(dmem);
      geraCodigo (NULL, "PARA");
   };

bloco:
   parte_declara_vars
   { }
   comando_composto;

parte_declara_vars: var;

var: 
   VAR declara_vars | ;

declara_vars: 
   declara_vars declara_var {num_vars=0; } | 
   declara_var {num_vars=0; } 
;

declara_var: 
   { 

   }
   lista_id_var DOIS_PONTOS
   tipo
   {
      atualiza_tipo_variaveis_tabela_simbolos(tabela_simbolos, tipo_variavel, num_vars);
      adicionaCodigoAMEM(num_vars);
   }
   PONTO_E_VIRGULA
;

tipo: 
   INTEGER 
   { tipo_variavel = TIPO_INTEGER; } |
   BOOLEAN { tipo_variavel = TIPO_BOOLEAN; }
;

lista_id_var: 
   lista_id_var VIRGULA IDENT
   {
      if (busca_simbolo(tabela_simbolos, token, nivel_lexico)) {
         imprimeErro("Simbolo já existente na tabela de simbolos");
      }

      num_vars++;
      dmem++;

      deslocamento++;
      novo_simbolo = cria_simbolo(token, VARIAVEL_SIMPLES, nivel_lexico, deslocamento, TIPO_UNDEFINED);
      adiciona_simbolo_tabela_simbolos(novo_simbolo, tabela_simbolos);
   } 
   | IDENT 
   { 

      if (busca_simbolo(tabela_simbolos, token, nivel_lexico)) {
         imprimeErro("Simbolo já existente na tabela de simbolos");
      }

      num_vars++;
      dmem++;

      deslocamento++;
      novo_simbolo = cria_simbolo(token, VARIAVEL_SIMPLES, nivel_lexico, deslocamento, TIPO_UNDEFINED);
      adiciona_simbolo_tabela_simbolos(novo_simbolo, tabela_simbolos);
   }
;

lista_idents: 
   lista_idents VIRGULA IDENT | 
   IDENT
;

comando_composto: T_BEGIN comandos T_END | T_BEGIN T_END;

comandos: 
   comando PONTO_E_VIRGULA comandos |
   comando PONTO_E_VIRGULA 
;

comando:
   comando_sem_rotulo 
;

comando_sem_rotulo: 
    atribuicao
;

atribuicao:
   variavel_chamada_funcao ATRIBUICAO expressao
;

expressao: 
   expressao_simples |
   expressao_simples relacao expressao_simples;

relacao:
   IGUAL | DIFERENTE | MENOR | MENOR_IGUAL | MAIOR_IGUAL | MAIOR ;

termo_com_sinal: 
   MAIS termo |
   MENOS termo |
   termo
;

lista_expressoes:
   expressao VIRGULA lista_expressoes |
   expressao
;

expressao_simples:
   termo_com_sinal operacoes |
   termo_com_sinal
;

operacoes:
   operacao operacoes |
   operacao
;

operacao:
   MAIS termo |
   MENOS termo |
   OR termo  
;

operacoes_fator:
   operacao_fator operacoes_fator |
   operacao_fator
;

operacao_fator:
   MULTIPLICACAO fator |
   DIV fator |
   AND fator 
;

termo:
   fator operacoes_fator |
   fator
;

fator:
   variavel_chamada_funcao |
   NUMERO |
   ABRE_PARENTESES expressao FECHA_PARENTESES |
   NOT fator
;

variavel_chamada_funcao:
   IDENT variavel |
   IDENT chamada_funcao
;

variavel:
   lista_expressoes | 
;

chamada_funcao:
   ABRE_PARENTESES lista_expressoes FECHA_PARENTESES
;


%%

int main (int argc, char** argv) {
   FILE* fp;
   extern FILE* yyin;

   if (argc<2 || argc>2) {
         printf("usage compilador <arq>a %d\n", argc);
         return(-1);
      }

   fp=fopen (argv[1], "r");
   if (fp == NULL) {
      printf("usage compilador <arq>b\n");
      return(-1);
   }


/* -------------------------------------------------------------------
 *  Inicia a Tabela de S�mbolos
 * ------------------------------------------------------------------- */
   tabela_simbolos = aloca_tabela_simbolos();
   dmem = 0;
   num_vars = 0;
   deslocamento = 0;
   nivel_lexico = 0;
   yyin=fp;
   yyparse();

   return 0;
}
