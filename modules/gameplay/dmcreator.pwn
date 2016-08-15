/*******************************************************************************
* NOME DO ARQUIVO :		modules/gameplay/dmcreator.pwn
*
* DESCRIÇÃO :
*	   Permite que administradores criem deathmatch.
*
* NOTAS :
*	   -
*/

#include <YSI\y_hooks>

//------------------------------------------------------------------------------

enum
{
    E_PLAYER_DM_STATE_NONE,
    E_PLAYER_CREATING_DM,
    E_PLAYER_CREATING_DM_SPAWN
}

//------------------------------------------------------------------------------

static gIsPlayerCreatingDM[MAX_PLAYERS];

//------------------------------------------------------------------------------

enum e_spawn_data
{
    Float:e_spawn_x,
    Float:e_spawn_y,
    Float:e_spawn_z,
    Float:e_spawn_a
}
static gPlayerSpawns[MAX_PLAYERS][MAX_DEATHMATCH_PLAYERS][e_spawn_data];

//------------------------------------------------------------------------------

static gPlayerDeathName[MAX_PLAYERS][MAX_DEATHMATCH_NAME];
static gPlayerWeapons[MAX_PLAYERS][4];
static gPlayerCurrentWeapon[MAX_PLAYERS];
static gPlayerCurrentSpawn[MAX_PLAYERS];
static gPlayerCurrentPrize[MAX_PLAYERS];
static gPlayerPoints[MAX_PLAYERS];
static gPlayerPrizes[MAX_PLAYERS][MAX_DEATHMATCH_PLAYERS];

//------------------------------------------------------------------------------

forward OnDeathmatchExport(playerid);

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

hook OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
    switch (dialogid)
    {
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
                        gIsPlayerCreatingDM[playerid] = E_PLAYER_DM_STATE_NONE;
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
				if(gPlayerSpawns[playerid][i][e_spawn_x] == 0.0)
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
				gPlayerPoints[playerid] = listitem + 10;
			}
            ShowPlayerDialog(playerid, DIALOG_DM_CREATOR_CONFIG, DIALOG_STYLE_LIST, "Configurações", "Nome\nPontuação", "Selecionar", "Voltar");
        }
    }
    return 1;
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

	// Limpando dados temporários
    gIsPlayerCreatingDM[playerid] = E_PLAYER_DM_STATE_NONE;
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

hook OnPlayerDisconnect(playerid, reason)
{
    gIsPlayerCreatingDM[playerid] = E_PLAYER_DM_STATE_NONE;
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

ShowPlayerDeathmatchDialog(playerid)
{
	ShowPlayerDialog(playerid, DIALOG_DM_CREATOR, DIALOG_STYLE_LIST, "Criando um deathmatch", "Spawns\nPremiações\nArmas\nConfigurações\nExportar\nCancelar", "Selecionar", "Sair");
}
