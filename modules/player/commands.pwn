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

hook OnGameModeInit()
{
	Command_AddAltNamed("ir",    		"goto");
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
