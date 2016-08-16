/*******************************************************************************
* NOME DO ARQUIVO :        modules/admin/commands.pwn
*
* DESCRIÇÃO :
*       Comandos apenas usados por administradores.
*
* NOTAS :
*       -
*/

#include <YSI\y_hooks>

//------------------------------------------------------------------------------

static bool:gAdminDuty[MAX_PLAYERS] = {true, ...};

forward OnDeleteAccount(playerid);

enum e_survey_data
{
    e_survey_question[128],
    e_survey_yes,
    e_survey_no,
    e_survey_active
}
static gSurveyData[e_survey_data];

//------------------------------------------------------------------------------

// Recomendável manter a lista em até 10 linhas, para melhor visualização
YCMD:acmds(playerid, params[], help)
{
    if(GetPlayerAdminLevel(playerid) < PLAYER_RANK_RECRUIT)
 		return SendClientMessage(playerid, COLOR_ERROR, "* Você não tem permissão.");

    new output[2088];
	if(GetPlayerAdminLevel(playerid) >= PLAYER_RANK_RECRUIT)
    {
        strcat(output, "{229f09}Nível 1\n{FFFFFF}/jogar - /trabalhar - /servico - /infoplayer - /verip - /avisar - /destrancarcarros - /kickar\n");
        strcat(output, "/tapa - /assistir - /passistir - /texto - /a - /particular - /players - /contagem - /limparchat\n");
        strcat(output, "/trazer - /setskin - /irpos - /pdist - /say - /fakekick\n\n");
    }

	if(GetPlayerAdminLevel(playerid) >= PLAYER_RANK_HELPER)
    {
        strcat(output, "{229f09}Nível 2\n{FFFFFF}/banir - /setarinterior - /setarvw - /advertir - /jetpack - /setarvida - /setarcolete - /congelar - /descongelar\n");
        strcat(output, "/dararma - /desarmar - /respawn - /destruircarro - /calar - /descalar - /forcarcarro - /forcarskin - /trazertodos - /moverplayer\n");
        strcat(output, "/fakeban\n\n");
    }

	if(GetPlayerAdminLevel(playerid) >= PLAYER_RANK_MODERATOR)
    {
        strcat(output, "{229f09}Nível 3\n{FFFFFF}/rtc - /ircar - /puxarcar - /tempo - /climatodos - /ejetarp - /setarpos - /setarpontos - /verpos\n");
        strcat(output, "/banip - /unbanip - /crash - /setarcor - /setarnome - /setarskin - /godmode - /enquete\n\n");
    }

	if(GetPlayerAdminLevel(playerid) >= PLAYER_RANK_SUB_OWNER)
    {
        strcat(output, "{229f09}Nível 4\n{FFFFFF}/gmx - /criarcorrida - /criardm - /criarevento - /setmoney - /setbanco - /setvip - /gerarchavevip - /kickartodos\n");
        strcat(output, "/desarmartodos - /chatfalso - /invisivel - /visivel - /interiortodos - /congelartodos - /descongelartodos - /ips - /matartodos\n");
        strcat(output, "/darvip - /tirarvip - /deletarconta\n\n");
    }

	if(GetPlayerAdminLevel(playerid) >= PLAYER_RANK_OWNER)
    {
        strcat(output, "{229f09}Nível 5\n{FFFFFF}/setadmin - /trancarserver - /destrancarserver - /nomegm - /nomeserver - /nomemapa - /setargravidade\n");
        strcat(output, "/abuildingcmds");
    }

    ShowPlayerDialog(playerid, DIALOG_ADMIN_COMMANDS, DIALOG_STYLE_MSGBOX, "{59c72c}LF - {FFFFFF}Comandos administrativos", output, "Fechar", "");
	return 1;
}

/*


RRRRRRRRRRRRRRRRR   EEEEEEEEEEEEEEEEEEEEEE       CCCCCCCCCCCCCRRRRRRRRRRRRRRRRR   UUUUUUUU     UUUUUUUUIIIIIIIIIITTTTTTTTTTTTTTTTTTTTTTT
R::::::::::::::::R  E::::::::::::::::::::E    CCC::::::::::::CR::::::::::::::::R  U::::::U     U::::::UI::::::::IT:::::::::::::::::::::T
R::::::RRRRRR:::::R E::::::::::::::::::::E  CC:::::::::::::::CR::::::RRRRRR:::::R U::::::U     U::::::UI::::::::IT:::::::::::::::::::::T
RR:::::R     R:::::REE::::::EEEEEEEEE::::E C:::::CCCCCCCC::::CRR:::::R     R:::::RUU:::::U     U:::::UUII::::::IIT:::::TT:::::::TT:::::T
R::::R     R:::::R  E:::::E       EEEEEEC:::::C       CCCCCC  R::::R     R:::::R U:::::U     U:::::U   I::::I  TTTTTT  T:::::T  TTTTTT
R::::R     R:::::R  E:::::E            C:::::C                R::::R     R:::::R U:::::D     D:::::U   I::::I          T:::::T
R::::RRRRRR:::::R   E::::::EEEEEEEEEE  C:::::C                R::::RRRRRR:::::R  U:::::D     D:::::U   I::::I          T:::::T
R:::::::::::::RR    E:::::::::::::::E  C:::::C                R:::::::::::::RR   U:::::D     D:::::U   I::::I          T:::::T
R::::RRRRRR:::::R   E:::::::::::::::E  C:::::C                R::::RRRRRR:::::R  U:::::D     D:::::U   I::::I          T:::::T
R::::R     R:::::R  E::::::EEEEEEEEEE  C:::::C                R::::R     R:::::R U:::::D     D:::::U   I::::I          T:::::T
R::::R     R:::::R  E:::::E            C:::::C                R::::R     R:::::R U:::::D     D:::::U   I::::I          T:::::T
R::::R     R:::::R  E:::::E       EEEEEEC:::::C       CCCCCC  R::::R     R:::::R U::::::U   U::::::U   I::::I          T:::::T
RR:::::R     R:::::REE::::::EEEEEEEE:::::E C:::::CCCCCCCC::::CRR:::::R     R:::::R U:::::::UUU:::::::U II::::::II      TT:::::::TT
R::::::R     R:::::RE::::::::::::::::::::E  CC:::::::::::::::CR::::::R     R:::::R  UU:::::::::::::UU  I::::::::I      T:::::::::T
R::::::R     R:::::RE::::::::::::::::::::E    CCC::::::::::::CR::::::R     R:::::R    UU:::::::::UU    I::::::::I      T:::::::::T
RRRRRRRR     RRRRRRREEEEEEEEEEEEEEEEEEEEEE       CCCCCCCCCCCCCRRRRRRRR     RRRRRRR      UUUUUUUUU      IIIIIIIIII      TTTTTTTTTTT

*/

//------------------------------------------------------------------------------

YCMD:limparchat(playerid, params[], help)
{
    if(GetPlayerAdminLevel(playerid) < PLAYER_RANK_RECRUIT)
        return SendClientMessage(playerid, COLOR_ERROR, "* Você não tem permissão.");

    foreach(new i: Player)
    {
        if(IsPlayerLogged(i))
        {
            ClearPlayerScreen(i);
        }
    }
    SendClientMessageToAllf(COLOR_ADMIN_COMMAND, "* O administrador %s limpou o chat.", GetPlayerNamef(playerid));
    return 1;
}

//------------------------------------------------------------------------------

YCMD:players(playerid, params[], help)
{
    if(GetPlayerAdminLevel(playerid) < PLAYER_RANK_RECRUIT)
        return SendClientMessage(playerid, COLOR_ERROR, "* Você não tem permissão.");

    new count = 0;
    foreach(new i: Player)
    {
        count++;
    }
    SendClientMessageToAllf(COLOR_ADMIN_COMMAND, "* Players Online: %d / %d", count, GetMaxPlayers());
    return 1;
}

//------------------------------------------------------------------------------

YCMD:jogar(playerid, params[], help)
{
    if(GetPlayerAdminLevel(playerid) < PLAYER_RANK_RECRUIT)
        return SendClientMessage(playerid, COLOR_ERROR, "* Você não tem permissão.");

    gAdminDuty[playerid] = false;
    SendClientMessageToAllf(COLOR_ADMIN_COMMAND, "* O administrador %s agora está jogando.", GetPlayerNamef(playerid));
    return 1;
}

//------------------------------------------------------------------------------

YCMD:trabalhar(playerid, params[], help)
{
    if(GetPlayerAdminLevel(playerid) < PLAYER_RANK_RECRUIT)
        return SendClientMessage(playerid, COLOR_ERROR, "* Você não tem permissão.");

    gAdminDuty[playerid] = true;
    SendClientMessageToAllf(COLOR_ADMIN_COMMAND, "* O administrador %s agora está trabalhando.", GetPlayerNamef(playerid));
    return 1;
}

//------------------------------------------------------------------------------

YCMD:servico(playerid, params[], help)
{
    if(GetPlayerAdminLevel(playerid) < PLAYER_RANK_RECRUIT)
        return SendClientMessage(playerid, COLOR_ERROR, "* Você não tem permissão.");

    if(gAdminDuty[playerid])
    {
        CallRemoteFunction("OnPlayerCommandText", "is", playerid, "/jogar");
    }
    else
    {
        CallRemoteFunction("OnPlayerCommandText", "is", playerid, "/trabalhar");
    }
    return 1;
}

//------------------------------------------------------------------------------

YCMD:destrancarcarros(playerid, params[], help)
{
    if(GetPlayerAdminLevel(playerid) < PLAYER_RANK_RECRUIT)
        return SendClientMessage(playerid, COLOR_ERROR, "* Você não tem permissão.");

    new engine, lights, alarm, doors, bonnet, boot, objective;
    for(new i = 0; i < MAX_VEHICLES; i++)
    {
        GetVehicleParamsEx(i, engine, lights, alarm, doors, bonnet, boot, objective);
        SetVehicleParamsEx(i, engine, lights, alarm, VEHICLE_PARAMS_OFF, bonnet, boot, objective);
    }
    SendClientMessageToAllf(COLOR_ADMIN_COMMAND, "* O administrador %s destrancou todos os veículos.", GetPlayerNamef(playerid));
    return 1;
}

//------------------------------------------------------------------------------

YCMD:assistir(playerid, params[], help)
{
    if(GetPlayerAdminLevel(playerid) < PLAYER_RANK_RECRUIT)
        return SendClientMessage(playerid, COLOR_ERROR, "* Você não tem permissão.");

    else if(GetPlayerGamemode(playerid) != GAMEMODE_FREEROAM)
        return SendClientMessage(playerid, COLOR_ERROR, "* Você só pode usar este comando no freeroam.");

    new targetid;
    if(sscanf(params, "u", targetid))
        return SendClientMessage(playerid, COLOR_INFO, "* /assistir [playerid]");

    else if(!IsPlayerLogged(targetid))
        return SendClientMessage(playerid, COLOR_ERROR, "* O jogador não está conectado.");

    else if(targetid == playerid)
        return SendClientMessage(playerid, COLOR_ERROR, "* Você não pode assistir você mesmo.");

    TogglePlayerSpectating(playerid, true);
    SetPlayerSpecatateTarget(playerid, targetid);
    return 1;
}

//------------------------------------------------------------------------------

YCMD:passistir(playerid, params[], help)
{
    if(GetPlayerAdminLevel(playerid) < PLAYER_RANK_RECRUIT)
        return SendClientMessage(playerid, COLOR_ERROR, "* Você não tem permissão.");

    else if(GetPlayerState(playerid) != PLAYER_STATE_SPECTATING)
        return SendClientMessage(playerid, COLOR_ERROR, "* Você não está assitindo.");

    else if(GetPlayerGamemode(playerid) != GAMEMODE_FREEROAM)
        return SendClientMessage(playerid, COLOR_ERROR, "* Você só pode usar este comando no freeroam.");

    TogglePlayerSpectating(playerid, false);
    return 1;
}

//------------------------------------------------------------------------------

YCMD:texto(playerid, params[], help)
{
    if(GetPlayerAdminLevel(playerid) < PLAYER_RANK_RECRUIT)
        return SendClientMessage(playerid, COLOR_ERROR, "* Você não tem permissão.");

    new message[128];
    if(sscanf(params, "s[128]", message))
        return SendClientMessage(playerid, COLOR_INFO, "* /texto [texto]");

    new output[144];
    format(output, sizeof(output), "~y~%s: ~w~%s", GetPlayerNamef(playerid), message);
    GameTextForAll(output, 2000, 4);
    return 1;
}

//------------------------------------------------------------------------------

YCMD:avisar(playerid, params[], help)
{
    if(GetPlayerAdminLevel(playerid) < PLAYER_RANK_RECRUIT)
        return SendClientMessage(playerid, COLOR_ERROR, "* Você não tem permissão.");

    new message[128];
    if(sscanf(params, "s[128]", message))
        return SendClientMessage(playerid, COLOR_INFO, "* /aviso [texto]");

    new output[144];
    format(output, sizeof(output), "Admin %s [nivel %d]: %s", GetPlayerNamef(playerid), GetPlayerAdminLevel(playerid), message);
    SendClientMessageToAll(COLOR_ADMIN_COMMAND, "________________________AVISO DA ADMINISTRAÇÃO________________________");
    SendClientMessageToAll(COLOR_ADMIN_COMMAND, output);
    return 1;
}

//------------------------------------------------------------------------------

YCMD:a(playerid, params[], help)
{
    if(GetPlayerAdminLevel(playerid) < PLAYER_RANK_RECRUIT)
        return SendClientMessage(playerid, COLOR_ERROR, "* Você não tem permissão.");

    new text[128];
    if(sscanf(params, "s[128]", text))
        return SendClientMessage(playerid, COLOR_INFO, "* /texto [texto]");

    new output[144];
    format(output, 144, "@ [{%06x}%s{ededed}] %s: {e3e3e3}%s", GetPlayerRankColor(playerid) >>> 8, GetPlayerAdminRankName(playerid, true), GetPlayerNamef(playerid), text);
    SendAdminMessage(PLAYER_RANK_RECRUIT, 0xedededff, output);
    return 1;
}

//------------------------------------------------------------------------------

YCMD:verip(playerid, params[], help)
{
    if(GetPlayerAdminLevel(playerid) < PLAYER_RANK_RECRUIT)
        return SendClientMessage(playerid, COLOR_ERROR, "* Você não tem permissão.");

    new targetid;
    if(sscanf(params, "u", targetid))
        return SendClientMessage(playerid, COLOR_INFO, "* /verip [playerid]");

    else if(!IsPlayerLogged(targetid))
        return SendClientMessage(playerid, COLOR_ERROR, "* O jogador não está conectado.");

    new ip[16];
    GetPlayerIp(targetid, ip, 16);
    SendClientMessagef(playerid, COLOR_ADMIN_COMMAND, "* (ID: %i)%s - %s.", targetid, GetPlayerNamef(targetid), ip);
    return 1;
}

//------------------------------------------------------------------------------

YCMD:tapa(playerid, params[], help)
{
    if(GetPlayerAdminLevel(playerid) < PLAYER_RANK_RECRUIT)
        return SendClientMessage(playerid, COLOR_ERROR, "* Você não tem permissão.");

    new targetid;
    if(sscanf(params, "u", targetid))
        return SendClientMessage(playerid, COLOR_INFO, "* /tapa [playerid]");

    else if(!IsPlayerLogged(targetid))
        return SendClientMessage(playerid, COLOR_ERROR, "* O jogador não está conectado.");

    new Float:x, Float:y, Float:z;
    GetPlayerPos(targetid, x, y, z);
    SetPlayerPos(targetid, x, y, z + 2.5);
    PlayerPlaySound(targetid, 1190, 0.0, 0.0, 0.0);

    SendClientMessagef(playerid, COLOR_ADMIN_COMMAND, "* Você deu um tapa em %s.", GetPlayerNamef(targetid));
    SendClientMessagef(targetid, COLOR_ADMIN_COMMAND, "* %s deu um tapa em você.", GetPlayerNamef(playerid));
    return 1;
}

//------------------------------------------------------------------------------

YCMD:infoplayer(playerid, params[], help)
{
    if(GetPlayerAdminLevel(playerid) < PLAYER_RANK_RECRUIT)
        return SendClientMessage(playerid, COLOR_ERROR, "* Você não tem permissão.");

    new targetid;
    if(sscanf(params, "u", targetid))
        return SendClientMessage(playerid, COLOR_INFO, "* /infoplayer [playerid]");

    else if(!IsPlayerLogged(targetid))
        return SendClientMessage(playerid, COLOR_ERROR, "* O jogador não está logado.");

    new output[512], string[128], ip[16];
    GetPlayerIp(targetid, ip, 16);
    format(string, sizeof(string), "{FFFFFF}Dados de {11D41E}%s{FFFFFF}\n\n{11D41E}Grana:{FFFFFF} $%d\n{11D41E}Banco:{FFFFFF} $%d\n{11D41E}Admin Level:{FFFFFF} %d\n{11D41E}Calado:{FFFFFF} %s\n", GetPlayerNamef(targetid), GetPlayerCash(targetid), GetPlayerBankCash(targetid), GetPlayerAdminLevel(targetid), (IsPlayerMuted(targetid)) ? "Sim" : "Não");
    strcat(output, string);

    format(string, sizeof(string), "{11D41E}Advertencias:{FFFFFF} %d \n{11D41E}IP:{FFFFFF} %s", GetPlayerWarning(targetid), ip);
    strcat(output, string);

    ShowPlayerDialog(playerid, DIALOG_INFO_PLAYER, DIALOG_STYLE_MSGBOX, "{59c72c}LF - {FFFFFF}Informações do Player", output, "Fechar", "");
    return 1;
}

//------------------------------------------------------------------------------

YCMD:trazer(playerid, params[], help)
{
    if(GetPlayerAdminLevel(playerid) < PLAYER_RANK_RECRUIT)
        return SendClientMessage(playerid, COLOR_ERROR, "* Você não tem permissão.");

    new targetid;
    if(sscanf(params, "u", targetid))
        return SendClientMessage(playerid, COLOR_INFO, "* /trazer [playerid]");

    else if(!IsPlayerLogged(targetid))
        return SendClientMessage(playerid, COLOR_ERROR, "* O jogador não está conectado.");

    else if(targetid == playerid)
        return SendClientMessage(playerid, COLOR_ERROR, "* Você não pode puxar você mesmo.");

    else if(GetPlayerGamemode(targetid) != GAMEMODE_FREEROAM)
        return SendClientMessage(playerid, COLOR_ERROR, "* Este jogador não está no modo freeroam.");

    new Float:x, Float:y, Float:z;
    GetPlayerPos(playerid, x, y, z);

    SetPlayerInterior(targetid, GetPlayerInterior(playerid));
    SetPlayerVirtualWorld(targetid, GetPlayerVirtualWorld(playerid));
    if(GetPlayerState(targetid) != PLAYER_STATE_DRIVER) { SetPlayerPos(targetid, x, y, z); }
    else
    {
        new vehicleid = GetPlayerVehicleID(targetid);
        SetVehiclePos(vehicleid, x, y, z);
        LinkVehicleToInterior(vehicleid, GetPlayerInterior(playerid));
        SetVehicleVirtualWorld(vehicleid, GetPlayerVirtualWorld(playerid));
    }

    SendClientMessagef(targetid, COLOR_ADMIN_COMMAND, "* %s puxou você.", GetPlayerNamef(playerid));
    SendClientMessagef(playerid, COLOR_ADMIN_COMMAND, "* Você puxou %s.", GetPlayerNamef(targetid));
    return 1;
}

//------------------------------------------------------------------------------

YCMD:say(playerid, params[], help)
{
   if(GetPlayerAdminLevel(playerid) < PLAYER_RANK_RECRUIT)
       return SendClientMessage(playerid, COLOR_ERROR, "* Você não tem permissão.");

   new message[128];
   if(sscanf(params, "s[128]", message))
       return SendClientMessage(playerid, COLOR_INFO, "* /say [mensagem]");

   new output[144];
   format(output, sizeof(output), "* Admin %s: %s", GetPlayerNamef(playerid), message);
   SendClientMessageToAll(0x97e632ff, output);
   return 1;
}

//------------------------------------------------------------------------------

YCMD:irpos(playerid, params[], help)
{
    if(GetPlayerAdminLevel(playerid) < PLAYER_RANK_RECRUIT)
        return SendClientMessage(playerid, COLOR_ERROR, "* Você não tem permissão.");

	new Float:x, Float:y, Float:z, i, w;
	if(sscanf(params, "fffI(0)I(0)", x, y, z, i, w))
		SendClientMessage(playerid, COLOR_INFO, "* /irpos [float x] [float y] [float z] [interior<opcional>] [world<opcional>]");
	else
    {
		SetPlayerInterior(playerid, i);
		SetPlayerVirtualWorld(playerid, w);
		SetPlayerPos(playerid, x, y, z);
	}
	return 1;
}

//------------------------------------------------------------------------------

YCMD:pdist(playerid, params[], help)
{
    if(GetPlayerAdminLevel(playerid) < PLAYER_RANK_RECRUIT)
        return SendClientMessage(playerid, COLOR_ERROR, "* Você não tem permissão.");

    new targetid;
    if(sscanf(params, "u", targetid))
        SendClientMessage(playerid, COLOR_INFO, "* /pdist [playerid]");
    else if(!IsPlayerLogged(targetid))
        SendClientMessage(playerid, COLOR_ERROR, "* O jogador não está conectado.");
	else
		SendClientMessagef(playerid, COLOR_ADMIN_COMMAND, "* Você está a %.2f units de distância do jogador.", GetPlayerDistanceFromPlayer(playerid, targetid));
	return 1;
}

//------------------------------------------------------------------------------

YCMD:kick(playerid, params[], help)
{
   if(GetPlayerAdminLevel(playerid) < PLAYER_RANK_RECRUIT)
       return SendClientMessage(playerid, COLOR_ERROR, "* Você não tem permissão.");

   new targetid, reason[128];
   if(sscanf(params, "us[128]", targetid, reason))
       return SendClientMessage(playerid, COLOR_INFO, "* /kick [playerid] [motivo]");

   else if(!IsPlayerLogged(targetid))
       return SendClientMessage(playerid, COLOR_ERROR, "* O jogador não está conectado.");

   else if(playerid == targetid)
       return SendClientMessage(playerid, COLOR_ERROR, "* Você não pode kickar você mesmo.");

   else if(IsPlayerNPC(targetid))
       return SendClientMessage(playerid, COLOR_ERROR, "* Você não pode kickar um NPC.");

   else if(GetPlayerAdminLevel(targetid) > PLAYER_RANK_RECRUIT)
       return SendClientMessage(playerid, COLOR_ERROR, "* Você não pode kickar um membro da administração.");

   new output[144];
   format(output, sizeof(output), "* %s foi kickado por %s. Motivo: %s", GetPlayerNamef(targetid), GetPlayerNamef(playerid), reason);
   SendClientMessageToAll(0xf26363ff, output);
   Kick(targetid);
   return 1;
}

//------------------------------------------------------------------------------

YCMD:fakekick(playerid, params[], help)
{
   if(GetPlayerAdminLevel(playerid) < PLAYER_RANK_RECRUIT)
       return SendClientMessage(playerid, COLOR_ERROR, "* Você não tem permissão.");

   new targetid, reason[128];
   if(sscanf(params, "us[128]", targetid, reason))
       return SendClientMessage(playerid, COLOR_INFO, "* /fakekick [playerid] [motivo]");

   else if(!IsPlayerLogged(targetid))
       return SendClientMessage(playerid, COLOR_ERROR, "* O jogador não está conectado.");

   else if(playerid == targetid)
       return SendClientMessage(playerid, COLOR_ERROR, "* Você não pode kickar você mesmo.");

   else if(IsPlayerNPC(targetid))
       return SendClientMessage(playerid, COLOR_ERROR, "* Você não pode kickar um NPC.");

   else if(GetPlayerAdminLevel(targetid) > PLAYER_RANK_RECRUIT)
       return SendClientMessage(playerid, COLOR_ERROR, "* Você não pode kickar um membro da administração.");

   new output[144];
   format(output, sizeof(output), "* %s foi kickado por %s. Motivo: %s", GetPlayerNamef(targetid), GetPlayerNamef(playerid), reason);
   SendClientMessageToAll(0xf26363ff, output);
   SendClientMessage(targetid, 0xA9C4E4FF, "Server closed the connection.");
   return 1;
}


/*


HHHHHHHHH     HHHHHHHHHEEEEEEEEEEEEEEEEEEEEEELLLLLLLLLLL             PPPPPPPPPPPPPPPPP   EEEEEEEEEEEEEEEEEEEEEERRRRRRRRRRRRRRRRR
H:::::::H     H:::::::HE::::::::::::::::::::EL:::::::::L             P::::::::::::::::P  E::::::::::::::::::::ER::::::::::::::::R
H:::::::H     H:::::::HE::::::::::::::::::::EL:::::::::L             P::::::PPPPPP:::::P E::::::::::::::::::::ER::::::RRRRRR:::::R
HH::::::H     H::::::HHEE::::::EEEEEEEEE::::ELL:::::::LL             PP:::::P     P:::::PEE::::::EEEEEEEEE::::ERR:::::R     R:::::R
H:::::H     H:::::H    E:::::E       EEEEEE  L:::::L                 P::::P     P:::::P  E:::::E       EEEEEE  R::::R     R:::::R
H:::::H     H:::::H    E:::::E               L:::::L                 P::::P     P:::::P  E:::::E               R::::R     R:::::R
H::::::HHHHH::::::H    E::::::EEEEEEEEEE     L:::::L                 P::::PPPPPP:::::P   E::::::EEEEEEEEEE     R::::RRRRRR:::::R
H:::::::::::::::::H    E:::::::::::::::E     L:::::L                 P:::::::::::::PP    E:::::::::::::::E     R:::::::::::::RR
H:::::::::::::::::H    E:::::::::::::::E     L:::::L                 P::::PPPPPPPPP      E:::::::::::::::E     R::::RRRRRR:::::R
H::::::HHHHH::::::H    E::::::EEEEEEEEEE     L:::::L                 P::::P              E::::::EEEEEEEEEE     R::::R     R:::::R
H:::::H     H:::::H    E:::::E               L:::::L                 P::::P              E:::::E               R::::R     R:::::R
H:::::H     H:::::H    E:::::E       EEEEEE  L:::::L         LLLLLL  P::::P              E:::::E       EEEEEE  R::::R     R:::::R
HH::::::H     H::::::HHEE::::::EEEEEEEE:::::ELL:::::::LLLLLLLLL:::::LPP::::::PP          EE::::::EEEEEEEE:::::ERR:::::R     R:::::R
H:::::::H     H:::::::HE::::::::::::::::::::EL::::::::::::::::::::::LP::::::::P          E::::::::::::::::::::ER::::::R     R:::::R
H:::::::H     H:::::::HE::::::::::::::::::::EL::::::::::::::::::::::LP::::::::P          E::::::::::::::::::::ER::::::R     R:::::R
HHHHHHHHH     HHHHHHHHHEEEEEEEEEEEEEEEEEEEEEELLLLLLLLLLLLLLLLLLLLLLLLPPPPPPPPPP          EEEEEEEEEEEEEEEEEEEEEERRRRRRRR     RRRRRRR

*/

//------------------------------------------------------------------------------

YCMD:aviso(playerid, params[], help)
{
    if(GetPlayerAdminLevel(playerid) < PLAYER_RANK_HELPER)
        return SendClientMessage(playerid, COLOR_ERROR, "* Você não tem permissão.");

    new targetid, reason[128];
    if(sscanf(params, "us[128]", targetid, reason))
        return SendClientMessage(playerid, COLOR_INFO, "* /aviso [playerid] [motivo]");

    else if(!IsPlayerLogged(targetid))
        return SendClientMessage(playerid, COLOR_ERROR, "* O jogador não está conectado.");

    else if(playerid == targetid)
        return SendClientMessage(playerid, COLOR_ERROR, "* Você não pode avisar você mesmo.");

    else if(IsPlayerNPC(targetid))
        return SendClientMessage(playerid, COLOR_ERROR, "* Você não pode avisar um NPC.");

    else if(GetPlayerAdminLevel(targetid) > PLAYER_RANK_RECRUIT)
        return SendClientMessage(playerid, COLOR_ERROR, "* Você não pode avisar um membro da administração.");

    if(GetPlayerWarning(targetid) == 2)
    {
        new output[144];
        format(output, sizeof(output), "* %s foi kickado por %s. Motivo: 3 avisos.", GetPlayerNamef(targetid), GetPlayerNamef(playerid));
        SendClientMessageToAll(0xf26363ff, output);
        SetPlayerWarning(targetid, 0);
        Kick(targetid);
    }
    else
    {
        new output[144];
        format(output, sizeof(output), "* %s foi advertido por %s. Motivo: %s", GetPlayerNamef(targetid), GetPlayerNamef(playerid), reason);
        SendClientMessageToAll(0xf26363ff, output);
        SetPlayerWarning(targetid, GetPlayerWarning(targetid) + 1);
    }
    return 1;
}

//------------------------------------------------------------------------------

YCMD:setskin(playerid, params[], help)
{
    if(GetPlayerAdminLevel(playerid) < PLAYER_RANK_HELPER)
        return SendClientMessage(playerid, COLOR_ERROR, "* Você não tem permissão.");

    new targetid, skinid;
    if(sscanf(params, "ui", targetid, skinid))
        return SendClientMessage(playerid, COLOR_INFO, "* /setskin [playerid] [skin]");

    else if(!IsPlayerLogged(targetid))
        return SendClientMessage(playerid, COLOR_ERROR, "* O jogador não está conectado.");

    else if(skinid < 0 || skinid > 311)
        return SendClientMessage(playerid, COLOR_ERROR, "* Skin inválida.");

    SetPlayerSkin(targetid, skinid);
    if(playerid != targetid)
        SendClientMessagef(targetid, COLOR_ADMIN_COMMAND, "* %s alterou sua skin para %d.", GetPlayerNamef(playerid), skinid);
    SendClientMessagef(playerid, COLOR_ADMIN_COMMAND, "* Você alterou a skin de %s para %d.", GetPlayerNamef(targetid), skinid);
    SetSpawnInfo(targetid, 255, skinid, 1119.9399, -1618.7476, 20.5210, 91.8327, 0, 0, 0, 0, 0, 0);
    return 1;
}

//------------------------------------------------------------------------------

YCMD:forcarcarro(playerid, params[], help)
{
    if(GetPlayerAdminLevel(playerid) < PLAYER_RANK_HELPER)
        return SendClientMessage(playerid, COLOR_ERROR, "* Você não tem permissão.");

    new targetid, vehicleid;
    if(sscanf(params, "ui", targetid, vehicleid))
        return SendClientMessage(playerid, COLOR_INFO, "* /forcarcarro [playerid] [veiculo]");

    else if(!IsPlayerLogged(targetid))
        return SendClientMessage(playerid, COLOR_ERROR, "* O jogador não está conectado.");

    if(playerid != targetid)
        SendClientMessagef(targetid, COLOR_ADMIN_COMMAND, "* %s forçou você a dirigir o veículo %d.", GetPlayerNamef(playerid), vehicleid);
    SendClientMessagef(playerid, COLOR_ADMIN_COMMAND, "* Você forçou %s a dirigir o veículo %d.", GetPlayerNamef(targetid), vehicleid);
    PutPlayerInVehicle(targetid, vehicleid, 0);
    return 1;
}

//------------------------------------------------------------------------------

YCMD:moverplayer(playerid, params[], help)
{
    if(GetPlayerAdminLevel(playerid) < PLAYER_RANK_HELPER)
        return SendClientMessage(playerid, COLOR_ERROR, "* Você não tem permissão.");

    new targetid, Float:x, Float:y, Float:z, int, world;
    if(sscanf(params, "ufffI(0)I(0)", targetid, x, y, z, int, world))
        return SendClientMessage(playerid, COLOR_INFO, "* /moverplayer [playerid] [x] [y] [z] [interior(opcional)] [world(opcional)]");

    if(playerid != targetid)
        SendClientMessagef(playerid, COLOR_ADMIN_COMMAND, "* %s moveu você para %.2f %.2f %.2f %i %i.", GetPlayerNamef(playerid), x, y, z, int, world);
    SendClientMessagef(playerid, COLOR_ADMIN_COMMAND, "* Você moveu %s para %.2f %.2f %.2f %i %i.", GetPlayerNamef(targetid), x, y, z, int, world);

    SetPlayerInterior(targetid, int);
    SetPlayerVirtualWorld(targetid, world);
    SetPlayerPos(targetid, x, y, z);
    return 1;
}

//------------------------------------------------------------------------------

YCMD:trazertodos(playerid, params[], help)
{
    if(GetPlayerAdminLevel(playerid) < PLAYER_RANK_HELPER)
        return SendClientMessage(playerid, COLOR_ERROR, "* Você não tem permissão.");

    new Float:x, Float:y, Float:z;
    GetPlayerPos(playerid, x, y, z);
    foreach(new i: Player)
    {
        if(i != playerid && GetPlayerGamemode(i) == GAMEMODE_FREEROAM)
            SetPlayerPos(i, x, y, z);
    }
    SendClientMessageToAllf(COLOR_ADMIN_COMMAND, "* %s trouxe todos os jogadores.", GetPlayerNamef(playerid));
    return 1;
}

//------------------------------------------------------------------------------

YCMD:setint(playerid, params[], help)
{
    if(GetPlayerAdminLevel(playerid) < PLAYER_RANK_HELPER)
        return SendClientMessage(playerid, COLOR_ERROR, "* Você não tem permissão.");

    new targetid, interior;
    if(sscanf(params, "ui", targetid, interior))
        return SendClientMessage(playerid, COLOR_INFO, "* /setint [playerid] [interior]");

    else if(!IsPlayerLogged(targetid))
        return SendClientMessage(playerid, COLOR_ERROR, "* O jogador não está conectado.");

    else if(interior < 0)
        return SendClientMessage(playerid, COLOR_ERROR, "* Interior inválido.");

    SetPlayerInterior(targetid, interior);
    if(playerid != targetid)
        SendClientMessagef(targetid, COLOR_ADMIN_COMMAND, "* %s alterou seu interior para %d.", GetPlayerNamef(playerid), interior);
    SendClientMessagef(playerid, COLOR_ADMIN_COMMAND, "* Você alterou o interior de %s para %d.", GetPlayerNamef(targetid), interior);
    return 1;
}

//------------------------------------------------------------------------------

YCMD:setvw(playerid, params[], help)
{
    if(GetPlayerAdminLevel(playerid) < PLAYER_RANK_HELPER)
        return SendClientMessage(playerid, COLOR_ERROR, "* Você não tem permissão.");

    new targetid, virtualworld;
    if(sscanf(params, "ui", targetid, virtualworld))
        return SendClientMessage(playerid, COLOR_INFO, "* /setvw [playerid] [interior]");

    else if(!IsPlayerLogged(targetid))
        return SendClientMessage(playerid, COLOR_ERROR, "* O jogador não está conectado.");

    else if(virtualworld < 0)
        return SendClientMessage(playerid, COLOR_ERROR, "* Virtual World inválido.");

    SetPlayerVirtualWorld(targetid, virtualworld);
    if(playerid != targetid)
        SendClientMessagef(targetid, COLOR_ADMIN_COMMAND, "* %s alterou seu virtual world para %d.", GetPlayerNamef(playerid), virtualworld);
    SendClientMessagef(playerid, COLOR_ADMIN_COMMAND, "* Você alterou o virtual world de %s para %d.", GetPlayerNamef(targetid), virtualworld);
    return 1;
}

//------------------------------------------------------------------------------

YCMD:jetpack(playerid, params[], help)
{
    if(GetPlayerAdminLevel(playerid) < PLAYER_RANK_HELPER)
        return SendClientMessage(playerid, COLOR_ERROR, "* Você não tem permissão.");

    SetPlayerSpecialAction(playerid, SPECIAL_ACTION_USEJETPACK);
    return 1;
}

//------------------------------------------------------------------------------

YCMD:ban(playerid, params[], help)
{
   if(GetPlayerAdminLevel(playerid) < PLAYER_RANK_HELPER)
       return SendClientMessage(playerid, COLOR_ERROR, "* Você não tem permissão.");

   new targetid, expire, reason[128];
   if(sscanf(params, "uis[128]", targetid, expire, reason))
       return SendClientMessage(playerid, COLOR_INFO, "* /ban [playerid] [duração(dias) | -1 = permanente] [motivo]");

   else if(!IsPlayerLogged(targetid))
       return SendClientMessage(playerid, COLOR_ERROR, "* O jogador não está conectado.");

   else if(playerid == targetid)
       return SendClientMessage(playerid, COLOR_ERROR, "* Você não pode banir você mesmo.");

   else if(IsPlayerNPC(targetid))
       return SendClientMessage(playerid, COLOR_ERROR, "* Você não pode banir um NPC.");

   else if(expire == 0)
       return SendClientMessage(playerid, COLOR_ERROR, "* Duração do banimento não pode ser 0.");

   else if(expire < -1)
       return SendClientMessage(playerid, COLOR_ERROR, "* Duração do banimento não pode ser menor do que -1.");

   else if(GetPlayerAdminLevel(targetid) > PLAYER_RANK_RECRUIT)
       return SendClientMessage(playerid, COLOR_ERROR, "* Você não pode banir um membro da administração.");

   new output[144];
   format(output, sizeof(output), "* %s foi banido por %s. Motivo: %s", GetPlayerNamef(targetid), GetPlayerNamef(playerid), reason);
   SendClientMessageToAll(0xf26363ff, output);

   new query[300];
   mysql_format(gMySQL, query, sizeof(query), "INSERT INTO `bans` (`username`, `admin`, `created_at`, `expire`, `reason`) VALUES ('%e', '%e', %d, %d, '%e')", GetPlayerNamef(targetid), GetPlayerNamef(playerid), gettime(), (expire == -1) ? expire : (expire * 86400) + gettime(), reason);
   mysql_tquery(gMySQL, query);

   Ban(targetid);
   return 1;
}

//------------------------------------------------------------------------------

YCMD:fakeban(playerid, params[], help)
{
   if(GetPlayerAdminLevel(playerid) < PLAYER_RANK_HELPER)
       return SendClientMessage(playerid, COLOR_ERROR, "* Você não tem permissão.");

   new targetid, reason[128];
   if(sscanf(params, "us[128]", targetid, reason))
       return SendClientMessage(playerid, COLOR_INFO, "* /fakeban [playerid] [motivo]");

   else if(!IsPlayerLogged(targetid))
       return SendClientMessage(playerid, COLOR_ERROR, "* O jogador não está conectado.");

   else if(playerid == targetid)
       return SendClientMessage(playerid, COLOR_ERROR, "* Você não pode banir você mesmo.");

   else if(IsPlayerNPC(targetid))
       return SendClientMessage(playerid, COLOR_ERROR, "* Você não pode banir um NPC.");

   else if(GetPlayerAdminLevel(targetid) > PLAYER_RANK_RECRUIT)
       return SendClientMessage(playerid, COLOR_ERROR, "* Você não pode banir um membro da administração.");

   new output[144];
   format(output, sizeof(output), "* %s foi banido por %s. Motivo: %s", GetPlayerNamef(targetid), GetPlayerNamef(playerid), reason);
   SendClientMessageToAll(0xf26363ff, output);

   SendClientMessage(targetid, 0xA9C4E4FF, "Server closed the connection.");
   return 1;
}

//------------------------------------------------------------------------------

YCMD:congelar(playerid, params[], help)
{
    if(GetPlayerAdminLevel(playerid) < PLAYER_RANK_HELPER)
        return SendClientMessage(playerid, COLOR_ERROR, "* Você não tem permissão.");

    new targetid;
    if(sscanf(params, "u", targetid))
        return SendClientMessage(playerid, COLOR_INFO, "* /congelar [playerid]");

    else if(!IsPlayerLogged(targetid))
        return SendClientMessage(playerid, COLOR_ERROR, "* O jogador não está conectado.");

    TogglePlayerControllable(targetid, false);
    if(playerid != targetid)
        SendClientMessagef(targetid, COLOR_ADMIN_COMMAND, "* %s congelou você.", GetPlayerNamef(playerid));
    SendClientMessagef(playerid, COLOR_ADMIN_COMMAND, "* Você congelou %s.", GetPlayerNamef(targetid));
    return 1;
}

//------------------------------------------------------------------------------

YCMD:descongelar(playerid, params[], help)
{
    if(GetPlayerAdminLevel(playerid) < PLAYER_RANK_HELPER)
        return SendClientMessage(playerid, COLOR_ERROR, "* Você não tem permissão.");

    new targetid;
    if(sscanf(params, "u", targetid))
        return SendClientMessage(playerid, COLOR_INFO, "* /descongelar [playerid]");

    else if(!IsPlayerLogged(targetid))
        return SendClientMessage(playerid, COLOR_ERROR, "* O jogador não está conectado.");

    TogglePlayerControllable(targetid, true);
    if(playerid != targetid)
        SendClientMessagef(targetid, COLOR_ADMIN_COMMAND, "* %s descongelou você.", GetPlayerNamef(playerid));
    SendClientMessagef(playerid, COLOR_ADMIN_COMMAND, "* Você descongelou %s.", GetPlayerNamef(targetid));
    return 1;
}

//------------------------------------------------------------------------------

YCMD:setarvida(playerid, params[], help)
{
    if(GetPlayerAdminLevel(playerid) < PLAYER_RANK_HELPER)
        return SendClientMessage(playerid, COLOR_ERROR, "* Você não tem permissão.");

    new targetid, Float:health;
    if(sscanf(params, "uf", targetid, health))
        return SendClientMessage(playerid, COLOR_INFO, "* /setarvida [playerid] [valor]");

    else if(!IsPlayerLogged(targetid))
        return SendClientMessage(playerid, COLOR_ERROR, "* O jogador não está conectado.");

    SetPlayerHealth(targetid, health);
    if(playerid != targetid)
        SendClientMessagef(targetid, COLOR_ADMIN_COMMAND, "* %s alterou sua HP para %.2f.", GetPlayerNamef(playerid), health);
    SendClientMessagef(playerid, COLOR_ADMIN_COMMAND, "* Você alterou a HP de %s para %.2f.", GetPlayerNamef(targetid), health);
    return 1;
}

//------------------------------------------------------------------------------

YCMD:setarcolete(playerid, params[], help)
{
    if(GetPlayerAdminLevel(playerid) < PLAYER_RANK_HELPER)
        return SendClientMessage(playerid, COLOR_ERROR, "* Você não tem permissão.");

    new targetid, Float:armour;
    if(sscanf(params, "uf", targetid, armour))
        return SendClientMessage(playerid, COLOR_INFO, "* /setarcolete [playerid] [valor]");

    else if(!IsPlayerLogged(targetid))
        return SendClientMessage(playerid, COLOR_ERROR, "* O jogador não está conectado.");

    SetPlayerArmour(targetid, armour);
    if(playerid != targetid)
        SendClientMessagef(targetid, COLOR_ADMIN_COMMAND, "* %s alterou seu colete para %.2f.", GetPlayerNamef(playerid), armour);
    SendClientMessagef(playerid, COLOR_ADMIN_COMMAND, "* Você alterou o colete de %s para %.2f.", GetPlayerNamef(targetid), armour);
    return 1;
}

//------------------------------------------------------------------------------

YCMD:dararma(playerid, params[], help)
{
   if(GetPlayerAdminLevel(playerid) < PLAYER_RANK_HELPER)
       return SendClientMessage(playerid, COLOR_ERROR, "* Você não tem permissão.");

   new targetid, weaponid, ammo;
   if(sscanf(params, "uii", targetid, weaponid, ammo))
       return SendClientMessage(playerid, COLOR_INFO, "* /dararma [playerid] [arma] [munição]");

   else if(!IsPlayerLogged(targetid))
       return SendClientMessage(playerid, COLOR_ERROR, "* O jogador não está conectado.");

   else if(weaponid < 0 || weaponid > 46)
       return SendClientMessage(playerid, COLOR_ERROR, "* Arma inválida.");

   else if(ammo < 1)
       return SendClientMessage(playerid, COLOR_ERROR, "* Munição inválida.");

   new weaponname[32];
   GivePlayerWeapon(targetid, weaponid, ammo);
   GetWeaponName(weaponid, weaponname, sizeof(weaponname));
   if(playerid != targetid)
       SendClientMessagef(targetid, COLOR_ADMIN_COMMAND, "* %s deu uma %s com %d balas para você.", GetPlayerNamef(playerid), weaponname, ammo);
   SendClientMessagef(playerid, COLOR_ADMIN_COMMAND, "* Você deu uma %s com %d balas para %s.", weaponname, ammo, GetPlayerNamef(targetid));
   return 1;
}

//------------------------------------------------------------------------------

YCMD:desarmar(playerid, params[], help)
{
   if(GetPlayerAdminLevel(playerid) < PLAYER_RANK_HELPER)
       return SendClientMessage(playerid, COLOR_ERROR, "* Você não tem permissão.");

   new targetid;
   if(sscanf(params, "u", targetid))
       return SendClientMessage(playerid, COLOR_INFO, "* /desarmar [playerid]");

   else if(!IsPlayerLogged(targetid))
       return SendClientMessage(playerid, COLOR_ERROR, "* O jogador não está conectado.");

   if(playerid != targetid)
       SendClientMessagef(targetid, COLOR_ADMIN_COMMAND, "* %s desarmou você.", GetPlayerNamef(playerid));
   SendClientMessagef(playerid, COLOR_ADMIN_COMMAND, "* Você desarmou %s.", GetPlayerNamef(targetid));
   ResetPlayerWeapons(targetid);
   return 1;
}

//------------------------------------------------------------------------------

YCMD:mutar(playerid, params[], help)
{
    if(GetPlayerAdminLevel(playerid) < PLAYER_RANK_HELPER)
        return SendClientMessage(playerid, COLOR_ERROR, "* Você não tem permissão.");

    new targetid;
    if(sscanf(params, "u", targetid))
        return SendClientMessage(playerid, COLOR_INFO, "* /mutar [playerid]");

    else if(!IsPlayerLogged(targetid))
        return SendClientMessage(playerid, COLOR_ERROR, "* O jogador não está conectado.");

    else if(IsPlayerMuted(targetid))
        return SendClientMessage(playerid, COLOR_ERROR, "* O jogador já está mutado.");

    TogglePlayerMute(targetid, true);
    if(playerid != targetid)
        SendClientMessagef(targetid, COLOR_ADMIN_COMMAND, "* %s mutou você.", GetPlayerNamef(playerid));
    SendClientMessagef(playerid, COLOR_ADMIN_COMMAND, "* Você mutou %s.", GetPlayerNamef(targetid));
    return 1;
}

//------------------------------------------------------------------------------

YCMD:desmutar(playerid, params[], help)
{
    if(GetPlayerAdminLevel(playerid) < PLAYER_RANK_MODERATOR)
        return SendClientMessage(playerid, COLOR_ERROR, "* Você não tem permissão.");

    new targetid;
    if(sscanf(params, "u", targetid))
        return SendClientMessage(playerid, COLOR_INFO, "* /desmutar [playerid]");

    else if(!IsPlayerLogged(targetid))
        return SendClientMessage(playerid, COLOR_ERROR, "* O jogador não está conectado.");

    else if(!IsPlayerMuted(targetid))
        return SendClientMessage(playerid, COLOR_ERROR, "* O jogador não está mutado.");

    TogglePlayerMute(targetid, false);
    if(playerid != targetid)
        SendClientMessagef(targetid, COLOR_ADMIN_COMMAND, "* %s desmutou você.", GetPlayerNamef(playerid));
    SendClientMessagef(playerid, COLOR_ADMIN_COMMAND, "* Você desmutou %s.", GetPlayerNamef(targetid));
    return 1;
}

//------------------------------------------------------------------------------

YCMD:destruircarro(playerid, params[], help)
{
   if(GetPlayerAdminLevel(playerid) < PLAYER_RANK_HELPER)
   {
       SendClientMessage(playerid, COLOR_ERROR, "* Você não tem permissão.");
   }
   else
   {
       new vehicleid;
       if(IsPlayerInAnyVehicle(playerid))
       {
           vehicleid = GetPlayerVehicleID(playerid);
       }
       else if(sscanf(params, "i", vehicleid))
       {
           SendClientMessage(playerid, COLOR_INFO, "* /destruircarro [veiculoid]");
       }
       SendClientMessagef(playerid, COLOR_ADMIN_COMMAND, "* Você destruiu o veículo id %s.", vehicleid);
       DestroyVehicle(vehicleid);
   }
   return 1;
}

//------------------------------------------------------------------------------

YCMD:respawn(playerid, params[], help)
{
   if(GetPlayerAdminLevel(playerid) < PLAYER_RANK_HELPER)
       return SendClientMessage(playerid, COLOR_ERROR, "* Você não tem permissão.");

   SendClientMessageToAllf(COLOR_ADMIN_COMMAND, "* %s deu respawn em todos os veículos.", GetPlayerNamef(playerid));
   for(new i = 0; i < MAX_VEHICLES; i++)
   {
       SetVehicleToRespawn(i);
   }
   return 1;
}

/*


MMMMMMMM               MMMMMMMM     OOOOOOOOO     DDDDDDDDDDDDD
M:::::::M             M:::::::M   OO:::::::::OO   D::::::::::::DDD
M::::::::M           M::::::::M OO:::::::::::::OO D:::::::::::::::DD
M:::::::::M         M:::::::::MO:::::::OOO:::::::ODDD:::::DDDDD:::::D
M::::::::::M       M::::::::::MO::::::O   O::::::O  D:::::D    D:::::D
M:::::::::::M     M:::::::::::MO:::::O     O:::::O  D:::::D     D:::::D
M:::::::M::::M   M::::M:::::::MO:::::O     O:::::O  D:::::D     D:::::D
M::::::M M::::M M::::M M::::::MO:::::O     O:::::O  D:::::D     D:::::D
M::::::M  M::::M::::M  M::::::MO:::::O     O:::::O  D:::::D     D:::::D
M::::::M   M:::::::M   M::::::MO:::::O     O:::::O  D:::::D     D:::::D
M::::::M    M:::::M    M::::::MO:::::O     O:::::O  D:::::D     D:::::D
M::::::M     MMMMM     M::::::MO::::::O   O::::::O  D:::::D    D:::::D
M::::::M               M::::::MO:::::::OOO:::::::ODDD:::::DDDDD:::::D
M::::::M               M::::::M OO:::::::::::::OO D:::::::::::::::DD
M::::::M               M::::::M   OO:::::::::OO   D::::::::::::DDD
MMMMMMMM               MMMMMMMM     OOOOOOOOO     DDDDDDDDDDDDD

*/

//------------------------------------------------------------------------------

YCMD:rtc(playerid, params[], help)
{
    if(GetPlayerAdminLevel(playerid) < PLAYER_RANK_MODERATOR)
        return SendClientMessage(playerid, COLOR_ERROR, "* Você não tem permissão.");

    else if(!IsPlayerInAnyVehicle(playerid))
        return SendClientMessage(playerid, COLOR_ERROR, "* Você não está em um veículo.");

	SetVehicleToRespawn(GetPlayerVehicleID(playerid));
	return 1;
}

//------------------------------------------------------------------------------

YCMD:ircar(playerid, params[], help)
{
    if(GetPlayerAdminLevel(playerid) < PLAYER_RANK_MODERATOR)
        return SendClientMessage(playerid, COLOR_ERROR, "* Você não tem permissão.");

	new vehicleid;
	if(sscanf(params, "i", vehicleid))
		SendClientMessage(playerid, COLOR_INFO, "* /ircar [veículo id]");
    else if(GetVehicleModel(vehicleid) == 0)
		SendClientMessage(playerid, COLOR_ERROR, "* Veículo não existe.");
	else
    {
		SendClientMessagef(playerid, COLOR_ADMIN_COMMAND, "* Você foi até o veículo %d.", vehicleid);

        new Float:x, Float:y, Float:z;
        GetVehiclePos(vehicleid, x, y, z);
        SetPlayerPos(playerid, x, y, z);
	}
	return 1;
}

//------------------------------------------------------------------------------

YCMD:puxarcar(playerid, params[], help)
{
    if(GetPlayerAdminLevel(playerid) < PLAYER_RANK_MODERATOR)
        return SendClientMessage(playerid, COLOR_ERROR, "* Você não tem permissão.");

	new vehicleid;
	if(sscanf(params, "i", vehicleid))
		SendClientMessage(playerid, COLOR_INFO, "* /puxarcar [veículo id]");
    else if(GetVehicleModel(vehicleid) == 0)
    	SendClientMessage(playerid, COLOR_ERROR, "* Veículo não existe.");
	else
    {
		SendClientMessagef(playerid, COLOR_ADMIN_COMMAND, "* Você puxou o veículo %d.", vehicleid);

        new Float:x, Float:y, Float:z;
        GetPlayerPos(playerid, x, y, z);
        SetVehiclePos(vehicleid, x, y, z);
        LinkVehicleToInterior(vehicleid, GetPlayerInterior(playerid));
        SetVehicleVirtualWorld(vehicleid, GetPlayerVirtualWorld(playerid));
	}
	return 1;
}

//------------------------------------------------------------------------------

YCMD:tempo(playerid, params[], help)
{
    if(GetPlayerAdminLevel(playerid) < PLAYER_RANK_MODERATOR)
        return SendClientMessage(playerid, COLOR_ERROR, "* Você não tem permissão.");

	new hour, minute;
	if(sscanf(params, "ii", hour, minute))
		SendClientMessage(playerid, COLOR_INFO, "* /tempo [hora] [minuto]");
    else if(hour < 0 || hour > 23)
    	SendClientMessage(playerid, COLOR_ERROR, "* Hora inválida.");
    else if(minute < 0 || minute > 59)
        SendClientMessage(playerid, COLOR_ERROR, "* Minuto inválido.");
	else
    {
        SetWorldTime(hour);
        foreach(new i: Player)
        {
            SetPlayerTime(playerid, hour, minute);
        }
		SendClientMessageToAllf(COLOR_ADMIN_COMMAND, "* %s alterou o horário do servidor para %02d:%02d.", GetPlayerNamef(playerid), hour, minute);
	}
	return 1;
}

//------------------------------------------------------------------------------

YCMD:climatodos(playerid, params[], help)
{
    if(GetPlayerAdminLevel(playerid) < PLAYER_RANK_MODERATOR)
        return SendClientMessage(playerid, COLOR_ERROR, "* Você não tem permissão.");

	new weatherid;
	if(sscanf(params, "i", weatherid))
		SendClientMessage(playerid, COLOR_INFO, "* /climatodos [clima]");
	else
    {
        SetWeather(weatherid);
		SendClientMessageToAllf(COLOR_ADMIN_COMMAND, "* %s alterou o clima do servidor para %d.", GetPlayerNamef(playerid), weatherid);
	}
	return 1;
}

//------------------------------------------------------------------------------

YCMD:ejetarp(playerid, params[], help)
{
    if(GetPlayerAdminLevel(playerid) < PLAYER_RANK_MODERATOR)
        return SendClientMessage(playerid, COLOR_ERROR, "* Você não tem permissão.");

	new targetid;
	if(sscanf(params, "u", targetid))
		SendClientMessage(playerid, COLOR_INFO, "* /ejetarp [playerid]");
	else
    {
        if(!IsPlayerInAnyVehicle(targetid))
        {
            SendClientMessage(playerid, COLOR_ERROR, "* O jogador não está em um veículo.");
        }
        else
        {
            RemovePlayerFromVehicle(targetid);
            SendClientMessagef(targetid, COLOR_ADMIN_COMMAND, "* %s removeu você do veículo.", GetPlayerNamef(playerid));
            SendClientMessagef(playerid, COLOR_ADMIN_COMMAND, "* Você removeu %s do veículo.", GetPlayerNamef(targetid));
        }
	}
	return 1;
}

//------------------------------------------------------------------------------

YCMD:setarpontos(playerid, params[], help)
{
    if(GetPlayerAdminLevel(playerid) < PLAYER_RANK_MODERATOR)
        return SendClientMessage(playerid, COLOR_ERROR, "* Você não tem permissão.");

	new targetid, score;
	if(sscanf(params, "ui", targetid, score))
		SendClientMessage(playerid, COLOR_INFO, "* /setarpontos [playerid] [pontos]");
	else
    {
        SetPlayerDriftPoints(playerid, score * 1000);
        SendClientMessagef(targetid, COLOR_ADMIN_COMMAND, "* %s alterou seus pontos para %d.", GetPlayerNamef(playerid), score);
        SendClientMessagef(playerid, COLOR_ADMIN_COMMAND, "* Você alterou os pontos de %s para %d.", GetPlayerNamef(targetid), score);
	}
	return 1;
}

//------------------------------------------------------------------------------

YCMD:banip(playerid, params[], help)
{
    if(GetPlayerAdminLevel(playerid) < PLAYER_RANK_MODERATOR)
        return SendClientMessage(playerid, COLOR_ERROR, "* Você não tem permissão.");

	new ip[16];
	if(sscanf(params, "s[16]", ip))
		SendClientMessage(playerid, COLOR_INFO, "* /banip [ip]");
	else
    {
        new rconcmd[64];
        format(rconcmd, sizeof(rconcmd), "banip %s", ip);
        SendRconCommand(rconcmd);
        SendRconCommand("reloadbans");

        SendClientMessagef(playerid, COLOR_ADMIN_COMMAND, "* Você baniu o IP: %s.", ip);
	}
	return 1;
}

//------------------------------------------------------------------------------

YCMD:unbanip(playerid, params[], help)
{
    if(GetPlayerAdminLevel(playerid) < PLAYER_RANK_MODERATOR)
        return SendClientMessage(playerid, COLOR_ERROR, "* Você não tem permissão.");

	new ip[16];
	if(sscanf(params, "s[16]", ip))
		SendClientMessage(playerid, COLOR_INFO, "* /unbanip [ip]");
	else
    {
        new rconcmd[64];
        format(rconcmd, sizeof(rconcmd), "unbanip %s", ip);
        SendRconCommand(rconcmd);
        SendRconCommand("reloadbans");

        SendClientMessagef(playerid, COLOR_ADMIN_COMMAND, "* Você desbaniu o IP: %s.", ip);
	}
	return 1;
}

//------------------------------------------------------------------------------

YCMD:crash(playerid, params[], help)
{
    if(GetPlayerAdminLevel(playerid) < PLAYER_RANK_MODERATOR)
        return SendClientMessage(playerid, COLOR_ERROR, "* Você não tem permissão.");

	new targetid, reason[128];
	if(sscanf(params, "us[128]", targetid, reason))
		SendClientMessage(playerid, COLOR_INFO, "* /crash [playerid] [motivo]");
	else
    {
        SendClientMessageToAllf(COLOR_ADMIN_COMMAND, "* O admin %s crashou %s. Motivo: %s.", GetPlayerNamef(playerid), GetPlayerNamef(targetid), reason);
        GameTextForPlayer(targetid, "~k~~INVALID_KEY~", 5000, 5);
        SendClientMessage(targetid, -1, "");
	}
	return 1;
}

//------------------------------------------------------------------------------

YCMD:setarnome(playerid, params[], help)
{
    if(GetPlayerAdminLevel(playerid) < PLAYER_RANK_MODERATOR)
        return SendClientMessage(playerid, COLOR_ERROR, "* Você não tem permissão.");

	new targetid, name[MAX_PLAYER_NAME];
	if(sscanf(params, "us[26]", targetid, name))
		SendClientMessage(playerid, COLOR_INFO, "* /setarnome [playerid] [nome]");
	else
    {
        SendClientMessagef(playerid, COLOR_ADMIN_COMMAND, "* Você alterou o nome de %s para %s.", GetPlayerNamef(targetid), name);
        SendClientMessagef(targetid, COLOR_ADMIN_COMMAND, "* %s alterou seu nome para %s.", GetPlayerNamef(playerid), name);
        ChangePlayerName(targetid, name);
	}
	return 1;
}

//------------------------------------------------------------------------------

YCMD:setarcor(playerid, params[], help)
{
    if(GetPlayerAdminLevel(playerid) < PLAYER_RANK_MODERATOR)
        return SendClientMessage(playerid, COLOR_ERROR, "* Você não tem permissão.");

	new targetid, color;
	if(sscanf(params, "ux", targetid, color))
		SendClientMessage(playerid, COLOR_INFO, "* /setarcor [playerid] [cor]");
	else
    {
        SendClientMessagef(playerid, COLOR_ADMIN_COMMAND, "* Você alterou a cor de %s para {%06x}esta.", GetPlayerNamef(targetid), color >>> 8);
        SendClientMessagef(targetid, COLOR_ADMIN_COMMAND, "* %s alterou sua cor para {%06x}esta.", GetPlayerNamef(playerid), color >>> 8);
        SetPlayerColor(targetid, color);
	}
	return 1;
}

//------------------------------------------------------------------------------

YCMD:godmode(playerid, params[], help)
{
    if(GetPlayerAdminLevel(playerid) < PLAYER_RANK_MODERATOR)
        return SendClientMessage(playerid, COLOR_ERROR, "* Você não tem permissão.");

	SetPlayerHealth(playerid, 999999.0);
	return 1;
}

//------------------------------------------------------------------------------

YCMD:enquete(playerid, params[], help)
{
    if(GetPlayerAdminLevel(playerid) < PLAYER_RANK_MODERATOR)
        return SendClientMessage(playerid, COLOR_ERROR, "* Você não tem permissão.");

    else if(gSurveyData[e_survey_active])
        return SendClientMessage(playerid, COLOR_ERROR, "* Uma enquete já está ativa.");

    new question[128];
	if(sscanf(params, "s[128]", question))
		SendClientMessage(playerid, COLOR_INFO, "* /enquete [pergunta]");
	else
    {
        gSurveyData[e_survey_active] = true;
        gSurveyData[e_survey_yes] = 0;
        gSurveyData[e_survey_no] = 0;
        format(gSurveyData[e_survey_question], sizeof(gSurveyData[e_survey_question]), question);

        SendClientMessagef(playerid, COLOR_ADMIN_COMMAND, "* %s criou uma enquete!", GetPlayerNamef(playerid));
        SendClientMessagef(playerid, COLOR_ADMIN_COMMAND, "* Pergunta: %s", question);

        new output[356];
        format(output, sizeof(output), "{ffffff}Enquete criada por: %s.\nPergunta: %s", GetPlayerNamef(playerid), question);
        foreach(new i: Player)
        {
            if(IsPlayerLogged(i))
            {
                ShowPlayerDialog(i, DIALOG_SURVEY, DIALOG_STYLE_MSGBOX, question, output, "Sim", "Não");
            }
        }

        defer EndSurvey();
	}
	return 1;
}

//------------------------------------------------------------------------------

YCMD:verpos(playerid, params[], help)
{
    if(GetPlayerAdminLevel(playerid) < PLAYER_RANK_MODERATOR)
        return SendClientMessage(playerid, COLOR_ERROR, "* Você não tem permissão.");

	new targetid;
	if(sscanf(params, "u", targetid))
		SendClientMessage(playerid, COLOR_INFO, "* /verpos [playerid]");
	else
    {
        new Float:x, Float:y, Float:z, Float:a;
        GetPlayerPos(targetid, x, y, z);
        GetPlayerFacingAngle(targetid, a);
        SendClientMessagef(playerid, COLOR_ADMIN_COMMAND, "* O jogador %s está nas coordenadas: %.2f, %.2f, %.2f, %.2f, %i, %i.", GetPlayerNamef(targetid), x, y, z, a, GetPlayerInterior(targetid), GetPlayerVirtualWorld(targetid));
	}
	return 1;
}

/*


SSSSSSSSSSSSSSS UUUUUUUU     UUUUUUUUBBBBBBBBBBBBBBBBB             OOOOOOOOO     WWWWWWWW                           WWWWWWWWNNNNNNNN        NNNNNNNNEEEEEEEEEEEEEEEEEEEEEERRRRRRRRRRRRRRRRR
SS:::::::::::::::SU::::::U     U::::::UB::::::::::::::::B          OO:::::::::OO   W::::::W                           W::::::WN:::::::N       N::::::NE::::::::::::::::::::ER::::::::::::::::R
S:::::SSSSSS::::::SU::::::U     U::::::UB::::::BBBBBB:::::B       OO:::::::::::::OO W::::::W                           W::::::WN::::::::N      N::::::NE::::::::::::::::::::ER::::::RRRRRR:::::R
S:::::S     SSSSSSSUU:::::U     U:::::UUBB:::::B     B:::::B     O:::::::OOO:::::::OW::::::W                           W::::::WN:::::::::N     N::::::NEE::::::EEEEEEEEE::::ERR:::::R     R:::::R
S:::::S             U:::::U     U:::::U   B::::B     B:::::B     O::::::O   O::::::O W:::::W           WWWWW           W:::::W N::::::::::N    N::::::N  E:::::E       EEEEEE  R::::R     R:::::R
S:::::S             U:::::D     D:::::U   B::::B     B:::::B     O:::::O     O:::::O  W:::::W         W:::::W         W:::::W  N:::::::::::N   N::::::N  E:::::E               R::::R     R:::::R
S::::SSSS          U:::::D     D:::::U   B::::BBBBBB:::::B      O:::::O     O:::::O   W:::::W       W:::::::W       W:::::W   N:::::::N::::N  N::::::N  E::::::EEEEEEEEEE     R::::RRRRRR:::::R
SS::::::SSSSS     U:::::D     D:::::U   B:::::::::::::BB       O:::::O     O:::::O    W:::::W     W:::::::::W     W:::::W    N::::::N N::::N N::::::N  E:::::::::::::::E     R:::::::::::::RR
SSS::::::::SS   U:::::D     D:::::U   B::::BBBBBB:::::B      O:::::O     O:::::O     W:::::W   W:::::W:::::W   W:::::W     N::::::N  N::::N:::::::N  E:::::::::::::::E     R::::RRRRRR:::::R
SSSSSS::::S  U:::::D     D:::::U   B::::B     B:::::B     O:::::O     O:::::O      W:::::W W:::::W W:::::W W:::::W      N::::::N   N:::::::::::N  E::::::EEEEEEEEEE     R::::R     R:::::R
S:::::S U:::::D     D:::::U   B::::B     B:::::B     O:::::O     O:::::O       W:::::W:::::W   W:::::W:::::W       N::::::N    N::::::::::N  E:::::E               R::::R     R:::::R
S:::::S U::::::U   U::::::U   B::::B     B:::::B     O::::::O   O::::::O        W:::::::::W     W:::::::::W        N::::::N     N:::::::::N  E:::::E       EEEEEE  R::::R     R:::::R
SSSSSSS     S:::::S U:::::::UUU:::::::U BB:::::BBBBBB::::::B     O:::::::OOO:::::::O         W:::::::W       W:::::::W         N::::::N      N::::::::NEE::::::EEEEEEEE:::::ERR:::::R     R:::::R
S::::::SSSSSS:::::S  UU:::::::::::::UU  B:::::::::::::::::B       OO:::::::::::::OO           W:::::W         W:::::W          N::::::N       N:::::::NE::::::::::::::::::::ER::::::R     R:::::R
S:::::::::::::::SS     UU:::::::::UU    B::::::::::::::::B          OO:::::::::OO              W:::W           W:::W           N::::::N        N::::::NE::::::::::::::::::::ER::::::R     R:::::R
SSSSSSSSSSSSSSS         UUUUUUUUU      BBBBBBBBBBBBBBBBB             OOOOOOOOO                 WWW             WWW            NNNNNNNN         NNNNNNNEEEEEEEEEEEEEEEEEEEEEERRRRRRRR     RRRRRRR


*/

//------------------------------------------------------------------------------

YCMD:gmx(playerid, params[], help)
{
    if(GetPlayerAdminLevel(playerid) < PLAYER_RANK_SUB_OWNER)
        return SendClientMessage(playerid, COLOR_ERROR, "* Você não tem permissão.");

    GameTextForAll("~b~~h~Reiniciando o servidor...", 15000, 3);
    foreach(new i: Player)
    {
        if(IsPlayerLogged(i))
        {
            ClearPlayerScreen(i);
            SavePlayerAccount(i);
            SetPlayerLogged(i, false);
        }
    }
    defer RestartGameMode();
    return 1;
}

//------------------------------------------------------------------------------

YCMD:setmoney(playerid, params[], help)
{
    if(GetPlayerAdminLevel(playerid) < PLAYER_RANK_SUB_OWNER)
        return SendClientMessage(playerid, COLOR_ERROR, "* Você não tem permissão.");

    new targetid, value;
    if(sscanf(params, "ui", targetid, value))
        return SendClientMessage(playerid, COLOR_INFO, "* /setmoney [playerid] [quantia]");

    else if(!IsPlayerLogged(targetid))
        return SendClientMessage(playerid, COLOR_ERROR, "* O jogador não está conectado.");

    else if(value < 0 || value > 2147483647)
        return SendClientMessage(playerid, COLOR_ERROR, "* Valor inválido. (0 - 2.147.483.647)");

    SetPlayerCash(targetid, value);
    if(playerid != targetid)
        SendClientMessagef(targetid, COLOR_ADMIN_COMMAND, "* %s alterou seu dinheiro para $%d.", GetPlayerNamef(playerid), value);
    SendClientMessagef(playerid, COLOR_ADMIN_COMMAND, "* Você alterou o dinheiro de %s para $%d.", GetPlayerNamef(targetid), value);
    return 1;
}

//------------------------------------------------------------------------------

YCMD:setbanco(playerid, params[], help)
{
    if(GetPlayerAdminLevel(playerid) < PLAYER_RANK_SUB_OWNER)
        return SendClientMessage(playerid, COLOR_ERROR, "* Você não tem permissão.");

    new targetid, value;
    if(sscanf(params, "ui", targetid, value))
        return SendClientMessage(playerid, COLOR_INFO, "* /setbanco [playerid] [quantia]");

    else if(!IsPlayerLogged(targetid))
        return SendClientMessage(playerid, COLOR_ERROR, "* O jogador não está conectado.");

    else if(value < 0 || value > 2147483647)
        return SendClientMessage(playerid, COLOR_ERROR, "* Valor inválido. (0 - 2.147.483.647)");

    SetPlayerBankCash(targetid, value);
    if(playerid != targetid)
        SendClientMessagef(targetid, COLOR_ADMIN_COMMAND, "* %s alterou seu dinheiro do banco para $%d.", GetPlayerNamef(playerid), value);
    SendClientMessagef(playerid, COLOR_ADMIN_COMMAND, "* Você alterou o dinheiro do banco de %s para $%d.", GetPlayerNamef(targetid), value);
    return 1;
}

//------------------------------------------------------------------------------

YCMD:setvip(playerid, params[], help)
{
    if(GetPlayerAdminLevel(playerid) >= PLAYER_RANK_SUB_OWNER)
    {
        new targetid, days;
        if(sscanf(params, "ui", targetid, days))
            return SendClientMessage(playerid, COLOR_INFO, "* /setvip [playerid] [dias]");

        else if(!IsPlayerLogged(targetid))
            return SendClientMessage(playerid, COLOR_ERROR, "* O jogador não está conectado.");

        else if(days < 0)
            return SendClientMessage(playerid, COLOR_ERROR, "* Valor inválido.");

        SetPlayerVIP(targetid, gettime() + (days * 86400));
        if(playerid != targetid)
        {
            if(!days)
                SendClientMessagef(targetid, COLOR_PLAYER_COMMAND, "* %s removeu seu VIP.", GetPlayerNamef(playerid));
            else
                SendClientMessagef(targetid, COLOR_PLAYER_COMMAND, "* %s ativou seu VIP por %d dias.", GetPlayerNamef(playerid), days);
        }

        if(!days)
            SendClientMessagef(playerid, COLOR_PLAYER_COMMAND, "* Você removeu o VIP de %s.", GetPlayerNamef(targetid));
        else
        {
            PlayerPlaySound(targetid, 5203, 0.0, 0.0, 0.0);
            SendClientMessagef(playerid, COLOR_PLAYER_COMMAND, "* Você ativou o VIP de %s por %d dias.", GetPlayerNamef(targetid), days);
        }
    }
    else
    {
        SendClientMessage(playerid, COLOR_ERROR, "* Você não tem permissão.");
    }
    return 1;
}

//------------------------------------------------------------------------------

YCMD:tirarvip(playerid, params[], help)
{
    if(GetPlayerAdminLevel(playerid) >= PLAYER_RANK_SUB_OWNER)
    {
        new targetid;
        if(sscanf(params, "u", targetid))
            return SendClientMessage(playerid, COLOR_INFO, "* /tirarvip [playerid]");

        else if(!IsPlayerLogged(targetid))
            return SendClientMessage(playerid, COLOR_ERROR, "* O jogador não está conectado.");

        if(playerid != targetid)
        {
            SendClientMessagef(targetid, COLOR_PLAYER_COMMAND, "* %s removeu seu VIP.", GetPlayerNamef(playerid));
        }

        SetPlayerVIP(targetid, 0);
        SendClientMessagef(playerid, COLOR_PLAYER_COMMAND, "* Você removeu o VIP de %s.", GetPlayerNamef(targetid));
    }
    else
    {
        SendClientMessage(playerid, COLOR_ERROR, "* Você não tem permissão.");
    }
    return 1;
}

//------------------------------------------------------------------------------

YCMD:deletarconta(playerid, params[], help)
{
    if(GetPlayerAdminLevel(playerid) >= PLAYER_RANK_SUB_OWNER)
    {
        new userName[MAX_PLAYER_NAME];
        if(sscanf(params, "s[26]", userName))
            return SendClientMessage(playerid, COLOR_INFO, "* /deletarconta [nome do usuário]");

        new playerName[MAX_PLAYER_NAME];
        foreach(new i: Player)
        {
            GetPlayerName(i, playerName, MAX_PLAYER_NAME);
            if(!strcmp(playerName, userName))
            {
                Kick(i);
            }
        }

        new query[64];
        mysql_format(gMySQL, query, sizeof(query), "DELETE FROM `users` WHERE `name`='%e'", userName);
        mysql_tquery(gMySQL, query, "OnDeleteAccount", "i", playerid);
    }
    else
    {
        SendClientMessage(playerid, COLOR_ERROR, "* Você não tem permissão.");
    }
    return 1;
}

//------------------------------------------------------------------------------

YCMD:gerarchavevip(playerid, params[], help)
{
    if(GetPlayerAdminLevel(playerid) >= PLAYER_RANK_SUB_OWNER)
    {
        PlaySelectSound(playerid);
        ShowPlayerDialog(playerid, DIALOG_GENERATE_VIP_KEY, DIALOG_STYLE_LIST, "Gerar chave VIP", "Dias\nTipo\nGerar", "Selecionar", "Fechar");
    }
    else
    {
        SendClientMessage(playerid, COLOR_ERROR, "* Você não tem permissão.");
    }
    return 1;
}

//------------------------------------------------------------------------------

YCMD:kickartodos(playerid, params[], help)
{
    if(GetPlayerAdminLevel(playerid) >= PLAYER_RANK_SUB_OWNER)
    {
        SendClientMessageToAllf(COLOR_ADMIN_COMMAND, "* %s kickou todos os jogadores do servidor.", GetPlayerNamef(playerid));
        foreach(new i: Player)
        {
            if(GetPlayerAdminLevel(i) < 1)
                Kick(i);
        }
    }
    else
    {
        SendClientMessage(playerid, COLOR_ERROR, "* Você não tem permissão.");
    }
    return 1;
}

//------------------------------------------------------------------------------

YCMD:desarmartodos(playerid, params[], help)
{
    if(GetPlayerAdminLevel(playerid) >= PLAYER_RANK_SUB_OWNER)
    {
        SendClientMessageToAllf(COLOR_ADMIN_COMMAND, "* %s desarmou todos.", GetPlayerNamef(playerid));
        foreach(new i: Player)
        {
            ResetPlayerWeapons(i);
        }
    }
    else
    {
        SendClientMessage(playerid, COLOR_ERROR, "* Você não tem permissão.");
    }
    return 1;
}

//------------------------------------------------------------------------------

YCMD:chatfalso(playerid, params[], help)
{
    if(GetPlayerAdminLevel(playerid) >= PLAYER_RANK_SUB_OWNER)
    {
        new targetid, text[128];
        if(sscanf(params, "us[128]", targetid, text))
            return SendClientMessage(playerid, COLOR_INFO, "* /chatfalso [playerid] [fala]");

        new message[144];
        format(message, sizeof(message), "%s (%i): {ffffff}%s", GetPlayerNamef(targetid), targetid, text);

        if(GetPlayerAdminLevel(targetid) >= PLAYER_RANK_RECRUIT)
        {
            new rankName[14];
            format(rankName, 14, "[%s] ", GetPlayerAdminRankName(targetid, true));
            strins(message, rankName, 0);
        }
        else if(IsPlayerVIP(targetid))
        {
            strins(message, "[VIP] ", 0);
        }

        foreach(new i: Player)
        {
            if(GetPlayerGamemode(i) != GAMEMODE_LOBBY)
            {
                SendClientMessage(i, GetPlayerColor(targetid), message);
            }
        }
    }
    else
    {
        SendClientMessage(playerid, COLOR_ERROR, "* Você não tem permissão.");
    }
    return 1;
}

//------------------------------------------------------------------------------

YCMD:interiortodos(playerid, params[], help)
{
    if(GetPlayerAdminLevel(playerid) >= PLAYER_RANK_SUB_OWNER)
    {
        new interior;
        if(sscanf(params, "i", interior))
            return SendClientMessage(playerid, COLOR_INFO, "* /interiortodos [interior]");

        SendClientMessageToAllf(COLOR_ADMIN_COMMAND, "* %s alterou o interior de todos para %d.", GetPlayerNamef(playerid), interior);
        foreach(new i: Player)
        {
            if(GetPlayerGamemode(i) == GAMEMODE_LOBBY)
            {
                SetPlayerInterior(i, interior);
            }
        }
    }
    else
    {
        SendClientMessage(playerid, COLOR_ERROR, "* Você não tem permissão.");
    }
    return 1;
}

//------------------------------------------------------------------------------

YCMD:matartodos(playerid, params[], help)
{
    if(GetPlayerAdminLevel(playerid) >= PLAYER_RANK_SUB_OWNER)
    {
        SendClientMessageToAllf(COLOR_ADMIN_COMMAND, "* %s matou todos.", GetPlayerNamef(playerid));
        foreach(new i: Player)
        {
            if(GetPlayerGamemode(i) == GAMEMODE_LOBBY && i != playerid)
            {
                SetPlayerHealth(i, 0.0);
            }
        }
    }
    else
    {
        SendClientMessage(playerid, COLOR_ERROR, "* Você não tem permissão.");
    }
    return 1;
}

//------------------------------------------------------------------------------

YCMD:congelartodos(playerid, params[], help)
{
    if(GetPlayerAdminLevel(playerid) >= PLAYER_RANK_SUB_OWNER)
    {
        SendClientMessageToAllf(COLOR_ADMIN_COMMAND, "* %s congelou todos.", GetPlayerNamef(playerid));
        foreach(new i: Player)
        {
            if(GetPlayerGamemode(i) == GAMEMODE_LOBBY && i != playerid)
            {
                TogglePlayerControllable(i, false);
            }
        }
    }
    else
    {
        SendClientMessage(playerid, COLOR_ERROR, "* Você não tem permissão.");
    }
    return 1;
}

//------------------------------------------------------------------------------

YCMD:descongelartodos(playerid, params[], help)
{
    if(GetPlayerAdminLevel(playerid) >= PLAYER_RANK_SUB_OWNER)
    {
        SendClientMessageToAllf(COLOR_ADMIN_COMMAND, "* %s congelou todos.", GetPlayerNamef(playerid));
        foreach(new i: Player)
        {
            if(GetPlayerGamemode(i) == GAMEMODE_LOBBY)
            {
                TogglePlayerControllable(i, true);
            }
        }
    }
    else
    {
        SendClientMessage(playerid, COLOR_ERROR, "* Você não tem permissão.");
    }
    return 1;
}

//------------------------------------------------------------------------------

YCMD:ips(playerid, params[], help)
{
    if(GetPlayerAdminLevel(playerid) >= PLAYER_RANK_SUB_OWNER)
    {
        new output[4096], ip[16], string[48];
        strcat(output, "Nome\tIP\n");
        foreach(new i: Player)
        {
            GetPlayerIp(i, ip, 16);
            format(string, sizeof(string), "%s\t%s\n", GetPlayerNamef(i), ip);
            strcat(output, string);
        }
        ShowPlayerDialog(playerid, DIALOG_PLAYERS_IP, DIALOG_STYLE_TABLIST_HEADERS, "IP dos Jogadores", output, "Fechar", "");
    }
    else
    {
        SendClientMessage(playerid, COLOR_ERROR, "* Você não tem permissão.");
    }
    return 1;
}

//------------------------------------------------------------------------------

YCMD:invisivel(playerid, params[], help)
{
    if(GetPlayerAdminLevel(playerid) >= PLAYER_RANK_SUB_OWNER)
    {
        if(GetPlayerGamemode(playerid) != GAMEMODE_FREEROAM)
            return SendClientMessage(playerid, COLOR_ERROR, "* Você precisa estar no freeroam.");
        SendClientMessage(playerid, COLOR_ADMIN_COMMAND, "* Você está invisível, use /visivel para voltar.");
        SetPlayerVirtualWorld(playerid, 8976);
    }
    else
    {
        SendClientMessage(playerid, COLOR_ERROR, "* Você não tem permissão.");
    }
    return 1;
}

//------------------------------------------------------------------------------

YCMD:visivel(playerid, params[], help)
{
    if(GetPlayerAdminLevel(playerid) >= PLAYER_RANK_SUB_OWNER)
    {
        if(GetPlayerGamemode(playerid) != GAMEMODE_FREEROAM)
            return SendClientMessage(playerid, COLOR_ERROR, "* Você precisa estar no freeroam.");
        SendClientMessage(playerid, COLOR_ADMIN_COMMAND, "* Você voltou a ser visível.");
        SetPlayerVirtualWorld(playerid, 0);
    }
    else
    {
        SendClientMessage(playerid, COLOR_ERROR, "* Você não tem permissão.");
    }
    return 1;
}

//------------------------------------------------------------------------------

GenerateVIPKey()
{
    new allowed_characters[] = {
        'A', 'B', 'C', 'D', 'E',
        'F', 'G', 'H', 'I', 'J',
        'K', 'L', 'M', 'N', 'O',
        'P', 'Q', 'R', 'S', 'T',
        'U', 'V', 'W', 'X', 'Y',
        'Z', '0', '1', '2', '3',
        '4', '5', '6', '7', '8',
        '9'
    };

    new key[30], character;
    for(new i = 0; i < sizeof(key) - 1; i++)
    {
        character = random(sizeof(allowed_characters));
        key[i] = allowed_characters[character];

        if(i == 4 || i == 10 || i == 16 || i == 22)
        {
            i++;
            key[i] = '-';
        }
    }
    return key;
}

/*
OOOOOOOOO     WWWWWWWW                           WWWWWWWWNNNNNNNN        NNNNNNNNEEEEEEEEEEEEEEEEEEEEEERRRRRRRRRRRRRRRRR
OO:::::::::OO   W::::::W                           W::::::WN:::::::N       N::::::NE::::::::::::::::::::ER::::::::::::::::R
OO:::::::::::::OO W::::::W                           W::::::WN::::::::N      N::::::NE::::::::::::::::::::ER::::::RRRRRR:::::R
O:::::::OOO:::::::OW::::::W                           W::::::WN:::::::::N     N::::::NEE::::::EEEEEEEEE::::ERR:::::R     R:::::R
O::::::O   O::::::O W:::::W           WWWWW           W:::::W N::::::::::N    N::::::N  E:::::E       EEEEEE  R::::R     R:::::R
O:::::O     O:::::O  W:::::W         W:::::W         W:::::W  N:::::::::::N   N::::::N  E:::::E               R::::R     R:::::R
O:::::O     O:::::O   W:::::W       W:::::::W       W:::::W   N:::::::N::::N  N::::::N  E::::::EEEEEEEEEE     R::::RRRRRR:::::R
O:::::O     O:::::O    W:::::W     W:::::::::W     W:::::W    N::::::N N::::N N::::::N  E:::::::::::::::E     R:::::::::::::RR
O:::::O     O:::::O     W:::::W   W:::::W:::::W   W:::::W     N::::::N  N::::N:::::::N  E:::::::::::::::E     R::::RRRRRR:::::R
O:::::O     O:::::O      W:::::W W:::::W W:::::W W:::::W      N::::::N   N:::::::::::N  E::::::EEEEEEEEEE     R::::R     R:::::R
O:::::O     O:::::O       W:::::W:::::W   W:::::W:::::W       N::::::N    N::::::::::N  E:::::E               R::::R     R:::::R
O::::::O   O::::::O        W:::::::::W     W:::::::::W        N::::::N     N:::::::::N  E:::::E       EEEEEE  R::::R     R:::::R
O:::::::OOO:::::::O         W:::::::W       W:::::::W         N::::::N      N::::::::NEE::::::EEEEEEEE:::::ERR:::::R     R:::::R
OO:::::::::::::OO           W:::::W         W:::::W          N::::::N       N:::::::NE::::::::::::::::::::ER::::::R     R:::::R
OO:::::::::OO              W:::W           W:::W           N::::::N        N::::::NE::::::::::::::::::::ER::::::R     R:::::R
OOOOOOOOO                 WWW             WWW            NNNNNNNN         NNNNNNNEEEEEEEEEEEEEEEEEEEEEERRRRRRRR     RRRRRRR

*/

//------------------------------------------------------------------------------

YCMD:setadmin(playerid, params[], help)
{
   if(GetPlayerAdminLevel(playerid) == PLAYER_RANK_OWNER || IsPlayerAdmin(playerid))
   {
       new targetid, level;
       if(sscanf(params, "ui", targetid, level))
           return SendClientMessage(playerid, COLOR_INFO, "* /setadmin [playerid] [level]");

       else if(!IsPlayerLogged(targetid))
           return SendClientMessage(playerid, COLOR_ERROR, "* O jogador não está conectado.");

       else if(level < 0 || level > 5)
           return SendClientMessage(playerid, COLOR_ERROR, "* Nível administrativo inválido.");

       SetPlayerAdminLevel(targetid, level);
       if(playerid != targetid)
       {
           SendClientMessagef(targetid, COLOR_PLAYER_COMMAND, "* %s alterou seu cargo administrativo para %s.", GetPlayerNamef(playerid), GetPlayerAdminRankName(targetid));
       }
       SendClientMessagef(playerid, COLOR_PLAYER_COMMAND, "* Você alterou o cargo administrativo de %s para %s.", GetPlayerNamef(targetid), GetPlayerAdminRankName(targetid));
   }
   else
   {
       SendClientMessage(playerid, COLOR_ERROR, "* Você não tem permissão.");
   }
   return 1;
}

//------------------------------------------------------------------------------

YCMD:nomegm(playerid, params[], help)
{
   if(GetPlayerAdminLevel(playerid) == PLAYER_RANK_OWNER)
   {
       new name[64];
       if(sscanf(params, "s[64]", name))
           return SendClientMessage(playerid, COLOR_INFO, "* /nomegm [nome]");

       SetGameModeText(name);
       SendClientMessageToAllf(COLOR_ADMIN_COMMAND, "* %s alterou o nome do gamemode para %s.", GetPlayerNamef(playerid), name);
   }
   else
   {
       SendClientMessage(playerid, COLOR_ERROR, "* Você não tem permissão.");
   }
   return 1;
}

//------------------------------------------------------------------------------

YCMD:nomeserver(playerid, params[], help)
{
   if(GetPlayerAdminLevel(playerid) == PLAYER_RANK_OWNER)
   {
       new name[64];
       if(sscanf(params, "s[64]", name))
           return SendClientMessage(playerid, COLOR_INFO, "* /nomeserver [nome]");

       new rconcmd[80];
       format(rconcmd, sizeof(rconcmd), "hostname %s", name);
       SendRconCommand(rconcmd);
       SendClientMessageToAllf(COLOR_ADMIN_COMMAND, "* %s alterou o nome do servidor para %s.", GetPlayerNamef(playerid), name);
   }
   else
   {
       SendClientMessage(playerid, COLOR_ERROR, "* Você não tem permissão.");
   }
   return 1;
}

//------------------------------------------------------------------------------

YCMD:nomemapa(playerid, params[], help)
{
   if(GetPlayerAdminLevel(playerid) == PLAYER_RANK_OWNER)
   {
       new name[64];
       if(sscanf(params, "s[64]", name))
           return SendClientMessage(playerid, COLOR_INFO, "* /nomemapa [nome]");

       new rconcmd[80];
       format(rconcmd, sizeof(rconcmd), "mapname %s", name);
       SendRconCommand(rconcmd);
       SendClientMessageToAllf(COLOR_ADMIN_COMMAND, "* %s alterou o nome do mapa do servidor para %s.", GetPlayerNamef(playerid), name);
   }
   else
   {
       SendClientMessage(playerid, COLOR_ERROR, "* Você não tem permissão.");
   }
   return 1;
}

//------------------------------------------------------------------------------

YCMD:setargravidade(playerid, params[], help)
{
   if(GetPlayerAdminLevel(playerid) == PLAYER_RANK_OWNER)
   {
       new Float:gravity;
       if(sscanf(params, "f", gravity))
           return SendClientMessage(playerid, COLOR_INFO, "* /setargravidade [gravidade]");

       SetGravity(gravity);
       SendClientMessageToAllf(COLOR_ADMIN_COMMAND, "* %s alterou a gravidade do servidor para %.2f.", GetPlayerNamef(playerid), gravity);
   }
   else
   {
       SendClientMessage(playerid, COLOR_ERROR, "* Você não tem permissão.");
   }
   return 1;
}

//------------------------------------------------------------------------------

YCMD:trancarserver(playerid, params[], help)
{
   if(GetPlayerAdminLevel(playerid) == PLAYER_RANK_OWNER)
   {
       new password[64];
       if(sscanf(params, "s[64]", password))
           return SendClientMessage(playerid, COLOR_INFO, "* /trancarserver [senha]");

       new rconcmd[80];
       format(rconcmd, sizeof(rconcmd), "password %s", password);
       SendRconCommand(rconcmd);
       SendClientMessageToAllf(COLOR_ADMIN_COMMAND, "* %s trancou o servidor.", GetPlayerNamef(playerid));
   }
   else
   {
       SendClientMessage(playerid, COLOR_ERROR, "* Você não tem permissão.");
   }
   return 1;
}

//------------------------------------------------------------------------------

YCMD:destrancarserver(playerid, params[], help)
{
   if(GetPlayerAdminLevel(playerid) == PLAYER_RANK_OWNER)
   {
       SendRconCommand("password 0");
       SendClientMessageToAllf(COLOR_ADMIN_COMMAND, "* %s trancou o servidor.", GetPlayerNamef(playerid));
   }
   else
   {
       SendClientMessage(playerid, COLOR_ERROR, "* Você não tem permissão.");
   }
   return 1;
}

//------------------------------------------------------------------------------

hook OnGameModeInit()
{
	Command_AddAltNamed("trazer",      "puxar");
	Command_AddAltNamed("kick",        "kickar");
	Command_AddAltNamed("ban",         "banir");
	Command_AddAltNamed("aviso",       "advertir");
	Command_AddAltNamed("pm",          "particular");
	Command_AddAltNamed("contar",      "contagem");
	Command_AddAltNamed("setint",      "setarinterior");
	Command_AddAltNamed("setvw",       "setarvw");
	Command_AddAltNamed("mutar",       "calar");
	Command_AddAltNamed("desmutar",    "descalar");
    Command_AddAltNamed("setarvida",   "sethp");
	Command_AddAltNamed("setarcolete", "setarmour");
	Command_AddAltNamed("setskin",     "forcarskin");
	Command_AddAltNamed("setvip",      "darvip");
	Command_AddAltNamed("moverplayer", "setarpos");
	Command_AddAltNamed("setskin",     "setarskin");
	return 1;
}

//------------------------------------------------------------------------------

public OnDeleteAccount(playerid)
{
    if(cache_affected_rows() > 0)
    {
        SendClientMessage(playerid, COLOR_SUCCESS, "* Usuário deletado com sucesso.");
    }
    else
    {
        PlayErrorSound(playerid);
        SendClientMessage(playerid, COLOR_ERROR, "* Usuário não encontrado.");
    }
}

//------------------------------------------------------------------------------

hook OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
    switch (dialogid)
    {
        case DIALOG_SURVEY:
        {
            PlaySelectSound(playerid);
            if(response)
            {
                gSurveyData[e_survey_yes]++;
                SendClientMessage(playerid, COLOR_SUCCESS, "* Você votou sim.");
            }
            else
            {
                gSurveyData[e_survey_no]++;
                SendClientMessage(playerid, COLOR_SUCCESS, "* Você votou não.");
            }
        }
        case DIALOG_GENERATE_VIP_KEY:
        {
            if(!response)
            {
                PlayCancelSound(playerid);
            }
            else
            {
                switch (listitem)
                {
                    case 0:
                        ShowPlayerDialog(playerid, DIALOG_GEN_VIP_KEY_DAYS, DIALOG_STYLE_INPUT, "Gerar chave vip: Dias", "Informe quantos dias este VIP irá durar:", "Confirmar", "Voltar");
                    case 1:
                        ShowPlayerDialog(playerid, DIALOG_GEN_VIP_KEY_TYPE, DIALOG_STYLE_LIST, "Gerar chave vip: Tipo", "Bronze\nPrata\nOuro", "Confirmar", "Voltar");
                    case 2:
                    {
                        if(GetPVarInt(playerid, "gen_vip_days") < 1)
                        {
                            PlayErrorSound(playerid);
                            SendClientMessage(playerid, COLOR_ERROR, "* Você não definiu os dias.");
                            ShowPlayerDialog(playerid, DIALOG_GENERATE_VIP_KEY, DIALOG_STYLE_LIST, "Gerar chave VIP", "Dias\nTipo\nGerar", "Selecionar", "Fechar");
                            return 1;
                        }

                        new key[30], type[30];
                        key = GenerateVIPKey();

                        if(GetPVarInt(playerid, "gen_vip_type") == 0)
                            type = "Bronze";
                        else if(GetPVarInt(playerid, "gen_vip_type") == 1)
                            type = "Prata";
                        else if(GetPVarInt(playerid, "gen_vip_type") == 2)
                            type = "Ouro";

                        SendClientMessagef(playerid, COLOR_TITLE, "Chave VIP Gerada!");
                        SendClientMessagef(playerid, COLOR_SUB_TITLE, "Dias: %d", GetPVarInt(playerid, "gen_vip_days"));
                        SendClientMessagef(playerid, COLOR_SUB_TITLE, "Tipo: %s", type);
                        SendClientMessagef(playerid, COLOR_SUB_TITLE, "Chave: %s", key);

                        new query[148];
                        mysql_format(gMySQL, query, sizeof(query), "INSERT INTO `vip_keys` (`serial`, `days`, `type`, `used`) VALUES ('%e', %d, %d, 0)", key, GetPVarInt(playerid, "gen_vip_days"), GetPVarInt(playerid, "gen_vip_type"));
                        mysql_tquery(gMySQL, query);
                    }
                }
            }
        }
        case DIALOG_GEN_VIP_KEY_DAYS:
        {
            if(!response)
            {
                PlayCancelSound(playerid);
                ShowPlayerDialog(playerid, DIALOG_GENERATE_VIP_KEY, DIALOG_STYLE_LIST, "Gerar chave VIP", "Dias\nTipo\nGerar", "Selecionar", "Fechar");
            }
            else
            {
                new days;
                if(sscanf(inputtext, "i", days))
                {
                    PlayErrorSound(playerid);
                    ShowPlayerDialog(playerid, DIALOG_GEN_VIP_KEY_DAYS, DIALOG_STYLE_INPUT, "Gerar chave vip: Dias", "Informe quantos dias este VIP irá durar:", "Confirmar", "Voltar");
                }

                else if(days < 1)
                {
                    PlayErrorSound(playerid);
                    SendClientMessage(playerid, COLOR_ERROR, "* Dias não podem ser menor que 1.");
                    ShowPlayerDialog(playerid, DIALOG_GEN_VIP_KEY_DAYS, DIALOG_STYLE_INPUT, "Gerar chave vip: Dias", "Informe quantos dias este VIP irá durar:", "Confirmar", "Voltar");
                }

                else
                {
                    PlaySelectSound(playerid);
                    SetPVarInt(playerid, "gen_vip_days", days);
                    ShowPlayerDialog(playerid, DIALOG_GENERATE_VIP_KEY, DIALOG_STYLE_LIST, "Gerar chave VIP", "Dias\nTipo\nGerar", "Selecionar", "Fechar");
                }
            }
        }
        case DIALOG_GEN_VIP_KEY_TYPE:
        {
            if(!response)
            {
                PlayCancelSound(playerid);
                ShowPlayerDialog(playerid, DIALOG_GENERATE_VIP_KEY, DIALOG_STYLE_LIST, "Gerar chave VIP", "Dias\nTipo\nGerar", "Selecionar", "Fechar");
            }
            else
            {
                PlaySelectSound(playerid);
                SetPVarInt(playerid, "gen_vip_type", listitem);
                ShowPlayerDialog(playerid, DIALOG_GENERATE_VIP_KEY, DIALOG_STYLE_LIST, "Gerar chave VIP", "Dias\nTipo\nGerar", "Selecionar", "Fechar");
            }
        }
    }
    return 1;
}

//------------------------------------------------------------------------------

timer RestartGameMode[5000]()
{
    SendRconCommand("gmx");
}

//------------------------------------------------------------------------------

timer EndSurvey[60000]()
{
    SendClientMessageToAll(COLOR_ADMIN_COMMAND, "* Enquete encerrada, resultados:");
    SendClientMessageToAll(COLOR_ADMIN_COMMAND, " ");
    SendClientMessageToAllf(COLOR_ADMIN_COMMAND, "* Sim: %d", gSurveyData[e_survey_yes]);
    SendClientMessageToAllf(COLOR_ADMIN_COMMAND, "* Não: %d", gSurveyData[e_survey_no]);
    gSurveyData[e_survey_active] = false;
}
