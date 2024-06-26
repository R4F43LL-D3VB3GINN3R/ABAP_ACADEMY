*&---------------------------------------------------------------------*
*& Report ZREPORT_6
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zreport_6.

TABLES: cepc,  "Tabela Transparente - Dados Mestres de Centros de Lucro
        cepct, "Tabela Transparente - Textos de Dados Mestres de Centro de Lucro
        tka01. "Áreas de Contabilidade de Custos

"------------------------------------------------------------------------------------------------------------------------"
"------------------------------------------------------------------------------------------------------------------------"
"------------------------------------------------------------------------------------------------------------------------"
"Variáveis, Estruturas e Tabelas

TYPES: BEGIN OF ty_cepc, "Estrutura - Dados Mestres de Centros de Lucro
  prctr TYPE cepc-prctr, "Centro de Lucro
  datbi TYPE cepc-datbi, "Data de Validade Final
  kokrs TYPE cepc-kokrs, "Área de Contabilidade de Custos
  datab TYPE cepc-datab, "Data Início Validade
  usnam TYPE cepc-usnam, "Criado Por
END OF ty_cepc.

DATA: t_cepc  TYPE TABLE OF ty_cepc, "Tabela Interna - Estrutura - Dados Mestres de Centros de Lucro
      ls_cepc TYPE ty_cepc.          "Estrutura - Estrutura - Dados Mestres de Centros de Lucro

TYPES: BEGIN OF ty_cepct, "Estrutura - Dados Mestres de Centros de Lucro
  prctr TYPE cepct-prctr, "Centro de Lucro
  datbi TYPE cepct-datbi, "Data de Validade Final
  kokrs TYPE cepct-kokrs, "Área de Contabilidade de Custos
  ltext TYPE cepct-ltext, "Texto Descritivo
END OF ty_cepct.

DATA: t_cepct  TYPE TABLE OF ty_cepct, "Tabela Interna - Estrutura - Dados Mestres de Centros de Lucro
      ls_cepct TYPE ty_cepct.          "Estrutura - Estrutura - Dados Mestres de Centros de Lucro

TYPES: BEGIN OF ty_tka01, "Estrutura - Áreas de Contabilidade de Custos
  kokrs TYPE tka01-kokrs, "Área de Contabilidade de Custos
  bezei TYPE tka01-bezei, "Denominação da Área de Contabilidade de Custos
END OF ty_tka01.

DATA: t_tka01  TYPE TABLE OF ty_tka01, "Tabela Interna - Estrutura - Áreas de Contabilidade de Custos
      ls_tka01 TYPE ty_tka01.          "Estrutura - Estrutura - Áreas de Contabilidade de Custos

TYPES: BEGIN OF ty_output, "Estrutura de Saída
  prctr TYPE cepc-prctr,   "Centro de Lucro
  usnam TYPE cepc-usnam,   "Criado Por
  datab TYPE cepc-datab,   "Data Início Validade
  datbi TYPE cepct-datbi,  "Data de Validade Final
  kokrs TYPE cepct-kokrs,  "Área de Contabilidade de Custos
  ltext TYPE cepct-ltext,  "Texto Descritivo
  bezei TYPE tka01-bezei,  "Denominação da Área de Contabilidade de Custos
END OF ty_output.

DATA: t_output  TYPE TABLE OF ty_output, "Tabela Interna - Estrutura de Saída
      ls_output TYPE ty_output.          "Estrutura - Estrutura - Estrutura de Saída

DATA: lv_count TYPE i,
      lv_count2 TYPE i,
      lv_last_prctr TYPE cepct-prctr,
      lv_last_kokrs TYPE cepct-kokrs,
      lv_total_reg TYPE i.

lv_count = 0.
lv_count2 = 0.
lv_total_reg = 0.

"------------------------------------------------------------------------------------------------------------------------"
"------------------------------------------------------------------------------------------------------------------------"
"------------------------------------------------------------------------------------------------------------------------"

*6 - Elaborar um programa ABAP onde deverá ser criada uma tela de seleção com
*o Centro de lucro como seleção múltipla e a Área de contabilidade de custos também
*como seleção múltipla. Seus tipos se encontram na tabela CEPC.

SELECTION-SCREEN SKIP 1.
SELECTION-SCREEN BEGIN OF BLOCK a1 WITH FRAME TITLE TEXT-001.
  SELECT-OPTIONS s_prctr FOR cepc-prctr. "Campo de Escolha Múltipla - Centro de Lucro
  SELECT-OPTIONS s_kokrs FOR cepc-kokrs. "Campo de Escolha Múltipla - Área de Contabilidade de Custos
SELECTION-SCREEN END OF BLOCK a1.
SELECTION-SCREEN SKIP 1.

START-OF-SELECTION.
  PERFORM get_data.
  PERFORM fill_data.
  PERFORM display_data.
END-OF-SELECTION.

*&---------------------------------------------------------------------*
*& Form get_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_data .

*Selecionar na tabela CEPC todos os Centros de lucro e Área de contabilidade de
*custos que estiverem de acordo com os dois campos da tela de seleção e a Data de
*validade final for igual a 31.12.9999, retornando os campos Centro de lucro, Data de
*validade final, Área de contabilidade de custos, Data início validade e Criado por.

SELECT prctr, "Selecione Centro de Lucro
       datbi, "Data de Validade Final
       kokrs, "Área de Contabilidade de Custos
       datab, "Data Início Validade
       usnam  "Criado Por
       FROM cepc "Da Tabela Transparente - Dados Mestres de Centros de Lucro
       INTO CORRESPONDING FIELDS OF TABLE @t_cepc "Nos campos correspondetes da Tabela Interna - Dados Mestres de Centros de Lucro
       WHERE prctr IN @s_prctr "Onde Centro de Lucro estiver no range do campo de múltipla escolha
       AND kokrs IN @s_kokrs "E onde a Área de Contabilidade de Custos estiver no range do campo de múltipla escolha
       AND datbi = '99991231'.

*Para cada registro encontrado na tabela CEPC, selecionar na tabela CEPCT as
*descrições dos Centros de lucro, onde Código de idioma = ‘PT’ e as duas tabelas são
*relacionadas pelos campos Centro de lucro, Data de validade final e Área de
*contabilidade de custos, retornando os campos Centro de lucro, Data de validade final,
*Área de contabilidade de custos e Texto descritivo.

SELECT prctr, "Selecione Centro de Lucro
       datbi, "Data de Validade Final
       kokrs, "Área de Contabilidade de Custos
       ltext  "Texto Descritivo
       FROM cepct "Na Tabela Transparente - Dados Mestres de Centros de Lucro
       INTO CORRESPONDING FIELDS OF TABLE @t_cepct "Nos campos correspondentes da Tabela Interna - Dados Mestres de Centros de Lucro
       FOR ALL ENTRIES IN @t_cepc "Relacionada com a Tabela Interna - Dados Mestres de Centros de Lucro
       WHERE prctr = @t_cepc-prctr "Onde as duas possuem os mesmos Centros de Lucros
       AND datbi = @t_cepc-datbi   "E possuem as mesmas Datas de Validade Final
       AND kokrs = @t_cepc-kokrs   "E possuem as memas Áreas de Contabilidade de Custos
       AND spras = 'P'             "E o idioma for Português.
       AND ltext <> ''.            "Haviam algumas descrições vazias na BD, então inseri está cláusula.

*Para cada registro encontrado na tabela CEPC, selecionar na tabela TKA01 as
*descrições das Áreas de contabilidade de custos encontradas onde, o campo Área de
*contabilidade de custos relaciona as duas tabelas. Retornar os campos Área de
*contabilidade de custos e Denominação da área de contabilidade de custos

SELECT kokrs, "Selecione a Área de Contabilidade de Custos
       bezei  "Denominação da Área de Contabilidade de Custos
       FROM tka01 "Da Tabela Transparente - Áreas de Contabilidade de Custos
       INTO CORRESPONDING FIELDS OF TABLE @t_tka01 "Nos campos correspondentes da Tabela Interna - Áreas de Contabilidade de Custos
       FOR ALL ENTRIES IN @t_cepc "Relacionando com os campos da Tabela Interna - Dados Mestres de Centros de Lucro
       WHERE kokrs = @t_cepc-kokrs. "Os a Área de Contabilidade de Custos são iguais.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form fill_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM fill_data .

  "Preenche a Tabela de Saída com os dados das consultas.
  LOOP AT t_cepc INTO ls_cepc.
    READ TABLE t_cepct INTO ls_cepct WITH KEY prctr = ls_cepc-prctr.
      ls_output-prctr = ls_cepc-prctr.  "Centro de Lucro
      ls_output-usnam = ls_cepc-usnam.  "Criado Por
      ls_output-datab = ls_cepc-datab.  "Data Início Validade
      ls_output-datbi = ls_cepct-datbi. "Data de Validade Final
      ls_output-kokrs = ls_cepct-kokrs. "Área de Contabilidade de Custos
      ls_output-ltext = ls_cepct-ltext. "Texto Descritivo
      READ TABLE t_tka01 INTO ls_tka01 WITH KEY kokrs = ls_cepc-kokrs.
        ls_output-bezei = ls_tka01-bezei. "Denominação da Área de Contabilidade de Custos
        APPEND ls_output TO t_output.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form display_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM display_data .

*O relatório deve imprimir todos os Centros de Lucro de cada Área de contabilidade
*de custos selecionada. Para cada Área de contabilidade de custos deverá mostrar um
*contador de Centros de Lucro e no final do relatório a quantidade de registros
*encontrados.

*Imprimir os campos: Área de contabilidade de custos, Denominação da área de
*contabilidade de custos, Centro de lucro, Texto descritivo, Criado por, Data início
*validade, Data de validade final.

  SORT t_output BY kokrs prctr.

  WRITE: / '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'.

  LOOP AT t_output INTO ls_output.
    IF ls_output-kokrs <> lv_last_kokrs.
      IF lv_count2 <> 0.
        WRITE: / 'Total de Centros de Lucro para a Área', lv_last_kokrs, '=', lv_count2.
        WRITE: / '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'.
        lv_count2 = 0.
      ENDIF.
      WRITE: / 'Área de contabilidade de custos:', ls_output-kokrs.
      WRITE: / 'Denominação da área de contabilidade de custos:', ls_output-bezei.
      WRITE: / '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'.
      lv_last_kokrs = ls_output-kokrs.
      lv_count = 0.
    ENDIF.

    IF ls_output-prctr <> lv_last_prctr.
      WRITE: / 'Centro de lucro:', ls_output-prctr,
             / 'Texto descritivo:', ls_output-ltext,
             / 'Criado por:', ls_output-usnam,
             / 'Data início validade:', ls_output-datab,
             / 'Data de validade final:', ls_output-datbi.
      WRITE: / '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'.
      lv_last_prctr = ls_output-prctr.
      lv_count = lv_count + 1.
      lv_count2 = lv_count2 + 1.
      lv_total_reg = lv_total_reg + 1.
    ENDIF.
  ENDLOOP.

  IF lv_count2 <> 0.
    WRITE: / 'Total de Centros de Lucro para a Área', lv_last_kokrs, '=', lv_count2.
    WRITE: / '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'.
  ENDIF.

  WRITE: / 'Total de registros selecionados =', lv_total_reg.
  WRITE: / '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'.

ENDFORM.
