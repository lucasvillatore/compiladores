
// Testar se funciona corretamente o empilhamento de par�metros
// passados por valor ou por refer�ncia.


%{
#include <stdio.h>
#include <ctype.h>
#include <stdlib.h>
#include <string.h>
#include "compilador.h"
#include "pilha.c"
#include "pilha-gen.c"
#include "comandos.c"

tabela_simbolos_t *tabela_simbolos;

int num_rotulo;
int num_vars;
int dmem;
int nivel_lexico;
int deslocamento;
int deslocamento_anterior;
int tipo_variavel;
int tipo_variavel_atribuicao;
int tipo_operacao;
int tipo_relacao;
int rotulo_atual;
int tipo_termo;
int tipo_fator;
simbolo_t *novo_simbolo;
simbolo_t *variavel;
simbolo_t *variavel_atribuicao;
simbolo_t *procedimento;

pilha_t *pilhaNVars;
pilha_t *pilhaExpr;
pilha_t *pilhaTermo;
pilha_t *pilhaFator;
pilha_t *pilhaRelac;
pilha_t *pilhaOpers;
pilha_t *pilhaRot;

void verificaTipos(pilha_t *p1, pilha_t *p2, int tipoComparacao);


int criaRotulo()
{
   return num_rotulo++;
}

simbolo_t *obtemSimbolo(char *token)
{
   simbolo_t *simbolo = busca_simbolo_sem_nivel_lexico(tabela_simbolos, token);

   if (!simbolo) {
      imprimeErro("Variável não existe na tabela de símbolos");
   }

   return simbolo;
}

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

%nonassoc LOWER_THAN_ELSE
%nonassoc ELSE


%%

programa: 
   {
      geraCodigo (NULL, "INPP");
   }
   PROGRAM IDENT
   ABRE_PARENTESES lista_idents FECHA_PARENTESES PONTO_E_VIRGULA
   bloco { printf("oi\n\n"); } PONTO 
   {
      adicionaCodigoDMEM(num_vars);
      geraCodigo (NULL, "PARA");
   };

bloco:
   parte_declara_vars

   parte_declara_subrotinas_ou_vazio

   comando_composto;

parte_declara_vars: var;


parte_declara_subrotinas_ou_vazio:
   {
      nivel_lexico++;
      insere_pilha(pilhaRot, (rotulo_atual = criaRotulo()));
      adicionaCodigoDesviaSempre(rotulo_atual);
      adicionaCodigoEntraProcedimento((rotulo_atual = criaRotulo()), nivel_lexico);
      insere_pilha(pilhaNVars, num_vars);
      num_vars = 0;

   } 
   
   parte_declara_subrotinas
   { 
      adicionaCodigoDMEM(num_vars); 
      adicionaCodigoRetornaProcedimento(nivel_lexico, 0);

      nivel_lexico--;
      num_vars = remove_pilha(pilhaNVars);
      adicionaCodigoNada(remove_pilha(pilhaRot));
   }  | 

;
parte_declara_subrotinas: 
   parte_declara_subtorinas declara_subrotinas 
;
declara_subrotinas:
   declara_procedimento |
;

declara_procedimento:
   declara_procedimento_sem_ponto_virgula PONTO_E_VIRGULA | 
   declara_procedimento_sem_ponto_virgula
;

declara_procedimento_sem_ponto_virgula:
   PROCEDURE IDENT 
   {
      if (busca_simbolo(tabela_simbolos, token, nivel_lexico)) {
         imprimeErro("Simbolo já existente na tabela de simbolos");
      }

      novo_simbolo = cria_simbolo_procedure(token, PROCEDURE, nivel_lexico, rotulo_atual);
      adiciona_simbolo_tabela_simbolos(novo_simbolo, tabela_simbolos);
      
   } 
   PONTO_E_VIRGULA bloco
   {
      remove_multiplos_simbolos(tabela_simbolos, num_vars);
   }
;


var: 
   VAR {num_vars=0;} declara_vars | ;

declara_vars: 
   declara_vars declara_var | 
   declara_var  
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

      novo_simbolo = cria_simbolo(token, VARIAVEL_SIMPLES, nivel_lexico, deslocamento, TIPO_UNDEFINED, 0);
      adiciona_simbolo_tabela_simbolos(novo_simbolo, tabela_simbolos);
      deslocamento++;
   } 
   | IDENT 
   { 

      if (busca_simbolo(tabela_simbolos, token, nivel_lexico)) {
         imprimeErro("Simbolo já existente na tabela de simbolos");
      }

      num_vars++;
      dmem++;

      novo_simbolo = cria_simbolo(token, VARIAVEL_SIMPLES, nivel_lexico, deslocamento, TIPO_UNDEFINED, 0);
      adiciona_simbolo_tabela_simbolos(novo_simbolo, tabela_simbolos);
      deslocamento++;
   }
;

lista_idents: 
   lista_idents VIRGULA IDENT | 
   IDENT
;

comando_composto: T_BEGIN comandos T_END | T_BEGIN T_END;

comandos: 
   comandos PONTO_E_VIRGULA comando |
   comandos PONTO_E_VIRGULA |
   comando
;

comando:
   comando_sem_rotulo 
;

comando_sem_rotulo:  
   cond_if |
   cond_while |
   comando_composto |
   read |
   write |
   variavel_atribuicao atribuicao_chamada_procedimento
;

atribuicao_chamada_procedimento:
   atribuicao | chama_procedure 
;
atribuicao:
   ATRIBUICAO expressao
   { 
      if (tipo_variavel_atribuicao != remove_pilha(pilhaExpr))
         imprimeErro("Atribuicao com tipo de variavel invalido");
      
      adicionaCodigoArmazena(variavel_atribuicao);
   }
;

variavel_atribuicao:
   IDENT 
   {
      printf("entro aqui %s\n", token); 
      variavel_atribuicao = obtemSimbolo(token);
      tipo_variavel_atribuicao = variavel_atribuicao->tipo;
   } 
;

chama_procedure:
   {
      procedimento = variavel_atribuicao;
      if (!procedimento) {
         imprimeErro("Procedure não encontrada.");
      }
      
      adicionaCodigoChamaProcedimento(procedimento->rotulo, nivel_lexico);
   }
;

read_idents:
   read_idents VIRGULA IDENT 
   { 
      adicionaCodigoLeitura(obtemSimbolo(token)); 
   } 
   | IDENT 
   { 
      adicionaCodigoLeitura(obtemSimbolo(token)); 
   } 
;

read:
   READ 
   ABRE_PARENTESES 
   read_idents
   FECHA_PARENTESES 
;

write_idents:
   write_idents VIRGULA IDENT 
   { 
      adicionaCodigoEscrita(obtemSimbolo(token)); 
   } 
   | IDENT 
   { 
      adicionaCodigoEscrita(obtemSimbolo(token)); 
   }
   | write_idents VIRGULA NUMERO 
   { 
      adicionaCodigoEscritaConstante(token); 
   } 
   | NUMERO 
   { 
      adicionaCodigoEscritaConstante(token); 
   }
;

write:
   WRITE 
   ABRE_PARENTESES 
   write_idents
   FECHA_PARENTESES 
;

cond_while:
   WHILE 
   { 
      rotulo_atual = criaRotulo();
      insere_pilha(pilhaRot, rotulo_atual);
      adicionaCodigoNada(rotulo_atual); 
   } 
   expressao 
   { 
      rotulo_atual = criaRotulo();
      insere_pilha(pilhaRot, rotulo_atual);
      adicionaDesviaSeFalso(rotulo_atual); 
   }
   DO 
   comando_sem_rotulo 
   { 
      rotulo_atual = remove_pilha(pilhaRot);

      adicionaCodigoDesviaSempre(remove_pilha(pilhaRot)); 
      adicionaCodigoNada(rotulo_atual); 
   }
;

cond_if: 
   if_then cond_else
   {
      adicionaCodigoNada(remove_pilha(pilhaRot));
   } 
;

if_then: 
   IF expressao 
   {
      rotulo_atual = criaRotulo();
      insere_pilha(pilhaRot, rotulo_atual);
      adicionaDesviaSeFalso(rotulo_atual); 
   }
   THEN comando_sem_rotulo
   {
      // pular o else
      rotulo_atual = criaRotulo();
      adicionaCodigoDesviaSempre(rotulo_atual);
      adicionaCodigoNada(remove_pilha(pilhaRot));
      insere_pilha(pilhaRot, rotulo_atual);
   }
;

cond_else: 
   ELSE comando_sem_rotulo
   | %prec LOWER_THAN_ELSE
;

variavel:
   IDENT 
   {
      variavel = obtemSimbolo(token);
      tipo_variavel = variavel->tipo;
   }
;

numero:
   NUMERO
   {
      tipo_variavel = TIPO_INTEGER;

      adicionaCodigoCarregaConstante(token);
   }
;

boolean:
   TRUE 
   {
      tipo_variavel = TIPO_BOOLEAN;
      adicionaCodigoCarregaConstante("1");
   } 
   | FALSE
   {
      tipo_variavel = TIPO_BOOLEAN;
      adicionaCodigoCarregaConstante("0");
   }
;
expressao: 
   expressao relacao expressao_simples 
   {
      tipo_relacao = remove_pilha(pilhaRelac);
      verificaRelacao(pilhaExpr, pilhaExpr, tipo_relacao);
      adicionaCodigoRelacao(tipo_relacao);
      printf("expressao %d \n", tipo_relacao);
   } |
   expressao_simples { printf("expressao simples direta\n");}
;

expressao_simples:
   expressao_simples operacao termo 
   {
      tipo_operacao = remove_pilha(pilhaOpers);
      verificaOperacao(pilhaExpr, pilhaTermo, tipo_operacao);
      adicionaCodigoOperacao(tipo_operacao);

   } |
   termo_com_sinal {insere_pilha(pilhaExpr, remove_pilha(pilhaTermo)); printf("termsosinal\n");}
;

relacao:
   IGUAL { insere_pilha(pilhaRelac, RELACAO_IGUAL); } | 
   DIFERENTE  { insere_pilha(pilhaRelac, RELACAO_DIFERENTE); }| 
   MENOR  { insere_pilha(pilhaRelac, RELACAO_MENOR); } | 
   MENOR_IGUAL  { insere_pilha(pilhaRelac, RELACAO_MENOR_IGUAL); } | 
   MAIOR_IGUAL  { insere_pilha(pilhaRelac, RELACAO_MAIOR_IGUAL); } | 
   MAIOR  { insere_pilha(pilhaRelac, RELACAO_MAIOR); }
;

termo_com_sinal: 
   MAIS termo 
   {
      tipo_termo = remove_pilha(pilhaTermo);
      if (tipo_termo != TIPO_INTEGER)
         imprimeErro("Sinal inválido para o termo");

      insere_pilha(pilhaTermo, tipo_termo);
   } |
   MENOS termo 
   {
      tipo_termo = remove_pilha(pilhaTermo);
      if (tipo_termo != TIPO_INTEGER)
         imprimeErro("Sinal inválido para o termo");

      insere_pilha(pilhaTermo, tipo_termo);

      adicionaCodigoInverteValor();
   } |
   termo
;

termo:
   termo operacao_fator fator 
   {    
      tipo_operacao = remove_pilha(pilhaOpers);
      verificaOperacao(pilhaTermo, pilhaFator, tipo_operacao);
      adicionaCodigoOperacao(tipo_operacao);
   } |
   fator {insere_pilha(pilhaTermo, remove_pilha(pilhaFator)); printf("fator\n");}
;

fator:
   variavel {
      adicionaCodigoCarregaValor(variavel);
      insere_pilha(pilhaFator, tipo_variavel); 
   } |
   numero {insere_pilha(pilhaFator, tipo_variavel); } |
   boolean {insere_pilha(pilhaFator, tipo_variavel); } |
   ABRE_PARENTESES expressao FECHA_PARENTESES 
   {insere_pilha(pilhaFator, remove_pilha(pilhaExpr));} |
   NOT fator {
      tipo_fator = remove_pilha(pilhaFator);
      if (tipo_fator != TIPO_BOOLEAN)
         imprimeErro("Operação inválda para o fator");

      insere_pilha(pilhaFator, tipo_fator);

      adicionaCodigoNegaValor();
   } 
;

operacao:
   MAIS 
   {
      insere_pilha(pilhaOpers, OPERACAO_MAIS);
   }
   | MENOS 
   {
      insere_pilha(pilhaOpers, OPERACAO_MENOS);
   }
   | OR 
   {
      insere_pilha(pilhaOpers, OPERACAO_OR);
   }
;


operacao_fator:
   MULTIPLICACAO {insere_pilha(pilhaOpers, OPERACAO_MULT);}|
   DIV {insere_pilha(pilhaOpers, OPERACAO_DIV);}|
   AND  {insere_pilha(pilhaOpers, OPERACAO_AND);}
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

   
   pilhaExpr = cria_pilha();
   pilhaTermo = cria_pilha();
   pilhaFator = cria_pilha();
   pilhaRelac = cria_pilha();
   pilhaOpers = cria_pilha();
   pilhaRot = cria_pilha();
   pilhaNVars = cria_pilha();
/* -------------------------------------------------------------------
 *  Inicia a Tabela de S�mbolos
 * ------------------------------------------------------------------- */
   tabela_simbolos = aloca_tabela_simbolos();
   dmem = 0;
   num_vars = 0;
   deslocamento = 0;
   nivel_lexico = 0;
   num_rotulo = 0;
   yyin=fp;

   yyparse();

   return 0;
}
