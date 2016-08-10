/*******************************************************************************
* NOME DO ARQUIVO :		modules/player/commands.pwn
*
* DESCRIÇÃO :
*	   Comandos quem podem ser usados por qualquer jogador.
*
* NOTAS :
*	   -
*/

#include <YSI\y_hooks>

//------------------------------------------------------------------------------

static gplMarkExt[MAX_PLAYERS][2];
static Float:gplMarkPos[MAX_PLAYERS][3];

static gplAutoRepair[MAX_PLAYERS];
static gplHideNameTags[MAX_PLAYERS];
static gplGotoBlocked[MAX_PLAYERS];
static gplDriftActive[MAX_PLAYERS] = {true, ...};
static gplDriftCounter[MAX_PLAYERS];

static gCountDown;

static gplCreatedVehicle[MAX_PLAYERS][MAX_CREATED_VEHICLE_PER_PLAYER];

//------------------------------------------------------------------------------

hook OnGameModeInit()
{
	Command_AddAltNamed("comandos",		"cmds");
	Command_AddAltNamed("janela",		"j");
	Command_AddAltNamed("lobby",		"m");
	Command_AddAltNamed("car",			"v");
	Command_AddAltNamed("myacc",		"stats");
	Command_AddAltNamed("myacc",		"rg");
	Command_AddAltNamed("sp",			"marcar");
	Command_AddAltNamed("irp",			"irmarca");
	Command_AddAltNamed("ir",			"goto");
	Command_AddAltNamed("pm",			"mp");
	return 1;
}

//------------------------------------------------------------------------------

// Recomendável manter a lista em até 10 linhas, para melhor visualização
YCMD:comandos(playerid, params[], help)
{
	PlaySelectSound(playerid);
	ShowPlayerDialog(playerid, DIALOG_COMMAND_LIST, DIALOG_STYLE_MSGBOX, "Lista de Comandos",
	"* /car - /reparar - /ir - /pm - /tunar - /x - /listadecarros - /clima - /dia - /tarde - /noite\n\
	* /placa - /lutas - /sp - /irp - /mdist - /reportar - /relatorio - /ejetar - /farol - /admins - /id\n\
	* /eu - /pagar - /autoreparo - /janela - /nick - /goto - /kill - /myacc - /mudarsenha - /mudarnome\n\
	* /contar - /drift - /contador - /lobby\n\
	* /carcmd - /regras - /creditos - /acmds", "Fechar", "");
	/*SendClientMessage(playerid, COLOR_TITLE, "---------------------------------------- Comandos ----------------------------------------");
	SendClientMessage(playerid, COLOR_SUB_TITLE, "* /car - /reparar - /ir - /pm - /tunar - /x - /listadecarros - /clima - /dia - /tarde - /noite");
	SendClientMessage(playerid, COLOR_SUB_TITLE, "* /placa - /lutas - /sp - /irp - /mdist - /reportar - /relatorio - /ejetar - /farol - /admins - /id");
	SendClientMessage(playerid, COLOR_SUB_TITLE, "* /eu - /pagar - /autoreparo - /janela - /nick - /goto - /kill - /myacc - /mudarsenha - /mudarnome");
	SendClientMessage(playerid, COLOR_SUB_TITLE, "* /contar - /drift - /contador - /lobby");
	SendClientMessage(playerid, COLOR_SUB_TITLE, "* /carcmd - /regras - /creditos");
	if(IsPlayerAdmin(playerid) || GetPlayerAdminLevel(playerid) >= PLAYER_RANK_RECRUIT)
		SendClientMessage(playerid, COLOR_SUB_TITLE, "* /acmds");
	SendClientMessage(playerid, COLOR_TITLE, "---------------------------------------- Comandos ----------------------------------------");*/
	return 1;
}

//------------------------------------------------------------------------------

YCMD:carcmd(playerid, params[], help)
{
	SendClientMessage(playerid, COLOR_TITLE, "---------------------------------------- Comandos - Carros ----------------------------------------");
	SendClientMessage(playerid, COLOR_SUB_TITLE, "* /car - /reparar - /tunar - /x - /listadecarros - /placa - /ejetar - /farol - /janela - /autoreparo");
	SendClientMessage(playerid, COLOR_TITLE, "---------------------------------------- Comandos - Carros ----------------------------------------");
	return 1;
}

//------------------------------------------------------------------------------

YCMD:regras(playerid, params[], help)
{
	SendClientMessage(playerid, COLOR_TITLE, "---------------------------------------- Regras ----------------------------------------");
	SendClientMessage(playerid, COLOR_SUB_TITLE, "* Não é permitido utilizar cheats.");
	SendClientMessage(playerid, COLOR_SUB_TITLE, "* Não é permitido desrespeitar outros jogadores.");
	SendClientMessage(playerid, COLOR_SUB_TITLE, "* Não é permitido fazer anúncio de outros servidores.");
	SendClientMessage(playerid, COLOR_TITLE, "---------------------------------------- Regras ----------------------------------------");
	return 1;
}

//------------------------------------------------------------------------------

YCMD:creditos(playerid, params[], help)
{
	PlaySelectSound(playerid);
	ShowPlayerDialog(playerid, DIALOG_CREDITS, DIALOG_STYLE_MSGBOX, "{ffffff}Pessoas que contruibuiram para que o {67f571}B{ffffff}rothers in {67f571}Game{ffffff} existisse",
	"\t\t\t\t{67f571}B{ffffff}rothers in {67f571}Game{ffffff}\n\t\t\t{ffffff}Desenvolvido pela equipe {67f571}B{ffffff}in{67f571}G\n\n{ffffff}Contribuidores:\nY_Less, Incognito, BlueG, SA-MP Team e você", "Fechar", "");
	return 1;
}

//------------------------------------------------------------------------------

YCMD:contar(playerid, params[], help)
{
	if(gCountDown > 0)
		return SendClientMessage(playerid, COLOR_ERROR, "* Uma contagem já está em andamento.");

	new timer;
	sscanf(params, "I(3)", timer);

	if(timer > 10 || timer < 3)
		return SendClientMessage(playerid, COLOR_ERROR, "* A contagem não pode ser menor que 3 e maior que 10.");

	gCountDown = timer;
	CountDown();
	SendClientMessageToAllf(0xc2d645ff, "* %s iniciou uma contagem regressiva!", GetPlayerNamef(playerid));
	return 1;
}

//------------------------------------------------------------------------------

YCMD:myacc(playerid, params[], help)
{
	new ip[16];
	GetPlayerIp(playerid, ip, 16);
	SendClientMessage(playerid, COLOR_TITLE, "---------------------------------------- Minha Conta ----------------------------------------");
	SendClientMessagef(playerid, COLOR_SUB_TITLE, "Nome: %s - Dinheiro: $%d - Banco: $%d - IP: %s", GetPlayerNamef(playerid), GetPlayerCash(playerid), GetPlayerBankCash(playerid), ip);
	SendClientMessagef(playerid, COLOR_SUB_TITLE, "Ultimo Login: %s", convertTimestamp(GetPlayerLastLogin(playerid)));
	SendClientMessage(playerid, COLOR_TITLE, "---------------------------------------- Minha Conta ----------------------------------------");
	return 1;
}

//------------------------------------------------------------------------------

YCMD:kill(playerid, params[], help)
{
	SetPlayerHealth(playerid, 0.0);
	return 1;
}

//------------------------------------------------------------------------------

YCMD:drift(playerid, params[], help)
{
	if(!gplDriftActive[playerid])
	{
		PlayConfirmSound(playerid);
		SendClientMessage(playerid, COLOR_SUCCESS, "* Você ativou o contador de drift.");
		gplDriftActive[playerid] = true;
	}
	else
	{
		PlayCancelSound(playerid);
		SendClientMessage(playerid, COLOR_SUCCESS, "* Você desativou o contador de drift.");
		gplDriftActive[playerid] = false;

		if(gplDriftCounter[playerid] == 0)
		{
			HidePlayerDriftTextdraw(playerid, true);
		}
	}
	return 1;
}

//------------------------------------------------------------------------------

YCMD:contador(playerid, params[], help)
{
	if(!gplDriftCounter[playerid])
	{
		PlayConfirmSound(playerid);
		SendClientMessage(playerid, COLOR_SUCCESS, "* Você alterou o contador de drift para o estilo #2.");
		gplDriftCounter[playerid] = true;
		HidePlayerDriftTextdraw(playerid, true);
	}
	else
	{
		PlayConfirmSound(playerid);
		SendClientMessage(playerid, COLOR_SUCCESS, "* Você alterou o contador de drift para o estilo #1.");
		gplDriftCounter[playerid] = false;
	}
	return 1;
}

//------------------------------------------------------------------------------

YCMD:goto(playerid, params[], help)
{
	if(!gplGotoBlocked[playerid])
	{
		PlayCancelSound(playerid);
		SendClientMessage(playerid, COLOR_SUCCESS, "* Você bloqueou os teleportes até você.");
		gplGotoBlocked[playerid] = true;
	}
	else
	{
		PlayConfirmSound(playerid);
		SendClientMessage(playerid, COLOR_SUCCESS, "* Você desbloqueou os teleportes até você.");
		gplGotoBlocked[playerid] = false;
	}
	return 1;
}

//------------------------------------------------------------------------------

YCMD:nick(playerid, params[], help)
{
	if(!gplHideNameTags[playerid])
	{
		PlayCancelSound(playerid);
		SendClientMessage(playerid, COLOR_SUCCESS, "* Você ocultou todos os nicks.");
		gplHideNameTags[playerid] = true;

		foreach(new i: Player)
		{
			ShowPlayerNameTagForPlayer(playerid, i, false);
		}
	}
	else
	{
		PlayConfirmSound(playerid);
		SendClientMessage(playerid, COLOR_SUCCESS, "* Você mostrou todos os nicks.");
		gplHideNameTags[playerid] = false;

		foreach(new i: Player)
		{
			ShowPlayerNameTagForPlayer(playerid, i, true);
		}
	}
	return 1;
}

//------------------------------------------------------------------------------

YCMD:autoreparo(playerid, params[], help)
{
	if(!gplAutoRepair[playerid])
	{
		PlayConfirmSound(playerid);
		SendClientMessage(playerid, COLOR_SUCCESS, "* Você ativou o reparo automático para seus veículos.");
		gplAutoRepair[playerid] = true;
	}
	else
	{
		PlayCancelSound(playerid);
		SendClientMessage(playerid, COLOR_SUCCESS, "* Você desativou o reparo automático para seus veículos.");
		gplAutoRepair[playerid] = false;
	}
	return 1;
}

//------------------------------------------------------------------------------

YCMD:pagar(playerid, params[], help)
{
	new	targetid, value;
	if(sscanf(params, "ui", targetid, value))
		return SendClientMessage(playerid, COLOR_INFO, "* /pagar [playerid] [valor]");

	else if(!IsPlayerLogged(targetid))
		return SendClientMessage(playerid, COLOR_ERROR, "* Jogador não conectado.");

	else if(GetPlayerDistanceFromPlayer(playerid, targetid) > 5.0)
		return SendClientMessage(playerid, COLOR_ERROR, "* Você não está próximo do jogador.");

	else if(GetPlayerCash(playerid) < value)
		return SendClientMessage(playerid, COLOR_ERROR, "* Você não tem essa quantia de dinheiro.");

	SendClientMessagef(playerid, 0xa5f413ff, "* Você deu $%d para %s.", value, GetPlayerNamef(targetid));
	SendClientMessagef(targetid, 0xa5f413ff, "* %s deu $%d para você.", GetPlayerNamef(playerid), value);

	new message[38 + MAX_PLAYER_NAME];
	format(message, sizeof(message), "deu uma quantia de dinheiro para %s.", GetPlayerNamef(targetid));
	SendClientActionMessage(playerid, 20.0, message);

	SetPlayerCash(playerid, GetPlayerCash(playerid) - value);
	SetPlayerCash(targetid, GetPlayerCash(targetid) + value);
	return 1;
}

//------------------------------------------------------------------------------

YCMD:mudarnome(playerid, params[], help)
{
	new	current_password[32], newName[MAX_PLAYER_NAME];
	if(sscanf(params, "s[32]s[32]", current_password, newName))
		return SendClientMessage(playerid, COLOR_INFO, "* /mudarsenha [senha atual] [novo nome]");

	if(strlen(newName) > MAX_PLAYER_NAME)
		return SendClientMessage(playerid, COLOR_ERROR, "* Nome muito longo.");

	if(!strcmp(GetPlayerPassword(playerid), current_password) && !isnull(current_password))
	{
		ChangePlayerName(playerid, newName);
	}
	else
	{
		SendClientMessage(playerid, COLOR_ERROR, "* Senha atual incorreta.");
	}
	return 1;
}

//------------------------------------------------------------------------------

YCMD:mudarsenha(playerid, params[], help)
{
	new	current_password[32], new_password[32];
	if(sscanf(params, "s[32]s[32]", current_password, new_password))
		return SendClientMessage(playerid, COLOR_INFO, "* /mudarsenha [senha atual] [nova senha]");

	if(strlen(new_password) > 31)
		return SendClientMessage(playerid, COLOR_ERROR, "* Senha muito longa.");

	if(!strcmp(GetPlayerPassword(playerid), current_password) && !isnull(current_password))
	{
		SetPlayerPassword(playerid, new_password);
		SendClientMessage(playerid, COLOR_SUCCESS, "* Senha alterada com sucesso.");
	}
	else
	{
		SendClientMessage(playerid, COLOR_ERROR, "* Senha atual incorreta.");
	}
	return 1;
}

//------------------------------------------------------------------------------

YCMD:eu(playerid, params[], help)
{
	if(isnull(params))
		return SendClientMessage(playerid, COLOR_INFO, "* /eu [mensagem]");

	SendClientActionMessage(playerid, 20.0, params);
	return 1;
}

//------------------------------------------------------------------------------

YCMD:id(playerid, params[], help)
{
	new targetid;
	if(sscanf(params, "u", targetid))
		return SendClientMessage(playerid, COLOR_INFO, "* /id [jogador]");

	else if(!IsPlayerLogged(targetid))
		SendClientMessage(playerid, COLOR_ERROR, "* Jogador não conectado.");

    new output[40];
	format(output, sizeof(output), "* %s(ID: %i)", GetPlayerNamef(targetid), targetid);
	SendClientMessage(playerid, COLOR_INFO, output);
	return 1;
}

//------------------------------------------------------------------------------

YCMD:janela(playerid, params[], help)
{
    if(!IsPlayerInAnyVehicle(playerid))
        SendClientMessage(playerid, COLOR_ERROR, "* Você não está em um veículo.");
    else
    {
        new driver, passenger, backleft, backright;
        new vehicleid = GetPlayerVehicleID(playerid);
        GetVehicleParamsCarWindows(vehicleid, driver, passenger, backleft, backright);

        switch(GetPlayerVehicleSeat(playerid))
        {
            case 0:
            {
                if(driver == -1 || driver == 1)
                {
                    SendClientActionMessage(playerid, 15.0, "abre a janela do motorista.");
                    SetVehicleParamsCarWindows(vehicleid, 0, passenger, backleft, backright);
                }
                else
                {
                    SendClientActionMessage(playerid, 15.0, "fecha a janela do motorista.");
                    SetVehicleParamsCarWindows(vehicleid, 1, passenger, backleft, backright);
                }
            }
            case 1:
            {
                if(passenger == -1 || passenger == 1)
                {
                    SendClientActionMessage(playerid, 15.0, "abre a janela do passageiro.");
                    SetVehicleParamsCarWindows(vehicleid, driver, 0, backleft, backright);
                }
                else
                {
                    SendClientActionMessage(playerid, 15.0, "fecha a janela do passageiro.");
                    SetVehicleParamsCarWindows(vehicleid, driver, 1, backleft, backright);
                }
            }
            case 2:
            {
                if(backleft == -1 || backleft == 1)
                {
                    SendClientActionMessage(playerid, 15.0, "abre a janela do passageiro.");
                    SetVehicleParamsCarWindows(vehicleid, driver, passenger, 0, backright);
                }
                else
                {
                    SendClientActionMessage(playerid, 15.0, "fecha a janela do passageiro.");
                    SetVehicleParamsCarWindows(vehicleid, driver, passenger, 1, backright);
                }
            }
            case 3:
            {
                if(backright == -1 || backright == 1)
                {
                    SendClientActionMessage(playerid, 15.0, "abre a janela do passageiro.");
                    SetVehicleParamsCarWindows(vehicleid, driver, passenger, backleft, 0);
                }
                else
                {
                    SendClientActionMessage(playerid, 15.0, "fecha a janela do passageiro.");
                    SetVehicleParamsCarWindows(vehicleid, driver, passenger, backleft, 1);
                }
            }
            default:
            {
                SendClientMessage(playerid, COLOR_ERROR, "* Você não pode abrir essa janela.");
            }
        }
    }
    return 1;
}

//------------------------------------------------------------------------------

YCMD:farol(playerid, params[], help)
{
    if(!IsPlayerInAnyVehicle(playerid))
        SendClientMessage(playerid, COLOR_ERROR, "* Você não está em um veículo.");
    else if(GetPlayerState(playerid) != PLAYER_STATE_DRIVER)
        SendClientMessage(playerid, COLOR_ERROR, "* Você não é o motorista.");
    else
    {
        new engine, lights, alarm, doors, bonnet, boot, objective, vehicleid;
        vehicleid = GetPlayerVehicleID(playerid);
        GetVehicleParamsEx(vehicleid, engine, lights, alarm, doors, bonnet, boot, objective);

        if(lights == VEHICLE_PARAMS_OFF || lights == VEHICLE_PARAMS_UNSET)
		{
			PlayConfirmSound(playerid);
			SendClientMessage(playerid, COLOR_SUCCESS, "* Você ligou o farol do veículo.");
			SetVehicleParamsEx(vehicleid, engine, VEHICLE_PARAMS_ON, alarm, doors, bonnet, boot, objective);
		}
        else
		{
			PlayCancelSound(playerid);
			SendClientMessage(playerid, COLOR_SUCCESS, "* Você desligou o farol do veículo.");
			SetVehicleParamsEx(vehicleid, engine, VEHICLE_PARAMS_OFF, alarm, doors, bonnet, boot, objective);
		}
    }
    return 1;
}

//------------------------------------------------------------------------------

YCMD:ejetar(playerid, params[], help)
{
	if(!IsPlayerInAnyVehicle(playerid))
		return SendClientMessage(playerid, COLOR_ERROR, "* Você não está em um veículo.");

	else if(GetPlayerState(playerid) != PLAYER_STATE_DRIVER)
		return SendClientMessage(playerid, COLOR_ERROR, "* Você não é o motorista.");

	new targetid;
	if(sscanf(params, "u", targetid))
		return SendClientMessage(playerid, COLOR_INFO, "* /ejetar [playerid]");

	else if(!IsPlayerInVehicle(targetid, GetPlayerVehicleID(playerid)))
		return SendClientMessage(playerid, COLOR_ERROR, "* O jogador não está em seu veículo.");

	else if(playerid == targetid)
		return SendClientMessage(playerid, COLOR_ERROR, "* Você não pode ejetar você mesmo.");

	SendClientMessagef(playerid, 0xFFFFFFFF, "* Você ejetou {00ACE6}%s{FFFFFF} do veículo.", GetPlayerNamef(targetid));
	SendClientMessagef(targetid, 0xFFFFFFFF, "* Você foi ejetado do veículo por {00ACE6}%s{FFFFFF}.", GetPlayerNamef(playerid));
	RemovePlayerFromVehicle(targetid);
	return true;
}


//------------------------------------------------------------------------------

YCMD:admins(playerid, params[], help)
{
	new count = 0, string[74];
	SendClientMessage(playerid, COLOR_TITLE, "- Membros da moderação online -");

	foreach(new i: Player)
	{
		if(GetPlayerAdminLevel(i) >= PLAYER_RANK_RECRUIT)
		{
			format(string, sizeof string, "* {FFFFFF}[{%06x}%s{FFFFFF}] %s {A6A6A6}(ID: %i)", GetPlayerRankColor(i) >>> 8, GetPlayerAdminRankName(i, true), GetPlayerNamef(i), i);
			SendClientMessage(playerid, COLOR_INFO, string);
			count++;
		}
	}

	if(count == 0)
		SendClientMessage(playerid, COLOR_ERROR, "* Nenhum membro da moderação online.");
	return 1;
}

//------------------------------------------------------------------------------

YCMD:relatorio(playerid, params[], help)
{
	if(isnull(params))
		return SendClientMessage(playerid, COLOR_INFO, "* /relatorio [mensagem]");

	foreach(new i: Player)
	{
		if(GetPlayerAdminLevel(i) < PLAYER_RANK_RECRUIT)
			continue;

		new message[150 + MAX_PLAYER_NAME];
		format(message, 150 + MAX_PLAYER_NAME, "* Relatório de %s: %s", GetPlayerNamef(playerid), params);
		SendClientMessage(i, 0x5b809eff, message);
	}
	SendClientMessage(playerid, 0x5b809eff, "* Relatório enviado com sucesso.");
	return 1;
}

//------------------------------------------------------------------------------

YCMD:reportar(playerid, params[], help)
{
	new targetid, reason[128];
	if(sscanf(params, "us", targetid, reason))
		return SendClientMessage(playerid, COLOR_INFO, "* /reportar [playerid] [motivo]");

	if(playerid == targetid)
		return SendClientMessage(playerid, COLOR_ERROR, "* Você não pode reportar você mesmo.");

	if(IsPlayerNPC(targetid) || !IsPlayerLogged(targetid))
		return SendClientMessage(playerid, COLOR_ERROR, "* Jogador não conectado.");

	if(GetPlayerAdminLevel(targetid) > PLAYER_RANK_RECRUIT)
		return SendClientMessage(playerid, COLOR_ERROR, "* Você não pode reportar administradores, use o site/forum.");

	foreach(new i: Player)
	{
		if(GetPlayerAdminLevel(i) < PLAYER_RANK_RECRUIT)
			continue;

		new message[150 + MAX_PLAYER_NAME];
		format(message, 150 + MAX_PLAYER_NAME, "* %s reportou %s. Motivo: %s", GetPlayerNamef(playerid), GetPlayerNamef(targetid), reason);
		SendClientMessage(i, 0x5b809eff, message);
	}
	SendClientMessage(playerid, 0x5b809eff, "* Jogador reportado com sucesso.");
	return 1;
}

//------------------------------------------------------------------------------

YCMD:sp(playerid, params[], help)
{
    if(GetPlayerAdminLevel(playerid) < PLAYER_RANK_RECRUIT)
        return SendClientMessage(playerid, COLOR_ERROR, "* Você não tem permissão.");

    gplMarkExt[playerid][0] = GetPlayerInterior(playerid);
    gplMarkExt[playerid][1] = GetPlayerVirtualWorld(playerid);
    GetPlayerPos(playerid, gplMarkPos[playerid][0], gplMarkPos[playerid][1], gplMarkPos[playerid][2]);
	SendClientMessagef(playerid, COLOR_ADMIN_COMMAND, "* Você marcou sua posição atual. (%.2f, %.2f, %.2f, %d, %d)", gplMarkPos[playerid][0], gplMarkPos[playerid][1], gplMarkPos[playerid][2], gplMarkExt[playerid][0], gplMarkExt[playerid][1]);
	return 1;
}

//------------------------------------------------------------------------------

YCMD:irp(playerid, params[], help)
{
    if(GetPlayerAdminLevel(playerid) < PLAYER_RANK_RECRUIT)
        return SendClientMessage(playerid, COLOR_ERROR, "* Você não tem permissão.");

    SetPlayerInterior(playerid, gplMarkExt[playerid][0]);
    SetPlayerVirtualWorld(playerid, gplMarkExt[playerid][1]);
    if(GetPlayerState(playerid) != PLAYER_STATE_DRIVER)
        SetPlayerPos(playerid, gplMarkPos[playerid][0], gplMarkPos[playerid][1], gplMarkPos[playerid][2]);
    else
        SetVehiclePos(GetPlayerVehicleID(playerid), gplMarkPos[playerid][0], gplMarkPos[playerid][1], gplMarkPos[playerid][2]);
	SendClientMessagef(playerid, COLOR_ADMIN_COMMAND, "* Você foi até a posição marcada. (%.2f, %.2f, %.2f, %d, %d)", gplMarkPos[playerid][0], gplMarkPos[playerid][1], gplMarkPos[playerid][2], gplMarkExt[playerid][0], gplMarkExt[playerid][1]);
	return 1;
}

//------------------------------------------------------------------------------

YCMD:mdist(playerid, params[], help)
{
    if(GetPlayerAdminLevel(playerid) < PLAYER_RANK_RECRUIT)
        return SendClientMessage(playerid, COLOR_ERROR, "* Você não tem permissão.");

	SendClientMessagef(playerid, COLOR_ADMIN_COMMAND, "* Você está a %.2f units de distância da posição marcada. (%.2f, %.2f, %.2f, %d, %d)",
    GetPlayerDistanceFromPoint(playerid, gplMarkPos[playerid][0], gplMarkPos[playerid][1], gplMarkPos[playerid][2]), gplMarkPos[playerid][0], gplMarkPos[playerid][1], gplMarkPos[playerid][2], gplMarkExt[playerid][0], gplMarkExt[playerid][1]);
	return 1;
}

//------------------------------------------------------------------------------

YCMD:placa(playerid, params[], help)
{
	new plate[32];
	if(sscanf(params, "s[32]", plate))
		return SendClientMessage(playerid, COLOR_INFO, "* /placa [texto]");

	if(!IsPlayerInAnyVehicle(playerid))
		return SendClientMessage(playerid, COLOR_ERROR, "* Você não está em um veículo");

	if(GetPlayerState(playerid) != PLAYER_STATE_DRIVER)
		return SendClientMessage(playerid, COLOR_ERROR, "* Você não é o motorista deste veículo.");

	new vehicleid = GetPlayerVehicleID(playerid);
	new Float:x, Float:y, Float:z, Float:a;
	GetVehiclePos(vehicleid, x, y, z);
	GetVehicleZAngle(vehicleid, a);

	SetVehicleNumberPlate(vehicleid, plate);
	SetVehicleToRespawn(vehicleid);

	SetVehiclePos(vehicleid, x, y, z);
	SetVehicleZAngle(vehicleid, a);
	LinkVehicleToInterior(vehicleid, GetPlayerInterior(playerid));
	SetVehicleVirtualWorld(vehicleid, GetPlayerVirtualWorld(playerid));
	PutPlayerInVehicle(playerid, vehicleid, 0);
	return 1;
}

//------------------------------------------------------------------------------

YCMD:dia(playerid, params[], help)
{
	SetPlayerTime(playerid, 12, 00);
	return 1;
}

//------------------------------------------------------------------------------

YCMD:tarde(playerid, params[], help)
{
	SetPlayerTime(playerid, 18, 00);
	return 1;
}

//------------------------------------------------------------------------------

YCMD:noite(playerid, params[], help)
{
	SetPlayerTime(playerid, 01, 00);
	return 1;
}

//------------------------------------------------------------------------------

YCMD:lutas(playerid, params[], help)
{
	PlayConfirmSound(playerid);
	ShowPlayerDialog(playerid, DIALOG_FIGHTING_LIST, DIALOG_STYLE_LIST, "Lutas", "Normal\nBoxe\nKungfu\nKneeHead\nGrabKick\nElbow", "Definir", "Sair");
	return 1;
}
//------------------------------------------------------------------------------

YCMD:listadecarros(playerid, params[], help)
{
	new output[2706];
	strcat(output, "ID\tNome\n");
	for(new i = 0; i < sizeof(aVehicleNames); i++)
	{
		new string[32];
		format(string, sizeof(string), "%i\t%s\n",  i + 400, aVehicleNames[i]);
		strcat(output, string);
	}
	PlayConfirmSound(playerid);
	ShowPlayerDialog(playerid, DIALOG_VEHICLE_LIST, DIALOG_STYLE_TABLIST_HEADERS, "Lista de Carros", output, "Criar", "Sair");
	return 1;
}

//------------------------------------------------------------------------------

YCMD:x(playerid, params[], help)
{
	if(!IsPlayerInAnyVehicle(playerid))
		SendClientMessage(playerid, COLOR_ERROR, "* Você não está em um veículo.");
	else
	{
		new Float:a;
		GetVehicleZAngle(GetPlayerVehicleID(playerid), a);
		SetVehicleZAngle(GetPlayerVehicleID(playerid), a);
	}
	return 1;
}

//------------------------------------------------------------------------------

YCMD:reparar(playerid, params[], help)
{
	if(!IsPlayerInAnyVehicle(playerid))
		SendClientMessage(playerid, COLOR_ERROR, "* Você não está em um veículo.");
	else
	{
		PlayBuySound(playerid);
		RepairVehicle(GetPlayerVehicleID(playerid));
	}
	return 1;
}

//------------------------------------------------------------------------------

YCMD:clima(playerid, params[], help)
{
   new weatherid;
   if(sscanf(params, "i", weatherid))
	   return SendClientMessage(playerid, COLOR_INFO, "* /clima [id]");

   SetPlayerWeather(playerid, weatherid);
   SendClientMessagef(playerid, COLOR_PLAYER_COMMAND, "* Você alterou o ID de seu clima para %i.", weatherid);
   return 1;
}

//------------------------------------------------------------------------------

YCMD:ir(playerid, params[], help)
{
   new targetid;
   if(sscanf(params, "u", targetid))
	   return SendClientMessage(playerid, COLOR_INFO, "* /ir [playerid]");

   else if(!IsPlayerLogged(targetid))
	   return SendClientMessage(playerid, COLOR_ERROR, "* O jogador não está conectado.");

   else if(targetid == playerid)
	   return SendClientMessage(playerid, COLOR_ERROR, "* Você não pode ir até você mesmo.");

   else if(gplGotoBlocked[targetid])
	   return SendClientMessage(playerid, COLOR_ERROR, "* Este jogador bloqueou os teleportes até ele.");

   new Float:x, Float:y, Float:z;
   GetPlayerPos(targetid, x, y, z);

   SetPlayerInterior(playerid, GetPlayerInterior(targetid));
   SetPlayerVirtualWorld(playerid, GetPlayerVirtualWorld(targetid));
   if(GetPlayerState(playerid) != PLAYER_STATE_DRIVER) { SetPlayerPos(playerid, x, y, z); }
   else
   {
	   new vehicleid = GetPlayerVehicleID(playerid);
	   SetVehiclePos(vehicleid, x, y, z);
	   LinkVehicleToInterior(vehicleid, GetPlayerInterior(targetid));
	   SetVehicleVirtualWorld(vehicleid, GetPlayerVirtualWorld(targetid));
   }

   SendClientMessagef(targetid, COLOR_PLAYER_COMMAND, "* %s veio até você.", GetPlayerNamef(playerid));
   SendClientMessagef(playerid, COLOR_PLAYER_COMMAND, "* Você foi até %s.", GetPlayerNamef(targetid));
   return 1;
}

//------------------------------------------------------------------------------

YCMD:car(playerid, params[], help)
{
	if(GetPlayerGamemode(playerid) == GAMEMODE_RACE)
		return SendClientMessage(playerid, COLOR_ERROR, "* Você não pode criar veículos neste modo de jogo.");
	
	new vehicleName[32], color1, color2, idx, iString[128];
	if(sscanf(params, "s[32]I(-1)I(-1)", vehicleName, color1, color2))
		return SendClientMessage(playerid, COLOR_INFO, "* /car [nome] [cor] [cor]");

  	idx = GetVehicleModelIDFromName(vehicleName);

  	if(idx == -1)
  	{
  		idx = strval(iString);

  		if(idx < 400 || idx > 611)
  			return SendClientMessage(playerid, COLOR_ERROR, "* Veículo inválido.");
  	}

	new Float:x, Float:y, Float:z, Float:a;
	if(IsPlayerInAnyVehicle(playerid))
	{
		GetVehiclePos(GetPlayerVehicleID(playerid), x, y, z);
		GetVehicleZAngle(GetPlayerVehicleID(playerid), a);
	}
	else
	{
		GetPlayerPos(playerid, x, y, z);
		GetPlayerFacingAngle(playerid, a);
	}

	new bool:vehicle_created = false;
	for(new i = 0; i < MAX_CREATED_VEHICLE_PER_PLAYER; i++)
	{
		if(IsPlayerInVehicle(playerid, gplCreatedVehicle[playerid][i]))
		{
			vehicle_created = true;
			DestroyVehicle(gplCreatedVehicle[playerid][i]);
			gplCreatedVehicle[playerid][i] = CreateVehicle(idx, x, y, z, a, color1, color2, -1);
			SetVehicleVirtualWorld(gplCreatedVehicle[playerid][i], GetPlayerVirtualWorld(playerid));
			LinkVehicleToInterior(gplCreatedVehicle[playerid][i], GetPlayerInterior(playerid));
			PutPlayerInVehicle(playerid, gplCreatedVehicle[playerid][i], 0);
			SendClientMessagef(playerid, COLOR_PLAYER_COMMAND, "* Você criou um %s.", GetVehicleName(gplCreatedVehicle[playerid][i]));
			break;
		}
	}

	if(!vehicle_created)
	{
		for(new i = 0; i < MAX_CREATED_VEHICLE_PER_PLAYER; i++)
		{
			if(!gplCreatedVehicle[playerid][i])
			{
				vehicle_created = true;
				gplCreatedVehicle[playerid][i] = CreateVehicle(idx, x, y, z, a, color1, color2, -1);
				SetVehicleVirtualWorld(gplCreatedVehicle[playerid][i], GetPlayerVirtualWorld(playerid));
				LinkVehicleToInterior(gplCreatedVehicle[playerid][i], GetPlayerInterior(playerid));
				PutPlayerInVehicle(playerid, gplCreatedVehicle[playerid][i], 0);
				SendClientMessagef(playerid, COLOR_PLAYER_COMMAND, "* Você criou um %s.", GetVehicleName(gplCreatedVehicle[playerid][i]));
				break;
			}
		}
	}

	if(!vehicle_created)
	{
		vehicle_created = true;
		new vehicleid = random(MAX_CREATED_VEHICLE_PER_PLAYER);
		DestroyVehicle(gplCreatedVehicle[playerid][vehicleid]);
		gplCreatedVehicle[playerid][vehicleid] = CreateVehicle(idx, x, y, z, a, color1, color2, -1);
		SetVehicleVirtualWorld(gplCreatedVehicle[playerid][vehicleid], GetPlayerVirtualWorld(playerid));
		LinkVehicleToInterior(gplCreatedVehicle[playerid][vehicleid], GetPlayerInterior(playerid));
		PutPlayerInVehicle(playerid, gplCreatedVehicle[playerid][vehicleid], 0);
		SendClientMessagef(playerid, COLOR_PLAYER_COMMAND, "* Você criou um %s.", GetVehicleName(gplCreatedVehicle[playerid][vehicleid]));
		SendClientMessage(playerid, COLOR_WARNING, "* Você atingiu o limite de veículos por jogador, um de seus antigos veículos foi destruído.");
	}

	return 1;
}

//------------------------------------------------------------------------------

YCMD:pm(playerid, params[], help)
{
   new targetid, message[128];
   if(sscanf(params, "us[128]", targetid, message))
	   return SendClientMessage(playerid, COLOR_INFO, "* /pm [playerid] [mensagem]");

   else if(!IsPlayerLogged(targetid))
	   return SendClientMessage(playerid, COLOR_ERROR, "* O jogador não está conectado.");

   else if(playerid == targetid)
	   return SendClientMessage(playerid, COLOR_ERROR, "* Você não pode mandar mensagem privada para você mesmo.");

   new output[144];
   format(output, sizeof(output), "* [PM] %s(ID: %d): %s", GetPlayerNamef(playerid), playerid, message);
   SendClientMessage(targetid, COLOR_MUSTARD, output);
   format(output, sizeof(output), "* [PM] para %s(ID: %d): %s", GetPlayerNamef(targetid), targetid, message);
   SendClientMessage(playerid, COLOR_MUSTARD, output);
   return 1;
}

//------------------------------------------------------------------------------

hook OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	switch(dialogid)
	{
		case DIALOG_VEHICLE_LIST:
		{
			if(!response)
			{
				PlayCancelSound(playerid);
			}
			else
			{
				PlayBuySound(playerid);

				new command[32];
				format(command, sizeof(command), "/car %s", aVehicleNames[listitem]);
				CallRemoteFunction("OnPlayerCommandText", "is", playerid, command);
			}
			return -2;
		}
		case DIALOG_FIGHTING_LIST:
		{
			if(!response)
			{
				PlayCancelSound(playerid);
			}
			else
			{
				PlayConfirmSound(playerid);
				switch (listitem)
				{
					case 0:
						SetPlayerFightingStyle(playerid, FIGHT_STYLE_NORMAL);
					case 1:
						SetPlayerFightingStyle(playerid, FIGHT_STYLE_BOXING);
					case 2:
						SetPlayerFightingStyle(playerid, FIGHT_STYLE_KUNGFU);
					case 3:
						SetPlayerFightingStyle(playerid, FIGHT_STYLE_KNEEHEAD);
					case 4:
						SetPlayerFightingStyle(playerid, FIGHT_STYLE_GRABKICK);
					case 5:
						SetPlayerFightingStyle(playerid, FIGHT_STYLE_ELBOW);
				}
			}
			return -2;
		}
	}
	return 1;
}

//------------------------------------------------------------------------------

/*
		Error & Return type

	COMMAND_ZERO_RET	  = 0 , // The command returned 0.
	COMMAND_OK			= 1 , // Called corectly.
	COMMAND_UNDEFINED	 = 2 , // Command doesn't exist.
	COMMAND_DENIED		= 3 , // Can't use the command.
	COMMAND_HIDDEN		= 4 , // Can't use the command don't let them know it exists.
	COMMAND_NO_PLAYER	 = 6 , // Used by a player who shouldn't exist.
	COMMAND_DISABLED	  = 7 , // All commands are disabled for this player.
	COMMAND_BAD_PREFIX	= 8 , // Used "/" instead of "#", or something similar.
	COMMAND_INVALID_INPUT = 10, // Didn't type "/something".
*/

public e_COMMAND_ERRORS:OnPlayerCommandReceived(playerid, cmdtext[], e_COMMAND_ERRORS:success)
{
	if(!IsPlayerLogged(playerid))
	{
		SendClientMessage(playerid, COLOR_ERROR, "* Você precisa estar logado para usar algum comando.");
		return COMMAND_DENIED;
	}
	else if(success != COMMAND_OK)
		SendClientMessage(playerid, COLOR_ERROR, "* Este comando não existe. Veja /comandos.");
	return COMMAND_OK;
}

//------------------------------------------------------------------------------

ptask OnPlayerAutoRepair[1250](playerid)
{
	if(gplAutoRepair[playerid] && IsPlayerInAnyVehicle(playerid) && GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
	{
		RepairVehicle(GetPlayerVehicleID(playerid));
	}
}

public OnVehicleDamageStatusUpdate(vehicleid, playerid)
{
	if(gplAutoRepair[playerid] && IsPlayerInVehicle(playerid, vehicleid) && GetPlayerState(playerid) == PLAYER_STATE_DRIVER && !gplDriftActive[playerid])
	{
		RepairVehicle(GetPlayerVehicleID(playerid));
	}
	return 1;
}

timer CountDown[1000]()
{
	if(gCountDown == 0)
	{
		GameTextForAll("~g~GO!", 1000, 3);
		foreach(new i: Player)
			PlayerPlaySound(i, 1057, 0.0, 0.0, 0.0);
	}
	else
	{
		new string[8];
		format(string, sizeof(string), "~r~%i", gCountDown);
		GameTextForAll(string, 1000, 3);
		foreach(new i: Player)
			PlayerPlaySound(i, 1056, 0.0, 0.0, 0.0);

		gCountDown--;
		defer CountDown();
	}
}

//------------------------------------------------------------------------------

hook OnPlayerDisconnect(playerid, reason)
{
	for(new i = 0; i < MAX_CREATED_VEHICLE_PER_PLAYER; i++)
	{
		if(gplCreatedVehicle[playerid][i])
		{
			DestroyVehicle(gplCreatedVehicle[playerid][i]);
			gplCreatedVehicle[playerid][i] = 0;
		}
	}
	gplAutoRepair[playerid]		= false;
	gplHideNameTags[playerid]	= false;
	gplGotoBlocked[playerid]	= false;
	gplDriftActive[playerid]	= true;
	gplDriftCounter[playerid]	= 0;
	return 1;
}

//------------------------------------------------------------------------------

hook OnPlayerStreamIn(playerid, forplayerid)
{
	if(gplHideNameTags[forplayerid])
	{
		ShowPlayerNameTagForPlayer(forplayerid, playerid, false);
	}
	return 1;
}

//------------------------------------------------------------------------------

hook OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if(IsPlayerInAnyVehicle(playerid) && GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
	{
		if(newkeys & KEY_FIRE)
	    {
			AddVehicleComponent(GetPlayerVehicleID(playerid), 1010);
	    }
	}
    return 1;
}

//------------------------------------------------------------------------------

TogglePlayerAutoRepair(playerid, toggle)
{
	gplAutoRepair[playerid] = toggle;
}

GetPlayerAutoRepairState(playerid)
{
	return gplAutoRepair[playerid];
}

TogglePlayerNameTags(playerid, toggle)
{
	gplHideNameTags[playerid] = toggle;
}

GetPlayerNameTagsState(playerid)
{
	return gplHideNameTags[playerid];
}

TogglePlayerGoto(playerid, toggle)
{
	gplGotoBlocked[playerid] = toggle;
}

GetPlayerGotoState(playerid)
{
	return gplGotoBlocked[playerid];
}

TogglePlayerDrift(playerid, toggle)
{
	gplDriftActive[playerid] = toggle;
}

GetPlayerDriftState(playerid)
{
	return gplDriftActive[playerid];
}

TogglePlayerDriftCounter(playerid, toggle)
{
	gplDriftCounter[playerid] = toggle;
}

GetPlayerDriftCounter(playerid)
{
	return gplDriftCounter[playerid];
}
