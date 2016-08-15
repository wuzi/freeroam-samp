/*******************************************************************************
* NOME DO ARQUIVO :        modules/gameplay/building.pwn
*
* DESCRIÇÃO :
*       Responsável por permitir entradas e saídas dos interiores do jogo.
*
* NOTAS :
*       -
*/

#include <YSI\y_hooks>

//------------------------------------------------------------------------------

forward OnBuildingLoad();
forward OnInsertBuilding(buildingid);
forward OnPlayerEnterBuilding(playerid, building);
forward OnPlayerExitBuilding(playerid, building);

//------------------------------------------------------------------------------

#define INTERVAL_BETWEEN_PICKUP_UPDATES 3000
#define INVALID_BUILDING_ID             -1

//------------------------------------------------------------------------------

// enumaration of building's data
enum e_building_data
{
    // db
    e_building_db,

    // outside position
    Float:e_building_out_x,
    Float:e_building_out_y,
    Float:e_building_out_z,
    Float:e_building_out_a,
    e_building_out_i,
    e_building_out_v,

    // inside positions
    Float:e_building_in_x,
    Float:e_building_in_y,
    Float:e_building_in_z,
    Float:e_building_in_a,
    e_building_in_i,
    e_building_in_v,

    // states
    e_building_locked,

    // ids
    e_building_out_pkp_id,
    e_building_in_pkp_id
}
static gBuildingData[MAX_BUILDINGS][e_building_data];
static gCreatedBuildings;
static gPLEtickcount[MAX_PLAYERS];

//------------------------------------------------------------------------------

public OnBuildingLoad()
{
    for(new i, j = cache_get_row_count(gMySQL); i < j; i++)
	{
		gBuildingData[i][e_building_db]       = cache_get_row_int(i, 0, gMySQL);

        gBuildingData[i][e_building_out_x]    = cache_get_row_float(i, 1, gMySQL);
		gBuildingData[i][e_building_out_y]    = cache_get_row_float(i, 2, gMySQL);
		gBuildingData[i][e_building_out_z]    = cache_get_row_float(i, 3, gMySQL);
		gBuildingData[i][e_building_out_a]    = cache_get_row_float(i, 4, gMySQL);
		gBuildingData[i][e_building_out_i]    = cache_get_row_int(i, 5, gMySQL);
		gBuildingData[i][e_building_out_v]    = cache_get_row_int(i, 6, gMySQL);

		gBuildingData[i][e_building_in_x]     = cache_get_row_float(i, 7, gMySQL);
		gBuildingData[i][e_building_in_y]     = cache_get_row_float(i, 8, gMySQL);
		gBuildingData[i][e_building_in_z]     = cache_get_row_float(i, 9, gMySQL);
		gBuildingData[i][e_building_in_a]     = cache_get_row_float(i, 10, gMySQL);
		gBuildingData[i][e_building_in_i]     = cache_get_row_int(i, 11, gMySQL);
		gBuildingData[i][e_building_in_v]     = cache_get_row_int(i, 12, gMySQL);

        gBuildingData[i][e_building_locked]   = cache_get_row_int(i, 13, gMySQL);

        gBuildingData[i][e_building_out_pkp_id] = CreateDynamicPickup(19902, 1, gBuildingData[i][e_building_out_x], gBuildingData[i][e_building_out_y], gBuildingData[i][e_building_out_z] - 0.7, gBuildingData[i][e_building_out_v], gBuildingData[i][e_building_out_i]);
        gBuildingData[i][e_building_in_pkp_id] = CreateDynamicPickup(19902, 1, gBuildingData[i][e_building_in_x], gBuildingData[i][e_building_in_y], gBuildingData[i][e_building_in_z] - 0.7, gBuildingData[i][e_building_in_v], gBuildingData[i][e_building_in_i]);
        gCreatedBuildings++;
	}
    printf("Number of buildings loaded: %d", gCreatedBuildings);
}

//------------------------------------------------------------------------------

hook OnPlayerPickUpDynPickup(playerid, pickupid)
{
    if(gPLEtickcount[playerid] > GetTickCount())
        return 1;

    for (new i = 0; i < MAX_BUILDINGS; i++)
    {
        if(!gBuildingData[i][e_building_db])
            continue;

        if(pickupid == gBuildingData[i][e_building_out_pkp_id])
        {
            if(OnPlayerEnterBuilding(playerid, i) != 0)
            {
                SetPlayerInterior(playerid, gBuildingData[i][e_building_in_i]);
                SetPlayerVirtualWorld(playerid, gBuildingData[i][e_building_in_v]);
                SetPlayerPos(playerid, gBuildingData[i][e_building_in_x], gBuildingData[i][e_building_in_y], gBuildingData[i][e_building_in_z]);
                SetPlayerFacingAngle(playerid, gBuildingData[i][e_building_in_a]);
                SetCameraBehindPlayer(playerid);
                gPLEtickcount[playerid] = GetTickCount() + INTERVAL_BETWEEN_PICKUP_UPDATES;
            }
        }
        else if(pickupid == gBuildingData[i][e_building_in_pkp_id])
        {
            if(OnPlayerExitBuilding(playerid, i) != 0)
            {
                SetPlayerInterior(playerid, gBuildingData[i][e_building_out_i]);
                SetPlayerVirtualWorld(playerid, gBuildingData[i][e_building_out_v]);
                SetPlayerPos(playerid, gBuildingData[i][e_building_out_x], gBuildingData[i][e_building_out_y], gBuildingData[i][e_building_out_z]);
                SetPlayerFacingAngle(playerid, gBuildingData[i][e_building_out_a]);
                SetCameraBehindPlayer(playerid);
                gPLEtickcount[playerid] = GetTickCount() + INTERVAL_BETWEEN_PICKUP_UPDATES;
            }
        }
    }
    return 1;
}

//------------------------------------------------------------------------------

IsPlayerNearAnyBuilding(playerid)
{
    for(new i = 0; i < MAX_BUILDINGS; i++)
	{
        if(gBuildingData[i][e_building_db] == 0)
            continue;

	    if((IsPlayerInRangeOfPoint(playerid, 10.0, gBuildingData[i][e_building_out_x], gBuildingData[i][e_building_out_y], gBuildingData[i][e_building_out_z]) && GetPlayerVirtualWorld(playerid) == gBuildingData[i][e_building_out_v]) || (IsPlayerInRangeOfPoint(playerid, 25.0, gBuildingData[i][e_building_in_x], gBuildingData[i][e_building_in_y], gBuildingData[i][e_building_in_z])  && GetPlayerVirtualWorld(playerid) == gBuildingData[i][e_building_in_v]))
            return i;
	}
    return INVALID_BUILDING_ID;
}

//------------------------------------------------------------------------------

public OnPlayerEnterBuilding(playerid, building)
{
    if(gBuildingData[building][e_building_locked])
    {
        SendClientMessage(playerid, COLOR_ERROR, "* Porta trancada.");
        return 0;
    }
    return 1;
}

//------------------------------------------------------------------------------

public OnPlayerExitBuilding(playerid, building)
{
    return 1;
}

//------------------------------------------------------------------------------

hook OnGameModeInit()
{
    mysql_pquery(gMySQL, "SELECT * FROM `buildings`", "OnBuildingLoad");
    return 1;
}

//------------------------------------------------------------------------------

public OnInsertBuilding(buildingid)
{
    new index = cache_insert_id();
    gBuildingData[buildingid][e_building_db]       = index;
    gCreatedBuildings++;

    printf("[mysql] inserted building %d on database.", index);
}

//------------------------------------------------------------------------------

YCMD:abuildingcmds(playerid, params[], help)
{
    if(!IsPlayerAdmin(playerid))
 		return SendClientMessage(playerid, COLOR_ERROR, "* Você precisa estar logado na RCON para isso.");

	SendClientMessage(playerid, COLOR_TITLE, "---------------------------------------- Comandos Buildings - Banco de Dados ----------------------------------------");

    SendClientMessage(playerid, COLOR_SUB_TITLE, "* /buildingid - /insertbuilding - /updatebuilding - /deletebuilding");

	SendClientMessage(playerid, COLOR_TITLE, "---------------------------------------- Comandos Buildings - Banco de Dados ----------------------------------------");
	return 1;
}

//------------------------------------------------------------------------------

YCMD:buildingid(playerid, params[], help)
{
	new building_id = IsPlayerNearAnyBuilding(playerid);
    if(building_id == INVALID_BUILDING_ID)
        SendClientMessage(playerid, COLOR_ERROR, "* Você não está próximo de um building.");
    else
        SendClientMessagef(playerid, COLOR_ADMIN_ACTION, "* Building ID: %d.", building_id);
	return 1;
}

//------------------------------------------------------------------------------

YCMD:insertbuilding(playerid, params[], help)
{
    if(!IsPlayerAdmin(playerid))
        return SendClientMessage(playerid, COLOR_ERROR, "* Você precisa estar logado na RCON para isto.");

    new bid = INVALID_BUILDING_ID;
    for(new i = 0; i < MAX_BUILDINGS; i++)
	{
        if(gBuildingData[i][e_building_db] != 0)
            continue;
        bid = i;
        break;
    }

    if(bid == INVALID_BUILDING_ID)
        return SendClientMessage(playerid, COLOR_ERROR, "* O limite de buildings foi atingido.");

    new Float:x, Float:y, Float:z, Float:a;
    new i = GetPlayerInterior(playerid);
    new v = GetPlayerVirtualWorld(playerid);
    GetPlayerPos(playerid, x, y, z);
    GetPlayerFacingAngle(playerid, a);

    gBuildingData[bid][e_building_out_x]    = x;
    gBuildingData[bid][e_building_out_y]    = y;
    gBuildingData[bid][e_building_out_z]    = z;
    gBuildingData[bid][e_building_out_a]    = a;
    gBuildingData[bid][e_building_out_i]    = i;
    gBuildingData[bid][e_building_out_v]    = v;
    gBuildingData[bid][e_building_out_pkp_id] = CreateDynamicPickup(19902, 1, gBuildingData[bid][e_building_out_x], gBuildingData[bid][e_building_out_y], gBuildingData[bid][e_building_out_z] - 0.7, gBuildingData[bid][e_building_out_v], gBuildingData[bid][e_building_out_i]);
    gBuildingData[bid][e_building_in_pkp_id] = CreateDynamicPickup(19902, 1, 0.0, 0.0, 0.0, 50, 50);

    SendClientMessagef(playerid, COLOR_ADMIN_ACTION, "* Você inseriu um building no banco de dados, bid: %d.", bid);

    new query[220];
    mysql_format(gMySQL, query, sizeof(query), "INSERT INTO `buildings` (`building_out_x`, `building_out_y`, `building_out_z`, `building_out_a`, `building_out_i`, `building_out_v`, `building_locked`) VALUES (%f, %f, %f, %f, %i, %i, %i)", x, y, z, a, i, v, 1);
    mysql_pquery(gMySQL, query, "OnInsertBuilding", "i", bid);
    return 1;
}

//------------------------------------------------------------------------------

YCMD:updatebuilding(playerid, params[], help)
{
    if(!IsPlayerAdmin(playerid))
        return SendClientMessage(playerid, COLOR_ERROR, "* Você precisa estar logado na RCON para isto.");

    new bid, option[8];
	if(sscanf(params, "is[8]", bid, option))
		SendClientMessage(playerid, COLOR_INFO, "* /updatebuilding [id] [entrada - saida - porta]");
    else if(bid < 0 || bid > MAX_BUILDINGS-1)
        SendClientMessagef(playerid, COLOR_ERROR, "* Building inválido, valores de 0 à %i.", MAX_BUILDINGS);
    else if(gBuildingData[bid][e_building_db] == 0)
        SendClientMessage(playerid, COLOR_ERROR, "* Este building não existe.");
    else if(!strcmp(option, "entrada"))
    {
        new Float:x, Float:y, Float:z, Float:a;
        new i = GetPlayerInterior(playerid);
        new v = GetPlayerVirtualWorld(playerid);
        GetPlayerPos(playerid, x, y, z);
        GetPlayerFacingAngle(playerid, a);

        gBuildingData[bid][e_building_out_x]    = x;
        gBuildingData[bid][e_building_out_y]    = y;
        gBuildingData[bid][e_building_out_z]    = z;
        gBuildingData[bid][e_building_out_a]    = a;
        gBuildingData[bid][e_building_out_i]    = i;
        gBuildingData[bid][e_building_out_v]    = v;

        DestroyDynamicPickup(gBuildingData[bid][e_building_out_pkp_id]);
        gBuildingData[bid][e_building_out_pkp_id] = CreateDynamicPickup(19902, 1, gBuildingData[bid][e_building_out_x], gBuildingData[bid][e_building_out_y], gBuildingData[bid][e_building_out_z] - 0.7, gBuildingData[bid][e_building_out_v], gBuildingData[bid][e_building_out_i]);

        SendClientMessagef(playerid, COLOR_ADMIN_ACTION, "* Você alterou a entrada do building %d.", bid);

        new query[210];
        mysql_format(gMySQL, query, sizeof(query), "UPDATE `buildings` SET `building_out_x`=%f, `building_out_y`=%f, `building_out_z`=%f, `building_out_a`=%f, `building_out_i`=%i, `building_out_v`=%i WHERE `ID`=%d", x, y, z, a, i, v, gBuildingData[bid][e_building_db]);
        mysql_pquery(gMySQL, query);
    }
    else if(!strcmp(option, "saida"))
    {
        new Float:x, Float:y, Float:z, Float:a;
        new i = GetPlayerInterior(playerid);
        new v = GetPlayerVirtualWorld(playerid);
        GetPlayerPos(playerid, x, y, z);
        GetPlayerFacingAngle(playerid, a);

        gBuildingData[bid][e_building_in_x]    = x;
        gBuildingData[bid][e_building_in_y]    = y;
        gBuildingData[bid][e_building_in_z]    = z;
        gBuildingData[bid][e_building_in_a]    = a;
        gBuildingData[bid][e_building_in_i]    = i;
        gBuildingData[bid][e_building_in_v]    = v;

        DestroyDynamicPickup(gBuildingData[bid][e_building_in_pkp_id]);
        gBuildingData[bid][e_building_in_pkp_id] = CreateDynamicPickup(19902, 1, gBuildingData[bid][e_building_in_x], gBuildingData[bid][e_building_in_y], gBuildingData[bid][e_building_in_z] - 0.7, gBuildingData[bid][e_building_in_v], gBuildingData[bid][e_building_in_i]);

        SendClientMessagef(playerid, COLOR_ADMIN_ACTION, "* Você alterou a saída do building %d.", bid);

        new query[210];
        mysql_format(gMySQL, query, sizeof(query), "UPDATE `buildings` SET `building_in_x`=%f, `building_in_y`=%f, `building_in_z`=%f, `building_in_a`=%f, `building_in_i`=%i, `building_in_v`=%i WHERE `ID`=%d", x, y, z, a, i, v, gBuildingData[bid][e_building_db]);
        mysql_pquery(gMySQL, query);
    }
    else if(!strcmp(option, "porta"))
    {
        if(gBuildingData[bid][e_building_locked])
        {
            gBuildingData[bid][e_building_locked] = 0;
            SendClientMessagef(playerid, COLOR_ADMIN_ACTION, "* Você destrancou o building %d.", bid);
        }
        else
        {
            gBuildingData[bid][e_building_locked] = 1;
            SendClientMessagef(playerid, COLOR_ADMIN_ACTION, "* Você trancou o building %d.", bid);
        }
        new query[60];
        mysql_format(gMySQL, query, sizeof(query), "UPDATE `buildings` SET `building_locked`=%i WHERE `ID`=%d", gBuildingData[bid][e_building_locked], gBuildingData[bid][e_building_db]);
        mysql_pquery(gMySQL, query);
    }
    else SendClientMessage(playerid, COLOR_ERROR, "* Opção inválida.");
    return 1;
}

//------------------------------------------------------------------------------

YCMD:deletebuilding(playerid, params[], help)
{
    if(!IsPlayerAdmin(playerid))
        return SendClientMessage(playerid, COLOR_ERROR, "* Você precisa estar logado na RCON para isto.");

    new bid;
	if(sscanf(params, "i", bid))
		SendClientMessage(playerid, COLOR_INFO, "* /deletebuilding [id]");
    else if(bid < 0 || bid > MAX_BUILDINGS-1)
        SendClientMessagef(playerid, COLOR_ERROR, "* Building inválido, valores de 0 à %i.", MAX_BUILDINGS);
    else if(gBuildingData[bid][e_building_db] == 0)
        SendClientMessage(playerid, COLOR_ERROR, "* Este building não existe.");
    else
    {
        SendClientMessagef(playerid, COLOR_ADMIN_ACTION, "* Você deletou o building %d.", bid);

        new query[60];
        mysql_format(gMySQL, query, sizeof(query), "DELETE FROM `buildings` WHERE `ID`=%d", gBuildingData[bid][e_building_db]);
        mysql_pquery(gMySQL, query);

        gBuildingData[bid][e_building_db] = 0;
        DestroyDynamicPickup(gBuildingData[bid][e_building_out_pkp_id]);
        DestroyDynamicPickup(gBuildingData[bid][e_building_in_pkp_id]);
    }
    return 1;
}
