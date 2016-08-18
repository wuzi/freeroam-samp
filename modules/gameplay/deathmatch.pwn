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

#define MAX_DEATHMATCHES                                            64
#define MAX_DEATHMATCH_PLAYERS                                      30

//------------------------------------------------------------------------------

forward OnDeathmatchLoad();
forward OnDeathMatchDelete(playerid, dmid);
forward OnDeathmatchSpawnLoad(dmid);
forward OnDeathmatchExport(playerid);
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
    e_dm_points,
    e_dm_prize[MAX_DEATHMATCH_PLAYERS],
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
    DM_STATE_STARTED,
    DM_STATE_ENDING
}

enum
{
    DM_PLAYER_STATE_NONE,
    DM_PLAYER_STATE_PLAYING,
    DM_PLAYER_STATE_SPECTATING
}

enum
{
    E_PLAYER_CREATING_NONE,
    E_PLAYER_CREATING_DM,
    E_PLAYER_CREATING_DM_SPAWN
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

static gIsPlayerCreatingDM[MAX_PLAYERS];

enum e_spawn_data
{
    Float:e_spawn_x,
    Float:e_spawn_y,
    Float:e_spawn_z,
    Float:e_spawn_a
}
static gPlayerSpawns[MAX_PLAYERS][MAX_DEATHMATCH_PLAYERS][e_spawn_data];
static gPlayerDeathName[MAX_PLAYERS][MAX_DEATHMATCH_NAME];
static gPlayerWeapons[MAX_PLAYERS][4];
static gPlayerCurrentWeapon[MAX_PLAYERS];
static gPlayerCurrentSpawn[MAX_PLAYERS];
static gPlayerCurrentPrize[MAX_PLAYERS];
static gPlayerPoints[MAX_PLAYERS];
static gPlayerPrizes[MAX_PLAYERS][MAX_DEATHMATCH_PLAYERS];

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
        if(i == MAX_DEATHMATCHES)
        {
            print("[error] Trying to load more deathmatches than defined in MAX_DEATHMATCHES.");
            break;
        }

        gDeathmatchData[i][e_dm_db_id] = cache_get_field_content_int(i, "id", gMySQL);
        gDeathmatchData[i][e_dm_interior]  = cache_get_field_content_int(i, "interior", gMySQL);
        gDeathmatchData[i][e_dm_points] = cache_get_field_content_int(i, "points", gMySQL);
        cache_get_field_content(i, "name", gDeathmatchData[i][e_dm_name], gMySQL, MAX_DEATHMATCH_NAME);

        new query[68];
        mysql_format(gMySQL, query, sizeof(query), "SELECT * FROM deathmatch_spawns WHERE deathmatch_id = %d", gDeathmatchData[i][e_dm_db_id]);
        mysql_tquery(gMySQL, query, "OnDeathmatchSpawnLoad", "i", i);
        mysql_format(gMySQL, query, sizeof(query), "SELECT * FROM deathmatch_weapons WHERE deathmatch_id = %d", gDeathmatchData[i][e_dm_db_id]);
        mysql_tquery(gMySQL, query, "OnDeathmatchWeaponsLoad", "i", i);
    }
}

//------------------------------------------------------------------------------

public OnDeathMatchDelete(playerid, dmid)
{
    if(cache_affected_rows() > 0)
    {
        PlaySelectSound(playerid);
        SendClientMessage(playerid, COLOR_SUCCESS, "* Mapa deletado com sucesso, ele ainda estará disponível para jogar até o servidor reiniciar.");
    }
    else
    {
        PlayErrorSound(playerid);
        SendClientMessage(playerid, COLOR_ERROR, "* Este mapa já foi deletado.");
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
        gDeathmatchData[dmid][e_dm_prize][i] = cache_get_field_content_int(i, "prize", gMySQL);
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

public OnDeathmatchExport(playerid)
{
    new dmid = cache_insert_id();

	new query[138];
	for(new i = 0; i < gPlayerCurrentSpawn[playerid]; i++)
	{
	    mysql_format(gMySQL, query, sizeof(query), "INSERT INTO deathmatch_spawns (deathmatch_id, x, y, z, a, prize) VALUES (%d, %.2f, %.2f, %.2f, %.2f, %d)",
		dmid, gPlayerSpawns[playerid][i][e_spawn_x], gPlayerSpawns[playerid][i][e_spawn_y], gPlayerSpawns[playerid][i][e_spawn_z], gPlayerSpawns[playerid][i][e_spawn_a], gPlayerPrizes[playerid][i]);
	    mysql_tquery(gMySQL, query);
	}

	for(new i = 0; i < sizeof(gPlayerWeapons[]); i++)
	{
        if(!gPlayerWeapons[playerid][i])
            continue;

	    mysql_format(gMySQL, query, sizeof(query), "INSERT INTO deathmatch_weapons (deathmatch_id, weaponid) VALUES (%d, %d)",
		dmid, gPlayerWeapons[playerid][i]);
	    mysql_tquery(gMySQL, query);
	}

	PlayBuySound(playerid);
	SendClientMessage(playerid, COLOR_SUCCESS, "* Deathmatch criado com sucesso.");

    // Carregando o mapa criado
    new bool:found = false;
    for(new i = 0; i < MAX_DEATHMATCHES; i++)
    {
        if(gDeathmatchData[i][e_dm_db_id])
            continue;

        found = true;
        gDeathmatchData[i][e_dm_db_id]      = dmid;
        gDeathmatchData[i][e_dm_points]     = gPlayerPoints[playerid];
        gDeathmatchData[i][e_dm_interior]   = GetPlayerInterior(playerid);
        format(gDeathmatchData[i][e_dm_name], MAX_DEATHMATCH_NAME, "%s", gPlayerDeathName[playerid]);

        for(new j = 0; j < gPlayerCurrentSpawn[playerid]; j++)
    	{
            gDeathmatchData[i][e_dm_prize][j]   = gPlayerPrizes[playerid][j];
            gDeathmatchData[i][e_dm_spawn_x][j] = gPlayerSpawns[playerid][j][e_spawn_x];
            gDeathmatchData[i][e_dm_spawn_x][j] = gPlayerSpawns[playerid][j][e_spawn_y];
            gDeathmatchData[i][e_dm_spawn_x][j] = gPlayerSpawns[playerid][j][e_spawn_z];
            gDeathmatchData[i][e_dm_spawn_x][j] = gPlayerSpawns[playerid][j][e_spawn_a];
    	}

        for(new j = 0; j < sizeof(gPlayerWeapons[]); j++)
    	{
            if(!gPlayerWeapons[playerid][j])
                continue;

            gDeathmatchData[i][e_dm_weapon][j] = gPlayerWeapons[playerid][j];
    	}
        break;
    }

    if(!found)
        SendClientMessage(playerid, COLOR_ERROR, "* O deathmatch não pôde ser carregado por ter atingido o limite de deathmatch.");


	// Limpando dados temporários
    gIsPlayerCreatingDM[playerid] = E_PLAYER_CREATING_NONE;
    gPlayerCurrentWeapon[playerid] = 0;
    gPlayerCurrentSpawn[playerid] = 0;
    gPlayerCurrentPrize[playerid] = 0;
    gPlayerPoints[playerid] = 0;

	// Escrevendo no server_log
    new playerName[MAX_PLAYER_NAME];
    GetPlayerName(playerid, playerName, sizeof(playerName));
	printf("[mysql] new deathmatch inserted on database. ID: %d, by: %s", dmid, playerName);
	return 1;
}

//------------------------------------------------------------------------------

hook OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
    switch (dialogid)
    {
        case DIALOG_DEATHMATCH:
        {
            if(!response || !gDeathmatchData[listitem][e_dm_db_id])
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
        case DIALOG_DEATHMATCH_DELETE:
        {
            if(!response || !gDeathmatchData[listitem][e_dm_db_id])
            {
                PlayCancelSound(playerid);
            }
            else
            {
                new query[64];
                mysql_format(gMySQL, query, sizeof(query), "DELETE FROM `deathmatches` WHERE `deathmatches`.`id` = %d", gDeathmatchData[listitem][e_dm_db_id]);
                mysql_tquery(gMySQL, query, "OnDeathMatchDelete", "ii", playerid, gDeathmatchData[listitem][e_dm_db_id]);
            }
            gIsDialogShown[playerid] = false;
        }
        case DIALOG_DM_CREATOR:
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
                    {
                        PlaySelectSound(playerid);
						gIsPlayerCreatingDM[playerid] = E_PLAYER_CREATING_DM_SPAWN;
						SendClientMessage(playerid, COLOR_INFO, " ");
						SendClientMessage(playerid, 0x35CEFBFF, "* Você está criando spawns.");
						SendClientMessage(playerid, COLOR_SUCCESS, "* Pressione Y para colocar um spawn em sua posição, N para apagar o último spawn criado e H para abrir o dialog.");
                    }
                    case 1:
                    {
                        PlaySelectSound(playerid);
						gIsPlayerCreatingDM[playerid] = E_PLAYER_CREATING_DM;

						new output[132], bool:found = false;
						for(new i = 0; i < MAX_RACE_PLAYERS; i++)
						{
							if(gPlayerSpawns[playerid][i][e_spawn_x] != 0.0)
							{
								found = true;
								new string[32];
								format(string, sizeof(string), "%dº posição\n", i + 1);
								strcat(output, string);
							}
						}

						if(found)
						{
							ShowPlayerDialog(playerid, DIALOG_DM_CREATOR_PRIZE, DIALOG_STYLE_LIST, "Premiações", output, "Selecionar", "Voltar");
						}
						else
						{
							PlayErrorSound(playerid);
							SendClientMessage(playerid, COLOR_ERROR, "* Você ainda não criou spawns ainda.");
							ShowPlayerDeathmatchDialog(playerid);
						}
                    }
                    case 2:
                    {
                        PlaySelectSound(playerid);
                        gIsPlayerCreatingDM[playerid] = E_PLAYER_CREATING_DM;

                        new output[132];
						for(new i = 0; i < sizeof(gPlayerWeapons[]); i++)
						{
							new string[32];
							format(string, sizeof(string), "Slot %d\n", i + 1);
							strcat(output, string);
						}

						ShowPlayerDialog(playerid, DIALOG_DM_CREATOR_WEAPON, DIALOG_STYLE_LIST, "Armas", output, "Selecionar", "Voltar");
                    }
                    case 3:
                    {
                        PlaySelectSound(playerid);
                        ShowPlayerDialog(playerid, DIALOG_DM_CREATOR_CONFIG, DIALOG_STYLE_LIST, "Configurações", "Nome\nPontuação", "Selecionar", "Voltar");
                    }
                    case 4:
                    {
                        if(!gPlayerPoints[playerid])
                        {
                            PlayErrorSound(playerid);
                            SendClientMessage(playerid, COLOR_ERROR, "* Você não definiu a pontuação para vencer a partida.");
                            ShowPlayerDeathmatchDialog(playerid);
                        }
                        else if(gPlayerCurrentSpawn[playerid] < MINIMUM_PLAYERS_TO_START_DM)
                        {
                            PlayErrorSound(playerid);
                            SendClientMessage(playerid, COLOR_ERROR, "* Você não definiu posições de spawn suficientes.");
                            ShowPlayerDeathmatchDialog(playerid);
                        }
                        else
                        {
                            new query[200];
                            mysql_format(gMySQL, query, sizeof(query), "INSERT INTO deathmatches (user_id, name, interior, points, created_at) VALUES (%d, '%e', %d, %d, now())", GetPlayerDatabaseID(playerid), gPlayerDeathName[playerid], GetPlayerInterior(playerid), gPlayerPoints[playerid]);
                            mysql_tquery(gMySQL, query, "OnDeathmatchExport", "i", playerid);
                        }
                    }
                    case 5:
                    {
                        PlayCancelSound(playerid);
                        gIsPlayerCreatingDM[playerid] = E_PLAYER_CREATING_NONE;
                        gPlayerCurrentWeapon[playerid] = 0;
                        gPlayerCurrentSpawn[playerid] = 0;
                        gPlayerCurrentPrize[playerid] = 0;
                        gPlayerPoints[playerid] = 0;
                        SendClientMessage(playerid, 0x35CEFBFF, "* Você cancelou a criação da corrida.");
                    }
                }
            }
        }
        case DIALOG_DM_CREATOR_PRIZE:
		{
			if(!response)
			{
				PlayCancelSound(playerid);
				ShowPlayerDeathmatchDialog(playerid);
			}
			else
			{
				new caption[32];
				format(caption, sizeof(caption), "Premiação: %dº colocado", listitem + 1);
				ShowPlayerDialog(playerid, DIALOG_DM_PRIZE_VALUE, DIALOG_STYLE_INPUT, caption, "Informe o valor do premio:", "Salvar", "Voltar");
				gPlayerCurrentPrize[playerid] = listitem;
			}
		}
		case DIALOG_DM_PRIZE_VALUE:
		{
			if(!response)
			{
				PlayCancelSound(playerid);
                ShowPlayerDeathmatchDialog(playerid);
			}
			else
			{
				new prize;
				if(sscanf(inputtext, "i", prize))
				{
					PlayErrorSound(playerid);
					SendClientMessage(playerid, COLOR_ERROR, "* Valor inválido.");

					new caption[32];
					format(caption, sizeof(caption), "Premiação: %dº colocado", gPlayerCurrentPrize[playerid] + 1);
					ShowPlayerDialog(playerid, DIALOG_DM_PRIZE_VALUE, DIALOG_STYLE_INPUT, caption, "Informe o valor do premio:", "Salvar", "Voltar");
					return 1;
				}
				else
				{
					PlaySelectSound(playerid);
					SendClientMessagef(playerid, 0x35CEFBFF, "* Você definiu o premio da %dº colocação como $%d.", gPlayerCurrentPrize[playerid] + 1, prize);
					gPlayerPrizes[playerid][gPlayerCurrentPrize[playerid]] = prize;
				}
			}
			new output[132];
			for(new i = 0; i < MAX_RACE_PLAYERS; i++)
			{
				if(gPlayerSpawns[playerid][i][e_spawn_x] != 0.0)
				{
					new string[32];
					format(string, sizeof(string), "%dº posição\n", i + 1);
					strcat(output, string);
				}
			}
			ShowPlayerDialog(playerid, DIALOG_DM_CREATOR_PRIZE, DIALOG_STYLE_LIST, "Premiações", output, "Selecionar", "Voltar");
		}
        case DIALOG_DM_CREATOR_WEAPON:
        {
            if(!response)
			{
				PlayCancelSound(playerid);
                ShowPlayerDeathmatchDialog(playerid);
			}
			else
			{
                gPlayerCurrentWeapon[playerid] = listitem;
                ShowPlayerDialog(playerid, DIALOG_DM_CREATOR_WEAPON_ID, DIALOG_STYLE_INPUT, "Armas", "Digite o ID da arma", "Salvar", "Voltar");
            }
        }
        case DIALOG_DM_CREATOR_WEAPON_ID:
        {
            if(!response)
			{
				PlayCancelSound(playerid);
                ShowPlayerDeathmatchDialog(playerid);
			}
			else
			{
                new weaponid;
				if(sscanf(inputtext, "i", weaponid))
				{
					PlayErrorSound(playerid);
					SendClientMessage(playerid, COLOR_ERROR, "* Valor inválido.");
					ShowPlayerDialog(playerid, DIALOG_DM_CREATOR_WEAPON_ID, DIALOG_STYLE_INPUT, "Armas", "Digite o ID da arma", "Salvar", "Voltar");
				}
                else if(weaponid < 0 || weaponid > 46)
				{
					PlayErrorSound(playerid);
					SendClientMessage(playerid, COLOR_ERROR, "* Valor inválido.");
					ShowPlayerDialog(playerid, DIALOG_DM_CREATOR_WEAPON_ID, DIALOG_STYLE_INPUT, "Armas", "Digite o ID da arma", "Salvar", "Voltar");
				}
				else
				{
                    new weaponname[32];
                    GetWeaponName(weaponid, weaponname, sizeof(weaponname));
					SendClientMessagef(playerid, 0x35CEFBFF, "* Você definiu a arma slot %d como %s.", gPlayerCurrentWeapon[playerid] + 1, weaponname);
					gPlayerWeapons[playerid][gPlayerCurrentWeapon[playerid]] = weaponid;

                    new output[132];
                    for(new i = 0; i < sizeof(gPlayerWeapons[]); i++)
                    {
                        new string[32];
                        format(string, sizeof(string), "slot %d\n", i + 1);
                        strcat(output, string);
                    }

                    ShowPlayerDialog(playerid, DIALOG_DM_CREATOR_WEAPON, DIALOG_STYLE_LIST, "Armas", output, "Selecionar", "Voltar");
				}
            }
        }
        case DIALOG_DM_CREATOR_CONFIG:
        {
            if(!response)
			{
				PlayCancelSound(playerid);
                ShowPlayerDeathmatchDialog(playerid);
			}
			else
			{
                switch (listitem)
                {
                    case 0:
                    {
                        ShowPlayerDialog(playerid, DIALOG_DM_CRT_CONFIG_NAME, DIALOG_STYLE_INPUT, "Nome do deathmatch", "Insira o nome deste mapa", "Salvar", "Voltar");
                    }
                    case 1:
                    {
                        new output[128], string[4];
                        for(new i = 10; i < 101; i++)
                        {
                            format(string, sizeof(string), "%d\n", i);
                            strcat(output, string);
                        }
                        ShowPlayerDialog(playerid, DIALOG_DM_CRT_CONFIG_POINTS, DIALOG_STYLE_LIST, "Pontuação para vencer o deathmatch", output, "Salvar", "Voltar");
                    }
                }
                PlaySelectSound(playerid);
            }
        }
        case DIALOG_DM_CRT_CONFIG_NAME:
        {
            if(!response)
			{
				PlayCancelSound(playerid);
			}
			else
			{
				new name[MAX_DEATHMATCH_NAME];
				if(sscanf(inputtext, "s[" #MAX_RACE_NAME "]", name))
				{
					PlayErrorSound(playerid);
					SendClientMessage(playerid, COLOR_ERROR, "* Nome inválido inválido.");
					ShowPlayerDialog(playerid, DIALOG_DM_CRT_CONFIG_NAME, DIALOG_STYLE_INPUT, "Nome do deathmatch", "Insira o nome deste mapa", "Salvar", "Voltar");
					return 1;
				}
				else
				{
					PlaySelectSound(playerid);
					SendClientMessagef(playerid, 0x35CEFBFF, "* Você definiu o nome do deathmatch: %s.", name);
					format(gPlayerDeathName[playerid], MAX_DEATHMATCH_NAME, "%s", name);
				}
			}
            ShowPlayerDialog(playerid, DIALOG_DM_CREATOR_CONFIG, DIALOG_STYLE_LIST, "Configurações", "Nome\nPontuação", "Selecionar", "Voltar");
        }
        case DIALOG_DM_CRT_CONFIG_POINTS:
        {
            if(!response)
			{
				PlayCancelSound(playerid);
			}
			else
			{

                PlaySelectSound(playerid);
				gPlayerPoints[playerid] = listitem + 10;
                SendClientMessagef(playerid, COLOR_SUCCESS, "* Você definiu a pontuação para vencer o death para %d.", gPlayerPoints[playerid]);
			}
            ShowPlayerDialog(playerid, DIALOG_DM_CREATOR_CONFIG, DIALOG_STYLE_LIST, "Configurações", "Nome\nPontuação", "Selecionar", "Voltar");
        }
    }
    return 1;
}

//------------------------------------------------------------------------------

public OnPlayerEnterDeathmatch(playerid, dmid)
{
    if(GetPlayerGamemode(playerid) == GAMEMODE_DERBY)
    {
        ResetPlayerDerbyData(playerid);
    }
    else if(GetPlayerGamemode(playerid) == GAMEMODE_RACE)
    {
        ResetPlayerRaceData(playerid);
        DisableRemoteVehicleCollisions(playerid, false);
    }

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

    gIsPlayerCreatingDM[playerid] = E_PLAYER_CREATING_NONE;
    gPlayerCurrentWeapon[playerid] = 0;
    gPlayerCurrentSpawn[playerid] = 0;
    gPlayerCurrentPrize[playerid] = 0;
    gPlayerPoints[playerid] = 0;
    return 1;
}

//------------------------------------------------------------------------------

hook OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if(newkeys & KEY_YES)
    {
		switch (gIsPlayerCreatingDM[playerid])
		{
			case E_PLAYER_CREATING_DM_SPAWN:
			{
				if(gPlayerCurrentSpawn[playerid] < MAX_DEATHMATCH_PLAYERS)
				{
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

					gPlayerSpawns[playerid][gPlayerCurrentSpawn[playerid]][e_spawn_x] = x;
					gPlayerSpawns[playerid][gPlayerCurrentSpawn[playerid]][e_spawn_y] = y;
					gPlayerSpawns[playerid][gPlayerCurrentSpawn[playerid]][e_spawn_z] = z;
					gPlayerSpawns[playerid][gPlayerCurrentSpawn[playerid]][e_spawn_a] = a;
					gPlayerCurrentSpawn[playerid]++;

					PlaySelectSound(playerid);
					SendClientMessagef(playerid, 0x35CEFBFF, "* Você criou o %dº spawn nas coordenadas %f, %f, %f.", gPlayerCurrentSpawn[playerid], x, y, z);
				}
				else
				{
					PlayErrorSound(playerid);
					SendClientMessage(playerid, COLOR_ERROR, "* Você atingiu o limite máximo de jogadores por deathmatch.");
				}
			}
		}
    }
	else if(newkeys & KEY_NO)
    {
		switch (gIsPlayerCreatingDM[playerid])
		{
			case E_PLAYER_CREATING_CHECKPOINT:
			{
				if(gPlayerCurrentSpawn[playerid] > 0)
				{
					new Float:x, Float:y, Float:z;
					gPlayerCurrentSpawn[playerid]--;
					x = gPlayerSpawns[playerid][gPlayerCurrentSpawn[playerid]][e_spawn_x];
					y = gPlayerSpawns[playerid][gPlayerCurrentSpawn[playerid]][e_spawn_y];
					z = gPlayerSpawns[playerid][gPlayerCurrentSpawn[playerid]][e_spawn_z];

					PlayCancelSound(playerid);
					SendClientMessagef(playerid, 0x35CEFBFF, "* Você deletou o %dº spawn das coordenadas %f, %f, %f.", gPlayerCurrentSpawn[playerid] + 1, x, y, z);
				}
			}
		}
    }
	else if(((newkeys & KEY_CROUCH) && IsPlayerInAnyVehicle(playerid)) || ((newkeys & KEY_CTRL_BACK) && !IsPlayerInAnyVehicle(playerid)))
    {
		if (gIsPlayerCreatingDM[playerid] > E_PLAYER_RACE_STATE_NONE)
		{
			PlaySelectSound(playerid);
			ShowPlayerDeathmatchDialog(playerid);
		}
    }
    return 1;
}

//------------------------------------------------------------------------------

hook OnPlayerSpawn(playerid)
{
    if(GetPlayerDeathmatch(playerid) != INVALID_DEATHMATCH_ID && GetPlayerGamemode(playerid) == GAMEMODE_DEATHMATCH)
    {
        new dmid = GetPlayerDeathmatch(playerid);
        new count = 0;
        for(new i = 0; i < MAX_DEATHMATCH_PLAYERS; i++)
        {
            if(gDeathmatchData[dmid][e_dm_spawn_x][i] != 0.0)
                count++;
        }
        new spawn_id = random(count);
        SetPlayerInterior(playerid, gDeathmatchData[dmid][e_dm_interior]);
        SetPlayerPos(playerid, gDeathmatchData[dmid][e_dm_spawn_x][spawn_id], gDeathmatchData[dmid][e_dm_spawn_y][spawn_id], gDeathmatchData[dmid][e_dm_spawn_z][spawn_id]);
        SetPlayerFacingAngle(playerid, gDeathmatchData[dmid][e_dm_spawn_a][spawn_id]);
        SetCameraBehindPlayer(playerid);

        for(new j = 0; j < 11; j++)
        {
            if(gDeathmatchData[dmid][e_dm_state] == DM_STATE_STARTED)
                GivePlayerWeapon(playerid, gDeathmatchData[dmid][e_dm_weapon][j], 99999);
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
            new dmid = GetPlayerDeathmatch(killerid);
            gPlayerData[playerid][e_player_deaths]++;
            gPlayerData[killerid][e_player_kills]++;

            SetPlayerKill(killerid, GetPlayerKill(killerid) + 1);
            SetPlayerDeath(playerid, GetPlayerDeath(playerid) + 1);

            SetPlayerWantedLevel(playerid, 0);
            SetPlayerWantedLevel(killerid, GetPlayerWantedLevel(killerid) + 1);

            new leaderid = INVALID_PLAYER_ID, leader_points = 0;
            foreach(new i: Player)
            {
                if(GetPlayerDeathmatch(i) == dmid)
                {
                    if(gPlayerData[i][e_player_kills] >= leader_points)
                    {
                        leaderid = i;
                        leader_points = gPlayerData[i][e_player_kills];
                    }
                }
            }

            UpdatePlayerDeathmatchHud(playerid, gPlayerData[playerid][e_player_kills], gPlayerData[playerid][e_player_deaths], leaderid, leader_points, gDeathmatchData[dmid][e_dm_points]);
            UpdatePlayerDeathmatchHud(killerid, gPlayerData[killerid][e_player_kills], gPlayerData[killerid][e_player_deaths], leaderid, leader_points, gDeathmatchData[dmid][e_dm_points]);

            if(gPlayerData[killerid][e_player_kills] == gDeathmatchData[dmid][e_dm_points])
            {
                new output[4096], string[128], leaderboard[MAX_PLAYERS], count;
                strcat(output, "#\tJogador\tK/D\n");
                gDeathmatchData[dmid][e_dm_state] = DM_STATE_ENDING;
                SortArrayUsingComparator(gPlayerData, CompareKills, SORT_IS_PLAYERS) => leaderboard;
                for (new i = 0; i < sizeof(leaderboard); i++)
                {
                    new pid = leaderboard[i];

                    if (pid == INVALID_PLAYER_ID)
                        break;

                    if (!IsPlayerLogged(pid) || GetPlayerDeathmatch(pid) != dmid)
                        continue;

                    GivePlayerCash(pid, gDeathmatchData[dmid][e_dm_prize][count]);

                    if(i == 0)
                    {
                        SetPlayerPoint(pid, GetPlayerPoint(pid) + 5);
                        SetPlayerDeathmatchWins(playerid, GetPlayerDeathmatchWins(playerid) + 1);
                    }
                    else if(i == 1)
                        SetPlayerPoint(pid, GetPlayerPoint(pid) + 3);
                    else
                        SetPlayerPoint(pid, GetPlayerPoint(pid) + 1);

                    count++;
                    format(string, sizeof(string), "%i\t%s\t%d/%d\n", count, GetPlayerNamef(pid), gPlayerData[pid][e_player_kills], gPlayerData[pid][e_player_deaths]);
                    strcat(output, string);
                }

                foreach(new i: Player)
                {
                    if(GetPlayerDeathmatch(i) == dmid)
                    {
                        ResetPlayerWeapons(i);
                        ShowPlayerDialog(i, DIALOG_DEATHMATCH_LEADERBOARD, DIALOG_STYLE_TABLIST_HEADERS, "Resultados finais", output, "Fechar", "");
                    }
                }

                defer EndDeathmatch(dmid);
            }
        }
    }
    else if(killerid == INVALID_PLAYER_ID && GetPlayerDeathmatch(playerid) != INVALID_DEATHMATCH_ID)
    {
        if(gPlayerData[playerid][e_player_kills] > 0)
            gPlayerData[playerid][e_player_kills]--;

        SetPlayerWantedLevel(playerid, 0);
        SetPlayerDeath(playerid, GetPlayerDeath(playerid) + 1);
    }
    return 1;
}

//------------------------------------------------------------------------------

Comparator:CompareKills(left[e_player_dm_data], right[e_player_dm_data])
{
    return floatcmp(right[e_player_kills], left[e_player_kills]);
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
                new remaining_players = 0;
                gDeathmatchCountdown[dmid]--;
                foreach(new i: Player)
                {
                    if(GetPlayerDeathmatch(i) == dmid)
                    {
                        SetPlayerHealth(i, 100.0);
                        TogglePlayerControllable(i, true);
                        GameTextForPlayer(i, "~g~GO!", 3000, 3);
                        PlayerPlaySound(i, 1057, 0.0, 0.0, 0.0);
                        gPlayerData[i][e_player_start] = GetTickCount();

                        for(new j = 0; j < 11; j++)
                        {
                            GivePlayerWeapon(i, gDeathmatchData[dmid][e_dm_weapon][j], 9999);
                        }

                        if(gPlayerData[i][e_player_state] == DM_PLAYER_STATE_PLAYING)
                        {
                            remaining_players++;
                        }
                        UpdatePlayerDeathmatchHud(i, 0, 0, INVALID_PLAYER_ID, 0, gDeathmatchData[dmid][e_dm_points]);
                        ShowPlayerDeathmatchHud(i);
                    }
                }

                // Verifica se ainda há jogadores
                if(remaining_players < 2)
                {
                    gDeathmatchData[dmid][e_dm_state] = DM_STATE_ENDING;
                    foreach(new i: Player)
                    {
                        if(GetPlayerDeathmatch(i) == dmid)
                        {
                            ShowPlayerDialog(i, DIALOG_DEATHMATCH_LEADERBOARD, DIALOG_STYLE_LIST, "Resultados finais", "Sem jogadores suficientes", "Fechar", "");
                        }
                    }
                    defer EndDeathmatch(dmid);
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
            SetPlayerDeathmatch(i, 0);
            HidePlayerDeathmatchHud(i);
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

    HidePlayerDeathmatchHud(playerid);
    new dmid = GetPlayerDeathmatch(playerid);
    SetPlayerDeathmatch(playerid, INVALID_DEATHMATCH_ID);
    SetPlayerWantedLevel(playerid, 0);
    if(dmid != INVALID_DEATHMATCH_ID)
    {
        if(gDeathmatchData[dmid][e_dm_state] == DM_STATE_STARTED)
        {
            // Verifica se ainda há jogadores
            new remaining_players = 0;
            foreach(new i: Player)
            {
                if(GetPlayerDeathmatch(i) == dmid && gPlayerData[i][e_player_state] == DM_PLAYER_STATE_PLAYING)
                {
                    remaining_players++;
                }
            }

            // Se não houver mais jogadores finaliza a partida,
            // Se houver, aguarda a partida finalizar
            if(remaining_players < 2)
            {
                gDeathmatchData[dmid][e_dm_state] = DM_STATE_ENDING;
                foreach(new i: Player)
                {
                    if(GetPlayerDeathmatch(i) == dmid)
                    {
                        ShowPlayerDialog(i, DIALOG_DEATHMATCH_LEADERBOARD, DIALOG_STYLE_LIST, "Resultados finais", "Sem jogadores suficientes", "Fechar", "");
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

        // Se não houver nenhum jogador jogando, reiniciar a partida
        if(GetDmPlayerPoolSize(dmid) == 0)
        {
            EndDeathmatch(dmid);
        }
    }
}

//------------------------------------------------------------------------------

YCMD:criardm(playerid, params[], help)
{
	if(GetPlayerAdminLevel(playerid) >= PLAYER_RANK_SUB_OWNER)
	{
		if(!gIsPlayerCreatingDM[playerid])
		{
            PlaySelectSound(playerid);
			gIsPlayerCreatingDM[playerid] = E_PLAYER_CREATING_DM;
			ShowPlayerDeathmatchDialog(playerid);
		}
		else
		{
			SendClientMessage(playerid, COLOR_ERROR, "* Você já está criando um dm.");
		}
	}
	else
	{
		SendClientMessage(playerid, COLOR_ERROR, "* Você não tem permissão.");
	}
	return 1;
}

//------------------------------------------------------------------------------

YCMD:deletardm(playerid, params[], help)
{
	if(GetPlayerAdminLevel(playerid) >= PLAYER_RANK_SUB_OWNER)
	{
        ShowPlayerDeathmatchList(playerid, true);
        PlayerPlaySound(playerid, 1055, 0.0, 0.0, 0.0);
        SendClientMessage(playerid, COLOR_WARNING, "* ATENÇÃO: Essa operação NÃO tem volta!");
	}
	else
	{
		SendClientMessage(playerid, COLOR_ERROR, "* Você não tem permissão.");
	}
	return 1;
}

//------------------------------------------------------------------------------

SetPlayerDeathmatch(playerid, dmid)
{
    gPlayerData[playerid][e_player_deathmatch_id] = dmid;
}

//------------------------------------------------------------------------------

GetPlayerDeathmatch(playerid)
{
    if(GetPlayerGamemode(playerid) == GAMEMODE_DEATHMATCH)
    {
        return gPlayerData[playerid][e_player_deathmatch_id];
    }
    return INVALID_DEATHMATCH_ID;
}

//------------------------------------------------------------------------------

GetDmPlayerPoolSize(dmid)
{
    new counter = 0;
    foreach(new i: Player)
    {
        if(GetPlayerDeathmatch(i) == dmid)
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

ShowPlayerDeathmatchList(playerid, bool:delete = false)
{
    new output[4096], string[64], status[24], count = 0;
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
            case DM_STATE_ENDING:
                status = "Encerrando";
        }
        format(string, sizeof(string), "%s\t%d / %d\t%s\n", gDeathmatchData[i][e_dm_name], GetDmPlayerPoolSize(i), GetDmMaxPlayers(i), status);
        strcat(output, string);
        count++;
    }
    gIsDialogShown[playerid] = true;

    if(count)
        ShowPlayerDialog(playerid, (!delete) ? DIALOG_DEATHMATCH : DIALOG_DEATHMATCH_DELETE, DIALOG_STYLE_TABLIST_HEADERS, "Deathmatches", output, "Selecionar", "Voltar");
    else
        ShowPlayerDialog(playerid, (!delete) ? DIALOG_DEATHMATCH : DIALOG_DEATHMATCH_DELETE, DIALOG_STYLE_LIST, "Deathmatches", "Nenhuma sala existente", "Voltar", "");
}

//------------------------------------------------------------------------------

ShowPlayerDeathmatchDialog(playerid)
{
	ShowPlayerDialog(playerid, DIALOG_DM_CREATOR, DIALOG_STYLE_LIST, "Criando um deathmatch", "Spawns\nPremiações\nArmas\nConfigurações\nExportar\nCancelar", "Selecionar", "Sair");
}

//------------------------------------------------------------------------------
