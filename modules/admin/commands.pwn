/*******************************************************************************
* NOME DO ARQUIVO :        modules/admin/commands.pwn
*
* DESCRIÇÃO :
*       Comandos apenas usados por administradores.
*
* NOTAS :
*       -
*/

//------------------------------------------------------------------------------

// Recomendável manter a lista em até 10 linhas, para melhor visualização
YCMD:acmds(playerid, params[], help)
{
    if(GetPlayerAdminLevel(playerid) < PLAYER_RANK_RECRUIT)
 		return SendClientMessage(playerid, COLOR_ERROR, "* Você não tem permissão.");

	SendClientMessage(playerid, COLOR_TITLE, "---------------------------------------- Comandos Administrativos ----------------------------------------");
	if(GetPlayerAdminLevel(playerid) >= PLAYER_RANK_RECRUIT)
    {
        SendClientMessage(playerid, COLOR_SUB_TITLE, "* /puxar - /setskin - /irpos - /setint - /setvw - /jetpack");
        SendClientMessage(playerid, COLOR_SUB_TITLE, "* /pdist - /say");
    }

	if(GetPlayerAdminLevel(playerid) >= PLAYER_RANK_HELPER)
        SendClientMessage(playerid, COLOR_SUB_TITLE, "* /kick - /ban - /sethp - /setarmour - /aviso");

	if(GetPlayerAdminLevel(playerid) >= PLAYER_RANK_MODERATOR)
        SendClientMessage(playerid, COLOR_SUB_TITLE, "* /rtc - /ircar - /puxarcar - /dararma - /verip - /mutar - /desmutar - /congelar - /descongelar");

	if(GetPlayerAdminLevel(playerid) >= PLAYER_RANK_SUB_OWNER)
        SendClientMessage(playerid, COLOR_SUB_TITLE, "* /gmx - /criarcorrida - /criarevento - /setmoney - /setbanco - /setvip - /gerarchavevip");

	if(GetPlayerAdminLevel(playerid) >= PLAYER_RANK_OWNER || IsPlayerAdmin(playerid))
        SendClientMessage(playerid, COLOR_SUB_TITLE, "* /setadmin");

	SendClientMessage(playerid, COLOR_SUB_TITLE, "* Para falar no chat administrativo use @ antes da mensagem.");
	SendClientMessage(playerid, COLOR_TITLE, "---------------------------------------- Comandos Administrativos ----------------------------------------");
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

 YCMD:setint(playerid, params[], help)
 {
 	if(GetPlayerAdminLevel(playerid) < PLAYER_RANK_RECRUIT)
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
 	if(GetPlayerAdminLevel(playerid) < PLAYER_RANK_RECRUIT)
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

 YCMD:setskin(playerid, params[], help)
 {
 	if(GetPlayerAdminLevel(playerid) < PLAYER_RANK_RECRUIT)
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

 YCMD:puxar(playerid, params[], help)
 {
 	if(GetPlayerAdminLevel(playerid) < PLAYER_RANK_RECRUIT)
 		return SendClientMessage(playerid, COLOR_ERROR, "* Você não tem permissão.");

 	new targetid;
 	if(sscanf(params, "u", targetid))
 		return SendClientMessage(playerid, COLOR_INFO, "* /puxar [playerid]");

 	else if(!IsPlayerLogged(targetid))
 		return SendClientMessage(playerid, COLOR_ERROR, "* O jogador não está conectado.");

 	else if(targetid == playerid)
 		return SendClientMessage(playerid, COLOR_ERROR, "* Você não pode puxar você mesmo.");

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

YCMD:jetpack(playerid, params[], help)
{
   if(GetPlayerAdminLevel(playerid) < PLAYER_RANK_RECRUIT)
       return SendClientMessage(playerid, COLOR_ERROR, "* Você não tem permissão.");

   SetPlayerSpecialAction(playerid, SPECIAL_ACTION_USEJETPACK);
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

YCMD:kick(playerid, params[], help)
{
   if(GetPlayerAdminLevel(playerid) < PLAYER_RANK_HELPER)
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

 YCMD:sethp(playerid, params[], help)
 {
 	if(GetPlayerAdminLevel(playerid) < PLAYER_RANK_HELPER)
 		return SendClientMessage(playerid, COLOR_ERROR, "* Você não tem permissão.");

 	new targetid, Float:health;
 	if(sscanf(params, "uf", targetid, health))
 		return SendClientMessage(playerid, COLOR_INFO, "* /sethp [playerid] [valor]");

 	else if(!IsPlayerLogged(targetid))
 		return SendClientMessage(playerid, COLOR_ERROR, "* O jogador não está conectado.");

 	SetPlayerHealth(targetid, health);
    if(playerid != targetid)
        SendClientMessagef(targetid, COLOR_ADMIN_COMMAND, "* %s alterou sua HP para %.2f.", GetPlayerNamef(playerid), health);
    SendClientMessagef(playerid, COLOR_ADMIN_COMMAND, "* Você alterou a HP de %s para %.2f.", GetPlayerNamef(targetid), health);
 	return 1;
 }
//------------------------------------------------------------------------------

 YCMD:setarmour(playerid, params[], help)
 {
 	if(GetPlayerAdminLevel(playerid) < PLAYER_RANK_HELPER)
 		return SendClientMessage(playerid, COLOR_ERROR, "* Você não tem permissão.");

 	new targetid, Float:armour;
 	if(sscanf(params, "uf", targetid, armour))
 		return SendClientMessage(playerid, COLOR_INFO, "* /setarmour [playerid] [valor]");

 	else if(!IsPlayerLogged(targetid))
 		return SendClientMessage(playerid, COLOR_ERROR, "* O jogador não está conectado.");

 	SetPlayerArmour(targetid, armour);
    if(playerid != targetid)
        SendClientMessagef(targetid, COLOR_ADMIN_COMMAND, "* %s alterou seu colete para %.2f.", GetPlayerNamef(playerid), armour);
    SendClientMessagef(playerid, COLOR_ADMIN_COMMAND, "* Você alterou o colete de %s para %.2f.", GetPlayerNamef(targetid), armour);
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

YCMD:dararma(playerid, params[], help)
{
   if(GetPlayerAdminLevel(playerid) < PLAYER_RANK_MODERATOR)
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

 YCMD:mutar(playerid, params[], help)
 {
 	if(GetPlayerAdminLevel(playerid) < PLAYER_RANK_MODERATOR)
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

 YCMD:congelar(playerid, params[], help)
 {
 	if(GetPlayerAdminLevel(playerid) < PLAYER_RANK_MODERATOR)
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
 	if(GetPlayerAdminLevel(playerid) < PLAYER_RANK_MODERATOR)
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

 YCMD:verip(playerid, params[], help)
 {
 	if(GetPlayerAdminLevel(playerid) < PLAYER_RANK_MODERATOR)
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

 YCMD:gerarchavevip(playerid, params[], help)
 {
    if(GetPlayerAdminLevel(playerid) >= PLAYER_RANK_SUB_OWNER)
    {
        new days;
        if(sscanf(params, "i", days))
            return SendClientMessage(playerid, COLOR_INFO, "* /gerarchavevip [dias]");

        else if(days < 1)
            return SendClientMessage(playerid, COLOR_ERROR, "* Dias não podem ser menor que 1.");

        new key[30];
        key = GenerateVIPKey();
        SendClientMessagef(playerid, COLOR_TITLE, "Chave VIP Gerada!");
        SendClientMessagef(playerid, COLOR_SUB_TITLE, "Dias: %d", days);
        SendClientMessagef(playerid, COLOR_SUB_TITLE, "Chave: %s", key);

        new query[128];
        mysql_format(gMySQL, query, sizeof(query), "INSERT INTO `vip_keys` (`serial`, `days`, `used`) VALUES ('%e', %d, 0)", key, days);
        mysql_tquery(gMySQL, query);
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

timer RestartGameMode[5000]()
{
    SendRconCommand("gmx");
}
