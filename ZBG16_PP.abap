*&---------------------------------------------------------------------*
*& Report ZBG16_PP
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZBG16_PP.

"Includes do programa
INCLUDE ZBG16_PP_TOP.
INCLUDE ZBG16_PP_CLASSES.

"Includes das telas
INCLUDE ZBG16_PP_STATUS_01000001.
INCLUDE ZBG16_PP_USER_COMMAND_I01.
INCLUDE ZBG16_PP_DISPLAY_ALV001.
INCLUDE zbg16_pp_status_0200o01.
INCLUDE zbg16_pp_display_vendas_alvo01.
INCLUDE zbg16_pp_user_command_0200i01.
INCLUDE zbg16_pp_display_vendas_filo01.
INCLUDE zbg16_pp_status_0300o01.
INCLUDE zbg16_pp_user_command_0300i01.
INCLUDE zbg16_pp_display_dados_empro01.
INCLUDE zbg16_pp_display_produtos_eo01.

"Começar com o programa
START-OF-SELECTION.
NEW lcl_pp( )->init( ).
