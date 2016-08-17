/*******************************************************************************
* NOME DO ARQUIVO :		modules/gameplay/derby.pwn
*
* DESCRIÇÃO :
*	   Adiciona o modo derby ao servidor.
*
* NOTAS :
*	   -
*/

#include <YSI\y_hooks>

forward OnPlayerEnterDerby(playerid, derbyid);

//------------------------------------------------------------------------------

static const VIRTUAL_WORLD = 3000;

#define INVALID_DERBY_ID                                        -1

enum
{
    DERBY_STATE_WAITING_PLAYERS,
    DERBY_STATE_STARTING,
    DERBY_STATE_STARTED,
    DERBY_STATE_ENDING
}

enum
{
    DERBY_PLAYER_STATE_NONE,
    DERBY_PLAYER_STATE_ALIVE,
    DERBY_PLAYER_STATE_SPECTATING
}

//------------------------------------------------------------------------------

enum e_derby_data
{
    e_derby_name[32],
    e_derby_state,
    e_derby_vmodel,
    e_derby_leaderboard[MAX_PLAYERS],
    e_derby_lcounter
}
static gDerbyData[MAX_DERBY][e_derby_data];

enum e_player_derby_data
{
    e_grid_id,
    e_state,
    e_start_time,
    e_end_time,
    e_spec_targetid,
    e_vehicle_id
}
static gPlayerData[MAX_PLAYERS][e_player_derby_data];
static gPlayerCurrentDerby[MAX_PLAYERS] = {INVALID_DERBY_ID, ...};
static gDerbyCountdown[MAX_DERBY];
static gPlayerSpecTick[MAX_PLAYERS];

//------------------------------------------------------------------------------

// Locais onde os jogadores irão dar spawn em cada mapa
static const Float:gPlayerSpawns[][][] =
{
    // SUMO
    {
        { 2913.7920, -3130.5566, 107.2750, 163.2152 },
        { 2901.9172, -3126.9749, 107.2984, 191.7273 },
        { 2888.5759, -3131.6440, 107.3228, 208.8633 },
        { 2876.4026, -3138.3540, 107.3490, 235.2153 },
        { 2869.5813, -3150.2598, 107.3736, 264.0153 },
        { 2869.2766, -3161.9634, 107.3946, 276.5433 },
        { 2872.5164, -3174.3484, 107.4165, 291.9513 },
        { 2878.2810, -3185.4270, 107.4387, 321.1833 },
        { 2887.4141, -3192.7739, 107.4608, 321.1833 },
        { 2897.9683, -3196.9666, 107.4779, 355.0377 },
        { 2911.6592, -3197.2813, 107.5027, 355.0377 }
    }
};

static bool:gIsDialogShown[MAX_PLAYERS];

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

hook OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
    switch (dialogid)
    {
        case DIALOG_DERBY:
        {
            if(!response)
            {
                PlayCancelSound(playerid);
            }
            else if(GetDerbyPlayerPoolSize(listitem) == GetDerbyMaxPlayers())
            {
                PlayErrorSound(playerid);
                SendClientMessage(playerid, COLOR_ERROR, "* Esse derby está lotado.");
                ShowPlayerDerbyList(playerid);
            }
            else if(gDerbyData[listitem][e_derby_state] == DERBY_STATE_STARTED)
            {
                SendClientMessage(playerid, COLOR_INFO, "* Este derby já foi iniciado, você ficará de espectador até a próxima partida.");
                PlaySelectSound(playerid);
                ResetPlayerDerbyData(playerid);
                OnPlayerEnterDerby(playerid, listitem);
            }
            else
            {
                PlaySelectSound(playerid);
                ResetPlayerDerbyData(playerid);
                OnPlayerEnterDerby(playerid, listitem);
            }
            gIsDialogShown[playerid] = false;
        }
        case DIALOG_DERBY_LEADERBOARD:
        {
            PlaySelectSound(playerid);
        }
    }
    return 1;
}

//------------------------------------------------------------------------------

public OnPlayerEnterDerby(playerid, derbyid)
{
    if(GetPlayerGamemode(playerid) == GAMEMODE_RACE)
    {
        ResetPlayerRaceData(playerid);
        DisableRemoteVehicleCollisions(playerid, false);
    }
    else if(GetPlayerGamemode(playerid) == GAMEMODE_DEATHMATCH)
    {
        ResetPlayerDeathmatchData(playerid);
        ResetPlayerWeapons(playerid);
    }

    HidePlayerLobby(playerid);
    SetPlayerHealth(playerid, 9999.0);
    TogglePlayerControllable(playerid, true);
    SetPlayerDerby(playerid, derbyid);
    SetPlayerGamemode(playerid, GAMEMODE_DERBY);
    SetPlayerVirtualWorld(playerid, (derbyid + VIRTUAL_WORLD));

    if(gDerbyData[derbyid][e_derby_state] == DERBY_STATE_WAITING_PLAYERS || gDerbyData[derbyid][e_derby_state] == DERBY_STATE_STARTING)
    {
        new rand = random(sizeof(gLobbySpawns));
        SetPlayerInterior(playerid, 10);
        SetPlayerPos(playerid, gLobbySpawns[rand][0], gLobbySpawns[rand][1], gLobbySpawns[rand][2]);
        SetPlayerFacingAngle(playerid, gLobbySpawns[rand][3]);
        SendClientMessagef(playerid, COLOR_SUCCESS, "* Você entrou no derby %s!", gDerbyData[derbyid][e_derby_name]);
    }

    if(gDerbyData[derbyid][e_derby_state] == DERBY_STATE_WAITING_PLAYERS)
    {
        GameTextForPlayer(playerid, "~y~Aguardando jogadores...", 1250, 3);
        SendClientMessage(playerid, COLOR_SUCCESS, "* Aguardando mais jogadores para iniciar...");

        new count = 0;
        foreach(new i: Player)
        {
            if(GetPlayerDerby(i) == derbyid)
            {
                count++;
            }
        }

        if(count >= MINIMUM_PLAYERS_TO_START_DERBY)
        {
            foreach(new i: Player)
            {
                if(GetPlayerDerby(i) == derbyid)
                {
                    GameTextForPlayer(i, "~g~Iniciando derby...", 1250, 3);
                    SendClientMessagef(i, COLOR_SUCCESS, "* A quantidade minima de jogadores foi alcançada, o derby irá iniciar em %d segundos.", DERBY_COUNT_DOWN);
                }
            }
            gDerbyCountdown[derbyid] = DERBY_COUNT_DOWN;
            gDerbyData[derbyid][e_derby_state] = DERBY_STATE_STARTING;
        }
    }
    else if(gDerbyData[derbyid][e_derby_state] == DERBY_STATE_STARTED)
    {
        gPlayerData[playerid][e_state] = DERBY_PLAYER_STATE_SPECTATING;
        TogglePlayerSpectating(playerid, true);

        for(new p = 0, j = GetPlayerPoolSize(); p <= j; p++)
        {
            if(GetPlayerDerby(p) == derbyid && gPlayerData[p][e_state] == DERBY_PLAYER_STATE_ALIVE)
            {
                gPlayerData[playerid][e_spec_targetid] = p;
                SetPlayerInterior(playerid, 0);
                SetPlayerSpecatateTarget(playerid, p);
            }
        }
    }
    return 1;
}

//------------------------------------------------------------------------------

task OnDerbyUpdate[1000]()
{
    for(new derbyid = 0; derbyid < MAX_DERBY; derbyid++)
    {
        if(strlen(gDerbyData[derbyid][e_derby_name]) < 1)
            break;

        if(gDerbyData[derbyid][e_derby_state] == DERBY_STATE_WAITING_PLAYERS)
        {
            foreach(new i: Player)
            {
                if(GetPlayerDerby(i) == derbyid)
                {
                    GameTextForPlayer(i, "~y~Aguardando jogadores...", 1250, 3);
                }
            }
        }
        else if(gDerbyData[derbyid][e_derby_state] == DERBY_STATE_STARTING)
        {
            if(gDerbyCountdown[derbyid] > 0)
            {
                foreach(new i: Player)
                {
                    if(GetPlayerDerby(i) == derbyid)
                    {
                        new countstr[38];
                        format(countstr, sizeof(countstr), "~g~Iniciando derby~n~%02d", gDerbyCountdown[derbyid]);
                        GameTextForPlayer(i, countstr, 1250, 3);

                        if(gPlayerData[i][e_state] != DERBY_PLAYER_STATE_ALIVE)
                            gPlayerData[i][e_state] = DERBY_PLAYER_STATE_ALIVE;

                        if(gDerbyCountdown[derbyid] < 6)
                            PlayerPlaySound(i, 1056, 0.0, 0.0, 0.0);
                    }
                }
                gDerbyCountdown[derbyid]--;
            }
            else
            {
                new grid_id = 0;
                gDerbyData[derbyid][e_derby_state] = DERBY_STATE_STARTED;
                gDerbyCountdown[derbyid] = 6;
                foreach(new i: Player)
                {
                    if(GetPlayerDerby(i) == derbyid)
                    {
                        PlayerPlaySound(i, 1056, 0.0, 0.0, 0.0);
                        GameTextForPlayer(i, "~g~~h~O derby ira iniciar~n~prepare-se", 1250, 3);
                        gPlayerData[i][e_grid_id] = grid_id;
                        gPlayerData[i][e_vehicle_id] = CreateVehicle(gDerbyData[derbyid][e_derby_vmodel], gPlayerSpawns[derbyid][grid_id][0], gPlayerSpawns[derbyid][grid_id][1], gPlayerSpawns[derbyid][grid_id][2], gPlayerSpawns[derbyid][grid_id][3], -1, -1, -1);
                        SetPlayerInterior(i, 0);
                        SetVehicleVirtualWorld(gPlayerData[i][e_vehicle_id], (derbyid + VIRTUAL_WORLD));
                        PutPlayerInVehicle(i, gPlayerData[i][e_vehicle_id], 0);
                        SetCameraBehindPlayer(i);
                        TogglePlayerControllable(i, false);
                        grid_id++;
                    }
                }
            }
        }
        else if(gDerbyData[derbyid][e_derby_state] == DERBY_STATE_STARTED)
        {
            if(gDerbyCountdown[derbyid] > 1)
            {
                gDerbyCountdown[derbyid]--;
                foreach(new i: Player)
                {
                    if(GetPlayerDerby(i) == derbyid)
                    {
                        new countstr[38];
                        format(countstr, sizeof(countstr), "~r~%02d", gDerbyCountdown[derbyid]);
                        GameTextForPlayer(i, countstr, 1250, 3);
                        PlayerPlaySound(i, 1056, 0.0, 0.0, 0.0);
                    }
                }
            }
            else if(gDerbyCountdown[derbyid] == 1)
            {
                gDerbyCountdown[derbyid]--;
                foreach(new i: Player)
                {
                    if(GetPlayerDerby(i) == derbyid)
                    {
                        GameTextForPlayer(i, "~g~GO!", 3000, 3);
                        PlayerPlaySound(i, 1057, 0.0, 0.0, 0.0);
                        TogglePlayerControllable(i, true);
                        gPlayerData[i][e_start_time] = GetTickCount();
                    }
                }
            }
            else
            {
                new remaining_players = 0;
                new Float:x, Float:y, Float:z;
                foreach(new i: Player)
                {
                    if(GetPlayerDerby(i) == derbyid)
                    {
                        if(gPlayerData[i][e_state] == DERBY_PLAYER_STATE_ALIVE)
                        {
                            new away_time = (GetTickCount() - GetPlayerPausedTime(i));
                            GetPlayerPos(i, x, y, z);
                            if(z <= 10.0 || away_time > 4500)
                            {
                                if(away_time > 4500)
                                    SendClientMessage(i, COLOR_WARNING, "* Você foi desclassificado por ficar ausente no derby.");

                                gDerbyData[derbyid][e_derby_leaderboard][gDerbyData[derbyid][e_derby_lcounter]] = i;
                                gDerbyData[derbyid][e_derby_lcounter]++;
                                gPlayerData[i][e_end_time] = GetTickCount();
                                gPlayerData[i][e_state] = DERBY_PLAYER_STATE_SPECTATING;
                                TogglePlayerSpectating(i, true);

                                for(new p = 0, j = GetPlayerPoolSize(); p <= j; p++)
                                {
                                    if(GetPlayerDerby(p) == derbyid && gPlayerData[p][e_state] == DERBY_PLAYER_STATE_ALIVE)
                                    {
                                        gPlayerData[i][e_spec_targetid] = p;
                                        SetPlayerSpecatateTarget(i, p);
                                    }
                                }
                            }
                            remaining_players++;
                        }
                    }
                }

                if(remaining_players < 2)
                {
                    gDerbyData[derbyid][e_derby_state] = DERBY_STATE_ENDING;

                    foreach(new i: Player)
                    {
                        if(GetPlayerDerby(i) == derbyid && gPlayerData[i][e_state] == DERBY_PLAYER_STATE_ALIVE)
                        {
                            gPlayerData[i][e_end_time] = GetTickCount();
                            gDerbyData[derbyid][e_derby_leaderboard][gDerbyData[derbyid][e_derby_lcounter]] = i;
                            gDerbyData[derbyid][e_derby_lcounter]++;
                        }
                    }

                    new output[512];
                    strcat(output, "#\tJogador\tTempo\n");
                    new ranking = 0;
                    for(new i = (gDerbyData[derbyid][e_derby_lcounter] - 1); i > -1; i--)
                    {
                        ranking++;
                        new j = gDerbyData[derbyid][e_derby_leaderboard][i];

                        if(j == INVALID_PLAYER_ID)
                            continue;

                        new j_minutes         = (gPlayerData[j][e_end_time] - gPlayerData[j][e_start_time]) / 60000;
                        new j_seconds         = (((gPlayerData[j][e_end_time] - gPlayerData[j][e_start_time]) % (1000 * 60 * 60)) % (1000 * 60)) / 1000;
                        new j_milliseconds    = (gPlayerData[j][e_end_time] - gPlayerData[j][e_start_time]) % 1000;

                        new string[64];
                        format(string, sizeof(string), "%d\t%s\t%02d:%02d:%03d\n", ranking, GetPlayerNamef(j), j_minutes, j_seconds, j_milliseconds);
                        strcat(output, string);

                        if(ranking == 1)
                        {
                            SetPlayerPoint(j, GetPlayerPoint(j) + 5);
                            SetPlayerDerbyWins(j, GetPlayerDerbyWins(j) + 1);
                        }
                        else if(ranking == 2)
                            SetPlayerPoint(j, GetPlayerPoint(j) + 3);
                        else
                            SetPlayerPoint(j, GetPlayerPoint(j) + 1);
                    }

                    foreach(new i: Player)
                    {
                        if(GetPlayerDerby(i) == derbyid)
                        {
                            ShowPlayerDialog(i, DIALOG_DERBY_LEADERBOARD, DIALOG_STYLE_TABLIST_HEADERS, "Resultados finais", output, "Fechar", "");
                        }
                    }
                    defer EndDerby(derbyid);
                }
            }
        }
    }
}

//------------------------------------------------------------------------------

hook OnPlayerStateChange(playerid, newstate, oldstate)
{
    switch (oldstate)
    {
        case PLAYER_STATE_DRIVER:
        {
            new derbyid = GetPlayerDerby(playerid);
            if(derbyid != INVALID_DERBY_ID && gPlayerData[playerid][e_state] == DERBY_PLAYER_STATE_ALIVE)
            {
                gDerbyData[derbyid][e_derby_leaderboard][gDerbyData[derbyid][e_derby_lcounter]] = playerid;
                gDerbyData[derbyid][e_derby_lcounter]++;
                gPlayerData[playerid][e_end_time] = GetTickCount();
                gPlayerData[playerid][e_state] = DERBY_PLAYER_STATE_SPECTATING;
                TogglePlayerSpectating(playerid, true);

                for(new p = 0, j = GetPlayerPoolSize(); p <= j; p++)
                {
                    if(GetPlayerDerby(p) == derbyid && gPlayerData[p][e_state] == DERBY_PLAYER_STATE_ALIVE)
                    {
                        gPlayerData[playerid][e_spec_targetid] = p;
                        SetPlayerSpecatateTarget(playerid, p);
                    }
                }
            }
        }
    }
    return 1;
}

//------------------------------------------------------------------------------

hook OnPlayerUpdate(playerid)
{
    if(GetPlayerDerby(playerid) != INVALID_DERBY_ID && gPlayerData[playerid][e_state] == DERBY_PLAYER_STATE_SPECTATING)
    {
        if(GetPlayerState(playerid) != PLAYER_STATE_SPECTATING)
        {
            new derbyid = GetPlayerDerby(playerid);
            TogglePlayerSpectating(playerid, true);
            foreach(new i: Player)
            {
                if(GetPlayerDerby(i) == derbyid && gPlayerData[i][e_state] == DERBY_PLAYER_STATE_ALIVE)
                {
                    SetPlayerSpecatateTarget(playerid, i);
                    break;
                }
            }
        }
        else if(gPlayerSpecTick[playerid] < GetTickCount())
        {
            new
                derbyid = GetPlayerDerby(playerid),
                Keys,
                ud,
                lr
            ;
            GetPlayerKeys(playerid, Keys, ud, lr);
            gPlayerSpecTick[playerid] = GetTickCount() + 50;
            if(lr == KEY_LEFT)
            {
                for(new i = GetPlayerPoolSize(), j = 0; i > j; i--)
                {
                    if(GetPlayerDerby(i) == derbyid && gPlayerData[i][e_state] == DERBY_PLAYER_STATE_ALIVE)
                    {
                        if(gPlayerData[playerid][e_spec_targetid] > i)
                        {
                            gPlayerData[playerid][e_spec_targetid] = i;
                            SetPlayerSpecatateTarget(playerid, i);
                        }
                    }
                }
            }
            else if(lr == KEY_RIGHT)
            {
                foreach(new i: Player)
                {
                    if(GetPlayerDerby(i) == derbyid && gPlayerData[i][e_state] == DERBY_PLAYER_STATE_ALIVE)
                    {
                        if(gPlayerData[playerid][e_spec_targetid] < i)
                        {
                            gPlayerData[playerid][e_spec_targetid] = i;
                            SetPlayerSpecatateTarget(playerid, i);
                        }
                    }
                }
            }
        }
    }
    return 1;
}

//------------------------------------------------------------------------------

timer EndDerby[7500](derbyid)
{
    // Reseta todas as variaveis e envia o jogadores para o lobby do derby

    gDerbyData[derbyid][e_derby_state] = DERBY_STATE_WAITING_PLAYERS;
    gDerbyData[derbyid][e_derby_lcounter] = 0;
    for(new i = 0; i < MAX_PLAYERS; i++)
    {
        gDerbyData[derbyid][e_derby_leaderboard][i] = INVALID_PLAYER_ID;
    }

    for(new i = 0; i < MAX_PLAYERS; i++)
    {
        DestroyVehicle(gPlayerData[i][e_vehicle_id]);
        gPlayerData[i][e_vehicle_id] = INVALID_VEHICLE_ID;
    }

    foreach(new i: Player)
    {
        if(GetPlayerDerby(i) == derbyid)
        {
            if(GetPlayerState(i) == PLAYER_STATE_SPECTATING)
            {
                TogglePlayerSpectating(i, false);
                gPlayerData[i][e_spec_targetid] = INVALID_PLAYER_ID;
            }

            gPlayerData[i][e_grid_id] = 0;
            gPlayerData[i][e_state] = DERBY_PLAYER_STATE_NONE;
            gPlayerData[i][e_start_time] = 0;
            gPlayerData[i][e_end_time] = 0;
            OnPlayerEnterDerby(i, derbyid);
        }
    }
}

//------------------------------------------------------------------------------

hook OnGameModeInit()
{
    for(new i = 0; i < MAX_DERBY; i++)
    {
        for(new j = 0; j < MAX_PLAYERS; j++)
        {
            gDerbyData[i][e_derby_leaderboard][j] = INVALID_PLAYER_ID;
        }
    }
    // Dados relacionados ao mapa sumo
    gDerbyData[0][e_derby_vmodel] = 495;
    strcat(gDerbyData[0][e_derby_name], "Ringue de Sumo");
    CreateDynamicObject(13607, 2905.9548339844, -3160.29296875, 104.93536376953, 0, 0, 0, VIRTUAL_WORLD);
	CreateDynamicObject(18450, 2958.955078125, -3215.8120117188, 86.87939453125, 359.58288574219, 20.072540283203, 314.08843994141, VIRTUAL_WORLD);
	CreateDynamicObject(13607, 3007.0251464844, -3267.2795410156, 78.075241088867, 0, 0, 306, VIRTUAL_WORLD);
	CreateDynamicObject(1633, 2931.9726562500, -3195.7143554688, 99.627136230469, 11.920684814453, 0, 43.659301757813, VIRTUAL_WORLD);
	CreateDynamicObject(1633, 2940.1413574219, -3188.4636230469, 99.581954956055, 11.920166015625, 0, 43.654174804688, VIRTUAL_WORLD);
	CreateDynamicObject(1633, 2937.1958007813, -3191.3784179688, 99.564033508301, 11.920166015625, 0, 43.654174804688, VIRTUAL_WORLD);
	CreateDynamicObject(1633, 2934.4245605469, -3193.8444824219, 99.583084106445, 11.920166015625, 0, 43.654174804688, VIRTUAL_WORLD);
	CreateDynamicObject(3864, 2918.4550781250, -3195.91796875, 107.33255767822, 0, 0, 0, VIRTUAL_WORLD);
	CreateDynamicObject(3864, 2904.1618652344, -3198.6179199219, 107.49332427979, 0, 0, 0, VIRTUAL_WORLD);
	CreateDynamicObject(3864, 2891.4709472656, -3195.6599121094, 107.49332427979, 0, 0, 0, VIRTUAL_WORLD);
	CreateDynamicObject(3864, 2882.2456054688, -3190.8923339844, 107.49332427979, 0, 0, 0, VIRTUAL_WORLD);
	CreateDynamicObject(3864, 2873.7077636719, -3181.337890625, 107.49332427979, 0, 0, 0, VIRTUAL_WORLD);
	CreateDynamicObject(3864, 2869.1154785156, -3168.7836914063, 107.49332427979, 0, 0, 0, VIRTUAL_WORLD);
	CreateDynamicObject(3864, 2868.7441406250, -3155.3662109375, 107.49332427979, 0, 0, 0, VIRTUAL_WORLD);
	CreateDynamicObject(3864, 2871.6098632813, -3144.1569824219, 107.49332427979, 0, 0, 0, VIRTUAL_WORLD);
	CreateDynamicObject(3864, 2879.5402832031, -3132.4753417969, 107.49332427979, 0, 0, 0, VIRTUAL_WORLD);
	CreateDynamicObject(3864, 2893.7329101563, -3124.2341308594, 107.49332427979, 0, 0, 0, VIRTUAL_WORLD);
	CreateDynamicObject(3864, 2908.5739746094, -3122.6245117188, 107.49332427979, 0, 0, 0, VIRTUAL_WORLD);
	CreateDynamicObject(3864, 2923.6279296875, -3127.2817382813, 107.49332427979, 0, 0, 0, VIRTUAL_WORLD);
	CreateDynamicObject(3864, 2936.5686035156, -3137.7502441406, 107.49332427979, 0, 0, 0, VIRTUAL_WORLD);
	CreateDynamicObject(3864, 2941.8908691406, -3148.3449707031, 107.49332427979, 0, 0, 0, VIRTUAL_WORLD);
	CreateDynamicObject(3864, 2944.1440429688, -3162.4973144531, 107.5002746582, 0, 0, 0, VIRTUAL_WORLD);
	CreateDynamicObject(3864, 2940.5539550781, -3177.8244628906, 107.49332427979, 0, 0, 0, VIRTUAL_WORLD);
    return 1;
}

//------------------------------------------------------------------------------

hook OnPlayerDisconnect(playerid, reason)
{
    gIsDialogShown[playerid] = false;
    ResetPlayerDerbyData(playerid);
    return 1;
}

//------------------------------------------------------------------------------

SetPlayerDerby(playerid, derbyid)
{
    gPlayerCurrentDerby[playerid] = derbyid;
}

GetPlayerDerby(playerid)
{
    return gPlayerCurrentDerby[playerid];
}

GetDerbyMaxPlayers()
{
    return sizeof(gPlayerSpawns[]);
}

GetDerbyPlayerPoolSize(derbyid)
{
    new count = 0;
    foreach(new i: Player)
    {
        if(GetPlayerDerby(i) == derbyid)
        {
            count++;
        }
    }
    return count;
}

//------------------------------------------------------------------------------

ResetPlayerDerbyData(playerid)
{
    if(GetPlayerState(playerid) == PLAYER_STATE_SPECTATING)
        TogglePlayerSpectating(playerid, false);

    new derbyid = GetPlayerDerby(playerid);
    SetPlayerDerby(playerid, INVALID_DERBY_ID);
    gPlayerData[playerid][e_grid_id] = 0;
    gPlayerData[playerid][e_state] = DERBY_PLAYER_STATE_NONE;
    gPlayerData[playerid][e_start_time] = 0;
    gPlayerData[playerid][e_end_time] = 0;
    if(derbyid != INVALID_DERBY_ID)
    {
        if(gDerbyData[derbyid][e_derby_state] == DERBY_STATE_STARTED)
        {
            DestroyVehicle(gPlayerData[playerid][e_vehicle_id]);
            gPlayerData[playerid][e_vehicle_id] = INVALID_VEHICLE_ID;

            new remaining_players = 0;
            foreach(new i: Player)
            {
                if(GetPlayerDerby(i) == derbyid && gPlayerData[i][e_state] == DERBY_PLAYER_STATE_ALIVE)
                {
                    remaining_players++;
                }
            }

            if(remaining_players < 2)
            {
                gDerbyData[derbyid][e_derby_state] = DERBY_STATE_ENDING;

                foreach(new i: Player)
                {
                    if(GetPlayerDerby(i) == derbyid && gPlayerData[i][e_state] == DERBY_PLAYER_STATE_ALIVE)
                    {
                        gPlayerData[i][e_end_time] = GetTickCount();
                        gDerbyData[derbyid][e_derby_leaderboard][gDerbyData[derbyid][e_derby_lcounter]] = i;
                        gDerbyData[derbyid][e_derby_lcounter]++;
                    }
                }

                new output[512];
                strcat(output, "#\tJogador\tTempo\n");
                new ranking = 0;
                for(new i = (gDerbyData[derbyid][e_derby_lcounter] - 1); i > -1; i--)
                {
                    ranking++;
                    new j = gDerbyData[derbyid][e_derby_leaderboard][i];

                    if(j == INVALID_PLAYER_ID)
                        continue;

                    new j_minutes         = (gPlayerData[j][e_end_time] - gPlayerData[j][e_start_time]) / 60000;
                    new j_seconds         = (((gPlayerData[j][e_end_time] - gPlayerData[j][e_start_time]) % (1000 * 60 * 60)) % (1000 * 60)) / 1000;
                    new j_milliseconds    = (gPlayerData[j][e_end_time] - gPlayerData[j][e_start_time]) % 1000;

                    new string[64];
                    format(string, sizeof(string), "%d\t%s\t%02d:%02d:%03d\n", ranking, GetPlayerNamef(j), j_minutes, j_seconds, j_milliseconds);
                    strcat(output, string);

                    if(ranking == 1)
                    {
                        SetPlayerPoint(j, GetPlayerPoint(j) + 5);
                        SetPlayerDerbyWins(j, GetPlayerDerbyWins(j) + 1);
                    }
                    else if(ranking == 2)
                        SetPlayerPoint(j, GetPlayerPoint(j) + 3);
                    else
                        SetPlayerPoint(j, GetPlayerPoint(j) + 1);
                }

                foreach(new i: Player)
                {
                    if(GetPlayerDerby(i) == derbyid)
                    {
                        ShowPlayerDialog(i, DIALOG_DERBY_LEADERBOARD, DIALOG_STYLE_TABLIST_HEADERS, "Resultados finais", output, "Fechar", "");
                    }
                }
                defer EndDerby(derbyid);
            }
        }
    }
}

//------------------------------------------------------------------------------

IsDerbyDialogVisible(playerid)
{
    return gIsDialogShown[playerid];
}

//------------------------------------------------------------------------------

ShowPlayerDerbyList(playerid)
{
    new output[4096], string[64], status[24];
    strcat(output, "Nome\tJogadores\tStatus\n");
    for(new i = 0; i < MAX_DERBY; i++)
    {
        if(strlen(gDerbyData[i][e_derby_name]) < 1)
            break;

        switch (gDerbyData[i][e_derby_state])
        {
            case DERBY_STATE_WAITING_PLAYERS:
                status = "Aguardando jogadores";
            case DERBY_STATE_STARTING:
                status = "Prestes a iniciar";
            case DERBY_STATE_STARTED:
                status = "Em andamento";
            case DERBY_STATE_ENDING:
                status = "Encerrando";
        }
        format(string, sizeof(string), "%s\t%d / %d\t%s\n", gDerbyData[i][e_derby_name], GetDerbyPlayerPoolSize(i), GetDerbyMaxPlayers(), status);
        strcat(output, string);
    }
    gIsDialogShown[playerid] = true;
    ShowPlayerDialog(playerid, DIALOG_DERBY, DIALOG_STYLE_TABLIST_HEADERS, "Derby", output, "Selecionar", "Voltar");
}
