
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
tabela_simbolos_t *pilhaAtrib;

int num_rotulo;
int num_vars;
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
int total_parametros;
int nParams;
int tipo_parametro;
int num_fator;
int parametro_real;

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
pilha_t *pilhaNParams;

void verificaTipos(pilha_t *p1, pilha_t *p2, int tipoComparacao);


int criaRotulo()
{
   return num_rotulo++;
}

simbolo_t *obtemSimbolo(char *token)
{
   simbolo_t *simbolo = busca_simbolo_sem_nivel_lexico(tabela_simbolos, token);

   printf("token = %s\n", token);
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
   bloco PONTO 
   {
      adicionaCodigoDMEM(num_vars);
      geraCodigo (NULL, "PARA");
      
   };

bloco:
   {{ mostra_tabela_simbolos(tabela_simbolos); }}
   parte_declara_vars

   parte_declara_subrotinas

   comando_composto;

parte_declara_vars: var;

parte_declara_subrotinas:
   parte_declara_subrotinas declara_subrotina | 
;
declara_subrotina:
   {
      nivel_lexico++;
      insere_pilha(pilhaRot, (rotulo_atual = criaRotulo()));
      adicionaCodigoDesviaSempre(rotulo_atual);
      adicionaCodigoEntraProcedimento((rotulo_atual = criaRotulo()), nivel_lexico);
      insere_pilha(pilhaNVars, num_vars);
      total_parametros=0;
   } 
   declara_tipo_subrotina
   { 
      adicionaCodigoDMEM(num_vars); 
      adicionaCodigoRetornaProcedimento(nivel_lexico, total_parametros);

      nivel_lexico--;
      num_vars = remove_pilha(pilhaNVars);
      adicionaCodigoNada(remove_pilha(pilhaRot));
   }
;

declara_tipo_subrotina:
   declara_procedimento | declara_funcao
;


declara_funcao:
   declara_funcao_sem_ponto_virgula PONTO_E_VIRGULA | 
   declara_funcao_sem_ponto_virgula
;

declara_funcao_sem_ponto_virgula:
   FUNCTION IDENT 
   {
      if (busca_simbolo(tabela_simbolos, token, nivel_lexico)) {
         imprimeErro("Simbolo já existente na tabela de simbolos");
      }

      novo_simbolo = cria_simbolo_procedure(token, FUNCAO, nivel_lexico, rotulo_atual);
      adiciona_simbolo_tabela_simbolos(novo_simbolo, tabela_simbolos);
       
   } lista_parametros_formais DOIS_PONTOS tipo 
   {
      atualiza_retorno_funcao(tabela_simbolos, tipo_variavel);
   }
   PONTO_E_VIRGULA
   { num_vars = 0; }
   bloco
   {
      remove_multiplos_simbolos(tabela_simbolos, num_vars);
   }
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

      novo_simbolo = cria_simbolo_procedure(token, PROCEDIMENTO, nivel_lexico, rotulo_atual);
      adiciona_simbolo_tabela_simbolos(novo_simbolo, tabela_simbolos);
       
   } lista_parametros_formais PONTO_E_VIRGULA
   { num_vars = 0; }
   bloco
   {
      remove_multiplos_simbolos(tabela_simbolos, num_vars);
   }
;

lista_parametros_formais: 
   ABRE_PARENTESES sessoes_parametros_formais FECHA_PARENTESES 
   {
      nParams=0;
      while ((nParams = remove_pilha(pilhaNParams)) != -1)
         total_parametros+=nParams;
      
      atualiza_deslocamento_parametros_formais(tabela_simbolos,total_parametros);
   } |
;

sessoes_parametros_formais: 
   sessoes_parametros_formais PONTO_E_VIRGULA parametros_formais_valor_ou_referencia |
   parametros_formais_valor_ou_referencia
;

parametros_formais_valor_ou_referencia:
   VAR { tipo_parametro = 10; } parametros_formais | { tipo_parametro = 0;} parametros_formais 
;

parametros_formais: 
   {num_vars = 0; }
   lista_id_parametros_formais DOIS_PONTOS tipo 
   {
      atualiza_tipo_variaveis_tabela_simbolos(tabela_simbolos, tipo_variavel + tipo_parametro, num_vars);

      insere_pilha(pilhaNParams, num_vars);
   }
;

lista_id_parametros_formais: 
   lista_id_parametros_formais VIRGULA parametro_formal | 
   parametro_formal 
;

parametro_formal: 
   IDENT { 
      if (busca_simbolo(tabela_simbolos, token, nivel_lexico)) {
         imprimeErro("Simbolo já existente na tabela de simbolos");
      }

      num_vars++;

      novo_simbolo = cria_simbolo(token, PARAMETRO_FORMAL, nivel_lexico, 0, TIPO_UNDEFINED, 0);
      adiciona_simbolo_tabela_simbolos(novo_simbolo, tabela_simbolos);
   }
;

var: 
   VAR {num_vars=0; deslocamento=0;} declara_vars | ;

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
   BOOLEAN 
   { tipo_variavel = TIPO_BOOLEAN; }
;

lista_id_var: 
   lista_id_var VIRGULA IDENT
   {
      if (busca_simbolo(tabela_simbolos, token, nivel_lexico)) {
         imprimeErro("Simbolo já existente na tabela de simbolos");
      }

      num_vars++;
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
   atribuicao | 
   {
      procedimento = variavel_atribuicao;
      if (!procedimento) {
         imprimeErro("Procedure não encontrada.");
      }      
   } 
   chama_procedure 
   {
      adicionaCodigoChamaProcedimento(procedimento->rotulo, nivel_lexico);
   }
;
atribuicao:
   ATRIBUICAO expressao
   { 
      if (!comparaTipoExpressao(tipo_variavel_atribuicao, remove_pilha(pilhaExpr)) )
         imprimeErro("Atribuicao com tipo de variavel invalido");
      
      if ((variavel_atribuicao->tipo > 9)){
         adicionaCodigoArmazenaIndireto(variavel_atribuicao);
      }
      else{
         adicionaCodigoArmazena(variavel_atribuicao);
      }
   }
;

variavel_atribuicao:
   IDENT 
   {
      variavel_atribuicao = obtemSimbolo(token);
      tipo_variavel_atribuicao = variavel_atribuicao->tipo;
      printf("\n\natribuiu %s - %d\n\n", token, variavel_atribuicao->tipo);
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

   write_idents VIRGULA expressao {adicionaCodigoEscrita();} |
   expressao {adicionaCodigoEscrita();}
;

write:
   WRITE 
   ABRE_PARENTESES 
   write_idents
   FECHA_PARENTESES { printf("passaq1222\n\n");}
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
   IF {printf("111\n\n");} expressao {printf("1112\n\n");}
   {
      rotulo_atual = criaRotulo();
      insere_pilha(pilhaRot, rotulo_atual);
      adicionaDesviaSeFalso(rotulo_atual); 
   }
   THEN comando_sem_rotulo
   {
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
      printf("agui\n");
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
   } |
   expressao_simples { printf("passaq13333");}
;

expressao_simples:
   expressao_simples operacao termo 
   {
      tipo_operacao = remove_pilha(pilhaOpers);
      verificaOperacao(pilhaExpr, pilhaTermo, tipo_operacao);
      adicionaCodigoOperacao(tipo_operacao);

   } |
   termo_com_sinal {insere_pilha(pilhaExpr, remove_pilha(pilhaTermo));}
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
   fator {insere_pilha(pilhaTermo, remove_pilha(pilhaFator));}
;

fator:
   variavel_chamada_funcao |
   numero {insere_pilha(pilhaFator, tipo_variavel); num_fator++; } |
   boolean {insere_pilha(pilhaFator, tipo_variavel); num_fator++; } |
   ABRE_PARENTESES  expressao FECHA_PARENTESES
   {
      insere_pilha(pilhaFator, remove_pilha(pilhaExpr)); 
      num_fator++;
   } |
   NOT fator {
      tipo_fator = remove_pilha(pilhaFator);
      if (tipo_fator != TIPO_BOOLEAN)
         imprimeErro("Operação inválda para o fator");

      insere_pilha(pilhaFator, tipo_fator);

      adicionaCodigoNegaValor();

      num_fator++;
   }
   
;

variavel_chamada_funcao:
   variavel    
   {
      printf("passaq1\n\n");
      if(variavel_atribuicao){
         if (variavel->categoria == FUNCAO) {
            
            adicionaCodigoAMEM(1);
            num_fator += 2;
            insere_pilha(pilhaFator, variavel_atribuicao->tipo);
            adicionaCodigoChamaProcedimento(variavel_atribuicao->rotulo, nivel_lexico); 
         } else {
            if (parametro_real){
               printf("\n\n\n\n\n\n\n\n------%d %d %d \n\n",parametro_real , variavel_atribuicao->tiposParametros[nParams], variavel->tipo);
            }
            printf("\n\n\n\n\n\n\n\n------%d  \n\n",parametro_real);

            if (parametro_real && (variavel_atribuicao->tiposParametros[nParams] > 9) && variavel->tipo < 10 ){
               adicionaCodigoCarregaEndereco(variavel);
            }else if(variavel_atribuicao->parametros > 0 && variavel->tipo > 9 && variavel_atribuicao->tiposParametros[nParams] < 10) {
               adicionaCodigoCarregaValorIndireto(variavel);
            }else {
               adicionaCodigoCarregaValor(variavel);
            }
            
            insere_pilha(pilhaFator, tipo_variavel); 
            num_fator++;
         }
      } else {
         printf("passaqzz\n\n");
         adicionaCodigoCarregaValor(variavel);
         num_fator++;
         insere_pilha(pilhaFator, tipo_variavel); 
      }
         
   } 
   | variavel    
   {
      num_fator += 2;
      adicionaCodigoAMEM(1); 
   } 
   chama_funcao
;

chama_procedure:
   {
      if (variavel_atribuicao->categoria != PROCEDIMENTO) {
         imprimeErro("Função precisa ser atribuida a alguma variável");
      } 
   }
   ABRE_PARENTESES 
   {
      insere_pilha(pilhaNParams, nParams);
      nParams=0;
   }
   lista_parametros_reais FECHA_PARENTESES 
   {
      printf("fecha parenteses chama procedure\n");
      if (nParams != variavel_atribuicao->parametros)
         imprimeErro("Chamada de procedure com número incorreto de parâmetros");

      nParams = remove_pilha(pilhaNParams);
   } |
;

chama_funcao:
   ABRE_PARENTESES 
   { 
      printf("------------------nparams %d\n\n", nParams);
      insere_pilha(pilhaNParams, nParams);
      nParams=0; 
      printf("------------------nparams %d\n\n", nParams);
      adiciona_simbolo_tabela_simbolos(variavel_atribuicao, pilhaAtrib);
      variavel_atribuicao = variavel;
   } 
   lista_parametros_reais {printf("------------------nparams %d\n\n", nParams);} FECHA_PARENTESES 
   {
      if (nParams != variavel_atribuicao->parametros)
         imprimeErro("Chamada de funcao com número incorreto de parâmetros");

      adicionaCodigoChamaProcedimento(variavel_atribuicao->rotulo, nivel_lexico); 

      variavel_atribuicao = remove_simbolo_tabela_simbolos(pilhaAtrib);
 
      tipo_variavel_atribuicao = variavel_atribuicao->tipo;
      nParams = remove_pilha(pilhaNParams);
      insere_pilha(pilhaFator, variavel_atribuicao->tipo); 
     
   } 
;

lista_parametros_reais:
   lista_parametros_reais VIRGULA parametro_real |
   parametro_real 
;

parametro_real: 
   { 
      num_fator = 0; 
      parametro_real = 1; 
      printf("antes aqui %d\n",  num_fator);
      // adiciona_simbolo_tabela_simbolos(variavel_atribuicao, pilhaAtrib);
      // variavel_atribuicao = NULL;
   } 
   expressao 
   {
      // variavel_atribuicao = remove_simbolo_tabela_simbolos(pilhaAtrib);

      parametro_real = 0;
      if ((variavel_atribuicao->parametros == 0 || nParams > variavel_atribuicao->parametros))
         imprimeErro("Chamada de subrotina com número incorreto de parâmetros");

      if (variavel_atribuicao->tiposParametros[nParams] > 9 && num_fator != 1 )
         imprimeErro("Não é permitido expressões no parâmetro passada como referência");

      if(!comparaTipoExpressao(variavel_atribuicao->tiposParametros[nParams], tipo_variavel)) 
         imprimeErro("Parâmetro de tipo inválido");

      nParams++;

      printf("antes depois\n");
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
   pilhaNParams = cria_pilha();
   pilhaAtrib = aloca_tabela_simbolos();
/* -------------------------------------------------------------------
 *  Inicia a Tabela de S�mbolos
 * ------------------------------------------------------------------- */
   tabela_simbolos = aloca_tabela_simbolos();
   num_vars = 0;
   deslocamento = 0;
   nivel_lexico = 0;
   num_rotulo = 0;
   parametro_real = 0;
   yyin=fp;

   yyparse();

   return 0;
}
