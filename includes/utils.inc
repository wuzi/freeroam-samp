/*******************************************************************************
* NOME DO ARQUIVO :        utils.inc
*
* DESCRIÇÃO :
*       Macros e funções uteis para GTA:SA-MP Pawn.
*
* NOTES :
*       -
*
*/

//------------------------------------------------------------------------------

/*
    Macros para som
*/
#define PlayConfirmSound(%0)    PlayerPlaySound(%0,1058,0.0,0.0,0.0)
#define PlaySelectSound(%0)     PlayerPlaySound(%0,1083,0.0,0.0,0.0)
#define PlayCancelSound(%0)     PlayerPlaySound(%0,1084,0.0,0.0,0.0)
#define PlayErrorSound(%0)      PlayerPlaySound(%0,1085,0.0,0.0,0.0)

//------------------------------------------------------------------------------

/*
        ClearPlayerScreen
    DESCRIÇÃO:
        Limpar o chat do jogador.
    args:
        playerid - ID do jogador.
        lines - Quantidade de linhas. (opcional)
*/
stock ClearPlayerScreen(playerid, lines = 100)
{
    for(new i = 0; i < lines; i++)
        SendClientMessage(playerid, -1, " ");
}
