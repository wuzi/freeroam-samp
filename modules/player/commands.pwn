/*******************************************************************************
* NOME DO ARQUIVO :        modules/player/commands.pwn
*
* DESCRIÇÃO :
*       Comandos quem podem ser usados por qualquer jogador.
*
* NOTAS :
*       -
*/

#include <YSI\y_hooks>

//------------------------------------------------------------------------------

static gplCreatedVehicle[MAX_PLAYERS][MAX_CREATED_VEHICLE_PER_PLAYER];

//------------------------------------------------------------------------------

hook OnGameModeInit()
{
	Command_AddAltNamed("ir",    		"goto");
	Command_AddAltNamed("pm",    		"mp");
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
	new vehicleName[32], color1 = random(255), color2 = random(255), idx, iString[128];
	if(sscanf(params, "s[32]II", vehicleName, color1, color2))
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

/*
        Error & Return type

    COMMAND_ZERO_RET      = 0 , // The command returned 0.
    COMMAND_OK            = 1 , // Called corectly.
    COMMAND_UNDEFINED     = 2 , // Command doesn't exist.
    COMMAND_DENIED        = 3 , // Can't use the command.
    COMMAND_HIDDEN        = 4 , // Can't use the command don't let them know it exists.
    COMMAND_NO_PLAYER     = 6 , // Used by a player who shouldn't exist.
    COMMAND_DISABLED      = 7 , // All commands are disabled for this player.
    COMMAND_BAD_PREFIX    = 8 , // Used "/" instead of "#", or something similar.
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
		SendClientMessage(playerid, COLOR_ERROR, "* Este comando não existe.");
    return COMMAND_OK;
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
    return 1;
}
