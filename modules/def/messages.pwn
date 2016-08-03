/*******************************************************************************
* NOME DO ARQUIVO :        modules/def/messages.pwn
*
* DESCRIÇÃO :
*       Adiciona macros para funções relacionadas a mensagens
*
* NOTES :
*       Este arquivo deve conter apenas funções relacionadas a mensagens.
*
* LISTA DE FUNÇÕES :
*			SendClientMessagef
*			SendClientMessageToAllf
*			SendClientLocalMessage
*			SendMultiLineMessage
*			SendMultiLineMessageToAll
*
*/

//------------------------------------------------------------------------------

stock SendClientMessagef(playerid, color, const message[], va_args<>)
{
   new string[145];
   va_format(string, sizeof(string), message, va_start<3>);
   return SendClientMessage(playerid, color, string);
}

stock SendClientMessageToAllf(color, const message[], va_args<>)
{
   new string[145];
   va_format(string, sizeof(string), message, va_start<2>);
   return SendClientMessageToAll(color, string);
}

//------------------------------------------------------------------------------

stock SendClientLocalMessage(playerid, color, Float:radius, string[])
{
	new Float:fDist[3];
	GetPlayerPos(playerid, fDist[0], fDist[1], fDist[2]);
	SetPlayerChatBubble(playerid, string, color, radius, 5000);
	foreach(new i: Player)
	{
		if(GetPlayerDistanceFromPoint(i, fDist[0], fDist[1], fDist[2]) <= radius && GetPlayerVirtualWorld(i) == GetPlayerVirtualWorld(playerid))
		{
			SendClientMessage(i, color, string);
		}
	}
}

//------------------------------------------------------------------------------

stock SendMultiLineMessage(playerid, color, message[])
{
    if(strlen(message) > 144)
    {
        new
            secondLine[144];

        strmid(secondLine, message, 140, strlen(message));
        strdel(message, 140, strlen(message));
        strins(message, "...", 140, 144);
        strins(secondLine, "...", 0);

        SendClientMessage(playerid, color, message);
        SendClientMessage(playerid, color, secondLine);
    }
    else
        SendClientMessage(playerid, color, message);
    return 1;
}

stock SendMultiLineMessageToAll(color, message[])
{
    if(strlen(message) > 144)
    {
        new
            secondLine[144];

        strmid(secondLine, message, 140, strlen(message));
        strdel(message, 140, strlen(message));
        strins(message, "...", 140, 144);
        strins(secondLine, "...", 0);

        SendClientMessageToAll(color, message);
        SendClientMessageToAll(color, secondLine);
    }
    else
        SendClientMessageToAll(color, message);
    return 1;
}
