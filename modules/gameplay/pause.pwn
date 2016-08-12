/*******************************************************************************
* NOME DO ARQUIVO :		modules/gameplay/pause.pwn
*
* DESCRIÇÃO :
*	   Detecta se o jogador está pausado ou não.
*
* NOTAS :
*	   -
*/

#include <YSI\y_hooks>

static gPlayerTickCount[MAX_PLAYERS];

//------------------------------------------------------------------------------

hook OnPlayerUpdate(playerid)
{
    gPlayerTickCount[playerid] = GetTickCount();
    return 1;
}

//------------------------------------------------------------------------------

IsPlayerPaused(playerid)
{
    return ((gPlayerTickCount[playerid] + 3000) < GetTickCount());
}

//------------------------------------------------------------------------------

GetPlayerPausedTime(playerid)
{
    return gPlayerTickCount[playerid];
}
