/*******************************************************************************
* NOME DO ARQUIVO :        modules/gameplay/chat.pwn
*
* DESCRIÇÃO :
*       Comandos apenas usados por administradores.
*
* NOTAS :
*       -
*/

//------------------------------------------------------------------------------

#include <YSI\y_hooks>

//------------------------------------------------------------------------------

hook OnPlayerText(playerid, text[])
{
    if(!IsPlayerLogged(playerid))
    {
        SendClientMessage(playerid, COLOR_ERROR, "* Você não está logado.");
        return -1;
    }
    else if(IsPlayerMuted(playerid))
    {
        SendClientMessage(playerid, COLOR_ERROR, "* Você está mutado.");
        return -1;
    }
    else if(GetPlayerAdminLevel(playerid) >= PLAYER_RANK_RECRUIT && strfind(text, "@", true) == 0 && strlen(text) > 1)
	{
		strdel(text, 0, 1);
		new message[200];
		format(message, 200, "@ [{%06x}%s{ededed}] %s: {e3e3e3}%s", GetPlayerRankColor(playerid) >>> 8, GetPlayerAdminRankName(playerid, true), GetPlayerNamef(playerid), text);
		SendAdminMessage(PLAYER_RANK_RECRUIT, 0xedededff, message);
		return -1;
	}
    else
    {
        new message[144];
        format(message, sizeof(message), "%s (%i): {ffffff}%s", GetPlayerNamef(playerid), playerid, text);
        SendClientMessageToAll(GetPlayerColor(playerid), message);
    }
    return -1;
}
