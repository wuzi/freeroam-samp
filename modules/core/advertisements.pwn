/*******************************************************************************
* NOME DO ARQUIVO :        modules/core/ads.pwn
*
* DESCRIÇÃO :
*       Envia anúncios pre-definidos a cada x segundos para todos no servidor.
*
* NOTAS :
*       -
*/

#include <YSI\y_hooks>

static messages[][] = {
    "Para ver as vantagens VIP digite '{f00c0c}/vantagensvip{FFFFFF}'.",
    "Está com dúvidas? Digite '{f00c0c}/cmds{FFFFFF}' ou peça ajuda a um administrador {f00c0c}/admins{FFFFFF}.",
    "Viu um cheater? Contate a um administrador usando '{f00c0c}/reportar{FFFFFF}'."
};

task SendGlobalAdvertise[ADVERTISE_INTERVAL]()
{
    foreach(new i: Player)
    {
        if(!IsPlayerInTutorial(i) && GetPlayerGamemode(i) != GAMEMODE_LOBBY)
        {
            SendClientMessage(i, COLOR_WHITE, messages[random(sizeof(messages))]);
        }
    }
}

//------------------------------------------------------------------------------

static hostnames[][] = {
    "« LF - Liberty Freeroam (0.3.7) »"
};

task UpdateHostName[UPDATE_HOSTNAME_INTERVAL]()
{
    new cmd[128];
    format(cmd, sizeof(cmd), "hostname            %s", hostnames[random(sizeof(hostnames))]);
    SendRconCommand(cmd);
}

hook OnGameModeInit()
{
    UpdateHostName();
    return 1;
}
