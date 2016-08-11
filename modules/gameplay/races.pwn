/*******************************************************************************
* NOME DO ARQUIVO :		modules/gameplay/races.pwn
*
* DESCRIÇÃO :
*	   Permite que jogadores participem de corridas.
*
* NOTAS :
*	   -
*/

#include <YSI\y_hooks>

//------------------------------------------------------------------------------

forward OnRaceLoad();
forward OnRaceGridLoad(raceid);
forward OnRaceCheckpointLoad(raceid);
forward OnPlayerEnterRace(playerid, raceid);

//------------------------------------------------------------------------------

enum
{
    RACE_STATE_WAITING_PLAYERS,
    RACE_STATE_STARTING,
    RACE_STATE_STARTED
}

enum e_race_data
{
    e_race_id,
    e_race_name[MAX_RACE_NAME],
    e_race_leaderboard[MAX_RACE_PLAYERS],
    e_race_counter,
    e_race_state,
    e_race_interior,
    e_race_vmodel,
    e_race_cp_type,
    Float:e_race_cp_size
}
static gRaceData[MAX_RACES][e_race_data];

enum e_cp_data
{
    e_race_id,
    Float:e_checkpoint_x,
    Float:e_checkpoint_y,
    Float:e_checkpoint_z
}
static gCheckpointData[MAX_RACES][MAX_RACE_CHECKPOINTS][e_cp_data];

enum e_grid_data
{
    e_race_id,
    e_vehicle_id,
    Float:e_vehicle_x,
    Float:e_vehicle_y,
    Float:e_vehicle_z,
    Float:e_vehicle_a
}
static gVehicleData[MAX_RACES][MAX_RACE_PLAYERS][e_grid_data];
static gPrizeData[MAX_RACES][MAX_RACE_PLAYERS];

static Float:gLobbySpawns[][] =
{
    {   -974.8712,    1061.1549,  1345.6719,  88.9761     },
    {   -1041.3506,   1078.1920,  1347.8082,  251.8641    },
    {   -1065.9036,   1086.8920,  1346.4971,  124.6496    },
    {   -1063.5520,   1055.0902,  1347.4911,  87.0493     },
    {   -1089.4988,   1043.9332,  1347.3552,  81.9892     },
    {   -1101.5830,   1021.7955,  1342.0938,  358.9316    },
    {   -1128.0201,   1028.8192,  1345.7084,  276.8375    },
    {   -1131.4199,   1057.5118,  1346.4143,  272.4508    },
    {   -977.2980,    1089.4580,  1344.9617,  84.8873     },
    {   -1005.3085,   1078.5878,  1343.1176,  80.8140     }
};

static gPlayerCurrentRace[MAX_PLAYERS] = {INVALID_RACE_ID, ...};
static gRaceCountdown[MAX_RACES];

enum e_player_race_data
{
    e_grid_id,
    e_checkpoint_id,
    e_start_time,
    e_end_time,
    e_spec_targetid
}
static gPlayerData[MAX_PLAYERS][e_player_race_data];
static bool:gIsDialogShown[MAX_PLAYERS];

//------------------------------------------------------------------------------

public OnRaceLoad()
{
    new rows, fields;
	cache_get_data(rows, fields, gMySQL);
    for(new i = 0; i < rows; i++)
    {
        gRaceData[i][e_race_id]         = cache_get_field_content_int(i, "id", gMySQL);
        gRaceData[i][e_race_cp_type]    = cache_get_field_content_int(i, "cp_type", gMySQL);
        gRaceData[i][e_race_cp_size]    = cache_get_field_content_float(i, "cp_size", gMySQL);
        gRaceData[i][e_race_interior]   = cache_get_field_content_int(i, "interior", gMySQL);
        gRaceData[i][e_race_vmodel]     = cache_get_field_content_int(i, "vehicleid", gMySQL);
        cache_get_field_content(i, "name", gRaceData[i][e_race_name], gMySQL, MAX_RACE_NAME);

        new query[64];
        mysql_format(gMySQL, query, sizeof(query), "SELECT * FROM race_vehicles WHERE race_id = %d", gRaceData[i][e_race_id]);
        mysql_tquery(gMySQL, query, "OnRaceGridLoad", "i", i);
        mysql_format(gMySQL, query, sizeof(query), "SELECT * FROM race_checkpoints WHERE race_id = %d", gRaceData[i][e_race_id]);
        mysql_tquery(gMySQL, query, "OnRaceCheckpointLoad", "i", i);
    }
}

//------------------------------------------------------------------------------

public OnRaceGridLoad(raceid)
{
    new rows, fields;
	cache_get_data(rows, fields, gMySQL);
    for(new i = 0; i < rows; i++)
    {
        gVehicleData[raceid][i][e_race_id]      = cache_get_field_content_int(i, "race_id", gMySQL);
        gVehicleData[raceid][i][e_vehicle_x]    = cache_get_field_content_float(i, "x", gMySQL);
        gVehicleData[raceid][i][e_vehicle_y]    = cache_get_field_content_float(i, "y", gMySQL);
        gVehicleData[raceid][i][e_vehicle_z]    = cache_get_field_content_float(i, "z", gMySQL);
        gVehicleData[raceid][i][e_vehicle_a]    = cache_get_field_content_float(i, "a", gMySQL);
        gPrizeData[raceid][i]                   = cache_get_field_content_int(i, "prize", gMySQL);
    }
}

//------------------------------------------------------------------------------

public OnRaceCheckpointLoad(raceid)
{
    new rows, fields;
	cache_get_data(rows, fields, gMySQL);
    for(new i = 0; i < rows; i++)
    {
        gCheckpointData[raceid][i][e_race_id]       = cache_get_field_content_int(i, "race_id", gMySQL);
        gCheckpointData[raceid][i][e_checkpoint_x]  = cache_get_field_content_float(i, "x", gMySQL);
        gCheckpointData[raceid][i][e_checkpoint_y]  = cache_get_field_content_float(i, "y", gMySQL);
        gCheckpointData[raceid][i][e_checkpoint_z]  = cache_get_field_content_float(i, "z", gMySQL);
    }
}

//------------------------------------------------------------------------------

hook OnGameModeInit()
{
    mysql_tquery(gMySQL, "SELECT * FROM races", "OnRaceLoad");

    for(new raceid = 0; raceid < MAX_RACES; raceid++)
    {
        for(new i = 0; i < MAX_RACE_PLAYERS; i++)
        {
            gRaceData[raceid][e_race_leaderboard][i] = INVALID_PLAYER_ID;
        }
    }
    return 1;
}

//------------------------------------------------------------------------------


hook OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
    switch (dialogid)
    {
        case DIALOG_RACE:
        {
            if(!response)
            {
                PlayCancelSound(playerid);
            }
            else if(gRaceData[listitem][e_race_state] == RACE_STATE_STARTED)
            {
                PlayErrorSound(playerid);
                SendClientMessage(playerid, COLOR_ERROR, "* Essa corrida já foi iniciada.");
                ShowPlayerRaceList(playerid);
            }
            else if(GetRacePlayerPoolSize(listitem) == GetRaceMaxPlayers(listitem))
            {
                PlayErrorSound(playerid);
                SendClientMessage(playerid, COLOR_ERROR, "* Essa corrida está lotada.");
            }
            else
            {
                PlaySelectSound(playerid);
                ResetPlayerRaceData(playerid);
                OnPlayerEnterRace(playerid, listitem);
            }
            gIsDialogShown[playerid] = false;
        }
        case DIALOG_RACE_LEADERBOARD:
        {
            PlaySelectSound(playerid);
        }
    }
    return 1;
}

//------------------------------------------------------------------------------

public OnPlayerEnterRace(playerid, raceid)
{
    HidePlayerLobby(playerid);
    SetPlayerHealth(playerid, 9999.0);
    DisableRemoteVehicleCollisions(playerid, true);

    new rand = random(sizeof(gLobbySpawns));
    SetPlayerInterior(playerid, 10);
    SetPlayerPos(playerid, gLobbySpawns[rand][0], gLobbySpawns[rand][1], gLobbySpawns[rand][2]);
    SetPlayerFacingAngle(playerid, gLobbySpawns[rand][3]);
    SetPlayerVirtualWorld(playerid, (raceid + 2000));
    SetPlayerGamemode(playerid, GAMEMODE_RACE);
    SetPlayerRace(playerid, raceid);
    SendClientMessagef(playerid, COLOR_SUCCESS, "* Você entrou na corrida %s!", gRaceData[raceid][e_race_name]);

    if(gRaceData[raceid][e_race_state] == RACE_STATE_WAITING_PLAYERS)
    {
        GameTextForPlayer(playerid, "~y~Aguardando jogadores...", 1250, 3);
        SendClientMessage(playerid, COLOR_SUCCESS, "* Aguardando mais jogadores para iniciar...");

        new count = 0;
        foreach(new i: Player)
        {
            if(GetPlayerRace(i) == raceid)
            {
                count++;
            }
        }

        if(count >= MINIMUM_PLAYERS_TO_START_RACE)
        {
            foreach(new i: Player)
            {
                if(GetPlayerRace(i) == raceid)
                {
                    GameTextForPlayer(i, "~g~Iniciando corrida...", 1250, 3);
                    SendClientMessagef(i, COLOR_SUCCESS, "* A quantidade minima de jogadores foi alcançada, a corrida irá iniciar em %d segundos.", RACE_COUNT_DOWN);
                }
            }
            gRaceCountdown[raceid] = RACE_COUNT_DOWN;
            gRaceData[raceid][e_race_state] = RACE_STATE_STARTING;
        }
    }
    return 1;
}

//------------------------------------------------------------------------------

task OnRaceUpdate[1000]()
{
    for(new raceid = 0; raceid < MAX_RACES; raceid++)
    {
        if(!gRaceData[raceid][e_race_id])
            break;

        if(gRaceData[raceid][e_race_state] == RACE_STATE_WAITING_PLAYERS)
        {
            foreach(new i: Player)
            {
                if(GetPlayerRace(i) == raceid)
                {
                    if(gRaceData[raceid][e_race_state] == RACE_STATE_WAITING_PLAYERS)
                    {
                        GameTextForPlayer(i, "~y~Aguardando jogadores...", 1250, 3);
                    }
                }
            }
        }
        else if(gRaceData[raceid][e_race_state] == RACE_STATE_STARTING)
        {
            if(gRaceCountdown[raceid] > 0)
            {
                foreach(new i: Player)
                {
                    if(GetPlayerRace(i) == raceid)
                    {
                        new countstr[38];
                        format(countstr, sizeof(countstr), "~g~Iniciando corrida~n~%02d", gRaceCountdown[raceid]);
                        GameTextForPlayer(i, countstr, 1250, 3);
                        PlayerPlaySound(i, 1056, 0.0, 0.0, 0.0);
                    }
                }
                gRaceCountdown[raceid]--;
            }
            else
            {
                new racer_id = 0;
                gRaceData[raceid][e_race_state] = RACE_STATE_STARTED;
                gRaceCountdown[raceid] = 6;
                foreach(new i: Player)
                {
                    if(GetPlayerRace(i) == raceid)
                    {
                        PlayerPlaySound(i, 1056, 0.0, 0.0, 0.0);
                        GameTextForPlayer(i, "~g~~h~A corrida ira iniciar~n~prepare-se", 1250, 3);
                        gPlayerData[i][e_grid_id] = racer_id;
                        gPlayerData[i][e_checkpoint_id] = 0;
                        gVehicleData[raceid][racer_id][e_vehicle_id] = CreateVehicle(gRaceData[raceid][e_race_vmodel], gVehicleData[raceid][racer_id][e_vehicle_x], gVehicleData[raceid][racer_id][e_vehicle_y], gVehicleData[raceid][racer_id][e_vehicle_z], gVehicleData[raceid][racer_id][e_vehicle_a], -1, -1, -1);
                        LinkVehicleToInterior(gVehicleData[raceid][racer_id][e_vehicle_id], gRaceData[raceid][e_race_interior]);
                        SetVehicleVirtualWorld(gVehicleData[raceid][racer_id][e_vehicle_id], (raceid + 2000));
                        SetPlayerInterior(i, gRaceData[raceid][e_race_interior]);
                        PutPlayerInVehicle(i, gVehicleData[raceid][racer_id][e_vehicle_id], 0);
                        SetCameraBehindPlayer(i);
                        TogglePlayerControllable(i, false);
                        racer_id++;
                    }
                }
            }
        }
        else if(gRaceData[raceid][e_race_state] == RACE_STATE_STARTED)
        {
            if(gRaceCountdown[raceid] > 1)
            {
                gRaceCountdown[raceid]--;
                foreach(new i: Player)
                {
                    if(GetPlayerRace(i) == raceid)
                    {
                        new countstr[38];
                        format(countstr, sizeof(countstr), "~r~%02d", gRaceCountdown[raceid]);
                        GameTextForPlayer(i, countstr, 1250, 3);
                        PlayerPlaySound(i, 1056, 0.0, 0.0, 0.0);
                    }
                }
            }
            else if(gRaceCountdown[raceid] == 1)
            {
                gRaceCountdown[raceid]--;
                foreach(new i: Player)
                {
                    if(GetPlayerRace(i) == raceid)
                    {
                        GameTextForPlayer(i, "~g~GO!", 3000, 3);
                        PlayerPlaySound(i, 1057, 0.0, 0.0, 0.0);
                        ShowPlayerRaceCheckpoint(i);
                        TogglePlayerControllable(i, true);
                        gPlayerData[i][e_start_time] = GetTickCount();
                    }
                }
            }
        }
    }
}

//------------------------------------------------------------------------------

hook OnPlayerSpawn(playerid)
{
    if(GetPlayerRace(playerid) != INVALID_RACE_ID)
    {
        new raceid = GetPlayerRace(playerid);
        new racer_id = gPlayerData[playerid][e_grid_id];
        new vehicleid = gVehicleData[raceid][racer_id][e_vehicle_id];
        SetVehicleToRespawn(vehicleid);

        new cid = gPlayerData[playerid][e_checkpoint_id];
        new Float:x, Float:y, Float:z;
        if(cid > 0)
        {
            x = gCheckpointData[raceid][cid - 1][e_checkpoint_x];
            y = gCheckpointData[raceid][cid - 1][e_checkpoint_y];
            z = gCheckpointData[raceid][cid - 1][e_checkpoint_z];
        }
        else
        {
            x = gVehicleData[raceid][racer_id][e_vehicle_x];
            y = gVehicleData[raceid][racer_id][e_vehicle_y];
            z = gVehicleData[raceid][racer_id][e_vehicle_z];
        }
        SetVehiclePos(vehicleid, x, y, z);
        PutPlayerInVehicle(playerid, vehicleid, 0);
    }
    return 1;
}

//------------------------------------------------------------------------------

hook OnPlayerUpdate(playerid)
{
    if(GetPlayerRace(playerid) != INVALID_RACE_ID && GetPlayerState(playerid) == PLAYER_STATE_SPECTATING)
    {
        new raceid = GetPlayerRace(playerid);
        new Keys,ud,lr;
        GetPlayerKeys(playerid,Keys,ud,lr);

        new count;
        new players[MAX_RACE_PLAYERS] = {INVALID_PLAYER_ID, ...};
        if(lr == KEY_LEFT)
        {
            foreach(new i: Player)
            {
                if(GetPlayerRace(i) == raceid && GetPlayerState(i) != PLAYER_STATE_SPECTATING)
                {
                    players[count] = i;
                }
            }

            for(new i = 0; i < MAX_RACE_PLAYERS; i++)
            {
                if(gPlayerData[playerid][e_spec_targetid] < players[i] && players[i] > 0)
                {
                    SetPlayerSpecatateTarget(playerid, players[i]);
                    break;
                }
                else if(i == (MAX_RACE_PLAYERS - 1))
                {
                    SetPlayerSpecatateTarget(playerid, players[0]);
                }
            }
        }
        else if(lr == KEY_RIGHT)
        {
            foreach(new i: Player)
            {
                if(GetPlayerRace(i) == raceid && GetPlayerState(i) != PLAYER_STATE_SPECTATING)
                {
                    players[count] = i;
                }
            }

            for(new i = 0; i < MAX_RACE_PLAYERS; i++)
            {
                if(gPlayerData[playerid][e_spec_targetid] > players[i] && players[i] > 0)
                {
                    SetPlayerSpecatateTarget(playerid, players[i]);
                    break;
                }
                else if(i == (MAX_RACE_PLAYERS - 1))
                {
                    new targetid = -1;
                    for(new j = 0; j < MAX_RACE_PLAYERS; j++)
                    {
                        if(players[j] > targetid)
                            targetid = players[j];
                    }
                    SetPlayerSpecatateTarget(playerid, targetid);
                }
            }
        }
    }
    return 1;
}

//------------------------------------------------------------------------------

hook OnPlayerEnterRaceCP(playerid)
{
    new raceid = GetPlayerRace(playerid);
    if(raceid != INVALID_RACE_ID && gRaceData[raceid][e_race_state] == RACE_STATE_STARTED)
    {
        PlaySelectSound(playerid);
        gPlayerData[playerid][e_checkpoint_id]++;

        new cid     = gPlayerData[playerid][e_checkpoint_id];
        new Float:x = gCheckpointData[raceid][cid][e_checkpoint_x];
        new Float:y = gCheckpointData[raceid][cid][e_checkpoint_y];
        new Float:z = gCheckpointData[raceid][cid][e_checkpoint_z];
        if(cid == MAX_RACE_CHECKPOINTS || (x == 0.0 && y == 0.0 && z == 0.0))
        {
            gRaceData[raceid][e_race_leaderboard][gRaceData[raceid][e_race_counter]] = playerid;
            gRaceData[raceid][e_race_counter]++;
            gPlayerData[playerid][e_end_time] = GetTickCount();
            DisablePlayerRaceCheckpoint(playerid);

            new minutes         = (gPlayerData[playerid][e_end_time] - gPlayerData[playerid][e_start_time]) / 60000;
            new seconds         = (((gPlayerData[playerid][e_end_time] - gPlayerData[playerid][e_start_time]) % (1000 * 60 * 60)) % (1000 * 60)) / 1000;
            new milliseconds    = (gPlayerData[playerid][e_end_time] - gPlayerData[playerid][e_start_time]) % 1000;

            new gameText[64];
            format(gameText, sizeof(gameText), "~g~Corrida concluida~n~~w~%02d:%02d:%03d", minutes, seconds, milliseconds);
            GameTextForPlayer(playerid, gameText, 3000, 3);

            // Verifica se ainda há jogadores correndo
            new remaining_racers = 0;
            foreach(new i: Player)
            {
                if(GetPlayerRace(i) == raceid && gPlayerData[i][e_end_time] == 0)
                {
                    remaining_racers++;
                }
            }

            // Se não houver mais corredores finaliza a corrida,
            // Se houver, aguarda a corrida finalizar
            if(remaining_racers == 0)
            {
                new output[512];
                strcat(output, "#\tJogador\tTempo\n");
                for(new i = 0; i < MAX_RACE_PLAYERS; i++)
                {
                    new j = gRaceData[raceid][e_race_leaderboard][i];

                    if(j == INVALID_PLAYER_ID)
                        continue;

                    new j_minutes         = (gPlayerData[j][e_end_time] - gPlayerData[j][e_start_time]) / 60000;
                    new j_seconds         = (((gPlayerData[j][e_end_time] - gPlayerData[j][e_start_time]) % (1000 * 60 * 60)) % (1000 * 60)) / 1000;
                    new j_milliseconds    = (gPlayerData[j][e_end_time] - gPlayerData[j][e_start_time]) % 1000;

                    GivePlayerCash(playerid, gPrizeData[raceid][i]);

                    new string[64];
                    format(string, sizeof(string), "%d\t%s\t%02d:%02d:%03d\n", i + 1, GetPlayerNamef(j), j_minutes, j_seconds, j_milliseconds);
                    strcat(output, string);
                }

                foreach(new i: Player)
                {
                    if(GetPlayerRace(i) == raceid)
                    {
                        ShowPlayerDialog(i, DIALOG_RACE_LEADERBOARD, DIALOG_STYLE_TABLIST_HEADERS, "Resultados finais", output, "Fechar", "");
                    }
                }
                defer EndRace(raceid);
            }
            else
            {
                TogglePlayerSpectating(playerid, true);
                new grid = gPlayerData[playerid][e_grid_id];
                DestroyVehicle(gVehicleData[raceid][grid][e_vehicle_id]);
                gVehicleData[raceid][grid][e_vehicle_id] = INVALID_VEHICLE_ID;
                foreach(new i: Player)
                {
                    if(GetPlayerRace(i) == raceid && GetPlayerState(i) != PLAYER_STATE_SPECTATING && i != playerid)
                    {
                        SetPlayerSpecatateTarget(playerid, i);
                        break;
                    }
                }
            }
        }
        else
        {
            ShowPlayerRaceCheckpoint(playerid);
        }
    }
    return 1;
}

//------------------------------------------------------------------------------

hook OnPlayerDisconnect(playerid, reason)
{
    gIsDialogShown[playerid] = false;
    ResetPlayerRaceData(playerid);
    return 1;
}

//------------------------------------------------------------------------------

timer EndRace[7500](raceid)
{
    // Reseta todas as variaveis e envia o jogadores para o lobby da corrida

    gRaceData[raceid][e_race_state] = RACE_STATE_WAITING_PLAYERS;
    gRaceData[raceid][e_race_counter] = 0;
    for(new i = 0; i < MAX_RACE_PLAYERS; i++)
    {
        gRaceData[raceid][e_race_leaderboard][i] = INVALID_PLAYER_ID;
    }

    for(new i = 0; i < MAX_RACE_PLAYERS; i++)
    {
        DestroyVehicle(gVehicleData[raceid][i][e_vehicle_id]);
        gVehicleData[raceid][i][e_vehicle_id] = INVALID_VEHICLE_ID;
    }

    foreach(new i: Player)
    {
        if(GetPlayerRace(i) == raceid)
        {
            if(GetPlayerState(i) == PLAYER_STATE_SPECTATING)
            {
                TogglePlayerSpectating(i, false);
                gPlayerData[i][e_spec_targetid] = INVALID_PLAYER_ID;
            }

            gPlayerData[i][e_grid_id] = 0;
            gPlayerData[i][e_checkpoint_id] = 0;
            gPlayerData[i][e_start_time] = 0;
            gPlayerData[i][e_end_time] = 0;
            OnPlayerEnterRace(i, raceid);
        }
    }
}

//------------------------------------------------------------------------------

ShowPlayerRaceCheckpoint(playerid)
{
    new cid     = gPlayerData[playerid][e_checkpoint_id];
    new raceid  = GetPlayerRace(playerid);
    new Float:x = gCheckpointData[raceid][cid][e_checkpoint_x];
    new Float:y = gCheckpointData[raceid][cid][e_checkpoint_y];
    new Float:z = gCheckpointData[raceid][cid][e_checkpoint_z];
    new ctype = gRaceData[raceid][e_race_cp_type];
    new Float:size = gRaceData[raceid][e_race_cp_size];

    if(cid >= (MAX_RACE_CHECKPOINTS - 1))
    {
        SetPlayerRaceCheckpoint(playerid, ctype, x, y, z, 0.0, 0.0, 0.0, size);
    }
    else
    {
        new Float:nextx = gCheckpointData[raceid][cid + 1][e_checkpoint_x];
        new Float:nexty = gCheckpointData[raceid][cid + 1][e_checkpoint_y];
        new Float:nextz = gCheckpointData[raceid][cid + 1][e_checkpoint_z];
        if(nextx == 0.0 && nexty == 0.0 && nextz == 0.0)
        {
            SetPlayerRaceCheckpoint(playerid, ctype, x, y, z, 0.0, 0.0, 0.0, size);
        }
        else
        {
            SetPlayerRaceCheckpoint(playerid, (ctype == 4) ? 3 : 0, x, y, z, nextx, nexty, nextz, size);
        }
    }
}

//------------------------------------------------------------------------------

ResetPlayerRaceData(playerid)
{
    new raceid = GetPlayerRace(playerid);
    if(raceid != INVALID_RACE_ID)
    {
        if(gRaceData[raceid][e_race_state] == RACE_STATE_STARTED)
        {
            new grid = gPlayerData[playerid][e_grid_id];
            DestroyVehicle(gVehicleData[raceid][grid][e_vehicle_id]);
            gVehicleData[raceid][grid][e_vehicle_id] = INVALID_VEHICLE_ID;
            DisablePlayerRaceCheckpoint(playerid);
        }
        gPlayerData[playerid][e_grid_id] = 0;
        gPlayerData[playerid][e_checkpoint_id] = 0;
        gPlayerData[playerid][e_start_time] = 0;
        gPlayerData[playerid][e_end_time] = 0;
        SetPlayerRace(playerid, INVALID_RACE_ID);

        // Se não houver nenhum jogador correndo, reiniciar a corrida
        if(GetRacePlayerPoolSize(raceid) == 0)
        {
            EndRace(raceid);
        }
    }
}

//------------------------------------------------------------------------------

SetPlayerSpecatateTarget(playerid, targetid)
{
    if(IsPlayerInAnyVehicle(targetid))
    {
        PlayerSpectateVehicle(playerid, GetPlayerVehicleID(targetid));
    }
    else
    {
        PlayerSpectatePlayer(playerid, targetid);
    }
    gPlayerData[playerid][e_spec_targetid] = targetid;
}

//------------------------------------------------------------------------------

SetPlayerRace(playerid, raceid)
{
    gPlayerCurrentRace[playerid] = raceid;
}

GetPlayerRace(playerid)
{
    return gPlayerCurrentRace[playerid];
}

GetRacePlayerPoolSize(raceid)
{
    new count = 0;
    foreach(new i: Player)
    {
        if(GetPlayerRace(i) == raceid)
        {
            count++;
        }
    }
    return count;
}

GetRaceMaxPlayers(raceid)
{
    new count = 0;
    for(new i = 0; i < MAX_RACE_PLAYERS; i++)
    {
        if(gVehicleData[raceid][i][e_race_id] == 0)
            break;

        count++;
    }
    return count;
}

IsRaceDialogVisible(playerid)
{
    return gIsDialogShown[playerid];
}

//------------------------------------------------------------------------------

ShowPlayerRaceList(playerid)
{
    new output[256], string[64], status[24];
    strcat(output, "Nome\tJogadores\tStatus\n");
    for(new i = 0; i < MAX_RACES; i++)
    {
        if(!gRaceData[i][e_race_id])
            break;

        switch (gRaceData[i][e_race_state])
        {
            case RACE_STATE_WAITING_PLAYERS:
                status = "Aguardando jogadores";
            case RACE_STATE_STARTING:
                status = "Prestes a iniciar";
            case RACE_STATE_STARTED:
                status = "Em andamento";
        }
        format(string, sizeof(string), "%s\t%d / %d\t%s\n", gRaceData[i][e_race_name], GetRacePlayerPoolSize(i), GetRaceMaxPlayers(i), status);
        strcat(output, string);
    }
    gIsDialogShown[playerid] = true;
    ShowPlayerDialog(playerid, DIALOG_RACE, DIALOG_STYLE_TABLIST_HEADERS, "Corridas", output, "Selecionar", "Voltar");
}
