/*******************************************************************************
* NOME DO ARQUIVO :		modules/gameplay/racecreator.pwn
*
* DESCRIÇÃO :
*	   Permite que corridas sejam criadas dentro do servidor.
*
* NOTAS :
*	   -
*/

#include <YSI\y_hooks>

//------------------------------------------------------------------------------

#define MAX_RACE_CHECKPOINTS												64
#define MAX_RACE_PLAYERS													10

//------------------------------------------------------------------------------

enum
{
	E_PLAYER_RACE_STATE_NONE,
	E_PLAYER_CREATING_RACE,
	E_PLAYER_CREATING_CHECKPOINT,
	E_PLAYER_CREATING_GRID
}

//------------------------------------------------------------------------------

static gIsPlayerCreatingRace[MAX_PLAYERS];

enum e_vehicle_data
{
	e_vehicle_id,
	Float:e_vehicle_x,
	Float:e_vehicle_y,
	Float:e_vehicle_z,
	Float:e_vehicle_a
}
static gPlayerVehicles[MAX_PLAYERS][MAX_RACE_PLAYERS][e_vehicle_data];
static gPlayerCurrentVehicle[MAX_PLAYERS];

enum e_checkpoint_data
{
	Float:e_checkpoint_x,
	Float:e_checkpoint_y,
	Float:e_checkpoint_z
}
static gPlayerCheckpoints[MAX_PLAYERS][MAX_RACE_CHECKPOINTS][e_checkpoint_data];
static gPlayerCurrentCheckpoint[MAX_PLAYERS];

static gPlayerRacePrize[MAX_PLAYERS][MAX_RACE_PLAYERS];
static gPlayerCurrentPrize[MAX_PLAYERS];
static Float:gPlayerCheckpointSize[MAX_PLAYERS] = {3.5, ...};
static gPlayerCheckpointType[MAX_PLAYERS] = {1, ...};

//------------------------------------------------------------------------------

forward OnRaceExport(playerid);

//------------------------------------------------------------------------------

YCMD:criarcorrida(playerid, params[], help)
{
	if(GetPlayerAdminLevel(playerid) >= PLAYER_RANK_SUB_OWNER)
	{
		if(!gIsPlayerCreatingRace[playerid])
		{
			gIsPlayerCreatingRace[playerid] = E_PLAYER_CREATING_RACE;
			PlaySelectSound(playerid);
			ShowPlayerRaceDialog(playerid);
		}
		else
		{
			SendClientMessage(playerid, COLOR_ERROR, "* Você já está criando uma corrida.");
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
	switch(dialogid)
	{
		case DIALOG_RACE_CREATOR:
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
						gIsPlayerCreatingRace[playerid] = E_PLAYER_CREATING_CHECKPOINT;
						SendClientMessage(playerid, COLOR_INFO, " ");
						SendClientMessage(playerid, 0x35CEFBFF, "* Você está criando checkpoints.");
						SendClientMessage(playerid, COLOR_SUCCESS, "* Pressione Y para colocar um checkpoint em sua posição, N para apagar o último checkpoint criado e H para abrir o dialog.");
					}
					case 1:
					{
						PlaySelectSound(playerid);
						gIsPlayerCreatingRace[playerid] = E_PLAYER_CREATING_GRID;
						SendClientMessage(playerid, COLOR_INFO, " ");
						SendClientMessage(playerid, 0x35CEFBFF, "* Você está posicionando os veículos.");
						SendClientMessage(playerid, COLOR_SUCCESS, "* Pressione Y para colocar um veículo em sua posição, N para apagar o último veículo criado e H para abrir o dialog.");
					}
					case 2:
					{
						PlaySelectSound(playerid);
						gIsPlayerCreatingRace[playerid] = E_PLAYER_CREATING_RACE;

						new output[132], bool:found = false;
						for(new i = 0; i < MAX_RACE_PLAYERS; i++)
						{
							if(gPlayerVehicles[playerid][i][e_vehicle_id])
							{
								found = true;
								new string[32];
								format(string, sizeof(string), "%dº posição\n", i + 1);
								strcat(output, string);
							}
						}

						if(found)
						{
							ShowPlayerDialog(playerid, DIALOG_RACE_CREATOR_PRIZE, DIALOG_STYLE_LIST, "Premiações", output, "Selecionar", "Voltar");
						}
						else
						{
							PlayErrorSound(playerid);
							SendClientMessage(playerid, COLOR_ERROR, "* Você ainda não criou o grid de largada.");
							ShowPlayerRaceDialog(playerid);
						}
					}
					case 3:
					{
						PlaySelectSound(playerid);
						ShowPlayerDialog(playerid, DIALOG_RACE_CREATOR_CONFIG, DIALOG_STYLE_LIST, "Configurações", "Tipo do checkpoint\nTamanho do checkpoint", "Selecionar", "Voltar");
					}
					case 4:
					{
						if(gPlayerCurrentVehicle[playerid] < 2)
						{
							PlayErrorSound(playerid);
							ShowPlayerRaceDialog(playerid);
							SendClientMessage(playerid, COLOR_ERROR, "* Você precisa criar pelo menos 2 posições no grid para exportar.");
						}
						else if(gPlayerCurrentCheckpoint[playerid] < 1)
						{
							PlayErrorSound(playerid);
							ShowPlayerRaceDialog(playerid);
							SendClientMessage(playerid, COLOR_ERROR, "* Você precisa criar pelo menos 1 checkpoint para exportar.");
						}
						else
						{
							new query[128];
			                mysql_format(gMySQL, query, sizeof(query), "INSERT INTO races (user_id, cp_type, cp_size, created_at) VALUES (%d, %d, %.2f, now())", GetPlayerDatabaseID(playerid), gPlayerCheckpointType[playerid], gPlayerCheckpointSize[playerid]);
			            	mysql_tquery(gMySQL, query, "OnRaceExport", "i", playerid);
						}
					}
					case 5:
					{
						for(new i = 0; i < MAX_RACE_PLAYERS; i++)
						{
							if(gPlayerVehicles[playerid][i][e_vehicle_id])
							{
								DestroyVehicle(gPlayerVehicles[playerid][i][e_vehicle_id]);
								gPlayerVehicles[playerid][i][e_vehicle_id] = 0;
							}
						}
						PlayCancelSound(playerid);
						gPlayerCurrentCheckpoint[playerid] = 0;
						gPlayerCheckpointType[playerid] = 1;
						gPlayerCheckpointSize[playerid] = 3.5;
						gIsPlayerCreatingRace[playerid] = E_PLAYER_RACE_STATE_NONE;
						DisablePlayerRaceCheckpoint(playerid);
						SendClientMessage(playerid, 0x35CEFBFF, "* Você cancelou a criação da corrida.");
					}
				}
			}
		}
		case DIALOG_RACE_CREATOR_PRIZE:
		{
			if(!response)
			{
				PlayCancelSound(playerid);
				ShowPlayerRaceDialog(playerid);
			}
			else
			{
				new caption[32];
				format(caption, sizeof(caption), "Premiação: %dº colocado", listitem + 1);
				ShowPlayerDialog(playerid, DIALOG_RACE_PRIZE_VALUE, DIALOG_STYLE_INPUT, caption, "Informe o valor do premio:", "Salvar", "Voltar");
				gPlayerCurrentPrize[playerid] = listitem;
			}
		}
		case DIALOG_RACE_PRIZE_VALUE:
		{
			if(!response)
			{
				PlayCancelSound(playerid);
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
					ShowPlayerDialog(playerid, DIALOG_RACE_PRIZE_VALUE, DIALOG_STYLE_INPUT, caption, "Informe o valor do premio:", "Salvar", "Voltar");
					return 1;
				}
				else
				{
					PlaySelectSound(playerid);
					SendClientMessagef(playerid, 0x35CEFBFF, "* Você definiu o premio da %dº colocação como $%d.", gPlayerCurrentPrize[playerid] + 1, prize);
					gPlayerRacePrize[playerid][gPlayerCurrentPrize[playerid]] = prize;
				}
			}
			new output[132];
			for(new i = 0; i < MAX_RACE_PLAYERS; i++)
			{
				if(gPlayerVehicles[playerid][i][e_vehicle_id])
				{
					new string[32];
					format(string, sizeof(string), "%dº posição\n", i + 1);
					strcat(output, string);
				}
			}
			ShowPlayerDialog(playerid, DIALOG_RACE_CREATOR_PRIZE, DIALOG_STYLE_LIST, "Premiações", output, "Selecionar", "Voltar");
		}
		case DIALOG_RACE_CREATOR_CONFIG:
		{
			if(!response)
			{
				PlayCancelSound(playerid);
				ShowPlayerRaceDialog(playerid);
			}
			else
			{
				switch (listitem)
				{
					case 0:
					{
						ShowPlayerDialog(playerid, DIALOG_RACE_CONFIG_CP_TYPE, DIALOG_STYLE_LIST, "Tipo do checkpoint", "Terrestre\nAerero", "Confirmar", "Voltar");
					}
					case 1:
					{
						ShowPlayerDialog(playerid, DIALOG_RACE_CONFIG_CP_SIZE, DIALOG_STYLE_INPUT, "Tamanho do checkpoint", "Insira o tamanho do checkpoint\nRecomendado: 3.5", "Confirmar", "Voltar");
					}
				}
			}
		}
		case DIALOG_RACE_CONFIG_CP_TYPE:
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
						gPlayerCheckpointType[playerid] = 1;
					case 1:
						gPlayerCheckpointType[playerid] = 4;
				}
				PlaySelectSound(playerid);
				GenerateCheckpoint(playerid);
			}
			ShowPlayerDialog(playerid, DIALOG_RACE_CREATOR_CONFIG, DIALOG_STYLE_LIST, "Configurações", "Tipo do checkpoint\nTamanho do checkpoint", "Selecionar", "Voltar");
		}
		case DIALOG_RACE_CONFIG_CP_SIZE:
		{
			if(!response)
			{
				PlayCancelSound(playerid);
			}
			else
			{
				new Float:size;
				if(sscanf(inputtext, "f", size))
				{
					PlayErrorSound(playerid);
					SendClientMessage(playerid, COLOR_ERROR, "* Valor inválido.");
					ShowPlayerDialog(playerid, DIALOG_RACE_CONFIG_CP_SIZE, DIALOG_STYLE_INPUT, "Tamanho do checkpoint", "Insira o tamanho do checkpoint\nRecomendado: 3.5", "Confirmar", "Voltar");
					return 1;
				}
				else
				{
					PlaySelectSound(playerid);
					SendClientMessagef(playerid, 0x35CEFBFF, "* Você definiu o tamanho do checkpoint %.2f.", size);
					gPlayerCheckpointSize[playerid] = size;
					GenerateCheckpoint(playerid);
				}
			}
			ShowPlayerDialog(playerid, DIALOG_RACE_CREATOR_CONFIG, DIALOG_STYLE_LIST, "Configurações", "Tipo do checkpoint\nTamanho do checkpoint", "Selecionar", "Voltar");
		}
	}
	return 1;
}

//------------------------------------------------------------------------------

public OnRaceExport(playerid)
{
    new race_id = cache_insert_id();

	new query[138];
	for(new i = 0; i < gPlayerCurrentCheckpoint[playerid]; i++)
	{
	    mysql_format(gMySQL, query, sizeof(query), "INSERT INTO race_checkpoints (race_id, x, y, z) VALUES (%d, %.2f, %.2f, %.2f)",
		race_id, gPlayerCheckpoints[playerid][i][e_checkpoint_x], gPlayerCheckpoints[playerid][i][e_checkpoint_y], gPlayerCheckpoints[playerid][i][e_checkpoint_z]);
	    mysql_tquery(gMySQL, query);
	}

	for(new i = 0; i < gPlayerCurrentVehicle[playerid]; i++)
	{
	    mysql_format(gMySQL, query, sizeof(query), "INSERT INTO race_vehicles (race_id, x, y, z, a, prize) VALUES (%d, %.2f, %.2f, %.2f, %.2f, %d)",
		race_id, gPlayerVehicles[playerid][i][e_vehicle_x], gPlayerVehicles[playerid][i][e_vehicle_y], gPlayerVehicles[playerid][i][e_vehicle_z], gPlayerVehicles[playerid][i][e_vehicle_a], gPlayerRacePrize[playerid][i]);
	    mysql_tquery(gMySQL, query);
	}

	PlayBuySound(playerid);
	SendClientMessage(playerid, COLOR_SUCCESS, "* Corrida criada com sucesso.");

	// Limpando dados temporários
	for(new i = 0; i < MAX_RACE_PLAYERS; i++)
	{
		if(gPlayerVehicles[playerid][i][e_vehicle_id])
		{
			DestroyVehicle(gPlayerVehicles[playerid][i][e_vehicle_id]);
			gPlayerVehicles[playerid][i][e_vehicle_id] = 0;
		}
	}
	gPlayerCheckpointType[playerid]		= 1;
	gPlayerCheckpointSize[playerid]		= 3.5;
	gIsPlayerCreatingRace[playerid]		= E_PLAYER_RACE_STATE_NONE;
	gPlayerCurrentCheckpoint[playerid]	= 0;
	DisablePlayerRaceCheckpoint(playerid);

	// Escrevendo no server_log
    new playerName[MAX_PLAYER_NAME];
    GetPlayerName(playerid, playerName, sizeof(playerName));
	printf("[mysql] new race inserted on database. ID: %d, by: %s", race_id, playerName);
	return 1;
}

//------------------------------------------------------------------------------

hook OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if(newkeys & KEY_YES)
    {
		switch (gIsPlayerCreatingRace[playerid])
		{
			case E_PLAYER_CREATING_CHECKPOINT:
			{
				new Float:x, Float:y, Float:z;
				if(IsPlayerInAnyVehicle(playerid))
				{
					GetVehiclePos(GetPlayerVehicleID(playerid), x, y, z);
				}
				else
				{
					GetPlayerPos(playerid, x, y, z);
				}

				gPlayerCheckpoints[playerid][gPlayerCurrentCheckpoint[playerid]][e_checkpoint_x] = x;
				gPlayerCheckpoints[playerid][gPlayerCurrentCheckpoint[playerid]][e_checkpoint_y] = y;
				gPlayerCheckpoints[playerid][gPlayerCurrentCheckpoint[playerid]][e_checkpoint_z] = z;
				gPlayerCurrentCheckpoint[playerid]++;

				PlaySelectSound(playerid);
				GenerateCheckpoint(playerid);
				SendClientMessagef(playerid, 0x35CEFBFF, "* Você criou o %dº checkpoint nas coordenadas %f, %f, %f.", gPlayerCurrentCheckpoint[playerid], x, y, z);
			}
			case E_PLAYER_CREATING_GRID:
			{
				if(gPlayerCurrentVehicle[playerid] < MAX_RACE_PLAYERS)
				{
					new Float:x, Float:y, Float:z, Float:a;
					if(IsPlayerInAnyVehicle(playerid))
					{
						GetVehicleZAngle(GetPlayerVehicleID(playerid), a);
						GetVehiclePos(GetPlayerVehicleID(playerid), x, y, z);
					}
					else
					{
						GetPlayerPos(playerid, x, y, z);
						GetPlayerFacingAngle(playerid, a);
					}

					gPlayerVehicles[playerid][gPlayerCurrentVehicle[playerid]][e_vehicle_x] = x;
					gPlayerVehicles[playerid][gPlayerCurrentVehicle[playerid]][e_vehicle_y] = y;
					gPlayerVehicles[playerid][gPlayerCurrentVehicle[playerid]][e_vehicle_z] = z;
					gPlayerVehicles[playerid][gPlayerCurrentVehicle[playerid]][e_vehicle_a] = a;

					PlaySelectSound(playerid);
					GenerateVehicle(playerid, false);
					SendClientMessagef(playerid, 0x35CEFBFF, "* Você criou o %dº veículo nas coordenadas %f, %f, %f, %f.", gPlayerCurrentVehicle[playerid] + 1, x, y, z, a);
					gPlayerCurrentVehicle[playerid]++;
				}
				else
				{
					PlayErrorSound(playerid);
					SendClientMessage(playerid, COLOR_ERROR, "* Você atingiu o limite máximo de jogadores por corrida.");
				}
			}
		}
    }
	else if(newkeys & KEY_NO)
    {
		switch (gIsPlayerCreatingRace[playerid])
		{
			case E_PLAYER_CREATING_CHECKPOINT:
			{
				if(gPlayerCurrentCheckpoint[playerid] > 0)
				{
					new Float:x, Float:y, Float:z;
					gPlayerCurrentCheckpoint[playerid]--;
					x = gPlayerCheckpoints[playerid][gPlayerCurrentCheckpoint[playerid]][e_checkpoint_x];
					y = gPlayerCheckpoints[playerid][gPlayerCurrentCheckpoint[playerid]][e_checkpoint_y];
					z = gPlayerCheckpoints[playerid][gPlayerCurrentCheckpoint[playerid]][e_checkpoint_z];

					PlayCancelSound(playerid);
					GenerateCheckpoint(playerid);
					SendClientMessagef(playerid, 0x35CEFBFF, "* Você deletou o %dº checkpoint nas coordenadas %f, %f, %f.", gPlayerCurrentCheckpoint[playerid] + 1, x, y, z);
				}
			}
			case E_PLAYER_CREATING_GRID:
			{
				if(gPlayerCurrentVehicle[playerid] > 0)
				{
					new Float:x, Float:y, Float:z, Float:a;
					gPlayerCurrentVehicle[playerid]--;
					x = gPlayerVehicles[playerid][gPlayerCurrentVehicle[playerid]][e_vehicle_x];
					y = gPlayerVehicles[playerid][gPlayerCurrentVehicle[playerid]][e_vehicle_y];
					z = gPlayerVehicles[playerid][gPlayerCurrentVehicle[playerid]][e_vehicle_z];
					a = gPlayerVehicles[playerid][gPlayerCurrentVehicle[playerid]][e_vehicle_a];

					PlayCancelSound(playerid);
					GenerateVehicle(playerid, true);
					SendClientMessagef(playerid, 0x35CEFBFF, "* Você deletou o %dº veículo nas coordenadas %f, %f, %f, %f.", gPlayerCurrentVehicle[playerid] + 1, x, y, z, a);
				}
			}
		}
    }
	else if(((newkeys & KEY_CROUCH) && IsPlayerInAnyVehicle(playerid)) || ((newkeys & KEY_CTRL_BACK) && !IsPlayerInAnyVehicle(playerid)))
    {
		if (gIsPlayerCreatingRace[playerid] > E_PLAYER_RACE_STATE_NONE)
		{
			PlaySelectSound(playerid);
			ShowPlayerRaceDialog(playerid);
		}
    }
    return 1;
}

//------------------------------------------------------------------------------


hook OnPlayerDisconnect(playerid, reason)
{
	gIsPlayerCreatingRace[playerid]		= E_PLAYER_RACE_STATE_NONE;
	gPlayerCheckpointType[playerid]		= 1;
	gPlayerCheckpointSize[playerid]		= 3.5;
	gPlayerCurrentCheckpoint[playerid]	= 0;
	return 1;
}

//------------------------------------------------------------------------------

static GenerateCheckpoint(playerid)
{
	if(gPlayerCurrentCheckpoint[playerid] > 0)
	{
		new Float:x, Float:y, Float:z;
		x = gPlayerCheckpoints[playerid][gPlayerCurrentCheckpoint[playerid] - 1][e_checkpoint_x];
		y = gPlayerCheckpoints[playerid][gPlayerCurrentCheckpoint[playerid] - 1][e_checkpoint_y];
		z = gPlayerCheckpoints[playerid][gPlayerCurrentCheckpoint[playerid] - 1][e_checkpoint_z];
		SetPlayerRaceCheckpoint(playerid, (gPlayerCheckpointType[playerid] > 0) ? gPlayerCheckpointType[playerid] : 1, x, y, z, 0.0, 0.0, 0.0, (gPlayerCheckpointSize[playerid] > 0.0) ? gPlayerCheckpointSize[playerid] : 3.5);
	}
	else
	{
		DisablePlayerRaceCheckpoint(playerid);
	}
}

//------------------------------------------------------------------------------

static GenerateVehicle(playerid, bool:delete)
{
	if(gPlayerCurrentVehicle[playerid] < MAX_RACE_PLAYERS)
	{
		if(delete)
		{
			if(gPlayerVehicles[playerid][gPlayerCurrentVehicle[playerid]][e_vehicle_id])
			{
				DestroyVehicle(gPlayerVehicles[playerid][gPlayerCurrentVehicle[playerid]][e_vehicle_id]);
				gPlayerVehicles[playerid][gPlayerCurrentVehicle[playerid]][e_vehicle_id] = 0;
			}
		}
		else
		{
			new Float:x, Float:y, Float:z, Float:a;
			x = gPlayerVehicles[playerid][gPlayerCurrentVehicle[playerid]][e_vehicle_x];
			y = gPlayerVehicles[playerid][gPlayerCurrentVehicle[playerid]][e_vehicle_y];
			z = gPlayerVehicles[playerid][gPlayerCurrentVehicle[playerid]][e_vehicle_z];
			a = gPlayerVehicles[playerid][gPlayerCurrentVehicle[playerid]][e_vehicle_a];

			if(gPlayerVehicles[playerid][gPlayerCurrentVehicle[playerid]][e_vehicle_id])
			{
				DestroyVehicle(gPlayerVehicles[playerid][gPlayerCurrentVehicle[playerid]][e_vehicle_id]);
			}
			gPlayerVehicles[playerid][gPlayerCurrentVehicle[playerid]][e_vehicle_id] = CreateVehicle((IsPlayerInAnyVehicle(playerid)) ? GetVehicleModel(GetPlayerVehicleID(playerid)) : 494, x, y, z + 5.0, a, -1, -1, -1);
		}
	}
}

//------------------------------------------------------------------------------

ShowPlayerRaceDialog(playerid)
{
	ShowPlayerDialog(playerid, DIALOG_RACE_CREATOR, DIALOG_STYLE_LIST, "Criando uma corrida", "Checkpoints\nGrid de largada\nPremiações\nConfigurações\nExportar\nCancelar", "Selecionar", "Sair");
}
