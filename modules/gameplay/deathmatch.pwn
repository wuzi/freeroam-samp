/*******************************************************************************
* NOME DO ARQUIVO :		modules/gameplay/deathmatch.pwn
*
* DESCRIÇÃO :
*	   Permite que jogadores participem de deathmatch.
*
* NOTAS :
*	   -
*/

#include <YSI\y_hooks>

//------------------------------------------------------------------------------

static const VIRTUAL_WORLD = 1000;

#define MAX_DEATHMATCHES                                            32
#define MAX_DEATHMATCH_NAME                                         30
#define MAX_DEATHMATCH_PLAYERS                                      30

//------------------------------------------------------------------------------

forward OnDeathmatchLoad();
forward OnDeathmatchSpawnLoad(dmid);
forward OnDeathmatchWeaponsLoad(dmid);
forward OnPlayerEnterDeathmatch(playerid, dmid);

//------------------------------------------------------------------------------

enum e_player_dm_data
{
    e_player_state,
    e_player_spawn,
    e_player_kills,
    e_player_deaths,
    e_player_start,
    e_player_end,
    e_player_deathmatch_id,
    e_player_targetid
}
static gPlayerData[MAX_PLAYERS][e_player_dm_data];

enum e_dm_data
{
    e_dm_state,
    e_dm_db_id,
    e_dm_interior,
    e_dm_weapon[11],
    e_dm_name[MAX_DEATHMATCH_NAME],
    Float:e_dm_spawn_x[MAX_DEATHMATCH_PLAYERS],
    Float:e_dm_spawn_y[MAX_DEATHMATCH_PLAYERS],
    Float:e_dm_spawn_z[MAX_DEATHMATCH_PLAYERS],
    Float:e_dm_spawn_a[MAX_DEATHMATCH_PLAYERS]
}
static gDeathmatchData[MAX_DEATHMATCHES][e_dm_data];

//------------------------------------------------------------------------------

enum
{
    DM_STATE_WAITING_PLAYERS,
    DM_STATE_STARTING,
    DM_STATE_STARTED
}

enum
{
    DM_PLAYER_STATE_NONE,
    DM_PLAYER_STATE_PLAYING,
    DM_PLAYER_STATE_SPECTATING
}

//------------------------------------------------------------------------------

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

//------------------------------------------------------------------------------

static gIsDialogShown[MAX_PLAYERS];
static gPlayerSpecTick[MAX_PLAYERS];

static gDeathmatchCountdown[MAX_DEATHMATCHES];

//------------------------------------------------------------------------------

hook OnGameModeInit()
{
    mysql_tquery(gMySQL, "SELECT * FROM deathmatches", "OnDeathmatchLoad");
    return 1;
}

//------------------------------------------------------------------------------

public OnDeathmatchLoad()
{
    new rows, fields;
	cache_get_data(rows, fields, gMySQL);
    for(new i = 0; i < rows; i++)
    {
        gDeathmatchData[i][e_dm_db_id] = cache_get_field_content_int(i, "id", gMySQL);
        gDeathmatchData[i][e_dm_interior]  = cache_get_field_content_int(i, "interior", gMySQL);
        cache_get_field_content(i, "name", gDeathmatchData[i][e_dm_name], gMySQL, MAX_DEATHMATCH_NAME);

        new query[68];
        mysql_format(gMySQL, query, sizeof(query), "SELECT * FROM deathmatch_spawns WHERE deathmatch_id = %d", gDeathmatchData[i][e_dm_db_id]);
        mysql_tquery(gMySQL, query, "OnDeathmatchSpawnLoad", "i", i);
        mysql_format(gMySQL, query, sizeof(query), "SELECT * FROM deathmatch_weapons WHERE deathmatch_id = %d", gDeathmatchData[i][e_dm_db_id]);
        mysql_tquery(gMySQL, query, "OnDeathmatchWeaponsLoad", "i", i);
    }
}

//------------------------------------------------------------------------------

public OnDeathmatchSpawnLoad(dmid)
{
    new rows, fields;
	cache_get_data(rows, fields, gMySQL);
    for(new i = 0; i < rows; i++)
    {
        gDeathmatchData[dmid][e_dm_spawn_x][i] = cache_get_field_content_float(i, "x", gMySQL);
        gDeathmatchData[dmid][e_dm_spawn_y][i] = cache_get_field_content_float(i, "y", gMySQL);
        gDeathmatchData[dmid][e_dm_spawn_z][i] = cache_get_field_content_float(i, "z", gMySQL);
        gDeathmatchData[dmid][e_dm_spawn_a][i] = cache_get_field_content_float(i, "a", gMySQL);
    }
}

//------------------------------------------------------------------------------

public OnDeathmatchWeaponsLoad(dmid)
{
    new rows, fields;
	cache_get_data(rows, fields, gMySQL);
    for(new i = 0; i < rows; i++)
    {
        gDeathmatchData[dmid][e_dm_weapon][i] = cache_get_field_content_int(i, "weaponid", gMySQL);
    }
}

//------------------------------------------------------------------------------

hook OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
    switch (dialogid)
    {
        case DIALOG_DEATHMATCH:
        {
            if(!response)
            {
                PlayCancelSound(playerid);
            }
            else if(GetDmPlayerPoolSize(listitem) == GetDmMaxPlayers(listitem))
            {
                PlayErrorSound(playerid);
                SendClientMessage(playerid, COLOR_ERROR, "* Esse deathmatch está lotado.");
                ShowPlayerDeathmatchList(playerid);
            }
            else if(gDeathmatchData[listitem][e_dm_state] == DM_STATE_STARTED)
            {
                SendClientMessage(playerid, COLOR_INFO, "* Este deathmatch já foi iniciado, você ficará de espectador até a próxima partida.");
                PlaySelectSound(playerid);
                ResetPlayerDeathmatchData(playerid);
                OnPlayerEnterDeathmatch(playerid, listitem);
            }
            else
            {
                PlaySelectSound(playerid);
                ResetPlayerDeathmatchData(playerid);
                OnPlayerEnterDeathmatch(playerid, listitem);
            }
            gIsDialogShown[playerid] = false;
        }
        case DIALOG_DEATHMATCH_LEADERBOARD:
        {
            PlaySelectSound(playerid);
        }
    }
    return 1;
}

//------------------------------------------------------------------------------

public OnPlayerEnterDeathmatch(playerid, dmid)
{
    HidePlayerLobby(playerid);
    SetPlayerHealth(playerid, 9999.0);
    SetPlayerDeathmatch(playerid, dmid);
    TogglePlayerControllable(playerid, true);
    SetPlayerGamemode(playerid, GAMEMODE_DEATHMATCH);
    SetPlayerVirtualWorld(playerid, (dmid + VIRTUAL_WORLD));

    if(gDeathmatchData[dmid][e_dm_state] != DM_STATE_STARTED)
    {
        new rand = random(sizeof(gLobbySpawns));
        SetPlayerInterior(playerid, 10);
        SetPlayerPos(playerid, gLobbySpawns[rand][0], gLobbySpawns[rand][1], gLobbySpawns[rand][2]);
        SetPlayerFacingAngle(playerid, gLobbySpawns[rand][3]);
        SendClientMessagef(playerid, COLOR_SUCCESS, "* Você entrou no deathmatch %s!", gDeathmatchData[dmid][e_dm_name]);
        gPlayerData[playerid][e_player_state] = DM_PLAYER_STATE_PLAYING;
    }

    switch (gDeathmatchData[dmid][e_dm_state])
    {
        case DM_STATE_WAITING_PLAYERS:
        {
            GameTextForPlayer(playerid, "~y~Aguardando jogadores...", 1250, 3);
            SendClientMessage(playerid, COLOR_SUCCESS, "* Aguardando mais jogadores para iniciar...");

            new count = 0;
            foreach(new i: Player)
            {
                if(GetPlayerDeathmatch(i) == dmid)
                {
                    count++;
                }
            }

            if(count >= MINIMUM_PLAYERS_TO_START_DM)
            {
                foreach(new i: Player)
                {
                    if(GetPlayerDeathmatch(i) == dmid)
                    {
                        GameTextForPlayer(i, "~g~Iniciando deathmatch...", 1250, 3);
                        SendClientMessagef(i, COLOR_SUCCESS, "* A quantidade minima de jogadores foi alcançada, o deathmatch irá iniciar em %d segundos.", DEATHMATCH_COUNT_DOWN);
                    }
                }
                gDeathmatchCountdown[dmid] = DEATHMATCH_COUNT_DOWN;
                gDeathmatchData[dmid][e_dm_state] = DM_STATE_STARTING;
            }
        }
        case DM_STATE_STARTED:
        {
            gPlayerData[playerid][e_player_state] = DM_PLAYER_STATE_SPECTATING;
            TogglePlayerSpectating(playerid, true);

            foreach(new i: Player)
            {
                if(GetPlayerDeathmatch(i) == dmid && gPlayerData[i][e_player_state] == DM_PLAYER_STATE_PLAYING)
                {
                    gPlayerData[playerid][e_player_targetid] = i;
                    SetPlayerInterior(playerid, gDeathmatchData[dmid][e_dm_interior]);
                    PlayerSpectatePlayer(playerid, i);
                }
            }
        }
    }
    return 1;
}

//------------------------------------------------------------------------------

hook OnPlayerUpdate(playerid)
{
    if(GetPlayerDeathmatch(playerid) != INVALID_DEATHMATCH_ID && gPlayerData[playerid][e_player_state] == DM_PLAYER_STATE_SPECTATING)
    {
        new dmid = GetPlayerDeathmatch(playerid);
        if(GetPlayerState(playerid) != PLAYER_STATE_SPECTATING)
        {
            TogglePlayerSpectating(playerid, true);
            foreach(new i: Player)
            {
                if(GetPlayerDeathmatch(i) == dmid && gPlayerData[i][e_player_state] == DM_PLAYER_STATE_PLAYING)
                {
                    gPlayerData[playerid][e_player_targetid] = i;
                    PlayerSpectatePlayer(playerid, i);
                    break;
                }
            }
        }
        else if(gPlayerSpecTick[playerid] < GetTickCount())
        {
            new
                Keys,
                ud,
                lr
            ;
            GetPlayerKeys(playerid, Keys, ud, lr);
            gPlayerSpecTick[playerid] = GetTickCount() + 50;
            if(lr == KEY_LEFT)
            {
                foreach(new i: Player)
                {
                    if(GetPlayerDeathmatch(i) == dmid && gPlayerData[i][e_player_state] == DM_PLAYER_STATE_PLAYING)
                    {
                        if(gPlayerData[playerid][e_player_targetid] > i)
                        {
                            gPlayerData[playerid][e_player_targetid] = i;
                            PlayerSpectatePlayer(playerid, i);
                        }
                    }
                }
            }
            else if(lr == KEY_RIGHT)
            {
                foreach(new i: Player)
                {
                    if(GetPlayerDeathmatch(i) == dmid && gPlayerData[i][e_player_state] == DM_PLAYER_STATE_PLAYING)
                    {
                        if(gPlayerData[playerid][e_player_targetid] < i)
                        {
                            gPlayerData[playerid][e_player_targetid] = i;
                            PlayerSpectatePlayer(playerid, i);
                        }
                    }
                }
            }
        }
    }
    return 1;
}

//------------------------------------------------------------------------------

hook OnPlayerDisconnect(playerid, reason)
{
    gIsDialogShown[playerid] = false;
    ResetPlayerDeathmatchData(playerid);
    return 1;
}

//------------------------------------------------------------------------------

hook OnPlayerSpawn(playerid)
{
    if(GetPlayerDeathmatch(playerid) != INVALID_DEATHMATCH_ID && GetPlayerGamemode(playerid) == GAMEMODE_DEATHMATCH)
    {
        new dmid = GetPlayerDeathmatch(playerid);
        new spawn_id = gPlayerData[playerid][e_player_spawn];
        SetPlayerInterior(playerid, gDeathmatchData[dmid][e_dm_interior]);
        SetPlayerPos(playerid, gDeathmatchData[dmid][e_dm_spawn_x][spawn_id], gDeathmatchData[dmid][e_dm_spawn_y][spawn_id], gDeathmatchData[dmid][e_dm_spawn_z][spawn_id]);
        SetPlayerFacingAngle(playerid, gDeathmatchData[dmid][e_dm_spawn_a][spawn_id]);
        SetCameraBehindPlayer(playerid);

        for(new j = 0; j < 11; j++)
        {
            GivePlayerWeapon(playerid, gDeathmatchData[dmid][e_dm_weapon][j], 9999);
        }
    }
    return 1;
}

//------------------------------------------------------------------------------

hook OnPlayerDeath(playerid, killerid, reason)
{
    if(killerid != INVALID_PLAYER_ID)
    {
        if(GetPlayerDeathmatch(playerid) == GetPlayerDeathmatch(killerid))
        {
            gPlayerData[playerid][e_player_deaths]++;
            gPlayerData[killerid][e_player_kills]++;
        }
    }
    else if(killerid == INVALID_PLAYER_ID && GetPlayerDeathmatch(playerid) != INVALID_DEATHMATCH_ID)
    {
        if(gPlayerData[playerid][e_player_kills] > 0)
            gPlayerData[playerid][e_player_kills]--;
    }
    return 1;
}

//------------------------------------------------------------------------------

task OnDeathMatchUpdate[1000]()
{
    for(new dmid = 0; dmid < MAX_DEATHMATCHES; dmid++)
    {
        if(!gDeathmatchData[dmid][e_dm_db_id])
            break;

        if(gDeathmatchData[dmid][e_dm_state] == DM_STATE_WAITING_PLAYERS)
        {
            foreach(new i: Player)
            {
                if(GetPlayerDeathmatch(i) == dmid)
                {
                    if(gDeathmatchData[dmid][e_dm_state] == DM_STATE_WAITING_PLAYERS)
                    {
                        GameTextForPlayer(i, "~y~Aguardando jogadores...", 1250, 3);
                    }
                }
            }
        }
        else if(gDeathmatchData[dmid][e_dm_state] == DM_STATE_STARTING)
        {
            if(gDeathmatchCountdown[dmid] > 0)
            {
                foreach(new i: Player)
                {
                    if(GetPlayerDeathmatch(i) == dmid)
                    {
                        new countstr[38];
                        format(countstr, sizeof(countstr), "~g~Iniciando partida~n~%02d", gDeathmatchCountdown[dmid]);
                        GameTextForPlayer(i, countstr, 1250, 3);

                        if(gDeathmatchCountdown[dmid] < 6)
                            PlayerPlaySound(i, 1056, 0.0, 0.0, 0.0);
                    }
                }
                gDeathmatchCountdown[dmid]--;
            }
            else
            {
                new spawn_id = 0;
                gDeathmatchData[dmid][e_dm_state] = DM_STATE_STARTED;
                gDeathmatchCountdown[dmid] = 6;
                foreach(new i: Player)
                {
                    if(GetPlayerDeathmatch(i) == dmid)
                    {
                        PlayerPlaySound(i, 1056, 0.0, 0.0, 0.0);
                        GameTextForPlayer(i, "~g~~h~A partida ira iniciar~n~prepare-se", 1250, 3);
                        gPlayerData[i][e_player_spawn] = spawn_id;
                        SetPlayerInterior(i, gDeathmatchData[dmid][e_dm_interior]);
                        SetPlayerPos(i, gDeathmatchData[dmid][e_dm_spawn_x][spawn_id], gDeathmatchData[dmid][e_dm_spawn_y][spawn_id], gDeathmatchData[dmid][e_dm_spawn_z][spawn_id]);
                        SetPlayerFacingAngle(i, gDeathmatchData[dmid][e_dm_spawn_a][spawn_id]);
                        SetCameraBehindPlayer(i);
                        TogglePlayerControllable(i, false);
                        spawn_id++;
                    }
                }
            }
        }
        else if(gDeathmatchData[dmid][e_dm_state] == DM_STATE_STARTED)
        {
            if(gDeathmatchCountdown[dmid] > 1)
            {
                gDeathmatchCountdown[dmid]--;
                foreach(new i: Player)
                {
                    if(GetPlayerDeathmatch(i) == dmid)
                    {
                        new countstr[38];
                        format(countstr, sizeof(countstr), "~r~%02d", gDeathmatchCountdown[dmid]);
                        GameTextForPlayer(i, countstr, 1250, 3);
                        PlayerPlaySound(i, 1056, 0.0, 0.0, 0.0);
                    }
                }
            }
            else if(gDeathmatchCountdown[dmid] == 1)
            {
                gDeathmatchCountdown[dmid]--;
                foreach(new i: Player)
                {
                    if(GetPlayerDeathmatch(i) == dmid)
                    {
                        TogglePlayerControllable(i, true);
                        GameTextForPlayer(i, "~g~GO!", 3000, 3);
                        PlayerPlaySound(i, 1057, 0.0, 0.0, 0.0);
                        gPlayerData[i][e_player_start] = GetTickCount();

                        for(new j = 0; j < 11; j++)
                        {
                            GivePlayerWeapon(i, gDeathmatchData[dmid][e_dm_weapon][j], 9999);
                        }
                    }
                }
            }
        }
    }
}

//------------------------------------------------------------------------------

timer EndDeathmatch[7500](dmid)
{
    // Reseta todas as variaveis e envia o jogadores para o lobby do dm
    gDeathmatchData[dmid][e_dm_state] = DM_STATE_WAITING_PLAYERS;
    foreach(new i: Player)
    {
        if(GetPlayerDeathmatch(i) == dmid)
        {
            if(GetPlayerState(i) == PLAYER_STATE_SPECTATING)
            {
                TogglePlayerSpectating(i, false);
                gPlayerData[i][e_player_targetid] = INVALID_PLAYER_ID;
            }

            gPlayerData[i][e_player_start]          = 0;
            gPlayerData[i][e_player_end]            = 0;
            gPlayerData[i][e_player_kills]          = 0;
            gPlayerData[i][e_player_deaths]         = 0;
            gPlayerData[i][e_player_spawn]          = 0;
            gPlayerData[i][e_player_state]          = DM_PLAYER_STATE_NONE;
            gPlayerData[i][e_player_deathmatch_id]  = INVALID_DEATHMATCH_ID;
            OnPlayerEnterDeathmatch(i, dmid);
        }
    }
}

//------------------------------------------------------------------------------

ResetPlayerDeathmatchData(playerid)
{
    if(GetPlayerState(playerid) == PLAYER_STATE_SPECTATING)
        TogglePlayerSpectating(playerid, false);

    new dmid = GetPlayerDeathmatch(playerid);
    SetPlayerDeathmatch(playerid, INVALID_DEATHMATCH_ID);
    if(dmid != INVALID_DEATHMATCH_ID)
    {
        if(gDeathmatchData[dmid][e_dm_state] == DM_STATE_STARTED)
        {
            // Verifica se ainda há jogadores correndo
            new remaining_players = 0;
            foreach(new i: Player)
            {
                if(GetPlayerDeathmatch(i) == dmid && gPlayerData[i][e_player_state] == DM_PLAYER_STATE_PLAYING)
                {
                    remaining_players++;
                }
            }

            // Se não houver mais corredores finaliza a corrida,
            // Se houver, aguarda a corrida finalizar
            if(remaining_players < 2)
            {
                new output[4096];
                strcat(output, "#\tJogador\tTempo\tK/D\n");
                foreach(new i: Player)
                {
                    if(gPlayerData[i][e_player_state] != DM_PLAYER_STATE_PLAYING)
                        continue;

                    if(gPlayerData[i][e_player_end] == 0)
                        gPlayerData[i][e_player_end] = GetTickCount();

                    new j_minutes         = (gPlayerData[i][e_player_end] - gPlayerData[i][e_player_start]) / 60000;
                    new j_seconds         = (((gPlayerData[i][e_player_end] - gPlayerData[i][e_player_start]) % (1000 * 60 * 60)) % (1000 * 60)) / 1000;
                    new j_milliseconds    = (gPlayerData[i][e_player_end] - gPlayerData[i][e_player_start]) % 1000;

                    new string[74];
                    format(string, sizeof(string), "%d\t%s\t%02d:%02d:%03d\t%d/%d\n", i + 1, GetPlayerNamef(i), j_minutes, j_seconds, j_milliseconds, gPlayerData[i][e_player_kills], gPlayerData[i][e_player_deaths]);
                    strcat(output, string);
                }

                foreach(new i: Player)
                {
                    if(GetPlayerDeathmatch(i) == dmid)
                    {
                        ShowPlayerDialog(i, DIALOG_DEATHMATCH_LEADERBOARD, DIALOG_STYLE_TABLIST_HEADERS, "Resultados finais", output, "Fechar", "");
                    }
                }
                defer EndDeathmatch(dmid);
            }
        }
        gPlayerData[playerid][e_player_start]          = 0;
        gPlayerData[playerid][e_player_end]            = 0;
        gPlayerData[playerid][e_player_kills]          = 0;
        gPlayerData[playerid][e_player_deaths]         = 0;
        gPlayerData[playerid][e_player_spawn]          = 0;
        gPlayerData[playerid][e_player_state]          = DM_PLAYER_STATE_NONE;
        gPlayerData[playerid][e_player_deathmatch_id]  = INVALID_DEATHMATCH_ID;

        // Se não houver nenhum jogador correndo, reiniciar a corrida
        if(GetDmPlayerPoolSize(dmid) == 0)
        {
            EndDeathmatch(dmid);
        }
    }
}

//------------------------------------------------------------------------------

SetPlayerDeathmatch(playerid, dmid)
{
    gPlayerData[playerid][e_player_deathmatch_id] = dmid;
}

//------------------------------------------------------------------------------

GetPlayerDeathmatch(playerid)
{
    return gPlayerData[playerid][e_player_deathmatch_id];
}

//------------------------------------------------------------------------------

GetDmPlayerPoolSize(dmid)
{
    new counter = 0;
    foreach(new i: Player)
    {
        if(gPlayerData[i][e_player_deathmatch_id] == dmid)
            counter++;
    }
    return counter;
}

//------------------------------------------------------------------------------

GetDmMaxPlayers(dmid)
{
    new counter = 0;
    for(new i = 0; i < MAX_DEATHMATCH_PLAYERS; i++)
    {
        if(gDeathmatchData[dmid][e_dm_spawn_x][i] != 0.0)
            counter++;
    }
    return counter;
}

//------------------------------------------------------------------------------

IsDeathmatchDialogVisible(playerid)
{
    return gIsDialogShown[playerid];
}

//------------------------------------------------------------------------------

ShowPlayerDeathmatchList(playerid)
{
    new output[4096], string[64], status[24];
    strcat(output, "Nome\tJogadores\tStatus\n");
    for(new i = 0; i < MAX_DEATHMATCHES; i++)
    {
        if(!gDeathmatchData[i][e_dm_db_id])
            break;

        switch (gDeathmatchData[i][e_dm_state])
        {
            case DM_STATE_WAITING_PLAYERS:
                status = "Aguardando jogadores";
            case DM_STATE_STARTING:
                status = "Prestes a iniciar";
            case DM_STATE_STARTED:
                status = "Em andamento";
        }
        format(string, sizeof(string), "%s\t%d / %d\t%s\n", gDeathmatchData[i][e_dm_name], GetDmPlayerPoolSize(i), GetDmMaxPlayers(i), status);
        strcat(output, string);
    }
    gIsDialogShown[playerid] = true;
    ShowPlayerDialog(playerid, DIALOG_DEATHMATCH, DIALOG_STYLE_TABLIST_HEADERS, "Deathmatches", output, "Selecionar", "Voltar");
}

//------------------------------------------------------------------------------
