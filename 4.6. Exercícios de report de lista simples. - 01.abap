------------------------------------------------------------------------------------------------------------------------------
1.

*&---------------------------------------------------------------------*
*& Report ZREPORT_1
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zreport_1.

TABLES kna1. "Mestre de clientes

DATA: t_kna1 TYPE STANDARD TABLE OF kna1, "Tabela Interna - Mestre de Clientes
      ls_kna1 TYPE kna1.                  "Estrutura da Tabela Interna

SELECT *                      "Selecione tudo 
    FROM kna1                 "Da Tabela Mestre de Clientes
    INTO TABLE t_kna1         "Na Tabela Interna
    WHERE name1 LIKE 'A%' OR  "Onde os nomes são vogais....
          name1 LIKE 'E%' OR
          name1 LIKE 'I%' OR
          name1 LIKE 'O%' OR
          name1 LIKE 'U%' OR
          name1 LIKE 'a%' OR
          name1 LIKE 'e%' OR
          name1 LIKE 'i%' OR
          name1 LIKE 'o%' OR
          name1 LIKE 'u%'.

WRITE: '----------------------------------------------'.

"imprime os valores da tabela interna.
LOOP AT t_kna1 INTO ls_kna1.
  
  WRITE: / 'Nª Cliente: ', ls_kna1-kunnr.
  WRITE: / 'Nome: ', ls_kna1-name1.
  WRITE: / 'Rua e Nª', ls_kna1-stras.
  WRITE: / 'Local: ', ls_kna1-ort01.
  WRITE: / 'Data de Criação: ', ls_kna1-erdat.
  WRITE: / '----------------------------------------------'.
  
ENDLOOP.
